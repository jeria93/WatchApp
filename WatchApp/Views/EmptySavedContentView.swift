//
//  EmptySavedContentView.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-05-21.
//

import SwiftUI

struct EmptySavedContentView: View {
    
    let selectedType: ContentType
    private var message: String {
        switch selectedType {
        case .movie:
            return "You haven't saved any movies yet\nSave some movies to your watch"
        case .tv:
            return "You haven't saved any TV shows yet\nSave some shows to your watch"
        }
    }
    
    var body: some View {
        
        VStack(spacing: 10) {
            Image(systemName: selectedType == .movie ? "film" : "tv")
                .font(.system(size: 60))
                .foregroundStyle(.gray.opacity(0.3))
            
            Text(message)
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            
            
        }
        .padding(.top, 80)
        .padding(.horizontal)
    }
}

#Preview("Empty Movies") {
    EmptySavedContentView(selectedType: .movie)
}

#Preview("Empty TV Shows") {
    EmptySavedContentView(selectedType: .tv)
}
