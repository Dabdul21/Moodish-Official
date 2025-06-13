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
    @Published var healthKitAuthorized = false
    @Published var healthKitChanges: [String] = []
    @Published var latestSteps: Double = 0
    @Published var latestExerciseMinutes: Double = 0
    @Published var latestSleepStage: String = "Unknown"
    @Published var latestHeartRate: Double = 0
    @Published var shouldShowHealthKitHelp: Bool = false
    
    private var observerQueries: [HKObserverQuery] = []
    private var lastDataFetch: Date = Date.distantPast
    private let minimumFetchInterval: TimeInterval = 5 // Only fetch every 60 seconds

    init() { }
    
    // MARK: Authorization
    
//    <key>NSHealthShareUsageDescription</key>
//    <string>This app needs access to your health data to provide personalized insights.</string>
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health Data not available on device")
            return
        }
        
        let readTypes: Set<HKObjectType> = Set([
            HKQuantityType.quantityType(forIdentifier: .stepCount),
            HKQuantityType.quantityType(forIdentifier: .appleExerciseTime),
            HKQuantityType.quantityType(forIdentifier: .heartRate),
            HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)
        ].compactMap { $0 })

        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            DispatchQueue.main.async {
                if success {
                    self.healthKitAuthorized = true
                    self.shouldShowHealthKitHelp = false
                    print("HealthKit Authorized!")
                    self.fetchAllHealthData()
                    self.startObservers()
                } else {
                    self.healthKitAuthorized = false
                    self.shouldShowHealthKitHelp = true
                    print("HealthKit authorization failed")

                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    // MARK: Fetch All with Rate Limiting
    func fetchAllHealthData() {
        // Rate limiting - don't fetch too frequently
        let now = Date()
        if now.timeIntervalSince(lastDataFetch) < minimumFetchInterval {
            print("DEBUG: Skipping data fetch - too soon (last fetch: \(lastDataFetch))")
            return
        }
        
        print("DEBUG: Fetching all health data...")
        lastDataFetch = now
        
        fetchQuantity(.stepCount) {
            print("DEBUG: Steps fetched: \($0)")
            self.latestSteps = $0
        }
        fetchQuantity(.appleExerciseTime) {
            print("DEBUG: Exercise minutes fetched: \($0)")
            self.latestExerciseMinutes = $0
        }
        fetchQuantity(.heartRate) {
            print("DEBUG: Heart rate fetched: \($0)")
            self.latestHeartRate = $0
        }
        fetchSleepStage()
    }
    
    // MARK: Helpers
    private func fetchQuantity(_ typeIdentifier: HKQuantityTypeIdentifier, completion: @escaping (Double) -> Void) {
        guard let type = HKQuantityType.quantityType(forIdentifier: typeIdentifier) else {
            completion(0)
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        let predicate: NSPredicate?
        let limit: Int
        
        if typeIdentifier == .stepCount || typeIdentifier == .appleExerciseTime {
            // For cumulative data, get today's data
            let startOfDay = calendar.startOfDay(for: now)
            predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
            limit = HKObjectQueryNoLimit
        } else {
            // For heart rate, get recent data (last 2 hours)
            let twoHoursAgo = calendar.date(byAdding: .hour, value: -2, to: now) ?? now
            predicate = HKQuery.predicateForSamples(withStart: twoHoursAgo, end: now, options: .strictStartDate)
            limit = 10 // Get multiple recent samples for better average
        }
        
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(
            sampleType: type,
            predicate: predicate,
            limit: limit,
            sortDescriptors: [sort]
        ) { _, samples, error in
            
            if let error = error {
                print("Error fetching \(typeIdentifier): \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(0)
                }
                return
            }
            
            guard let samples = samples as? [HKQuantitySample], !samples.isEmpty else {
                print("DEBUG: No samples found for \(typeIdentifier)")
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
            
            var totalValue: Double = 0
            
            if typeIdentifier == .stepCount || typeIdentifier == .appleExerciseTime {
                // Sum all samples for cumulative data
                for sample in samples {
                    totalValue += sample.quantity.doubleValue(for: unit)
                }
            } else if typeIdentifier == .heartRate {
                // Average recent heart rate samples for more stable reading
                let recentSamples = Array(samples.prefix(5)) // Last 5 readings
                if !recentSamples.isEmpty {
                    let sum = recentSamples.reduce(0.0) { $0 + $1.quantity.doubleValue(for: unit) }
                    totalValue = sum / Double(recentSamples.count)
                }
            }
            
            DispatchQueue.main.async {
                completion(totalValue)
            }
        }
        
        healthStore.execute(query)
    }

    private func fetchSleepStage() {
        guard let type = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else {
            return
        }

        // Get sleep data from last 8 hours (more realistic window)
        let calendar = Calendar.current
        let now = Date()
        let eightHoursAgo = calendar.date(byAdding: .hour, value: -8, to: now) ?? now
        
        let predicate = HKQuery.predicateForSamples(withStart: eightHoursAgo, end: now, options: .strictStartDate)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(
            sampleType: type,
            predicate: predicate,
            limit: 1,
            sortDescriptors: [sort]
        ) { _, samples, error in
            
            if let error = error {
                print("Error fetching sleep stage: \(error.localizedDescription)")
                return
            }

            guard let firstSample = samples?.first as? HKCategorySample else {
                DispatchQueue.main.async {
                    print("DEBUG: No recent sleep data found")
                    self.latestSleepStage = "Unknown"
                }
                return
            }
            
            let sleepStage = HKCategoryValueSleepAnalysis(rawValue: firstSample.value)

            DispatchQueue.main.async {
                let stageDescription = self.describeSleepStage(sleepStage)
                print("DEBUG: Sleep stage fetched: \(stageDescription)")
                self.latestSleepStage = stageDescription
            }
        }
        
        healthStore.execute(query)
    }

    private func describeSleepStage(_ value: HKCategoryValueSleepAnalysis?) -> String {
        switch value {
        case .some(.asleepREM): return "REM"
        case .some(.asleepCore): return "Core"
        case .some(.asleepDeep): return "Deep"
        case .some(.awake): return "Awake"
        case .some(.inBed): return "In Bed"
        default: return "Unknown"
        }
    }
    
    // MARK: - Observer Queries with Rate Limiting
    func startObservers() {
        print("DEBUG: Starting health data observers...")
        
        stopObservers()
        
        let typesToObserve: [HKSampleType?] = [
            HKQuantityType.quantityType(forIdentifier: .stepCount),
            HKQuantityType.quantityType(forIdentifier: .appleExerciseTime),
            HKQuantityType.quantityType(forIdentifier: .heartRate),
            HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)
        ]
        
        for type in typesToObserve.compactMap({ $0 }) {
            let query = HKObserverQuery(sampleType: type, predicate: nil) { [weak self] _, completionHandler, error in
                if let error = error {
                    print("Observer error for \(type): \(error.localizedDescription)")
                    completionHandler()
                    return
                }
                
                print("DEBUG: Health data changed for type: \(type)")
                
                // Rate limit the data fetching from observers too
                DispatchQueue.main.async {
                    self?.fetchAllHealthData()
                }
                
                completionHandler()
            }

            observerQueries.append(query)
            healthStore.execute(query)

            // Use less frequent background delivery
            healthStore.enableBackgroundDelivery(for: type, frequency: .hourly) { success, error in
                if let error = error {
                    print("Background delivery error: \(error.localizedDescription)")
                } else if success {
                    print("Background delivery enabled for \(type)")
                }
            }
        }
    }
    
    func stopObservers() {
        for query in observerQueries {
            healthStore.stop(query)
        }
        observerQueries.removeAll()
    }
    
    deinit {
        stopObservers()
    }
}
