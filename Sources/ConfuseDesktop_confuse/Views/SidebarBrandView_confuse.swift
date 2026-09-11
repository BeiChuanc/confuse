import SwiftUI

/// 展示侧边栏品牌标识，通过轨道图形、英文品牌名和状态灯建立紧凑清晰的视觉层级。
struct SidebarBrandView_confuse: View {
    /// 返回侧边栏品牌视图。
    var body: some View {
        HStack(spacing: 11) {
            ZStack {
                RoundedRectangle(cornerRadius: 7)
                    .fill(Color.white.opacity(0.055))
                RoundedRectangle(cornerRadius: 7)
                    .stroke(Color.confuseBorder_confuse, lineWidth: 1)
                Circle()
                    .stroke(Color.confuseBlue_confuse.opacity(0.48), lineWidth: 1)
                    .frame(width: 24, height: 11)
                    .rotationEffect(.degrees(-18))
                Circle()
                    .fill(Color.confuseAccent_confuse)
                    .frame(width: 9, height: 9)
                    .shadow(color: Color.confuseAccent_confuse.opacity(0.7), radius: 5)
                Circle()
                    .fill(Color.confuseBlue_confuse)
                    .frame(width: 4, height: 4)
                    .offset(x: 11, y: -4)
            }
            .frame(width: 38, height: 38)

            VStack(alignment: .leading, spacing: 3) {
                Text("APP TOOLS")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("自动化工作台")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.white.opacity(0.4))
            }

            Spacer(minLength: 0)

            Circle()
                .fill(Color.confuseAccent_confuse)
                .frame(width: 6, height: 6)
                .shadow(color: Color.confuseAccent_confuse.opacity(0.55), radius: 4)
        }
        .accessibilityElement(children: .combine)
    }
}
