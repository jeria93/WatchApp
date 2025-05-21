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
    let contentType: ContentType
    
    /// small size poster
    var posterURLSmall: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w200\(path)")
    }

    /// large size poster
    var posterURLLarge: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }
}

struct MovieResults: Codable {
    let results: [Movie]
}
