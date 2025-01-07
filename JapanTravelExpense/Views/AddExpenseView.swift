import SwiftUI
import SwiftData

struct AddExpenseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var settings: [Settings]
    
    let trip: Trip
    @State private var amount = 0.0
    @State private var currency: Currency
    @State private var category = ""
    @State private var note = ""
    @State private var date = Date()
    @State private var isIncome = false
    @State private var location = ""
    
    private var currentSettings: Settings {
        settings.first ?? Settings()
    }
    
    init(trip: Trip) {
        self.trip = trip
        _currency = State(initialValue: Currency(rawValue: trip.budgetCurrency) ?? .twd)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("日期", selection: $date, displayedComponents: .date)
                }
                
                Section {
                    HStack {
                        Text(currency.symbol)
                        TextField("金額", value: $amount, format: .number)
                            .keyboardType(.decimalPad)
                    }
                    
                    Picker("貨幣", selection: $currency) {
                        ForEach(Currency.allCases, id: \.self) { currency in
                            Text(currency.rawValue).tag(currency)
                        }
                    }
                }
                
                Section {
                    TextField("類別", text: $category)
                    TextField("備註", text: $note)
                    TextField("地點", text: $location)
                }
                
                Section {
                    Toggle("收入", isOn: $isIncome)
                }
            }
            .navigationTitle(isIncome ? "新增收入" : "新增支出")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("新增") {
                        addExpense()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addExpense() {
        let expense = Expense(
            amount: amount,
            currency: currency.rawValue,
            category: category,
            note: note,
            date: date,
            isIncome: isIncome,
            location: location.isEmpty ? nil : location
        )
        
        trip.expenses.append(expense)
        modelContext.insert(expense)
        try? modelContext.save()
    }
}

#Preview {
    AddExpenseView(trip: Trip(name: "日本東京行", budget: 100000))
        .modelContainer(for: [Trip.self, Expense.self, Settings.self], inMemory: true)
}
