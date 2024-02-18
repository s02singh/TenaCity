import SwiftUI

struct LoadingScreen: View {
    @EnvironmentObject private var authManager: AuthManager
    @State private var showingHomeView = false

    var body: some View {
        VStack {
            HStack {
                // Company name
                Text("Bank")
                    .font(.custom("AvenirNext-DemiBold", size: 60))
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0, green: 128/255, blue: 128/255))
                
                Text("it")
                    .font(.custom("AvenirNext-DemiBold", size: 60))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
            }
            .padding(.top, 10)
            
            
            /* Comapny logo
            Image("BankItLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .padding(.top, 30)
             */
            
            Text("Verifying Login")
                .foregroundColor(Color(red: 0, green: 128/255, blue: 128/255))
                .padding(.top, 50)

            // Nice progressview visual while userManager is being set up.
            // We retrieve data from server using authToken and set our user values locally.
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0, green: 128/255, blue: 128/255)))
                .scaleEffect(2.0)
                .padding(.top, 20)
                .onAppear {
    
                                showingHomeView = true
                            
                            
                                                    
                     
                           // error handle
                               
                            
                        
                    
                }
        }
        .padding()
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showingHomeView) {
            Home()
                  }
        .navigationBarBackButtonHidden()
        .navigationBarHidden(true)
    }
}

struct LoadingScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoadingScreen()
    }
}
