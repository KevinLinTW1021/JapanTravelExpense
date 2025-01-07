import Foundation

class ExchangeRateService {
    static let shared = ExchangeRateService()
    
    private init() {}
    
    func fetchLatestRate() async throws -> Double {
        let url = URL(string: "https://api.exchangerate-api.com/v4/latest/JPY")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)
        return response.rates["TWD"] ?? 0.22 // 使用默認值作為備用
    }
}
