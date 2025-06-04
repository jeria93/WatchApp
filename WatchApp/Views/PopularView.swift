//
//  PopularView.swift
//  WatchApp
//
//  Created by David Kalitzki on 2025-06-04.
//

import SwiftUI

struct PopularView: View {
    
    @State private var topFive: [Int: Double] = [:]
    
    let firestore = FirestoreMovieService()
    
    var body: some View {
        
        VStack {
            ForEach(topFive.sorted(by: {$0.value > $1.value}).prefix(10), id: \.key) {
                movieId, average in
                Text("MovieId: \(movieId), Average Rating: \(String(format: "%.1f", average))")
            }
        }
        .onAppear {
            firestore.fetchTopAverage { result in
            topFive = result }
        }
    }
}

#Preview {
    PopularView()
}
