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
            NavigationBar()
        }
        .sheet(item: $selectedHabit, onDismiss: {
                       
        }) { habit in
            HabitDetailSheet(habit: habit)
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
            var fetchedHabitsCount = 0
            
            for habitID in habitIDs {
                db.collection("habits").document(habitID).getDocument { habitDocument, error in
                    if let error = error {
                        print("Error getting habit document: \(error)")
                        return
                    }
                    
                    guard let habitData = habitDocument?.data(),
                          let name = habitData["name"] as? String,
                          let isPublic = habitData["isPublic"] as? Bool,
                          let buildingID = habitData["buildingID"] as? String,
                          let progress = habitData["progress"] as? Int,
                          let goal = habitData["goal"] as? Int,
                          let noteData = habitData["note"] as? [String: String],
                          let contributionsData = habitData["contributions"] as? [String: Any] else {
                        print("Incomplete habit data")
                        return
                    }
                    
                    var contributions = [String: Int]()
                    for (userID, contribution) in contributionsData {
                        if let contributionString = contribution as? Int {
                            contributions[userID] = contributionString
                        }
                    }
                    
                    if isPublic {
                        let habit = GroupHabit(name: name,
                                               isPublic: isPublic,
                                               buildingID: buildingID,
                                               progress: progress,
                                               goal: goal,
                                               note: noteData,
                                               contributions: contributions)
                        habits.append(habit)
                    }
                    
                    fetchedHabitsCount += 1
                    
                    if fetchedHabitsCount == habitIDs.count {
                        DispatchQueue.main.async {
                            self.publicHabits = habits
                            completion()
                            isFetchingHabits = false
                        }
                    }
                }
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
                    .frame(width: 150, height: 150)
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
                
                ProgressBar(progress: habit.progress, goal: habit.goal)
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
                  let levelsIDs = buildingData["levelsIDs"] as? [String],
                  let levelIndex = buildingData["level"] as? Int,
                  levelIndex < levelsIDs.count else {
                print("Invalid building document")
                return
            }

            let levelID = levelsIDs[levelIndex]

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
    var progress: Int
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
    let id = UUID()
    let name: String
    let isPublic: Bool
    let buildingID: String
    let progress: Int
    let goal: Int
    let note: [String: String]
    let contributions: [String: Int]
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
        .onAppear {
            fetchUserNames()
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
    let contribution: Int
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

