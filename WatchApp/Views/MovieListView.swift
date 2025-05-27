//
//  MovieListView.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-05-19.
//

import SwiftUI

struct MovieListView: View {
    
    @StateObject private var viewModel = MovieViewModel()
    @StateObject private var firestoreVM = FirestoreViewModel()
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        VStack(spacing: 0) {
                SearchBarView(text: $viewModel.searchText) {
                    Task {
                        if viewModel.searchText.trimmingCharacters(in: .whitespaces).isEmpty {
                            await viewModel.fetchTrendingContent()
                        } else {
                            await viewModel.searchContent()
                        }
                    }
                }

                ContentTypePickerView(selectedType: $viewModel.selectedType) {
                        .font(.subheadline)
                        .foregroundColor(.popcornYellow)

                GenrePickerView(genres: Genre.previewGenres, selectedGenre: $viewModel.selectedGenre)
                    .padding(.vertical, 5)

                }
                
                Group {
                    if viewModel.isLoading {
                        LoadingView()
                    } else if let error = viewModel.errorMessage {
                        ErrorView(message: error)
                    } else if viewModel.movies.isEmpty {
                        EmptyStateView(searchText: viewModel.searchText)
                            .frame(maxHeight: .infinity)
                    } else {
                        ContentListView(movies: viewModel.filteredMovies, contentType: viewModel.selectedType) { movie in
                            Task { await firestoreVM.saveMovie(movie) }
                        }
                    }
                    
                }
                
            }
            .background(Color.BG.ignoresSafeArea(.all))
            .task { await viewModel.fetchTrendingContent() }
        
    }
}


#Preview {
    MovieListView()
        .environmentObject(AuthViewModel())
}

#Preview("Default Empty") {
    EmptyStateView(searchText: "")
}

#Preview("No results found for 'Batman'") {
    EmptyStateView(searchText: "Star Wars")
