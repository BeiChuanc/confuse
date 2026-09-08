import Foundation
import UIKit

// MARK: 帖子ViewModel

/// 帖子状态管理类
/// 功能：管理帖子、评论和点赞的增删改查
/// 设计：单例 + 通知驱动状态更新，UI 层监听通知刷新
@MainActor
class TitleViewModel_Base_one {

    /// 单例
    static let shared_Base_one = TitleViewModel_Base_one()

    // MARK: - 通知名称

    /// 帖子状态更新通知
    static let titleStateDidChangeNotification_Base_one = Notification.Name("TitleStateDidChange_Base_one")

    // MARK: - 私有属性

    /// 帖子列表
    private var posts_Base_one: [TitleModel_Base_one] = []

    private init() {}

    // MARK: - 公共方法 - 获取数据

    /// 获取帖子列表
    func getPosts_Base_one() -> [TitleModel_Base_one] { posts_Base_one }

    /// 初始化帖子列表
    func initPosts_Base_one() {
        posts_Base_one = LocalData_Base_one.shared_Base_one.titleList_Base_one
        notifyStateChange_Base_one()
    }

    /// 获取指定用户的帖子列表
    /// 参数：
    /// - user_base_one: 目标用户模型
    /// - type_base_one: 帖子类型过滤（保留参数，预留后续扩展）
    /// 返回值：该用户的帖子数组，用户ID缺失时返回空数组
    func getUserPosts_Base_one(user_base_one: PrewUserModel_Base_one, type_base_one: Int? = nil) -> [TitleModel_Base_one] {
        guard let userId_base_one = user_base_one.userId_Base_one else { return [] }
        return posts_Base_one.filter { $0.titleUserId_Base_one == userId_base_one }
    }

    /// 判断当前用户是否已点赞指定帖子
    func isLikedPost_Base_one(post_base_one: TitleModel_Base_one) -> Bool {
        UserViewModel_Base_one.shared_Base_one.isLikedByCurrentUser_Base_one(post_base_one: post_base_one)
    }

    // MARK: - 公共方法 - 发布帖子

    /// 发布帖子
    /// 功能：创建新帖子并追加到列表，同步更新当前用户的帖子记录
    /// 参数：
    /// - title_base_one: 帖子标题
    /// - content_base_one: 帖子正文
    /// - media_base_one: 媒体资源路径
    /// - type_base_one: 帖子类型，默认 0
    func releasePost_Base_one(title_base_one: String, content_base_one: String, media_base_one: String, type_base_one: Int = 0) {
        guard UserViewModel_Base_one.shared_Base_one.isLoggedIn_Base_one else {
            showLoginPrompt_Base_one()
            return
        }

        let currentUser_base_one = UserViewModel_Base_one.shared_Base_one.getCurrentUser_Base_one()
        let newPost_base_one = TitleModel_Base_one(
            titleId_Base_one: posts_Base_one.count + 21,
            titleUserId_Base_one: currentUser_base_one.userId_Base_one ?? 0,
            titleUserName_Base_one: currentUser_base_one.userName_Base_one ?? "User",
            titleMeidas_Base_one: [media_base_one],
            title_Base_one: title_base_one,
            titleContent_Base_one: content_base_one,
            reviews_Base_one: [],
            likes_Base_one: 0
        )

        posts_Base_one.append(newPost_base_one)
        UserViewModel_Base_one.shared_Base_one.addPostToCurrentUser_Base_one(post_base_one: newPost_base_one)
        Load_Base_one.showSuccess_Base_one(
            message_Base_one: "Published successfully.",
            image_Base_one: UIImage(systemName: "checkmark.circle.fill")
        )
        notifyStateChange_Base_one()
    }

    // MARK: - 公共方法 - 删除帖子

    /// 删除/屏蔽帖子
    /// 功能：从帖子列表及用户记录中移除帖子
    /// 参数：
    /// - post_base_one: 目标帖子
    /// - isDelete_base_one: true 表示主动删除，false 表示屏蔽（提示语不同）
    func deletePost_Base_one(post_base_one: TitleModel_Base_one, isDelete_base_one: Bool = false) {
        let userVM_base_one = UserViewModel_Base_one.shared_Base_one
        userVM_base_one.removePostFromCurrentUser_Base_one(post_base_one: post_base_one)
        userVM_base_one.removeLikeFromCurrentUser_Base_one(post_base_one: post_base_one)
        posts_Base_one.removeAll { $0.titleId_Base_one == post_base_one.titleId_Base_one }

        Load_Base_one.showSuccess_Base_one(
            message_Base_one: isDelete_base_one ? "Deleted successfully." : "This post will no longer appear.",
            image_Base_one: UIImage(systemName: "trash.fill"),
            delay_Base_one: 1.5
        )
        notifyStateChange_Base_one()
    }

