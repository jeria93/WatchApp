//
//  FirestoreViewModel.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-05-20.
//

import Foundation

@MainActor
final class FirestoreViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var errorMessage: String?
    
    private let firestoreService = FirestoreMovieService()
    
    func saveMovie(_ movie: Movie) async {
        do {
            try await firestoreService.saveMovie(movie)
        } catch {
            self.errorMessage = "Failed to save movie: \(error.localizedDescription)"
        }
    }
    
    func fetchMovies() async {
        do {
            movies = try await firestoreService.fetchSavedMovies()
        } catch {
            errorMessage = "Failed to load saved movies: \(error.localizedDescription)"
        }
    }
    
}
