//
//  SearchBarView.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-05-19.
//

import SwiftUI

struct SearchBarView: View {
    
    @Binding var text: String
    var filterType: FilterType
    var onSubmit: () -> Void
    
    var body: some View {
        ZStack(alignment: .trailing) {
            TextField(placeholder, text: $text)
                .foregroundColor(.white)
                .accentColor(.white)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.popcornYellow.opacity(0.5)))
                .onChange(of: text) { newValue in
                    if newValue.count > 35 {
                        text = String(newValue.prefix(35))
                    }
                }
                .onSubmit { onSubmit() }

            if !text.isEmpty {
                Button {
                    text = ""
                    onSubmit()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 10)
            }
        }
        .padding(.horizontal)
    }

    private var placeholder: String {
        switch filterType {
        case .title: return "Search by title..."
        case .genre: return "Filter by genre below"
        case .director: return "Search by director..."
        }
    }
}

#Preview("Title Search") {
    SearchBarView(
        text: .constant(""),
        filterType: .title,
        onSubmit: {}
    )
}

#Preview("Director Search") {
    SearchBarView(
        text: .constant("Christopher Nolan"),
        filterType: .director,
        onSubmit: {}
    )
}