    /// 删除指定用户的所有帖子
    func deleteUserPosts_Base_one(userId_base_one: Int) {
        posts_Base_one.removeAll { $0.titleUserId_Base_one == userId_base_one }
        notifyStateChange_Base_one()
    }

    // MARK: - 公共方法 - 评论管理

    /// 发布评论
    /// 功能：向指定帖子追加新评论
    /// 参数：
    /// - post_base_one: 目标帖子
    /// - content_base_one: 评论内容
    func releaseComment_Base_one(post_base_one: TitleModel_Base_one, content_base_one: String) {
        guard UserViewModel_Base_one.shared_Base_one.isLoggedIn_Base_one else {
            showLoginPrompt_Base_one()
            return
        }

        let currentUser_base_one = UserViewModel_Base_one.shared_Base_one.getCurrentUser_Base_one()
        let newComment_base_one = Comment_Base_one(
            commentId_Base_one: post_base_one.reviews_Base_one.count + 1,
            commentUserId_Base_one: currentUser_base_one.userId_Base_one ?? 0,
            commentUserName_Base_one: currentUser_base_one.userName_Base_one ?? "User",
            commentContent_Base_one: content_base_one
        )

        if let index_base_one = postIndex_Base_one(for: post_base_one) {
            posts_Base_one[index_base_one].reviews_Base_one.append(newComment_base_one)
        }
        notifyStateChange_Base_one()
    }

    /// 删除/屏蔽评论
    /// 参数：
    /// - post_base_one: 目标帖子
    /// - comment_base_one: 要删除的评论
    /// - isDelete_base_one: true 表示主动删除，false 表示屏蔽
    func deleteComment_Base_one(post_base_one: TitleModel_Base_one, comment_base_one: Comment_Base_one, isDelete_base_one: Bool = false) {
        if let index_base_one = postIndex_Base_one(for: post_base_one) {
            posts_Base_one[index_base_one].reviews_Base_one.removeAll {
                $0.commentId_Base_one == comment_base_one.commentId_Base_one
            }
        }

        Load_Base_one.showSuccess_Base_one(
            message_Base_one: isDelete_base_one ? "Deleted successfully." : "This comment will no longer appear.",
            delay_Base_one: 1.5
        )
        notifyStateChange_Base_one()
    }

    // MARK: - 公共方法 - 点赞管理

    /// 点赞 / 取消点赞
    /// 功能：切换当前用户对指定帖子的点赞状态，同步更新点赞计数
    /// 参数：
    /// - post_base_one: 目标帖子
    func likePost_Base_one(post_base_one: TitleModel_Base_one) {
        guard UserViewModel_Base_one.shared_Base_one.isLoggedIn_Base_one else {
            showLoginPrompt_Base_one()
            return
        }

        let userVM_base_one = UserViewModel_Base_one.shared_Base_one
        guard let index_base_one = postIndex_Base_one(for: post_base_one) else {
            notifyStateChange_Base_one()
            return
        }

        if isLikedPost_Base_one(post_base_one: post_base_one) {
            userVM_base_one.removeLikeFromCurrentUser_Base_one(post_base_one: post_base_one)
            posts_Base_one[index_base_one].likes_Base_one = max(0, posts_Base_one[index_base_one].likes_Base_one - 1)
        } else {
            userVM_base_one.addLikeToCurrentUser_Base_one(post_base_one: post_base_one)
            posts_Base_one[index_base_one].likes_Base_one += 1
        }
        notifyStateChange_Base_one()
    }

    // MARK: - 私有方法

    /// 查找帖子在列表中的下标
    /// 参数：
    /// - post_base_one: 目标帖子
    /// 返回值：下标索引，未找到时返回 nil
    private func postIndex_Base_one(for post_base_one: TitleModel_Base_one) -> Int? {
        posts_Base_one.firstIndex { $0.titleId_Base_one == post_base_one.titleId_Base_one }
    }

    /// 发送状态更新通知
    private func notifyStateChange_Base_one() {
        NotificationCenter.default.post(
            name: TitleViewModel_Base_one.titleStateDidChangeNotification_Base_one,
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
