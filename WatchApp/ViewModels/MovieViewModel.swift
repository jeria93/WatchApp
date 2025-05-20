//
//  MovieViewModel.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-05-19.
//

import Foundation

@MainActor
final class MovieViewModel: ObservableObject {
    
    @Published var movies: [Movie] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var totalResults: Int = 0
    
    private let service = TMDBService()
    
    /// Fetches the current list of trending movies from the API.
    ///
    /// This is the default call made on app start or when search is cleared.
    func fetchTrendingMovies() async {
        await fetch {
            try await self.service.fetchTrendingMovies()
        }
    }
    
    func searchMovies() async {
        
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            await fetchTrendingMovies()
            return
        }
        isLoading = true
        errorMessage = nil
        
        do {
            let fetched = try await service.searchMovies(query: trimmed)
            movies = fetched
            totalResults = fetched.count
        } catch {
            errorMessage = "Search failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func fetch(_ fetcher: () async throws -> [Movie]) async {
        isLoading = true
        errorMessage = nil
        do {
            let result = try await fetcher()
            movies = result
            totalResults = result.count
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    
}
