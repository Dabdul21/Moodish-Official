//
//  HealthManager.swift
//  LateNitesEarlyMornin
//
//  Created by Dayan Abdulla on 5/27/25.
//

import WatchKit
import HealthKit
import Combine

class HealthManager: ObservableObject {
    // MARK: Properties
    let healthStore = HKHealthStore()
    var healthKitAuthorized = false
    @Published var healthKitChanges: [String] = []
    @Published var latestSteps: Double = 0
    @Published var latestExerciseMinutes: Double = 0
    @Published var latestSleepStage: String = "Unknown"
    @Published var latestHeartRate: Double = 0
    @Published var shouldShowHealthKitHelp: Bool = false

    init() { }
    
    // MARK: Authorization
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health Data not available on device")
            return
        }
        
        // USES SOMETHING CALLED "compactMap" To unwrap and convert the objects. It will crash if you remove.
        let readTypes: Set<HKObjectType> = Set([
            HKQuantityType.quantityType(forIdentifier: .stepCount),
            HKQuantityType.quantityType(forIdentifier: .appleExerciseTime),
            HKQuantityType.quantityType(forIdentifier: .heartRate),
            HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)
        ].compactMap { $0 })

        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            // WE USE DISPATCH TO UPDATE THE PROPERTIES IN THE BACKGROUND. THEN CALLS fetchAllData
            DispatchQueue.main.async {
                if success {
                    self.healthKitAuthorized = true
                    self.shouldShowHealthKitHelp = false // help screen flag
                    print("Authorized!")
                    self.fetchAllHealthData()
                } else {
                    self.healthKitAuthorized = false
                    self.shouldShowHealthKitHelp = true // triggers help screen
                    print("HealthKit authorization failed")

                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                    }
                }
            }
        } // END: HealthKit Auth lets us read all those properties
    } // END OF requestAuthorization FUNCTION
    
    // MARK: Fetch All
    func fetchAllHealthData() {
        fetchQuantity(.stepCount) { self.latestSteps = $0 }
        fetchQuantity(.appleExerciseTime) { self.latestExerciseMinutes = $0 }
        fetchQuantity(.heartRate) { self.latestHeartRate = $0 }
        fetchSleepStage()
    } // END OF fetchAllHealthData FUNCTION
    
    // MARK: Helpers
    private func fetchQuantity(_ typeIdentifier: HKQuantityTypeIdentifier, completion: @escaping (Double) -> Void) {
        // WILL CONVERT IDENTIFIERS INTO A REAL HKQuantityType if it fails it returns early
        guard let type = HKQuantityType.quantityType(forIdentifier: typeIdentifier) else { 
            completion(0)
            return 
        }
        
        // SORTS RESULTS BY END DATE NEWEST WILL BE FIRST
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        // ASKS FOR THE MOST RECENT SAMPLE: limit 1 means give me the latest val
        let query = HKSampleQuery(
            sampleType: type,
            predicate: nil,
            limit: 1,
            sortDescriptors: [sort]
        ) { _, samples, error in
            
            // Handle errors
            if let error = error {
                print("Error fetching \(typeIdentifier): \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(0)
                }
                return
            }
            
            // Just returns 0 if you get no sample
            guard let sample = samples?.first as? HKQuantitySample else {
                DispatchQueue.main.async {
                    completion(0)
                }
                return
            }
            
            let unit: HKUnit
            switch typeIdentifier {
            case .heartRate:
                unit = HKUnit(from: "count/min")
            case .appleExerciseTime:
                unit = .minute()
            default:
                unit = .count()
            }

            
            // Completion returns the result from healthkit and doubleValue converts raw data to a readable double
            DispatchQueue.main.async {
                completion(sample.quantity.doubleValue(for: unit))
            }
        }
        
        healthStore.execute(query)
    } // END OF fetchQuantity FUNCTION

    private func fetchSleepStage() {
        // Will convert into a HKCategoryType sleepAnalysis
        guard let type = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else { 
            return 
        }

        // Sorts sleep samples by endDate in descending order
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(
            sampleType: type,
            predicate: nil,
            limit: 1,
            sortDescriptors: [sort]
        ) { _, samples, error in
            
            // Handle errors
            if let error = error {
                print("Error fetching sleep stage: \(error.localizedDescription)")
                return
            }

            // Check to see if a valid sleep sample is actually returned
            guard let firstSample = samples?.first as? HKCategorySample else {
                DispatchQueue.main.async {
                    self.latestSleepStage = "Unknown"
                }
                return
            }
            
            // It will then convert the value to a numeric number so it can be used by the enum
            let sleepStage = HKCategoryValueSleepAnalysis(rawValue: firstSample.value)

            // Update the published property on the main thread
            DispatchQueue.main.async {
                self.latestSleepStage = self.describeSleepStage(sleepStage)
            }
        }
        
        healthStore.execute(query)
    } // END OF fetchSleepStage FUNCTION

    private func describeSleepStage(_ value: HKCategoryValueSleepAnalysis?) -> String {
        switch value {
        case .some(.asleepREM): return "REM"
        case .some(.asleepCore): return "Core"
        case .some(.asleepDeep): return "Deep"
        case .some(.awake): return "Awake"
        case .some(.inBed): return "In Bed"
        default: return "Unknown"
        }
    } // END OF describeSleepStage FUNCTION
    
    // MARK: - Observer Queries

    func startObservers() {
        let typesToObserve: [HKSampleType?] = [
            HKQuantityType.quantityType(forIdentifier: .stepCount),
            HKQuantityType.quantityType(forIdentifier: .appleExerciseTime),
            HKQuantityType.quantityType(forIdentifier: .heartRate),
            HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)
        ]
        
        for type in typesToObserve.compactMap({ $0 }) {
            let query = HKObserverQuery(sampleType: type, predicate: nil) { [weak self] _, _, error in
                if let error = error {
                    print("Observer error for \(type): \(error.localizedDescription)")
                    return
                }
                
                print("Health data changed: \(type)")
                self?.fetchAllHealthData()
            }

            healthStore.execute(query)

            // Request background delivery (watchOS supports limited modes)
            healthStore.enableBackgroundDelivery(for: type, frequency: .immediate) { success, error in
                if let error = error {
                    print("Background delivery error: \(error.localizedDescription)")
                } else if success {
                    print("Background delivery enabled for \(type)")
                }
            }
        }
    }

} // END OF HEALTH MANAGER CLASS

