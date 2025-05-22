//
//  AuthViewModel.swift
//  WatchApp
//
//  Created by Frida Eriksson on 2025-05-19.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isSignedIn: Bool = false
    @Published var errorMessage: String?
    @Published var currentUsername: String?
    
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
                self?.fetchUsername(for: firebaseUser.uid)
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
                self?.fetchUsername(for: firebaseUser.uid)
                self?.errorMessage = nil
                print("Signed in with email: \(firebaseUser.email ?? "no email")")
            }
        }
    }

    func signUpWithEmail(email: String, password: String, username: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = "Error creating account: \(error.localizedDescription)"
                completion(false)
                return
            }

            guard let firebaseUser = result?.user else {
                self?.errorMessage = "User creation failed"
                completion(false)
                return
            }

            let user = User(uid: firebaseUser.uid, email: firebaseUser.email, isAnonymous: firebaseUser.isAnonymous)
            self?.user = user
            self?.isSignedIn = true
            self?.errorMessage = nil

            let userProfile = UserProfile(uid: firebaseUser.uid, email: firebaseUser.email ?? "", username: username)
            
            do {
                try Firestore.firestore()
                    .collection("users")
                    .document(firebaseUser.uid)
                    .setData(from: userProfile) { error in
                        if let error = error {
                            print("Failed to save user to Firestore: \(error.localizedDescription)")
                        } else {
                            print("User saved to Firestore with username: \(username)")
                        }
                    }
            } catch {
                print("Encoding error: \(error.localizedDescription)")
            }

            completion(true)
        }
    }

    func fetchUsername(for uid: String) {
        let docRef = Firestore.firestore().collection("users").document(uid)
        
        docRef.getDocument { snapshot, error in
            if let error = error {
                print("Failed to fetch username: \(error.localizedDescription)")
                return
            }
            
            if let data = snapshot?.data(),
               let username = data["username"] as? String {
                self.currentUsername = username
                print("Username loaded: \(username)")
            }
        }
    }
  
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.isSignedIn = false
            self.currentUsername = nil
        } catch {
            self.errorMessage = "Error signing out: \(error.localizedDescription)"
        }
    }

}
