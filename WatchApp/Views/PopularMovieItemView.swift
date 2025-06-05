//
//  PopularMovieItemView.swift
//  WatchApp
//
//  Created by David Kalitzki on 2025-06-05.
//

import SwiftUI

struct PopularMovieItemView: View {
    let movie: Movie
    @Binding var selectedMovie: Movie?
    
    var body: some View {
            VStack(spacing: 4) {
                AsyncImage(url: movie.posterURLSmall) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.popcornYellow, lineWidth: 1))
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.gray.opacity(0.3))
                        .frame(width: 80, height: 100)
                        .overlay(Text("🍿"))
                        .overlay(RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.popcornYellow, lineWidth: 1))
                }
                
                Text(movie.title)
                    .font(.caption)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .frame(maxWidth: 90)
                Text("\(movie.userRating)/5")
                    .font(.caption2)
                    .foregroundStyle(.popcornYellow)
            }
            
            .onTapGesture {
                selectedMovie = movie
            }
        }
}

//#Preview {
//    PopularMovieItemView()
//}
