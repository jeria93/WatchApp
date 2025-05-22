//
//  SearchBarView.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-05-19.
//

import SwiftUI

struct SearchBarView: View {
    
    @Binding var text: String
    var onSubmit: () -> Void
    
    var body: some View {
        
        ZStack(alignment: .trailing) {

            
            TextField("Search movies...", text: $text)
                .foregroundColor(.white)
                .accentColor(.white)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.gray.opacity(0.5)))
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
}

#Preview {
    SearchBarView(text: .constant(""), onSubmit: {})
}
