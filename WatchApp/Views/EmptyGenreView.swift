//
//  EmptyGenreView.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-05-28.
//

import SwiftUI

struct EmptyGenreView: View {
    var body: some View {
        VStack {
            Image(systemName: "eye.slash")
                .font(.system(size: 50))
                .foregroundColor(.gray)
                .padding(.bottom)
            
            Text("No movies found for selected genre.")
                .foregroundColor(.gray)
                .font(.headline)
        }
        .frame(maxHeight: .infinity)
    }
}

#Preview {
    EmptyGenreView()
}
