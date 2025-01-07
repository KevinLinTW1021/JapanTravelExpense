import SwiftUI
import SwiftData

struct TripListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingNewTripSheet = false
    @State private var trips: [Trip] = []
    
    private var activeTrips: [Trip] {
        trips.filter { !$0.isArchived }
            .sorted { $0.startDate > $1.startDate }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(activeTrips) { trip in
                    NavigationLink {
                        ExpenseListView(trip: trip)
                    } label: {
                        TripRowView(trip: trip)
                    }
                }
                .onDelete(perform: deleteTrips)
            }
            .navigationTitle("旅行記帳")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingNewTripSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showingNewTripSheet) {
                NewTripView()
            }
        }
        .task {
            do {
                let descriptor = FetchDescriptor<Trip>()
                trips = try modelContext.fetch(descriptor)
            } catch {
                print("Failed to fetch trips: \(error)")
            }
        }
        .onChange(of: showingNewTripSheet) { oldValue, newValue in
            if !newValue {
                // Sheet was dismissed, refresh trips
                Task {
                    do {
                        let descriptor = FetchDescriptor<Trip>()
                        trips = try modelContext.fetch(descriptor)
                    } catch {
                        print("Failed to fetch trips: \(error)")
                    }
                }
            }
        }
    }
    
    private func deleteTrips(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let trip = activeTrips[index]
                trip.isArchived = true
                try? modelContext.save()
            }
            // Refresh trips after deletion
            Task {
                do {
                    let descriptor = FetchDescriptor<Trip>()
                    trips = try modelContext.fetch(descriptor)
                } catch {
                    print("Failed to fetch trips: \(error)")
                }
            }
        }
    }
}

struct TripRowView: View {
    let trip: Trip
    @Query private var settings: [Settings]
    
    private var currentSettings: Settings {
        settings.first ?? Settings()
    }
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    
    private var totalExpenses: Double {
        let defaultCurrency = Currency(rawValue: trip.budgetCurrency) ?? .twd
        return trip.expenses.reduce(0) { total, expense in
            if let expenseCurrency = Currency(rawValue: expense.currency) {
                let amount = expense.isIncome ? expense.amount : -expense.amount
                if expenseCurrency == defaultCurrency {
                    return total + amount
                } else {
                    return total + CurrencyConverter.shared.convertSync(
                        amount,
                        from: expenseCurrency,
                        to: defaultCurrency
                    )
                }
            }
            return total
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(trip.name)
                .font(.headline)
            
            if let budget = trip.budget {
                let balance = budget + totalExpenses
                let progress = balance / budget
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("預算")
                        Spacer()
                        Text("\(numberFormatter.string(from: NSNumber(value: budget)) ?? "0") \(Currency(rawValue: trip.budgetCurrency)?.symbol ?? "")")
                    }
                    .font(.subheadline)
                    
                    HStack {
                        Text("剩餘")
                        Spacer()
                        Text("\(numberFormatter.string(from: NSNumber(value: balance)) ?? "0") \(Currency(rawValue: trip.budgetCurrency)?.symbol ?? "")")
                            .foregroundColor(progress < 0.1 ? .red : (progress < 0.3 ? .orange : .primary))
                    }
                    .font(.subheadline)
                    
                    ProgressView(value: max(0, min(1, progress)))
                        .tint(progress < 0.1 ? .red : (progress < 0.3 ? .orange : .blue))
                }
            } else {
                if totalExpenses != 0 {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("總支出")
                            Spacer()
                            Text("\(numberFormatter.string(from: NSNumber(value: -totalExpenses)) ?? "") \(Currency(rawValue: trip.budgetCurrency)?.symbol ?? "")")
                        }
                        .font(.subheadline)
                    }
                }
            }
            
            Text(trip.startDate.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TripListView()
        .modelContainer(for: [Trip.self, Expense.self, Settings.self], inMemory: true)
}
