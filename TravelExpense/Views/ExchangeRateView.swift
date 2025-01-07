import SwiftUI
import SwiftData

struct ExchangeRateResponse: Codable {
    let base: String
    let date: String
    let time_last_updated: Int
    let rates: [String: Double]
}

struct ExchangeRateView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ExchangeRate.lastUpdated) private var rates: [ExchangeRate]
    
    @State private var isUpdating = false
    
    var currentRate: ExchangeRate {
        if rates.isEmpty {
            let newRate = ExchangeRate()
            modelContext.insert(newRate)
            return newRate
        }
        return rates[0]
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text("目前匯率")
                .font(.headline)
            
            HStack {
                Text("1 JPY = \(String(format: "%.3f", currentRate.rate)) TWD")
                    .font(.title2)
                
                if isUpdating {
                    ProgressView()
                        .padding(.leading)
                }
            }
            
            Text("更新時間：\(currentRate.lastUpdated.formatted())")
                .font(.caption)
                .foregroundColor(.gray)
            
            Button(action: updateRate) {
                Label("更新匯率", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.bordered)
            .disabled(isUpdating)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
        .task {
            // 確保有初始匯率
            if rates.isEmpty {
                modelContext.insert(ExchangeRate())
            }
        }
    }
    
    private func updateRate() {
        guard !isUpdating else { return }
        
        isUpdating = true
        
        Task {
            do {
                let url = URL(string: "https://api.exchangerate-api.com/v4/latest/JPY")!
                let (data, _) = try await URLSession.shared.data(from: url)
                let response = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)
                
                if let rate = response.rates["TWD"] {
                    await MainActor.run {
                        let newRate = ExchangeRate()
                        newRate.rate = rate
                        newRate.lastUpdated = .now
                        
                        // 刪除舊的匯率
                        for oldRate in rates {
                            modelContext.delete(oldRate)
                        }
                        
                        modelContext.insert(newRate)
                    }
                }
            } catch {
                print("Error updating rate: \(error)")
            }
            
            isUpdating = false
        }
    }
}

#Preview {
    ExchangeRateView()
        .modelContainer(for: ExchangeRate.self, inMemory: true)
}
