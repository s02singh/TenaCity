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
    @State private var wrongInput: Bool = false
    
    enum Field {
        case username, password
    }
    
    var body: some View {
        VStack {
            VStack {
                Text("\(authManager.userName ?? "User")'s City")
                    .font(.title)
                    .padding()
                Image("TenaCityLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Spacer()
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                    .onAppear {
                        username = authManager.userName ?? ""
                    }
                    .onChange(of: username) {
                        authManager.userName = username
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
                        Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                            .foregroundColor(.blue)
                            .padding(.leading, 300)
                    }
                    .padding(.trailing, 20)
                    .onChange(of: password){
                        wrongInput = false
                    }
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
                
                if (wrongInput) {
                    Text("Please enter a password with more than 6 characters!")
                        .foregroundColor(Color.red)
                }
                
                Button {
                    if !username.isEmpty {
                        firestoreManager.updateUsername(userID: authManager.userID ?? "", newUsername: username) { error in
                            if let error = error {
                                print("Error updating username: \(error.localizedDescription)")
                            } else {
                                authManager.userName = username
                                print("successful username update")
                            }
                        }
                    }
                    
                    
                    if !password.isEmpty {
                        if (password.count < 6) {
                            wrongInput = true
                        }
                        firestoreManager.updatePassword(userID: authManager.userID ?? "", newPassword: password) { error in
                            if let error = error {
                                print("Error updating username: \(error.localizedDescription)")
                            } else {
                                authManager.updatePassword(pswd: password)
                                print("successful password update")
                            }
                        }
                    }
                } label: {
                    Text("Save")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color("Orange"))
                        .cornerRadius(10)
                }
                .padding(50)
                
                SignOutButton()
                Spacer()
                
            }
            .onTapGesture {
                focusedField = nil
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

