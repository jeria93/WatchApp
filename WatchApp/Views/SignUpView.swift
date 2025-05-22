//
//  SignUpView.swift
//  WatchApp
//
//  Created by Jonas Niyazson on 2025-05-20.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var authVM: AuthViewModel
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var username: String = ""
  
    @State private var emailError: String?
    @State private var passwordError: String?
    @State private var confirmPasswordError: String?
    @State private var usernameError: String?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                
              Text("Create Account")
                  .font(.title)
                  .fontWeight(.semibold)
                
              VStack(spacing: 8) {
                
                ClearableTextField(
                    title: "Email",
                    text: $email,
                    keyboardType: .emailAddress,
                    validate: { input in
                        if input.isEmpty {
                            return "Email krävs"
                        } else if !isValidEmail(input) {
                            return "Ogiltigt e-postformat"
                        }
                        return nil
                    }
                )

                ClearableTextField(
                    title: "Password",
                    text: $password,
                    isSecure: true,
                    validate: { input in
                        if input.isEmpty {
                            return "Lösenord krävs"
                        } else if input.count < 6 {
                            return "Minst 6 tecken"
                        }
                        return nil
                    }
                )

                ClearableTextField(
                    title: "Confirm Password",
                    text: $confirmPassword,
                    isSecure: true,
                    validate: { input in
                        if input != password {
                            return "Lösenorden matchar inte"
                        }
                        return nil
                    }
                )
                
                ClearableTextField(
                    title: "Username",
                    text: $username,
                    autocapitalization: .words,
                    validate: { input in
                        input.isEmpty ? "Användarnamn krävs" : nil
                    }
                )
              }
                
              Button("JOIN!") {
                SoundPlayer.play("pop")
                  emailError = nil
                  passwordError = nil
                  confirmPasswordError = nil
                  usernameError = nil
                  
                  var isValid = true
                  
                  if email.isEmpty {
                      emailError = "Email får inte vara tomt"
                      isValid = false
                  }

                  if password.isEmpty {
                      passwordError = "Lösenord krävs"
                      isValid = false
                  } else if password.count < 6 {
                      passwordError = "Minst 6 tecken"
                      isValid = false
                  }

                  if confirmPassword != password {
                      confirmPasswordError = "Lösenorden matchar inte"
                      isValid = false
                  }

                  if username.isEmpty {
                      usernameError = "Användarnamn krävs"
                      isValid = false
                  }

                  guard isValid else { return }

                  authVM.signUpWithEmail(email: email, password: password, username: username) { success in
                      if success {
                          dismiss()
                      }
                  }
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
            .background(Color.popcornYellow).ignoresSafeArea(.all)
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
  
  func isValidEmail(_ email: String) -> Bool {
      let regex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
      return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
  }
}


#Preview {
    SignUpView(authVM: AuthViewModel())
        .presentationDetents([.fraction(0.5)])
        .presentationDragIndicator(.visible)
}
