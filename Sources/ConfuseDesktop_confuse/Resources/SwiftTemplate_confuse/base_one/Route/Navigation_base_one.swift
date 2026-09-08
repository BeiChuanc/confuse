import UIKit

// MARK: 导航类

/// 导航方式枚举
enum NavigationStyle_Base_one {
    /// Push方式（导航栈推入）
    case push_base_one
    /// Present方式（模态展示）
    case present_base_one
    /// Replace方式（替换当前视图控制器）
    case replace_base_one
}

/// 页面导航管理器
/// 功能：统一管理 Push、Present、Replace 及根视图切换
/// 设计：静态方法门面，页面跳转全部收敛到此类
class Navigation_Base_one: NSObject {

    // MARK: - 基础导航方法

    /// 获取当前显示的视图控制器
    static func currentViewController_Base_one() -> UIViewController? {
        UIViewController.currentViewController_Base_one()
    }

    /// 解析来源控制器（未指定时取当前顶层 VC）
    /// 参数：
    /// - from: 指定来源控制器，nil 时自动获取当前顶层
    private static func resolveSourceVC_Base_one(from: UIViewController?) -> UIViewController? {
        from ?? currentViewController_Base_one()
    }

    /// Push方式跳转到指定页面
    static func push_Base_one(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        resolveSourceVC_Base_one(from: from)?.navigationController?.pushViewController(viewController, animated: animated)
    }

    /// Present方式展示指定页面
    static func present_Base_one(viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        resolveSourceVC_Base_one(from: from)?.present(viewController, animated: animated, completion: completion)
    }

    /// Pop返回上一页
    static func pop_Base_one(animated: Bool = true, from: UIViewController? = nil) {
        resolveSourceVC_Base_one(from: from)?.navigationController?.popViewController(animated: animated)
    }

    /// Pop返回到根视图控制器
    static func popToRoot_Base_one(animated: Bool = true, from: UIViewController? = nil) {
        resolveSourceVC_Base_one(from: from)?.navigationController?.popToRootViewController(animated: animated)
    }

    /// Dismiss关闭当前模态页面
    static func dismiss_Base_one(animated: Bool = true, completion: (() -> Void)? = nil, from: UIViewController? = nil) {
        resolveSourceVC_Base_one(from: from)?.dismiss(animated: animated, completion: completion)
    }

    /// Replace方式替换当前页面
    static func replace_Base_one(to viewController: UIViewController, animated: Bool = true, from: UIViewController? = nil) {
        guard let nav_base_one = resolveSourceVC_Base_one(from: from)?.navigationController else {
            print("⚠️ 警告：当前视图控制器没有导航控制器，无法替换")
            return
        }

        var stack_base_one = nav_base_one.viewControllers
        if stack_base_one.isEmpty {
            nav_base_one.pushViewController(viewController, animated: animated)
        } else {
            stack_base_one[stack_base_one.count - 1] = viewController
            nav_base_one.setViewControllers(stack_base_one, animated: animated)
        }
    }

    // MARK: - 通用导航方法

    /// 根据导航方式跳转到指定页面
    /// 参数：
    /// - viewController_base_one: 目标页面
    /// - style_base_one: 导航方式
    /// - wrapInNavigation_base_one: 是否包装导航控制器，nil 时 present 默认包装
    /// - animated_base_one: 是否动画
    /// - completion_base_one: 完成回调
    static func navigateToViewController_Base_one(
        viewController_base_one: UIViewController,
        style_base_one: NavigationStyle_Base_one,
        wrapInNavigation_base_one: Bool? = nil,
        animated_base_one: Bool = true,
        completion_base_one: (() -> Void)? = nil
    ) {
        let shouldWrap_base_one = wrapInNavigation_base_one ?? (style_base_one == .present_base_one)

        switch style_base_one {
        case .push_base_one:
            push_Base_one(to: viewController_base_one, animated: animated_base_one)
            completion_base_one?()

        case .present_base_one:
            let targetVC_base_one = shouldWrap_base_one
                ? createNavigationController_Base_one(rootViewController: viewController_base_one)
                : viewController_base_one
            targetVC_base_one.modalPresentationStyle = .fullScreen
            present_Base_one(viewController: targetVC_base_one, animated: animated_base_one, completion: completion_base_one)

        case .replace_base_one:
            replace_Base_one(to: viewController_base_one, animated: animated_base_one)
            completion_base_one?()
        }
    }

    /// 创建全屏导航控制器
    private static func createNavigationController_Base_one(rootViewController: UIViewController) -> UINavigationController {
        let nav_base_one = UINavigationController(rootViewController: rootViewController)
        nav_base_one.modalPresentationStyle = .fullScreen
        return nav_base_one
    }

