//
//  SettingsView.swift
//  TenaCity
//
//  Created by Lena Ray on 2/29/24.
//

import GoogleSignIn
import Firebase
import SwiftUI

struct SettingsView: View {
    @ObservedObject var authManager = AuthManager()
    @ObservedObject var firestoreManager = FirestoreManager()
    @State private var username = ""
    @State private var password = ""
    @State private var email = ""
    @State private var isEditingUsername = false
    @State private var isEditingPasswrod = false
    @FocusState private var focusedField: Field?
    @State private var isPasswordVisible = false
    
    enum Field {
        case username, password
    }
    
    var body: some View {
        VStack {
            VStack {
                Text("\(authManager.userName ?? "User")'s City")
                    .font(.title)
                    .padding()
                Spacer()
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                    .onAppear {
                        username = authManager.userName ?? ""
                    }
                ZStack {
                    if isPasswordVisible {
                        TextField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(minWidth: 0, maxWidth: .infinity)
                    } else {
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(minWidth: 0, maxWidth: .infinity)
                    }
                    Button(action: {
                        isPasswordVisible.toggle()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.blue)
                            .padding(.leading, 300)
                    }
                    .padding(.trailing, 20)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
                .focused($focusedField, equals: .password)
                .onTapGesture {
                    focusedField = .password
                }
                
                TextField("Email", text: .constant(authManager.user?.email ?? ""))
                    .disabled(true)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 20)
                
                Button("Save") {
                    if !username.isEmpty {
                        firestoreManager.updateUsername(userID: authManager.userID ?? "", newUsername: username) { error in
                            if let error = error {
                                print("Error updating username: \(error.localizedDescription)")
                            } else {
                                authManager.userName = username
                            }
                        }
                    }
                    
                    
                    if !password.isEmpty {
                        firestoreManager.updatePassword(userID: authManager.userID ?? "", newPassword: password) { error in
                            if let error = error {
                                print("Error updating password \(error.localizedDescription)")
                            } else {
                                
                            }
                            
                        }
                    }
                }
                .padding(30)
                
                Spacer()
                SignOutButton()
                Spacer()
                
            }
            .onTapGesture {
                focusedField = nil
            }
        }
        .background(
            Image("testBackground")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .opacity(0.8)
        )
    }
}

struct SignOutButton: View {
    var body: some View {
        Button(action: {
            let firebaseAuth = Auth.auth()
            do {
              try firebaseAuth.signOut()
              UserDefaults.standard.set(false, forKey: "signIn")
              UserDefaults.standard.set(nil, forKey: "userID")
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

