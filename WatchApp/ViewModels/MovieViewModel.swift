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
    
    /// Fetches trending content (movies or TV shows) based on the selected content type.
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
    
    /// Searches for movies or TV shows using the current `searchText`
    ///
    /// Falls back to `fetchTrendingContent()` if the search text is empty.
    /// Results are mapped to `Movie` models using `ContentMapper`
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
    
    
    /// A reusable fetch wrapper used for trending or other content loaders.
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
