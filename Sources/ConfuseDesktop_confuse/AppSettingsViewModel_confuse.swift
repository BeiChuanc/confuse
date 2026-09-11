import AppKit
import Foundation
import SwiftUI

/// 管理全局主题与桌宠设置，通过 UserDefaults 持久化并使用 ObservableObject 驱动界面实时刷新。
final class AppSettingsViewModel_confuse: ObservableObject {
    static let shared_confuse = AppSettingsViewModel_confuse()

    @Published var themeMode_confuse: ThemeColorMode_confuse {
        didSet { persistSettings_confuse() }
    }
    @Published var primaryHex_confuse: String {
        didSet { persistSettings_confuse() }
    }
    @Published var secondaryHex_confuse: String {
        didSet { persistSettings_confuse() }
    }
    @Published var sidebarPet_confuse: SidebarPet_confuse {
        didSet { persistSettings_confuse() }
    }

    private let defaults_confuse: UserDefaults

    private enum StorageKey_confuse {
        static let themeMode_confuse = "confuse.settings.themeMode"
        static let primaryHex_confuse = "confuse.settings.primaryHex"
        static let secondaryHex_confuse = "confuse.settings.secondaryHex"
        static let sidebarPet_confuse = "confuse.settings.sidebarPet"
    }

    /// 从本地设置读取主题与桌宠状态；首次启动使用极光混色和轨道探针。
    /// - Parameter defaults_confuse: 用于保存应用设置的 UserDefaults 实例。
    init(defaults_confuse: UserDefaults = .standard) {
        self.defaults_confuse = defaults_confuse
        themeMode_confuse = ThemeColorMode_confuse(
            rawValue: defaults_confuse.string(forKey: StorageKey_confuse.themeMode_confuse) ?? ""
        ) ?? .blended_confuse
        primaryHex_confuse = defaults_confuse.string(
            forKey: StorageKey_confuse.primaryHex_confuse
        ) ?? "#47C7B2"
        secondaryHex_confuse = defaults_confuse.string(
            forKey: StorageKey_confuse.secondaryHex_confuse
        ) ?? "#578FF5"
        sidebarPet_confuse = SidebarPet_confuse(
            rawValue: defaults_confuse.string(forKey: StorageKey_confuse.sidebarPet_confuse) ?? ""
        ) ?? .orbitProbe_confuse
    }

    /// 返回当前主题的主色。
    /// - Returns: 可直接用于 SwiftUI 的主强调色。
    var primaryColor_confuse: Color {
        Color(hex_confuse: primaryHex_confuse)
    }

    /// 返回当前主题的辅助色；单色模式下与主色保持一致。
    /// - Returns: 可直接用于 SwiftUI 的辅助强调色。
    var secondaryColor_confuse: Color {
        themeMode_confuse == .solid_confuse
            ? primaryColor_confuse
            : Color(hex_confuse: secondaryHex_confuse)
    }

    /// 返回随主题颜色变化的深色主背景。
    /// - Returns: 保持白色文字对比度的主题背景色。
    var backgroundColor_confuse: Color {
        let components_confuse = blendedComponents_confuse
        return Color(
            red: 0.032 + components_confuse.red_confuse * 0.082,
            green: 0.032 + components_confuse.green_confuse * 0.082,
            blue: 0.038 + components_confuse.blue_confuse * 0.092
        )
    }

    /// 返回比主背景略亮的主题面板色。
    /// - Returns: 用于卡片与表单容器的主题面板色。
    var panelColor_confuse: Color {
        let components_confuse = blendedComponents_confuse
        return Color(
            red: 0.065 + components_confuse.red_confuse * 0.105,
            green: 0.065 + components_confuse.green_confuse * 0.105,
            blue: 0.075 + components_confuse.blue_confuse * 0.115
        )
    }

    /// 返回比主背景更深的侧边栏主题色。
    /// - Returns: 用于区分导航区域的深色主题色。
    var sidebarColor_confuse: Color {
        let components_confuse = blendedComponents_confuse
        return Color(
            red: 0.020 + components_confuse.red_confuse * 0.050,
            green: 0.020 + components_confuse.green_confuse * 0.050,
            blue: 0.025 + components_confuse.blue_confuse * 0.058
        )
    }

