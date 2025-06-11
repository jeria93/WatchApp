//
//  EditUsernameView.swift
//  WatchApp
//
//  Created by Frida Eriksson on 2025-06-10.
//

import SwiftUI

struct EditUsernameView: View {
    @Binding var username: String?
    @EnvironmentObject var authVM: AuthViewModel
    @Binding var showModal: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("Edit Username")
                .font(.title2)
                .foregroundStyle(.popcornYellow)
                .fontWeight(.bold)

            Divider()

            TextField("Username", text: Binding(get: { username ?? "" },
                                                set: { username = $0.isEmpty ? nil : $0 }))
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            .foregroundStyle(.black)

            HStack {
                Button("Cancel") {
                    withAnimation { showModal = false }
                }
                Button("Save") {
                    authVM.updateUsername(newUsername: username ?? "") { success in
                        if success { withAnimation { showModal = false } }
                    }
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
//    EditUsernameView()
//}
