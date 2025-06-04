//
//  TMDBService.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-05-19.
//

import Foundation

/// Makes all the calls to the API
final class TMDBService {
    private let baseURL = "https://api.themoviedb.org/3"
    private let session = URLSession.shared


    /// Fetches the current list of trending movies by today
    func fetchTrendingMovies() async throws -> [MovieRaw] {
        let result: MovieResults = try await request(path: "/trending/movie/week")
        return result.results
    }

    /// Searches API for movies matching the given query
    func searchMovies(query: String) async throws -> [MovieRaw] {
        let queryItems = [URLQueryItem(name: "query", value: query)]
        let result: MovieResults = try await request(path: "/search/movie", queryItems: queryItems)
        return result.results
    }

    /// Searches API for tv-series
    func searchTvSeries(query: String) async throws -> [TVShow] {
        let queryItems = [URLQueryItem(name: "query", value: query)]
        let result: TVShowResults = try await request(path: "/search/tv", queryItems: queryItems)
        return result.results
    }

    /// Fetches API for trending tv-series for the day
    func fetchTrendingTvSeries() async throws -> [TVShow] {
        let result: TVShowResults = try await request(path: "/trending/tv/week")
        return result.results
    }

    /// Fetches all available movie genres supported by TMDB.
    func fetchMovieGenres() async throws -> [Genre] {
        let queryItems = [URLQueryItem(name: "language", value: "en")]
        let result: GenreResult = try await request(path: "/genre/movie/list", queryItems: queryItems)
        return result.genres
    }

    /// Fetches all available TV genres supported by TMDB.
    func fetchTvGenres() async throws -> [Genre] {
        let queryItems = [URLQueryItem(name: "language", value: "en")]
        let result: GenreResult = try await request(path: "/genre/tv/list", queryItems: queryItems)
        return result.genres
    }

    func searchDirector(query: String) async throws -> [CrewCredit] {
        let personResults: PersonSearchResult = try await request(path: "/search/person", queryItems: [URLQueryItem(name: "query", value: query)])

        guard let director = personResults.results.first else {
            return []
        }

        let credits: CombinedCredits = try await request(path: "/person/\(director.id)/combined_credits")

        return credits.crew.filter { $0.job == "Director" }
    }

    func searchMoviesByReleaseYear(year: String) async throws -> [MovieRaw] {
        let queryItems = [
            URLQueryItem(name: "primary_release_year", value: year),
            URLQueryItem(name: "sort_by", value: "popularity.desc")
        ]
        let result: MovieResults = try await request(path: "/discover/movie", queryItems: queryItems)
        return result.results
    }

    func searchTvSeriesByReleaseYear(year: String) async throws -> [TVShow] {
        let start = "\(year)-01-01"
        let end   = "\(year)-12-31"
        let queryItems = [
          URLQueryItem(name: "first_air_date.gte", value: start),
          URLQueryItem(name: "first_air_date.lte", value: end),
          URLQueryItem(name: "sort_by",          value: "popularity.desc")
        ]
        let result: TVShowResults = try await request(path: "/discover/tv", queryItems: queryItems)
        return result.results
    }
    
    func fetchMovieById(_ movieId: Int) async throws -> MovieRaw {
        let result: MovieRaw = try await request(path: "/movie/\(movieId)")
        return result
    }

    /// Generic method that sends a GET request to TMDB and decodes the response into any Decodable model.
    ///
    /// - Parameters:
    ///   - path: The endpoint path to append to the base TMDB URL.
    ///   - queryItems: Optional query parameters to be appended to the request.
    /// - Returns: A decoded model of the specified type.
    /// - Throws: A `URLError` or decoding error if something goes wrong.
    private func request<Model: Decodable>(path: String, queryItems: [URLQueryItem] = []) async throws -> Model {
        var components = URLComponents(string: "\(baseURL)\(path)")!
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let url = components.url else { throw URLError(.badURL) }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.allHTTPHeaderFields = [
            "accept": "application/json",
            "Authorization": "Bearer \(SecretManager.bearerToken)"
        ]

        let (data, _) = try await session.data(for: req)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(Model.self, from: data)
    }
}