    /// 返回当前主题参与背景计算的融合颜色分量。
    private var blendedComponents_confuse: (
        red_confuse: Double,
        green_confuse: Double,
        blue_confuse: Double
    ) {
        let primaryComponents_confuse = rgbComponents_confuse(hex_confuse: primaryHex_confuse)
        guard themeMode_confuse == .blended_confuse else {
            return primaryComponents_confuse
        }
        let secondaryComponents_confuse = rgbComponents_confuse(hex_confuse: secondaryHex_confuse)
        return (
            (primaryComponents_confuse.red_confuse + secondaryComponents_confuse.red_confuse) / 2,
            (primaryComponents_confuse.green_confuse + secondaryComponents_confuse.green_confuse) / 2,
            (primaryComponents_confuse.blue_confuse + secondaryComponents_confuse.blue_confuse) / 2
        )
    }

    /// 应用用户选择的主题预设，并保留当前单色或混色模式。
    /// - Parameter preset_confuse: 待应用的主题预设。
    func applyPreset_confuse(preset_confuse: ThemePreset_confuse) {
        primaryHex_confuse = preset_confuse.primaryHex_confuse
        secondaryHex_confuse = preset_confuse.secondaryHex_confuse
    }

    /// 将颜色选择器返回的颜色保存为主色。
    /// - Parameter color_confuse: 用户选择的 SwiftUI 颜色。
    func updatePrimaryColor_confuse(color_confuse: Color) {
        primaryHex_confuse = color_confuse.hexString_confuse(fallback_confuse: primaryHex_confuse)
    }

    /// 将颜色选择器返回的颜色保存为辅助色。
    /// - Parameter color_confuse: 用户选择的 SwiftUI 颜色。
    func updateSecondaryColor_confuse(color_confuse: Color) {
        secondaryHex_confuse = color_confuse.hexString_confuse(fallback_confuse: secondaryHex_confuse)
    }

    /// 根据开关状态显示或隐藏用户选定的轨道探针桌宠。
    /// - Parameter isEnabled_confuse: 是否在侧边栏显示桌宠。
    func setSidebarPetEnabled_confuse(isEnabled_confuse: Bool) {
        sidebarPet_confuse = isEnabled_confuse ? .orbitProbe_confuse : .hidden_confuse
    }

    /// 恢复默认的极光混色与轨道探针设置。
    func restoreDefaults_confuse() {
        themeMode_confuse = .blended_confuse
        primaryHex_confuse = "#47C7B2"
        secondaryHex_confuse = "#578FF5"
        sidebarPet_confuse = .orbitProbe_confuse
    }

    /// 将当前设置写入 UserDefaults。
    private func persistSettings_confuse() {
        defaults_confuse.set(themeMode_confuse.rawValue, forKey: StorageKey_confuse.themeMode_confuse)
        defaults_confuse.set(primaryHex_confuse, forKey: StorageKey_confuse.primaryHex_confuse)
        defaults_confuse.set(secondaryHex_confuse, forKey: StorageKey_confuse.secondaryHex_confuse)
        defaults_confuse.set(sidebarPet_confuse.rawValue, forKey: StorageKey_confuse.sidebarPet_confuse)
    }

    /// 将十六进制颜色拆分为标准化 RGB 分量，无效输入使用默认极光主色。
    /// - Parameter hex_confuse: 支持 `#RRGGBB` 或 `RRGGBB` 格式的颜色文本。
    /// - Returns: 取值范围为 0 至 1 的红、绿、蓝分量。
    private func rgbComponents_confuse(hex_confuse: String) -> (
        red_confuse: Double,
        green_confuse: Double,
        blue_confuse: Double
    ) {
        let value_confuse = hex_confuse.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var rgbValue_confuse: UInt64 = 0
        guard value_confuse.count == 6,
              Scanner(string: value_confuse).scanHexInt64(&rgbValue_confuse) else {
            return (0.278, 0.780, 0.698)
        }
        return (
            Double((rgbValue_confuse >> 16) & 0xFF) / 255,
            Double((rgbValue_confuse >> 8) & 0xFF) / 255,
            Double(rgbValue_confuse & 0xFF) / 255
        )
    }
}
