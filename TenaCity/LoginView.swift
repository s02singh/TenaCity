import SwiftUI
import GoogleSignIn

struct LoginView: View {
    var body: some View {
        VStack {
            Spacer()
            
            /*
             LOGO
            Image("put something here later")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
                .padding(.bottom, 50)
            */
            Text("Welcome to TenaCity")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.bottom, 60)
            
            Button(action: {
                // Set up Oauth here
                // use GoogleSignIn library
            }) {
                Text("Sign in with Google")
                    .fontWeight(.semibold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding()
    }
}
