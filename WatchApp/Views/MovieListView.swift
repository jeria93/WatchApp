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
                        
                        if viewModel.searchText.trimmingCharacters(in: .whitespaces).isEmpty {
                            await viewModel.fetchTrendingMovies()
                        } else {
                            await viewModel.searchMovies()
                        }
                    }
                }
                
                if !viewModel.movies.isEmpty {
                    Text(viewModel.searchText.isEmpty ? "Trending now" : "\(viewModel.totalResults) results found")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 10)
                }
                
                Group {
                    if viewModel.isLoading {
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
                        }
                    }
                }
            }
            .navigationTitle("🎬 Trending Movies")
            .task { await viewModel.fetchTrendingMovies() }
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

#Preview("Default Empty") {
    EmptyStateView(searchText: "")
}

#Preview("No results found for 'Batman'") {
    EmptyStateView(searchText: "Star Wars")
}
