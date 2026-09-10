import SwiftUI
import UniformTypeIdentifiers

/// 展示 Codemagic 项目选择、Profile 信息、API 文件和三步自动化流程。
///
/// 页面仅负责响应式展示和拖拽事件转发，项目解析、文件校验和浏览器任务均由
/// CodeMagicAutomationViewModel_confuse 处理。
struct CodeMagicAutomationView_confuse: View {
    @ObservedObject var viewModel_confuse: CodeMagicAutomationViewModel_confuse
    @State private var isProjectDropTargeted_confuse = false
    @State private var isAPIKeyDropTargeted_confuse = false

    /// 返回云端构建完整页面并承载错误弹窗。
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header_confuse
                browserPanel_confuse
                projectPanel_confuse
                apiKeyPanel_confuse
                workflowPanel_confuse
                progressPanel_confuse
            }
            .padding(.horizontal, 34)
            .padding(.vertical, 30)
        }
        .alert("云端构建失败", isPresented: $viewModel_confuse.isShowingAlert_confuse) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(viewModel_confuse.alertMessage_confuse)
        }
    }

    /// 返回页面标题和当前运行状态。
    private var header_confuse: some View {
        HStack(alignment: .top, spacing: 18) {
            VStack(alignment: .leading, spacing: 7) {
                Text("云端构建")
                    .font(.system(size: 27, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("复用当前 Chrome 登录状态，自动配置 Codemagic 签名资源。")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.52))
            }
            Spacer()
            HStack(spacing: 7) {
                Circle()
                    .fill(viewModel_confuse.isRunning_confuse ? Color.orange : Color.confuseAccent_confuse)
                    .frame(width: 7, height: 7)
                Text(viewModel_confuse.statusText_confuse)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.75))
            }
            .padding(.horizontal, 11)
            .padding(.vertical, 7)
            .background(Color.white.opacity(0.07))
            .clipShape(Capsule())
        }
    }

    /// 返回浏览器助手状态和更新入口。
    private var browserPanel_confuse: some View {
        HStack(spacing: 12) {
            Image(systemName: viewModel_confuse.isExtensionPrepared_confuse
                ? "checkmark.circle.fill"
                : "puzzlepiece.extension.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(viewModel_confuse.isExtensionPrepared_confuse
                    ? Color.confuseAccent_confuse
                    : Color.orange)
                .frame(width: 38, height: 38)
                .background(Color.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading, spacing: 4) {
                Text("App Tools 浏览器助手")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                Text(viewModel_confuse.isExtensionPrepared_confuse
                    ? "浏览器助手已准备，应用更新后请在 Chrome 中重新加载。"
                    : "执行 Codemagic 自动化前请先准备浏览器助手。")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.44))
            }
            Spacer()
            Button {
                viewModel_confuse.prepareBrowserAssistant_confuse()
            } label: {
                Label("更新浏览器助手", systemImage: "arrow.triangle.2.circlepath")
            }
            .buttonStyle(.bordered)
            .tint(Color.confuseBlue_confuse)
            .disabled(viewModel_confuse.isRunning_confuse)
        }
        .codeMagicPanelStyle_confuse()
    }

    /// 返回项目选择、拖入区域和自动读取的 Profile 字段。
    private var projectPanel_confuse: some View {
        VStack(alignment: .leading, spacing: 14) {
            panelTitle_confuse(
                title_confuse: "项目与 Profile",
                subtitle_confuse: "应用会从 PROFILE 目录读取 <项目名>_profile.txt。"
            )
            HStack(spacing: 10) {
                Image(systemName: "folder.fill")
                    .foregroundStyle(Color.confuseBlue_confuse)
                Text(viewModel_confuse.projectPath_confuse.isEmpty
                    ? "尚未选择项目"
                    : viewModel_confuse.projectPath_confuse)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.white.opacity(viewModel_confuse.projectPath_confuse.isEmpty ? 0.34 : 0.80))
                Spacer()
                Button("选择项目") { viewModel_confuse.chooseProject_confuse() }
                    .buttonStyle(.bordered)
                    .disabled(viewModel_confuse.isRunning_confuse)
            }
            .padding(12)
            .background(Color.black.opacity(0.16))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            dropArea_confuse(
                title_confuse: "将项目拖到这里",
                subtitle_confuse: "支持项目文件夹或 .xcodeproj",
                iconName_confuse: "folder.badge.plus",
                isTargeted_confuse: isProjectDropTargeted_confuse
            )
            .onDrop(of: [UTType.fileURL.identifier], isTargeted: $isProjectDropTargeted_confuse) {
                providers_confuse in
                acceptDrop_confuse(providers_confuse: providers_confuse) { url_confuse in
                    viewModel_confuse.acceptProject_confuse(url_confuse: url_confuse)
                }
            }

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 210), spacing: 10)],
                alignment: .leading,
                spacing: 10
            ) {
                valueItem_confuse(title_confuse: "项目名称", value_confuse: viewModel_confuse.projectName_confuse)
                valueItem_confuse(title_confuse: "应用包标识", value_confuse: viewModel_confuse.bundleID_confuse)
                valueItem_confuse(title_confuse: "签发者 ID", value_confuse: viewModel_confuse.issuerID_confuse)
                valueItem_confuse(title_confuse: "密钥 ID", value_confuse: viewModel_confuse.keyID_confuse)
            }
        }
        .codeMagicPanelStyle_confuse()
    }

    /// 返回 `.p8` API 文件选择和拖入区域。
    private var apiKeyPanel_confuse: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 14) {
                panelTitle_confuse(
                    title_confuse: "App Store Connect API 密钥",
                    subtitle_confuse: "仅创建开发者门户集成时需要提供。"
                )
                Spacer()
                Button("选择 .p8") { viewModel_confuse.chooseAPIKey_confuse() }
                    .buttonStyle(.bordered)
                    .disabled(viewModel_confuse.isRunning_confuse)
            }
            dropArea_confuse(
                title_confuse: viewModel_confuse.apiKeyPath_confuse.isEmpty
                    ? "将 API 密钥拖到这里"
                    : URL(fileURLWithPath: viewModel_confuse.apiKeyPath_confuse).lastPathComponent,
                subtitle_confuse: viewModel_confuse.apiKeyPath_confuse.isEmpty
                    ? "支持 .p8 文件"
                    : viewModel_confuse.apiKeyPath_confuse,
                iconName_confuse: "key.horizontal.fill",
                isTargeted_confuse: isAPIKeyDropTargeted_confuse
            )
            .onDrop(of: [UTType.fileURL.identifier], isTargeted: $isAPIKeyDropTargeted_confuse) {
                providers_confuse in
                acceptDrop_confuse(providers_confuse: providers_confuse) { url_confuse in
                    viewModel_confuse.acceptAPIKey_confuse(url_confuse: url_confuse)
                }
            }
        }
        .codeMagicPanelStyle_confuse()
    }

    /// 返回三个可独立执行的 Codemagic 步骤。
    private var workflowPanel_confuse: some View {
        VStack(alignment: .leading, spacing: 0) {
            panelTitle_confuse(
                title_confuse: "签名配置流程",
                subtitle_confuse: "可以按顺序执行全部步骤，也可以单独重试。"
            )
            .padding(.bottom, 8)
            ForEach(Array(CodeMagicStep_confuse.allCases.enumerated()), id: \.element.id) {
                index_confuse, step_confuse in
                HStack(spacing: 14) {
                    Image(systemName: step_confuse.iconName_confuse)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.confuseBlue_confuse)
                        .frame(width: 38, height: 38)
                        .background(Color.confuseBlue_confuse.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(step_confuse.displayName_confuse)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.white)
                            Text(viewModel_confuse.stepStates_confuse[step_confuse] ?? "等待执行")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(Color.confuseAccent_confuse)
                        }
                        Text(step_confuse.description_confuse)
                            .font(.system(size: 10))
                            .foregroundStyle(.white.opacity(0.38))
                    }
                    Spacer()
                    Button("执行") { viewModel_confuse.runStep_confuse(step_confuse: step_confuse) }
                        .buttonStyle(.bordered)
                        .disabled(!canRunStep_confuse(step_confuse: step_confuse))
                }
                .frame(minHeight: 68)
                if index_confuse < CodeMagicStep_confuse.allCases.count - 1 {
                    Divider().overlay(Color.confuseBorder_confuse).padding(.leading, 52)
                }
            }
        }
        .codeMagicPanelStyle_confuse()
    }

    /// 返回执行进度、停止和一键执行按钮。
    private var progressPanel_confuse: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                panelTitle_confuse(title_confuse: "执行进度", subtitle_confuse: viewModel_confuse.detailText_confuse)
                Spacer()
                Text("\(Int(viewModel_confuse.progress_confuse * 100))%")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.54))
                if viewModel_confuse.isRunning_confuse {
                    Button("停止") { viewModel_confuse.cancel_confuse() }
                        .buttonStyle(.bordered)
                        .tint(.orange)
                } else {
                    Button {
                        viewModel_confuse.runAll_confuse()
                    } label: {
                        Label("执行全部", systemImage: "play.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.confuseAccent_confuse)
                    .disabled(!viewModel_confuse.canRunAll_confuse)
                }
            }
            ProgressView(value: viewModel_confuse.progress_confuse)
                .tint(Color.confuseAccent_confuse)
                .animation(.easeInOut(duration: 0.22), value: viewModel_confuse.progress_confuse)
        }
        .codeMagicPanelStyle_confuse()
    }

    /// 返回固定尺寸的文件拖入区域。
    /// - Parameters:
    ///   - title_confuse: 主标题。
    ///   - subtitle_confuse: 文件类型或路径说明。
    ///   - iconName_confuse: SF Symbols 图标名称。
    ///   - isTargeted_confuse: 当前是否有拖拽内容悬停。
    /// - Returns: 稳定高度的拖入视图。
    private func dropArea_confuse(
        title_confuse: String,
        subtitle_confuse: String,
        iconName_confuse: String,
        isTargeted_confuse: Bool
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: iconName_confuse)
                .font(.system(size: 19, weight: .medium))
                .foregroundStyle(isTargeted_confuse ? Color.confuseAccent_confuse : .white.opacity(0.55))
            VStack(alignment: .leading, spacing: 4) {
                Text(title_confuse)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.76))
                Text(subtitle_confuse)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.35))
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            Spacer()
        }
        .padding(.horizontal, 15)
        .frame(maxWidth: .infinity, minHeight: 72)
        .background(Color.white.opacity(isTargeted_confuse ? 0.06 : 0.025))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(
            isTargeted_confuse ? Color.confuseAccent_confuse : Color.white.opacity(0.14),
            style: StrokeStyle(lineWidth: 1.2, dash: [6])
        ))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    /// 返回一个 Profile 只读字段。
    /// - Parameters:
    ///   - title_confuse: 字段标题。
    ///   - value_confuse: 字段值。
    /// - Returns: 支持文本选择的字段视图。
    private func valueItem_confuse(title_confuse: String, value_confuse: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title_confuse)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.white.opacity(0.42))
            Text(value_confuse.isEmpty ? "未识别" : value_confuse)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundStyle(.white.opacity(value_confuse.isEmpty ? 0.28 : 0.82))
                .lineLimit(1)
                .truncationMode(.middle)
                .textSelection(.enabled)
        }
        .padding(11)
        .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
        .background(Color.black.opacity(0.16))
        .clipShape(RoundedRectangle(cornerRadius: 7))
    }

    /// 返回当前步骤是否允许独立执行。
    /// - Parameter step_confuse: 待检查步骤。
    /// - Returns: 项目和必要文件均准备好时返回 true。
    private func canRunStep_confuse(step_confuse: CodeMagicStep_confuse) -> Bool {
        guard viewModel_confuse.isProjectReady_confuse, !viewModel_confuse.isRunning_confuse else { return false }
        return step_confuse != .apiKey_confuse || !viewModel_confuse.apiKeyPath_confuse.isEmpty
    }

    /// 接收首个拖拽 URL 并交给指定处理闭包。
    /// - Parameters:
    ///   - providers_confuse: 拖拽数据提供者。
    ///   - action_confuse: 在主线程接收文件 URL 的闭包。
    /// - Returns: 找到拖拽提供者时返回 true。
    private func acceptDrop_confuse(
        providers_confuse: [NSItemProvider],
        action_confuse: @escaping (URL) -> Void
    ) -> Bool {
        guard let provider_confuse = providers_confuse.first else { return false }
        provider_confuse.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) {
            item_confuse, _ in
            guard let data_confuse = item_confuse as? Data,
                  let url_confuse = URL(dataRepresentation: data_confuse, relativeTo: nil) else { return }
            Task { @MainActor in action_confuse(url_confuse) }
        }
        return true
    }

    /// 返回面板标题和辅助说明。
    /// - Parameters:
    ///   - title_confuse: 标题文本。
    ///   - subtitle_confuse: 辅助说明。
    /// - Returns: 标题视图。
    private func panelTitle_confuse(title_confuse: String, subtitle_confuse: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title_confuse)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
            Text(subtitle_confuse)
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.40))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

/// 为云端构建页面提供统一面板样式。
private struct CodeMagicPanelStyle_confuse: ViewModifier {
    /// 应用云端构建面板样式。
    /// - Parameter content_confuse: 被修饰的内容。
    /// - Returns: 带背景、边框和内边距的视图。
    func body(content: Content) -> some View {
        content
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.confusePanel_confuse)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.confuseBorder_confuse, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

/// 为云端构建页面内容提供统一面板样式入口。
private extension View {
    /// 应用云端构建页面面板样式。
    /// - Returns: 添加面板样式后的视图。
    func codeMagicPanelStyle_confuse() -> some View {
        modifier(CodeMagicPanelStyle_confuse())
    }
}
