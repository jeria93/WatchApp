//
//  ContentMapper.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-05-21.
//

import Foundation

struct ContentMapper {
    
    static func fromRaw(_ raw: MovieRaw) -> Movie {
        Movie(
            id: raw.id,
            title: raw.title,
            overview: raw.overview,
            posterPath: raw.posterPath,
            voteAverage: raw.voteAverage,
            releaseDate: raw.releaseDate,
            contentType: .movie
        )
    }

    static func fromTVShow(_ show: TVShow) -> Movie {
        Movie(
            id: show.id,
            title: show.name,
            overview: show.overview,
            posterPath: show.posterPath,
            voteAverage: show.voteAverage,
            releaseDate: show.firstAirDate,
            contentType: .tv
        )
    }
}
