import Foundation
import SwiftData

enum Currency: String, CaseIterable, Codable {
    case usd = "美元 (USD)"
    case jpy = "日圓 (JPY)"
    case twd = "新台幣 (TWD)"
    case eur = "歐元 (EUR)"
    case gbp = "英鎊 (GBP)"
    case krw = "韓元 (KRW)"
    case cny = "人民幣 (CNY)"
    case hkd = "港幣 (HKD)"
    case sgd = "新加坡幣 (SGD)"
    case thb = "泰銖 (THB)"
    
    var symbol: String {
        switch self {
        case .usd: return "$"
        case .jpy: return "¥"
        case .twd: return "NT$"
        case .eur: return "€"
        case .gbp: return "£"
        case .krw: return "₩"
        case .cny: return "¥"
        case .hkd: return "HK$"
        case .sgd: return "S$"
        case .thb: return "฿"
        }
    }
    
    var code: String {
        switch self {
        case .usd: return "USD"
        case .jpy: return "JPY"
        case .twd: return "TWD"
        case .eur: return "EUR"
        case .gbp: return "GBP"
        case .krw: return "KRW"
        case .cny: return "CNY"
        case .hkd: return "HKD"
        case .sgd: return "SGD"
        case .thb: return "THB"
        }
    }
}

enum AppTheme: String, CaseIterable, Codable {
    case system = "系統"
    case light = "淺色"
    case dark = "深色"
}

@Model
final class Settings {
    var defaultCurrencyRaw: String = Currency.twd.rawValue
    var themeRaw: String = AppTheme.system.rawValue
    var autoUpdateExchangeRate: Bool = true
    var roundingDigits: Int = 0
    var defaultExpenseTypeRaw: String = "食物"
    var notificationsEnabled: Bool = true
    var notifyAt75Percent: Bool = true
    var notifyAt90Percent: Bool = true
    var notifyAt100Percent: Bool = true
    
    var defaultCurrency: Currency {
        get { Currency(rawValue: defaultCurrencyRaw) ?? .twd }
        set { defaultCurrencyRaw = newValue.rawValue }
    }
    
    var theme: AppTheme {
        get { AppTheme(rawValue: themeRaw) ?? .system }
        set { themeRaw = newValue.rawValue }
    }
    
    var defaultExpenseType: String {
        get { defaultExpenseTypeRaw }
        set { defaultExpenseTypeRaw = newValue }
    }
    
    init(
        defaultCurrency: Currency = .twd,
        theme: AppTheme = .system,
        autoUpdateExchangeRate: Bool = true,
        roundingDigits: Int = 0,
        defaultExpenseType: String = "食物",
        notificationsEnabled: Bool = true,
        notifyAt75Percent: Bool = true,
        notifyAt90Percent: Bool = true,
        notifyAt100Percent: Bool = true
    ) {
        self.defaultCurrencyRaw = defaultCurrency.rawValue
        self.themeRaw = theme.rawValue
        self.autoUpdateExchangeRate = autoUpdateExchangeRate
        self.roundingDigits = roundingDigits
        self.defaultExpenseTypeRaw = defaultExpenseType
        self.notificationsEnabled = notificationsEnabled
        self.notifyAt75Percent = notifyAt75Percent
        self.notifyAt90Percent = notifyAt90Percent
        self.notifyAt100Percent = notifyAt100Percent
    }
}
