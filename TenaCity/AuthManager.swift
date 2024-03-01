import Foundation
import FirebaseAuth
import GoogleSignIn
import Firebase
import SwiftUI
import FirebaseFirestore
import FirebaseCore

class AuthManager: ObservableObject {
    @Published var isSignIn = false
    @Published var isLoading = true
    @Published var userName: String?
    @Published var userID: String?
    
    func checkUserSignIn() {
        if let _ = Auth.auth().currentUser {
            isSignIn = true
        } else {
            isSignIn = false
        }
        isLoading = false
    }
    
    func signIn(username: String, password: String) async throws -> (userId: String, username: String)?{

        let users = try await Firestore.firestore().collection("users").whereField("username", isEqualTo: username).getDocuments()
         
        print("in here")
        let documents = users.documents
            if let user = documents.first?.data() {
                if let storedPassword = user["password"] as? String {
                    if comparePasswords(password: password, storedPassword: storedPassword) {
                        if let userId = documents.first?.documentID, let userName = user["username"] as? String {
                            print(userName)
                            print(userId)
                            return (userId, userName)
                        }
                    }
                }
            }
        return nil
      }
    
    private func comparePasswords(password: String, storedPassword: String) -> Bool {
        return password == storedPassword
      }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            isSignIn = false
            self.userID = nil
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
