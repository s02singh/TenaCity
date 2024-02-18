
import SwiftUI

struct LoadingScreen: View {
    var body: some View {
        VStack {
            ProgressView()
                .padding()
                .progressViewStyle(CircularProgressViewStyle())
            Text("Loading...")
                .padding()
        }
    }
}
