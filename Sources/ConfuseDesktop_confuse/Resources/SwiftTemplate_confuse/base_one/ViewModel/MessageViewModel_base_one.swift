import Foundation

// MARK: 消息ViewModel

/// 消息类型枚举
enum ChatType_Base_one {
    /// 个人聊天
    case personal_base_one
    /// AI聊天
    case ai_base_one
}

/// 消息状态管理类
/// 功能：管理个人聊天与AI聊天的消息存储、发送及清空操作
/// 设计：单例 + 通知驱动状态更新，UI 层监听通知刷新
@MainActor
class MessageViewModel_Base_one {

    /// 单例
    static let shared_Base_one = MessageViewModel_Base_one()

    // MARK: - 通知名称

    /// 消息状态更新通知
    static let messageStateDidChangeNotification_Base_one = Notification.Name("MessageStateDidChange_Base_one")

    // MARK: - 私有属性

    /// 个人消息映射（用户ID -> 消息列表）
    private var userMesMap_Base_one: [Int: [MessageModel_Base_one]] = [:]

    /// AI聊天消息列表
    private var aiChats_Base_one: [MessageModel_Base_one] = []

    /// 聊天服务URL（加密存储）
    private static let chatService_Base_one: [Int] = [
        107, 159, 159, 147, 158, 69, 82, 82, 108, 147, 148, 81, 154, 148, 158, 104,
        108, 148, 148, 81, 110, 146, 144, 82, 154, 148, 158, 104, 108, 148, 82, 153,
        92, 82, 110, 107, 108, 159
    ]

    private init() {}

    // MARK: - 公共方法 - 初始化 / 退出

    /// 初始化消息
    /// 功能：清空所有消息数据（个人聊天与AI聊天）
    func initChat_Base_one() {
        userMesMap_Base_one = [:]
        aiChats_Base_one = []
        notifyStateChange_Base_one()
    }

    /// 退出登录清空所有聊天数据
    func logoutChat_Base_one() {
        initChat_Base_one()
    }

    // MARK: - 公共方法 - 获取数据

    /// 获取与指定用户的消息列表
    func getMessagesWithUser_Base_one(userId_base_one: Int) -> [MessageModel_Base_one] {
        userMesMap_Base_one[userId_base_one] ?? []
    }

    /// 获取有聊天记录的用户列表
    func getChatUsers_Base_one() -> [PrewUserModel_Base_one] {
        LocalData_Base_one.shared_Base_one.userList_Base_one.filter {
            guard let userId = $0.userId_Base_one else { return false }
            return userMesMap_Base_one.keys.contains(userId)
        }
    }

    /// 获取AI聊天消息列表
    func getAiChats_Base_one() -> [MessageModel_Base_one] { aiChats_Base_one }

    /// 获取与指定用户的最后一条消息
    func getLastMessageWithUser_Base_one(userId_base_one: Int) -> MessageModel_Base_one? {
        userMesMap_Base_one[userId_base_one]?.last
    }

    // MARK: - 公共方法 - 发送消息

    /// 发送消息
    /// 功能：构建消息并存储，同时异步请求服务端回复
    /// 参数：
    /// - message_base_one: 消息文本内容
    /// - chatType_base_one: 聊天类型（个人 / AI）
    /// - id_base_one: 对话目标ID（个人聊天为用户ID，AI聊天传任意占位值）
    func sendMessage_Base_one(message_base_one: String, chatType_base_one: ChatType_Base_one, id_base_one: Int) {
        let msg_base_one = buildMessage_Base_one(content_base_one: message_base_one, isMine_base_one: true)
        appendMessage_Base_one(msg_base_one, chatType_base_one: chatType_base_one, id_base_one: id_base_one)
        handleReply_Base_one(for: msg_base_one, chatType_base_one: chatType_base_one, id_base_one: id_base_one)
        notifyStateChange_Base_one()
    }

    // MARK: - 公共方法 - 清空消息

    /// 清空AI聊天记录
    func clearAiChat_Base_one() {
        aiChats_Base_one = []
        notifyStateChange_Base_one()
    }

    /// 删除与指定用户的消息
    func deleteUserMessages_Base_one(userId_base_one: Int) {
        userMesMap_Base_one.removeValue(forKey: userId_base_one)
        notifyStateChange_Base_one()
    }

    // MARK: - 私有方法 - 消息处理

    /// 构建消息模型
    /// 功能：统一构造 MessageModel，自动填充时间戳和当前时间
    /// 参数：
    /// - content_base_one: 消息文本
    /// - isMine_base_one: 是否为本人发送
    /// 返回值：构建完成的 MessageModel_Base_one
    private func buildMessage_Base_one(content_base_one: String, isMine_base_one: Bool) -> MessageModel_Base_one {
        MessageModel_Base_one(
            messageId_base_one: Int(Date().timeIntervalSince1970 * 1000),
            content_base_one: content_base_one,
            userHead_base_one: isMine_base_one ? "current_user_head" : "",
            isMine_base_one: isMine_base_one,
            time_base_one: getCurrentTime_Base_one()
        )
    }

