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
    func saveMovie(_ movie: Movie, userId: String) async throws {
        try firestore.collection("users").document(userId).collection("savedMovies").document("\(movie.id)").setData(from: movie)
    }
    
    /// Fetches all saved movies from the `savedMovies` collection in Firestore
    func fetchSavedMovies(userId: String) async throws -> [Movie] {
        let snapshot = try await firestore.collection("users").document(userId).collection("savedMovies").getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: Movie.self)}
    }
    
    func isMovieSaved(id: Int, userId: String) async throws -> Bool {
        let doc = try await firestore.collection("users").document(userId).collection("savedMovies").document("\(id)").getDocument()
        return doc.exists
    }
    
    func addUserRating(ratedMovieId: Int, rating: Int) {
        let ratedMovieId = ratedMovieId
        let rating = rating
        firestore.collection("ratedMovies").document("\(ratedMovieId)").setData(["rating": rating])
    }
    
    func fetchUserRating(id: Int, completion: @escaping (Int?) -> Void){
        firestore.collection("ratedMovies").document("\(id)").getDocument { (document, _) in
            if let rating = document?.get("rating") as? Int {
                completion(rating)
            } else {
                completion(nil)
            }
        }
    }
    
}
