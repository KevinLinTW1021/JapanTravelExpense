import SwiftUI
import SwiftData

struct EditExpenseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var settings: [Settings]
    
    let expense: Expense
    @State private var amount: Double
    @State private var currency: Currency
    @State private var category: String
    @State private var note: String
    @State private var date: Date
    @State private var isIncome: Bool
    @State private var location: String
    @State private var showDeleteAlert = false
    
    private var currentSettings: Settings {
        settings.first ?? Settings()
    }
    
    init(expense: Expense) {
        self.expense = expense
        _amount = State(initialValue: expense.amount)
        _currency = State(initialValue: Currency(rawValue: expense.currency) ?? .twd)
        _category = State(initialValue: expense.category)
        _note = State(initialValue: expense.note)
        _date = State(initialValue: expense.date)
        _isIncome = State(initialValue: expense.isIncome)
        _location = State(initialValue: expense.location ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("日期", selection: $date, displayedComponents: .date)
                }
                
                Section {
                    TextField("金額", value: $amount, format: .number)
                        .keyboardType(.decimalPad)
                    
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
                
                Section {
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("刪除")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("編輯支出")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("儲存") {
                        saveChanges()
                        dismiss()
                    }
                }
            }
            .alert("確定要刪除嗎？", isPresented: $showDeleteAlert) {
                Button("取消", role: .cancel) { }
                Button("刪除", role: .destructive) {
                    deleteExpense()
                    dismiss()
                }
            } message: {
                Text("此操作無法復原")
            }
        }
    }
    
    private func saveChanges() {
        expense.amount = amount
        expense.currency = currency.rawValue
        expense.category = category
        expense.note = note
        expense.date = date
        expense.isIncome = isIncome
        expense.location = location.isEmpty ? nil : location
        
        try? modelContext.save()
    }
    
    private func deleteExpense() {
        modelContext.delete(expense)
        try? modelContext.save()
    }
}

#Preview {
    EditExpenseView(expense: Expense(
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
