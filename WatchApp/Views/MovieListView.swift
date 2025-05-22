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
                SearchBarView(text: $viewModel.searchText) {
                    Task {
<<<<<<< HEAD
                        
                        if viewModel.searchText.trimmingCharacters(in: .whitespaces).isEmpty {
                            await viewModel.fetchTrendingMovies()
                        } else {
                            await viewModel.searchMovies()
=======
                        if viewModel.searchText.trimmingCharacters(in: .whitespaces).isEmpty {
                            await viewModel.fetchTrendingContent()
                        } else {
                            await viewModel.searchContent()
>>>>>>> dev-add-favorite-nico
                        }
                    }
                }
                
<<<<<<< HEAD
                
=======
                Picker("Type", selection: $viewModel.selectedType) {
                    ForEach(ContentType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: viewModel.selectedType) { _ in
                    Task { await viewModel.fetchTrendingContent() }
                }
>>>>>>> dev-add-favorite-nico
                
                if !viewModel.movies.isEmpty {
                    Text(viewModel.searchText.isEmpty ? "Trending now" : "\(viewModel.totalResults) results found")
                        .font(.subheadline)
                        .foregroundColor(.popcornYellow)
                        .padding(.top, 10)
                }
                
                Group {
                    if viewModel.isLoading {
<<<<<<< HEAD
                        VStack {
                            ProgressView("Loading movies...")
                            Spacer()
                        }
                        .frame(maxHeight: .infinity)
                        
                    } else if let error = viewModel.errorMessage {
                        VStack {
                            Text(error)
                                .foregroundColor(.red)
                            Spacer()
                        }
                        .padding()
                        .frame(maxHeight: .infinity)
                        
                    } else if viewModel.movies.isEmpty {
                        EmptyStateView(searchText: viewModel.searchText)
                            .frame(maxHeight: .infinity)
                        
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 15) {
                                ForEach(viewModel.movies) { movie in
                                    MovieRow(movie: movie) {
                                        Task { await firestoreVM.saveMovie(movie)}
                                    }
                                }
                            }
                            .padding()
=======
                        LoadingView()
                    } else if let error = viewModel.errorMessage {
                        ErrorView(message: error)
                    } else if viewModel.movies.isEmpty {
                        EmptyStateView(searchText: viewModel.searchText)
                            .frame(maxHeight: .infinity)
                    } else {
                        ContentListView(movies: viewModel.movies, contentType: viewModel.selectedType) { movie in
                            Task { await firestoreVM.saveMovie(movie) }
>>>>>>> dev-add-favorite-nico
                        }
                    }
                }
            }
            .background(Color.BG.ignoresSafeArea(.all))
            .navigationTitle("🎬 Trending Movies")
<<<<<<< HEAD
            .task { await viewModel.fetchTrendingMovies() }
=======
            .task { await viewModel.fetchTrendingContent() }
>>>>>>> dev-add-favorite-nico
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
<<<<<<< HEAD

=======
>>>>>>> dev-add-favorite-nico
        }
    }
}

#Preview {
    MovieListView(authVM: AuthViewModel())
}

#Preview("Default Empty") {
    EmptyStateView(searchText: "")
}

#Preview("No results found for 'Batman'") {
    EmptyStateView(searchText: "Star Wars")
}
