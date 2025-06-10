//
//  ResetPasswordInfoText.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-10.
//

import SwiftUI

struct ResetPasswordInfoText: View {
    var body: some View {
        Text("""
        A reset link will be sent to your email address.
        Follow instructions to reset your password,
        then try login again.
        Remember password needs to contain at least 6 characters.
        """)
        .fontDesign(.rounded)
        .multilineTextAlignment(.center)
        .fontWeight(.semibold)
    }
}

#Preview {
    ResetPasswordInfoText()
}
