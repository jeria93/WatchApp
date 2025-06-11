//
//  PopularView.swift
//  WatchApp
//
//  Created by David Kalitzki on 2025-06-04.
//

import SwiftUI

struct PopularView: View {
    
    @State private var topFive: [Int: Double] = [:]
    @State private var movies: [Movie] = []
    @State private var selectedMovie: Movie?
    
    let firestore = FirestoreMovieService()
    let tmdbService = TMDBService()
    
    var body: some View {
        ZStack {
            Color.BG
                .ignoresSafeArea(.all)
            
            
            VStack (alignment: .leading) {
                ForEach(movies.sorted(by: {$0.averageRating > $1.averageRating}), id: \.id) { movie in
                    HStack() {
                        
                        VStack(alignment: .center){
                            
                        
                        ZStack{
                            Image("pop_white")
                                .resizable()
                                .frame(width: 75, height: 75)
                            Text((String(format: "%.1f", movie.averageRating)))
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.black)
                        }
                    }
                        VStack {
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
                            }
                        }
                        Text(movie.title)
                            .font(.headline)
                            .foregroundStyle(Color.popcornYellow)
                    }
                    .onTapGesture {
                        selectedMovie = movie
                    }
                }
            }
            .padding(8)
            .onAppear {
                firestore.fetchTopAverage { result in
                    topFive = result
                    
                    for (movieId, rating) in topFive.sorted(by: { $0.value > $1.value }).prefix(5) {
                        
                        Task {
                            do {
                                let movieRaw = try await tmdbService.fetchMovieById(movieId)
                                var movie = Movie(from: movieRaw, userRating: 0)
                                movie.averageRating = rating
                                DispatchQueue.main.async {
                                    self.movies.append(movie)
                                }
                            } catch {
                                print("Error fetching movie: \(error)")
                            }
                        }
                    }
                    movies = []
                }
            }
            .background(Color.BG)
        }
        .sheet(item: $selectedMovie) { movie in
            MovieDetailView(movie: movie, contentType: .movie)
        }
    }
}
    
    //#Preview {
    //    PopularView()
    //}
