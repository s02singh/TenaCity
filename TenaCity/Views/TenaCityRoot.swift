
import SwiftUI
import FirebaseAuth


struct TenaCityRoot: View {
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
