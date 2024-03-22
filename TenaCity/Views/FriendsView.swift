import SwiftUI
import Firebase
import FirebaseFirestore


// Define the friendHabit struct
// We want to know the habit they have and the building they chsoe.
struct friendHabit: Identifiable {
    let id: String
    let name: String
    let buildingID: String
}

// Define a Friend struct.
// We want to know their id, username, and their habits.
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
                // Simple header
                Text("My Friends")
                    .font(.system(size: 24, weight: .bold, design: .default))
                    .foregroundColor(Color.blue)
                    .padding(.top, 20)
                
                // Displays number of friends
                Text("\(friends.count) friends")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)
                
                ScrollView {
                    LazyVStack {
                        ForEach(friends) { friend in
                            // Displays each friend in a stylized row design with a quick button to show habits
                            // when you click your friends row.
                            FriendRow(friend: friend, selectedFriend: $selectedFriend)
                                .onTapGesture {
                                    selectedFriend = friend
                                }
                        }
                    }
                }
            }
            .padding()
            // the friend view opens when you click their row.
            .sheet(item: $selectedFriend, onDismiss: {
                // on dismiss we reload friends.
                loadFriends()
            }) { friend in
                // opens friend view with the selected friend
                MenuView(friend: friend, isPresented: $selectedFriend)
            }
            .onAppear {
                // when the view opens we load our friends
                print("loading friends")
                loadFriends()
            }
            
            Spacer()
            // button to open add friend view
            Button {
                showingAddFriend.toggle()
            } label: {
                Text("Add Friend")
            }
            .padding()
            .background(Color("SageGreen"))
            .foregroundColor(.white)
            .cornerRadius(8)
            .sheet(isPresented: $showingAddFriend, onDismiss: {
                // loads friends on dismiss
                loadFriends()
            }) {
                AddFriendView()
            }
        }
        .background(
            Image("basicBackground")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .opacity(0.8)
        )
    }

    
    // main function to load friends.
    func loadFriends() {
        let db = Firestore.firestore()
        guard let myUserID = authManager.userID else {return}
        
        // retireves current users list of friends
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
                                    // create a friend object with the firebase data
                                    let friend = Friend(id: friendID, username: username, houseIconURL: "https://media.istockphoto.com/id/1358860685/vector/house-icon-pixel-art-front-view-a-small-hut-vector-simple-flat-graphic-illustration-the.jpg?s=612x612&w=0&k=20&c=qodGeD6HSaJKRrZhglbSjXnGnrdXVZsyAlwdlcPaDZw=", habits: [])
                                    
                                    // add new friend object to our list of friends
                                    friends.append(friend)
                                    print(friend.username)
                                    // Loads the friends habits as well.
                                    loadHabits(for: friend)
                                }
                            } else {
                                print("Friend document does not exist")
                            }
                        }
                    }
                   
                    // If a friend is deleted, we make sure to remove them from the view.
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

    
    // main function for loading friends views.
    func loadHabits(for friend: Friend) {
        let db = Firestore.firestore()
        let userDocRef = db.collection("users").document(friend.id)
        
        // uses the friendId to find document.
        userDocRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let habitIDs = document.data()?["habitIDs"] as? [String] {
                    for habitID in habitIDs {
                        db.collection("habits").document(habitID).getDocument { (habitDocument, error) in
                            
                            // Collect all information of the habit and make a friendHabit object.
                            if let habitDocument = habitDocument, habitDocument.exists {
                                if let habitData = habitDocument.data(),
                                   let id = habitData["id"] as? String,
                                   let name = habitData["name"] as? String,
                                   let buildingID = habitData["buildingID"] as? String {
                                    let habit = friendHabit(id: id, name: name, buildingID: buildingID)
                                    // append the new habbit to list of habits
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

    
    // quick function to find the index of the friend selected from friendsrow
    func getIndex(for friend: Friend) -> Int {
        if let index = friends.firstIndex(where: { $0.id == friend.id }) {
            return index
        }
        return 0
    }
}

// A friendrow is a stylized way to show each friend.
struct FriendRow: View {
    @State var friend: Friend
    @State private var isShowingSheet = false
    @Binding var selectedFriend: Friend?
    @State var checker: Friend?
    
    var body: some View {
        
        // A nice house icon to represent the friend.
        HStack {
            AsyncImage(url: URL(string: friend.houseIconURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 50, height: 50)
            .cornerRadius(12)
            
            // Displays their name
            HStack() {
                Text(friend.username)
                    .font(.headline)
                Spacer()
                
                // A quick button to make a group habit with the friend.
                HStack {
                    // It will open a new sheet to create the habit.
                    Button("Group") {
                        print(friend.id)
                        isShowingSheet.toggle()
                        checker = friend
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .sheet(item: $checker, onDismiss: {
                       
                    }) { friend in
                        QuickCreateGroupHabitSheet(friend: friend)
                    }
                }
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}

// menuview will show a friends habits.
struct MenuView: View {
    let friend: Friend
    @Binding var isPresented: Friend?
    @State private var showingAlert = false
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        
        // Simple header
        VStack {
            Text("Habits of \(friend.username)")
                .font(.title)
                .padding()
            
            // This scroll view will create a nice way to look through your friends habits.
            ScrollView {
                ForEach(friend.habits) { habit in
                    VStack {
                        // Shows the image of the habit.
                        AsyncImage(url: URL(string: "https://static.vecteezy.com/system/resources/previews/011/453/045/original/skyscraper-pixel-art-style-free-vector.jpg")) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 150, height: 150)
                        .cornerRadius(12)
                        
                        // Displays the name of the habit.
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

            // This button allows you to remove your friend.
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

    // function to remove friend from your friends list.
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


// Simple struct to store friend requests
struct FriendRequest: Identifiable {
    let id: String
    let username: String
}

// This struct defines the sheet that opens when wanting to add a newfriend
struct AddFriendView: View {
    
    // Set up our variables
    @State private var searchText = ""
    @State private var searchResults = [Friend]()
    @State private var friendRequests = [FriendRequest]()
    @State private var showingFriendRequests = false
    @EnvironmentObject var authManager: AuthManager
    @State private var numRequests = 0
    @State private var sentFriendRequests = [String: Bool]() // Dictionary to track sent requests

    var body: some View {
        // Simple header
        VStack {
            TextField("Search username", text: $searchText)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            
            // Will list 5 matching results at max
            List(searchResults.prefix(5), id: \.id) { friend in
                HStack {
                    // Displays the user with a simple box using their username, icon and a button to add
                    Text(friend.username)
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
                        // if we send a request, disable the Add button and change text
                        Text(sentFriendRequests[friend.id, default: false] ? "Sent!" : "Add")
                    }
                    .padding()
                    .disabled(sentFriendRequests[friend.id, default: false]) // Disable based on dictionary
                }
            }

            // Opens sheet to see current friend requests
            Button("View Friend Requests (\(numRequests))") {
                showingFriendRequests.toggle()
            }
            .sheet(isPresented: $showingFriendRequests, onDismiss: {
                // on dismiss we want to reload our friend requests
                loadFriendRequests()
            }) {
                FriendRequestsView(friendRequests: friendRequests)
            }
        }
        .onAppear {
            // load requests on appear
            loadFriendRequests()
        }
        .padding()

        // dynamic search by checking searchtext
        .onChange(of: searchText) { newValue in
            searchUser()
        }
    }

    // function to load friend requests
    func loadFriendRequests() {
        guard let currentUserID = authManager.userID else {
            return
        }
        let db = Firestore.firestore()
        
        // checks the firestore document to see if anything is in the requestsIDs array.
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
                    
                    // If there is an ID, we create a friend request object and append it to our list
                    let friendRequest = FriendRequest(id: requestID, username: username)
                    friendRequests.append(friendRequest)
                    numRequests = friendRequests.count
                }
            }
        }
    }

    
    // function to send a friend request.
    func sendFriendRequest(to friend: Friend) {
        guard let currentUserID = authManager.userID else {
            return
        }
        let db = Firestore.firestore()
        
        
        // this simply appends the current users id to the other users requests list.
        let requestedUserRef = db.collection("users").document(friend.id)
        requestedUserRef.updateData(["requests": FieldValue.arrayUnion([currentUserID])]) { error in
            if let error = error {
                print("Error updating requests: \(error.localizedDescription)")
            } else {
                print("Friend request sent successfully!")
                sentFriendRequests[friend.id] = true // Update dictionary
            }
        }
    }

    // function to dynamically search users.
    func searchUser() {
        let db = Firestore.firestore()
        searchResults.removeAll()

        if searchText.isEmpty {
            return
        }

        // we make to sure to allow search of all matching texts. this means
        // partial input will work.
        // If we search for Je, it would show Jeff, Jean, Jeremy, etc.
        db.collection("users")
            .whereField("username", isGreaterThanOrEqualTo: searchText)
            .whereField("username", isLessThan: searchText + "z") // Ensures only results starting with searchText are returned
            .getDocuments { querySnapshot, error in
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
                        let friend = Friend(id: id, username: username, houseIconURL: "https://media.istockphoto.com/id/1358860685/vector/house-icon-pixel-art-front-view-a-small-hut-vector-simple-flat-graphic-illustration-the.jpg?s=612x612&w=0&k=20&c=qodGeD6HSaJKRrZhglbSjXnGnrdXVZsyAlwdlcPaDZw=", habits: [])
                        // We create a object for the searched user and append to searchresults
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
                // Simple Accept and Decline options
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
    
    // Function to accept request
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
            
            // append the new friends id to friendIDs list.
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
    
    // creates a nice message letting you know a friend is added.
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
    
    // function to decline requests
    func declineFriendRequest(_ request: FriendRequest) {
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
            
            print("Friend request declined successfully!")
            // Remove the declined request from the list
            if let index = friendRequests.firstIndex(where: { $0.id == request.id }) {
                friendRequests.remove(at: index)
            }
        }
    }
}



// a view extension to overlay the toast and play for 2 seconds.
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


/**
 A view for creating a group habit with customizable details such as habit name, habit goal and building.

 - Parameters:
    - friend: The friend for whom the habit is being created.

 - Functions:
    - fetchBuildingImage(imageURL:index:): Asynchronously fetches an image from the provided URL and assigns it to the appropriate image state variable.
    - fetchFriends(): Fetches the list of friends associated with the authenticated user and updates the 'friends' dictionary.
    - saveGroupHabit(): Saves the created habit data to Firestore, including habit name, goal, contributions, and identifier type.
*/

struct QuickCreateGroupHabitSheet: View {
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
    let friend: Friend
    @State private var showCustomGoal: Bool = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Habit Details").font(.headline)) {
                    TextField("Habit Name", text: $habitName)
                    VStack {
                        Text("Goal")
                        HStack{
                            Spacer()
                            Button(action: {
                                goal = "50"
                            }) {
                                Text("50")
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(Color.gray)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle()) // Using PlainButtonStyle for better customization
                            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
                            .fixedSize()
                            
                            Button(action: {
                                goal = "100"
                            }) {
                                Text("100")
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(Color.gray)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
                            .fixedSize()
                            
                            Button(action: {
                                goal = "10000"
                            }) {
                                Text("10000")
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(Color.gray)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
                            .fixedSize()
                            
                            Button(action: {
                                showCustomGoal.toggle()
                            }) {
                                Text("Custom")
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(Color.gray)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
                            .fixedSize()
                            
                            Spacer()
                        }
                        
                    }
                    if showCustomGoal {
                        TextField("Custom Goal", text: $goal)
                    }
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
            selectedFriends.insert(friend.id)
            fetchBuildingImage(imageURL: "https://static.vecteezy.com/system/resources/previews/011/453/045/original/skyscraper-pixel-art-style-free-vector.jpg", index: 0)
            fetchBuildingImage(imageURL: "https://media.istockphoto.com/id/1358860685/vector/house-icon-pixel-art-front-view-a-small-hut-vector-simple-flat-graphic-illustration-the.jpg?s=612x612&w=0&k=20&c=qodGeD6HSaJKRrZhglbSjXnGnrdXVZsyAlwdlcPaDZw=", index: 1)
            
        }
        .accentColor(.blue)
    }
    
    /**
         Asynchronously fetches an image from the provided URL and assigns it to the appropriate image state variable.
         
         - Parameters:
            - imageURL: The URL of the image to be fetched.
            - index: The index indicating which image state variable to update.
        */
    
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

    /**
        Fetches the list of friends associated with the authenticated user and updates the 'friends' dictionary.
       */
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

        
    
    
    // create and store the new grouphabit
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
            buildingID = "t61IP0alWTc4cIbUwcIL"
        }
        else{buildingID = "t61IP0alWTc4cIbUwcIL"}
        // habit data
        let habitData: [String: Any] = [
            "name": habitName,
            "buildingID": buildingID,
            "progress": 0,
            "goal": goalValue,
            "note": [:],
            "contributions": contributions,
            "isPublic": true,
            "identifier": selectedIdentifier
        ]

        // Add the habit to Firestore

        let newDocument = db.collection("habits").document()
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
