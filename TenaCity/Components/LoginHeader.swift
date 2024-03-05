
import SwiftUI

struct LoginHeader: View {
    var body: some View {
        VStack {
            Text("Welcome to TenaCity!")
                .multilineTextAlignment(.center)
        }
    }
}

struct LoginHeader_Previews: PreviewProvider {
    static var previews: some View {
        LoginHeader()
    }
}
