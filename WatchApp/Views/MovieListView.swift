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
    @ObservedObject var authVM: AuthViewModel

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.selectedFilter != .genre {
                    SearchBarView(text: $viewModel.searchText, filterType: viewModel.selectedFilter) {
                        Task {
                            if viewModel.searchText.trimmingCharacters(in: .whitespaces).isEmpty {
                                await viewModel.fetchTrendingContent()
                            } else {
                                await viewModel.searchContent()
                            }
                        }
                    }
                }

                Picker("Filter", selection: $viewModel.selectedFilter) {
                    ForEach(FilterType.allCases) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                ContentTypePickerView(selectedType: $viewModel.selectedType) {
                    Task { await viewModel.fetchTrendingContent() }
                }

                if viewModel.selectedFilter == .genre {
                    GenrePickerView(genres: viewModel.allGenres, selectedGenre: $viewModel.selectedGenre)
                        .padding(.vertical, 5)
                }

                if !viewModel.movies.isEmpty {
                    Text(viewModel.searchText.isEmpty ? "Trending now" : "\(viewModel.totalResults) results found")
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
            }
            .background(Color.BG.ignoresSafeArea(.all))
            .navigationTitle("🎬 Trending Movies")
            .task {
                await viewModel.fetchTrendingContent()
                await viewModel.fetchGenresForSelectedType()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        authVM.signOut()
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.title3)
                            .foregroundColor(.yellow)
                    }
                }
            }
        }
    }
}

#Preview {
    MovieListView(authVM: AuthViewModel())
}
