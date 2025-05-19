//
//  MovieRow.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-05-19.
//

import SwiftUI

struct MovieRow: View {
    let movie: Movie
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 12) {
            
            AsyncImage(url: movie.posterURLSmall) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.gray.opacity(0.3))
                    .frame(width: 80, height: 120)
                    .overlay(Text("🍿"))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(movie.title)
                    .font(.headline)
                
                if let releaseDate = movie.releaseDate {
                    Text("Released: \(releaseDate)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                let overview = movie.overview.trimmingCharacters(in: .whitespacesAndNewlines)
                Text(overview.isEmpty ? "No description available." : overview)
                    .font(.subheadline)
                    .lineLimit(3)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(minHeight: 120, alignment: .topLeading)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

#Preview {
    MovieRow(movie: .preview)
}

extension Movie {
    static var preview: Movie {
        Movie(
            id: 157336,
            title: "Interstellar",
            overview: "Set in a dystopian future where Earth is suffering from catastrophic blight and famine, the film follows a group of astronauts who travel through a wormhole near Saturn in search of a new home for mankind.",
            posterPath: "/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg",
            voteAverage: 8.8,
            releaseDate: "2025-05-15"
        )
    }
}
