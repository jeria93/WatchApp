//
//  ContentType.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-05-20.
//

import Foundation

enum ContentType: String, CaseIterable, Identifiable {
    
    var id: String { rawValue }
    case movie = "Movies"
    case tv = "TV Shows"
}
