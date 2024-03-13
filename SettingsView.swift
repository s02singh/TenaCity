//
//  SettingsView.swift
//  TenaCity
//
//  Created by Lena Ray on 2/29/24.
//

import GoogleSignIn
import Firebase
import SwiftUI

struct SecureTextField: View {
    @State var isSecureField: Bool = true
    @Binding var text: String
    
    var body: some View {
        HStack {
            if isSecureField {
                SecureField("Password", text: $text)
            } else {
                TextField("Password", text: $text)
            }
        }
        .overlay(alignment: .trailing) {
            Image(systemName: isSecureField ? "eye" : "eye.slash")
                .onTapGesture {
                    isSecureField.toggle()
                }
        }
    }
}

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
            Text("\(authManager.userName ?? "User")'s City")
                .font(.title)
                .padding()
            
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
                .focused($focusedField, equals: .username)
                .onTapGesture {
                    focusedField = .username
                }
                .onAppear {
                    username = authManager.userName ?? ""
                }
            
            SecureTextField(text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
                .onTapGesture {
                    focusedField = .password
                }
            
//            Text(LocalizedStringKey(authManager.user?.email ?? "email"))
//                .padding(.horizontal, 20)
            
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
            .padding()
            
            Spacer()
            SignOutButton()
            
            
        }
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField = nil
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .onReceive(authManager.$userName) { userName in
            username = userName ?? ""
            print(username)
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
