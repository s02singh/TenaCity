import Foundation
import FirebaseAuth
import GoogleSignIn
import Firebase
import SwiftUI
import FirebaseFirestore
import FirebaseCore

class AuthManager: ObservableObject {
    // records various auth variables
    // this includes a signin bool, the username, userID, and the User struct.
    @Published var isSignIn = false
    @Published var isLoading = true
    @Published var userName: String?
    @Published var userID: String?
    @Published var user: User?
    @ObservedObject var firestoreManager = FirestoreManager()
    @ObservedObject var healthManager = HealthManager()
    var timer: Timer?
    
    init() {
        // If we were signed in already, we pull the authmanager data from firebase and store it locally
        if let savedUserID = UserDefaults.standard.string(forKey: "userID") {
            self.userID = savedUserID
            firestoreManager.fetchUser(id: userID ?? "") { user, error in
                if let error = error {
                    print("Error fetching user: \(error.localizedDescription)")
                } else if let fetchedUser = user {
                    self.user = fetchedUser
                    self.userName = fetchedUser.username //username update
                } else {
                    print("User not found.")
                }
            }
            timer = Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { _ in
                self.updateHabits(userID: savedUserID)
            }
        } else {
            print("No user saved")
        }
    }
    
    // Small function for easy check if signin
    func checkUserSignIn() {
        if let _ = Auth.auth().currentUser {
            isSignIn = true
        } else {
            isSignIn = false
        }
        isLoading = false
    }
    
    // signin function used when logging in with a password and username.
    func signIn(username: String, password: String) async throws -> (userId: String, username: String)?{
        print(username)
        // Fetches the user with the current username
        let users = try await Firestore.firestore().collection("users").whereField("username", isEqualTo: username).getDocuments()
         
        // It will compare the passwords of the firestore saved and current inputted.
        let documents = users.documents
        print(documents)
        if let user = documents.first?.data() {
            if let storedPassword = user["password"] as? String {
                if comparePasswords(password: password, storedPassword: storedPassword) {
                    if let userId = documents.first?.documentID, let userName = user["username"] as? String {
                        print(userName)
                        print(userId)
                        self.userID = userID
                        return (userId, userName)
                    }
                }
            }
        }
        return nil
      }
    
    // Helper function to compare passwords. Can incorporate hashing later if we wanted.
    private func comparePasswords(password: String, storedPassword: String) -> Bool {
        return password == storedPassword
      }
    
    // Quick access function to sign out. sets sign in to false.
    func signOut() {
        do {
            try Auth.auth().signOut()
            isSignIn = false
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    func updateHabits(userID: String) {
        print(Date())
        //healthManager.fetchTodaySteps()
    }
}
