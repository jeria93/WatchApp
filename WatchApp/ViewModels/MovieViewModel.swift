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
                let movies = try await service.fetchTrendingMovies()
                return movies.map { movie in
                    Movie(
                        id: movie.id,
                        title: movie.title,
                        overview: movie.overview,
                        posterPath: movie.posterPath,
                        voteAverage: movie.voteAverage,
                        releaseDate: movie.releaseDate,
                        contentType: .movie
                    )
                }
            case .tv:
                let shows = try await service.trendingTVShows()
                return shows.map { show in
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
                let moviesFound = try await service.searchMovies(query: trimmed)
                fetched = moviesFound.map { movie in
                    Movie(
                        id: movie.id,
                        title: movie.title,
                        overview: movie.overview,
                        posterPath: movie.posterPath,
                        voteAverage: movie.voteAverage,
                        releaseDate: movie.releaseDate,
                        contentType: .movie
                    )
                }
            case .tv:
                let shows = try await service.searchTVSeries(query: trimmed)
                fetched = shows.map { show in
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
