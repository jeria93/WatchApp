//
//  Genre.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-05-26.
//

import Foundation

struct Genre: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
}

struct GenreResult: Codable {
    let genres: [Genre]
}

extension Genre {
    static let previewGenres: [Genre] = [
        .init(id: 28, name: "Action"),
        .init(id: 35, name: "Comedy"),
        .init(id: 18, name: "Drama"),
        .init(id: 10749, name: "Romance"),
        .init(id: 27, name: "Horror")
        ]
}
