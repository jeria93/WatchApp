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
    func fetchTrendingMovies() async throws -> [Movie] {
        try await request(path: "/trending/movie/day")
    }
    
    /// Searches API for movies matching the given query
    func searchMovies(query: String) async throws -> [Movie] {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return try await request(path: "/search/movie?query=\(encoded)")
    }
    
    
    /// Helper method that builds and sends a TMDB GET request, then decodes the response.
    ///
    /// This avoids repeating boilerplate code when making API calls like fetching trending movies
    /// or searching by query.
    ///
    /// - Parameter path: The TMDB API endpoint path, e.g. `/trending/movie/day`
    /// - Returns: A list of decoded `Movie` objects.
    /// - Throws: Errors if the URL is invalid, the network request fails, or decoding fails.
    private func request(path: String) async throws -> [Movie] {
        
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
}
