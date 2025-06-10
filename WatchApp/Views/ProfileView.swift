//
//  ProfileView.swift
//  WatchApp
//
//  Created by Frida Eriksson on 2025-05-27.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var firestoreVM = FirestoreViewModel()
    @State private var showEditEmail = false
    @State private var showEditUsername = false
    @State private var showDeleteAccount = false
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var selectedMovie: Movie?

    var body: some View {
        ZStack {
            Color.BG
                .ignoresSafeArea(.all)

            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .center, spacing: 10) {
                        Text(authVM.currentUsername ?? "🤷")
                            .foregroundStyle(.white)
                            .fontDesign(.rounded)
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top, 85)

                        Spacer()

                        ZStack(alignment: .topTrailing) {
                            if authVM.isGoogleUser, let photoURL = authVM.photoURL, let url = URL(string: photoURL) {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                } placeholder: {
                                    Circle()
                                        .fill(.gray)
                                        .frame(width: 120, height: 120)
                                        .overlay(Text("🤷‍♂️"))
                                }
                            } else if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                            } else {
                                ProfileImageView()
                            }

                            if !authVM.isGoogleUser {
                                Button {
                                    showImagePicker = true
                                } label: {
                                    Image(systemName: "pencil")
                                        .imageScale(.small)
                                        .foregroundStyle(.red)
                                        .background {
                                            Circle()
                                                .fill(.white)
                                                .frame(width: 32, height: 32)
                                        }
                                }
                                .offset(x: -8, y: 10)
                            }
                        }
                        .sheet(isPresented: $showImagePicker) {
                            ImagePicker(selectedImage: $selectedImage)
                        }
                    }
                    .padding(.horizontal, 35)
                    .padding(.bottom, 20)

                    VStack(alignment: .leading, spacing: 10) {
                        Button(action: { showEditUsername = true }) {
                            profileItem(icon: "person", title: "Username", value: authVM.currentUsername ?? "No user")
                        }

                        Button(action: { showEditEmail = true }) {
                            profileItem(icon: "envelope", title: "Email", value: authVM.user?.email ?? "No user")
                        }
                    }
                    .padding(.horizontal)


                    TopRatedMoviesListView(movies: firestoreVM.topRatedMovies, selectedMovie: $selectedMovie)
                        .frame(maxWidth: .infinity)

                    HStack {
                        Spacer()
                        Button(action: { showDeleteAccount = true }) {
                            HStack {
                                Image(systemName: "trash")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundStyle(.red)
                                Text("Delete Account")
                                    .foregroundStyle(.red)
                            }
                            .padding()
                        }
                        Spacer()
                    }
                }
                .padding(.top, 44)
            }
            .background(Color.BG)

            if showEditEmail {
                overlayView {
                    EditEmailView(newEmail: authVM.user?.email ?? "", showModal: $showEditEmail)
                        .environmentObject(authVM)
                }
            }

            if showEditUsername {
                overlayView {
                    EditUsernameView(
                        username: Binding(get: { authVM.currentUsername }, set: { authVM.currentUsername = $0 }),
                        showModal: $showEditUsername
                    )
                    .environmentObject(authVM)
                }
            }

            if showDeleteAccount {
                overlayView {
                    DeleteAccountView(showModal: $showDeleteAccount)
                        .environmentObject(authVM)
                }
            }
        }
        .sheet(item: $selectedMovie) { movie in
            MovieDetailView(movie: movie, contentType: .movie)
                .environmentObject(authVM)
                .onDisappear {
                    firestoreVM.fetchTopRatedMovies()
                }
        }
        .onAppear {
            firestoreVM.fetchTopRatedMovies()
            if !authVM.isGoogleUser {
                selectedImage = loadSavedImage()
            }
        }
    }

    private func profileItem(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .resizable()
                .frame(width: 40, height: icon == "person" ? 40 : 30)
                .foregroundStyle(.white)
                .padding(.horizontal)
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
                Text(value)
                    .foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.primary)
        .cornerRadius(10)
    }

    private func overlayView<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        Color.black.opacity(0.4)
            .ignoresSafeArea()
            .onTapGesture { withAnimation { showEditEmail = false; showEditUsername = false; showDeleteAccount = false } }
            .overlay(content().transition(.scale))
    }

    private func loadSavedImage() -> UIImage? {
        let filename = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("selected_image.jpg")
        if let data = try? Data(contentsOf: filename) {
            return UIImage(data: data)
        }
        return nil
    }
}

// MARK: - TopRatedMoviesListView
struct TopRatedMoviesListView: View {
    let movies: [Movie]
    @Binding var selectedMovie: Movie?

