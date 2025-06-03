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
                                                print("Bookmark toggled for movie: \(movie.title), id: \(movie.id)")
                                                let wasRemoved = await viewModel.saveMovie(movie)
                                                print("Bookmark result: wasRemoved = \(wasRemoved)")
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
                                                print("Bookmark toggled for movie: \(movie.title), id: \(movie.id)")
                                                let wasRemoved = await viewModel.saveMovie(movie)
                                                print("Bookmark result: wasRemoved = \(wasRemoved)")
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
                Text("Movie deleted")
                    .foregroundStyle(.white)
                Button("UNDO") {
                    Task{
                        await viewModel.undoDelete()
                    }
                }
                .foregroundStyle(.red)
                .background(Color.white.opacity(0.5).cornerRadius(4))
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
