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

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
