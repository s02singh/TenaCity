
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
        
    var body: some View {
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
