import SwiftUI

struct MovieDetailView: View {

    @State var movie: Movie
    let contentType: ContentType
    let firestore = FirestoreMovieService()
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                AsyncImage(url: movie.posterURLSmall) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.gray.opacity(0.3))
                        .frame(width: 80, height: 120)
                        .overlay(Text("🍿"))
                }

                HStack(alignment: .lastTextBaseline) {
                    Text(movie.title)
                        .font(.title)
                        .foregroundColor(.white)

                    Text(contentType == .movie ? "🎬" : "📺")
                    if let releaseDate = movie.releaseDate {
                        let displayYear = String(releaseDate.prefix(4))
                        Text("(\(displayYear))")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }

                HStack {
                    Image("pop_white")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .opacity(movie.userRating >= 1 ? 1.0 : 0.2)
                        .onTapGesture {
                                setRating(id: movie.id, rating: 1)
                                fetchRating()
                        }
                    Image("pop_white")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .opacity(movie.userRating >= 2 ? 1.0 : 0.2)
                        .onTapGesture {
                            setRating(id: movie.id, rating: 2)
                            fetchRating()
                        }
                    Image("pop_white")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .opacity(movie.userRating >= 3 ? 1.0 : 0.2)
                        .onTapGesture {
                            setRating(id: movie.id, rating: 3)
                            fetchRating()
                        }
                    Image("pop_white")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .opacity(movie.userRating >= 4 ? 1.0 : 0.2)
                        .onTapGesture {
                            setRating(id: movie.id, rating: 4)
                            fetchRating()
                        }
                    Image("pop_white")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .opacity(movie.userRating >= 5 ? 1.0 : 0.2)
                        .onTapGesture {
                            setRating(id: movie.id, rating: 5)
                            fetchRating()
                        }
                    
                    Spacer()
                    
                    ShareButtonView(movie: movie)
                        .padding(.horizontal, 7)
                }

                Text(movie.overview)
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color.BG.ignoresSafeArea(.all))
        .onAppear {
            fetchRating()
        }
    }

    private func setRating(id: Int, rating: Int) {
        if !authVM.isAnonymous {
            if let userId = authVM.currentUserId {
                firestore.addSignedInUserRating(userId: userId, ratedMovieId: id, rating: rating)
                firestore.addRatingForAverage(userId: userId, ratedMovieId: id, rating: rating)
            }
        } else {
            print("Not signed in. Cant set rating")
            return
        }
    }

    func fetchRating() {
        if !authVM.isAnonymous {
            if let userId = authVM.currentUserId {
                firestore.fetchSignedInUserRating(userId: userId, ratedMovieId: movie.id) { rating in
                    if let rating = rating {
                        movie.userRating = rating
                    } else {
                        return
                    }
                }
            }
            } else {
                print("Not signed in. Cant fetch rating")
                return
            }
        }
}

#Preview {
    MovieDetailView(movie: .detailPreview, contentType: .movie)
}

extension Movie {
    static var detailPreview: Movie {
        Movie(
            id: 1,
            title: "Interstellar",
            overview: "Set in a dystopian future where Earth is suffering from catastrophic blight and famine, the film follows a group of astronauts who travel through a wormhole near Saturn in search of a new home for mankind.",
            posterPath: "/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg",
            voteAverage: 8.8,
            releaseDate: "2025-05-15",
            genreIds: [1],
            contentType: .movie,
            userRating: 3
        )
    }
}
