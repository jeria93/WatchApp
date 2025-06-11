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
    private let tmdbService = TMDBService()

    /// Saves a movie to the `savedMovies` collection in Firestore
    func saveMovie(_ movie: Movie, userId: String) async throws {
        try firestore.collection("users").document(userId).collection("savedMovies").document("\(movie.id)").setData(from: movie)
    }
    
    func deleteMovie(movieId: Int, userId: String) async throws {
        try await firestore.collection("users").document(userId).collection("savedMovies").document("\(movieId)").delete()
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
    
    func addSignedInUserRating(userId: String, ratedMovieId: Int, rating: Int) {
        let userId = userId
        let ratedMovieId = ratedMovieId
        let rating = rating
        firestore.collection("users").document(userId).collection("ratedMovies").document("\(ratedMovieId)").setData(["rating": rating])
        Task {
            do {
                let isSaved = try await isMovieSaved(id: ratedMovieId, userId: "userId")
                try await firestore.collection("users").document(userId).collection("savedMovies").document("\(ratedMovieId)").updateData(["userRating": rating])
            } catch {
                print("not sparad")
            }
        }
        addRatingForAverage(userId: userId, ratedMovieId: ratedMovieId, rating: rating)
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
    
    func fetchSignedInUserRating(userId: String, ratedMovieId: Int, completion: @escaping (Int?) -> Void){
        firestore.collection("users").document(userId).collection("ratedMovies").document("\(ratedMovieId)").getDocument { (document, _) in
            if let rating = document?.get("rating") as? Int {
                completion(rating)
            } else {
                completion(nil)
            }
        }
    }
    
    func fetchAllUserRatings(userId: String) async throws -> [(movieId: Int, rating: Int)] {
        let snapshot = try await firestore.collection("users").document(userId).collection("ratedMovies").getDocuments()
        return snapshot.documents.compactMap { doc in
            guard let rating = doc.data()["rating"] as? Int,
                  let movieId = Int(doc.documentID) else { return nil }
            return (movieId: movieId, rating: rating)
        }
    }
    
    func fetchTopRatedMovies(userId: String, limit: Int = 5) async throws -> [Movie] {
        let ratings = try await fetchAllUserRatings(userId: userId)
        let sortedRatings = ratings.sorted { $0.rating > $1.rating }
        var movies: [Movie] = []
        for rating in sortedRatings {
            do{
                let movieRaw = try await tmdbService.fetchMovieById(rating.movieId)
                var movie = Movie(from: movieRaw, userRating: rating.rating)
                movies.append(movie)
                if movies.count >= limit { break }
            }catch {
                print("Error fetching movie \(rating.movieId): \(error)")
            }
        }
        return movies
    }
    
    func addRatingForAverage(userId: String, ratedMovieId: Int, rating: Int){
        let documentRef = firestore.collection("ratingsForAverage").document("\(ratedMovieId)")

        documentRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let ratingsDb = document.data() ?? [:]
                
                if ratingsDb.keys.contains("rating") && !ratingsDb.keys.contains("rating\(userId)"){
                    
                    let newFieldName = "rating\(userId)"
                    
                    documentRef.updateData([
                        newFieldName: rating
                    ]) { error in
                        if let error = error {
                            print("Error updating document: \(error.localizedDescription)")
                        } else {
                            print("Document successfully updated with new field: \(newFieldName)")
                        }
                    }
                } else {
                    documentRef.updateData(["rating": rating])
                }
            } else {
                documentRef.setData(["rating": rating])
            }
        }
    }
    
    func fetchAverageRating(movieId: Int, completion: @escaping (Double?) -> Void){
        let documentRef = firestore.collection("ratingsForAverage").document("\(movieId)")

        documentRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data() ?? [:]
                var allRatings: [Int] = []

                for (_, value) in data {
                    if let rating = value as? Int {
                        allRatings.append(rating)
                    }
                }
                if !allRatings.isEmpty {
                    let sum = allRatings.reduce(0, +)
                    let average = Double(sum) / Double(allRatings.count)
                    completion(average)
                } else {
                    completion(nil)
                }
            } else {
                print("Document does not exist or there was an error: \(error?.localizedDescription ?? "unknown error")")
                completion(nil)
            }
        }
    }
    
    func fetchTopAverage(completion: @escaping ([Int: Double]) -> Void ) {
        var topFive: [Int: Double] = [:]
        let collectionRef = firestore.collection("ratingsForAverage")

        collectionRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
            } else {
                for document in querySnapshot!.documents {
                    if let movieId = Int(document.documentID) {
                        self.fetchAverageRating(movieId: movieId) { average in
                            if let average = average {
                                topFive[movieId] = average
                                
                                if topFive.count == min(5, querySnapshot!.documents.count) {
                                    completion(topFive)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
