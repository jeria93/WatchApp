//
//  MovieListView.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-05-19.
//

import SwiftUI

struct MovieListView: View {
    
    @StateObject private var viewModel = MovieViewModel()
    
    var body: some View {
        NavigationStack {
              Group {
                  if viewModel.isLoading {
                      ProgressView("Loading movies...")
                  } else if let error = viewModel.errorMessage {
                      Text(error).foregroundColor(.red)
                  } else {
                      List(viewModel.movies) { movie in
                          VStack(alignment: .leading, spacing: 6) {
                              Text(movie.title).font(.headline)
                              Text(movie.overview).font(.subheadline).lineLimit(2)
                          }
                          .padding(.vertical, 4)
                      }
                  }
              }
              .navigationTitle("Trending Movies")
          }
          .task { await viewModel.fetchTrendingMovies() }
    }
}

#Preview {
    MovieListView()
}
