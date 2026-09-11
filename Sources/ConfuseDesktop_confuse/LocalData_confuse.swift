import Foundation

/// 集中保存应用内置的主题预设，避免设置界面直接维护业务数据。
enum LocalData_confuse {
    static let themePresets_confuse: [ThemePreset_confuse] = [
        ThemePreset_confuse(
            id_confuse: "aurora",
            name_confuse: "极光",
            primaryHex_confuse: "#47C7B2",
            secondaryHex_confuse: "#578FF5"
        ),
        ThemePreset_confuse(
            id_confuse: "coral",
            name_confuse: "珊瑚",
            primaryHex_confuse: "#FF705D",
            secondaryHex_confuse: "#F8C54A"
        ),
        ThemePreset_confuse(
            id_confuse: "forest",
            name_confuse: "森林",
            primaryHex_confuse: "#67C76F",
            secondaryHex_confuse: "#E2B84B"
        ),
        ThemePreset_confuse(
            id_confuse: "ocean",
            name_confuse: "海洋",
            primaryHex_confuse: "#3FA7D6",
            secondaryHex_confuse: "#F07178"
        )
    ]
}
