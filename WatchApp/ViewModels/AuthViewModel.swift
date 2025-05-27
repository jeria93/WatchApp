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
    @Published var successMessage: String?
    
    init() {
        Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            if let firebaseUser = firebaseUser {
                self?.user = User(uid: firebaseUser.uid, email: firebaseUser.email, isAnonymous: firebaseUser.isAnonymous)
                self?.isSignedIn = true
                self?.fetchUsername(for: firebaseUser.uid)
            } else {
                self?.user = nil
                self?.isSignedIn = false
                self?.currentUsername = nil
            }
        }
    }
    
    func signInAnonymously() {
        Auth.auth().signInAnonymously { [weak self] result, error in
            if let error = error {
                self?.errorMessage = "Error signing in anonymously: \(error.localizedDescription)"
                return
            }
            
            if let firebaseUser = result?.user {
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
                self?.errorMessage = nil
                print("Signed in with email: \(firebaseUser.email ?? "no email")")
                
                if UserDefaults.standard.bool(forKey: "rememberMe") {
                    UserDefaults.standard.set(email, forKey: "savedEmail")
                    KeychainService.shared.save(password, forKey: "savedPassword")
                }
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
            
            if !UserDefaults.standard.bool(forKey: "rememberMe"){
                UserDefaults.standard.removeObject(forKey: "savedEmail")
                KeychainService.shared.delete(forKey: "savedPassword")
            }
        } catch {
            self.errorMessage = "Error signing out: \(error.localizedDescription)"
        }
    }

    
    func sendPasswordResetEmail(email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            if let error = error {
                self?.errorMessage = "Error sending reset email: \(error.localizedDescription)"
                self?.successMessage = nil
                return
            }
            
            self?.successMessage = "A password reset link has been sent to \(email)"
            self?.errorMessage = nil
        }
    }
}
