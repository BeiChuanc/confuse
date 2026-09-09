import SwiftUI
import UniformTypeIdentifiers

/// 展示合包语言、类型、目标工程、后台配置、代码清单和执行进度。
///
/// 页面只绑定 PackageAssemblyViewModel_confuse 的状态与命令，拖拽文件解析、
/// 工程检查和实际写入均由视图模型及服务层完成。
struct PackageAssemblyView_confuse: View {
    @ObservedObject var viewModel_confuse: PackageAssemblyViewModel_confuse
    @State private var isDropTargeted_confuse = false

    /// 返回合包整理完整页面，并承载错误弹窗。
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header_confuse
                selectionPanel_confuse
                targetProjectPanel_confuse
                backendConfigurationPanel_confuse
                packageFilesPanel_confuse
                progressPanel_confuse
            }
            .padding(.horizontal, 34)
            .padding(.vertical, 30)
        }
        .alert("操作失败", isPresented: $viewModel_confuse.isShowingAlert_confuse) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(viewModel_confuse.alertMessage_confuse)
        }
        .animation(.easeInOut(duration: 0.22), value: viewModel_confuse.backendConfiguration_confuse)
    }

    /// 返回页面标题和当前状态。
    private var header_confuse: some View {
        HStack(alignment: .top, spacing: 18) {
            VStack(alignment: .leading, spacing: 7) {
                Text("合包整理")
                    .font(.system(size: 27, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("将合包代码和配置合并到目标项目。")
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

    /// 返回语言和合包类型选择区域。
    private var selectionPanel_confuse: some View {
        VStack(alignment: .leading, spacing: 18) {
            selectionTitle_confuse(title_confuse: "项目语言")
            Picker(
                "项目语言",
                selection: Binding(
                    get: { viewModel_confuse.language_confuse },
                    set: { viewModel_confuse.selectLanguage_confuse(language_confuse: $0) }
                )
            ) {
                ForEach(PackageLanguage_confuse.allCases) { language_confuse in
                    Text(language_confuse.displayName_confuse).tag(language_confuse)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            selectionTitle_confuse(title_confuse: "合包类型")
            Picker(
                "合包类型",
                selection: Binding(
                    get: { viewModel_confuse.type_confuse },
                    set: { viewModel_confuse.selectType_confuse(type_confuse: $0) }
                )
            ) {
                ForEach(PackageType_confuse.allCases) { type_confuse in
                    Text(type_confuse.displayName_confuse).tag(type_confuse)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "info.circle")
                    .foregroundStyle(Color.confuseBlue_confuse)
                Text(viewModel_confuse.language_confuse == .swift_confuse
                    ? "Swift 合包将更新 Podfile、Mix 源文件、AppDelegate 和 Info.plist。"
                    : "Flutter 合包功能暂未开放。")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.43))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .packagePanelStyle_confuse()
    }

    /// 返回目标工程选择和拖拽区域。
    private var targetProjectPanel_confuse: some View {
        VStack(alignment: .leading, spacing: 13) {
            panelTitle_confuse(
                title_confuse: "目标项目",
                subtitle_confuse: "选择项目文件夹，或将项目拖入下方区域。"
            )
            HStack(spacing: 10) {
                Image(systemName: "folder.fill")
                    .foregroundStyle(Color.confuseBlue_confuse)
                Text(viewModel_confuse.targetProjectPath_confuse.isEmpty
                    ? "尚未选择项目"
                    : viewModel_confuse.targetProjectPath_confuse)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(viewModel_confuse.targetProjectPath_confuse.isEmpty
                        ? .white.opacity(0.36)
                        : .white.opacity(0.8))
                Spacer()
                Button("选择项目") {
                    viewModel_confuse.chooseTargetProject_confuse()
                }
                .buttonStyle(.bordered)
                .tint(Color.confuseBlue_confuse)
                .disabled(viewModel_confuse.isBusy_confuse)
            }
            .padding(13)
            .background(Color.black.opacity(0.18))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(
                        isDropTargeted_confuse ? Color.confuseAccent_confuse : Color.white.opacity(0.15),
                        style: StrokeStyle(lineWidth: 1.2, dash: [6])
                    )
                    .background(
                        Color.white.opacity(isDropTargeted_confuse ? 0.06 : 0.025)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    )
                VStack(spacing: 7) {
                    Image(systemName: "arrow.down.to.line.compact")
                        .font(.system(size: 21, weight: .medium))
                        .foregroundStyle(isDropTargeted_confuse
                            ? Color.confuseAccent_confuse
                            : .white.opacity(0.58))
                    Text("将目标项目拖到这里")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.72))
                    Text("支持项目文件夹或 .xcodeproj")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.34))
                }
            }
            .frame(height: 100)
            .onDrop(of: [UTType.fileURL.identifier], isTargeted: $isDropTargeted_confuse) {
                providers_confuse in
                acceptDrop_confuse(providers_confuse: providers_confuse)
            }

            HStack(spacing: 9) {
                Image(systemName: "shippingbox")
                    .foregroundStyle(Color.confuseAccent_confuse)
                Text("目标 Bundle ID")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.48))
                Text(viewModel_confuse.targetBundleID_confuse.isEmpty
                    ? "等待识别"
                    : viewModel_confuse.targetBundleID_confuse)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundStyle(viewModel_confuse.targetBundleID_confuse.isEmpty
                        ? .white.opacity(0.32)
                        : .white.opacity(0.82))
                    .textSelection(.enabled)
                Spacer()
            }
        }
        .packagePanelStyle_confuse()
    }

    /// 返回后台登录、读取进度和结构化配置展示区域。
    private var backendConfigurationPanel_confuse: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                panelTitle_confuse(
                    title_confuse: "获取后台配置",
                    subtitle_confuse: "复用当前 Chrome 登录苹果马甲包后台，并按目标 Bundle ID 获取配置。"
                )
                Spacer()
                HStack(spacing: 7) {
                    Circle()
                        .fill(viewModel_confuse.backendConfiguration_confuse == nil
                            ? Color.orange
                            : Color.confuseAccent_confuse)
                        .frame(width: 7, height: 7)
                    Text(viewModel_confuse.backendStatusText_confuse)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.72))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.06))
                .clipShape(Capsule())
            }

            HStack(spacing: 10) {
                Image(systemName: viewModel_confuse.isExtensionPrepared_confuse
                    ? "checkmark.circle.fill"
                    : "puzzlepiece.extension.fill")
                    .foregroundStyle(viewModel_confuse.isExtensionPrepared_confuse
                        ? Color.confuseAccent_confuse
                        : Color.orange)
                Text(viewModel_confuse.extensionStatusText_confuse)
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.58))
                Spacer()
                Button {
                    viewModel_confuse.prepareBrowserAssistant_confuse()
                } label: {
                    Label("更新浏览器助手", systemImage: "arrow.triangle.2.circlepath")
                }
                .buttonStyle(.bordered)
                .tint(Color.confuseBlue_confuse)
                .disabled(viewModel_confuse.isBusy_confuse)
            }
            .padding(12)
            .background(Color.black.opacity(0.16))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 210), spacing: 12)],
                alignment: .leading,
                spacing: 12
            ) {
                inputField_confuse(
                    title_confuse: "后台账号",
                    placeholder_confuse: "请输入后台账号",
                    text_confuse: $viewModel_confuse.backendAccount_confuse
                )
                secureInputField_confuse(
                    title_confuse: "后台密码",
                    placeholder_confuse: "请输入后台密码",
                    text_confuse: $viewModel_confuse.backendPassword_confuse
                )
                secureInputField_confuse(
                    title_confuse: "2FA",
                    placeholder_confuse: "请输入当前 2FA",
                    text_confuse: $viewModel_confuse.backendTwoFactorCode_confuse
                )
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(viewModel_confuse.backendDetailText_confuse)
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.54))
                        .fixedSize(horizontal: false, vertical: true)
                    ProgressView(value: viewModel_confuse.backendProgress_confuse)
                        .tint(Color.confuseBlue_confuse)
                        .frame(maxWidth: 360)
                }
                Spacer()
                if viewModel_confuse.isFetchingBackend_confuse {
                    Button("停止获取") {
                        viewModel_confuse.stopBackendConfiguration_confuse()
                    }
                    .buttonStyle(.bordered)
                    .tint(.orange)
                } else {
                    Button {
                        viewModel_confuse.fetchBackendConfiguration_confuse()
                    } label: {
                        Label("获取后台配置", systemImage: "arrow.down.circle.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.confuseBlue_confuse)
                    .disabled(!viewModel_confuse.canFetchBackendConfiguration_confuse)
                }
            }

            if let configuration_confuse = viewModel_confuse.backendConfiguration_confuse {
                Divider()
                    .overlay(Color.white.opacity(0.08))
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 250), spacing: 12)],
                    alignment: .leading,
                    spacing: 10
                ) {
                    backendConfigurationItem_confuse(
                        title_confuse: "AppsFlyer 开发者密钥",
                        value_confuse: configuration_confuse.appsFlyerDevKey_confuse,
                        iconName_confuse: "key.fill"
                    )
                    backendConfigurationItem_confuse(
                        title_confuse: "Apple App ID",
                        value_confuse: configuration_confuse.appleAppID_confuse,
                        iconName_confuse: "apple.logo"
                    )
                    backendConfigurationItem_confuse(
                        title_confuse: "配置域名",
                        value_confuse: configuration_confuse.configurationDomain_confuse,
                        iconName_confuse: "network"
                    )
                    backendConfigurationItem_confuse(
                        title_confuse: "请求域名",
                        value_confuse: configuration_confuse.requestDomain_confuse,
                        iconName_confuse: "globe"
                    )
                    backendConfigurationItem_confuse(
                        title_confuse: "Facebook 应用编号",
                        value_confuse: configuration_confuse.facebookAppID_confuse,
                        iconName_confuse: "number"
                    )
                    backendConfigurationItem_confuse(
                        title_confuse: "Facebook 客户端令牌",
                        value_confuse: configuration_confuse.facebookClientToken_confuse,
                        iconName_confuse: "lock.fill"
                    )
                    backendConfigurationItem_confuse(
                        title_confuse: "Facebook 显示名称",
                        value_confuse: configuration_confuse.facebookDisplayName_confuse,
                        iconName_confuse: "textformat"
                    )
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .packagePanelStyle_confuse()
    }

    /// 返回 PACKAGE 文件清单和缺失文件提示。
    private var packageFilesPanel_confuse: some View {
        VStack(alignment: .leading, spacing: 13) {
            panelTitle_confuse(title_confuse: "合包代码", subtitle_confuse: viewModel_confuse.directoryText_confuse)

            if !viewModel_confuse.missingFiles_confuse.isEmpty {
                Label(
                    "缺少：\(viewModel_confuse.missingFiles_confuse.joined(separator: ", "))",
                    systemImage: "exclamationmark.triangle.fill"
                )
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.orange)
            }

            if viewModel_confuse.packageFiles_confuse.isEmpty {
                VStack(spacing: 9) {
                    Image(systemName: "shippingbox")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(.white.opacity(0.24))
                    Text("未找到匹配的合包代码")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.54))
                    Text("请将代码放入当前选择的 PACKAGE 目录。")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.32))
                }
                .frame(maxWidth: .infinity, minHeight: 130)
            } else {
                VStack(alignment: .leading, spacing: 7) {
                    ForEach(viewModel_confuse.packageFiles_confuse, id: \.self) { path_confuse in
                        HStack(spacing: 10) {
                            Image(systemName: "doc.text")
                                .foregroundStyle(Color.confuseBlue_confuse)
                            Text(URL(fileURLWithPath: path_confuse).lastPathComponent)
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.78))
                            Spacer()
                        }
                        .padding(.vertical, 7)
                    }
                }
            }
        }
        .packagePanelStyle_confuse()
    }

    /// 返回进度条和执行按钮。
    private var progressPanel_confuse: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                panelTitle_confuse(title_confuse: "执行进度", subtitle_confuse: viewModel_confuse.detailText_confuse)
                Spacer()
                Text("\(Int(viewModel_confuse.progress_confuse * 100))%")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.54))
                Button {
                    viewModel_confuse.refresh_confuse()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
                .help("刷新合包代码")
                .disabled(viewModel_confuse.isBusy_confuse)
                Button {
                    viewModel_confuse.assemble_confuse()
                } label: {
                    Label(
                        viewModel_confuse.isRunning_confuse ? "处理中" : "开始合包",
                        systemImage: "shippingbox.and.arrow.backward"
                    )
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.confuseAccent_confuse)
                .disabled(!viewModel_confuse.canAssemble_confuse)
            }
            ProgressView(value: viewModel_confuse.progress_confuse)
                .tint(Color.confuseAccent_confuse)
                .animation(.easeInOut(duration: 0.22), value: viewModel_confuse.progress_confuse)
        }
        .packagePanelStyle_confuse()
    }

    /// 接收文件拖拽并将首个 URL 交给视图模型。
    /// - Parameter providers_confuse: 拖拽数据提供者列表。
    /// - Returns: 已接受拖拽时返回 true。
    private func acceptDrop_confuse(providers_confuse: [NSItemProvider]) -> Bool {
        guard let provider_confuse = providers_confuse.first else { return false }
        provider_confuse.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) {
            item_confuse, _ in
            guard let data_confuse = item_confuse as? Data,
                  let url_confuse = URL(dataRepresentation: data_confuse, relativeTo: nil) else { return }
            Task { @MainActor in
                viewModel_confuse.acceptTargetProject_confuse(url_confuse: url_confuse)
            }
        }
        return true
    }

    /// 返回单行输入字段。
    /// - Parameters:
    ///   - title_confuse: 字段标题。
    ///   - placeholder_confuse: 输入占位文本。
    ///   - text_confuse: 输入绑定。
    /// - Returns: 带标题的输入视图。
    private func inputField_confuse(
        title_confuse: String,
        placeholder_confuse: String,
        text_confuse: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title_confuse)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.white.opacity(0.46))
            TextField(placeholder_confuse, text: text_confuse)
                .textFieldStyle(.roundedBorder)
                .disabled(viewModel_confuse.isBusy_confuse)
        }
        .frame(maxWidth: .infinity)
    }

    /// 返回不显示明文的单行输入字段。
    /// - Parameters:
    ///   - title_confuse: 字段标题。
    ///   - placeholder_confuse: 输入占位文本。
    ///   - text_confuse: 输入绑定。
    /// - Returns: 带标题的安全输入视图。
    private func secureInputField_confuse(
        title_confuse: String,
        placeholder_confuse: String,
        text_confuse: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title_confuse)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.white.opacity(0.46))
            SecureField(placeholder_confuse, text: text_confuse)
                .textFieldStyle(.roundedBorder)
                .disabled(viewModel_confuse.isBusy_confuse)
        }
        .frame(maxWidth: .infinity)
    }

    /// 返回单项后台配置的只读展示。
    /// - Parameters:
    ///   - title_confuse: 配置项中文名称。
    ///   - value_confuse: 后台读取到的原始值。
    ///   - iconName_confuse: 配置项图标名称。
    /// - Returns: 支持选择文本的后台配置视图。
    private func backendConfigurationItem_confuse(
        title_confuse: String,
        value_confuse: String,
        iconName_confuse: String
    ) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: iconName_confuse)
                .frame(width: 18)
                .foregroundStyle(Color.confuseBlue_confuse)
            VStack(alignment: .leading, spacing: 5) {
                Text(title_confuse)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.42))
                Text(value_confuse)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.82))
                    .fixedSize(horizontal: false, vertical: true)
                    .textSelection(.enabled)
            }
            Spacer(minLength: 0)
        }
        .padding(11)
        .frame(maxWidth: .infinity, minHeight: 58, alignment: .leading)
        .background(Color.black.opacity(0.16))
        .clipShape(RoundedRectangle(cornerRadius: 7))
    }

    /// 返回选择项标题。
    /// - Parameter title_confuse: 标题文本。
    /// - Returns: 标题视图。
    private func selectionTitle_confuse(title_confuse: String) -> some View {
        Text(title_confuse)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.white.opacity(0.62))
    }

    /// 返回面板标题和辅助说明。
    /// - Parameters:
    ///   - title_confuse: 面板标题。
    ///   - subtitle_confuse: 面板说明。
    /// - Returns: 标题视图。
    private func panelTitle_confuse(title_confuse: String, subtitle_confuse: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title_confuse)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
            Text(subtitle_confuse)
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.white.opacity(0.38))
                .lineLimit(2)
                .truncationMode(.middle)
        }
    }
}

/// 为合包整理页面提供统一面板样式。
private struct PackagePanelStyle_confuse: ViewModifier {
    /// 应用合包整理面板样式。
    /// - Parameter content_confuse: 被修饰的页面内容。
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

/// 为合包整理页面内容提供统一面板样式入口。
private extension View {
    /// 应用合包整理页面面板样式。
    /// - Returns: 添加面板样式后的视图。
    func packagePanelStyle_confuse() -> some View {
        modifier(PackagePanelStyle_confuse())
    }
}
