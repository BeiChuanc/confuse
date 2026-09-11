import SwiftUI

/// 绘制用户选定的轨道探针桌宠，通过原生 SwiftUI 动画实现悬浮、轨道旋转和核心呼吸。
struct OrbitProbePetView_confuse: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion_confuse
    @State private var isFloating_confuse = false
    @State private var isOrbiting_confuse = false
    @State private var isPulsing_confuse = false

    /// 返回适配侧边栏底部空间的动态轨道探针。
    var body: some View {
        VStack(spacing: 3) {
            ZStack {
                Ellipse()
                    .stroke(Color.confuseBlue_confuse.opacity(0.24), lineWidth: 1)
                    .frame(width: 128, height: 45)
                    .rotationEffect(.degrees(11))

                ZStack {
                    Ellipse()
                        .stroke(
                            Color.confuseAccent_confuse.opacity(0.62),
                            style: StrokeStyle(lineWidth: 1, dash: [4, 5])
                        )
                        .frame(width: 112, height: 38)

                    Circle()
                        .fill(Color.confuseBlue_confuse)
                        .frame(width: 8, height: 8)
                        .overlay(Circle().stroke(Color.white.opacity(0.65), lineWidth: 1))
                        .offset(x: 55)
                }
                .rotationEffect(.degrees(isOrbiting_confuse ? 360 : 0))

                VStack(spacing: -1) {
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.32))
                            .frame(width: 52, height: 52)
                        Circle()
                            .stroke(Color.confuseBlue_confuse.opacity(0.9), lineWidth: 1.5)
                            .frame(width: 52, height: 52)
                        Circle()
                            .fill(Color.confuseAccent_confuse.opacity(0.18))
                            .frame(width: 31, height: 31)
                            .scaleEffect(isPulsing_confuse ? 1.13 : 0.86)
                        Circle()
                            .fill(Color.confuseAccent_confuse)
                            .frame(width: 15, height: 15)
                            .shadow(color: Color.confuseAccent_confuse.opacity(0.72), radius: 8)
                        Circle()
                            .fill(Color.white.opacity(0.9))
                            .frame(width: 5, height: 5)
                            .offset(x: -3, y: -3)
                    }

                    HStack(spacing: 18) {
                        Capsule()
                            .fill(Color.confuseBlue_confuse.opacity(0.76))
                            .frame(width: 3, height: 14)
                            .rotationEffect(.degrees(24))
                        Capsule()
                            .fill(Color.confuseBlue_confuse.opacity(0.76))
                            .frame(width: 3, height: 14)
                            .rotationEffect(.degrees(-24))
                    }
                }
                .offset(y: isFloating_confuse ? -4 : 3)
            }
            .frame(width: 152, height: 84)

            HStack(spacing: 6) {
                Circle()
                    .fill(Color.confuseAccent_confuse)
                    .frame(width: 5, height: 5)
                Text("轨道探针")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.58))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 108)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.confuseBorder_confuse)
                .frame(height: 1)
        }
        .onAppear {
            guard !reduceMotion_confuse else { return }
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                isFloating_confuse = true
            }
            withAnimation(.linear(duration: 4.2).repeatForever(autoreverses: false)) {
                isOrbiting_confuse = true
            }
            withAnimation(.easeInOut(duration: 1.55).repeatForever(autoreverses: true)) {
                isPulsing_confuse = true
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("轨道探针动态桌宠")
    }
}
