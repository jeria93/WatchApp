//
//  GoogleAuthRepository.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-05.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class GoogleAuthRepository {

    private let googleAuthManager = GoogleAuthManager.shared

    /// Signs in the user with Google and ensures a user profile exists in Firestore.
    func signInWithGoogle(from vc: UIViewController) async throws -> UserProfile {
        let authResult = try await performGoogleSignIn(presenting: vc)
        let firebaseUser = authResult.user

        if let existingProfile = try await fetchExistingUserProfile(for: firebaseUser) {
            return existingProfile
        } else {
            let newProfile = try await createNewUserProfile(for: firebaseUser)
            return newProfile
        }
    }

    /// Performs the Google Sign-In flow
    private func performGoogleSignIn(presenting vc: UIViewController) async throws -> AuthDataResult {
        return try await withCheckedThrowingContinuation { continuation in
            googleAuthManager.signIn(presenting: vc) { result in
                switch result {
                case .success(let authResult):
                    continuation.resume(returning: authResult)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Checks Firestore for an existing user profile for the given Firebase user.
    /// If no profile is found, returns `nil`.
    private func fetchExistingUserProfile(for user: FirebaseAuth.User) async throws -> UserProfile? {
        let userRef = Firestore.firestore().collection("users").document(user.uid)
        let snapshot = try await userRef.getDocument()

        guard snapshot.exists, let data = snapshot.data() else { return nil }

        var userProfile = try Firestore.Decoder().decode(UserProfile.self, from: data)

        if userProfile.photoURL == nil || userProfile.photoURL?.isEmpty == true {
            userProfile.photoURL = user.photoURL?.absoluteString
            try? await userRef.updateData(["photoURL": user.photoURL?.absoluteString ?? ""])
        }

        return userProfile
    }

    /// Creates a new user profile in Firestore for the given Firebase user.
    private func createNewUserProfile(for user: FirebaseAuth.User) async throws -> UserProfile {
        let username = user.displayName ?? user.email ?? "New User"
        let userProfile = UserProfile(
            uid: user.uid,
            email: user.email ?? "",
            username: username,
            displayName: user.displayName,
            photoURL: user.photoURL?.absoluteString
        )

        let userRef = Firestore.firestore().collection("users").document(user.uid)
        try userRef.setData(from: userProfile)
        print("New Google user created in Firestore: \(username)")
        return userProfile
    }
}
