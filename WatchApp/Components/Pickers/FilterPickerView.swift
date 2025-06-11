//
//  FilterPickerView.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-01.
//

import SwiftUI

struct FilterPickerView: View {

    @Binding var selectedFilter: FilterType

    var body: some View {
        Picker("Filter", selection: $selectedFilter) {
            ForEach(FilterType.allCases) { filter in
                Text(filter.rawValue)
                    .tag(filter)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }
}

#Preview {
    VStack {
        Text("FilterPickerView Preview").font(.headline)
        FilterPickerView(selectedFilter: .constant(.title))
        FilterPickerView(selectedFilter: .constant(.genre))
        FilterPickerView(selectedFilter: .constant(.releaseDate))
    }.padding()
}
