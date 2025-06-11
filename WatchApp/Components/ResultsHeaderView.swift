//
//  ResultsHeaderView.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-01.
//

import SwiftUI

struct ResultsHeaderView: View {

    let searchText: String
    let totalResults: Int

    var body: some View {
       HStack {
           Spacer()

            Text(headerText)
                .font(.subheadline)
                .foregroundColor(.popcornYellow)
            Spacer()
        }
       .padding(.top, 10)

    }

    private var headerText: String {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return "Trending now"
        } else {
            return "\(totalResults) results found"
        }
    }
}

#Preview {
    ResultsHeaderView(searchText: "", totalResults: 1)
}
