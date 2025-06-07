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
    private var lastDataFetch: Date = .distantPast
    private let minimumFetchInterval: TimeInterval = 1  // lowered for Quick Fix 1

    init() { }

    // MARK: Authorization
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health Data not available on device")
            return
        }
        // build an Array<HKObjectType?> then compactMap to [HKObjectType]
          let typesArray: [HKObjectType?] = [
              HKQuantityType.quantityType(forIdentifier: .stepCount),
              HKQuantityType.quantityType(forIdentifier: .appleExerciseTime),
              HKQuantityType.quantityType(forIdentifier: .heartRate),
              HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)
          ]

          // now wrap into a Set<HKObjectType>
          let readTypes: Set<HKObjectType> = Set(typesArray.compactMap { $0 })
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            DispatchQueue.main.async {
                if success {
                    self.healthKitAuthorized = true
                    self.shouldShowHealthKitHelp = false
                    print("HealthKit Authorized!")

                    // 1) start live heart-rate streaming
                    self.startHeartRateStreaming()

                    // 2) then your usual batch fetch
                    self.fetchAllHealthData()

                    // 3) set up observers for background updates
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

    // MARK: Live Streaming for Heart Rate
    func startHeartRateStreaming() {
        guard let hrType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }
        let predicate = HKQuery.predicateForSamples(withStart: Date(), end: nil, options: .strictStartDate)

        let streamQuery = HKAnchoredObjectQuery(
            type: hrType,
            predicate: predicate,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] _, samples, _, newAnchor, error in
            self?.processHeartRateSamples(samples)
        }

        streamQuery.updateHandler = { [weak self] _, samples, _, newAnchor, error in
            self?.processHeartRateSamples(samples)
        }

        healthStore.execute(streamQuery)
    }

    private func processHeartRateSamples(_ samples: [HKSample]?) {
        guard let qtySamples = samples as? [HKQuantitySample], let first = qtySamples.first else { return }
        let bpm = first.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
        DispatchQueue.main.async {
            self.latestHeartRate = bpm
            print("DEBUG: Streamed HR = \(bpm)")
        }
    }

    // MARK: Fetch All with Rate Limiting
    func fetchAllHealthData() {
        let now = Date()
        if now.timeIntervalSince(lastDataFetch) < minimumFetchInterval {
            print("DEBUG: Skipping data fetch - too soon (last fetch: \(lastDataFetch))")
            return
        }
        print("DEBUG: Fetching all health data.")
        lastDataFetch = now

        fetchQuantity(.stepCount) {
            print("DEBUG: Steps fetched: \($0)"); self.latestSteps = $0
        }
        fetchQuantity(.appleExerciseTime) {
            print("DEBUG: Exercise minutes fetched: \($0)"); self.latestExerciseMinutes = $0
        }
        fetchQuantity(.heartRate) {
            print("DEBUG: BATCH heart rate fetched: \($0)");
            // batch will fill in only if stream hasn't already
            if self.latestHeartRate <= 0 { self.latestHeartRate = $0 }
        }
        fetchSleepStage()
    }

    // MARK: Helpers
    private func fetchQuantity(_ typeIdentifier: HKQuantityTypeIdentifier,
                               completion: @escaping (Double) -> Void) {
        guard let type = HKQuantityType.quantityType(forIdentifier: typeIdentifier) else {
            completion(0); return
        }

        let calendar = Calendar.current
        let now = Date()
        let predicate: NSPredicate
        let limit: Int

        if typeIdentifier == .stepCount || typeIdentifier == .appleExerciseTime {
            // today's data
            let startOfDay = calendar.startOfDay(for: now)
            predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
            limit = HKObjectQueryNoLimit
        } else {
            // widen to last 24h for heart rate (Quick Fix 3)
            let oneDayAgo = calendar.date(byAdding: .day, value: -1, to: now)!
            predicate = HKQuery.predicateForSamples(withStart: oneDayAgo, end: now, options: .strictStartDate)
            limit = HKObjectQueryNoLimit
        }

        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: type,
                                  predicate: predicate,
                                  limit: limit,
                                  sortDescriptors: [sort]) { _, samples, error in
            if let error = error {
                print("Error fetching \(typeIdentifier): \(error.localizedDescription)")
                DispatchQueue.main.async { completion(0) }
                return
            }
            guard let qty = samples as? [HKQuantitySample], !qty.isEmpty else {
                print("DEBUG: No samples for \(typeIdentifier)");
                DispatchQueue.main.async { completion(0) }
                return
            }

            let unit: HKUnit = (typeIdentifier == .heartRate)
                ? HKUnit.count().unitDivided(by: .minute())
                : (typeIdentifier == .appleExerciseTime ? .minute() : .count())

            var value: Double = 0
            if typeIdentifier == .stepCount || typeIdentifier == .appleExerciseTime {
                // sum all
                value = qty.reduce(0) { $0 + $1.quantity.doubleValue(for: unit) }
            } else {
                // average last 5 readings
                let samples = Array(qty.prefix(5))
                let sum = samples.reduce(0) { $0 + $1.quantity.doubleValue(for: unit) }
                value = sum / Double(samples.count)
            }

            DispatchQueue.main.async { completion(value) }
        }
        healthStore.execute(query)
    }

    private func fetchSleepStage() {
        guard let type = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else { return }
        let now = Date()
        let eightHoursAgo = Calendar.current.date(byAdding: .hour, value: -8, to: now)!
        let predicate = HKQuery.predicateForSamples(withStart: eightHoursAgo, end: now, options: .strictStartDate)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        let query = HKSampleQuery(sampleType: type,
                                  predicate: predicate,
                                  limit: 1,
                                  sortDescriptors: [sort]) { _, samples, error in
            if let error = error {
                print("Error fetching sleep: \(error.localizedDescription)"); return
            }
            guard let sample = samples?.first as? HKCategorySample else {
                DispatchQueue.main.async {
                    print("DEBUG: No recent sleep data found")
                    self.latestSleepStage = "Unknown"
                }
                return
            }
            let stage = HKCategoryValueSleepAnalysis(rawValue: sample.value)
            let desc: String
            switch stage {
            case .asleepREM:   desc = "REM"
            case .asleepCore:  desc = "Core"
            case .asleepDeep:  desc = "Deep"
            case .awake:       desc = "Awake"
            case .inBed:       desc = "In Bed"
            default:           desc = "Unknown"
            }
            DispatchQueue.main.async {
                print("DEBUG: Sleep fetched: \(desc)"); self.latestSleepStage = desc
            }
        }
        healthStore.execute(query)
    }

    // MARK: Observers
    func startObservers() {
        print("DEBUG: Starting health data observers...")
        stopObservers()
        let types: [HKSampleType?] = [
            HKQuantityType.quantityType(forIdentifier: .stepCount),
            HKQuantityType.quantityType(forIdentifier: .appleExerciseTime),
            HKObjectType.quantityType(forIdentifier: .heartRate),
            HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)
        ]
        for t in types.compactMap({ $0 }) {
            let q = HKObserverQuery(sampleType: t, predicate: nil) { [weak self] _, cb, err in
                if err != nil { cb(); return }
                DispatchQueue.main.async { self?.fetchAllHealthData() }
                cb()
            }
            observerQueries.append(q)
            healthStore.execute(q)
            healthStore.enableBackgroundDelivery(for: t, frequency: .hourly) { success, err in
                if success { print("Background delivery enabled for \(t)") }
            }
        }
    }

    func stopObservers() {
        observerQueries.forEach { healthStore.stop($0) }
        observerQueries.removeAll()
    }

    deinit {
        stopObservers()
    }
}
