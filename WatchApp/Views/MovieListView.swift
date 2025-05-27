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
        ZStack{
            Color.BG
                .ignoresSafeArea(.all)
            
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
                .padding(.vertical)
                
                ContentTypePickerView(selectedType: $viewModel.selectedType) {
                    Task { await viewModel.fetchTrendingContent() }
                }
                .padding(.vertical, 5)
                
                GenrePickerView(genres: Genre.previewGenres, selectedGenre: $viewModel.selectedGenre)
                    .padding(.vertical, 5)
                
                if !viewModel.movies.isEmpty {
                    Text(viewModel.searchText.isEmpty ? "Trending now" : "(viewModel.totalResults) results found")
                        .font(.subheadline)
                        .foregroundColor(.popcornYellow)
                        .padding(.top, 10)
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
                .frame(maxHeight: .infinity)
            }
        }
        //            .background(Color.BG.ignoresSafeArea(.all))
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
}
