import Foundation
import SwiftData

@MainActor
class CurrencyConverter {
    static let shared = CurrencyConverter()
    private var container: ModelContainer?
    
    private init() {
        do {
            let schema = Schema([
                Expense.self,
                Settings.self,
                ExchangeRate.self
            ])
            let modelConfiguration = ModelConfiguration(isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            print("Error creating ModelContainer: \(error)")
        }
    }
    
    // 同步版本的轉換方法
    func convertSync(_ amount: Double, from sourceCurrency: Currency, to targetCurrency: Currency) -> Double {
        if sourceCurrency == targetCurrency {
            return amount
        }
        
        // 目前只支援 JPY 和 TWD 之間的轉換
        switch (sourceCurrency, targetCurrency) {
        case (.jpy, .twd):
            // 使用最新匯率
            let descriptor = FetchDescriptor<ExchangeRate>(sortBy: [SortDescriptor(\.lastUpdated, order: .reverse)])
            let rates = try? container?.mainContext.fetch(descriptor)
            let rate = rates?.first?.rate ?? 0.22 // 使用默認匯率作為備用
            return amount * rate
            
        case (.twd, .jpy):
            let descriptor = FetchDescriptor<ExchangeRate>(sortBy: [SortDescriptor(\.lastUpdated, order: .reverse)])
            let rates = try? container?.mainContext.fetch(descriptor)
            let rate = rates?.first?.rate ?? 0.22
            return amount / rate
            
        default:
            // 其他貨幣轉換暫不支援，返回原值
            return amount
        }
    }
    
    // 異步版本的轉換方法
    func convert(_ amount: Double, from sourceCurrency: Currency, to targetCurrency: Currency) async -> Double {
        return convertSync(amount, from: sourceCurrency, to: targetCurrency)
    }
}
