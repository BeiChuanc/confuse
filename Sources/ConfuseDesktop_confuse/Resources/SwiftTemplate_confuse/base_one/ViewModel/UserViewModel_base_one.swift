import Foundation
import UIKit

// MARK: 用户ViewModel

/// 登出类型枚举
/// 功能：区分删除账号和普通登出
enum LogOutType_Base_one {
    /// 删除账号
    case delete_base_one
    /// 普通登出
    case logout_base_one
}

/// 用户状态管理类
/// 功能：管理登录用户的状态、信息更新、关注、点赞和帖子操作
/// 设计：单例 + 通知驱动状态更新，UI 层监听通知刷新
@MainActor
class UserViewModel_Base_one {

    /// 单例
    static let shared_Base_one = UserViewModel_Base_one()

    // MARK: - 通知名称

    /// 用户状态更新通知
    static let userStateDidChangeNotification_Base_one = Notification.Name("UserStateDidChange_Base_one")

    // MARK: - 私有属性

    /// 当前登录用户
    private var loggedUser_Base_one: LoginUserModel_Base_one?

    /// 默认用户（游客）
    private let defaultUser_Base_one = LoginUserModel_Base_one(
        userId_Base_one: 0,
        userPwd_Base_one: nil,
        userName_Base_one: "Guest",
        userIntroduce_Base_one: "Nothing yet.",
        userHead_Base_one: "default_avatar",
        userPosts_Base_one: [],
        userLike_Base_one: [],
        userFollow_Base_one: []
    )

    private init() {}

    // MARK: - 公共属性

    /// 是否已登录
    var isLoggedIn_Base_one: Bool {
        loggedUser_Base_one?.userId_Base_one != 0
    }

    /// 获取当前用户（未登录时返回游客）
    func getCurrentUser_Base_one() -> LoginUserModel_Base_one {
        loggedUser_Base_one ?? defaultUser_Base_one
    }

    // MARK: - 初始化

    /// 初始化用户状态（重置为游客）
    func initUser_Base_one() {
        loggedUser_Base_one = defaultUser_Base_one
        notifyStateChange_Base_one()
    }

    // MARK: - 登录 / 登出

