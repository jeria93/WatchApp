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
    
    private let service = TMDBService()
    
    func fetchTrendingMovies() async {
        isLoading = true
        errorMessage = nil
        do {
            let fetchedMovies = try await service.fetchTrendingMovies()
            movies = fetchedMovies
        } catch {
            errorMessage = "Failed to load movies: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
}
