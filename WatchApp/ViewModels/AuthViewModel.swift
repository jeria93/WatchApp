//
//  AuthViewModel.swift
//  WatchApp
//
//  Created by Frida Eriksson on 2025-05-19.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import GoogleSignInSwift
import FirebaseCore

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isSignedIn: Bool = false
    @Published var isAnonymous: Bool = false

    @Published var currentUsername: String?
    @Published var displayName: String?
    @Published var photoURL: String?

    @Published var errorMessage: String?
    @Published var successMessage: String?

    // Google
    @Published var isGoogleUser: Bool = false
    private let googleAuth = GoogleAuthManager.shared

    private var previousEmail: String?
    var currentUserId: String? { Auth.auth().currentUser?.uid }

    init() {
        Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            guard let self = self else { return }

            if let firebaseUser = firebaseUser {
                let newEmail = firebaseUser.email

                if self.isSignedIn, let previousEmail = self.previousEmail, let newEmail = newEmail, previousEmail != newEmail {
                    self.updateEmailInFirestore(uid: firebaseUser.uid, newEmail: newEmail) { success in
                        if success {
                            self.signOut()
                            self.successMessage = "Email updated. Please log in again with your new email."
                        }
                    }
                    return
                }

                self.user = User(uid: firebaseUser.uid, email: firebaseUser.email, isAnonymous: firebaseUser.isAnonymous)
                self.previousEmail = newEmail
                self.isSignedIn = true
                self.fetchUsername(for: firebaseUser.uid)
                self.displayName = firebaseUser.displayName
                self.photoURL = firebaseUser.photoURL?.absoluteString
                self.fetchUserProfile()
                self.isGoogleUser = false
            } else {
                self.user = nil
                self.isSignedIn = false
                self.currentUsername = nil
                self.previousEmail = nil
                self.displayName = nil
                self.photoURL = nil
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
                print("inloggad anonymt")
                self?.isAnonymous = true
                print(self?.isAnonymous ?? false)
            }
        }
    }

    func signInWithEmail(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = "Error signing in: \(error.localizedDescription)"
                return
            }

            if let firebaseUser = result?.user {
                self?.errorMessage = nil
                self?.photoURL = nil
                self?.deleteAllDocumentsData()

                if let newEmail = firebaseUser.email {
                    self?.updateEmailInFirestore(uid: firebaseUser.uid, newEmail: newEmail) { success in
                        if success {
                            print("Email synced with Firestore after signing in")
                        } else {
                            print("Failed to sync email after signed in")
                        }
                    }

                    // Remove profile photoURL from Firestore (avoid overwriting with local)
                    let docRef = Firestore.firestore().collection("users").document(firebaseUser.uid)
                    docRef.updateData(["photoURL": FieldValue.delete()]) { error in
                        if let error = error {
                            print("Failed to remove photoURL for email user: \(error.localizedDescription)")
                        } else {
                            print("Removed photoURL for email user in Firestore.")
                        }
                    }
                }
                if UserDefaults.standard.bool(forKey: "rememberMe") {
                    UserDefaults.standard.set(email, forKey: "savedEmail")
                    KeychainService.shared.save(password, forKey: "savedPassword")
                }

                self?.isAnonymous = false
            }
        }
    }

    func signUpWithEmail(email: String, password: String, username: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error as NSError? {
                if error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                    self?.errorMessage = "An account with this email already exists."
                } else {
                    self?.errorMessage = "Error creating account: \(error.localizedDescription)"
                }
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
                print("Error fetching username: \(error.localizedDescription)")
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

    func updateUsername(newUsername: String, completion: @escaping (Bool) -> Void) {
        guard let uid = user?.uid else {
            errorMessage = "No user signed in"
            completion(false)
            return
        }

        let docRef = Firestore.firestore().collection("users").document(uid)

        docRef.updateData(["username": newUsername]){  error in
            if let error = error {
                self.errorMessage = "Failed to update username: \(error.localizedDescription)"
                completion(false)
                return
            }

            self.currentUsername = newUsername
            completion(true)
        }
    }

    func updateEmail(newEmail: String, completion: @escaping (Bool) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            errorMessage = "No user signed in"
            completion(false)
            return
        }

        currentUser.sendEmailVerification(beforeUpdatingEmail: newEmail){  error in
            if let error = error as NSError? {
                if error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                    self.errorMessage = "Email already in use"
                } else {
                    self.errorMessage = "Failed to send emailverification: \(error.localizedDescription)"
                }
                completion(false)
                return
            }

            self.successMessage = "Verification email sent to \(newEmail). Go to your mail and verify on the link to update your email. You will be automatically signed out in 10 seconds."
            self.signOutAfterDelay(seconds: 10)
            completion(true)
        }
    }

    private func updateEmailInFirestore(uid: String, newEmail: String, completion: @escaping (Bool) -> Void) {
        let docRef = Firestore.firestore().collection("users").document(uid)

        docRef.updateData(["email": newEmail]){  error in
            if let error = error {
                self.errorMessage = "Failed to update email in database: \(error.localizedDescription)"
                completion(false)
            } else {
                print("Email updated in Firestore successfully: \(newEmail)")
                completion(true)
            }
        }
    }

    func signOutAfterDelay(seconds: Double = 10.0) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.signOut()
        }
    }

    //function to delete account with reauthentication is user stayed logged in for a while
    func deleteAccount(email: String? = nil, password: String? = nil, completion: @escaping (Bool) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            self.errorMessage = "No user signed in"
            completion(false)
            return
        }

        let uid = currentUser.uid
        let userDocRef = Firestore.firestore().collection("users").document(uid)

        if let email = email, let password = password {
            let credential = EmailAuthProvider.credential(withEmail: email, password: password)
            currentUser.reauthenticate(with: credential) { [weak self] _, error in
                if let error = error {
                    self?.errorMessage = "Failed to reauthenticate: \(error.localizedDescription)"
                    print("Reauthentication failed: \(error.localizedDescription)")
                    completion(false)
                    return
                }

                self?.accountDeletedSuccessfully(userDocRef: userDocRef, currentUser: currentUser, completion: completion)
            }
        } else {
            accountDeletedSuccessfully(userDocRef: userDocRef, currentUser: currentUser, completion: completion)
        }
    }

    //Functions to make sure all user data deletes, both the user and their saved and rated movie collections
    private func accountDeletedSuccessfully(userDocRef: DocumentReference, currentUser: FirebaseAuth.User, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let batch = db.batch()

        func deleteCollection(_ collectionRef: CollectionReference, completion: @escaping (Error?) -> Void) {
            collectionRef.getDocuments { (snapshot, error) in
                if let error = error {
                    completion(error)
                    return
                }

                guard let documents = snapshot?.documents else {
                    completion(nil)
                    return
                }
                for document in documents {
                    batch.deleteDocument(document.reference)
                }
                completion(nil)
            }
        }

        //Collects all the documents for user to delete all
        batch.deleteDocument(userDocRef)

        let collectionsToDelete = [
            userDocRef.collection("savedMovies"),
            userDocRef.collection("ratedMovies")
        ]

        let group = DispatchGroup()
        var deletionError: Error?

        //Delete these subcollections
        for collectionRef in collectionsToDelete {
            group.enter()
            deleteCollection(collectionRef) { error in
                if let error = error {
                    deletionError = error
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if let error = deletionError {
                self.errorMessage = "Failed to delete user data: \(error.localizedDescription)"
                completion(false)
                return
            }

            batch.commit { [weak self] error in
                if let error = error {
                    self?.errorMessage = "Failed to delete all user data: \(error.localizedDescription)"
                    completion(false)
                    return
                }

                //Delete user from Firebase authentication
                currentUser.delete { [weak self] error in
                    if let error = error as NSError? {
                        if error.code == AuthErrorCode.requiresRecentLogin.rawValue {
                            self?.errorMessage = "To delete account a recent login is needed. Please login again to delete your account."
                            completion(false)
                            return
                        }
                        self?.errorMessage = "Failed to delete user: \(error.localizedDescription)"
                        completion(false)
                        return
                    }

                    self?.user = nil
                    self?.isSignedIn = false
                    self?.currentUsername = nil
                    self?.previousEmail = nil
                    self?.errorMessage = nil
                    completion(true)
                }
            }
        }
    }

    /// Initiates the Google-Sign-In flow and updates the local error state.
    func signInWithGoogle(from vc: UIViewController) {
        let googleRepo = GoogleAuthRepository()
        Task {
            do {
                let userProfile = try await googleRepo.signInWithGoogle(from: vc)

                self.deleteAllDocumentsData()
                self.currentUsername = userProfile.username
                self.displayName = userProfile.displayName
                self.photoURL = userProfile.photoURL
                self.isSignedIn = true
                self.user = User(uid: userProfile.uid, email: userProfile.email, isAnonymous: false)
                self.isGoogleUser = true

                print("Google Sign-in successful for: \(userProfile.username)")
            } catch {
                self.errorMessage = error.localizedDescription
                print("Google Sign-in error: \(error.localizedDescription)")
            }
        }
    }

    /// Fetches the current user's profile from Firestore and updates local properties.
    func fetchUserProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let userRef = Firestore.firestore().collection("users").document(uid)
        userRef.getDocument { snapshot, error in
            if let error = error {
                print("Error fetching user profile: \(error.localizedDescription)")
                return
            }

            if let data = snapshot?.data() {
                do {
                    let userProfile = try Firestore.Decoder().decode(UserProfile.self, from: data)
                    self.displayName = userProfile.displayName
                    self.photoURL = userProfile.photoURL
                    self.currentUsername = userProfile.username
                    print("User profile fetched: \(userProfile.username)")
                } catch {
                    print("Error decoding user profile: \(error.localizedDescription)")
                }
            } else {
                print("No user profile data found.")
            }
        }
    }

    /// Deletes all files in the user's Documents directory.
    private func deleteAllDocumentsData() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil, options: [])
            for fileURL in fileURLs {
                try FileManager.default.removeItem(at: fileURL)
                print("Deleted file: \(fileURL.lastPathComponent)")
            }
            print("Deleted all files in Documents directory!")
        } catch {
            print("Error deleting documents: \(error)")
        }
    }

    /// Removes the `photoURL` field from the Firestore user document for the specified user ID.
    /// Typically used when an email/password user logs in to ensure that any local profile image does not overwrite their profile.
    private func removePhotoURLFromFirestore(for uid: String) {
        let docRef = Firestore.firestore().collection("users").document(uid)
        docRef.updateData(["photoURL": FieldValue.delete()]) { error in
            if let error = error {
                print("Failed to remove photoURL for email user: \(error.localizedDescription)")
            } else {
                print("Removed photoURL for email user in Firestore.")
            }
        }
    }
}
