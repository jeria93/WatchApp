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
            ZStack {
                Color.BG
                    .ignoresSafeArea(.all)

                VStack(spacing: 15) {

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
                        .padding(.vertical)
                    }

                    if viewModel.selectedFilter == .releaseDate {
                        DateFilterView(selectedDate: $viewModel.selectedDate) { newDate in
                            await viewModel.searchByReleaseYear(newDate)
                        }
                    }

                    FilterPickerView(selectedFilter: $viewModel.selectedFilter)

                    ContentTypePickerView(selectedType: $viewModel.selectedType)

                    if viewModel.selectedFilter == .genre {
                        GenrePickerView(genres: viewModel.allGenres, selectedGenre: $viewModel.selectedGenre)
                            .padding(.vertical, 5)
                    }

                    if !viewModel.movies.isEmpty {
                        ResultsHeaderView(searchText: viewModel.searchText, totalResults: viewModel.totalResults)
                    }

                    Group {
                        if viewModel.isLoading {
                            LoadingView()
                        } else if let error = viewModel.errorMessage {
                            ErrorView(message: error)
                        } else if viewModel.selectedFilter == .genre && viewModel.filteredMovies.isEmpty {
                            EmptyGenreView()
                        } else if viewModel.movies.isEmpty {
                            EmptyStateView(searchText: viewModel.searchText)
                                .frame(maxHeight: .infinity)
                        } else {
                            ContentListView(movies: viewModel.filteredMovies, contentType: viewModel.selectedType, onSave: { movie in
                                Task { await firestoreVM.saveMovie(movie) }
                            }, onDelete: nil,
                            showWatchedButton: false,
                            disableAfterSave: true
                            )
                        }
                    }
                    .frame(maxHeight: .infinity)
                }
                .task {
                await viewModel.fetchTrendingContent()
                await viewModel.fetchGenresForSelectedType()
            }
        }
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
