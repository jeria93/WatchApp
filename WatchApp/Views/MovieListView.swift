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

                VStack(spacing: 0) {

                    // Visa bara sökfältet om det inte är genre
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

                    // Filterväljare (FilterType)
                    Picker("Filter", selection: $viewModel.selectedFilter) {
                        ForEach(FilterType.allCases) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // Typväljare (Movie eller TV)
                    ContentTypePickerView(selectedType: $viewModel.selectedType) {
                        Task { await viewModel.fetchTrendingContent() }
                    }
                    .padding(.vertical, 5)

                    // Genre-väljare om genre är valt
                    if viewModel.selectedFilter == .genre {
                        GenrePickerView(genres: viewModel.allGenres, selectedGenre: $viewModel.selectedGenre)
                            .padding(.vertical, 5)
                    }

                    // Resultattext
                    if !viewModel.movies.isEmpty {
                        Text(viewModel.searchText.isEmpty ? "Trending now" : "\(viewModel.totalResults) results found")
                            .font(.subheadline)
                            .foregroundColor(.popcornYellow)
                            .padding(.top, 10)
                    }

                    // Innehåll
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
    MovieListView()
        .environmentObject(AuthViewModel())
}

#Preview("Default Empty") {
    EmptyStateView(searchText: "")
}

#Preview("No results found for 'Batman'") {
    EmptyStateView(searchText: "Star Wars")
}
