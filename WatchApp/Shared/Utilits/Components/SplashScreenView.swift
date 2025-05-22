//
//  SplashScreenView.swift
//  WatchApp
//
//  Created by Jonas Niyazson on 2025-05-19.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var logoScale: CGFloat = 0.0
    @State private var logoOpacity: Double = 0.0
  
    @State private var rectOffset: CGFloat = 750
    @State private var rectRotation: Double = 0.0
    @State private var rectOpacity: Double = 0.0


    var body: some View {
        ZStack {
            Color.BG.ignoresSafeArea()
          
          // MARK: - Animated Rectangle
          RedRectangleView(
            offset: rectOffset,
            rotation: rectRotation,
            opacity: rectOpacity
          )
          .onAppear {
            withAnimation(.easeOut(duration: 3.0)) {
              rectOffset = 0
              rectRotation = -50
              rectOpacity = 1.0
            }
          }

            // MARK: - Logo Animation
            VStack {
              Image("logo_stor")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 400)
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                .shadow(color: Color.gray.opacity(0.9), radius: 7, x: 0, y: 0)
                .onAppear {
                    withAnimation(.easeOut(duration: 3.0).delay(0.3)) {
                      logoScale = 1.0
                      logoOpacity = 1.0
                      SoundPlayer.play("intro")
                    }
                }
            }
        }
    }
}

// MARK: - PREVIEW
#Preview {
    SplashScreenView()
}
