import Foundation
import SwiftData

@Model
final class ExchangeRate {
    var rate: Double           // 1日圓兌換新台幣的匯率
    var lastUpdated: Date      // 最後更新時間
    
    init(rate: Double = 0.22, lastUpdated: Date = Date()) {
        self.rate = rate
        self.lastUpdated = lastUpdated
    }
    
    // 日圓轉換為新台幣
    func jpyToTwd(_ amount: Double) -> Double {
        return amount * rate
    }
    
    // 新台幣轉換為日圓
    func twdToJpy(_ amount: Double) -> Double {
        guard rate > 0 else { return 0 }
        return amount / rate
    }
}
