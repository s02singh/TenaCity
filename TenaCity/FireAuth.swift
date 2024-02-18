//
//  FirebAuth.swift
//  SignInUsingGoogle
//
//  Created by Swee Kwang Chua on 12/5/22.
//

/*
import Foundation
import FirebaseAuth
import GoogleSignIn
import Firebase
import SwiftUI

struct FireAuth {
    static let share = FireAuth()
    
    private init() {}
    
    func signinWithGoogle(presenting: UIViewController,
                          completion: @escaping (Error?) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: View.getRootViewController()) { signResult, error in
            
            if let error = error {
                //
                return
            }
            
            guard let user = signResult?.user,
                  let idToken = user.idToken else { return }
            
            let accessToken = user.accessToken
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
            
            // Use the credential to authenticate with Firebase
            
            
            
            
            // Use the credential to authenticate with Firebase
            
            Auth.auth().signIn(with: credential) { authResult, error in
                
            }
            print("SIGN IN")
            UserDefaults.standard.set(true, forKey: "signIn") // When this change to true, it will go to the home screen
        }
    }
}

*/
