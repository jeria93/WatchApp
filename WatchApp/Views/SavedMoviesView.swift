//
//  SavedMoviesView.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-05-20.
//

import SwiftUI

struct SavedMoviesView: View {
    @StateObject private var viewModel = FirestoreViewModel()
    @State private var selectedType: ContentType = .movie
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
    
            VStack {
                Picker("Type", selection: $selectedType) {
                    ForEach(ContentType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                Group {
                    if let error = viewModel.errorMessage {
                        ErrorView(message: error)
                    } else {
                        let unwatched = viewModel.movies.filter { $0.contentType == selectedType && !$0.isWatched }
                        let watched = viewModel.movies.filter { $0.contentType == selectedType && $0.isWatched }
                                                              
                        if unwatched.isEmpty && watched.isEmpty {
                            EmptySavedContentView(selectedType: selectedType)
                        } else {
                            ScrollView {
                                if !unwatched.isEmpty {
                                    Section(header: Text("Unwatched").foregroundStyle(.popcornYellow).font(.headline).padding(.top)) {
                                        ContentListView(movies: unwatched, contentType: selectedType, onSave: { movie in
                                            Task {
                                                await viewModel.saveMovie(movie)
                                                await viewModel.fetchMovies()
                                            }
                                        },
                                                        showWatchedButton: true)
                                    }
                                }
                                
                                if !watched.isEmpty {
                                    Section(header: Text("Watched").foregroundStyle(.popcornYellow).font(.headline)) {
                                        ContentListView(movies: watched,
                                                        contentType: selectedType, onSave: { movie in
                                            Task {
                                                await viewModel.saveMovie(movie)
                                                await viewModel.fetchMovies()
                                            }
                                        },
                                                        showWatchedButton: true)
                                    }
                                }
                            }
                        }
                    }
                }
                                
                                Spacer()
                            }
                            .task { await viewModel.fetchMovies() }
                            .background(Color.BG.ignoresSafeArea(.all))
                            
                        }
}

#Preview {
    SavedMoviesView()
        .environmentObject(AuthViewModel())
}
