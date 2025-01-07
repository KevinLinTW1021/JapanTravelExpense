//
//  TravelExpenseApp.swift
//  TravelExpense
//
//  Created by KevinLin on 2025/1/7.
//

import SwiftUI
import SwiftData

@main
struct TravelExpenseApp: App {
    let container: ModelContainer
    
    init() {
        do {
            let schema = Schema([
                Trip.self,
                Expense.self,
                Settings.self,
                ExchangeRate.self
            ])
            let modelConfiguration = ModelConfiguration(isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            // 確保有初始設置
            let context = container.mainContext
            let settingsRequest = FetchDescriptor<Settings>()
            let settings = try context.fetch(settingsRequest)
            if settings.isEmpty {
                let initialSettings = Settings()
                context.insert(initialSettings)
            }
            
            // 確保有初始匯率
            let rateRequest = FetchDescriptor<ExchangeRate>()
            let rates = try context.fetch(rateRequest)
            if rates.isEmpty {
                let initialRate = ExchangeRate()
                context.insert(initialRate)
            }
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            TripListView()
        }
        .modelContainer(container)
    }
}
