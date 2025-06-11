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
                    .padding(5)
                    .fontWeight(.bold)
                    .foregroundStyle(.accent)
                    .background(Color.popcornYellow.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 7))
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
