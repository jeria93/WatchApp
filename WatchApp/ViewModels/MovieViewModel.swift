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
    @Published var selectedGenre: Genre?
    @Published var selectedFilter: FilterType = .title
    @Published var allGenres: [Genre] = []
    private var hasLoadedGenres = false

    var filteredMovies: [Movie] {
        guard let selectedGenre else { return movies }
        return movies.filter { $0.genreIds.contains(selectedGenre.id) }
    }

    private let service = TMDBService()

    /// Fetches trending content (movies or TV shows) based on the selected content type.
    func fetchTrendingContent() async {
        await fetch {
            switch selectedType {
            case .movie:
                let raw = try await service.fetchTrendingMovies()
                return raw.map(ContentMapper.fromRaw)
            case .tv:
                let shows = try await service.fetchTrendingTvSeries()
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
            var fetched: [Movie] = []

            switch selectedFilter {
            case .title:
                switch selectedType {
                case .movie:
                    let raw = try await service.searchMovies(query: trimmed)
                    fetched = raw.map(ContentMapper.fromRaw)
                case .tv:
                    let shows = try await service.searchTvSeries(query: trimmed)
                    fetched = shows.map(ContentMapper.fromTVShow)
                }

            case .director:
                let directedCredits = try await service.searchDirector(query: trimmed)
                fetched = directedCredits.compactMap(ContentMapper.fromCrewCredit)
            case .genre:
                fetched = movies
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

    /// Loads genres from TMDB once (movie or tv depending on selectedType)
    func fetchGenresForSelectedType() async {
        guard !hasLoadedGenres else { return }

        do {
            switch selectedType {
            case .movie:
                allGenres = try await service.fetchMovieGenres()
            case .tv:
                allGenres = try await service.fetchTvGenres()
            }
            hasLoadedGenres = true
        } catch {
            print("Failed to fetch genres: \(error.localizedDescription)")
            errorMessage = "Failed to load genres."
        }
    }
}
