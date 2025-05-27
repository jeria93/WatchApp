//
//  ContentListView.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-05-20.
//

import SwiftUI

struct ContentListView: View {
    
    let movies: [Movie]
    let contentType: ContentType
    var onSave: ((Movie) -> Void)?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 15) {
                ForEach(movies) { movie in
                    MovieRow(
                        movie: movie,
                        onSave: onSave.map { save in { save(movie) } },
                        contentType: contentType
                    )
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentListView(
        movies: [Movie.preview,
                 Movie(
                    id: 2,
                    title: "The Matrix",
                    overview: "A computer hacker learns the truth about his past and the nature of reality as he navigates a labyrinth of virtual worlds",
                    posterPath: "/dXNAPwY7VrqMAo51EKhhCJfaGb5.jpg",
                    voteAverage: 9.9,
                    releaseDate: "1999-03-31",
                    genreIds: [28, 12, 878],
                    contentType: .movie
                 )],
        contentType: .movie,
        onSave: {_ in }
    )
}
