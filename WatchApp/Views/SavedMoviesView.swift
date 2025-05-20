//
//  SavedMoviesView.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-05-20.
//

import SwiftUI

struct SavedMoviesView: View {
    
    @StateObject private var viewModel = FirestoreViewModel()
    
    var body: some View {
        
        NavigationStack {
            Group {
                if let error = viewModel.errorMessage {
                    ErrorView(message: error)
                } else if viewModel.movies.isEmpty {
                    EmptyStateView(searchText: "")
                } else {
                    ContentListView(movies: viewModel.movies, contentType: .movie)
                }
            }
            .navigationTitle("Saved Movies")
            .task { await viewModel.fetchMovies() }
        }
    }
}

#Preview {
    SavedMoviesView()
}
