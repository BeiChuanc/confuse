import UIKit

// MARK: - 举报/删除助手类

/// 举报/删除助手类
/// 功能：统一处理用户拉黑、帖子/评论举报与删除，以及对应操作按钮的创建
/// 设计：静态工具类，弹窗确认 + 异步执行 ViewModel 操作
class ReportDeleteHelper_Base_one {

    // MARK: - 常量

    /// 操作延迟时间（秒）
    private static let actionDelay_Base_one: TimeInterval = 0.5

    /// 按钮点击动画时长
    private static let animationDuration_Base_one: TimeInterval = 0.1

    /// 按钮点击缩放比例
    private static let animationScale_Base_one: CGFloat = 0.85

    /// 删除确认弹窗文案
    private enum DeleteAlertConfig_Base_one {
        static let postTitle_Base_one = "Delete Post"
        static let postMessage_Base_one = "Are you sure you want to delete this post? This action cannot be undone."
        static let commentTitle_Base_one = "Delete Comment"
        static let commentMessage_Base_one = "Are you sure you want to delete this comment? This action cannot be undone."
        static let deleteButtonTitle_Base_one = "Delete"
        static let cancelButtonTitle_Base_one = "Cancel"
    }

    // MARK: - 用户操作

    /// 拉黑用户
    /// 参数：
    /// - user_Base_one: 被拉黑的用户
    /// - viewController_Base_one: 发起操作的视图控制器
    /// - completion_Base_one: 确认后立即回调（不等待异步操作完成）
    static func block_Base_one(
        user_Base_one: PrewUserModel_Base_one,
        from viewController_Base_one: UIViewController,
        completion_Base_one: (() -> Void)? = nil
    ) {
        UIAlertController.report_Base_one(with: true, completeBlock: {
            performBlockUser_Base_one(user_Base_one: user_Base_one)
            completion_Base_one?()
        })
    }

    // MARK: - 举报

    /// 举报帖子
    static func report_Base_one(
        post_Base_one: TitleModel_Base_one,
        from viewController_Base_one: UIViewController,
        completion_Base_one: (() -> Void)? = nil
    ) {
        UIAlertController.report_Base_one(with: false, completeBlock: {
            performReportPost_Base_one(post_Base_one: post_Base_one, completion_Base_one: completion_Base_one)
        })
    }

    /// 举报评论
    static func report_Base_one(
        comment_Base_one: Comment_Base_one,
        post_Base_one: TitleModel_Base_one,
        from viewController_Base_one: UIViewController,
        completion_Base_one: (() -> Void)? = nil
    ) {
        UIAlertController.report_Base_one(with: false, completeBlock: {
            performReportComment_Base_one(
                comment_Base_one: comment_Base_one,
                post_Base_one: post_Base_one,
                completion_Base_one: completion_Base_one
            )
        })
    }

    // MARK: - 删除

    /// 删除帖子
    static func delete_Base_one(
        post_Base_one: TitleModel_Base_one,
        from viewController_Base_one: UIViewController,
        completion_Base_one: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Base_one(
            title_Base_one: DeleteAlertConfig_Base_one.postTitle_Base_one,
            message_Base_one: DeleteAlertConfig_Base_one.postMessage_Base_one,
            from: viewController_Base_one
        ) {
            performDeletePost_Base_one(post_Base_one: post_Base_one, completion_Base_one: completion_Base_one)
        }
    }

    /// 删除评论
    static func delete_Base_one(
        comment_Base_one: Comment_Base_one,
        post_Base_one: TitleModel_Base_one,
        from viewController_Base_one: UIViewController,
        completion_Base_one: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Base_one(
            title_Base_one: DeleteAlertConfig_Base_one.commentTitle_Base_one,
            message_Base_one: DeleteAlertConfig_Base_one.commentMessage_Base_one,
            from: viewController_Base_one
        ) {
            performDeleteComment_Base_one(
                comment_Base_one: comment_Base_one,
                post_Base_one: post_Base_one,
                completion_Base_one: completion_Base_one
            )
        }
    }

    /// 显示删除确认弹窗
    private static func showDeleteConfirmAlert_Base_one(
        title_Base_one: String,
        message_Base_one: String,
        from viewController_Base_one: UIViewController,
        completion_Base_one: @escaping () -> Void
    ) {
        let alert_Base_one = UIAlertController(title: title_Base_one, message: message_Base_one, preferredStyle: .alert)
        alert_Base_one.addAction(UIAlertAction(title: DeleteAlertConfig_Base_one.cancelButtonTitle_Base_one, style: .cancel))
        alert_Base_one.addAction(UIAlertAction(title: DeleteAlertConfig_Base_one.deleteButtonTitle_Base_one, style: .destructive) { _ in
            completion_Base_one()
        })
        viewController_Base_one.present(alert_Base_one, animated: true)
    }

