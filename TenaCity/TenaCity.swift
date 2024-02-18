
import SwiftUI

@main
struct TenaCity: App {
    @AppStorage("signIn") var isSignIn = false
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var authManager = AuthManager()
    
    var body: some Scene {
        WindowGroup {
            if !isSignIn {
                LoginScreen()
                    .preferredColorScheme(.light)
                    .environmentObject(authManager)
            } else {
                Home()
                    .preferredColorScheme(.light)
                    .environmentObject(authManager)
            }
        }
    }
}
