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
    
    
    func addUserRating(ratedMovieId: Int, rating: Int) {
        let ratedMovieId = ratedMovieId
        let rating = rating
        firestore.collection("ratedMovies").document("\(ratedMovieId)").setData(["rating": rating])
    }
    
    func fetchUserRating(ratedMovieId: Int, completion: @escaping (Int?) -> Void){
        firestore.collection("ratedMovies").document("\(ratedMovieId)").getDocument { (document, _) in
            if let rating = document?.get("rating") as? Int {
                completion(rating)
            } else {
                completion(nil)
            }
        }
    }
    
    func snapshotRatingsListener(ratedMovieId: Int, completion: @escaping (Int?) -> Void) {
        let ref = firestore.collection("ratedMovies").document("\(ratedMovieId)")
        ref.addSnapshotListener { snapshot, error in
            if let error = error {
                print("error listening \(error)")
                completion(nil)
            } else {
                if let document = snapshot, document.exists {
                    if let userRating = document.get("userRating") as? Int {
                        completion(userRating)
                    } else {
                        print("rating not found")
                        completion(nil)
                    }
                } else {
                    completion(nil)
                }
            }
        
        }
    }
    
    
    
    
    
}
