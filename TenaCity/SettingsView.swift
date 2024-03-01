//
//  SettingsView.swift
//  TenaCity
//
//  Created by Lena Ray on 2/29/24.
//

import SwiftUI

struct SettingsView: View {
    @Binding var username: String
    @State private var originalUsername: String
    @State private var password: String = "*******"
    @State private var email: String = ""
    @FocusState private var isTextFieldFocused: Bool
    let streakCount = 0
    let userID: String
    
    @ObservedObject var firestoreManager: FirestoreManager
    @State private var isDataLoaded = false
    
    init(username: Binding<String>, userID: String, firestoreManager: FirestoreManager) {
            self._username = username
            self._originalUsername = State(initialValue: username.wrappedValue)
            self.userID = userID
            self.firestoreManager = firestoreManager
    }
    
    var body: some View {
        VStack {
            Spacer()
                .onTapGesture {
                    isTextFieldFocused = false
                }
            
            Text("\(username)'s City")
                .font(.title)
                .padding()
            
            TextField("Username", text: $username)
                .focused($isTextFieldFocused)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
            
//            TextField("Password", text: $password)
//                .padding()
//                .frame(maxWidth: .infinity)
//                .background(Color.white)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 8)
//                        .stroke(Color.gray, lineWidth: 1)
//                )
//                .disabled(true)
            
            TextField("Email", text: $email)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .disabled(true)
            
            Spacer()
                .frame(height: 20)
            
            HStack {
                Text("")
                    .padding(.trailing, 8)
                    .foregroundColor(.gray)
                
                Button("Save") {
                    Task {
                        isTextFieldFocused = false
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                
                Spacer()
                    .onTapGesture {
                        isTextFieldFocused = false
                    }
                
            }
            
            Spacer()
        }
        .padding()
        .contentShape(Rectangle())
        .onTapGesture {
            isTextFieldFocused = false
        }
        .onAppear {
            firestoreManager.fetchUser(id: "aNidfr4ppzmPzKB3MbFw") { user, error in
                if let error = error {
                    print("Error fetching user: \(error.localizedDescription)")
                } else if let user = user {
                    username = user.username
                    originalUsername = user.username
                    email = user.email
                } else {
                    print("User not found.")
                }
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func updateUsernameInFirestore() async {
        if username != originalUsername {
            do {
                try await firestoreManager.updateUser(username: username, id: userID) { error in
                    if let error = error {
                        print("Failed to update username in Firestore: \(error.localizedDescription)")
                    } else {
                        originalUsername = username
                    }
                }
            }
        }
    }
}

//struct SettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsView(username: .constant("John Doe"), firestoreManager: FirestoreManager())
//    }
//}

//#Preview {
//    SettingsView(username: .constant("John Doe"))
//}
