import SwiftUI
import Firebase
import FirebaseFirestore


struct GroupHabitView: View {
    @State private var publicHabits = [GroupHabit]()
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedHabit: GroupHabit?
    @State private var isHabitDetailSheetPresented = false
    @State var numHabits = 0
    @State private var isFetchingHabits = false
    @State private var isCreateHabitPresented = false
    
    @State var opened = false
    
    // Made a grid for the habits, we can change later
    let columns = [
        GridItem(.flexible(minimum: 100, maximum: 150)),
        GridItem(.flexible(minimum: 100, maximum: 150)),
        GridItem(.flexible(minimum: 100, maximum: 150))
    ]
    
    var body: some View {
            VStack {
                VStack{
                    GroupHabitHeaderView()
                        .onAppear {
                            fetchPublicHabits(){
                                numHabits = publicHabits.count
                            }
                        }
                    
                    if !publicHabits.isEmpty {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(publicHabits) { habit in
                                    Button(action: {
                                        print(habit.name)
                                        selectedHabit = habit
                                        isHabitDetailSheetPresented = true
                                    }) {
                                        HabitView(habit: habit)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding([.horizontal, .bottom])
                        }
                    } else if isFetchingHabits {
                        ProgressView()
                            .padding()
                    } else {
                        Text("No public habits available")
                            .foregroundColor(.gray)
                    }
                    
                }
                .padding()
                Spacer()
                Button(action: {
                    isCreateHabitPresented = true
                }) {
                    Text("Create Group Habit")
                        .padding()
                        .background(Color("Orange"))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                
            }
            .background(
                Image("basicBackground")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .opacity(0.8)
            )
            .sheet(item: $selectedHabit, onDismiss: {
                /*
                fetchPublicHabits {
                    numHabits = publicHabits.count
                }
                 */
                
            }) { habit in
                HabitDetailSheet(habit: habit)
            }
            
            .sheet(isPresented: $isCreateHabitPresented, onDismiss: {
                
            }) {
                CreateGroupHabitSheet()
            }
            .onAppear {
                fetchPublicHabits() {
                    numHabits = publicHabits.count
                }
              
            }
    }
    
    func fetchPublicHabits(completion: @escaping () -> Void) {
        print("about to fetch")
        guard let currentUserID = authManager.userID else {
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("users").document(currentUserID).getDocument { document, error in
            if let error = error {
                print("Error getting user document: \(error)")
                return
            }
            
            guard let habitIDs = document?.data()?["habitIDs"] as? [String] else {
                print("No habit IDs found for the user")
                return
            }
            
            isFetchingHabits = true
            
            var habits = [GroupHabit]()
            let dispatchGroup = DispatchGroup() // Create DispatchGroup
            
            for habitID in habitIDs {
                dispatchGroup.enter() // Enter DispatchGroup before starting each task
                db.collection("habits").document(habitID).getDocument { habitDocument, error in
                    defer {
                        dispatchGroup.leave() // Leave DispatchGroup after finishing each task
                    }
                    
                    if let error = error {
                        print("Error getting habit document: \(error)")
                        return
                    }
                    guard let habitData = habitDocument?.data(),
                          let name = habitData["name"] as? String,
                          let isPublic = habitData["isPublic"] as? Bool,
                          let buildingID = habitData["buildingID"] as? String,
                          let progress = habitData["progress"] as? Double,
                          let goal = habitData["goal"] as? Int,
                          let noteData = habitData["note"] as? [String: String],
                          let contributionsData = habitData["contributions"] as? [String: Any] else {
                        print("Incomplete habit data")
                        return
                    }
                    
                    var contributions = [String: Double]()
                    for (userID, contribution) in contributionsData {
                        if let contributionString = contribution as? Double {
                            contributions[userID] = contributionString
                        }
                    }
                    
                    if isPublic {
                        let habit = GroupHabit(id: habitID,
                                               name: name,
                                               isPublic: isPublic,
                                               buildingID: buildingID,
                                               progress: progress,
                                               goal: goal,
                                               note: noteData,
                                               contributions: contributions)
                        habits.append(habit)
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self.publicHabits = habits
                isFetchingHabits = false
                completion() // Call completion handler after all tasks are done
            }
        }
    }

}



struct HabitView: View {
    let habit: GroupHabit
    @State private var buildingImage: UIImage?
    @State private var isImageLoaded: Bool = false
    
    var body: some View {
        VStack {
            if let buildingImage = buildingImage {
                Image(uiImage: buildingImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 150)
                    .cornerRadius(12)
                    .padding(.bottom, 7)
                    .onAppear {
                        isImageLoaded = true
                    }
            } else {
                ProgressView()
                    .padding()
            }
            
            if isImageLoaded {
                Text(habit.name)
                    .font(.headline)
                    .padding(.bottom, 10)
                
                ProgressBar(progress: min(habit.progress, Double(habit.goal)), goal: habit.goal)
                    .frame(height: 10)
                    .padding()
            }
        }
        .onAppear {
            fetchBuildingImage()
        }
    }
    
    func fetchBuildingImage() {
        let db = Firestore.firestore()
        db.collection("buildings").document(habit.buildingID).getDocument { document, error in
            if let error = error {
                print("Error getting building document: \(error)")
                return
            }

            guard let buildingData = document?.data(),
                  let levelsIDs = buildingData["levelIDs"] as? [String]
            else {
                print("Invalid building document")
                return
            }

            let levelID = levelsIDs[0]

            db.collection("skins").document(levelID).getDocument { document, error in
                if let error = error {
                    print("Error getting skins document: \(error)")
                    return
                }

                guard let skinsData = document?.data(),
                      let imageURLString = skinsData["url"] as? String,
                      let imageURL = URL(string: imageURLString) else {
                    print("Invalid skins document")
                    return
                }

                // Fetch building image from URL we have saved in skins
                URLSession.shared.dataTask(with: imageURL) { data, response, error in
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.buildingImage = image
                        }
                    } else {
                        print("Failed to fetch image: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }.resume()
            }
        }
    }
}

struct GroupHabitHeaderView: View {
    var body: some View {
        VStack {
            Text("Group Habits")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
                .padding(.bottom, 30)
        }
    }
}

struct ProgressBar: View {
    var progress: Double
    var goal: Int
    
    @State private var progressBarWidth: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 8) {
                ZStack(alignment: .leading) {
                    Rectangle()
                        .foregroundColor(Color.gray.opacity(0.2))
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .cornerRadius(5)
                    
                    LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.7), Color.green.opacity(0.9)]),
                                   startPoint: .leading,
                                   endPoint: .trailing)
                        .frame(width: progressBarWidth,
                               height: geometry.size.height)
                        .cornerRadius(5)
                }
                
                Text("\(Int(Double(progress) / Double(goal) * 100))%")
                    .font(.custom("Comic Sans MS", size: 18))
                    .foregroundColor(Color.blue)
            }
            .onAppear {
                let calculatedWidth = min(CGFloat(progress) / CGFloat(goal) * geometry.size.width, geometry.size.width)
                
                withAnimation(.linear(duration: 1.0)) {
                    progressBarWidth = calculatedWidth
                }
            }
        }
    }
}

