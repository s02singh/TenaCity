import SwiftUI
import Firebase
import FirebaseFirestore

struct friendHabit: Identifiable {
    let id: String
    let name: String
    let buildingID: String
}

struct Friend: Identifiable {
    let id: String
    let username: String
    let houseIconURL: String
    var habits: [friendHabit]
}

struct FriendsView: View {
    @State private var friends = [Friend]()
    @State private var selectedFriend: Friend?
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        VStack {
            VStack {
                Text("My Friends")
                    .font(.system(size: 24, weight: .bold, design: .default))
                    .foregroundColor(Color.blue)
                    .padding(.top, 20)
                
                Text("\(friends.count) friends")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                        ForEach(friends) { friend in
                            Button(action: {
                                selectedFriend = friend
                            }) {
                                VStack {
                                    AsyncImage(url: URL(string: friend.houseIconURL)) { image in
                                        image.resizable()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 150, height: 150)
                                    .cornerRadius(12)
                                    
                                    Text(friend.username)
                                        .font(.headline)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .sheet(item: $selectedFriend) { friend in
                MenuView(friend: friend)
            }
            .onAppear {
                loadFriends()
            }
            Spacer()
//            NavigationBar()
        }
    }
    
    func loadFriends() {
        let db = Firestore.firestore()
        guard let myUserID = authManager.userID else {return}
        db.collection("users").document(myUserID).getDocument { (document, error) in
            if let document = document, document.exists {
                if let friendIDs = document.data()?["friendIDs"] as? [String] {
                    for friendID in friendIDs {
                        print(friendID)
                        db.collection("users").document(friendID).getDocument { (friendDocument, error) in
                            if let friendDocument = friendDocument, friendDocument.exists {
                                let friendData = friendDocument.data()
                                if let username = friendData?["username"] as? String {
                                    let friend = Friend(id: friendID, username: username, houseIconURL: "https://media.istockphoto.com/id/1358860685/vector/house-icon-pixel-art-front-view-a-small-hut-vector-simple-flat-graphic-illustration-the.jpg?s=612x612&w=0&k=20&c=qodGeD6HSaJKRrZhglbSjXnGnrdXVZsyAlwdlcPaDZw=", habits: [])
                                    friends.append(friend)
                                    print(friend.username)
                                    
                                    loadHabits(for: friend)
                                }
                            } else {
                                print("Friend document does not exist")
                            }
                        }
                    }
                }
            } else {
                print("User document does not exist")
            }
        }
    }
    
    func loadHabits(for friend: Friend) {
        let db = Firestore.firestore()
        let userDocRef = db.collection("users").document(friend.id)
        
        userDocRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let habitIDs = document.data()?["habitIDs"] as? [String] {
                    for habitID in habitIDs {
                        db.collection("habits").document(habitID).getDocument { (habitDocument, error) in
                            if let habitDocument = habitDocument, habitDocument.exists {
                                if let habitData = habitDocument.data(),
                                   let id = habitData["id"] as? String,
                                   let name = habitData["name"] as? String,
                                   let buildingID = habitData["buildingID"] as? String {
                                    let habit = friendHabit(id: id, name: name, buildingID: buildingID)
                                    friends[getIndex(for: friend)].habits.append(habit)
                                }
                            } else {
                                print("Habit document does not exist")
                            }
                        }
                    }
                }
            } else {
                print("User document does not exist")
            }
        }
    }

    
    func getIndex(for friend: Friend) -> Int {
        if let index = friends.firstIndex(where: { $0.id == friend.id }) {
            return index
        }
        return 0
    }
}

struct MenuView: View {
    let friend: Friend
    
    var body: some View {
        VStack {
            Text("Habits of \(friend.username)")
                .font(.title)
                .padding()
            
            ScrollView {
                ForEach(friend.habits) { habit in
                    VStack {
                        AsyncImage(url: URL(string: "https://static.vecteezy.com/system/resources/previews/011/453/045/original/skyscraper-pixel-art-style-free-vector.jpg")) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 150, height: 150)
                        .cornerRadius(12)
                        
                        Text(habit.name)
                            .font(.headline)
                            .padding(.bottom, 10)
                    }
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding()
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        FriendsView()
    }
}
