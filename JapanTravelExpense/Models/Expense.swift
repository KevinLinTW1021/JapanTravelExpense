import Foundation
import SwiftData

@Model
final class Expense {
    var amount: Double          // 金額
    var currency: String        // 貨幣代碼
    var category: String        // 支出類別
    var note: String           // 備註
    var date: Date             // 日期
    var isIncome: Bool         // 是否為收入
    var location: String?      // 地點（選填）
    
    init(
        amount: Double,
        currency: String = Currency.twd.rawValue,
        category: String,
        note: String,
        date: Date = Date(),
        isIncome: Bool = false,
        location: String? = nil
    ) {
        self.amount = amount
        self.currency = currency
        self.category = category
        self.note = note
        self.date = date
        self.isIncome = isIncome
        self.location = location
    }
}

// 預設支出類別
enum ExpenseCategory: String, CaseIterable {
    case food = "食物"
    case transportation = "交通"
    case shopping = "購物"
    case accommodation = "住宿"
    case entertainment = "娛樂"
    case sightseeing = "觀光"
    case health = "醫療"
    case communication = "通訊"
    case other = "其他"
    
    var iconName: String {
        switch self {
        case .food: return "fork.knife"
        case .transportation: return "train.side.front.car"
        case .shopping: return "bag"
        case .accommodation: return "house"
        case .entertainment: return "star"
        case .sightseeing: return "camera"
        case .health: return "cross.case"
        case .communication: return "phone"
        case .other: return "ellipsis.circle"
        }
    }
}