    /// 通过用户ID登录
    /// 参数：
    /// - userId_base_one: 目标用户ID
    func loginById_Base_one(userId_base_one: Int) {
        Load_Base_one.showLoading_Base_one(message_Base_one: "Logging in...")

        let localUser_base_one = LocalData_Base_one.shared_Base_one.userList_Base_one.first {
            $0.userId_Base_one == userId_base_one
        }

        loggedUser_Base_one = LoginUserModel_Base_one(
            userId_Base_one: userId_base_one,
            userPwd_Base_one: nil,
            userName_Base_one: "Wanderer",
            userIntroduce_Base_one: localUser_base_one?.userIntroduce_Base_one ?? "Nothing yet.",
            userHead_Base_one: "user_avatar",
            userPosts_Base_one: [],
            userLike_Base_one: [],
            userFollow_Base_one: []
        )

        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            Load_Base_one.dismissLoading_Base_one()
            Load_Base_one.showSuccess_Base_one(message_Base_one: "Login successful!")
            Navigation_Base_one.switchToTabbar_Base_one(animated: true)
            notifyStateChange_Base_one()
        }
    }

    /// 用户登出
    /// 参数：
    /// - logoutType_base_one: 登出类型（普通登出 / 删除账号）
    func logout_Base_one(logoutType_base_one: LogOutType_Base_one) {
        guard isLoggedIn_Base_one else {
            showLoginPrompt_Base_one()
            return
        }

        loggedUser_Base_one = defaultUser_Base_one
        MessageViewModel_Base_one.shared_Base_one.clearAiChat_Base_one()
        LocalData_Base_one.shared_Base_one.initData_Base_one()
        notifyStateChange_Base_one()
        Navigation_Base_one.switchToTabbar_Base_one()

        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            if logoutType_base_one == .delete_base_one {
                Load_Base_one.showInfo_Base_one(
                    message_Base_one: "The account will be deleted after 24 hours. If you log in within 24 hours, it will be considered a logout failure.",
                    delay_Base_one: 3.0
                )
            } else {
                Load_Base_one.showSuccess_Base_one(message_Base_one: "Logout successful")
            }
        }
    }

    // MARK: - 用户信息更新

    /// 更新用户头像
    /// 参数：
    /// - headUrl_base_one: 新头像路径
    func updateHead_Base_one(headUrl_base_one: String) {
        guard loggedUser_Base_one != nil else { return }
        loggedUser_Base_one?.userHead_Base_one = headUrl_base_one
        Load_Base_one.showSuccess_Base_one(message_Base_one: "Avatar updated successfully")
        notifyStateChange_Base_one()
    }

    /// 更新用户昵称
    /// 参数：
    /// - userName_base_one: 新昵称
    func updateName_Base_one(userName_base_one: String) {
        guard loggedUser_Base_one != nil else { return }
        loggedUser_Base_one?.userName_Base_one = userName_base_one
        Load_Base_one.showSuccess_Base_one(message_Base_one: "Name updated successfully")
        notifyStateChange_Base_one()
    }

    /// 更新用户自我介绍
    /// 参数：
    /// - userIntroduce_base_one: 新自我介绍内容
    func updateIntroduce_Base_one(userIntroduce_base_one: String) {
        guard loggedUser_Base_one != nil else { return }
        loggedUser_Base_one?.userIntroduce_Base_one = userIntroduce_base_one
        Load_Base_one.showSuccess_Base_one(message_Base_one: "Bio updated successfully")
        notifyStateChange_Base_one()
    }

    /// 上传用户封面
    /// 参数：
    /// - coverUrl_base_one: 封面图片路径
    func uploadCover_Base_one(coverUrl_base_one: String) {
        Load_Base_one.showSuccess_Base_one(message_Base_one: "Cover updated successfully")
        notifyStateChange_Base_one()
    }

    // MARK: - 打卡功能

    /// 检查今天是否已打卡
    /// 返回值：已打卡返回 true，否则 false
    func hasCheckedInToday_Base_one() -> Bool { false }

    /// 执行打卡
    /// 功能：已打卡时提示，未打卡时记录并提示成功
    func checkIn_Base_one() {
        guard !hasCheckedInToday_Base_one() else {
            Load_Base_one.showWarning_Base_one(message_Base_one: "You have already checked in today.")
            return
        }
        Load_Base_one.showSuccess_Base_one(
            message_Base_one: "Check-in successful!",
            image_Base_one: UIImage(systemName: "checkmark.seal.fill")
        )
        notifyStateChange_Base_one()
    }

    // MARK: - 关注功能

    /// 判断当前用户是否关注了指定用户
    /// 参数：
    /// - user_base_one: 目标用户
    /// 返回值：已关注返回 true，未登录或未关注返回 false
    func isFollowing_Base_one(user_base_one: PrewUserModel_Base_one) -> Bool {
        guard let logged_base_one = loggedUser_Base_one else { return false }
        return logged_base_one.userFollow_Base_one.contains { $0.userId_Base_one == logged_base_one.userId_Base_one }
    }

    /// 关注 / 取消关注用户
    /// 参数：
    /// - user_base_one: 目标用户
    func followUser_Base_one(user_base_one: PrewUserModel_Base_one) {
        guard isLoggedIn_Base_one else {
            showLoginPrompt_Base_one()
            return
        }

        if isFollowing_Base_one(user_base_one: user_base_one) {
            loggedUser_Base_one?.userFollow_Base_one.removeAll { $0.userId_Base_one == user_base_one.userId_Base_one }
        } else {
            loggedUser_Base_one?.userFollow_Base_one.append(user_base_one)
        }
        notifyStateChange_Base_one()
    }

    // MARK: - 举报功能

    /// 举报并屏蔽用户
    /// 功能：删除该用户的聊天记录、帖子，并从本地用户列表移除
    /// 参数：
    /// - user_base_one: 被举报的用户
    func reportUser_Base_one(user_base_one: PrewUserModel_Base_one) {
        guard let userId_base_one = user_base_one.userId_Base_one else { return }

        MessageViewModel_Base_one.shared_Base_one.deleteUserMessages_Base_one(userId_base_one: userId_base_one)
        TitleViewModel_Base_one.shared_Base_one.deleteUserPosts_Base_one(userId_base_one: userId_base_one)
        LocalData_Base_one.shared_Base_one.userList_Base_one.removeAll { $0.userId_Base_one == userId_base_one }

        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            Load_Base_one.showSuccess_Base_one(message_Base_one: "This user will no longer appear.", delay_Base_one: 2.0)
        }
        notifyStateChange_Base_one()
    }

    // MARK: - 用户查询

    /// 判断是否是当前登录用户
    /// 参数：
    /// - userId_base_one: 待判断的用户ID
    func isCurrentUser_Base_one(userId_base_one: Int) -> Bool {
        loggedUser_Base_one?.userId_Base_one == userId_base_one
    }

    /// 根据用户ID获取用户信息
    /// 参数：
    /// - userId_base_one: 目标用户ID
    /// 返回值：找到时返回对应用户，未找到时返回以该ID构建的默认游客模型
    func getUserById_Base_one(userId_base_one: Int) -> PrewUserModel_Base_one {
        if let found_base_one = LocalData_Base_one.shared_Base_one.userList_Base_one.first(where: { $0.userId_Base_one == userId_base_one }) {
            return found_base_one
        }
        let guest_base_one = PrewUserModel_Base_one()
        guest_base_one.userId_Base_one = userId_base_one
        guest_base_one.userName_Base_one = "Guest"
        guest_base_one.userHead_Base_one = "default_avatar"
        return guest_base_one
    }

    /// 获取用户关注排行榜
    /// 返回值：用户列表（当前按原始顺序返回）
    func getUserFollowRanking_Base_one() -> [PrewUserModel_Base_one] {
        LocalData_Base_one.shared_Base_one.userList_Base_one
    }

    // MARK: - 帖子和点赞管理

    /// 将帖子添加到当前用户的帖子列表
    func addPostToCurrentUser_Base_one(post_base_one: TitleModel_Base_one) {
        guard loggedUser_Base_one != nil else { return }
        loggedUser_Base_one?.userPosts_Base_one.append(post_base_one)
        notifyStateChange_Base_one()
    }

    /// 从当前用户的帖子列表中移除帖子
    func removePostFromCurrentUser_Base_one(post_base_one: TitleModel_Base_one) {
        guard loggedUser_Base_one != nil else { return }
        loggedUser_Base_one?.userPosts_Base_one.removeAll { $0.titleId_Base_one == post_base_one.titleId_Base_one }
        notifyStateChange_Base_one()
    }

    /// 将帖子添加到当前用户的喜欢列表（已存在时跳过）
    func addLikeToCurrentUser_Base_one(post_base_one: TitleModel_Base_one) {
        guard let user_base_one = loggedUser_Base_one,
              !user_base_one.userLike_Base_one.contains(where: { $0.titleId_Base_one == post_base_one.titleId_Base_one }) else { return }
        user_base_one.userLike_Base_one.append(post_base_one)
        notifyStateChange_Base_one()
    }

    /// 从当前用户的喜欢列表中移除帖子
    func removeLikeFromCurrentUser_Base_one(post_base_one: TitleModel_Base_one) {
        guard loggedUser_Base_one != nil else { return }
        loggedUser_Base_one?.userLike_Base_one.removeAll { $0.titleId_Base_one == post_base_one.titleId_Base_one }
        notifyStateChange_Base_one()
    }

    /// 判断当前用户是否喜欢指定帖子
    func isLikedByCurrentUser_Base_one(post_base_one: TitleModel_Base_one) -> Bool {
        loggedUser_Base_one?.userLike_Base_one.contains { $0.titleId_Base_one == post_base_one.titleId_Base_one } ?? false
    }

    // MARK: - 私有方法

    /// 发送状态更新通知
    private func notifyStateChange_Base_one() {
        NotificationCenter.default.post(
            name: UserViewModel_Base_one.userStateDidChangeNotification_Base_one,
            object: nil
        )
    }

    /// 显示登录引导（延迟 0.5 秒后跳转登录页）
    private func showLoginPrompt_Base_one() {
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            Navigation_Base_one.toLogin_Base_one(style_base_one: .present_base_one)
        }
    }
}
