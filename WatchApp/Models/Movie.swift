//
//  Movie.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-05-19.
//

import Foundation


struct Movie: Codable, Identifiable, Equatable, Hashable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let voteAverage: Double
    let releaseDate: String?
    let genreIds: [Int]
    let contentType: ContentType
    var userRating = 0
    var isWatched: Bool = false
    var isSaved: Bool = false
    var averageRating: Double = 0.0
    var tmdbURL: URL {
        URL(string: "https://www.themoviedb.org/movie/\(id)")!
    }

    /// A helper property that builds a small-size poster image URL using the poster path.
    /// Not part of the original API response – used only for display convenience.
    var posterURLSmall: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w200\(path)")
    }

    /// A helper property that builds a large-size poster image URL using the poster path.
    /// Not part of the original API response – used only for display convenience.
    var posterURLLarge: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }
    
    init(id: Int, title: String, overview: String, posterPath: String?, voteAverage: Double,
         releaseDate: String?, genreIds: [Int], contentType: ContentType = .movie, userRating: Int = 0, isWatched: Bool = false, isSaved: Bool = false) {
                self.id = id
                self.title = title
                self.overview = overview
                self.posterPath = posterPath
                self.voteAverage = voteAverage
                self.releaseDate = releaseDate
                self.genreIds = genreIds
                self.contentType = contentType
                self.userRating = userRating
                self.isWatched = isWatched
                self.isSaved = isSaved
    }
    
    init(from raw: MovieRaw, contentType: ContentType = .movie, userRating: Int = 0, isWatched: Bool = false, isSaved: Bool = false) {
        self.id = raw.id
        self.title = raw.title
        self.overview = raw.overview
        self.posterPath = raw.posterPath
        self.voteAverage = raw.voteAverage
        self.releaseDate = raw.releaseDate
        self.genreIds = raw.genreIds ?? []
        self.contentType = contentType
        self.userRating = userRating
        self.isSaved = isSaved
        self.isWatched = isWatched
    }
}

struct MovieResults: Codable {
    let results: [MovieRaw]
}
