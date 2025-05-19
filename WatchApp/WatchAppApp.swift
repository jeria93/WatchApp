//
//  WatchAppApp.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-05-12.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}


@main
struct WatchAppApp: App {
    
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
          Group {
            if showSplash {
              SplashScreenView()
                .onAppear {
                  DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
                      showSplash = false
                  }
                }
            } else {
                ContentView()
            }
          }
        }
    }
}
