//
//  CrewCredit.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-05-27.
//

import Foundation

/// Represents a single credit for a person in a crew role (e.g. Director, Producer).
///
/// Used in the context of `/person/{person_id}/combined_credits` from TMDB API.
struct CrewCredit: Codable {
    let id: Int
    let job: String
    let title: String?
    let overview: String?
    let posterPath: String?
    let voteAverage: Double?
    let releaseDate: String?
    let genreIds: [Int]?
    let mediaType: String
}
/// Wraps all crew-related credits for a person from the `/combined_credits` endpoint.
struct CombinedCredits: Codable {
    let crew: [CrewCredit]
}
