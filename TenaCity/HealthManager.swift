//
//  HealthManager.swift
//  TenaCity
//
//  Created by Shikhar Gupta on 2/29/24.
//

import SwiftUI
import HealthKit

class HealthManager: ObservableObject {
    let healthStore = HKHealthStore()
    
    init() {
        let steps = HKQuantityType.quantityType(forIdentifier: .stepCount)
        let distance = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)
        let calories = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)
        
        if let steps = steps, let distance = distance, let calories = calories {
            let healthTypes: Set = [steps, distance, calories]
            
            Task {
                do {
                    try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
                } catch {
                    print("Error getting health data")
                }
            }
        }
    }
    
    func fetchTodaySteps(completion: @escaping (Double?, Error?) -> Void) {
        let steps = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: Date()), end: Date())
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) {_, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else {
                completion(nil, error)
                return
            }
            
            let stepCount = quantity.doubleValue(for: .count())
            completion(stepCount, nil)
        }
        
        healthStore.execute(query)
    }

    
    func fetchTodayDistance(completion: @escaping (Double?, Error?) -> Void) {
        let distance = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: Date()), end: Date())
        let query = HKStatisticsQuery(quantityType: distance, quantitySamplePredicate: predicate) {_, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else {
                completion(nil, error)
                return
            }
            
            let distanceValue = quantity.doubleValue(for: .meter())
            completion(distanceValue, nil)
        }
        
        healthStore.execute(query)
    }

    func fetchTodayCaloriesBurned(completion: @escaping (Double?, Error?) -> Void) {
        let calories = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: Date()), end: Date())
        let query = HKStatisticsQuery(quantityType: calories, quantitySamplePredicate: predicate) {_, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else {
                completion(nil, error)
                return
            }
            
            let calorieCount = quantity.doubleValue(for: .kilocalorie())
            completion(calorieCount, nil)
        }
        
        healthStore.execute(query)
    }

}
