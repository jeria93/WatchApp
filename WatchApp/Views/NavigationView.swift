//
//  NavigationView.swift
//  WatchApp
//
//  Created by David Kalitzki on 2025-05-20.
//

import SwiftUI

struct NavigationView: View {
    
    @State private var selection = 2
    @StateObject private var authVM = AuthViewModel()
    
    var body: some View {
        TabView(selection:$selection) {
            VStack {
                Text("WatchList")
            }
            .tabItem {
                Image("pop_black_icon1x")
                Text("WatchList")
            }
            .tag(1)
            
            VStack {
                MovieListView(authVM: authVM)
                Text("")
                    .background(Color.black)
            }
            .tabItem {
                Image("movies_black_1x")
                Text("Movies")
            }
            .tag(2)
            
            SavedMoviesView()
                .tabItem {
                    Label("Saved", systemImage: "bookmark.fill")
                }
                .tag(3)
            
            VStack {
                Text("Edit profile")
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }
            .tag(4)
        }
        .onAppear() {
            UITabBar.appearance().backgroundColor = .black
            UITabBar.appearance().unselectedItemTintColor = .popcornYellow
        }
    }
}

#Preview {
    NavigationView()
}
