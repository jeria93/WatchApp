//
//  MovieDetailView.swift
//  WatchApp
//
//  Created by David Kalitzki on 2025-05-26.
//

import SwiftUI

struct MovieDetailView: View {
    
    let movie: Movie
    let contentType: ContentType
    
    let fireStore = FirestoreMovieService()
    
    
    var body: some View {

        VStack(alignment: .leading, spacing: 12) {
            AsyncImage(url: movie.posterURLSmall) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.gray.opacity(0.3))
                    .frame(width: 80, height: 120)
                    .overlay(Text("🍿"))
            }
            
            HStack(alignment: .lastTextBaseline){
                Text(movie.title)
                    .font(.title)
                    .foregroundColor(.white)
                
                Text(contentType == .movie ? "🎬" : "📺")
                if let releaseDate = movie.releaseDate {
                    let displayYear = String(releaseDate.prefix(4))
                    Text("(\(displayYear))")
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
            
            
            HStack{
                Image("pop_white")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .opacity(movie.userRating >= 1 ? 1.0 : 0.2)
                    .onTapGesture {
                        print("1 clicked")
                        setRating(id: movie.id, rating: 1)
                    }
                Image("pop_white")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .opacity(movie.userRating >= 2 ? 1.0 : 0.2)
                    .onTapGesture {
                        print("2 clicked")
                        setRating(id: movie.id, rating: 2)
                    }
                Image("pop_white")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .opacity(movie.userRating >= 3 ? 1.0 : 0.2)
                    .onTapGesture {
                        print("3 clicked")
                        setRating(id: movie.id, rating: 3)
                    }
                Image("pop_white")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .opacity(movie.userRating >= 4 ? 1.0 : 0.2)
                    .onTapGesture {
                        print("4 clicked")
                        setRating(id: movie.id, rating: 4)
                    }
                Image("pop_white")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .opacity(movie.userRating >= 5 ? 1.0 : 0.2)
                    .onTapGesture {
                        print("5 clicked")
                        setRating(id: movie.id, rating: 5)
                    }
            }
            
            Text(movie.overview)
                .font(.subheadline)
                .foregroundColor(.white)
            
        }
        .padding()
        .background(Color.BG.ignoresSafeArea(.all))
    }
    
    private func setRating(id: Int, rating: Int) {
        let id = id
        let rating = rating
        print("\(id), \(rating)")
        
        
        
    }
    
}

#Preview {
    MovieDetailView(movie: .detailPreview, contentType: .movie)
}

extension Movie {
    static var detailPreview: Movie {
        Movie(
            id: 1,
            title: "Interstellar",
            overview: "Set in a dystopian future where Earth is suffering from catastrophic blight and famine, the film follows a group of astronauts who travel through a wormhole near Saturn in search of a new home for mankind.",
            posterPath: "/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg",
            voteAverage: 8.8,
            releaseDate: "2025-05-15",
            contentType: .movie,
            userRating: 3
        )
    }
}
