//
//  ShareButtonView.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-02.
//

import SwiftUI

struct ShareButtonView: View {
    let movie: Movie
    @State private var shareItem: MovieShareItem?

    var body: some View {
        if let shareItem {
            ShareLink(item: shareItem.url, preview: SharePreview(shareItem.title, image: Image(uiImage: shareItem.image))) {
                Label("Share", systemImage: "square.and.arrow.up")
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        } else {
            ProgressView()
                .onAppear {
                    Task {
                        shareItem = await ShareHelper.createShareItem(for: movie)
                    }
                }
        }
    }
}
#Preview {
    ShareButtonView(movie: .preview).padding()
}
