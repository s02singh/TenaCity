//
//  CreateHabitView.swift
//  TenaCity
//
//  Created by Shikhar Gupta on 3/7/24.
//

import SwiftUI

struct CreateHabitView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authManager: AuthManager
    @ObservedObject var firestoreManager = FirestoreManager()
    @State var selectedHabit: String = habitNames[0]
    @State var goal: String = "10"
    @State var selectedBuilding: Building? = nil
    @State var selectedBuildingName: String = ""
    @State var name: String = ""
    @State var buildings: [Building]? = nil
    @Binding var isShowingCreateHabitView: Bool
    @State var user: User
    
    var body: some View {
        if let buildings = buildings {
            Form {
                Section(header: Text("Name").font(.headline)) {
                    TextField("My Habit Name", text: $name)
                }
                Section(header: Text("Habit Type").font(.headline)) {
                    List {
                        ForEach(habitNames, id: \.self) { habitName in
                            Button(action: {
                                self.selectedHabit = habitName
                            }) {
                                Text(habitName)
                                    .foregroundColor(selectedHabit == habitName ? .blue : .black)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
                Section(header: Text("Goal").font(.headline)) {
                    HStack {
                        TextField("Goal", text: $goal)
                            .keyboardType(.numberPad)
                        Text(habitIdentifiers[habitNames.firstIndex(of: selectedHabit) ?? 0]).padding()
                    }
                }
                
                Section(header: Text("Building").font(.headline)) {
                    Picker("Building Type", selection: $selectedBuildingName) {
                        ForEach(buildings, id: \.self) { building in
                            Text(building.name).tag(building.name)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: selectedBuildingName) { newBuildingName in
                        if let selectedBuilding = buildings.first(where: { $0.name == newBuildingName }) {
                            self.selectedBuilding = selectedBuilding
                        }
                    }
                    
                    HStack {
                        Spacer()
                        AsyncImage(
                            url: URL(string: selectedBuilding?.thumbnail ?? ""),
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
                        Spacer()
                    }
                }
                
                Button(action: {
                    if let building = selectedBuilding,
                       let goal = Int(goal) {
                        let habit = firestoreManager.createHabit(name: name, building: building, user: user, goal: goal, identifier: habitIdentifiers[habitNames.firstIndex(of: selectedHabit) ?? 0])
                        user.habitIDs.append(habit.id)
                        isShowingCreateHabitView = false
                    } else {
                        print("Error creating habit")
                    }
                }) {
                    Text("Save")
                }
            }
        } else {
            ProgressView()
            let _ = firestoreManager.fetchAllBuildings { buildings, error in
                if let buildings = buildings {
                    self.buildings = buildings
                    self.selectedBuildingName = buildings[0].name
                    self.selectedBuilding = buildings[0]
                    print("selected", buildings[0].name)
                } else {
                    print("Error fetching buildings")
                }
            }
            
        }
    }
}

#Preview {
    CreateHabitView(isShowingCreateHabitView: .constant(false), user: User(id: "", email: "", password: "", username: "", accountCreationDate: Date(), userInvitedIDs: [], habitIDs: [], friendIDs: []))
}
