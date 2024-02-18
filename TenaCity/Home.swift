
import Foundation
import FirebaseAuth
import GoogleSignIn
import Firebase
import SwiftUI


struct Home: View {
    @State private var displayName: String = ""
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        VStack {
            Text("Hello \(displayName)!")
                .padding()
                .onAppear {
                    if let currentUser = authManager.userName{
                        self.displayName = currentUser
                    }
                    else if let currentUser = Auth.auth().currentUser {
                        self.displayName = currentUser.displayName ?? ""
                        authManager.userName = currentUser.displayName
                    }
                    
                    
                    /// KEEP FOR LATER IF WE WANT MORE THAN GOOGLE SIGNIN
                    /*
                    if let currentUser = Auth.auth().currentUser {
                        self.displayName = currentUser.displayName ?? ""
                    }
                     */
                    
                }
            SignOutButton()
        }
    }
}

struct SignOutButton: View {
    var body: some View {
        Button(action: {
            let firebaseAuth = Auth.auth()
            do {
              try firebaseAuth.signOut()
              UserDefaults.standard.set(false, forKey: "signIn")
            } catch let signOutError as NSError {
              print("Error signing out: %@", signOutError)
            }
        }) {
            Text("Sign Out")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.red)
                .cornerRadius(10)
        }
        .padding()
    }
}
