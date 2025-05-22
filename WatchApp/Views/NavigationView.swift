//
//  NavigationView.swift
//  WatchApp
//
//  Created by David Kalitzki on 2025-05-20.
//

import SwiftUI

struct NavigationView: View {
    
    @State private var selection = 2
    
    var body: some View {
        
        TabView(selection:$selection){
            VStack{
                Text("WatchList")
            }
            .tabItem{
                Image("pop_black_icon1x")
                Text("WatchList")
            }
            .tag(1)
            VStack{
                MovieListView(authVM: authVM)
                Text("")
            }
            .tabItem{
                Image("movies_black_1x")
                Text("Movies")
            }
            SavedMoviesView()
                .tabItem {
                    Label("Saved", systemImage: "bookmark.fill")
                }
            .tag(2)
            VStack{
                Text("Edit profile")
                
            }
            .tabItem{
                Image(systemName: "person.fill")
                Text("Profile")
            }
            .tag(3)
        }
    }
}

#Preview {
    NavigationView()
}
