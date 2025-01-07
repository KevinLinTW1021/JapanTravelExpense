import Foundation
import SwiftData

@Model
final class Trip {
    var name: String
    var startDate: Date
    var endDate: Date?
    var budget: Double?
    var budgetCurrency: String
    var notes: String?
    var isArchived: Bool
    @Relationship(deleteRule: .cascade) var expenses: [Expense]
    
    init(
        name: String,
        startDate: Date = Date(),
        endDate: Date? = nil,
        budget: Double? = nil,
        budgetCurrency: String = Currency.twd.rawValue,
        notes: String? = nil
    ) {
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.budget = budget
        self.budgetCurrency = budgetCurrency
        self.notes = notes
        self.isArchived = false
        self.expenses = []
    }
}
