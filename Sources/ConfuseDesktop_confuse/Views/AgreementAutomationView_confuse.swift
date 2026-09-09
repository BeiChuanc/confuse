import SwiftUI

/// 展示协议自动化输入、三阶段运行状态和生成链接，所有浏览器操作由视图模型处理。
struct AgreementAutomationView_confuse: View {
    @ObservedObject var viewModel_confuse: AgreementAutomationViewModel_confuse

    /// 返回协议处理页面，并统一承载错误弹窗。
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header_confuse
                configurationPanel_confuse
                agreementPanel_confuse
                actionBar_confuse
            }
            .padding(.horizontal, 34)
            .padding(.vertical, 30)
        }
        .alert("协议生成失败", isPresented: $viewModel_confuse.isShowingAlert_confuse) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(viewModel_confuse.alertMessage_confuse)
        }
    }

    /// 返回页面标题、用途说明和当前任务状态。
    private var header_confuse: some View {
        HStack(alignment: .top, spacing: 18) {
            VStack(alignment: .leading, spacing: 7) {
                Text("协议处理")
                    .font(.system(size: 27, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("复用当前已登录的 Chrome，自动生成隐私政策、使用条款和最终用户许可协议。")
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

    /// 返回应用名称和联系邮箱输入区域。
    private var configurationPanel_confuse: some View {
        VStack(alignment: .leading, spacing: 16) {
            panelTitle_confuse(
                title_confuse: "协议信息",
                subtitle_confuse: "以下内容会填入三个协议生成器。"
            )

            HStack(alignment: .top, spacing: 14) {
                inputField_confuse(
                    title_confuse: "应用名称",
                    placeholder_confuse: "请输入应用名称",
                    text_confuse: $viewModel_confuse.appName_confuse
                )
                inputField_confuse(
                    title_confuse: "联系邮箱",
                    placeholder_confuse: "请输入邮箱地址",
                    text_confuse: $viewModel_confuse.email_confuse
                )
            }

            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "info.circle")
                    .foregroundStyle(Color.confuseBlue_confuse)
                Text("请先在“整理资料”页面准备 App Tools 浏览器助手。生成时会在当前 Chrome 窗口新建标签页，并将应用名称和邮箱提交至 FreePrivacyPolicy。")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.42))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .agreementPanelStyle_confuse()
    }

    /// 返回三个协议阶段及其独立操作和结果链接。
    private var agreementPanel_confuse: some View {
        VStack(alignment: .leading, spacing: 0) {
            panelTitle_confuse(
                title_confuse: "生成流程",
                subtitle_confuse: viewModel_confuse.detailText_confuse
            )
            .padding(.bottom, 8)

            ForEach(Array(AgreementType_confuse.allCases.enumerated()), id: \.element.id) {
                index_confuse, type_confuse in
                agreementRow_confuse(type_confuse: type_confuse)
                if index_confuse < AgreementType_confuse.allCases.count - 1 {
                    Divider()
                        .overlay(Color.confuseBorder_confuse)
                        .padding(.leading, 50)
                }
            }
        }
        .agreementPanelStyle_confuse()
    }

    /// 返回一项协议的图标、说明、状态、链接与操作按钮。
    /// - Parameter type_confuse: 当前协议类型。
    /// - Returns: 单项协议流程视图。
    private func agreementRow_confuse(type_confuse: AgreementType_confuse) -> some View {
        let state_confuse = viewModel_confuse.state_confuse(type_confuse: type_confuse)
        return HStack(alignment: .center, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 7)
                    .fill(stateColor_confuse(state_confuse: state_confuse).opacity(0.14))
                Image(systemName: stateIcon_confuse(type_confuse: type_confuse, state_confuse: state_confuse))
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(stateColor_confuse(state_confuse: state_confuse))
            }
            .frame(width: 38, height: 38)

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    Text(type_confuse.displayName_confuse)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                    Text(viewModel_confuse.messages_confuse[type_confuse] ?? "尚未生成")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(stateColor_confuse(state_confuse: state_confuse))
                }
                Text(type_confuse.description_confuse)
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.36))

                if let link_confuse = viewModel_confuse.links_confuse[type_confuse] {
                    HStack(spacing: 7) {
                        Text(link_confuse)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(Color.confuseBlue_confuse)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Button {
                            viewModel_confuse.copyLink_confuse(type_confuse: type_confuse)
                        } label: {
                            Image(systemName: "doc.on.doc")
                        }
                        .buttonStyle(.plain)
                        .help("复制链接")
                        Button {
                            viewModel_confuse.openLink_confuse(type_confuse: type_confuse)
                        } label: {
                            Image(systemName: "arrow.up.right.square")
                        }
                        .buttonStyle(.plain)
                        .help("打开链接")
                    }
                }
            }

            Spacer(minLength: 12)

            Button {
                viewModel_confuse.generate_confuse(type_confuse: type_confuse)
            } label: {
                Label(
                    state_confuse == .completed_confuse ? "重新生成" : "生成",
                    systemImage: "play.fill"
                )
            }
            .buttonStyle(.bordered)
            .disabled(!viewModel_confuse.canGenerate_confuse)
        }
        .frame(minHeight: 74)
        .animation(.easeInOut(duration: 0.2), value: state_confuse)
    }

    /// 返回停止任务或一键生成全部协议的底部操作栏。
    private var actionBar_confuse: some View {
        HStack(spacing: 12) {
            Spacer()
            if viewModel_confuse.isRunning_confuse {
                Button {
                    viewModel_confuse.cancel_confuse()
                } label: {
                    Label("停止", systemImage: "stop.fill")
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
            Button {
                viewModel_confuse.generateAll_confuse()
            } label: {
                HStack(spacing: 8) {
                    if viewModel_confuse.isRunning_confuse {
                        ProgressView().controlSize(.small)
                    } else {
                        Image(systemName: "wand.and.stars")
                    }
                    Text(viewModel_confuse.isRunning_confuse ? "生成中" : "一键生成全部")
                }
                .font(.system(size: 13, weight: .semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.confuseAccent_confuse)
            .disabled(!viewModel_confuse.canGenerate_confuse)
        }
    }

    /// 返回统一的输入字段。
    /// - Parameters:
    ///   - title_confuse: 字段标题。
    ///   - placeholder_confuse: 输入占位文本。
    ///   - text_confuse: 输入值绑定。
    /// - Returns: 带中文标题的输入视图。
    private func inputField_confuse(
        title_confuse: String,
        placeholder_confuse: String,
        text_confuse: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title_confuse)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.52))
            TextField(placeholder_confuse, text: text_confuse)
                .textFieldStyle(.roundedBorder)
                .disabled(viewModel_confuse.isRunning_confuse)
        }
        .frame(maxWidth: .infinity)
    }

    /// 返回统一的面板标题和辅助说明。
    /// - Parameters:
    ///   - title_confuse: 面板标题。
    ///   - subtitle_confuse: 面板辅助说明。
    /// - Returns: 标题视图。
    private func panelTitle_confuse(title_confuse: String, subtitle_confuse: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title_confuse)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
            Text(subtitle_confuse)
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.40))
                .lineLimit(2)
        }
    }

    /// 返回协议状态对应的颜色。
    /// - Parameter state_confuse: 当前协议状态。
    /// - Returns: 用于图标和状态文字的颜色。
    private func stateColor_confuse(state_confuse: AgreementGenerationState_confuse) -> Color {
        switch state_confuse {
        case .pending_confuse: return .white.opacity(0.34)
        case .running_confuse: return .orange
        case .completed_confuse: return Color.confuseAccent_confuse
        case .failed_confuse: return .red
        }
    }

    /// 返回协议类型和状态对应的图标。
    /// - Parameters:
    ///   - type_confuse: 当前协议类型。
    ///   - state_confuse: 当前协议状态。
    /// - Returns: SF Symbols 图标名称。
    private func stateIcon_confuse(
        type_confuse: AgreementType_confuse,
        state_confuse: AgreementGenerationState_confuse
    ) -> String {
        switch state_confuse {
        case .pending_confuse: return type_confuse.iconName_confuse
        case .running_confuse: return "arrow.triangle.2.circlepath"
        case .completed_confuse: return "checkmark"
        case .failed_confuse: return "exclamationmark"
        }
    }
}