struct GroupHabit: Identifiable {
    let id: String
    let name: String
    let isPublic: Bool
    let buildingID: String
    let progress: Double
    let goal: Int
    let note: [String: String]
    let contributions: [String: Double]
}


import SwiftUI

struct GradientText: View {
    let text: String
    let gradient: LinearGradient

    var body: some View {
        ZStack {
            gradient
                .mask(Text(text).font(.custom("Avenir", size: 20)))
        }
    }
}

struct HabitDetailSheet: View {
    let habit: GroupHabit
    @State private var userNames: [String: String] = [:]
    
    var body: some View {
        VStack {
            Text("Habit Detail Sheet for \(habit.name)")
                .font(.title)
                .padding()
            
            Text("Progress: \(habit.progress)")
                .padding()
            
            Text("Goal: \(habit.goal)")
                .padding()
            
            if !habit.note.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes:")
                        .font(.headline)
                    
                    ForEach(habit.note.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                        if let userName = userNames[key] {
                            Text("- \(userName): \(value)")
                        } else {
                            Text("- \(key): \(value)")
                        }
                    }
                }
                .padding()
            }
            
            ContributionsDisplay(habit: habit, userNames: userNames)
                .padding()
        }
    }
    
    func fetchUserNames() {
        let db = Firestore.firestore()
        let userIds = Array(habit.note.keys) + Array(habit.contributions.keys)
        
        userIds.forEach { userId in
            db.collection("users").document(userId).getDocument { document, error in
                if let error = error {
                    print("Error getting user document: \(error)")
                    return
                }
                
                guard let userName = document?.data()?["username"] as? String else {
                    print("No name found for user with ID: \(userId)")
                    return
                }
                
                DispatchQueue.main.async {
                    userNames[userId] = userName
                }
            }
        }
    }
}

