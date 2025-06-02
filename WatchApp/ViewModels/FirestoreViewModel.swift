//
//  FirestoreViewModel.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-05-20.
//

import Foundation
import FirebaseAuth

@MainActor
final class FirestoreViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var errorMessage: String?
    
    private let firestoreService = FirestoreMovieService()
    
    /// Saves a movie/tv-show to Firestore
    func saveMovie(_ movie: Movie) async {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "User not authenticated"
            return
        }
        do {
            try await firestoreService.saveMovie(movie, userId: userId)
        } catch {
            self.errorMessage = "Failed to save movie: \(error.localizedDescription)"
        }
    }
    
    
    /// Fetches all saved movies/shows from Firestore
    func fetchMovies() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "User not authenticated"
            return
        }
        do {
            movies = try await firestoreService.fetchSavedMovies(userId: userId)
        } catch {
            errorMessage = "Failed to load saved movies: \(error.localizedDescription)"
        }
    }
    
}
