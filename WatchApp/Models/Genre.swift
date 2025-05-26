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
