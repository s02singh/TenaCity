
import SwiftUI


// Stylized header for LoginScreen. Idea was to potentially change it but we liked it as is.
struct LoginHeader: View {
    var body: some View {
        VStack {
            Text("Welcome to TenaCity")
                .multilineTextAlignment(.center)
        }
    }
}

struct LoginHeader_Previews: PreviewProvider {
    static var previews: some View {
        LoginHeader()
    }
}
