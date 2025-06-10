//
//  RandomPickerView.swift
//  WatchApp
//
//  Created by Frida Eriksson on 2025-06-04.
//

import SwiftUI

struct RandomPickerView: View {
    let movies: [Movie]
    let onSelect: (Movie) -> Void
    let onCancel: () -> Void
    
    @State private var displayedMovie: Movie?
    @State private var isAnimating = false
    @State private var animationCompleted = false
    @State private var flipCount = 0
    
    private var unwatchedMovies: [Movie] {
        movies.filter { !$0.isWatched }
    }
    
    var body: some View {
        ZStack {
            Color.BG.ignoresSafeArea()
                .onTapGesture { onCancel () }
            
            VStack {
                Text("Your Random Pick!")
                    .foregroundStyle(.popcornYellow)
                    .font(.title2)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .padding(.top)
                
                ZStack{
                    if let movie = displayedMovie {
                        AsyncImage(url: movie.posterURLLarge) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 200, height: 300)
                                .clipShape(RoundedRectangle(cornerRadius: 55))
                                .overlay(RoundedRectangle(cornerRadius: 55)
                                    .stroke(Color.BG, lineWidth: 1))
                                .rotation3DEffect(.degrees(isAnimating ? 360 : 0), axis: (x: 0, y: 1, z: 0))
                                .offset(y: -20)
                                .zIndex(0)
                                .padding(.top, 90)
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 55)
                                .fill(.gray.opacity(0.3))
                                .frame(width: 200, height: 300)
                                .overlay(Text(movie.contentType == .movie ? "🎬" : "📺"))
                                .overlay(RoundedRectangle(cornerRadius: 55)
                                    .stroke(Color.BG, lineWidth: 1))
                                .offset(y: -20)
                                .zIndex(0)
                                .padding(.top, 90)
                        }
                    } else{
                        Text(unwatchedMovies.isEmpty ? "No unwatched\nmovies available" : "No movies available")
                            .foregroundStyle(.red)
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .zIndex(0)
                    }
                    
                        Image("popbox_white")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 400)
                            .opacity(0.9)
                            .zIndex(1)
                }
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimating)
                
                if let movie = displayedMovie {
                    Text(movie.title)
                        .foregroundStyle(.white)
                        .font(.title2)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .frame(width: 200)
                        .padding(.top, 10)
                }
                
                VStack{
                    if !animationCompleted {
                        Button(action: onCancel) {
                            Text("Cancel")
                                .foregroundStyle(.accent)
                                .padding()
                                .background(Color.gray.opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    
                    if animationCompleted {
                            Button(action: {
                                onSelect(displayedMovie!)
                                displayedMovie = nil
                                animationCompleted = false
                            }) {
                                Text("Watch this!👆🏽")
                                    .foregroundStyle(.popcornYellow)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding()
                                    .background(Color.BG)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .disabled(displayedMovie == nil)
                            
                            Button(action: { startAnimation() }) {
                                Text("Pick Again")
                                    .foregroundStyle(.white)
                                    .padding()
                                    .background(Color.gray.opacity(0.5))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                    }
                }
                .padding(.top)
            }
            .padding()
        }
        .onAppear { startAnimation() }
    }
    
    private func startAnimation() {
        guard !unwatchedMovies.isEmpty else {
            displayedMovie = nil
            animationCompleted = true
            return
        }
        
        isAnimating = true
        flipCount = 0
        animationCompleted = false
        
        let flipDuration = 0.2
        let maxFlips = Int.random(in: 8...12)
        
        func flipNext() {
            guard flipCount < maxFlips else {
                displayedMovie = unwatchedMovies.randomElement()
                isAnimating = false
                animationCompleted = true
                return
            }
            
            withAnimation(.linear(duration: flipDuration)) {
                displayedMovie = unwatchedMovies.randomElement()
                flipCount += 1
                isAnimating.toggle()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + flipDuration) {
                flipNext()
            }
        }
        flipNext()
    }
}

#Preview {
    let mockMovies = [
        Movie(
            id: 1,
            title: "Inception",
            overview: "A thief who steals secrets through dreams...",
            posterPath: "/inception.jpg",
            voteAverage: 8.8,
            releaseDate: "2010-07-16",
            genreIds: [878, 28],
            contentType: .movie,
            userRating: 4,
            isWatched: false,
            isSaved: true,
        ),
        Movie(
            id: 2,
            title: "The Matrix",
            overview: "A hacker learns about reality...",
            posterPath: "/matrix.jpg",
            voteAverage: 8.7,
            releaseDate: "1999-03-31",
            genreIds: [28, 878],
            contentType: .movie,
            userRating: 5,
            isWatched: true,
            isSaved: true
        ),
        Movie(
            id: 3,
            title: "Breaking Bad",
            overview: "A chemistry teacher turns to crime...",
            posterPath: "/breakingbad.jpg",
            voteAverage: 9.5,
            releaseDate: "2008-01-20",
            genreIds: [18],
            contentType: .tv,
            userRating: 3,
            isWatched: false,
            isSaved: true,
        )
    ]
    
    RandomPickerView(
        movies: mockMovies,
        onSelect: { movie in
            print("Selected movie: \(movie.title)")
        },
        onCancel: {
            print("Cancelled")
        }
    )
}
