import SwiftUI
import SwiftData
import Foundation
import UIKit

struct ExpenseListView: View {
    let trip: Trip
    @Environment(\.modelContext) private var modelContext
    @State private var settings: [Settings] = []
    @State private var showingAddExpense = false
    @State private var searchText = ""
    
    private var currentSettings: Settings {
        settings.first ?? Settings()
    }
    
    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter
    }
    
    private var filteredExpenses: [Expense] {
        if searchText.isEmpty {
            return trip.expenses.sorted { $0.date > $1.date }
        }
        
        return trip.expenses.filter { expense in
            let categoryMatch = expense.category.localizedCaseInsensitiveContains(searchText)
            let noteMatch = expense.note.localizedCaseInsensitiveContains(searchText)
            return categoryMatch || noteMatch
        }.sorted { $0.date > $1.date }
    }
    
    // 計算總支出（包括收入和支出）
    private var totalExpenses: Double {
        let tripCurrency = Currency(rawValue: trip.budgetCurrency) ?? currentSettings.defaultCurrency
        
        return trip.expenses.reduce(0) { total, expense in
            if let expenseCurrency = Currency(rawValue: expense.currency) {
                let amount = expense.isIncome ? expense.amount : -expense.amount
                if expenseCurrency == tripCurrency {
                    return total + amount
                } else {
                    return total + CurrencyConverter.shared.convertSync(
                        amount,
                        from: expenseCurrency,
                        to: tripCurrency
                    )
                }
            }
            return total
        }
    }
    
    // 計算餘額（預算 + 總支出）
    private var balance: Double {
        let budget = trip.budget ?? 0
        return budget + totalExpenses
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let tripCurrency = Currency(rawValue: trip.budgetCurrency) ?? currentSettings.defaultCurrency
        return "\(numberFormatter.string(from: NSNumber(value: abs(amount))) ?? "0") \(tripCurrency.symbol)"
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // 顯示預算和餘額
                VStack(spacing: 16) {
                    if trip.budget != nil {
                        Text("餘額")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(formatAmount(balance))
                            .font(.system(.title2, design: .rounded, weight: .bold))
                            .foregroundColor(balance >= 0 ? .primary : .red)
                    } else {
                        Text("總支出")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(formatAmount(-totalExpenses))
                            .font(.system(.title2, design: .rounded, weight: .bold))
                            .foregroundColor(totalExpenses <= 0 ? .primary : .red)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color(uiColor: .secondarySystemBackground))
                
                // 預算進度條
                if trip.budget != nil {
                    let progress = totalExpenses / (trip.budget ?? 0)
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("預算")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(numberFormatter.string(from: NSNumber(value: trip.budget ?? 0)) ?? "0") \(Currency(rawValue: trip.budgetCurrency)?.symbol ?? "")")
                                .font(.system(.headline, design: .rounded))
                        }
                        
                        HStack {
                            Text("已支出")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(numberFormatter.string(from: NSNumber(value: -totalExpenses)) ?? "0") \(Currency(rawValue: trip.budgetCurrency)?.symbol ?? "")")
                                .foregroundColor(progress >= 0.9 ? .red : .primary)
                        }
                        .font(.subheadline)
                        
                        ProgressView(value: min(max(0, -progress), 1.0))
                            .tint(-progress >= 0.9 ? .red : (-progress >= 0.75 ? .orange : .blue))
                        
                        Text("\(Int(min(max(0, -progress), 1.0) * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemBackground))
                }
                
                // 支出列表
                LazyVStack(spacing: 0) {
                    ForEach(filteredExpenses) { expense in
                        ExpenseRowView(expense: expense)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color(uiColor: .systemBackground))
                        Divider()
                    }
                    .onDelete(perform: deleteItems)
                }
            }
        }
        .navigationTitle(trip.name)
        .searchable(text: $searchText, prompt: "搜尋支出...")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddExpense = true }) {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    SettingsView()
                } label: {
                    Image(systemName: "gear")
                }
            }
        }
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView(trip: trip)
        }
        .task {
            do {
                let descriptor = FetchDescriptor<Settings>()
                settings = try modelContext.fetch(descriptor)
            } catch {
                print("Failed to fetch settings: \(error)")
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let expense = filteredExpenses[index]
                trip.expenses.removeAll { $0.id == expense.id }
                modelContext.delete(expense)
            }
            try? modelContext.save()
        }
    }
}

#Preview {
    NavigationStack {
        ExpenseListView(trip: Trip(name: "日本東京行", budget: 100000))
    }
    .modelContainer(for: [Trip.self, Expense.self, Settings.self], inMemory: true)
}
