//
//  EditEmailView.swift
//  WatchApp
//
//  Created by Frida Eriksson on 2025-06-10.
//

import SwiftUI

struct EditEmailView: View {
    @State var newEmail: String
    @EnvironmentObject var authVM: AuthViewModel
    @Binding var showModal: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("Edit Email")
                .font(.title2)
                .foregroundStyle(.popcornYellow)
                .fontWeight(.bold)

            TextField("Email", text: $newEmail)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .textContentType(.emailAddress)
                .autocapitalization(.none)

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
                Button("Save") {
                    authVM.updateEmail(newEmail: newEmail) { _ in }
                }
                .padding(.horizontal)
                .background(.BG)
                .foregroundStyle(.popcornYellow)
                .cornerRadius(20)
                .fontWeight(.semibold)
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
//    EditEmailView()
//}
