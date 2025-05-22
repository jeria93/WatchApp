//
//  MovieRow.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-05-19.
//

import SwiftUI

struct MovieRow: View {
    
    let movie: Movie
    var onSave: (() -> Void)?
    let contentType: ContentType
    
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
            
            VStack(alignment: .leading, spacing: 5) {
                
                Text(contentType == .movie ? "🎬 Movie" : "📺 TV Show")
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Text(movie.title)
                    .font(.headline)
                
                if let releaseDate = movie.releaseDate {
                    Text("Released: \(releaseDate)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(movie.overview.isEmpty ? "No description available" : movie.overview)
                    .font(.subheadline)
                    .lineLimit(3)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let onSave = onSave {
                    Button {
                        onSave()
                    } label: {
                        Label("Save", systemImage: "plus")
                    }
                    .buttonStyle(.borderedProminent)
                    .font(.caption)
                    
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 160)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 1)
    }
}

#Preview("Movie Preview") {
    MovieRow(movie: .preview, contentType: .movie)
}

extension Movie {
    static var preview: Movie {
        Movie(
            id: 1,
            title: "Interstellar",
            overview: "Set in a dystopian future where Earth is suffering from catastrophic blight and famine, the film follows a group of astronauts who travel through a wormhole near Saturn in search of a new home for mankind.",
            posterPath: "/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg",
            voteAverage: 8.8,
            releaseDate: "2025-05-15",
            contentType: .movie
        )
    }
}
