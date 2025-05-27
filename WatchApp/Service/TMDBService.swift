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
        try await request(path: "/trending/movie/day")
    }

    /// Searches API for movies matching the given query
    func searchMovies(query: String) async throws -> [MovieRaw] {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return try await request(path: "/search/movie?query=\(encoded)")
    }

    /// Searches API for tv-series
    func searchTVSeries(query: String) async throws -> [TVShow] {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return try await requestTV(path: "/search/tv?query=\(encoded)")
    }
    /// fetches API for trending tv-series for the day
    func fetchTrendingTVSeries() async throws -> [TVShow] {
        try await requestTV(path: "/trending/tv/day")
    }

    /// This method sends a GET request to the `/genre/movie/list` endpoint,
    /// which returns a predefined list of all available movie genres supported by TMDB.
    ///
    /// - Returns: An array of `Genre` objects representing movie genres.
    /// - Throws: A `URLError` or decoding error if the request fails or the response is invalid.
    func fetchMoviesGenres() async throws -> [Genre] {
        try await requestGenres(path: "/genre/movie/list")
    }

    /// This method sends a GET request to the `/genre/tv/list` endpoint,
    /// which returns a predefined list of all available TV show genres supported by TMDB.
    ///
    /// - Returns: An array of `Genre` objects representing TV genres.
    /// - Throws: A `URLError` or decoding error if the request fails or the response is invalid.
    func fetchTvGenres() async throws -> [Genre] {
        try await requestGenres(path: "/genre/tv/list")
    }

    /// Helper method that builds and sends a TMDB GET request, then decodes the response.
    ///
    /// This avoids repeating boilerplate code when making API calls like fetching trending movies
    /// or searching by query.
    ///
    /// - Parameter path: The TMDB API endpoint path, e.g. `/trending/movie/day`
    /// - Returns: A list of decoded `Movie` objects.
    /// - Throws: Errors if the URL is invalid, the network request fails, or decoding fails.
    private func request(path: String) async throws -> [MovieRaw] {
        guard let url = URL(string: "\(baseURL)\(path)") else { throw URLError(.badURL) }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.allHTTPHeaderFields = [
            "accept": "application/json",
            "Authorization": "Bearer \(SecretManager.bearerToken)"
        ]

        let (data,_) = try await session.data(for: req)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(MovieResults.self, from: data).results
    }

    /// This method is used to fetch TV-related content from TMDB, such as trending shows or search results.
    ///
    /// - Parameter path: The endpoint path to append to the base TMDB URL (e.g. `/trending/tv/day`).
    /// - Returns: An array of decoded `TVShow` objects.
    /// - Throws: A `URLError` if the URL is invalid or a decoding/network error occurs.
    private func requestTV(path: String) async throws -> [TVShow] {

        guard let url = URL(string: "\(baseURL)\(path)") else { throw URLError(.badURL) }
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.allHTTPHeaderFields = [
            "accept": "application/json",
            "Authorization": "Bearer \(SecretManager.bearerToken)"
        ]
        let (data,_) = try await session.data(for: req)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(TVShowResults.self, from: data).results

    }

    /// This method is used to retrieve a predefined list of movie or TV show genres from TMDB.
    /// It appends `?language=en` to the query to ensure the genre names are returned in English.
    ///
    /// - Parameter path: The endpoint path to append to the base TMDB URL (e.g. `/genre/movie/list`).
    /// - Returns: An array of decoded `Genre` objects.
    /// - Throws: A `URLError` if the URL is invalid or a decoding/network error occurs.
    private func requestGenres(path: String) async throws -> [Genre] {
        guard let url = URL(string: "\(baseURL)\(path)?language=en") else { throw URLError(.badURL) }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.allHTTPHeaderFields = [
            "accept": "application/json",
            "Authorization": "Bearer \(SecretManager.bearerToken)"
        ]

        let (data,_) = try await session.data(for: req)
        let decoded = try JSONDecoder().decode(GenreResult.self, from: data)
        return decoded.genres
    }

//    MARK: - TEST
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
