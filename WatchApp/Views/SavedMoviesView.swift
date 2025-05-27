//
//  SavedMoviesView.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-05-20.
//

import SwiftUI

struct SavedMoviesView: View {
    @StateObject private var viewModel = FirestoreViewModel()
    @State private var selectedType: ContentType = .movie
    
    var body: some View {
    
            VStack {
                Picker("Type", selection: $selectedType) {
                    ForEach(ContentType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                Group {
                    if let error = viewModel.errorMessage {
                        ErrorView(message: error)
                    } else {
                        let filtered = viewModel.movies.filter { $0.contentType == selectedType }
                        if filtered.isEmpty {
                           EmptySavedContentView(selectedType: selectedType)
                        } else {
                            ContentListView(movies: filtered, contentType: selectedType)
                        }
                    }
                }
                
                Spacer()
            }
            .task { await viewModel.fetchMovies() }
            .background(Color.BG.ignoresSafeArea(.all))
        
    }
}

#Preview {
    SavedMoviesView()
        .environmentObject(AuthViewModel())
}
