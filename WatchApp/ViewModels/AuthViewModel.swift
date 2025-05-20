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
    @Published var errorMessage: String?
    
    init() {
        if let currentUser = Auth.auth().currentUser {
            self.user = User(uid: currentUser.uid, email: currentUser.email, isAnonymous: currentUser.isAnonymous)
            self.isSignedIn = true
        }
    }
    
    func signInAnonymously() {
        Auth.auth().signInAnonymously { [weak self] result, error in
            if let error = error {
                self?.errorMessage = "Error signing in anonymously: \(error.localizedDescription)"
                return
            }
            
            if let firebaseUser = result?.user {
                let user = User(uid: firebaseUser.uid, email: nil, isAnonymous: firebaseUser.isAnonymous)
                self?.user = user
                self?.isSignedIn = true
                self?.errorMessage = nil
                print("Signed in anonymously with Uid: \(firebaseUser.uid)")
            }
        }
    }
    
    func signInWithEmail(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = "Error signing in : \(error.localizedDescription)"
                return
            }
            
            if let firebaseUser = result?.user {
                let user = User(uid: firebaseUser.uid, email: firebaseUser.email, isAnonymous: firebaseUser.isAnonymous)
                self?.user = user
                self?.isSignedIn = true
                self?.errorMessage = nil
                print("Signed in with email: \(firebaseUser.email ?? "no email")")
            }
        }
    }
}
