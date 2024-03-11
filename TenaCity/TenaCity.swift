
import SwiftUI
import FirebaseAuth

@main
struct TenaCity: App {
    @AppStorage("signIn") var isSignIn = false
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var authManager = AuthManager()
    @StateObject var firestoreManager = FirestoreManager()
    @StateObject var healthManager = HealthManager()
    @StateObject var locationManager = LocationManager()

    var body: some Scene {
        WindowGroup {
            Splash()
                .preferredColorScheme(.light)
        }
    }
}