    /// 页面跳转简化入口（自动判断是否包装导航控制器）
    private static func navigate_Base_one(
        to viewController_base_one: UIViewController,
        style_base_one: NavigationStyle_Base_one,
        animated_base_one: Bool = true,
        completion_base_one: (() -> Void)? = nil
    ) {
        navigateToViewController_Base_one(
            viewController_base_one: viewController_base_one,
            style_base_one: style_base_one,
            animated_base_one: animated_base_one,
            completion_base_one: completion_base_one
        )
    }

    // MARK: - 主导航

    /// 验证 Window 是否有效
    private static func validateWindow_Base_one(_ window: UIWindow?) -> UIWindow? {
        guard let window else {
            print("❌ 错误：Window为空，无法设置根视图控制器")
            return nil
        }
        return window
    }

    /// 设置根视图控制器到 Tabbar
    static func setRootToTabbar_Base_one(window: UIWindow?) {
        guard let window_base_one = validateWindow_Base_one(window) else { return }

        let nav_base_one = UINavigationController(rootViewController: TabBar_Base_one())
        nav_base_one.navigationBar.isHidden = true
        window_base_one.rootViewController = nav_base_one
        window_base_one.makeKeyAndVisible()
    }

    /// 设置根视图控制器（通用方法）
    static func setRootViewController_Base_one(viewController: UIViewController, window: UIWindow?, animated: Bool = false) {
        guard let window_base_one = validateWindow_Base_one(window) else { return }

        let applyRoot_base_one = { window_base_one.rootViewController = viewController }
        if animated {
            UIView.transition(with: window_base_one, duration: 0.3, options: .transitionCrossDissolve, animations: applyRoot_base_one)
        } else {
            applyRoot_base_one()
        }
        window_base_one.makeKeyAndVisible()
    }

    /// 获取 AppDelegate 中的 Window
    static func getAppWindow_Base_one() -> UIWindow? {
        (UIApplication.shared.delegate as? AppDelegate)?.window
    }

    /// 切换到主 Tabbar（自动获取 Window）
    static func switchToTabbar_Base_one(animated: Bool = true) {
        let window_base_one = getAppWindow_Base_one()
        setRootToTabbar_Base_one(window: window_base_one)

        guard animated else { return }
        window_base_one?.alpha = 0
        UIView.animate(withDuration: 0.3) { window_base_one?.alpha = 1 }
    }

    // MARK: - 登录注册

    static func toLogin_Base_one(
        style_base_one: NavigationStyle_Base_one = .present_base_one,
        animated_base_one: Bool = true,
        completion_base_one: (() -> Void)? = nil
    ) {
        navigate_Base_one(to: Login_Base_one(), style_base_one: style_base_one, animated_base_one: animated_base_one, completion_base_one: completion_base_one)
    }

    static func toRegister_Base_one(
        style_base_one: NavigationStyle_Base_one = .present_base_one,
        animated_base_one: Bool = true,
        completion_base_one: (() -> Void)? = nil
    ) {
        navigate_Base_one(to: Register_Base_one(), style_base_one: style_base_one, animated_base_one: animated_base_one, completion_base_one: completion_base_one)
    }

    // MARK: - 首页 / 发现

    static func toHome_Base_one(style_base_one: NavigationStyle_Base_one = .push_base_one, animated_base_one: Bool = true) {
        navigate_Base_one(to: Home_Base_one(), style_base_one: style_base_one, animated_base_one: animated_base_one)
    }

    static func toDiscover_Base_one(style_base_one: NavigationStyle_Base_one = .push_base_one, animated_base_one: Bool = true) {
        navigate_Base_one(to: Discover_Base_one(), style_base_one: style_base_one, animated_base_one: animated_base_one)
    }

    static func toTitleDetail_Base_one(
        titleModel_base_one: TitleModel_Base_one,
        style_base_one: NavigationStyle_Base_one = .push_base_one,
        animated_base_one: Bool = true
    ) {
        let detailVC_base_one = Detail_Base_one()
        detailVC_base_one.titleModel_Base_one = titleModel_base_one
        navigate_Base_one(to: detailVC_base_one, style_base_one: style_base_one, animated_base_one: animated_base_one)
    }

    // MARK: - 发布

    static func toRelease_Base_one(
        style_base_one: NavigationStyle_Base_one = .present_base_one,
        animated_base_one: Bool = true,
        completion_base_one: (() -> Void)? = nil
    ) {
        navigate_Base_one(to: Release_Base_one(), style_base_one: style_base_one, animated_base_one: animated_base_one, completion_base_one: completion_base_one)
    }

    // MARK: - 消息

