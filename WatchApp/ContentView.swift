//
//  ContentView.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-05-12.
//

import SwiftUI

struct ContentView: View {
    
    @State private var showSplash = true
    @StateObject private var authVM = AuthViewModel()
    
    var body: some View {
        Group {
          if showSplash {
            SplashScreenView()
              .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
                    showSplash = false
                }
              }
          } else if authVM.isSignedIn {
              NavigationView()
                  .environmentObject(authVM)
          } else {
              LoginView()
                  .environmentObject(authVM)
          }
        }
    }
}

#Preview {
    ContentView()
}
