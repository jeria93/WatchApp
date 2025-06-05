//
//  ProfileImageView.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-05.
//

import SwiftUI

struct ProfileImageView: View {

    @EnvironmentObject var auth: AuthViewModel

    var body: some View {

        Group {
            if let urlString = auth.photoURL,
               let url = URL(string: urlString) {

                AsyncImage(url: url) { phase in
                    switch phase {

                    case .success(let img): img
                            .resizable()

                    default: ProgressView()

                    }
                }
            } else {
                Image(systemName: "photo.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .background{
                        Circle()
                            .fill(Color(.systemGray6))
                            .frame(width: 128, height: 128)
                            .shadow(radius: 10)
                    }
            }
        }
        .frame(width: 60, height: 60)
        .clipShape(Circle())
        .shadow(radius: 3)
    }
}

#Preview {
    ProfileImageView()
        .environmentObject(AuthViewModel())
}
