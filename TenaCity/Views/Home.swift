
import Foundation
import FirebaseAuth
import GoogleSignIn
import Firebase
import SwiftUI
import FirebaseFirestore

struct Home: View {
    @State private var displayName: String = ""
    @EnvironmentObject var authManager: AuthManager
    @State private var newPassword: String = ""
    @EnvironmentObject var healthManager: HealthManager
    @State private var isNavigatingToFriends = false
        
    var body: some View {
        VStack {
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
                            authManager.userID = UserDefaults.standard.object(forKey: "userID") as? String
                        }
                        
                        
                        /// KEEP FOR LATER IF WE WANT MORE THAN GOOGLE SIGNIN
                        /*
                         if let currentUser = Auth.auth().currentUser {
                         self.displayName = currentUser.displayName ?? ""
                         }
                         */
                        
                    }
                FriendsViewButton(isNavigatingToFriends: $isNavigatingToFriends)
                
                SignOutButton()
            }
            .navigationDestination(isPresented: $isNavigatingToFriends) {
                FriendsView().environmentObject(authManager)
            }
            
            VStack {
                TextField("New Password", text: $newPassword)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: {
                    
                    self.setPassword(newPassword: newPassword)
                    
                }) {
                    Text("Set Password")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
                
                NavigationLink(destination: BuildingView().environmentObject(healthManager)) {
                    Text("Go to Building View")
                }
            }
            Spacer()
            NavigationBar()
        }
        .ignoresSafeArea(.keyboard)
    }
    
    private func setPassword(newPassword: String) {
        let db = Firestore.firestore()
        guard let userID = authManager.userID else{return}
        let userRef = db.collection("users").document(userID)
        
        userRef.getDocument { document, error in
            if let document = document, document.exists {
              
                userRef.updateData(["password": newPassword]) { error in
                    if let error = error {
                        print("Error updating document: \(error)")
                    } else {
                        print("Password successfully updated")
                    }
                }
            } else {
             
                userRef.setData(["password": newPassword]) { error in
                    if let error = error {
                        print("Error adding document: \(error)")
                    } else {
                        print("Password successfully set")
                    }
                }
            }
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

struct FriendsViewButton: View {
    @Binding var isNavigatingToFriends: Bool
    
    var body: some View {
        Button("Friends View") {
            isNavigatingToFriends = true
        }
        .font(.headline)
        .foregroundColor(.white)
        .padding()
        .background(Color.blue)
        .cornerRadius(10)
        .padding()
    }
}
