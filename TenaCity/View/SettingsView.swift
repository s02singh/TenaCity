//
//  SettingsView.swift
//  TenaCity
//
//  Created by Divya Raj on 2/26/24.
//

import SwiftUI

struct SettingsView: View {
    @State var myName: String = ""
    @State var username: String = ""
    @State var password: String = "" //need a user struct with this var
    @State var email: String = ""
    @State var maxStreak: String = ""
    @State var stars: String = ""
    
    var body: some View {
        VStack {
            Text(myName + "'s City")
            
            HStack {
                Text("Username:")
                TextField("username", text: $username)
                    .onAppear {
                        username = UserDefaults.standard.string(forKey: "username") ?? username
                    }
            }
            
            HStack {
                Text("Password:")
                TextField("password", text: $stars)
                    .onAppear {
                        password = stars
                        stars = ""
                        for _ in password {
                            stars += "*"
                        }
                    }
            }
            
            HStack {
                Text("Email:")
                TextField("email", text: $email)
            }
            
            HStack {
                Text("Max Streak:")
                TextField("maxStreak", text: $maxStreak)
            }
            
            
            //Add Nav Bar
            
        }
    }
}

#Preview {
    SettingsView()
}
