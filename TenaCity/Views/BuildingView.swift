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
    @State var isBuildingAnimationShowing = false
    @State var rotationDegrees: Double = 0.0
    @State var rotateImage: Bool = true
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            if let user = authManager.user {
                ScrollView {
                    Text("Your Habits")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                        .padding(.bottom, 30)
                    
                    if buildings.count == user.habitIDs.count {
                        ForEach(user.habitIDs, id: \.self) { habitID in
                            if let building = buildings.first(where: { $0.0?.id == habitID }) {
                                if let habit = building.0, let skin = building.1 {
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
                                        
                                        ProgressBar(progress: habit.progress, goal: habit.goal)
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
                        
                        Button(action: {
                            isShowingCreateHabitView = true
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Create Habit")
                                    .font(.headline)
                            }
                            .padding(20)
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(10)
                        }
                    } else {
                        ProgressView()
                        ForEach(user.habitIDs, id: \.self) { habitID in
                            let _ = firestoreManager.fetchHabit(id: habitID) { habit, error in
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
                }
                .padding()
                .sheet(isPresented: $isShowingCreateHabitView) {
                    CreateHabitView()
                }
                .popover(isPresented: $isBuildingAnimationShowing, content: {
                    VStack {
                        if rotateImage {
                            AsyncImage(
                                url: URL(string: "https://media.istockphoto.com/id/1358860685/vector/house-icon-pixel-art-front-view-a-small-hut-vector-simple-flat-graphic-illustration-the.jpg?s=612x612&w=0&k=20&c=qodGeD6HSaJKRrZhglbSjXnGnrdXVZsyAlwdlcPaDZw="),
                                content: { image in
                                    image.resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 150, height: 150)
                                        .rotation3DEffect(.degrees(rotationDegrees), axis: (x: 0, y: 1, z: 0))
                                        .onReceive(timer) { _ in
                                            rotationDegrees += 2.5
                                        }
                                        .onTapGesture {
                                            rotateImage = false
                                        }
                                },
                                placeholder: {
                                    ProgressView()
                                }
                            )
                        } else {
                            AsyncImage(
                                url: URL(string: "https://static.vecteezy.com/system/resources/previews/011/453/045/original/skyscraper-pixel-art-style-free-vector.jpg"),
                                content: { image in
                                    image.resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 150, height: 150)
                                },
                                placeholder: {
                                    ProgressView()
                                }
                            )
                        }
                        Text("Reached next level for [habit]!")
                        Text("Tap to reveal the next building.")
                        Button("Close") {
                            isBuildingAnimationShowing = false
                        }
                        .padding()
                    }
                    .frame(width: 200, height: 200)
                    .cornerRadius(10)
                })
                .onAppear(perform: {
                    print("appeared")
                    //isBuildingAnimationShowing = true
                })
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
            Text("Note: \(habit.note.description)") // Assuming note is a dictionary
        }
        .padding()
    }
}
