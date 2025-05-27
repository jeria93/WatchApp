//
//  ResetPasswordView.swift
//  WatchApp
//
//  Created by Frida Eriksson on 2025-05-26.
//

import SwiftUI

struct ResetPasswordView: View {
    @ObservedObject var authVM: AuthViewModel
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
                            emailError = validateEmail(newValue)
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
                    
                    VStack{
                        Text("A reset link will be sent to your email address.\nFollow instructions to reset your password, \nthen try login again. \nRemember password needs to contain atleast 6 characters.")
                    }
                    .fontDesign(.rounded)
                    .multilineTextAlignment(.center)
                    .fontWeight(.semibold)
                    
                    Button(action: {
                        emailError = validateEmail(email)
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
    
        private func validateEmail(_ email: String) -> String? {
            if email.isEmpty {
                return "Email is required"
            } else if !isValidEmail(email) {
                return "Invalid email format"
            }
            return nil
        }
        
   private func isValidEmail(_ email: String) -> Bool {
        let regex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }
}

#Preview {
    ResetPasswordView(authVM: AuthViewModel())
}

