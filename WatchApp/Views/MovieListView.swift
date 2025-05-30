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
        NavigationStack {
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
                        DatePicker(
                            "Select year",
                            selection: $viewModel.selectedDate,
                            in: ...Date(),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .padding(.horizontal)
                        .onChange(of: viewModel.selectedDate) { _ in
                            Task { await viewModel.searchByReleaseYear(viewModel.selectedDate) }
                        }

                        Text("Showing results for year: \(Calendar.current.component(.year, from: viewModel.selectedDate))")
                            .font(.subheadline)
                            .foregroundColor(.popcornYellow)
                            .padding(.top, 5)
                    }

                    //                    Extract to its own view later TODO:
                    Picker("Filter", selection: $viewModel.selectedFilter) {
                        ForEach(FilterType.allCases) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    ContentTypePickerView(selectedType: $viewModel.selectedType)

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
                        } else if viewModel.selectedFilter == .genre && viewModel.filteredMovies.isEmpty {
                            EmptyGenreView()
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
            .navigationTitle("🎬 Trending Movies")
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
