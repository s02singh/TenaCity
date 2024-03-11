//
//  CreateHabitView.swift
//  TenaCity
//
//  Created by Shikhar Gupta on 3/7/24.
//

import SwiftUI

struct CreateHabitView: View {
    @EnvironmentObject var authManager: AuthManager
    @ObservedObject var firestoreManager = FirestoreManager()
    @State var selectedHabit: String = "Steps"
    @State var goal: String = ""
    @State var selectedBuilding: Building?
    @State var buildings: [Building]? = nil
    
    var body: some View {
        VStack {
            if let buildings = buildings {
                Picker(selection: $selectedHabit, label: Text("Select Habit")) {
                    ForEach(habitNames.indices, id: \.self) { index in
                        HStack {
                            Text(habitNames[index])
                            Image(systemName: habitIcons[index])
                        }
                    }
                }
                
                
                TextField("Enter Goal", text: $goal)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                
                Picker(selection: $selectedBuilding, label: Text("Select Building")) {
                    ForEach(buildings, id: \.self) { building in
                        Text(building.id)
                    }
                }
                .pickerStyle(DefaultPickerStyle())
                
                Button(action: {
                    if let building = selectedBuilding,
                       let goal = Int(goal) {
                        firestoreManager.createHabit(name: selectedHabit, building: building, goal: goal, identifier: selectedHabit)
                    }
                }) {
                    Text("Create Habit")
                }
            } else {
                ProgressView()
            }
        }
        .onAppear(perform: {
            firestoreManager.fetchAllBuildings { buildings, error in
                if let buildings = buildings {
                    self.buildings = buildings
                } else {
                    print("Error fetching buildings")
                }
            }
        })
    }
}

#Preview {
    CreateHabitView()
}
