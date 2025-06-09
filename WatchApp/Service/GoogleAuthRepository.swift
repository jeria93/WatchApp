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

    func signInWithGoogle(from vc: UIViewController) async throws -> UserProfile {
        let authResult = try await withCheckedThrowingContinuation { continuation in

            googleAuthManager.signIn(presenting: vc) { result in

                switch result {

                case .success(let authResult):
                    continuation.resume(returning: authResult)

                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }

        let firebaseUser = authResult.user
        let userRef = Firestore.firestore().collection("users").document(firebaseUser.uid)

        let snapshot = try await userRef.getDocument()
        if snapshot.exists {
            let data = snapshot.data()!
            let userProfile = try Firestore.Decoder().decode(UserProfile.self, from: data)
            return userProfile
        }

        let username = firebaseUser.displayName ?? firebaseUser.email ?? "New User"
        let userProfile = UserProfile(
            uid: firebaseUser.uid,
            email: firebaseUser.email ?? "",
            username: username,
            displayName: firebaseUser.displayName,
            photoURL: firebaseUser.photoURL?.absoluteString
        )

        try userRef.setData(from: userProfile)
        print("New Google user created in Firestore: \(username)")
        return userProfile
    }
}
