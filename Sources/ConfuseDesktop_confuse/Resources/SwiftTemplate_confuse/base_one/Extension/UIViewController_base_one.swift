import Foundation
import UIKit

extension UIViewController {
    
    static func currentViewController_Base_one(view_Base_one: UIViewController? = nil) -> UIViewController? {
        var baseViewContrller_Base_one = view_Base_one
        if baseViewContrller_Base_one == nil {
            if #available(iOS 13.0, *) {
                let windowScene = UIApplication.shared.connectedScenes
                   .first { $0.activationState == .foregroundActive } as? UIWindowScene
                baseViewContrller_Base_one = windowScene?.windows.first?.rootViewController
            } else {
                baseViewContrller_Base_one = UIApplication.shared.keyWindow?.rootViewController
            }
        }
        if let UINav_Base_one = baseViewContrller_Base_one as? UINavigationController {
            return currentViewController_Base_one(view_Base_one: UINav_Base_one.visibleViewController)
        } else if let UITab_Base_one = baseViewContrller_Base_one as? UITabBarController {
            return currentViewController_Base_one(view_Base_one: UITab_Base_one.selectedViewController)
        } else if let preView_Base_one = baseViewContrller_Base_one?.presentedViewController {
            return currentViewController_Base_one(view_Base_one: preView_Base_one)
        }
        return baseViewContrller_Base_one
    }
}

// 拓展Xcode中可视化的属性设置
extension UIView {

    @IBInspectable
    var radius: CGFloat{
        get{
            return layer.cornerRadius
        }
        set{

            clipsToBounds = true
            self.layer.cornerRadius = newValue
        }

    }
}