struct ContributionsDisplay: View {
    let habit: GroupHabit
    let userNames: [String: String]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(habit.contributions.sorted(by: { $0.value > $1.value }), id: \.key) { userID, contribution in
                    ContributionRow(userName: userNames[userID] ?? "Unknown", contribution: contribution, goal: habit.goal)
                }
            }
            .padding()
        }
    }
}

struct ContributionRow: View {
    let userName: String
    let contribution: Double
    let goal: Int
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(userName)
                    .font(Font.custom("Avenir-Heavy", size: 18))
                    .foregroundColor(.black)
                Text("Contribution: \(contribution)")
                    .font(Font.custom("Avenir", size: 14))
                    .foregroundColor(.black)
                Text("\(Int(Double(contribution) / Double(goal) * 100))% of Goal Completed")
                    .font(Font.custom("Avenir", size: 12))
                    .foregroundColor(.gray)
            }
            Spacer()
            ZStack {
                
                GradientText(text: "\(contribution)", gradient: LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.7), Color.green.opacity(0.9)]), startPoint: .top, endPoint: .bottom))
                    .font(Font.custom("Avenir", size: 20))
            }
        }
        .padding(.horizontal)
    }
}


struct CreateGroupHabitSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedFriends: Set<String> = []
    @State private var habitName: String = ""
    @State private var goal: String = ""
    @State private var selectedIdentifier: String = ""
    @State private var selectedBuilding: String = ""
    @State private var skyscraperImage: UIImage?
    @State private var houseImage: UIImage?
    @State private var buildingType: String = "Cabin" // Default selection
    @State private var friends: [String: String] = [:]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Habit Details").font(.headline)) {
                    TextField("Habit Name", text: $habitName)
                    TextField("Goal", text: $goal)
                    Picker("Identifier", selection: $selectedIdentifier) {
                        Text("Steps").tag("Steps")
                        Text("Hours").tag("Hours")
                        // Add more when we get them
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Picker("Building Type", selection: $buildingType) {
                        Text("Cabin").tag("Cabin")
                        Text("House").tag("House")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    if buildingType == "Cabin" {
                        if let buildingImage = skyscraperImage {
                            HStack {
                                Spacer()
                                Image(uiImage: buildingImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 150, height: 150)
                                    .cornerRadius(12)
                                    .padding(.bottom, 7)
                                Spacer()
                            }
                            .onAppear {
                                fetchBuildingImage(imageURL: "https://media.istockphoto.com/id/1358860685/vector/house-icon-pixel-art-front-view-a-small-hut-vector-simple-flat-graphic-illustration-the.jpg?s=612x612&w=0&k=20&c=qodGeD6HSaJKRrZhglbSjXnGnrdXVZsyAlwdlcPaDZw=", index: 0)
                            }
                        } else {
                            ProgressView()
                                .padding()
                        }
                    } else {
                        if let buildingImage = houseImage {
                            HStack {
                                Spacer()
                                Image(uiImage: buildingImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 150, height: 150)
                                    .cornerRadius(12)
                                    .padding(.bottom, 7)
                                Spacer()
                            }
                            .onAppear {
                                fetchBuildingImage(imageURL: "https://media.istockphoto.com/id/1358860685/vector/house-icon-pixel-art-front-view-a-small-hut-vector-simple-flat-graphic-illustration-the.jpg?s=612x612&w=0&k=20&c=qodGeD6HSaJKRrZhglbSjXnGnrdXVZsyAlwdlcPaDZw=", index: 1)
                            }
                        } else {
                            ProgressView()
                                .padding()
                        }
                    }
                }
                Section(header: Text("Select Friends").font(.headline)) {
                    List {
                        ForEach(friends.sorted(by: { $0.value < $1.value }), id: \.key) { friendID, friendName in
                            Toggle(isOn: Binding<Bool>(
                                get: {
                                    self.selectedFriends.contains(friendID)
                                },
                                set: { newValue in
                                    if newValue {
                                        self.selectedFriends.insert(friendID)
                                    } else {
                                        self.selectedFriends.remove(friendID)
                                    }
                                }
                            )) {
                                Text(friendName)
                            }
                        }
                    }
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
                        saveGroupHabit()
                    }) {
                        Text("Save")
                    }
            )
        }
        .onAppear{
            fetchFriends()
            fetchBuildingImage(imageURL: "https://media.istockphoto.com/id/1358860685/vector/house-icon-pixel-art-front-view-a-small-hut-vector-simple-flat-graphic-illustration-the.jpg?s=612x612&w=0&k=20&c=qodGeD6HSaJKRrZhglbSjXnGnrdXVZsyAlwdlcPaDZw=", index: 0)
            fetchBuildingImage(imageURL: "https://media.istockphoto.com/id/1358860685/vector/house-icon-pixel-art-front-view-a-small-hut-vector-simple-flat-graphic-illustration-the.jpg?s=612x612&w=0&k=20&c=qodGeD6HSaJKRrZhglbSjXnGnrdXVZsyAlwdlcPaDZw=", index: 1)
        }
        .accentColor(.blue)
    }
    
    func fetchBuildingImage(imageURL: String, index: Int) {
        guard let url = URL(string: imageURL) else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    if(index == 0){
                        skyscraperImage = image
                    }
                    else{
                        houseImage = image
                    }
                    
                }
            } else {
                print("Failed to fetch image: \(error?.localizedDescription ?? "Unknown error")")
         
            }
        }.resume()
    }

    func fetchFriends() {
        guard let currentUserID = authManager.userID else {
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("users").document(currentUserID).getDocument { document, error in
            if let error = error {
                print("Error getting user document: \(error)")
                return
            }
            
            guard let friendIDs = document?.data()?["friendIDs"] as? [String] else {
                print("No friend IDs found for the user")
                return
            }
            
            var friendsMap: [String: String] = [:]
            
            let dispatchGroup = DispatchGroup()
            
            for friendID in friendIDs {
                dispatchGroup.enter()
                db.collection("users").document(friendID).getDocument { friendDocument, friendError in
                    defer {
                        dispatchGroup.leave()
                    }
                    
                    if let friendError = friendError {
                        print("Error getting friend document: \(friendError)")
                        return
                    }
                    
                    guard let username = friendDocument?.data()?["username"] as? String else {
                        print("No username found for friend with ID: \(friendID)")
                        return
                    }
                    
                    friendsMap[friendID] = username
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self.friends = friendsMap
            }
        }
    }

        
    
    func saveGroupHabit() {
        guard let currentUserID = authManager.userID else {
            print("Current user ID not available")
            return
        }

        let db = Firestore.firestore()

        // Convert goal to Int
        guard let goalValue = Int(goal) else {
            print("Invalid goal value")
            return
        }

        // Get contributions ready
        var contributions: [String: Any] = [:]
        for friendID in selectedFriends {
            contributions[friendID] = 0
        }
        
        contributions[currentUserID] = 0
        var buildingID = ""
        if(buildingType == "Cabin"){
            buildingID = "AhPawVNNtkPUzziZZvON"
        }
        else{buildingID = "AhPawVNNtkPUzziZZvON"}
        
        // Add the habit to Firestore
        let newDocument = db.collection("habits").document()
        // habit data
        let habitData: [String: Any] = [
            "id": newDocument.documentID,
            "name": habitName,
            "buildingID": buildingID,
            "progress": 0.0,
            "goal": goalValue,
            "note": [:],
            "contributions": contributions,
            "isPublic": true,
            "identifier": selectedIdentifier,
            "dates": [],
            "streak": 0,
        ]
        newDocument.setData(habitData) { error in
            if let error = error {
                print("Error adding habit: \(error.localizedDescription)")
            } else {
                print("New habit created with ID: \(newDocument.documentID)")
                db.collection("users").document(currentUserID).updateData([
                               "habitIDs": FieldValue.arrayUnion([newDocument.documentID])
                           ]) { error in
                               if let error = error {
                                   print("Error updating habitIDs for current user: \(error.localizedDescription)")
                               } else {
                                   print("Habit ID added to current user's habitIDs")
                               }
                           }
                           // Update habitIDs field for selected friends
                           for friendID in self.selectedFriends {
                               db.collection("users").document(friendID).updateData([
                                   "habitIDs": FieldValue.arrayUnion([newDocument.documentID])
                               ]) { error in
                                   if let error = error {
                                       print("Error updating habitIDs for friend \(friendID): \(error.localizedDescription)")
                                   } else {
                                       print("Habit ID added to habitIDs of friend \(friendID)")
                                   }
                               }
                           }
                self.presentationMode.wrappedValue.dismiss()
            }
        }

        
    }

}
