
//
//  LoginScreen.swift
//  TenaCity
//
//  Created by Sahilbir Singh on 2/17/24.
//



import Foundation
import FirebaseAuth
import GoogleSignIn
import Firebase
import SwiftUI
import FirebaseFirestore


// LoginScreen: A view struct for the entire login process.

struct LoginScreen: View {
    @State var username: String = ""
    @State var password: String = ""
    @EnvironmentObject var authManager: AuthManager
    @ObservedObject var firestoreManager = FirestoreManager()
    
    var body: some View {
        VStack {
            VStack {
                
                // Display logo
                Image("TenaCityLogo")
                     .resizable()
                     .aspectRatio(contentMode: .fit)
                     .frame(width: 200, height: 200)
                
                // Displays the header, a nice welcome message..
                LoginHeader()
                    .padding(.bottom)
                
                // Prompt to enter username
                TextField("Username", text: $username)
                    .padding(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke()
                    )
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                
                // Prompt to enter password
                TextField("Password", text: $password)
                    .padding(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke()
                    )
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                
                // Button for forgot password - in progress.
                /*
                HStack {
                    Spacer()
                    Button(action: {}) {
                        Text("Forgot Password?")
                    }
                }
                .padding(.trailing, 24)
                */
                
                // Login button
                Button(action: {
                    
                    Task {
                        
                        do {
                            // if successful, it will set the user's appropriate firebalses
                            // after retrieving them from the firebase.
                            if let (userId, userName) = try await authManager.signIn(username: username, password: password) {
                             
                                UserDefaults.standard.set(userId, forKey: "userID")
                                authManager.userID = userId
                                authManager.userName = userName
                                authManager.isSignIn = true
                                UserDefaults.standard.set(true, forKey: "signIn")
                               
                            } else {
                            
                            }
                        } catch {
                            print("Error signing in: \(error)")
                        }
                            }
                    
                }) {
                    HStack {
                        Spacer()
                        Text("Login")
                            .foregroundColor(.white)
                        Spacer()
                    }
                }
                .padding()
                .background(.black)
                .cornerRadius(12)
                .padding()
            
                
                
                // Google signin button
                GoogleSiginBtn {
                    
                    // Google sigin functionality
                    guard let clientID = FirebaseApp.app()?.options.clientID else { return }
                    
                    let config = GIDConfiguration(clientID: clientID)
                    
                    GIDSignIn.sharedInstance.configuration = config
                    
                    // Opens window to login
                    GIDSignIn.sharedInstance.signIn(withPresenting: getRootViewController()) { signResult, error in
                        
                        if let error = error {
                            //
                            return
                        }
                        
                        
                        // Retrieves all information from Google account to make a TenaCity account
                        // Also sets the authManager variables
                        guard let user = signResult?.user,
                              let idToken = user.idToken else { return }
                        
                        guard let profile = user.profile else{ return }
                        authManager.userName = profile.name
                        let accessToken = user.accessToken
                        
                        let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
               
                        Auth.auth().signIn(with: credential) { authResult, error in
                           
                        }
                        // Checks if email is already linked to a user
                        let db = Firestore.firestore()
                        let usersRef = db.collection("users")
                        
                        
                        guard let userProfile = user.profile else{return}
                        let userEmail = userProfile.email
                        
                        usersRef.whereField("email", isEqualTo: userEmail).getDocuments { querySnapshot, error in
                            if let error = error {
                                
                                print("Error querying Firestore: \(error.localizedDescription)")
                                return
                            }
                            
                            if let document = querySnapshot?.documents.first, document.exists {
                                // User exists
                                print("User already exists.")
                                if let userId = document.get("id") as? String {
                                    // Store user ID in UserDefaults
                                    UserDefaults.standard.set(userId, forKey: "userID")
                                    authManager.userID = userId
                                    firestoreManager.fetchUser(id: userId) { user, error in
                                        if let error = error {
                                            print("Error fetching user: \(error.localizedDescription)")
                                        } else if let fetchedUser = user {
                                            authManager.user = fetchedUser
                                        } else {
                                            print("User not found.")
                                        }
                                    }
                                    print(userId)
                                }
                            } else {
                                // User doesn't exist so make a new one
                                if let profile = user.profile {
                                    firestoreManager.createUser(email: userEmail, password: "TODO", username: profile.name)
                                }
                            }
                        }
                        
                        print("SIGN IN")
                        UserDefaults.standard.set(true, forKey: "signIn")
                        
                    }
                }

                } // GoogleSiginBtn
            } // VStack
            .padding(.top, 52)
            Spacer()
        }
    }



struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreen()
    }
}
