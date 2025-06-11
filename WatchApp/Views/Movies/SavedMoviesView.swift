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
    @State private var showDeleteAllConfirmation = false
    @State private var selectedMovie: Movie?
    @State private var showRandomPicker = false
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        
        ZStack {
            Color.BG.edgesIgnoringSafeArea(.all)
            
            VStack {
                Picker("Type", selection: $selectedType) {
                    ForEach(ContentType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                HStack{
                    Button(action: {
                        showRandomPicker = true }) {
                            Text("Pick Random")
                                .foregroundStyle(.popcornYellow)
                                .padding(.top, 4)
                        }
                        .padding(.horizontal)
                        .disabled(viewModel.movies.filter { $0.contentType == selectedType }.isEmpty)
                    Spacer()
                    
                    Button(action: {
                        showDeleteAllConfirmation = true
                    }) {
                        Text("Delete All")
                            .foregroundStyle(.red)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal)
                    .disabled(viewModel.movies.isEmpty)
                }
                
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
                                                let wasRemoved = await viewModel.saveMovie(movie)
                                                await viewModel.fetchMovies()
                                            }
                                        },
                                                        onDelete: nil,
                                                        showWatchedButton: true,
                                                        disableAfterSave: false)
                                    }
                                }
                                
                                if !watched.isEmpty {
                                    Section(header: Text("Watched").foregroundStyle(.popcornYellow).font(.headline)) {
                                        ContentListView(movies: watched,
                                                        contentType: selectedType, onSave: { movie in
                                            Task {
                                                let wasRemoved = await viewModel.saveMovie(movie)
                                                await viewModel.fetchMovies()
                                            }
                                        },                   onDelete: nil,
                                                        showWatchedButton: true,
                                                        disableAfterSave: false)
                                    }
                                }
                            }
                        }
                    }
                }
                
                Spacer()
                
                if viewModel.showUndoMessage {
                    UndoSnackBar(viewModel: viewModel)
                }
            }
            .alert("Delete all saved content?", isPresented: $showDeleteAllConfirmation) {
                Button("Delete", role: .destructive) {
                    Task {
                        await viewModel.deleteAllMovies()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete all saved content? This action cannot be undone.")
            }
            .sheet(isPresented: $showRandomPicker) {
                RandomPickerView(movies: viewModel.movies.filter { $0.contentType == selectedType}, onSelect: { movie in
                    selectedMovie = movie
                showRandomPicker = false},
                                 onCancel: {showRandomPicker = false }
                )
            }
            .sheet(item: $selectedMovie) { movie in
                MovieDetailView(movie: movie, contentType: movie.contentType)
                    .environmentObject(authVM)
                    .onDisappear {
                        selectedMovie = nil
                    }
            }
            .task { await viewModel.fetchMovies() }
        }
    }
}

struct UndoSnackBar: View {
    let viewModel: FirestoreViewModel
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Text("Deleted")
                    .foregroundStyle(.white)
                Button("UNDO") {
                    Task{
                        await viewModel.undoDelete()
                    }
                }
                .foregroundStyle(.red)
                .background(Color.black.cornerRadius(4))
                .padding(.horizontal)
            }
            .padding()
            .background(Color.gray.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.bottom)
            .transition(.move(edge: .bottom))
        }
        .background(.clear)
    }
}


#Preview {
    SavedMoviesView()
        .environmentObject(AuthViewModel())
}
