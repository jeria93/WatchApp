//
//  GoogleAuthManager.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-03.
//

import Foundation
import FirebaseAuth
import GoogleSignIn

final class GoogleAuthManager {

    static let shared = GoogleAuthManager()

    private init() {}

    func signIn(presenting vc: UIViewController, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {

        /// Kick off Google Sign-In UI.
        GIDSignIn.sharedInstance.signIn(withPresenting: vc) { result, error in

            /// Bubble up any Google-SDK error immediately.
            if let error = error { return completion(.failure(error)) }

            /// Validate we actuallly get the token we needed
            guard
                let user     = result?.user,
                let idToken  = user.idToken?.tokenString
            else { return completion(.failure(SignInError.missingIDToken)) }

            /// Convert tokens to Firebase Credentials
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )

            /// Sign in to Firebase Auth.
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    completion(.failure(error))
                } else if let authResult = authResult {
                    completion(.success(authResult))
                }
            }
        }
    }

    enum SignInError: LocalizedError { case missingIDToken }

}

extension UIApplication {
    var rootViewController: UIViewController? {
        connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow?.rootViewController }
            .first
    }
}
