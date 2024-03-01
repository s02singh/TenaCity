//
//  FirestoreManager.swift
//  TenaCity
//
//  Created by Shikhar Gupta on 2/22/24.
//

import Foundation
import Firebase
import FirebaseFirestore

class FirestoreManager: ObservableObject {
    var db: Firestore
    // maybe todo: make a state object of the current user
    
    init() {
        db = Firestore.firestore()
        
        /* How to fetch a user
        fetchUser(id: "LJ92RtswXZzgZFK2J6EM") { user, error in
            if let error = error {
                print("Error fetching user: \(error.localizedDescription)")
            } else if let user = user {
                print("Fetched user: \(user)")
            } else {
                print("User not found.")
            }
        }
         */
    }

    func createUser(email: String, username: String) -> User {
        let userRef = db.collection("users").document()
        let newUser = User(id: userRef.documentID, email: email, username: username, accountCreationDate: Date(), userInvitedIDs: [], habitIDs: [], friendIDs: [])
        userRef.setData(newUser.dictionary) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("User added with ID: \(String(describing: newUser.id))")
            }
        }
        return newUser
    }

    func createHabit(name: String, building: Building) -> Habit {
        let habitRef = db.collection("habits").document()
        let newHabit = Habit(id: habitRef.documentID, name: name, buildingID: building.id, dates: [], streak: 0, note: "", isPublic: false)
        habitRef.setData(newHabit.dictionary) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Habit added with ID: \(String(describing: newHabit.id))")
            }
        }
        return newHabit
    }

    func createPost(description: String, user: User, habit: Habit) {
        let postRef = db.collection("posts").document()
        let newPost = Post(id: postRef.documentID, habitID: habit.id, userID: user.id, votes: 0, description: description, interactedIDs: [])
        postRef.setData(newPost.dictionary) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Post added with ID: \(String(describing: newPost.id))")
            }
        }
    }

    func createBuilding(levels: [Skin]) -> Building {
        let buildingRef = db.collection("buildings").document()
        let newBuilding = Building(id: buildingRef.documentID, levelsIDs: levels.map { $0.id })
        buildingRef.setData(newBuilding.dictionary) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Building added with ID: \(String(describing: newBuilding.id))")
            }
        }
        return newBuilding
    }

    func createSkin(url: String) -> Skin {
        let skinRef = db.collection("skins").document()
        let newSkin = Skin(id: skinRef.documentID, url: url)
        skinRef.setData(newSkin.dictionary) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Skin added with ID: \(String(describing: newSkin.id))")
            }
        }
        return newSkin
    }
    
    func fetchUser(id: String, completion: @escaping (User?, Error?) -> Void) {
        let userDocument = db.collection("users").document(id)

        userDocument.getDocument { document, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let document = document, document.exists else {
                completion(nil, nil)
                return
            }

            if let userData = document.data(),
               let id = userData["id"] as? String,
               let email = userData["email"] as? String,
               let username = userData["username"] as? String,
               let accountCreationTimestamp = userData["accountCreationDate"] as? Timestamp,
               let userInvitedIDs = userData["userInvitedIDs"] as? [String],
               let habitIDs = userData["habitIDs"] as? [String],
               let friendIDs = userData["friendIDs"] as? [String] {
                   let user = User(id: id,
                                   email: email,
                                   username: username,
                                   accountCreationDate: accountCreationTimestamp.dateValue(),
                                   userInvitedIDs: userInvitedIDs,
                                   habitIDs: habitIDs,
                                   friendIDs: friendIDs)
                   
                   completion(user, nil)
            } else {
                let dataError = NSError(domain: "DataUnwrapError", code: 1, userInfo: nil)
                completion(nil, dataError)
            }
        }
    }
    
    // Fetch Habit
    func fetchHabit(id: String, completion: @escaping (Habit?, Error?) -> Void) {
        let habitDocument = db.collection("habits").document(id)

        habitDocument.getDocument { document, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let document = document, document.exists else {
                completion(nil, nil)
                return
            }

            if let habitData = document.data(),
               let id = habitData["id"] as? String,
               let name = habitData["name"] as? String,
               let buildingID = habitData["buildingID"] as? String,
               let dates = habitData["dates"] as? [Date],
               let streak = habitData["streak"] as? Int,
               let note = habitData["note"] as? String,
               let isPublic = habitData["isPublic"] as? Bool {
                   let habit = Habit(id: id,
                                     name: name,
                                     buildingID: buildingID,
                                     dates: dates,
                                     streak: streak,
                                     note: note,
                                     isPublic: isPublic)
                   
                   completion(habit, nil)
            } else {
                let dataError = NSError(domain: "DataUnwrapError", code: 1, userInfo: nil)
                completion(nil, dataError)
            }
        }
    }

    // Fetch Post
    func fetchPost(id: String, completion: @escaping (Post?, Error?) -> Void) {
        let postDocument = db.collection("posts").document(id)

        postDocument.getDocument { document, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let document = document, document.exists else {
                completion(nil, nil)
                return
            }

            if let postData = document.data(),
               let id = postData["id"] as? String,
               let habitID = postData["habitID"] as? String,
               let userID = postData["userID"] as? String,
               let votes = postData["votes"] as? Int,
               let description = postData["description"] as? String,
               let interactedIDs = postData["interactedIDs"] as? [String] {
                   let post = Post(id: id,
                                   habitID: habitID,
                                   userID: userID,
                                   votes: votes,
                                   description: description,
                                   interactedIDs: interactedIDs)
                   
                   completion(post, nil)
            } else {
                let dataError = NSError(domain: "DataUnwrapError", code: 1, userInfo: nil)
                completion(nil, dataError)
            }
        }
    }

    // Fetch Building
    func fetchBuilding(id: String, completion: @escaping (Building?, Error?) -> Void) {
        let buildingDocument = db.collection("buildings").document(id)

        buildingDocument.getDocument { document, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let document = document, document.exists else {
                completion(nil, nil)
                return
            }

            if let buildingData = document.data(),
               let id = buildingData["id"] as? String,
               let levelsIDs = buildingData["levelsIDs"] as? [String] {
                   let building = Building(id: id,
                                           levelsIDs: levelsIDs)
                   
                   completion(building, nil)
            } else {
                let dataError = NSError(domain: "DataUnwrapError", code: 1, userInfo: nil)
                completion(nil, dataError)
            }
        }
    }

    // Fetch Skin
    func fetchSkin(id: String, completion: @escaping (Skin?, Error?) -> Void) {
        let skinDocument = db.collection("skins").document(id)

        skinDocument.getDocument { document, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let document = document, document.exists else {
                completion(nil, nil)
                return
            }

            if let skinData = document.data(),
               let id = skinData["id"] as? String,
               let url = skinData["url"] as? String {
                   let skin = Skin(id: id,
                                   url: url)
                   
                   completion(skin, nil)
            } else {
                let dataError = NSError(domain: "DataUnwrapError", code: 1, userInfo: nil)
                completion(nil, dataError)
            }
        }
    }
    
    
    func addFriend(user: User, friend: User) {
        let userDocument = db.collection("users").document(user.id)
        let friendDocument = db.collection("users").document(friend.id)
        
        userDocument.updateData(["friendIDs": FieldValue.arrayUnion([friend.id])]) { error in
            if let error = error {
                print("Error adding friend: \(error)")
            } else {
                print("Friend added to user's friend list")
            }
        }
        
        friendDocument.updateData(["friendIDs": FieldValue.arrayUnion([user.id])]) { error in
            if let error = error {
                print("Error adding friend: \(error)")
            } else {
                print("User added to friend's friend list")
            }
        }
    }
    
    func addHabitToUser(user: User, habit: Habit) {
        let userDocument = db.collection("users").document(user.id)
        
        userDocument.updateData(["habitIDs": FieldValue.arrayUnion([habit.id])]) { error in
            if let error = error {
                print("Error adding habit: \(error)")
            } else {
                print("Habit added to user's habit list")
            }
        }

    }
    
    
    func populateFirestore() {
        // Create users
        let user1 = createUser(email: "user1@abc.com", username: "fakeUser1")
        let user2 = createUser(email: "user2@abc.com", username: "fakeUser2")
        let user3 = createUser(email: "user3@abc.com", username: "fakeUser3")
        
        // Create building skins
        let houseSkin = createSkin(url: "https://media.istockphoto.com/id/1358860685/vector/house-icon-pixel-art-front-view-a-small-hut-vector-simple-flat-graphic-illustration-the.jpg?s=612x612&w=0&k=20&c=qodGeD6HSaJKRrZhglbSjXnGnrdXVZsyAlwdlcPaDZw=")
        let skyscraperSkin = createSkin(url: "https://static.vecteezy.com/system/resources/previews/011/453/045/original/skyscraper-pixel-art-style-free-vector.jpg")
        
        // Create building with skins
        let building = createBuilding(levels: [houseSkin, skyscraperSkin])
        
        // Create habits
        let habit1User1 = createHabit(name: "Exercise", building: building)
        let habit2User1 = createHabit(name: "Meditation", building: building)
        let habit1User2 = createHabit(name: "Reading", building: building)
        
        // Make user1 and user2 friends
        addFriend(user: user1, friend: user2)
        
        // Create Post
        createPost(description: "My first post", user: user1, habit: habit1User1)
        
        // Add habits
        addHabitToUser(user: user1, habit: habit1User1)
        addHabitToUser(user: user1, habit: habit2User1)
        addHabitToUser(user: user2, habit: habit1User2)
    }
    
    func updateUser(username: String, id: String, completion: @escaping(Error?) -> Void) {
        let userRef = db.collection("users").document(id)
        
        userRef.updateData(["username": username]) { error in
            if let error = error {
                print("Error updating username: \(error)")
                completion(error)
            } else {
                print("Username updated successfully")
                completion(nil)
            }
        }
    }
}
