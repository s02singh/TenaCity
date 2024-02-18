
//
//  LoginScreen.swift
//  TenaCity
//
//  Created by Sahilbir Singh on 2/17/24.
//



import Foundation
import FirebaseAuth
import GoogleSignIn
import Firebase
import SwiftUI

struct LoginScreen: View {
    @State var username: String = ""
    @State var password: String = ""
    
    var body: some View {
        VStack {
            VStack {
                LoginHeader()
                    .padding(.bottom)
                
                TextField("Username", text: $username)
                    .padding(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke()
                    )
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                
                TextField("Password", text: $password)
                    .padding(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke()
                    )
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                
                HStack {
                    Spacer()
                    Button(action: {}) {
                        Text("Forgot Password?")
                    }
                }
                .padding(.trailing, 24)
                
                CustomButton()
                
                
                GoogleSiginBtn {
                    guard let clientID = FirebaseApp.app()?.options.clientID else { return }
                    
                    let config = GIDConfiguration(clientID: clientID)
                    
                    GIDSignIn.sharedInstance.configuration = config
                    
                    GIDSignIn.sharedInstance.signIn(withPresenting: getRootViewController()) { signResult, error in
                        
                        if let error = error {
                            //
                            return
                        }
                        
                        guard let user = signResult?.user,
                              let idToken = user.idToken else { return }
                        
                        let accessToken = user.accessToken
                        
                        let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
               
                        Auth.auth().signIn(with: credential) { authResult, error in
                            
                        }
                        print("SIGN IN")
                        UserDefaults.standard.set(true, forKey: "signIn")
                        
                    }
                }

                } // GoogleSiginBtn
            } // VStack
            .padding(.top, 52)
            Spacer()
        }
    }



struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreen()
    }
}
