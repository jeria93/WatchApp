//
//  SignUpView.swift
//  WatchApp
//
//  Created by Jonas Niyazson on 2025-05-20.
//

import SwiftUI

struct SignUpView: View {
    // Environment & Focus
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    @FocusState private var focusedField: Field?

    // Input Fields
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var username: String = ""

    // Enum for focus
    private enum Field: Hashable {
        case email, password, confirmPassword, username
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.popcornYellow
                    .ignoresSafeArea(.all)

                VStack(spacing: 16) {
                    Text("Create Account")
                        .font(.title)
                        .fontWeight(.semibold)

                    VStack(spacing: 8) {
                        ClearableTextField(
                            title: "Email",
                            text: $email,
                            keyboardType: .emailAddress,
                            validate: validateEmail
                        )
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .password }

                        ClearableTextField(
                            title: "Password",
                            text: $password,
                            isSecure: true,
                            validate: validatePassword
                        )
                        .focused($focusedField, equals: .password)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .confirmPassword }

                        ClearableTextField(
                            title: "Confirm Password",
                            text: $confirmPassword,
                            isSecure: true,
                            validate: validateConfirmPassword
                        )
                        .focused($focusedField, equals: .confirmPassword)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .username }

                        ClearableTextField(
                            title: "Username",
                            text: $username,
                            autocapitalization: .words,
                            validate: validateUsername
                        )
                        .focused($focusedField, equals: .username)
                        .submitLabel(.done)
                        .onSubmit { submitForm() }
                    }

                    if let errorMessage = authVM.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, 4)
                            .transition(.opacity)
                    }

                    Button("JOIN!") {
                        SoundPlayer.play("pop")
                        focusedField = nil
                        submitForm()
                    }
                    .padding(.horizontal, 25)
                    .padding(.vertical, 12)
                    .background(Color.BG)
                    .font(.title3.bold())
                    .foregroundColor(.popcornYellow)
                    .cornerRadius(30)

                    Spacer()
                }
                .padding(.horizontal, 34)
                .padding(.top, 40)
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
    SignUpView().environmentObject(AuthViewModel())
        .presentationDetents([.fraction(0.5)])
        .presentationDragIndicator(.visible)
}

// MARK: - Validation & Form Logic
extension SignUpView {
    func validateEmail(_ input: String) -> String? {
        if input.isEmpty {
            return "Email is required"
        } else if !isValidEmail(input) {
            return "Invalid email format"
        }
        return nil
    }
    func validatePassword(_ input: String) -> String? {
        if input.isEmpty {
            return "Password is required"
        } else if input.count < 6 {
            return "At least 6 characters"
        }
        return nil
    }
    func validateConfirmPassword(_ input: String) -> String? {
        if input != password {
            return "Passwords do not match"
        }
        return nil
    }
    func validateUsername(_ input: String) -> String? {
        return input.isEmpty ? "Username is required" : nil
    }
    func isValidEmail(_ email: String) -> Bool {
        let regex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }
    private func submitForm() {
        guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty, !username.isEmpty else {
            print("One or more fields are empty.")
            return
        }

        authVM.signUpWithEmail(email: email, password: password, username: username) { success in
            if success {
                dismiss()
            }
        }
    }
}
