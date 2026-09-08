import SwiftUI

/// 集中定义应用的颜色、圆角和间距，避免界面文件散落重复样式。
extension Color {
    /// 应用主背景色。
    static let confuseBackground_confuse = Color(red: 0.055, green: 0.071, blue: 0.102)
    /// 应用面板色。
    static let confusePanel_confuse = Color(red: 0.098, green: 0.122, blue: 0.169)
    /// 应用强调色。
    static let confuseAccent_confuse = Color(red: 0.28, green: 0.78, blue: 0.69)
    /// 应用辅助强调色。
    static let confuseBlue_confuse = Color(red: 0.34, green: 0.57, blue: 0.96)
    /// 应用边框色。
    static let confuseBorder_confuse = Color.white.opacity(0.10)
}
