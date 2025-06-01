//
//  DateFilterView.swift
//  WatchApp
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-01.
//

import SwiftUI

struct DateFilterView: View {

    @Binding var selectedDate: Date
    let onDateChanged: (Date) async -> Void

    var body: some View {

        VStack(spacing: 5) {

            DatePicker("Select Year", selection: $selectedDate, in: ...Date(), displayedComponents: .date)
                .datePickerStyle(.compact)
                .padding(.horizontal)
                .onChange(of: selectedDate) { newDate in
                    Task { await onDateChanged(newDate) }
                }

            Text("Showing results for year: \(Calendar.current.component(.year, from: selectedDate))")
                .font(.subheadline)
                .foregroundStyle(.popcornYellow)
                .padding(.top, 5)
        }
    }
}


#Preview {
    DateFilterView(selectedDate: .constant(Date()), onDateChanged: {_ in })
}