/// 展示整理资料流程自动生成的协议状态和链接。
///
/// 该组件只负责协议结果展示和链接操作，数据和任务控制由外部视图模型提供，
/// 因此可以嵌入整理资料页面而不重复创建协议自动化任务。
struct AgreementResultPanel_confuse: View {
    @Binding var appName_confuse: String
    @Binding var email_confuse: String
    let hasRecord_confuse: Bool
    let states_confuse: [AgreementType_confuse: AgreementGenerationState_confuse]
    let messages_confuse: [AgreementType_confuse: String]
    let links_confuse: [AgreementType_confuse: String]
    let copyLink_confuse: (AgreementType_confuse) -> Void
    let openLink_confuse: (AgreementType_confuse) -> Void
    let canGenerate_confuse: Bool
    let generateLink_confuse: (AgreementType_confuse) -> Void
    let generateAll_confuse: () -> Void

    /// 返回协议状态和链接列表面板。
    /// - Returns: 协议结果展示视图。
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text("协议处理")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                Text(hasRecord_confuse
                    ? "资料已读取，请确认应用名和邮箱后生成协议并保存 Profile。"
                    : "未整理资料时，可直接填写应用名和邮箱单独生成协议。")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.40))
                    .lineLimit(2)
            }
            .padding(.bottom, 8)

            HStack(alignment: .top, spacing: 12) {
                agreementInputField_confuse(
                    title_confuse: "应用名称",
                    placeholder_confuse: "请输入应用名称",
                    text_confuse: $appName_confuse
                )
                agreementInputField_confuse(
                    title_confuse: "联系邮箱",
                    placeholder_confuse: "请输入邮箱地址",
                    text_confuse: $email_confuse
                )
            }
            .padding(.bottom, 10)

            ForEach(Array(AgreementType_confuse.allCases.enumerated()), id: \.element.id) {
                index_confuse, type_confuse in
                agreementRow_confuse(type_confuse: type_confuse)
                if index_confuse < AgreementType_confuse.allCases.count - 1 {
                    Divider()
                        .overlay(Color.confuseBorder_confuse)
                        .padding(.leading, 50)
                }
            }

            HStack {
                Spacer()
                Button {
                    generateAll_confuse()
                } label: {
                    Label(
                        hasRecord_confuse ? "生成协议并生成 Profile" : "一键生成全部",
                        systemImage: "wand.and.stars"
                    )
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.confuseAccent_confuse)
                .disabled(!canGenerate_confuse)
            }
            .padding(.top, 10)
        }
        .padding(18)
        .background(Color.confusePanel_confuse)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.confuseBorder_confuse, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    /// 返回协议生成所需的应用名称或邮箱输入框。
    /// - Parameters:
    ///   - title_confuse: 输入框标题。
    ///   - placeholder_confuse: 输入框占位提示。
    ///   - text_confuse: 输入值绑定。
    /// - Returns: 带标题的协议参数输入视图。
    private func agreementInputField_confuse(
        title_confuse: String,
        placeholder_confuse: String,
        text_confuse: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title_confuse)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.white.opacity(0.46))
            TextField(placeholder_confuse, text: text_confuse)
                .textFieldStyle(.roundedBorder)
        }
        .frame(maxWidth: .infinity)
    }

    /// 返回一项协议的状态、链接和操作按钮。
    /// - Parameter type_confuse: 当前协议类型。
    /// - Returns: 协议状态行。
    private func agreementRow_confuse(type_confuse: AgreementType_confuse) -> some View {
        let state_confuse = states_confuse[type_confuse] ?? .pending_confuse
        return HStack(alignment: .center, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 7)
                    .fill(stateColor_confuse(state_confuse: state_confuse).opacity(0.14))
                Image(systemName: stateIcon_confuse(type_confuse: type_confuse, state_confuse: state_confuse))
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(stateColor_confuse(state_confuse: state_confuse))
            }
            .frame(width: 38, height: 38)

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    Text(type_confuse.displayName_confuse)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                    Text(messages_confuse[type_confuse] ?? "等待资料读取")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(stateColor_confuse(state_confuse: state_confuse))
                }
                Text(type_confuse.description_confuse)
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.36))

                if let link_confuse = links_confuse[type_confuse] {
                    HStack(spacing: 7) {
                        Text(link_confuse)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(Color.confuseBlue_confuse)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Button {
                            copyLink_confuse(type_confuse)
                        } label: {
                            Image(systemName: "doc.on.doc")
                        }
                        .buttonStyle(.plain)
                        .help("复制链接")
                        Button {
                            openLink_confuse(type_confuse)
                        } label: {
                            Image(systemName: "arrow.up.right.square")
                        }
                        .buttonStyle(.plain)
                        .help("打开链接")
                    }
                }
            }
            Spacer(minLength: 12)

            Button {
                generateLink_confuse(type_confuse)
            } label: {
                Label(
                    state_confuse == .completed_confuse ? "重新生成" : "生成",
                    systemImage: "play.fill"
                )
            }
            .buttonStyle(.bordered)
            .disabled(!canGenerate_confuse)
        }
        .frame(minHeight: 74)
        .animation(.easeInOut(duration: 0.2), value: state_confuse)
    }

    /// 返回协议状态对应的颜色。
    /// - Parameter state_confuse: 当前协议状态。
    /// - Returns: 用于图标和状态文字的颜色。
    private func stateColor_confuse(state_confuse: AgreementGenerationState_confuse) -> Color {
        switch state_confuse {
        case .pending_confuse: return .white.opacity(0.34)
        case .running_confuse: return .orange
        case .completed_confuse: return Color.confuseAccent_confuse
        case .failed_confuse: return .red
        }
    }

    /// 返回协议状态对应的图标。
    /// - Parameters:
    ///   - type_confuse: 当前协议类型。
    ///   - state_confuse: 当前协议状态。
    /// - Returns: SF Symbols 图标名称。
    private func stateIcon_confuse(
        type_confuse: AgreementType_confuse,
        state_confuse: AgreementGenerationState_confuse
    ) -> String {
        switch state_confuse {
        case .pending_confuse: return type_confuse.iconName_confuse
        case .running_confuse: return "arrow.triangle.2.circlepath"
        case .completed_confuse: return "checkmark"
        case .failed_confuse: return "exclamationmark"
        }
    }
}

/// 为协议处理页面的配置和流程区域提供统一面板样式。
private struct AgreementPanelStyle_confuse: ViewModifier {
    /// 应用协议页面面板样式。
    /// - Parameter content_confuse: 被修饰的内容。
    /// - Returns: 带背景、边框和内边距的视图。
    func body(content: Content) -> some View {
        content
            .padding(18)
            .background(Color.confusePanel_confuse)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.confuseBorder_confuse, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

/// 为协议处理页面内容提供面板样式入口。
private extension View {
    /// 应用协议页面统一面板样式。
    /// - Returns: 添加面板样式后的视图。
    func agreementPanelStyle_confuse() -> some View {
        modifier(AgreementPanelStyle_confuse())
    }
}
