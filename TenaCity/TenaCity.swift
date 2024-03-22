
import SwiftUI
import FirebaseAuth

@main
struct TenaCity: App {
    // Basic setup of managers and check if signedin.
    // If you are signed in, you can skip the loginscreen.
    @AppStorage("signIn") var isSignIn = false
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var authManager = AuthManager()
    @StateObject var firestoreManager = FirestoreManager()
    @StateObject var healthManager = HealthManager()

    var body: some Scene {
        WindowGroup {
            // Start off by calling the splashscreen
            Splash()
                .preferredColorScheme(.light)
        }
    }
}
