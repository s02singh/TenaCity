
import SwiftUI


// Needed to extend View so we could return to app after using GIDSignIn
extension View {
    func getRootViewController() -> UIViewController {
        // extends the view to get the first connected scene
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }

        // Gets the root viewcontroller
        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        

        return root
    }
}

