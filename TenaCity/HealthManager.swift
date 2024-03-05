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
        
        fetchTodaySteps()
        fetchTodayDistance()
        fetchTodayCaloriesBurned()
    }
    
    func fetchTodaySteps() {
        let steps = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: Date()), end: Date())
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) {_, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else {
                print("error getting todays step data")
                return
            }
            
            let stepCount = quantity.doubleValue(for: .count())
            print(stepCount, "steps")
        }
        
        healthStore.execute(query)
    }
    
    func fetchTodayDistance() {
        let distance = HKQuantityType(.distanceWalkingRunning)
        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: Date()), end: Date())
        let query = HKStatisticsQuery(quantityType: distance, quantitySamplePredicate: predicate) {_, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else {
                print("error getting todays distance data")
                return
            }
            
            //let mileCount = quantity / 1609.34      // convert meters to miles
            print(quantity)
        }
        
        healthStore.execute(query)
    }
    
    func fetchTodayCaloriesBurned() {
        let calories = HKQuantityType(.activeEnergyBurned)
        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: Date()), end: Date())
        let query = HKStatisticsQuery(quantityType: calories, quantitySamplePredicate: predicate) {_, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else {
                print("error getting todays calories data")
                return
            }
            
            //let calorieCount = quantity.doubleValue(for: .count())
            print(quantity, "calories")
        }
        
        healthStore.execute(query)
    }
}
