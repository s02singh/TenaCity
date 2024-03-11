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
    @State private var showingAddFriend = false
    
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
            .sheet(item: $selectedFriend, onDismiss: {
                           loadFriends()
            }) { friend in
                MenuView(friend: friend, isPresented: $selectedFriend)
            }
            .onAppear {
                print("loading friends")
                loadFriends()
            }
            Spacer()
            Button("Add Friend") {
                            showingAddFriend.toggle()
                        }
                        .padding()

                      
                        .sheet(isPresented: $showingAddFriend, onDismiss: {
                            loadFriends()
                        }) {
                            AddFriendView()
                        }
            
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
                        if friends.contains(where: { $0.id == friendID }) {
                            continue // Skip if already present
                        }
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
                   
                    let friendsToRemove = friends.filter { friend in
                        !friendIDs.contains(friend.id)
                    }
                    friends.removeAll(where: { friendToRemove in
                        friendsToRemove.contains(where: { friendToRemove.id == $0.id })
                    })

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
    @Binding var isPresented: Friend?
    @State private var showingAlert = false
    @EnvironmentObject var authManager: AuthManager

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

            Button(action: {
                showingAlert = true
            }) {
                Text("Remove Friend")
                    .foregroundColor(.red)
            }
            .padding()
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Remove Friend"), message: Text("Are you sure you want to remove \(friend.username) from your friends?"), primaryButton: .destructive(Text("Remove")) {
                   
                    removeFriend()
                }, secondaryButton: .cancel())
            }
        }
    }

    func removeFriend() {
        // Remove friend from Firestore and update UI
        let db = Firestore.firestore()
        guard let userID = authManager.userID else {return}
        
        db.collection("users").document(userID).updateData([
            "friendIDs": FieldValue.arrayRemove([friend.id])
        ]) { error in
            if let error = error {
                print("Error removing friend: \(error.localizedDescription)")
                // Handle error, maybe show an alert
            } else {
             
                print("Friend removed successfully")
                // Close sheet
                isPresented = nil
            }
        }
    }
}


struct FriendRequest: Identifiable {
    let id: String
    let username: String
}

struct AddFriendView: View {
    @State private var searchText = ""
    @State private var searchResults = [Friend]()
    @State private var friendRequests = [FriendRequest]()
    @State private var showingFriendRequests = false
    @EnvironmentObject var authManager: AuthManager
    @State private var numRequests = 0
    
    @State private var isRequestSent = false

    var body: some View {
        VStack {
            TextField("Search username", text: $searchText)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("Search") {
                isRequestSent = false
                searchUser()
                
            }
            .padding()

            List(searchResults) { friend in
                HStack {
                    Text(friend.username)
                    // All of the profile info
                    AsyncImage(url: URL(string: friend.houseIconURL)) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 50, height: 50)
                    .cornerRadius(12)
                    Spacer()
                    Button(action: {
                        sendFriendRequest(to: friend)
                    }) {
                        Text(isRequestSent ? "Sent!" : "Add")
                    }
                    .padding()
                    .disabled(isRequestSent)
                }
            }

            Button("View Friend Requests (\(numRequests))") {
                
                showingFriendRequests.toggle()
            }
            .sheet(isPresented: $showingFriendRequests, onDismiss: {
                loadFriendRequests()
            }) {
                FriendRequestsView(friendRequests: friendRequests)
            }
        }
        .onAppear{
            loadFriendRequests()
        }
        .padding()
    }
        
    func loadFriendRequests() {
            guard let currentUserID = authManager.userID else {
                return
            }
            let db = Firestore.firestore()
            
            // Fetch friend requests for the current user
            db.collection("users").document(currentUserID).getDocument { snapshot, error in
                if let error = error {
                    print("Error fetching friend requests: \(error.localizedDescription)")
                    return
                }
                
                guard let data = snapshot?.data(),
                      let requests = data["requests"] as? [String] else {
                    print("No friend requests found")
                    return
                }
                
                // Fetch usernames of users who sent friend requests
                for requestID in requests {
                    if friendRequests.contains(where: { $0.id == requestID }) {
                        continue // Skip if already present
                    }
                    db.collection("users").document(requestID).getDocument { snapshot, error in
                        if let error = error {
                            print("Error fetching request: \(error.localizedDescription)")
                            return
                        }
                        
                        guard let data = snapshot?.data(),
                              let username = data["username"] as? String else {
                            print("No username found for request")
                            return
                        }
                       
                        let friendRequest = FriendRequest(id: requestID, username: username)
                        friendRequests.append(friendRequest)
                        numRequests = friendRequests.count
                    }
                }
            }
        }
    
    // Function to send friend request
    func sendFriendRequest(to friend: Friend) {
        guard let currentUserID = authManager.userID else {
            return
        }
        let db = Firestore.firestore()
        
        // Add our id to the other user's requests
        let requestedUserRef = db.collection("users").document(friend.id)
        requestedUserRef.updateData(["requests": FieldValue.arrayUnion([currentUserID])]) { error in
            if let error = error {
                print("Error updating requests: \(error.localizedDescription)")
            } else {
                print("Friend request sent successfully!")
                // Update UI to show request is sent
                isRequestSent = true
            }
        }
    }
    
    func searchUser() {
        let db = Firestore.firestore()
        
    
        searchResults.removeAll()
        print(searchText)
        
        db.collection("users")
            .whereField("username", isEqualTo: searchText)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error searching users: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No documents found")
                    return
                }
                
                for document in documents {
                    let data = document.data()
                    if let username = data["username"] as? String,
                       let id = data["id"] as? String {
                        // Create Friend object with the retrieved data
                        let friend = Friend(id: id, username: username, houseIconURL: "https://media.istockphoto.com/id/1358860685/vector/house-icon-pixel-art-front-view-a-small-hut-vector-simple-flat-graphic-illustration-the.jpg?s=612x612&w=0&k=20&c=qodGeD6HSaJKRrZhglbSjXnGnrdXVZsyAlwdlcPaDZw=", habits: [])
                   
                        searchResults.append(friend)
                    }
                }
            }
    }
    




}

