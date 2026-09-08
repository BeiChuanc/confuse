import Foundation
import UserNotifications

/// 在审核状态变化时发送 macOS、PushPlus 和飞书通知。
enum MonitoringNotificationService_confuse {
    /// 向已配置的通知渠道发送状态变化消息。
    /// - Parameters:
    ///   - title_confuse: 通知标题。
    ///   - message_confuse: 通知正文。
    ///   - configuration_confuse: 包含远程通知令牌的监控配置。
    static func send_confuse(
        title_confuse: String,
        message_confuse: String,
        configuration_confuse: MonitoringConfiguration_confuse
    ) async {
        await sendLocalNotification_confuse(title_confuse: title_confuse, message_confuse: message_confuse)
        await sendPushPlus_confuse(
            token_confuse: configuration_confuse.pushPlusToken_confuse,
            title_confuse: title_confuse,
            message_confuse: message_confuse
        )
        await sendFeishu_confuse(
            webhook_confuse: configuration_confuse.feishuWebhook_confuse,
            title_confuse: title_confuse,
            message_confuse: message_confuse
        )
    }

    /// 请求通知权限并发送一条 macOS 本地通知。
    /// - Parameters:
    ///   - title_confuse: 通知标题。
    ///   - message_confuse: 通知正文。
    private static func sendLocalNotification_confuse(
        title_confuse: String,
        message_confuse: String
    ) async {
        let center_confuse = UNUserNotificationCenter.current()
        let granted_confuse = (try? await center_confuse.requestAuthorization(options: [.alert, .sound])) ?? false
        guard granted_confuse else { return }
        let content_confuse = UNMutableNotificationContent()
        content_confuse.title = title_confuse
        content_confuse.body = message_confuse
        content_confuse.sound = .default
        let request_confuse = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content_confuse,
            trigger: nil
        )
        try? await center_confuse.add(request_confuse)
    }

    /// 通过 PushPlus 发送状态变化消息。
    /// - Parameters:
    ///   - token_confuse: PushPlus Token，空值时跳过。
    ///   - title_confuse: 通知标题。
    ///   - message_confuse: 通知正文。
    private static func sendPushPlus_confuse(
        token_confuse: String,
        title_confuse: String,
        message_confuse: String
    ) async {
        let cleanToken_confuse = token_confuse.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanToken_confuse.isEmpty,
              let url_confuse = URL(string: "https://www.pushplus.plus/send") else { return }
        await postJSON_confuse(
            url_confuse: url_confuse,
            object_confuse: [
                "token": cleanToken_confuse,
                "title": title_confuse,
                "content": message_confuse
            ]
        )
    }

    /// 通过飞书机器人 Webhook 发送状态变化消息。
    /// - Parameters:
    ///   - webhook_confuse: 飞书 Webhook URL，空值时跳过。
    ///   - title_confuse: 通知标题。
    ///   - message_confuse: 通知正文。
    private static func sendFeishu_confuse(
        webhook_confuse: String,
        title_confuse: String,
        message_confuse: String
    ) async {
        let cleanWebhook_confuse = webhook_confuse.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanWebhook_confuse.isEmpty,
              let url_confuse = URL(string: cleanWebhook_confuse) else { return }
        await postJSON_confuse(
            url_confuse: url_confuse,
            object_confuse: [
                "msg_type": "text",
                "content": ["text": "\(title_confuse)\n\n\(message_confuse)"]
            ]
        )
    }

    /// 使用独立网络会话发送 JSON 请求，失败时静默返回。
    /// - Parameters:
    ///   - url_confuse: 接收通知的 URL。
    ///   - object_confuse: JSON 根对象。
    private static func postJSON_confuse(url_confuse: URL, object_confuse: [String: Any]) async {
        guard let body_confuse = try? JSONSerialization.data(withJSONObject: object_confuse) else { return }
        var request_confuse = URLRequest(url: url_confuse)
        request_confuse.httpMethod = "POST"
        request_confuse.timeoutInterval = 10
        request_confuse.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request_confuse.httpBody = body_confuse
        _ = try? await URLSession.shared.data(for: request_confuse)
    }
}
