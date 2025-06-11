//
//  TopRatedMoviesListView.swift
//  WatchApp
//
//  Created by Frida Eriksson on 2025-06-10.
//

import SwiftUI

struct TopRatedMoviesListView: View {
    let movies: [Movie]
    @Binding var selectedMovie: Movie?

    var body: some View {
        ZStack {
            Image("popbox_white")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .opacity(0.8)
                .padding(.top, 10)

            VStack(spacing: 16) {
                Text("Your Top 5")
                    .foregroundStyle(.popcornYellow)
                    .font(.title2)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .padding(.top, 94)

                if movies.isEmpty {
                    Text("No rated movies yet")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .padding(.vertical, 40)
                } else {
                    VStack(spacing: 8){
                        LazyVGrid(columns: [GridItem(.fixed(100)), GridItem(.fixed(100))], spacing: 8) {
                            ForEach(movies.prefix(4), id: \.id) { movie in
                                MovieItemView(movie: movie, selectedMovie: $selectedMovie)
                                    .frame(width: 100, height: 150)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        if movies.count > 4 {
                            MovieItemView(movie: movies[4], selectedMovie: $selectedMovie)
                                .frame(width: 100, height: 150)
                                .padding(.top, 8)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding(.bottom, 5)
        }
    }
}

struct MovieItemView: View {
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
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.popcornYellow, lineWidth: 1))
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.gray.opacity(0.3))
                    .frame(width: 80, height: 100)
                    .overlay(Text("🍿"))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.popcornYellow, lineWidth: 1))
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
//    TopRatedMoviesListView()
//}
