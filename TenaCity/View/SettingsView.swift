//
//  SettingsView.swift
//  TenaCity
//
//  Created by Divya Raj on 2/26/24.
//

import SwiftUI

struct SettingsView: View {
    @State var username: String = "_______" // can update this later
    @State var password: String = "" //need a user struct with this var
    @State var email: String = ""
    @State var maxStreak: String = "0"
    @State var stars: String = ""
    
    var body: some View {
        Text(username + "'s City")
            .padding(EdgeInsets(top: 60, leading: 0, bottom: 0, trailing: 0))
            .font(.system(size: 40))
        VStack {
            Spacer()
            HStack {
                Text("Username:")
                    .font(.system(size: 25))
                TextField("\(username)", text: $username)
                    .onAppear {
                        username = UserDefaults.standard.string(forKey: "username") ?? username
                        //this is all dummy logic - will update once user class is created
                    }
                    .onChange(of: username) { input in
                        username = input
                    }
                    .font(.system(size: 25))
            }
            .padding(.horizontal)
            .padding(EdgeInsets(top: 0, leading: 50, bottom: 0, trailing: 0))
            
            HStack {
                Text("Password:")
                    .font(.system(size: 25))
                TextField("\(password)", text: $stars)
                    .onAppear {
                        password = stars
                        stars = ""
                        for _ in password {
                            stars += "*"
                        }
                    }
                    .onChange(of: stars) { input in
                        password = input
                    }
                    .font(.system(size: 25))
            }
            .padding(.horizontal)
            .padding(EdgeInsets(top: 0, leading: 50, bottom: 0, trailing: 0))

            HStack {
                Text("Email:")
                    .font(.system(size: 25))
                TextField("\(email)", text: $email)
                    .onChange(of: email) { input in
                        email = input
                    }
                    .font(.system(size: 25))
            }
            .padding(.horizontal)
            .padding(EdgeInsets(top: 0, leading: 50, bottom: 0, trailing: 0))
            
            HStack {
                Text("Max Streak:")
                    .font(.system(size: 25))
                TextField("\(maxStreak)", text: $maxStreak)
                    .disabled(true)
                    .font(.system(size: 25))
            }
            .padding(.horizontal)
            .padding(EdgeInsets(top: 0, leading: 50, bottom: 0, trailing: 0))
            
            Spacer()
            Button {
                //add later
            } label: {
                Text("Save")
                    .foregroundStyle(Color("SageGreen"))
            }
        }
        .frame(height: .infinity, alignment: .center)
        NavigationBar()
            .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    SettingsView()
}
