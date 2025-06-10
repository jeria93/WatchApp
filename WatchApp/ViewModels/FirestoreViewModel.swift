//
//  FirestoreViewModel.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-05-20.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class FirestoreViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var errorMessage: String?
    @Published var showUndoMessage: Bool = false
    @Published var lastDeletedMovie: Movie?
    @Published var topRatedMovies: [Movie] = []
    private var isFetchingTopRated = false
    
    private let firestoreService = FirestoreMovieService()
    
    /// Saves a movie/tv-show to Firestore
    func saveMovie(_ movie: Movie) async -> Bool {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "User not authenticated"
            return false
        }
        do {
            if movie.isSaved {
                try await firestoreService.saveMovie(movie, userId: userId)
                if !movies.contains(where: { $0.id == movie.id }) {
                    movies.append(movie)
                }
                return false
            } else {
                lastDeletedMovie = movie
                showUndoMessage = true
                try await firestoreService.deleteMovie(movieId: movie.id, userId: userId)
                movies.removeAll { $0.id == movie.id }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.showUndoMessage = false
                    self.lastDeletedMovie = nil
                }
                return true
            }
        }catch {
            self.errorMessage = "Failed to save/delete movie: \(error.localizedDescription)"
            return false
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
    
    func undoDelete() async {
        guard let movie = lastDeletedMovie else { return }

        var movieToSave = movie
        movieToSave.isSaved = true
        
        let wasDeleted = await saveMovie(movieToSave)
        if wasDeleted {
            self.errorMessage = "Failed to undo delete"
        } else {
            await fetchMovies()
        }
    
        showUndoMessage = false
        self.lastDeletedMovie = nil
    }
    
    func deleteAllMovies() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "User not authenticated"
            return
        }
        do{
            let db = Firestore.firestore()
            let collectionRef = db.collection("users").document(userId).collection("savedMovies")
            let snapshot = try await collectionRef.getDocuments()
            
            let batch = db.batch()
            for document in snapshot.documents {
                batch.deleteDocument(document.reference)
            }
            try await batch.commit()
            
            movies = []
        } catch {
            self.errorMessage = "Failed to delete everything saved: \(error.localizedDescription)"
        }
    }
    
    func fetchTopRatedMovies() {
        guard let userId = Auth.auth().currentUser?.uid, !isFetchingTopRated else {
            topRatedMovies = []
            return
        }
        
        isFetchingTopRated = true
        Task {
            do{
                let movies = try await firestoreService.fetchTopRatedMovies(userId: userId, limit: 5)
                let userRatedMovies = Array(Set(movies.prefix(5)))
                topRatedMovies = userRatedMovies.count > 5 ? Array(userRatedMovies.prefix(5)) : userRatedMovies
                print("Fetched top 5 movies: \(topRatedMovies.map { ($0.title, $0.userRating) })")
            } catch {
                print("Error fetching top rated movies: \(error)")
                topRatedMovies = []
            }
            isFetchingTopRated = false
        }
    }
}