// MARK: DOCS
/*
Section         Item                              Type                                  Description                                                                                         Return ->
Properties    healthStore                         HKHealthStore                       The main HealthKit interface used to request authorization and execute health data queries.
Properties    healthKitAuthorized                 Bool                           Tracks whether HealthKit authorization was successfully granted.
Properties    @Published latestSteps              Double                      The latest step count retrieved from HealthKit.
Properties    @Published latestExerciseMinutes    Double            The latest exercise time in minutes retrieved from HealthKit.
Properties    @Published latestSleepStage         String                 The latest sleep stage retrieved and converted to a human-readable string.
Properties    @Published latestHeartRate          Double                  The most recent heart rate value (BPM) retrieved from HealthKit.
Functions    requestAuthorization()                                 Requests read access from the user for required HealthKit data types. On success, fetches the latest health data. ->   Void
Functions    fetchAllHealthData()                                   Fetches the latest values for steps, exercise time, heart rate, and sleep stage.                                  ->       Void
Functions    fetchQuantity(_:completion:)                           Fetches the latest quantity sample for a given HealthKit quantity type (e.g., step count, heart rate). Calls the completion handler with a Double result.                                                                                                                                                                               -> Void
Functions    fetchSleepStage()                                      Fetches the latest sleep analysis category sample and updates the `latestSleepStage` property.                      -> Void
Functions    describeSleepStage(_:)                                 Converts a `HKCategoryValueSleepAnalysis` value into a human-readable sleep stage string (e.g., REM, Core, Deep).   -> String
*/