// FriendRequestsView for displaying current friend requests
struct FriendRequestsView: View {
    @State var friendRequests: [FriendRequest]
    @EnvironmentObject var authManager: AuthManager
    @State private var toastMessage = ""
    @State private var isToastShowing = false
    
    var body: some View {
        VStack{
            if friendRequests.isEmpty {
                Text("No friend requests")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List(friendRequests) { request in
                    HStack {
                        Text(request.username)
                        Spacer()
                        HStack {
                            Button(action: {
                                acceptFriendRequest(request)
                            }) {
                                Text("Accept")
                            }
                            .padding()
                            .buttonStyle(.borderless)
                            .foregroundColor(.green)
                            
                            Button(action: {
                                declineFriendRequest(request)
                            }) {
                                Text("Decline")
                            }
                            .padding()
                            .buttonStyle(.borderless)
                            .foregroundColor(.red)
                        }
                    }
                    
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding()
                }
            }
        }
        .toast(isShowing: $isToastShowing, message: toastMessage)
    }
    
    func acceptFriendRequest(_ request: FriendRequest) {
        guard let currentUserID = authManager.userID else {
            return
        }
        let db = Firestore.firestore()
        
        // Remove friend request from requests
        db.collection("users").document(currentUserID).updateData(["requests": FieldValue.arrayRemove([request.id])]) { error in
            if let error = error {
                print("Error removing friend request: \(error.localizedDescription)")
                return
            }
            
            db.collection("users").document(request.id).updateData(["friendIDs": FieldValue.arrayUnion([currentUserID])]) { error in
                if let error = error {
                    print("Error accepting friend request: \(error.localizedDescription)")
                    return
                }
                
                print("Friend request accepted successfully!")
               
                
            }

            
            // Add the requester's ID to the current user's friends list
            db.collection("users").document(currentUserID).updateData(["friendIDs": FieldValue.arrayUnion([request.id])]) { error in
                if let error = error {
                    print("Error accepting friend request: \(error.localizedDescription)")
                    return
                }
                
                print("Friend request accepted successfully!")
               
                if let index = friendRequests.firstIndex(where: { $0.id == request.id }) {
                    friendRequests.remove(at: index)
                }
                
                let friendUsername = request.username
                let fanfareMessage = "\(friendUsername) was added as a friend!"
                showToast(message: fanfareMessage)
            }
        }
    }
    
    func showToast(message: String) {
        let duration: TimeInterval = 2
        
        withAnimation {
            toastMessage = message
            isToastShowing = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation {
                isToastShowing = false
            }
        }
    }
    
    func declineFriendRequest(_ request: FriendRequest) {
        guard let currentUserID = authManager.userID else {
            return
        }
        let db = Firestore.firestore()
        
        // Remove friend request
        db.collection("users").document(currentUserID).updateData(["requests": FieldValue.arrayRemove([request.id])]) { error in
            if let error = error {
                print("Error removing friend request: \(error.localizedDescription)")
                return
            }
            
            print("Friend request declined successfully!")
            // Remove the declined request from the list
            if let index = friendRequests.firstIndex(where: { $0.id == request.id }) {
                friendRequests.remove(at: index)
            }
        }
    }
}



extension View {
    func toast(isShowing: Binding<Bool>, message: String) -> some View {
        ZStack {
            self

            if isShowing.wrappedValue {
                VStack {
                    Text(message)
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 15)
                        .background(Color.black)
                        .cornerRadius(8)
                }
                .transition(.move(edge: .top))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            isShowing.wrappedValue = false
                        }
                    }
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

