
import SwiftUI
import FirebaseAuth

@main
struct TenaCity: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            Splash()
                .preferredColorScheme(.light)
        }
    }
}
