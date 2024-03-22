
import SwiftUI
import FirebaseAuth


struct TenaCityRoot: View {
    
    // Basic setup of managers and check if signedin.
    // If you are signed in, you can skip the loginscreen.
    @AppStorage("signIn") var isSignIn = false
    @StateObject var authManager = AuthManager()
    @StateObject var firestoreManager = FirestoreManager()
    @StateObject var healthManager = HealthManager()
    
    var body: some View {
            if !isSignIn {
                LoginScreen()
                    .preferredColorScheme(.light)
                    .environmentObject(authManager)
                    .environmentObject(healthManager)
            } else {
                NavigationStack {
                    Home()
                        .preferredColorScheme(.light)
                        .environmentObject(authManager)
                        .environmentObject(healthManager)
                }
            }
        }
    
}
