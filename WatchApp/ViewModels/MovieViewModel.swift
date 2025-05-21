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
    @Published var selectedType: ContentType = .movie
    
    private let service = TMDBService()
    
    /// Fetches the current list of trending movies from the API.
    ///
    /// This is the default call made on app start or when search is cleared.
    func fetchTrendingContent() async {
        await fetch {
            switch selectedType {
            case .movie:
                let raw = try await service.fetchTrendingMovies()
                return raw.map(ContentMapper.fromRaw)
            case .tv:
                let shows = try await service.fetchTrendingTVSeries()
                return shows.map(ContentMapper.fromTVShow)
            }
        }
    }
    
    func searchContent() async {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            await fetchTrendingContent()
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let fetched: [Movie]
            switch selectedType {
            case .movie:
                let raw = try await service.searchMovies(query: trimmed)
                fetched = raw.map(ContentMapper.fromRaw)
            case .tv:
                let shows = try await service.searchTVSeries(query: trimmed)
                fetched = shows.map(ContentMapper.fromTVShow)
            }
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
