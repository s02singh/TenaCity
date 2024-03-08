//
//  DeviceActivityManager.swift
//  TenaCity
//
//  Created by Shikhar Gupta on 3/7/24.
//

import SwiftUI
import FamilyControls
import DeviceActivity


class DeviceActivityManager: ObservableObject {
    let ac = AuthorizationCenter.shared
    var activitySelection = FamilyActivitySelection()
    
    let schedule = DeviceActivitySchedule(
        intervalStart: DateComponents(hour: 0, minute: 0, second: 0),
        intervalEnd: DateComponents(hour: 23, minute: 59, second: 59),
        repeats: true
    )
    
    
    init() {
        Task {
            do {
                try await ac.requestAuthorization(for: .individual)
            }
            catch {
                print("Error in getting screen time permissions")
            }
        }
    }
    
    func setLimit(limit: Int, selection: UIApplication) {
        let activity = DeviceActivityName("MyApp.ScreenTime")

        let event = DeviceActivityEvent(
            applications: selection.applicationTokens,
            categories: selection.categoryTokens,
            webDomains: selection.webDomainTokens,
            threshold: DateComponents(minute: limit)
        )
    }
}
