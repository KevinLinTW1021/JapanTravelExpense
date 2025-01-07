import SwiftUI
import SwiftData

struct ExpenseRowView: View {
    let expense: Expense
    @Query private var settings: [Settings]
    @State private var showingEditSheet = false
    
    private var currentSettings: Settings {
        settings.first ?? Settings()
    }
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    
    private var amountText: String {
        if let currency = Currency(rawValue: expense.currency) {
            let defaultCurrency = currentSettings.defaultCurrency
            let amount = expense.amount
            
            if currency == defaultCurrency {
                return "\(numberFormatter.string(from: NSNumber(value: amount)) ?? "0") \(currency.symbol)"
            } else {
                let convertedAmount = CurrencyConverter.shared.convertSync(amount, from: currency, to: defaultCurrency)
                return "\(numberFormatter.string(from: NSNumber(value: amount)) ?? "0") \(currency.symbol) (\(numberFormatter.string(from: NSNumber(value: convertedAmount)) ?? "0") \(defaultCurrency.symbol))"
            }
        }
        return "\(expense.amount) \(expense.currency)"
    }
    
    var body: some View {
        Button {
            showingEditSheet = true
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(expense.category)
                        .font(.headline)
                    Text(expense.note)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    if let location = expense.location {
                        Text(location)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(amountText)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(expense.isIncome ? .green : .primary)
                    Text(expense.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingEditSheet) {
            EditExpenseView(expense: expense)
        }
    }
}

#Preview {
    ExpenseRowView(expense: Expense(
        amount: 1000,
        currency: Currency.jpy.rawValue,
        category: "食物",
        note: "午餐",
        date: Date(),
        isIncome: false,
        location: "東京"
    ))
    .modelContainer(for: [Expense.self, Settings.self], inMemory: true)
}
