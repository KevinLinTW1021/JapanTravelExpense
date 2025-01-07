import SwiftUI

struct CategoryFilterView: View {
    @Binding var selectedCategory: String?
    
    let categories = ["全部"] + ExpenseCategory.allCases.map { $0.rawValue }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    CategoryChip(
                        title: category,
                        isSelected: category == (selectedCategory ?? "全部"),
                        action: {
                            selectedCategory = category == "全部" ? nil : category
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    private var icon: String {
        if title == "全部" {
            return "list.bullet"
        }
        return ExpenseCategory(rawValue: title)?.iconName ?? "circle"
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

#Preview {
    CategoryFilterView(selectedCategory: .constant(nil))
}
