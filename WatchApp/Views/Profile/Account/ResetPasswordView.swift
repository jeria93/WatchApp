//
//  ResetPasswordView.swift
//  WatchApp
//
//  Created by Frida Eriksson on 2025-05-26.
//

import SwiftUI

struct ResetPasswordView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var emailError: String?
    @State private var email: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.popcornYellow
                    .ignoresSafeArea(.all)

                VStack() {
                    Text("Reset Password")
                        .font(.title)
                        .fontWeight(.semibold)

                    VStack(alignment: .leading, spacing: 8) {
                        ClearableTextField(
                            title: "Enter your Email",
                            text: $email,
                            keyboardType: .emailAddress
                        )
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .onChange(of: email) { newValue in
                            emailError = newValue.emailValidationError
                        }

                        if let successMessage = authVM.successMessage {
                            Text(successMessage)
                                .foregroundStyle(.green)
                                .font(.caption)
                                .padding(.horizontal)
                        }

                        if let emailError = emailError {
                            Text(emailError)
                                .foregroundStyle(.red)
                                .font(.caption)
                                .padding(.horizontal)
                        }
                    }

                    ResetPasswordInfoText()

                    Button(action: {
                        emailError = email.emailValidationError
                        if emailError == nil {
                            authVM.sendPasswordResetEmail(email: email)
                        }
                    }) {
                        Text("Send Reset Link")
                            .padding(.horizontal, 25)
                            .padding(.vertical, 10)
                            .foregroundStyle(.popcornYellow)
                            .font(.headline)
                            .background(Color.black.opacity(0.9))
                            .cornerRadius(40)
                    }
                    .padding(.top)

                }
                .padding()
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            SoundPlayer.play("pop-1")
                            dismiss()
                        }
                    }

                }
            }
        }
    }
}

#Preview {
    ResetPasswordView().environmentObject(AuthViewModel())
}

extension String {
    func isValidEmail() -> Bool {
        let regex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
    var emailValidationError: String? {
        if self.isEmpty {
            return "Email is required"
        } else if !self.isValidEmail() {
            return "Invalid email format"
        }
        return nil
    }
}