    // MARK: - 执行操作

    /// 延迟后异步执行操作，完成后回调
    private static func performAsyncAction_Base_one(
        action_Base_one: @escaping @MainActor () -> Void,
        completion_Base_one: (() -> Void)? = nil
    ) {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(actionDelay_Base_one * 1_000_000_000))
            await action_Base_one()
            if let completion_Base_one {
                await MainActor.run { completion_Base_one() }
            }
        }
    }

    private static func performBlockUser_Base_one(user_Base_one: PrewUserModel_Base_one) {
        performAsyncAction_Base_one(action_Base_one: {
            UserViewModel_Base_one.shared_Base_one.reportUser_Base_one(user_base_one: user_Base_one)
            print("已拉黑用户: \(user_Base_one.userName_Base_one ?? "Unknown")")
        })
    }

    private static func performReportPost_Base_one(post_Base_one: TitleModel_Base_one, completion_Base_one: (() -> Void)? = nil) {
        performAsyncAction_Base_one(action_Base_one: {
            TitleViewModel_Base_one.shared_Base_one.deletePost_Base_one(post_base_one: post_Base_one)
            print("已举报帖子: \(post_Base_one.title_Base_one)")
        }, completion_Base_one: completion_Base_one)
    }

    private static func performReportComment_Base_one(
        comment_Base_one: Comment_Base_one,
        post_Base_one: TitleModel_Base_one,
        completion_Base_one: (() -> Void)? = nil
    ) {
        performAsyncAction_Base_one(action_Base_one: {
            TitleViewModel_Base_one.shared_Base_one.deleteComment_Base_one(
                post_base_one: post_Base_one,
                comment_base_one: comment_Base_one
            )
            print("已举报评论: \(comment_Base_one.commentContent_Base_one)")
        }, completion_Base_one: completion_Base_one)
    }

    private static func performDeletePost_Base_one(post_Base_one: TitleModel_Base_one, completion_Base_one: (() -> Void)? = nil) {
        performAsyncAction_Base_one(action_Base_one: {
            TitleViewModel_Base_one.shared_Base_one.deletePost_Base_one(post_base_one: post_Base_one, isDelete_base_one: true)
            print("已删除帖子: \(post_Base_one.title_Base_one)")
        }, completion_Base_one: completion_Base_one)
    }

    private static func performDeleteComment_Base_one(
        comment_Base_one: Comment_Base_one,
        post_Base_one: TitleModel_Base_one,
        completion_Base_one: (() -> Void)? = nil
    ) {
        performAsyncAction_Base_one(action_Base_one: {
            TitleViewModel_Base_one.shared_Base_one.deleteComment_Base_one(
                post_base_one: post_Base_one,
                comment_base_one: comment_Base_one,
                isDelete_base_one: true
            )
            print("已删除评论: \(comment_Base_one.commentContent_Base_one)")
        }, completion_Base_one: completion_Base_one)
    }

    // MARK: - 按钮创建

    /// 创建帖子举报/删除按钮（自己的帖子显示删除图标）
    @MainActor static func createPostReportButton_Base_one(
        post_Base_one: TitleModel_Base_one,
        size_Base_one: CGFloat = 25,
        color_Base_one: UIColor = .black,
        from viewController_Base_one: UIViewController,
        completion_Base_one: (() -> Void)? = nil
    ) -> UIButton {
        createContentReportButton_Base_one(
            ownerUserId_base_one: post_Base_one.titleUserId_Base_one,
            size_Base_one: size_Base_one,
            color_Base_one: color_Base_one,
            from: viewController_Base_one
        ) { vc_base_one, isMine_base_one in
            if isMine_base_one {
                delete_Base_one(post_Base_one: post_Base_one, from: vc_base_one, completion_Base_one: completion_Base_one)
            } else {
                report_Base_one(post_Base_one: post_Base_one, from: vc_base_one, completion_Base_one: completion_Base_one)
            }
        }
    }

    /// 创建评论举报/删除按钮（自己的评论显示删除图标）
    @MainActor static func createCommentReportButton_Base_one(
        comment_Base_one: Comment_Base_one,
        post_Base_one: TitleModel_Base_one,
        size_Base_one: CGFloat = 25,
        color_Base_one: UIColor = .black,
        from viewController_Base_one: UIViewController,
        completion_Base_one: (() -> Void)? = nil
    ) -> UIButton {
        createContentReportButton_Base_one(
            ownerUserId_base_one: comment_Base_one.commentUserId_Base_one,
            size_Base_one: size_Base_one,
            color_Base_one: color_Base_one,
            from: viewController_Base_one
        ) { vc_base_one, isMine_base_one in
            if isMine_base_one {
                delete_Base_one(
                    comment_Base_one: comment_Base_one,
                    post_Base_one: post_Base_one,
                    from: vc_base_one,
                    completion_Base_one: completion_Base_one
                )
            } else {
                report_Base_one(
                    comment_Base_one: comment_Base_one,
                    post_Base_one: post_Base_one,
                    from: vc_base_one,
                    completion_Base_one: completion_Base_one
                )
            }
        }
    }

    /// 创建用户举报按钮（用于聊天、视频通话等场景）
    static func createUserReportButton_Base_one(
        size_Base_one: CGFloat = 44,
        backgroundColor_Base_one: UIColor? = nil,
        tintColor_Base_one: UIColor = .white,
        withShadow_Base_one: Bool = false
    ) -> UIButton {
        let button_Base_one = UIButton(type: .system)
        let iconSize_Base_one = size_Base_one * 0.5
        button_Base_one.setImage(
            UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(pointSize: iconSize_Base_one, weight: .semibold)),
            for: .normal
        )
        button_Base_one.tintColor = tintColor_Base_one
        button_Base_one.backgroundColor = backgroundColor_Base_one ?? UIColor.white.withAlphaComponent(0.2)
        button_Base_one.layer.cornerRadius = size_Base_one / 2

        if withShadow_Base_one {
            button_Base_one.layer.shadowColor = UIColor.black.cgColor
            button_Base_one.layer.shadowOffset = CGSize(width: 0, height: 4)
            button_Base_one.layer.shadowOpacity = 0.15
            button_Base_one.layer.shadowRadius = 8
        }
        return button_Base_one
    }

    // MARK: - 私有辅助方法

    /// 创建帖子/评论通用的举报操作按钮
    /// 参数：
    /// - ownerUserId_base_one: 内容所属用户 ID
    /// - onTap_base_one: 点击回调，参数为 (视图控制器, 是否为本人内容)
    @MainActor
    private static func createContentReportButton_Base_one(
        ownerUserId_base_one: Int,
        size_Base_one: CGFloat,
        color_Base_one: UIColor,
        from viewController_Base_one: UIViewController,
        onTap_base_one: @escaping (UIViewController, Bool) -> Void
    ) -> UIButton {
        let button_Base_one = UIButton(type: .system)
        let isMine_base_one = UserViewModel_Base_one.shared_Base_one.isCurrentUser_Base_one(userId_base_one: ownerUserId_base_one)
        configureButtonIcon_Base_one(
            button_Base_one: button_Base_one,
            iconName_Base_one: isMine_base_one ? "trash" : "ellipsis",
            size_Base_one: size_Base_one,
            color_Base_one: color_Base_one
        )
        button_Base_one.addAction(UIAction { [weak viewController_Base_one] _ in
            guard let vc_base_one = viewController_Base_one else { return }
            addButtonAnimation_Base_one(button_Base_one: button_Base_one)
            onTap_base_one(vc_base_one, isMine_base_one)
        }, for: .touchUpInside)
        return button_Base_one
    }

    /// 按钮按压缩放动画
    private static func addButtonAnimation_Base_one(button_Base_one: UIButton) {
        UIView.animate(withDuration: animationDuration_Base_one, animations: {
            button_Base_one.transform = CGAffineTransform(scaleX: animationScale_Base_one, y: animationScale_Base_one)
        }) { _ in
            UIView.animate(withDuration: animationDuration_Base_one) { button_Base_one.transform = .identity }
        }
    }

    /// 配置 SF Symbol 图标
    private static func configureButtonIcon_Base_one(
        button_Base_one: UIButton,
        iconName_Base_one: String,
        size_Base_one: CGFloat,
        color_Base_one: UIColor
    ) {
        let config_Base_one = UIImage.SymbolConfiguration(pointSize: size_Base_one, weight: .semibold)
        button_Base_one.setImage(UIImage(systemName: iconName_Base_one, withConfiguration: config_Base_one), for: .normal)
        button_Base_one.tintColor = color_Base_one
    }
}
