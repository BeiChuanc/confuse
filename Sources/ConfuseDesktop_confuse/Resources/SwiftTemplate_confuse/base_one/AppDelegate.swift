import UIKit
import IQKeyboardManager

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 初始化键盘管理器
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        
        // 配置HUD全局样式
        Load_Base_one.setupHUDConfig_Base_one(fontSize_Base_one: 16)
        
        // 初始化本地数据
        LocalData_Base_one.shared_Base_one.initData_Base_one()
        
        // 初始化用户模块
        Task { @MainActor in
            UserViewModel_Base_one.shared_Base_one.initUser_Base_one()
        }
        
        // 初始化帖子模块
        Task { @MainActor in
            TitleViewModel_Base_one.shared_Base_one.initPosts_Base_one()
        }
        
        // 初始化消息模块
        Task { @MainActor in
            MessageViewModel_Base_one.shared_Base_one.initChat_Base_one()
        }
        
        // 设置窗口
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .clear
        Navigation_Base_one.setRootToTabbar_Base_one(window: window)
        
        return true
    }

}

