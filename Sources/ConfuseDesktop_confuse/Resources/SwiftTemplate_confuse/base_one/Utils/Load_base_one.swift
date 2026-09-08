import Foundation
import ProgressHUD
import UIKit

// MARK: 工具类

/// 工具类
class Load_Base_one: NSObject {
    
    // MARK: - HUD配置
    
    /// HUD全局配置
    /// - Parameter fontSize_Base_one: 字体大小，默认30
    static func setupHUDConfig_Base_one(fontSize_Base_one: CGFloat = 25) {
        // 设置字体为圆体艺术字，提升视觉效果
        if let roundedFont_Base_one = UIFont(name: "AvenirNext-Medium", size: fontSize_Base_one) {
            ProgressHUD.fontStatus = roundedFont_Base_one
        } else if let roundedFont_Base_one = UIFont(name: "Helvetica Neue", size: fontSize_Base_one) {
            // 备选艺术字体
            ProgressHUD.fontStatus = roundedFont_Base_one
        } else {
            // 最终备选方案：使用系统加粗字体
            ProgressHUD.fontStatus = UIFont.systemFont(ofSize: fontSize_Base_one, weight: .semibold)
        }
        
        // 设置文字颜色（深色，确保清晰可见）
        ProgressHUD.colorStatus = .label
        
        // 设置动画类型
        ProgressHUD.animationType = .circleStrokeSpin
        
        // 设置媒体大小（与字体大小成比例）
        ProgressHUD.mediaSize = 40
        
        // 设置HUD背景和边距，让文字有更好的展示空间
        ProgressHUD.colorBackground = .systemBackground.withAlphaComponent(0.95)
        ProgressHUD.colorHUD = .systemGray6.withAlphaComponent(0.98)
        ProgressHUD.marginSize = CGFloat(20)
    }
    
    // MARK: - 加载动画
    
    /// 显示加载动画
    static func showLoading_Base_one(message_Base_one: String? = nil) {
        if let message_Base_one = message_Base_one, !message_Base_one.isEmpty {
            ProgressHUD.animate(message_Base_one)
        } else {
            ProgressHUD.animate()
        }
    }
    
    /// 显示带进度的加载动画
    static func showProgress_Base_one(
        progress_Base_one: CGFloat,
        message_Base_one: String? = nil
    ) {
        if let message_Base_one = message_Base_one, !message_Base_one.isEmpty {
            ProgressHUD.progress(message_Base_one, progress_Base_one)
        } else {
            ProgressHUD.progress(progress_Base_one)
        }
    }
    
    /// 取消加载动画
    static func dismissLoading_Base_one() {
        ProgressHUD.dismiss()
    }
    
    /// 延迟取消加载动画
    static func dismissLoadingWithDelay_Base_one(delay_Base_one: TimeInterval = 0.5) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay_Base_one) {
            ProgressHUD.dismiss()
        }
    }
    
    // MARK: - 成功提示
    
    /// 显示成功提示
    static func showSuccess_Base_one(
        message_Base_one: String = "Success",
        image_Base_one: UIImage? = nil,
        delay_Base_one: TimeInterval = 1.5
    ) {
        ProgressHUD.succeed(message_Base_one)
        dismissLoadingWithDelay_Base_one(delay_Base_one: delay_Base_one)
    }
    
    // MARK: - 错误提示
    
    /// 显示错误提示
    static func showError_Base_one(
        message_Base_one: String = "Error",
        image_Base_one: UIImage? = nil,
        delay_Base_one: TimeInterval = 2.0
    ) {
        ProgressHUD.failed(message_Base_one)
        dismissLoadingWithDelay_Base_one(delay_Base_one: delay_Base_one)
    }
    
    // MARK: - 普通提示
    
    /// 显示普通文字提示
    static func showMessage_Base_one(
        message_Base_one: String,
        delay_Base_one: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Base_one, delay: delay_Base_one)
    }
    
    /// 显示带图标的提示
    static func showMessageWithImage_Base_one(
        message_Base_one: String,
        image_Base_one: UIImage,
        delay_Base_one: TimeInterval = 1.5
    ) {
        ProgressHUD.banner("", message_Base_one, delay: delay_Base_one)
    }
    
    /// 显示符号图标提示
    static func showMessageWithSymbol_Base_one(
        message_Base_one: String,
        symbolName_Base_one: String,
        delay_Base_one: TimeInterval = 1.5
    ) {
        ProgressHUD.symbol(message_Base_one, name: symbolName_Base_one)
        dismissLoadingWithDelay_Base_one(delay_Base_one: delay_Base_one)
    }
    
    // MARK: - 特殊提示
    
    /// 显示警告提示
    static func showWarning_Base_one(
        message_Base_one: String,
        delay_Base_one: TimeInterval = 2.0
    ) {
        showMessageWithSymbol_Base_one(
            message_Base_one: message_Base_one,
            symbolName_Base_one: "exclamationmark.triangle.fill",
            delay_Base_one: delay_Base_one
        )
    }
    
    /// 显示信息提示
    static func showInfo_Base_one(
        message_Base_one: String,
        delay_Base_one: TimeInterval = 1.5
    ) {
        showMessageWithSymbol_Base_one(
            message_Base_one: message_Base_one,
            symbolName_Base_one: "info.circle.fill",
            delay_Base_one: delay_Base_one
        )
    }
    
    // MARK: - 横幅提示
    
    /// 显示顶部横幅提示
    static func showBanner_Base_one(
        title_Base_one: String = "",
        message_Base_one: String,
        delay_Base_one: TimeInterval = 2.0
    ) {
        ProgressHUD.banner(title_Base_one, message_Base_one, delay: delay_Base_one)
    }
    
    // MARK: - 实用工具方法
    
    /// 移除所有HUD
    static func removeAll_Base_one() {
        ProgressHUD.remove()
    }
}
