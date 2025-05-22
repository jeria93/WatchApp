//
//  LoadingView.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-05-20.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView("Loading movies...")
            Spacer()
        }
        .frame(maxHeight: .infinity)
    }
}

#Preview {
    LoadingView()
}
