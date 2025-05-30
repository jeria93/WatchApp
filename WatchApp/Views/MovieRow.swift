//
//  MovieRow.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-05-19.
//

import SwiftUI

struct MovieRow: View {

    @State var movie: Movie
    var onSave: (() -> Void)?
    let contentType: ContentType
    @EnvironmentObject var authVM: AuthViewModel
    
    let firestore = FirestoreMovieService()
    
    @State private var showDetails = false
    @State private var isSaved = false

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

                Text(movie.title)
                    .font(.headline)
                    .foregroundColor(.black)

                HStack{
                    Text(contentType == .movie ? "🎬" : "📺")
                        .font(.caption)
                        .foregroundColor(.blue)

                    if let releaseDate = movie.releaseDate {
                        let displayYear = String(releaseDate.prefix(4))
                        Text(displayYear)
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    if let onSave = onSave {
                        Button {
                            Task {
                                guard let userId = authVM.user?.uid else { return }
                            do {
                                    onSave()
                                    try await firestore.saveMovie(movie, userId: userId)
                                    isSaved = true
                            }catch {
                                print("Error updating movie save status: \(error)")
                            }
                        }
                        } label: {
                            Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                                    .resizable()
                                    .frame(width: 10, height: 15)
                                    .foregroundColor(.white)
                        }
                        .buttonStyle(.plain)
                    }
                    
                }

                    Text(movie.overview.isEmpty ? "No description available" : movie.overview)
                        .font(.caption)
                        .lineLimit(3)
                        .foregroundColor(.white)
                    
                    HStack{
                        Image("pop_white")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .opacity(movie.userRating >= 1 ? 1.0 : 0.2)
                        Image("pop_white")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .opacity(movie.userRating >= 2 ? 1.0 : 0.2)
                        Image("pop_white")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .opacity(movie.userRating >= 3 ? 1.0 : 0.2)
                        Image("pop_white")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .opacity(movie.userRating >= 4 ? 1.0 : 0.2)
                        Image("pop_white")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .opacity(movie.userRating >= 5 ? 1.0 : 0.2)
                    }
                        
                    }
                    
                }
        .frame(height: 120)
        .padding()
        .background(Color.popcornYellow.opacity(0.8).ignoresSafeArea(.all))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 1)
        .onAppear{
            Task{
                guard let userId = authVM.user?.uid else { return }
                do {
                    isSaved = try await firestore.isMovieSaved(id: movie.id, userId: userId)
                } catch {
                    print("Error checking saved status: \(error)")
                }
            }
                firestore.fetchUserRating(id: movie.id) { rating in
                    if let rating = rating {
                        movie.userRating = rating
                    } else {
                        print("not rated yet")
                    }
            }
        }
        .onTapGesture {
            showDetails = true
        }
        .sheet(isPresented: $showDetails){
            MovieDetailView(movie: movie, contentType: contentType)
        }
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
            genreIds: [28, 12, 878],
            contentType: .movie
        )
    }
}
