import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [Settings]
    @State private var showingExchangeRateView = false
    
    private var currentSettings: Settings {
        settings.first ?? Settings()
    }
    
    private let defaultExpenseTypes = [
        "食物", "交通", "住宿", "購物", "娛樂", "其他"
    ]
    
    var body: some View {
        Form {
            Section {
                Picker("預設貨幣", selection: Binding(
                    get: { currentSettings.defaultCurrency },
                    set: { newValue in
                        if let settings = settings.first {
                            settings.defaultCurrency = newValue
                            try? modelContext.save()
                        }
                    }
                )) {
                    ForEach(Currency.allCases, id: \.self) { currency in
                        Text(currency.rawValue).tag(currency)
                    }
                }
                
                Picker("預設支出類型", selection: Binding(
                    get: { currentSettings.defaultExpenseType },
                    set: { newValue in
                        if let settings = settings.first {
                            settings.defaultExpenseType = newValue
                            try? modelContext.save()
                        }
                    }
                )) {
                    ForEach(defaultExpenseTypes, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
            } header: {
                Text("一般設定")
            }
            
            Section {
                Toggle("自動更新匯率", isOn: Binding(
                    get: { currentSettings.autoUpdateExchangeRate },
                    set: { newValue in
                        if let settings = settings.first {
                            settings.autoUpdateExchangeRate = newValue
                            try? modelContext.save()
                        }
                    }
                ))
                
                Button {
                    showingExchangeRateView = true
                } label: {
                    HStack {
                        Text("匯率設定")
                        Spacer()
                        Text("更新匯率")
                            .foregroundColor(.secondary)
                    }
                }
            } header: {
                Text("匯率設定")
            }
            
            Section {
                Toggle("開啟通知", isOn: Binding(
                    get: { currentSettings.notificationsEnabled },
                    set: { newValue in
                        if let settings = settings.first {
                            settings.notificationsEnabled = newValue
                            try? modelContext.save()
                        }
                    }
                ))
                
                if currentSettings.notificationsEnabled {
                    Toggle("預算達到75%時通知", isOn: Binding(
                        get: { currentSettings.notifyAt75Percent },
                        set: { newValue in
                            if let settings = settings.first {
                                settings.notifyAt75Percent = newValue
                                try? modelContext.save()
                            }
                        }
                    ))
                    
                    Toggle("預算達到90%時通知", isOn: Binding(
                        get: { currentSettings.notifyAt90Percent },
                        set: { newValue in
                            if let settings = settings.first {
                                settings.notifyAt90Percent = newValue
                                try? modelContext.save()
                            }
                        }
                    ))
                    
                    Toggle("預算達到100%時通知", isOn: Binding(
                        get: { currentSettings.notifyAt100Percent },
                        set: { newValue in
                            if let settings = settings.first {
                                settings.notifyAt100Percent = newValue
                                try? modelContext.save()
                            }
                        }
                    ))
                }
            } header: {
                Text("通知設定")
            }
        }
        .navigationTitle("設定")
        .sheet(isPresented: $showingExchangeRateView) {
            NavigationStack {
                ExchangeRateView()
            }
        }
        .onAppear {
            if settings.isEmpty {
                let newSettings = Settings()
                modelContext.insert(newSettings)
                try? modelContext.save()
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .modelContainer(for: [Settings.self, ExchangeRate.self], inMemory: true)
}
