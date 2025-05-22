//
//  TVShow.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-05-20.
//

import Foundation

struct TVShow: Codable, Identifiable {
    let id: Int
    let name: String
    let overview: String
    let posterPath: String?
    let voteAverage: Double
    let firstAirDate: String?
    
    var posterURLSmall: URL? {
        guard let posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w200/\(posterPath)")
    }
}

struct TVShowResults: Codable {
    let results: [TVShow]
}
