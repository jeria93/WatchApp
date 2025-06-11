//
//  ContentType.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-05-20.
//

import Foundation

/// Represents the type of content that can be displayed or saved in the app.
///
/// Used to distinguish between movies and TV shows in UI logic, API calls, and storage.
enum ContentType: String, CaseIterable, Identifiable, Codable {

    var id: String { rawValue }
    case movie = "Movies"
    case tv = "TV Shows"
}