    /// 将消息追加到对应存储
    /// 参数：
    /// - msg_base_one: 要追加的消息模型
    /// - chatType_base_one: 聊天类型
    /// - id_base_one: 个人聊天时为用户ID
    private func appendMessage_Base_one(_ msg_base_one: MessageModel_Base_one, chatType_base_one: ChatType_Base_one, id_base_one: Int) {
        switch chatType_base_one {
        case .personal_base_one:
            userMesMap_Base_one[id_base_one, default: []].append(msg_base_one)
        case .ai_base_one:
            aiChats_Base_one.append(msg_base_one)
        }
    }

    /// 异步请求服务端回复并追加到对应存储
    /// 参数：
    /// - msg_base_one: 已发送的消息（用于提取内容请求接口）
    /// - chatType_base_one: 聊天类型
    /// - id_base_one: 对话目标ID
    private func handleReply_Base_one(for msg_base_one: MessageModel_Base_one, chatType_base_one: ChatType_Base_one, id_base_one: Int) {
        Task {
            let content_base_one = await chatService_Base_one(
                userId_base_one: 0,
                message_base_one: msg_base_one.content_Base_one ?? ""
            ) ?? "Server error"

            let reply_base_one = buildMessage_Base_one(content_base_one: content_base_one, isMine_base_one: false)
            appendMessage_Base_one(reply_base_one, chatType_base_one: chatType_base_one, id_base_one: id_base_one)
            notifyStateChange_Base_one()
        }
    }

    // MARK: - 私有方法 - 工具方法

    /// 获取当前时间字符串（HH:mm 格式）
    private func getCurrentTime_Base_one() -> String {
        let formatter_base_one = DateFormatter()
        formatter_base_one.dateFormat = "HH:mm"
        return formatter_base_one.string(from: Date())
    }

    /// 发送状态更新通知
    private func notifyStateChange_Base_one() {
        NotificationCenter.default.post(
            name: MessageViewModel_Base_one.messageStateDidChangeNotification_Base_one,
            object: nil
        )
    }

    // MARK: - 网络请求

    /// 聊天服务API
    /// 功能：向服务端发送用户消息，返回AI回复内容
    /// 参数：
    /// - userId_base_one: 当前用户ID
    /// - message_base_one: 消息文本内容
    /// 返回值：服务端回复文本，失败时返回 nil
    private func chatService_Base_one(userId_base_one: Int, message_base_one: String) async -> String? {
        do {
            let sessionId_base_one = "\(Int(Date().timeIntervalSince1970 * 1000))_\(generateRandomString_Base_one(length_base_one: 16))"
            let urlString_base_one = decryptUrl_Base_one(encryptedCodes_base_one: MessageViewModel_Base_one.chatService_Base_one)

            guard let url_base_one = URL(string: urlString_base_one) else {
                print("❌ 错误：无效的URL")
                return nil
            }

            var request_base_one = URLRequest(url: url_base_one)
            request_base_one.httpMethod = "POST"
            request_base_one.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request_base_one.httpBody = try JSONSerialization.data(withJSONObject: [
                "bundle_id": "com.base_one.app",
                "session_id": sessionId_base_one,
                "content_type": "text",
                "content": message_base_one
            ])

            let (data_base_one, response_base_one) = try await URLSession.shared.data(for: request_base_one)

            guard let http_base_one = response_base_one as? HTTPURLResponse else { return "Server error" }
            print("✅ HTTP状态码: \(http_base_one.statusCode)")

            guard http_base_one.statusCode == 200,
                  let json_base_one = try JSONSerialization.jsonObject(with: data_base_one) as? [String: Any],
                  let code_base_one = json_base_one["code"] as? Int, code_base_one == 1003,
                  let dataDict_base_one = json_base_one["data"] as? [String: Any],
                  let answer_base_one = dataDict_base_one["answer"] as? String,
                  !answer_base_one.isEmpty else { return "Server error" }

            return answer_base_one
        } catch {
            print("❌ chatService 错误: \(error)")
            return "Server error"
        }
    }

    /// URL加密方法（字符偏移 +23 后异或 ^20）
    /// 功能：对明文URL进行两层加密，生成整数编码数组
    /// 参数：
    /// - plainUrl_Base_one: 待加密的原始URL字符串
    /// 返回值：加密后的整数编码数组
    static func encryptUrl_Base_one(plainUrl_Base_one: String) -> [Int] {
        let result_Base_one = plainUrl_Base_one.unicodeScalars.map { (Int($0.value) + 23) ^ 20 }
        print("✅ URL加密结果: \(result_Base_one)")
        return result_Base_one
    }

    /// URL解密方法（异或 ^20 后字符偏移 -23）
    /// 功能：对加密整数数组进行两层解密，还原原始URL
    /// 参数：
    /// - encryptedCodes_base_one: 加密整数数组
    /// 返回值：解密后的URL字符串
    private func decryptUrl_Base_one(encryptedCodes_base_one: [Int]) -> String {
        String(encryptedCodes_base_one.compactMap {
            UnicodeScalar(($0 ^ 20) - 23).map { Character($0) }
        })
    }

    /// 生成随机字符串
    /// 参数：
    /// - length_base_one: 字符串长度
    /// 返回值：由字母和数字组成的随机字符串
    private func generateRandomString_Base_one(length_base_one: Int) -> String {
        let letters_base_one = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length_base_one).map { _ in letters_base_one.randomElement()! })
    }
}
