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

    /// Converts a `CrewCredit` into a `Movie` object if it's a movie-type credit.
    ///
    /// - Parameter credit: A credit object representing a crew member's contribution.
    /// - Returns: A `Movie` if the credit is for a movie, otherwise `nil`.
    static func fromCrewCreditMovie(_ credit: CrewCredit) -> Movie? {
        guard credit.mediaType == "movie",
              let title = credit.title else { return nil }

        return Movie(
            id: credit.id,
            title: title,
            overview: credit.overview ?? "",
            posterPath: credit.posterPath,
            voteAverage: credit.voteAverage ?? 0.0,
            releaseDate: credit.releaseDate,
            genreIds: credit.genreIds ?? [],
            contentType: .movie
        )
    }
    /// Converts a `CrewCredit` into a `Movie` object if it's a TV-type credit.
    ///
    /// - Parameter credit: A credit object representing a crew member's contribution.
    /// - Returns: A `Movie` if the credit is for a TV show, otherwise `nil`.
    static func fromCrewCreditTV(_ credit: CrewCredit) -> Movie? {
        guard credit.mediaType == "tv", let title = credit.title else { return nil }
        return Movie(
            id: credit.id,
            title: title,
            overview: credit.overview ?? "",
            posterPath: credit.posterPath,
            voteAverage: credit.voteAverage ?? 0.0,
            releaseDate: credit.releaseDate,
            genreIds: credit.genreIds ?? [],
            contentType: .tv
        )
    }
}
