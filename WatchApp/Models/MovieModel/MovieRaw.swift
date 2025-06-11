//
//  MovieRaw.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-05-21.
//

import Foundation

struct MovieRaw: Codable, Identifiable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let voteAverage: Double
    let releaseDate: String?
    let genreIds: [Int]?
}
