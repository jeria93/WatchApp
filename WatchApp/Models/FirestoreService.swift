//
//  FirestoreService.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-05-20.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

final class FirestoreMovieService {
    
    private let firestore = Firestore.firestore()
    
    /// Saves a movie to the `savedMovies` collection in Firestore
    func saveMovie(_ movie: Movie) async throws {
        try firestore.collection("savedMovies").document("\(movie.id)").setData(from: movie)
    }
    
    /// Fetches all saved movies from the `savedMovies` collection in Firestore
    func fetchSavedMovies() async throws -> [Movie] {
        let snapshot = try await firestore.collection("savedMovies").getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: Movie.self)}
    }
    
}
