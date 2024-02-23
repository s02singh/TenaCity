
import SwiftUI
import FirebaseAuth

@main
struct TenaCity: App {
    @AppStorage("signIn") var isSignIn = false
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var authManager = AuthManager()
    @StateObject var firestoreManager = FirestoreManager()

    
    var body: some Scene {
        WindowGroup {
            if !isSignIn {
                LoginScreen()
                    .preferredColorScheme(.light)
                    .environmentObject(authManager)
            } else {
                NavigationStack{
                    Home()
                        .preferredColorScheme(.light)
                        .environmentObject(authManager)
                }
                .environmentObject(authManager)
 
            }
        }
    }
}
