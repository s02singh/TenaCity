import Foundation
import FirebaseAuth
import GoogleSignIn
import Firebase
import SwiftUI


class AuthManager: ObservableObject {
    @Published var isSignIn = false
    @Published var isLoading = true
    @Published var userName: String?
    
    func checkUserSignIn() {
        if let _ = Auth.auth().currentUser {
            isSignIn = true
        } else {
            isSignIn = false
        }
        isLoading = false
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            isSignIn = false
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
