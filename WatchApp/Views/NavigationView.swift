//
//  NavigationView.swift
//  WatchApp
//
//  Created by David Kalitzki on 2025-05-20.
//

import SwiftUI

struct NavigationView: View {
    
    @State private var selection = 2
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        NavigationStack {
            TabView(selection:$selection) {
                VStack {
                    Text("POPular movies (coming soon...)")
                }
                .tabItem {
                    Image("pop_black_icon1x")
                    Text("POPular")
                }
                .tag(1)
                
                MovieListView()
                    .environmentObject(authVM)
                    .tabItem {
                        Image("movies_black_1x")
                        Text("Library")
                    }
                    .tag(2)
                
                SavedMoviesView()
                    .environmentObject(authVM)
                    .tabItem {
                        Label("Watchlist", systemImage: "bookmark.fill")
                    }
                    .tag(3)
                
            
                    ProfileView()
                        .environmentObject(authVM)
                        .tabItem {
                            Image(systemName: "person.fill")
                            Text("Profile")
                        }
                        .tag(4)
                }
                .onAppear() {
                    UITabBar.appearance().backgroundColor = .black
                    UITabBar.appearance().unselectedItemTintColor = .popcornYellow
                    UINavigationBar.appearance().barTintColor = UIColor(Color.BG)
                }
                .toolbar{
                    ToolbarItem(placement: .topBarLeading) {
                        Text(navigationTitle)
                            .foregroundStyle(.accent)
                            .font(.title)
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                            .padding(.top, 8)
                            .padding(.bottom, 16)
                    }
                }
                .withLogoutButton(authVM: authVM)
                .background(Color.BG.ignoresSafeArea(.all))
                
            }
        
    }
    
    private var navigationTitle: String {
        switch selection {
        case 1:
            return "🍿 POPular"
        case 2:
            return "🎬 Library"
        case 3:
            return "🎞️ Watchlist"
        case 4:
            return "🪞 Profile"
        default:
            return ""
        }
    }
}

#Preview {
    NavigationView()
        .environmentObject(AuthViewModel())
}
