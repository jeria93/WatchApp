//
//  GenrePickerView.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-05-26.
//

import SwiftUI

struct GenrePickerView: View {
    let genres: [Genre]
    @Binding var selectedGenre: Genre?
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(genres) { genre in
                    Button {
                        selectedGenre = genre
                    } label: {
                        Text(genre.name)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 8)
                            .background(selectedGenre == genre ? Color.red : Color.gray.opacity(0.3))
                            .clipShape(Capsule())
                            .foregroundStyle(.white)
                            .fontWeight(.semibold)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    GenrePickerView(
        genres: Genre.previewGenres,
        selectedGenre: .constant(Genre.previewGenres.first)
    )
}
