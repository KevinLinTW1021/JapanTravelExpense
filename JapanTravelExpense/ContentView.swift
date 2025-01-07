//
//  ContentView.swift
//  JapanTravelExpense
//
//  Created by KevinLin on 2025/1/7.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TripListView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Trip.self, Expense.self, Settings.self, ExchangeRate.self], inMemory: true)
}
