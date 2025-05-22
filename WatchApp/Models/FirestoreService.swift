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
    
    func saveMovie(_ movie: Movie) async throws {
        try firestore.collection("savedMovies").document("\(movie.id)").setData(from: movie)
    }
}
