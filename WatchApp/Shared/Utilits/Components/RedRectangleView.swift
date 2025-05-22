//
//  RedRectangleView.swift
//  WatchApp
//
//  Created by Jonas Niyazson on 2025-05-19.
//

import SwiftUI

struct RedRectangleView: View {
    var offset: CGFloat
    var rotation: Double
    var opacity: Double

    var body: some View {
      Rectangle()
        .fill(Color.accentColor)
        .frame(width: 700, height: 80)
        .rotationEffect(.degrees(rotation))
        .opacity(opacity)
        .offset(x: offset, y: 0)
        .position(x: 250, y: 750)
    }
}

#Preview {
    RedRectangleView(
      offset: 0,
      rotation: -45,
      opacity: 1.0
    )
    .background(Color.black)
}
