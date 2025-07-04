//
//  ContentTypePickerView.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-05-26.
//

import SwiftUI

struct ContentTypePickerView: View {

    @Binding var selectedType: ContentType

    var body: some View {
        Picker("Type", selection: $selectedType) {
            ForEach(ContentType.allCases) { type in
                Text(type.rawValue)
                    .tag(type)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }
}

#Preview("Movie Picker Preview") {
    ContentTypePickerView(
        selectedType: .constant(.movie)
    )
}

#Preview("TV Picker Preview") {
    ContentTypePickerView(
        selectedType: .constant(.tv)
    )
}
