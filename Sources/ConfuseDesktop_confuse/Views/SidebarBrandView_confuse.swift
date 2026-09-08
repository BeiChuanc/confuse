import SwiftUI

/// 展示侧边栏品牌标识，通过紧凑图标底座和双层文字建立清晰的视觉层级。
struct SidebarBrandView_confuse: View {
    /// 返回侧边栏品牌视图。
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.confusePanel_confuse)
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.confuseAccent_confuse.opacity(0.32), lineWidth: 1)
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.confuseAccent_confuse)
            }
            .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: 2) {
                Text("应用工具")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("工作台")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white.opacity(0.38))
            }

            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }
}

/// 展示侧边栏底部装饰图案，以规则点阵和连接符号填充空白区域。
struct SidebarFooterArtwork_confuse: View {
    /// 返回侧边栏底部装饰视图。
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(systemName: "command")
                .font(.system(size: 84, weight: .thin))
                .foregroundStyle(.white.opacity(0.025))
                .offset(x: 16, y: 18)

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Image(systemName: "point.3.connected.trianglepath.dotted")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color.confuseAccent_confuse.opacity(0.72))
                    Spacer()
                    Image(systemName: "sparkles")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.confuseBlue_confuse.opacity(0.65))
                }

                LazyVGrid(
                    columns: Array(
                        repeating: GridItem(.fixed(7), spacing: 8),
                        count: 8
                    ),
                    alignment: .leading,
                    spacing: 8
                ) {
                    ForEach(0..<32, id: \.self) { index_confuse in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(tileColor_confuse(index_confuse: index_confuse))
                            .frame(width: 7, height: 7)
                            .opacity(tileOpacity_confuse(index_confuse: index_confuse))
                    }
                }

                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { index_confuse in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(index_confuse == 1 ? Color.confuseBlue_confuse : Color.confuseAccent_confuse)
                            .frame(maxWidth: .infinity)
                            .frame(height: 4)
                            .opacity(index_confuse == 1 ? 0.34 : 0.20)
                    }
                }
            }
            .padding(.top, 16)
        }
        .frame(height: 122)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.white.opacity(0.07))
                .frame(height: 1)
        }
        .accessibilityHidden(true)
    }

    /// 返回指定点阵单元的颜色。
    /// - Parameter index_confuse: 点阵单元索引。
    /// - Returns: 对应强调色或辅助强调色。
    private func tileColor_confuse(index_confuse: Int) -> Color {
        index_confuse.isMultiple(of: 5) ? Color.confuseBlue_confuse : Color.confuseAccent_confuse
    }

    /// 返回指定点阵单元的透明度，形成稳定的明暗节奏。
    /// - Parameter index_confuse: 点阵单元索引。
    /// - Returns: 当前单元的透明度。
    private func tileOpacity_confuse(index_confuse: Int) -> Double {
        switch index_confuse % 4 {
        case 0: return 0.62
        case 1: return 0.34
        case 2: return 0.18
        default: return 0.42
        }
    }
}
