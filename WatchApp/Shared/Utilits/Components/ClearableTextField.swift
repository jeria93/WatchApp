//
//  ClearableTextField.swift
//  WatchApp
//
//  Created by Jonas Niyazson on 2025-05-20.
//

import SwiftUI

struct ClearableTextField: View {
    let title: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .never
    var validate: ((String) -> String?)? = nil
    
    @State private var internalError: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            ZStack(alignment: .trailing) {
                Group {
                    if isSecure {
                        SecureField(title, text: $text)
                    } else {
                          TextField(title, text: $text)
                            .keyboardType(keyboardType)
                            .textInputAutocapitalization(autocapitalization)
                    }
                }
                .frame(height: 50)
                .textFieldStyle(.roundedBorder)
                .foregroundColor(.gold)
                .onChange(of: text) { newValue in
                    if let validate = validate {
                        internalError = validate(newValue)
                    }
                }

                if !text.isEmpty {
                    Button(action: {
                        text = ""
                        internalError = nil
                    }) {
                        Image(systemName: "xmark.circle")
                            .foregroundStyle(.gold)
                            .padding(.trailing, 8)
                    }
                }
            }

            if let error = internalError, !error.isEmpty {
              Text(error)
                  .foregroundColor(.red)
                  .font(.caption)
                  .padding(.leading, 4)
            }
        }
    }
}