    static func toMessageList_Base_one(style_base_one: NavigationStyle_Base_one = .push_base_one, animated_base_one: Bool = true) {
        navigate_Base_one(to: MessageList_Base_one(), style_base_one: style_base_one, animated_base_one: animated_base_one)
    }

    static func toMessageUser_Base_one(
        with userModel_base_one: PrewUserModel_Base_one,
        style_base_one: NavigationStyle_Base_one = .push_base_one,
        animated_base_one: Bool = true,
        completion_base_one: (() -> Void)? = nil
    ) {
        let messageUserVC_base_one = MessageUser_Base_one()
        messageUserVC_base_one.userModel_Base_one = userModel_base_one
        navigate_Base_one(to: messageUserVC_base_one, style_base_one: style_base_one, animated_base_one: animated_base_one, completion_base_one: completion_base_one)
    }

    // MARK: - 个人中心

    static func toMe_Base_one(style_base_one: NavigationStyle_Base_one = .push_base_one, animated_base_one: Bool = true) {
        navigate_Base_one(to: Me_Base_one(), style_base_one: style_base_one, animated_base_one: animated_base_one)
    }

    static func toMe_Base_one(
        with userModel_base_one: LoginUserModel_Base_one,
        style_base_one: NavigationStyle_Base_one = .push_base_one,
        animated_base_one: Bool = true
    ) {
        let meVC_base_one = Me_Base_one()
        meVC_base_one.meModel_Base_one = userModel_base_one
        navigate_Base_one(to: meVC_base_one, style_base_one: style_base_one, animated_base_one: animated_base_one)
    }

    static func toUserInfo_Base_one(
        with userModel_base_one: PrewUserModel_Base_one,
        style_base_one: NavigationStyle_Base_one = .push_base_one,
        animated_base_one: Bool = true,
        completion_base_one: (() -> Void)? = nil
    ) {
        let userInfoVC_base_one = UserInfo_Base_one()
        userInfoVC_base_one.userModel_Base_one = userModel_base_one
        navigate_Base_one(to: userInfoVC_base_one, style_base_one: style_base_one, animated_base_one: animated_base_one, completion_base_one: completion_base_one)
    }

    static func toEditInfo_Base_one(style_base_one: NavigationStyle_Base_one = .push_base_one, animated_base_one: Bool = true) {
        navigate_Base_one(to: EditInfo_Base_one(), style_base_one: style_base_one, animated_base_one: animated_base_one)
    }

    static func toSetting_Base_one(style_base_one: NavigationStyle_Base_one = .push_base_one, animated_base_one: Bool = true) {
        navigate_Base_one(to: Setting_Base_one(), style_base_one: style_base_one, animated_base_one: animated_base_one)
    }
}

// MARK: - 举报拉黑后安全导航

extension Navigation_Base_one {

    /// 举报/拉黑用户后，清除导航堆栈中与该用户相关的页面并返回安全位置
    /// 处理两种情形：
    /// 1. 当前 VC 以 present 展示：先 dismiss，再操作 presentingVC 的导航栈
    /// 2. 当前 VC 在导航栈中：直接 pop 到安全位置
    /// 参数：
    /// - viewController_base_one: 发起举报操作的视图控制器
    static func popToSafeStateAfterBlock_Base_one(from viewController_base_one: UIViewController) {
        if let presentingVC_base_one = viewController_base_one.presentingViewController {
            viewController_base_one.dismiss(animated: true) {
                let nav_base_one = (presentingVC_base_one as? UINavigationController) ?? presentingVC_base_one.navigationController
                nav_base_one.map { popStackToSafeVC_Base_one(nav: $0) }
            }
        } else {
            viewController_base_one.navigationController.map { popStackToSafeVC_Base_one(nav: $0) }
        }
    }

    /// 在导航栈中从栈顶向下查找最近的安全 VC 并 pop 到该位置
    /// 排除：帖子详情、消息聊天、TabBar 五个子页面；若均为排除类型则 popToRoot
    private static func popStackToSafeVC_Base_one(nav: UINavigationController) {
        let excludedTypes_base_one: [AnyClass] = [
            Detail_Base_one.self, MessageUser_Base_one.self,
            Home_Base_one.self, Discover_Base_one.self, Release_Base_one.self,
            MessageList_Base_one.self, Me_Base_one.self
        ]

        if let safeVC_base_one = nav.viewControllers.reversed().first(where: { vc in
            !excludedTypes_base_one.contains { vc.isKind(of: $0) }
        }) {
            guard safeVC_base_one !== nav.topViewController else { return }
            nav.popToViewController(safeVC_base_one, animated: true)
        } else {
            print("⚠️ 导航堆栈中无安全 VC，已返回根视图控制器")
            nav.popToRootViewController(animated: true)
        }
    }
}
