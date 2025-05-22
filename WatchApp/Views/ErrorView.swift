//
//  ErrorView.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-05-20.
//

import SwiftUI

struct ErrorView: View {
    
    let message: String
    var body: some View {
        VStack {
            Text(message)
                .foregroundColor(.red)
            Spacer()
        }
        .padding()
        .frame(maxHeight: .infinity)
    }
}

#Preview {
    ErrorView(message: "Preview Error")
}
