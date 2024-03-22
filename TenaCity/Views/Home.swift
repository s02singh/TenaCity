
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
        Text("This is the info sheet")
            .padding()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
