//
//  Movie.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-05-19.
//

import Foundation


struct Movie: Codable, Identifiable, Equatable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let voteAverage: Double
    let releaseDate: String?
    let genreIds: [Int]
    let contentType: ContentType
    var userRating = 0

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
}

struct MovieResults: Codable {
    let results: [MovieRaw]
}
