
import Foundation
import FirebaseAuth
import GoogleSignIn
import Firebase
import SwiftUI
import FirebaseFirestore

struct Home: View {
    @State private var displayName: String = ""
    @State private var viewState: Int = 3
    @EnvironmentObject var authManager: AuthManager
    @State private var newPassword: String = ""
    @EnvironmentObject var healthManager: HealthManager
    @State private var isNavigatingToFriends = false
    
    @State private var showingInfoSheet = false
        
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Hello \(displayName)!")
                    .padding(EdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 70))
                    .onAppear {
                        if let currentUser = authManager.userName{
                            self.displayName = currentUser
                        }
                        else if let currentUser = Auth.auth().currentUser {
                            self.displayName = currentUser.displayName ?? ""
                            authManager.userName = currentUser.displayName
                            authManager.userID = UserDefaults.standard.object(forKey: "userID") as? String
                        }
                    }
                    
                Button(action: {
                    showingInfoSheet.toggle()
                }) {
                    Image(systemName: "info.circle")
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color("SageGreen"))
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                .sheet(isPresented: $showingInfoSheet) {
                    InfoSheet()
                }
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            }
            
            TabView (selection: $viewState) {
                Group {
                    FriendsView()
                        .tabItem() {
                            Image(systemName: "person.2")
                        }
                        .tag(2)
                    
                    BuildingView()
                        .tabItem() {
                            Image(systemName: "building.2")
                        }
                        .tag(3)
                    
                    GroupHabitView()
                        .tabItem() {
                            Image(systemName: "person.3")
                        }
                        .tag(4)
                    
                    SettingsView()
                        .tabItem() {
                            Image(systemName: "gearshape")
                        }
                        .tag(5)
                }
                .toolbarBackground(.visible, for: .tabBar)
                .toolbarBackground(Color("SageGreen"), for: .tabBar)
                .toolbarColorScheme(.dark, for: .tabBar)
            }
            
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct InfoSheet: View {
    var body: some View {
        ScrollView {
            VStack {
                Text("Welcome to TenaCity!")
                    .padding()
                    .bold()
                    .font(.largeTitle)
                
                Text("Create a Personal Habit")
                    .font(.title)
                    .frame(alignment: .leading)
                //steps
                VStack(alignment: .leading) {
                    HStack() {
                        Text("1. Navigate to the Building View")
                        Image(systemName: "building.2")
                    }
                    Text("2. Select 'Create Habit'")
                    Text("3. Select your Habit type")
                    Text("4. Select your Goal amount for your Habit")
                    Text("5. Select the building you want to represent your Habit")
                    Text("6. Select 'Save'")
                    Text("7. Start working on your Habit!")
                    
                }
                .padding()
                
                Text("Update Your Account Info")
                    .font(.title)
                    .frame(alignment: .leading)
                //steps
                VStack(alignment: .leading) {
                    HStack() {
                        Text("1. Navigate to the Settings View")
                        Image(systemName: "gearshape")
                    }
                    Text("2. Select the field that you'd like to update")
                    Text("NOTE: You are NOT allowed to edit the email field at this time.")
                    Text("3. Enter your desired information")
                    Text("4. Select 'Save'")
                }
                .padding()
                
                Text("Add a Friend")
                    .font(.title)
                    .frame(alignment: .leading)
                //steps
                Text("1. alsdkfjaldf")
                    .frame(alignment: .center)
                
                Text("Create a Group Habit")
                    .font(.title)
                    .frame(alignment: .leading)
                //steps
                VStack(alignment: .leading) {
                    Text("There are two ways that you can create a Group Habit:")
                    
                    HStack() {
                        Text("1. Through the Friends View")
                        Image(systemName: "person.2")
                        Text("\n")
                    }
                    VStack() {
                        Text("a. Select the 'Group' button next to the friend that you'd like to create a Habit with")
                        Text("b. Enter the name of your Habit")
                    }
                    .padding(.leading, 20)
                    
                }
                .padding()
            }
            .frame(alignment: .center)
            
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        InfoSheet()
    }
}
