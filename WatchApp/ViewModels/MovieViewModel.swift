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
    @Published var selectedGenre: Genre?
    @Published var allGenres: [Genre] = []

    private var hasLoadedGenres = false
    private let service = TMDBService()

    @Published var selectedType: ContentType = .movie {
        didSet {
            Task { await handleSelectedTypeChange() }
        }
    }

    @Published var selectedFilter: FilterType = .title {
        didSet {
            Task { await handleSelectedFilterChange() }
        }
    }

    var filteredMovies: [Movie] {
        guard let selectedGenre else { return movies }
        return movies.filter { $0.genreIds.contains(selectedGenre.id) }
    }

    /// Handles changes to the selected content type (e.g., movie or TV show).
    /// Triggers a new search based on the updated selection.
    private func handleSelectedTypeChange() async {
        await onSearchTrigger()
    }

    /// Handles changes to the selected filter type (e.g., title, genre, director).
    /// Resets the appropriate search fields and fetches trending content.
    private func handleSelectedFilterChange() async {
        if selectedFilter == .genre {
            searchText = ""
        } else {
            selectedGenre = nil
        }
        await fetchTrendingContent()
    }

    /// Determines whether to search or fetch trending content based on search text.
    func onSearchTrigger() async {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            await fetchTrendingContent()
        } else {
            await searchContent()
        }
    }

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

    /// Searches for content based on the selected filter and search text.
    func searchContent() async {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            await fetchTrendingContent()
            return
        }

        movies = []
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
                switch selectedType {
                case .movie:
                    fetched = directedCredits.compactMap(ContentMapper.fromCrewCreditMovie)
                case .tv:
                    fetched = directedCredits.compactMap(ContentMapper.fromCrewCreditTV)
                }

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
