//
//  ContentMapper.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-05-21.
//

import Foundation

struct ContentMapper {
    
    /// Converts a `MovieRaw` (from TMDB's movie endpoint) into a `Movie`.
    ///
    /// - Parameter raw: A decoded `MovieRaw` object from the API.
    /// - Returns: A fully initialized `Movie` object with `.movie` as contentType.
    static func fromRaw(_ raw: MovieRaw) -> Movie {
        Movie(
            id: raw.id,
            title: raw.title,
            overview: raw.overview,
            posterPath: raw.posterPath,
            voteAverage: raw.voteAverage,
            releaseDate: raw.releaseDate,
            genreIds: raw.genreIds,
            contentType: .movie
        )
    }
    
    /// Converts a `TVShow` (from TMDB's TV endpoint) into a `Movie` model.
    ///
    /// - Parameter show: A decoded `TVShow` object from the API.
    /// - Returns: A `Movie` object adapted for reuse, with `.tv` as contentType.
    static func fromTVShow(_ show: TVShow) -> Movie {
        Movie(
            id: show.id,
            title: show.name,
            overview: show.overview,
            posterPath: show.posterPath,
            voteAverage: show.voteAverage,
            releaseDate: show.firstAirDate,
            genreIds: show.genreIds,
            contentType: .tv
        )
    }
}