    var body: some View {
        ZStack {
            Image("popbox_white")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .opacity(0.8)
                .padding(.top, 10)

            VStack(spacing: 16) {
                Text("Your Top 5")
                    .foregroundStyle(.popcornYellow)
                    .font(.title2)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .padding(.top, 94)

                if movies.isEmpty {
                    Text("No rated movies yet")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .padding(.vertical, 40)
                } else {
                    ForEach(0..<min(movies.count, 5), id: \.self) { index in
                        HStack(spacing: 16) {
                            MovieItemView(movie: movies[index], selectedMovie: $selectedMovie)
                            if index % 2 == 0 && index + 1 < movies.count {
                                MovieItemView(movie: movies[index + 1], selectedMovie: $selectedMovie)
                            } else {
                                Spacer()
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.bottom, 5)
        }
    }
}

// MARK: - MovieItemView
struct MovieItemView: View {
    let movie: Movie
    @Binding var selectedMovie: Movie?

    var body: some View {
        VStack(spacing: 4) {
            AsyncImage(url: movie.posterURLSmall) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.popcornYellow, lineWidth: 1))
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.gray.opacity(0.3))
                    .frame(width: 80, height: 100)
                    .overlay(Text("🍿"))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.popcornYellow, lineWidth: 1))
            }

            Text(movie.title)
                .font(.caption)
                .foregroundStyle(.white)
                .lineLimit(1)
                .frame(maxWidth: 90)
            Text("\(movie.userRating)/5")
                .font(.caption2)
                .foregroundStyle(.popcornYellow)
        }
        .onTapGesture {
            selectedMovie = movie
        }
    }
}

// MARK: - EditUsernameView
struct EditUsernameView: View {
    @Binding var username: String?
    @EnvironmentObject var authVM: AuthViewModel
    @Binding var showModal: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("Edit Username")
                .font(.title2)
                .foregroundStyle(.popcornYellow)
                .fontWeight(.bold)

            Divider()

            TextField("Username", text: Binding(get: { username ?? "" },
                                                set: { username = $0.isEmpty ? nil : $0 }))
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            .foregroundStyle(.black)

            HStack {
                Button("Cancel") {
                    withAnimation { showModal = false }
                }
                Button("Save") {
                    authVM.updateUsername(newUsername: username ?? "") { success in
                        if success { withAnimation { showModal = false } }
                    }
                }
                .padding(.horizontal)
                .background(.BG)
                .foregroundStyle(.popcornYellow)
                .cornerRadius(20)
                .fontWeight(.semibold)
            }
        }
        .frame(height: 300)
        .background(.black)
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding()
    }
}

// MARK: - EditEmailView
struct EditEmailView: View {
    @State var newEmail: String
    @EnvironmentObject var authVM: AuthViewModel
    @Binding var showModal: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("Edit Email")
                .font(.title2)
                .foregroundStyle(.popcornYellow)
                .fontWeight(.bold)

            TextField("Email", text: $newEmail)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .textContentType(.emailAddress)
                .autocapitalization(.none)

            if let successMessage = authVM.successMessage {
                Text(successMessage)
                    .foregroundStyle(.green)
                    .padding()
            }

            if let errorMessage = authVM.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .padding()
            }

            HStack {
                Button("Cancel") {
                    withAnimation { showModal = false }
                }
                Button("Save") {
                    authVM.updateEmail(newEmail: newEmail) { _ in }
                }
                .padding(.horizontal)
                .background(.BG)
                .foregroundStyle(.popcornYellow)
                .cornerRadius(20)
                .fontWeight(.semibold)
            }
        }
        .frame(height: 300)
        .background(.black)
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding()
    }
}

// MARK: - DeleteAccountView
struct DeleteAccountView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Binding var showModal: Bool
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showReauthentication: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Delete Account")
                .font(.title2)
                .foregroundStyle(.popcornYellow)
                .fontWeight(.bold)

            if showReauthentication {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .textContentType(.password)
            } else {
                Text("Are you sure you want to delete your account? This action cannot be undone.")
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding()
            }

            if let successMessage = authVM.successMessage {
                Text(successMessage)
                    .foregroundStyle(.green)
                    .padding()
            }

            if let errorMessage = authVM.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .padding()
            }

            HStack {
                Button("Cancel") {
                    withAnimation { showModal = false }
                }
                .padding(.horizontal)
                .background(.BG)
                .foregroundStyle(.popcornYellow)
                .cornerRadius(20)
                .fontWeight(.semibold)

                Button("Delete") {
                    if showReauthentication {
                        authVM.deleteAccount(email: email, password: password) { success in
                            if success { withAnimation { showModal = false } }
                        }
                    } else {
                        authVM.deleteAccount { success in
                            if !success, authVM.errorMessage?.contains("recent login") ?? false {
                                showReauthentication = true
                            } else if success {
                                withAnimation { showModal = false }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .foregroundStyle(.red)
                .fontWeight(.bold)
            }
        }
        .frame(height: 300)
        .background(.black)
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding()
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
