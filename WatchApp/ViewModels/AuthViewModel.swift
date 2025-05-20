//
//  AuthViewModel.swift
//  WatchApp
//
//  Created by Frida Eriksson on 2025-05-19.
//

import Foundation
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isSignedIn: Bool = false
    
    
    init() {
        if let currentUser = Auth.auth().currentUser {
            self.user = User(uid: currentUser.uid, isAnonymous: currentUser.isAnonymous)
            self.isSignedIn = true
        }
    }
    
    func signInAnonymously() {
        Auth.auth().signInAnonymously { [weak self] result, error in
            if let error = error {
                print("Error signing in anonymously: \(error.localizedDescription)")
                return
            }
            
            if let firebaseUser = result?.user {
                let user = User(uid: firebaseUser.uid, isAnonymous: firebaseUser.isAnonymous)
                self?.user = user
                self?.isSignedIn = true
                print("Signed in anonymously with Uid: \(firebaseUser.uid)")
            }
        }
    }
}
