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
    @State var goal: String = ""
    @State var selectedBuilding: Building? = nil
    @State var selectedBuildingName: String = ""
    @State var buildings: [Building]? = nil
    
    var body: some View {
        if let buildings = buildings {
            Form {
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
                
                // todo: delete this and figure out navigation thing
                Button(action: {
                    if let building = selectedBuilding,
                       let goal = Int(goal) {
                        firestoreManager.createHabit(name: selectedHabit, building: building, goal: goal, identifier: selectedHabit)
                    }
                }) {
                    Text("Save")
                }
            }
            .navigationBarTitle("Create Group Habit", displayMode: .inline)
            .navigationBarItems(
                leading:
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel").foregroundColor(.red)
                    },
                trailing:
                    Button(action: {
                        if let building = selectedBuilding,
                           let goal = Int(goal) {
                            firestoreManager.createHabit(name: selectedHabit, building: building, goal: goal, identifier: selectedHabit)
                        }
                    }) {
                        Text("Save")
                    }
            )
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
    CreateHabitView()
}
