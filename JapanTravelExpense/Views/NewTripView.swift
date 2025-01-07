import SwiftUI
import SwiftData

struct NewTripView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var settings: [Settings]
    
    @State private var name = ""
    @State private var startDate = Date()
    @State private var endDate: Date?
    @State private var budget: Double?
    @State private var budgetCurrency: Currency = .twd
    @State private var notes = ""
    @State private var hasEndDate = false
    @State private var hasBudget = false
    
    private var currentSettings: Settings {
        settings.first ?? Settings()
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("旅行名稱", text: $name)
                }
                
                Section {
                    DatePicker("開始日期", selection: $startDate, displayedComponents: .date)
                    
                    Toggle("設定結束日期", isOn: $hasEndDate)
                    if hasEndDate {
                        DatePicker("結束日期", selection: Binding(
                            get: { endDate ?? startDate },
                            set: { endDate = $0 }
                        ), in: startDate..., displayedComponents: .date)
                    }
                }
                
                Section {
                    Toggle("設定預算", isOn: $hasBudget)
                    if hasBudget {
                        TextField("預算", value: $budget, format: .number)
                            .keyboardType(.decimalPad)
                        
                        Picker("預算貨幣", selection: $budgetCurrency) {
                            ForEach(Currency.allCases, id: \.self) { currency in
                                Text(currency.rawValue).tag(currency)
                            }
                        }
                    }
                }
                
                Section {
                    TextField("備註", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("新增旅行")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("新增") {
                        addTrip()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .onAppear {
                // 在視圖出現時設置預設貨幣
                budgetCurrency = currentSettings.defaultCurrency
            }
        }
    }
    
    private func addTrip() {
        let trip = Trip(
            name: name,
            startDate: startDate,
            endDate: hasEndDate ? endDate : nil,
            budget: hasBudget ? budget : nil,
            budgetCurrency: budgetCurrency.rawValue,
            notes: notes.isEmpty ? nil : notes
        )
        
        modelContext.insert(trip)
        try? modelContext.save()
    }
}

#Preview {
    NewTripView()
        .modelContainer(for: [Trip.self, Settings.self], inMemory: true)
}
