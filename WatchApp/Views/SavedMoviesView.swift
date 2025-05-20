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
                    
                    Text(error)
                        .foregroundColor(.red)
                    
                } else if viewModel.movies.isEmpty {
                    
                    Text("No saved movies yet")
                        .foregroundColor(.gray)
                } else {
                    List(viewModel.movies) { movie in
                        MovieRow(movie: movie)
                    }
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
