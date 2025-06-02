//
//  FilterType.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-05-27.
//

import Foundation

enum FilterType: String, CaseIterable, Identifiable {
    case title = "Title"
    case genre = "Genre"
    case director = "Director"
    case releaseDate = "Release Date"
    var id: String { rawValue }
}
