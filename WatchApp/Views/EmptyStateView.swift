//
//  EmptyStateView.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-05-19.
//

import SwiftUI

struct EmptyStateView: View {
    
    let searchText: String
    
    var body: some View {
        
        VStack(spacing: 12) {
            Image(systemName: "film")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.4))
            
            Text(message)
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
    }
    
    private var message: String {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return "No trending movies at the moment."
        } else {
            return "No results for “\(searchText)”"
        }
    }
}

#Preview("No search results") {
    EmptyStateView(searchText: "Batman")
}

#Preview("No trending movies") {
    EmptyStateView(searchText: "")
}
