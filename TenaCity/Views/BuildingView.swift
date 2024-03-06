//
//  BuildingView.swift
//  TenaCity
//
//  Created by Shikhar Gupta on 2/26/24.
//

import SwiftUI

struct BuildingView: View {
    @EnvironmentObject var authManager: AuthManager
    @ObservedObject var firestoreManager = FirestoreManager()
    @State var buildings: [(Habit?, Skin?)] = []
    @EnvironmentObject var healthManager: HealthManager
    
    var body: some View {
        VStack {
            if let user = authManager.user {
                let _ = print(user.habitIDs)
                ScrollView {
                    Text("Habits")
                    if buildings.count == user.habitIDs.count {
                        ForEach(user.habitIDs, id: \.self) { habitID in
                            if let building = buildings.first(where: { $0.0?.id == habitID }) {
                                if let habit = building.0, let skin = building.1 {
                                    VStack {
                                        Text("Habit Name: \(habit.name)")
                                        Text("Goal: \(habit.goal) \(habit.identifier)")
                                        Text("Progress: \(habit.progress) \(habit.identifier)")
                                        Text("Streak: \(habit.streak) days")
                                        Text("Note: \(habit.note)")
                                        AsyncImage(
                                            url: URL(string: skin.url),
                                            content: { image in
                                                image.resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(maxWidth: 100, maxHeight: 200)
                                            },
                                            placeholder: {
                                                ProgressView()
                                            }
                                        )
                                    }
                                    .padding(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.blue, lineWidth: 2)
                                    )
                                }
                            }
                        }
                    } else {
                        ProgressView()
                        ForEach(user.habitIDs, id: \.self) { habitID in
                            let _ = firestoreManager.fetchHabit(id: habitID) { habit, error in
                                if let habit = habit {
                                    let _ = print(habit)
                                    firestoreManager.fetchBuilding(id: habit.buildingID) { building, error in
                                        if let building = building {
                                            firestoreManager.fetchSkin(id: building.levelsIDs[0]) { skin, error in
                                                if let skin = skin {
                                                    buildings.append((habit, skin))
                                                } else {
                                                    print("Error fetching skin from building")
                                                    buildings.append((nil, nil))
                                                }
                                            }
                                        } else {
                                            print("Error fetching building from habit")
                                            buildings.append((nil, nil))
                                        }
                                    }
                                } else {
                                    print("Error fetching habit")
                                    buildings.append((nil, nil))
                                }
                            }
                        }
                        
                    }
                }
                .padding()
            } else {
                Text("User data not available")
                    .padding()
            }
            Spacer()
            NavigationBar()
        }
    }
}

#Preview {
    BuildingView()
}
