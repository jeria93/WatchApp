//
//  ShareButtonView.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-02.
//

import SwiftUI

struct ShareButtonView: View {
    let movie: Movie

    var body: some View {
        ShareLink(
            item: "Check out \(movie.title) on TMDB: https://www.themoviedb.org/movie/\(movie.id)") {
            Label("Share", systemImage: "square.and.arrow.up")
                .padding()
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}
#Preview {
    ShareButtonView(movie: .preview)
}
