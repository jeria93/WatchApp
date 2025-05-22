//
//  MovieListView.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-05-19.
//

import SwiftUI

struct MovieListView: View {
<<<<<<< HEAD
    
    @StateObject private var viewModel = MovieViewModel()
    @StateObject private var firestoreVM = FirestoreViewModel()
    @ObservedObject var authVM: AuthViewModel
    
=======

    @StateObject private var viewModel = MovieViewModel()
    @StateObject private var firestoreVM = FirestoreViewModel()
    @ObservedObject var authVM: AuthViewModel

>>>>>>> dev-main
    var body: some View {
        NavigationStack {
            VStack {
                SearchBarView(text: $viewModel.searchText) {
                    Task {
                        if viewModel.searchText.trimmingCharacters(in: .whitespaces).isEmpty {
                            await viewModel.fetchTrendingContent()
                        } else {
                            await viewModel.searchContent()
                        }
                    }
                }
<<<<<<< HEAD
                
=======

>>>>>>> dev-main
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
<<<<<<< HEAD
                
                if !viewModel.movies.isEmpty {
                    Text(viewModel.searchText.isEmpty ? "Trending now" : "\(viewModel.totalResults) results found")
=======

                if !viewModel.movies.isEmpty {
                    Text(viewModel.searchText.isEmpty ? "Trending now" : "(viewModel.totalResults) results found")
>>>>>>> dev-main
                        .font(.subheadline)
                        .foregroundColor(.popcornYellow)
                        .padding(.top, 10)
                }
<<<<<<< HEAD
                
=======

>>>>>>> dev-main
                Group {
                    if viewModel.isLoading {
                        LoadingView()
                    } else if let error = viewModel.errorMessage {
                        ErrorView(message: error)
                    } else if viewModel.movies.isEmpty {
                        EmptyStateView(searchText: viewModel.searchText)
                            .frame(maxHeight: .infinity)
                    } else {
                        ContentListView(movies: viewModel.movies, contentType: viewModel.selectedType) { movie in
                            Task { await firestoreVM.saveMovie(movie) }
                        }
                    }
                }
            }
            .background(Color.BG.ignoresSafeArea(.all))
            .navigationTitle("🎬 Trending Movies")
            .task { await viewModel.fetchTrendingContent() }
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
