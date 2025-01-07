import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    
    private init() {
        requestAuthorization()
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("通知權限已獲得")
            } else if let error = error {
                print("通知權限請求失敗: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleNotification(title: String, body: String, identifier: String = UUID().uuidString) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("通知排程失敗: \(error.localizedDescription)")
            }
        }
    }
    
    func checkBudgetStatus(currentAmount: Double, budget: Double, currency: String) {
        let percentage = (currentAmount / budget) * 100
        
        if currentAmount >= budget {
            scheduleNotification(
                title: "預算警告！",
                body: "您已超出預算！當前支出：\(currency)\(String(format: "%.2f", currentAmount))"
            )
        } else if percentage >= 90 {
            scheduleNotification(
                title: "預算提醒",
                body: "您已使用了 \(String(format: "%.1f", percentage))% 的預算，請注意支出！"
            )
        } else if percentage >= 75 {
            scheduleNotification(
                title: "預算提醒",
                body: "您已使用了 \(String(format: "%.1f", percentage))% 的預算。"
            )
        }
    }
}
