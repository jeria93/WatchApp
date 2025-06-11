//
//  MovieShareItem.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-02.
//

import Foundation
import UIKit

struct MovieShareItem: Identifiable {
    var id = UUID()
    let title: String
    let url: URL
    let image: UIImage
}
