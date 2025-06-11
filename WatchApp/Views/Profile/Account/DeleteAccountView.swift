//
//  DeleteAccountView.swift
//  WatchApp
//
//  Created by Frida Eriksson on 2025-06-10.
//

import SwiftUI

struct DeleteAccountView: View {
@EnvironmentObject var authVM: AuthViewModel
@Binding var showModal: Bool
@State private var email: String = ""
@State private var password: String = ""
@State private var showReauthentication: Bool = false

var body: some View {
    VStack(spacing: 20) {
        Text("Delete Account")
            .font(.title2)
            .foregroundStyle(.popcornYellow)
            .fontWeight(.bold)

        if showReauthentication {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .textContentType(.emailAddress)
                .autocapitalization(.none)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .textContentType(.password)
        } else {
            Text("Are you sure you want to delete your account? This action cannot be undone.")
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding()
        }

        if let successMessage = authVM.successMessage {
            Text(successMessage)
                .foregroundStyle(.green)
                .padding()
        }

        if let errorMessage = authVM.errorMessage {
            Text(errorMessage)
                .foregroundStyle(.red)
                .padding()
        }

        HStack {
            Button("Cancel") {
                withAnimation { showModal = false }
            }
            .padding(.horizontal)
            .background(.BG)
            .foregroundStyle(.popcornYellow)
            .cornerRadius(20)
            .fontWeight(.semibold)

            Button("Delete") {
                if showReauthentication {
                    authVM.deleteAccount(email: email, password: password) { success in
                        if success { withAnimation { showModal = false } }
                    }
                } else {
                    authVM.deleteAccount { success in
                        if !success, authVM.errorMessage?.contains("recent login") ?? false {
                            showReauthentication = true
                        } else if success {
                            withAnimation { showModal = false }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .foregroundStyle(.red)
            .fontWeight(.bold)
        }
    }
    .frame(height: 300)
    .background(.black)
    .cornerRadius(20)
    .shadow(radius: 10)
    .padding()
    }
}

//#Preview {
//    DeleteAccountView()
//}
