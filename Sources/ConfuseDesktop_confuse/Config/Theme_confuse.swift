import AppKit
import SwiftUI

/// 集中定义应用的颜色、圆角和间距，避免界面文件散落重复样式。
extension Color {
    /// 应用主背景色。
    static var confuseBackground_confuse: Color {
        AppSettingsViewModel_confuse.shared_confuse.backgroundColor_confuse
    }
    /// 应用面板色。
    static var confusePanel_confuse: Color {
        AppSettingsViewModel_confuse.shared_confuse.panelColor_confuse
    }
    /// 应用侧边栏背景色。
    static var confuseSidebar_confuse: Color {
        AppSettingsViewModel_confuse.shared_confuse.sidebarColor_confuse
    }
    /// 应用强调色。
    static var confuseAccent_confuse: Color {
        AppSettingsViewModel_confuse.shared_confuse.primaryColor_confuse
    }
    /// 应用辅助强调色。
    static var confuseBlue_confuse: Color {
        AppSettingsViewModel_confuse.shared_confuse.secondaryColor_confuse
    }
    /// 应用边框色。
    static let confuseBorder_confuse = Color.white.opacity(0.10)

    /// 根据十六进制字符串创建颜色，无效输入会回退到应用默认强调色。
    /// - Parameter hex_confuse: 支持 `#RRGGBB` 或 `RRGGBB` 格式的颜色文本。
    init(hex_confuse: String) {
        let value_confuse = hex_confuse.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var rgb_confuse: UInt64 = 0
        guard value_confuse.count == 6,
              Scanner(string: value_confuse).scanHexInt64(&rgb_confuse) else {
            self.init(red: 0.28, green: 0.78, blue: 0.69)
            return
        }
        self.init(
            red: Double((rgb_confuse >> 16) & 0xFF) / 255,
            green: Double((rgb_confuse >> 8) & 0xFF) / 255,
            blue: Double(rgb_confuse & 0xFF) / 255
        )
    }

    /// 将 SwiftUI 颜色转换为十六进制文本，转换失败时返回指定回退值。
    /// - Parameter fallback_confuse: 无法转换颜色空间时返回的颜色文本。
    /// - Returns: `#RRGGBB` 格式的颜色文本。
    func hexString_confuse(fallback_confuse: String) -> String {
        guard let color_confuse = NSColor(self).usingColorSpace(.sRGB) else {
            return fallback_confuse
        }
        return String(
            format: "#%02X%02X%02X",
            Int(round(color_confuse.redComponent * 255)),
            Int(round(color_confuse.greenComponent * 255)),
            Int(round(color_confuse.blueComponent * 255))
        )
    }
}
