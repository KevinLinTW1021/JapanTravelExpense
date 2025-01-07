import SwiftUI
import SwiftData

struct ExpenseStatsView: View {
    @Query private var expenses: [Expense]
    @Query private var exchangeRates: [ExchangeRate]
    
    private var currentRate: ExchangeRate {
        exchangeRates.first ?? ExchangeRate()
    }
    
    private var totalExpense: Double {
        expenses.filter { !$0.isIncome }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var totalIncome: Double {
        expenses.filter { $0.isIncome }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var categoryStats: [(String, Double)] {
        Dictionary(grouping: expenses.filter { !$0.isIncome }) { $0.category }
            .mapValues { expenses in
                expenses.reduce(0) { $0 + $1.amount }
            }
            .sorted { $0.value > $1.value }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // 總計區域
            HStack(spacing: 20) {
                StatCardView(
                    title: "總支出",
                    amount: totalExpense,
                    amountTWD: currentRate.jpyToTwd(totalExpense),
                    color: .red
                )
                
                StatCardView(
                    title: "總收入",
                    amount: totalIncome,
                    amountTWD: currentRate.jpyToTwd(totalIncome),
                    color: .green
                )
            }
            
            // 分類統計
            VStack(alignment: .leading, spacing: 8) {
                Text("支出分類")
                    .font(.headline)
                
                ForEach(categoryStats.prefix(5), id: \.0) { category, amount in
                    CategoryRowView(
                        category: category,
                        amount: amount,
                        total: totalExpense
                    )
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(radius: 2)
        }
        .padding()
    }
}

// 統計卡片視圖
struct StatCardView: View {
    let title: String
    let amount: Double
    let amountTWD: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("¥\(Int(amount))")
                .font(.title2)
                .foregroundColor(color)
            
            Text("NT$\(Int(amountTWD))")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

// 分類統計行視圖
struct CategoryRowView: View {
    let category: String
    let amount: Double
    let total: Double
    
    private var percentage: Double {
        guard total > 0 else { return 0 }
        return (amount / total) * 100
    }
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Image(systemName: ExpenseCategory(rawValue: category)?.iconName ?? "circle")
                Text(category)
                Spacer()
                Text("¥\(Int(amount))")
                    .foregroundColor(.gray)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                    
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * CGFloat(percentage / 100))
                }
            }
            .frame(height: 4)
            .cornerRadius(2)
        }
    }
}

#Preview {
    ExpenseStatsView()
        .modelContainer(for: [Expense.self, ExchangeRate.self], inMemory: true)
}
