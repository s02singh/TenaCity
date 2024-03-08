//
//  SettingsView.swift
//  TenaCity
//
//  Created by Lena Ray on 2/29/24.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var user: User?
    
    var body: some View {
        VStack {
            if let user = user {
                Text("Username: \(user.username)")
                Text("Email: \(user.email)")
            } else {
                ProgressView()
            }
        }
        .onAppear {
            fetchUserInfo()
        }
    }
    
    private func fetchUserInfo() {
        guard let userID = authManager.userID else {
            return
        }
        
        authManager.firestoreManager.fetchUser(id: userID) { user, error in
            if let error = error {
                print("Error fetching user: \(error.localizedDescription)")
            } else if let fetchedUser = user {
                self.user = fetchedUser
            } else {
                print("User not found.")
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
