//
//  Person.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-05-27.
//

import Foundation

/// A person from TMDB, like a director or actor.
struct Person: Codable {
    let id: Int
    let name: String
}

/// The result from searching for a person (like a director) on TMDB.
struct PersonSearchResult: Codable {
    let results: [Person]
}

/// Only using `id` and `name` for now since that’s all I need
/// But TMDB gives way more stuff like profile image and popularity
/// Maybe later I’ll show the director’s face or famous movies they’ve made
