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

    func fetchTrendingMovies() async throws -> [Movie] {
        
        guard let url = URL(string: "\(baseURL)/trending/movie/day") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = [
            "accept": "application/json",
            "Authorization": "Bearer \(SecretManager.bearerToken)"
        ]

        let (data, _) = try await session.data(for: request)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let movieResults = try decoder.decode(MovieResults.self, from: data)
        return movieResults.results
    }
}
