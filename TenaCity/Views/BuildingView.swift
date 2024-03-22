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
    @State var isShowingCreateHabitView = false
    @State var isHabitSheetPresented = false
    @State var selectedHabit: Habit? = nil
    
    func loadBuildings(user: User) {
        buildings = []
        for habitID in user.habitIDs {
            firestoreManager.fetchHabit(id: habitID) { habit, error in
                if let habit = habit {
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
                    print("Error fetching habit: \(error)")
                    buildings.append((nil, nil))
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            if let user = authManager.user {
                ScrollView {
                    Text("Your Habits")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                        .padding(.bottom, 30)
                    
                    if user.habitIDs.count == 0 {
                        Text("No habits created. Click the info button on top right to learn about this app!").foregroundColor(.gray)
                    }
                    else if buildings.count == user.habitIDs.count {
                        ForEach(user.habitIDs, id: \.self) { habitID in
                            if let building = buildings.first(where: { $0.0?.id == habitID }) {
                                if let habit = building.0, let skin = building.1, habit.isPublic == false {
                                    VStack {
                                        AsyncImage(
                                            url: URL(string: skin.url),
                                            content: { image in
                                                image.resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 150, height: 150)
                                                    .cornerRadius(12)
                                                    .padding(.bottom, 7)
                                            },
                                            placeholder: {
                                                ProgressView()
                                            }
                                        )
                                        
                                        Text(habit.name)
                                            .font(.title3)
                                            .padding(.bottom, 10)
                                            .bold()
                                        
                                        ProgressBar(progress: min(Int(habit.progress * 100), habit.goal * 100), goal: habit.goal * 100)
                                            .frame(height: 10)
                                            .padding()
                                    }
                                    .padding(10)
                                    .sheet(isPresented: $isHabitSheetPresented) {
                                        if let habit = selectedHabit {
                                            HabitDetailView(habit: habit)
                                        }
                                    }
                                    .onTapGesture {
                                        selectedHabit = habit
                                        isHabitSheetPresented = true
                                    }
                                }
                            }
                        }.padding(10)
                    } else {
                        ProgressView()
                    }
                }
                .padding()
                .sheet(isPresented: $isShowingCreateHabitView) {
                    CreateHabitView(isShowingCreateHabitView: $isShowingCreateHabitView, user: user)
                }
                .onAppear(perform: {
                    loadBuildings(user: user)
                })
                .onChange(of: isShowingCreateHabitView) {
                    loadBuildings(user: user)
                }
                
                Spacer()
                Button(action: {
                    isShowingCreateHabitView = true
                }) {
                    Text("Create Habit")
                        .padding()
                        .background(Color("Orange"))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }.padding()
            } else {
                Text("User data not available")
                    .padding()
            }
        }
        .background(
            Image("basicBackground")
//                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
                .opacity(0.8)
        )
    }
}

struct HabitDetailView: View {
    let habit: Habit

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Habit Name: \(habit.name)")
                .font(.headline)
            Text("ID: \(habit.id)")
            Text("Building ID: \(habit.buildingID)")
            Text("Streak: \(habit.streak) days")
            Text("Is Public: \(habit.isPublic ? "Yes" : "No")")
            Text("Goal: \(habit.goal) \(habit.identifier)")
            Text("Progress: \(habit.progress) \(habit.identifier)")
            Text("Note: \(habit.note.description)") 
        }
        .padding()
    }
}
