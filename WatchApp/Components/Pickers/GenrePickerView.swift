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
    @State private var animateIn = false
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        selectedGenre = nil
                    }
                } label: {
                    Text("All")
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(selectedGenre == nil ? Color.red : Color.gray.opacity(0.3))
                        .clipShape(Capsule())
                        .foregroundStyle(.white)
                        .fontWeight(.semibold)
                        .scaleEffect(selectedGenre == nil ? 1.1 : 1.0)
                }
                ForEach(genres) { genre in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            selectedGenre = genre
                        }
                    } label: {
                        Text(genre.name)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 8)
                            .background(selectedGenre == genre ? Color.red : Color.gray.opacity(0.3))
                            .clipShape(Capsule())
                            .foregroundStyle(.white)
                            .fontWeight(.semibold)
                            .scaleEffect(selectedGenre == genre ? 1.1 : 1.0)
                    }
                }
            }
            .padding(.horizontal)
            .opacity(animateIn ? 1 : 0)
            .animation(.easeIn(duration: 0.6), value: animateIn)
            .onAppear { animateIn = true }
        }
    }
}

#Preview {
    GenrePickerView(
        genres: Genre.previewGenres,
        selectedGenre: .constant(nil)
    )
}
