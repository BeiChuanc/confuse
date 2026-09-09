import SwiftUI

/// 展示飞书项目搜索、登录提示、读取进度和九项资料结果，所有业务操作由视图模型处理。
struct MaterialAutomationView_confuse: View {
    @ObservedObject var viewModel_confuse: MaterialAutomationViewModel_confuse
    private let columns_confuse = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    /// 返回整理资料页面，并统一承载错误弹窗。
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header_confuse
                extensionPanel_confuse
                searchPanel_confuse
                progressPanel_confuse
                resultPanel_confuse
                agreementResultPanel_confuse
            }
            .padding(.horizontal, 34)
            .padding(.vertical, 30)
        }
        .alert("资料整理失败", isPresented: $viewModel_confuse.isShowingAlert_confuse) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(viewModel_confuse.alertMessage_confuse)
        }
        .alert("确认生成协议并保存 Profile？", isPresented: $viewModel_confuse.isShowingAgreementConfirmation_confuse) {
            Button("继续生成") {
                viewModel_confuse.confirmGenerateAllAgreements_confuse()
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("将使用当前应用名称和邮箱生成三类协议，并把整理资料与协议链接写入 PROFILE 文件。")
        }
    }

    /// 返回页面标题、用途说明和当前状态。
    private var header_confuse: some View {
        HStack(alignment: .top, spacing: 18) {
            VStack(alignment: .leading, spacing: 7) {
                Text("整理资料")
                    .font(.system(size: 27, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("通过 Chrome 扩展复用飞书登录状态，并集中展示提交所需资料。")
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

    /// 返回 Chrome 扩展准备状态、安装步骤和快捷操作。
    private var extensionPanel_confuse: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "puzzlepiece.extension.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.confuseBlue_confuse)
                    .frame(width: 38, height: 38)
                    .background(Color.confuseBlue_confuse.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                VStack(alignment: .leading, spacing: 4) {
                    Text("App Tools 浏览器助手")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                    Text(viewModel_confuse.extensionStatusText_confuse)
                        .font(.system(size: 11))
                        .foregroundStyle(
                            viewModel_confuse.isExtensionPrepared_confuse
                                ? Color.confuseAccent_confuse
                                : .white.opacity(0.42)
                        )
                }
                Spacer()
                Button {
                    viewModel_confuse.prepareExtension_confuse()
                } label: {
                    Label(
                        viewModel_confuse.isExtensionPrepared_confuse ? "更新扩展" : "准备扩展",
                        systemImage: "shippingbox.fill"
                    )
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.confuseBlue_confuse)
                Button {
                    viewModel_confuse.showExtensionDirectory_confuse()
                } label: {
                    Image(systemName: "folder")
                }
                .buttonStyle(.bordered)
                .disabled(!viewModel_confuse.isExtensionPrepared_confuse)
                .help("显示扩展目录")
                Button {
                    viewModel_confuse.openChromeExtensionManager_confuse()
                } label: {
                    Image(systemName: "puzzlepiece.extension")
                }
                .buttonStyle(.bordered)
                .help("打开 Chrome 扩展管理")
            }

            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "info.circle")
                    .foregroundStyle(Color.confuseBlue_confuse)
                Text("首次使用：点击“准备扩展”，在 Chrome 扩展管理页开启开发者模式，点击“加载已解压的扩展程序”，选择访达中显示的 ChromeExtension_confuse 文件夹。")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.43))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .materialPanelStyle_confuse()
    }

    /// 返回项目 UI 编号输入、开始读取和飞书原始页面入口。
    private var searchPanel_confuse: some View {
        VStack(alignment: .leading, spacing: 15) {
            panelTitle_confuse(
                title_confuse: "查找项目",
                subtitle_confuse: "请输入飞书表格中的完整 UI 编号。"
            )

            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.confuseBlue_confuse)
                TextField("请输入 UI 编号", text: $viewModel_confuse.uiNumber_confuse)
                    .textFieldStyle(.roundedBorder)
                    .disabled(viewModel_confuse.isRunning_confuse)
                    .onSubmit { viewModel_confuse.start_confuse() }
                Button {
                    viewModel_confuse.openFeishu_confuse()
                } label: {
                    Image(systemName: "safari")
                }
                .buttonStyle(.bordered)
                .help("打开飞书项目管理")
                Button {
                    viewModel_confuse.start_confuse()
                } label: {
                    Label("开始整理", systemImage: "play.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.confuseAccent_confuse)
                .disabled(!viewModel_confuse.canStart_confuse)
            }

            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "person.badge.key")
                    .foregroundStyle(Color.confuseBlue_confuse)
                Text("应用通过浏览器助手复用当前 Chrome 登录状态；未找到目标页面时，仅在当前窗口中新建标签页。")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.43))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .materialPanelStyle_confuse()
    }

    /// 返回当前自动化阶段、进度条和停止操作。
    private var progressPanel_confuse: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                panelTitle_confuse(title_confuse: "执行进度", subtitle_confuse: viewModel_confuse.detailText_confuse)
                Spacer()
                Text("\(Int(viewModel_confuse.progress_confuse * 100))%")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.54))
                if viewModel_confuse.isRunning_confuse {
                    Button {
                        viewModel_confuse.cancel_confuse()
                    } label: {
                        Image(systemName: "stop.fill")
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                    .help("停止整理")
                }
            }
            ProgressView(value: viewModel_confuse.progress_confuse)
                .tint(Color.confuseAccent_confuse)
                .animation(.easeInOut(duration: 0.22), value: viewModel_confuse.progress_confuse)
        }
        .materialPanelStyle_confuse()
    }

    /// 返回项目资料结果；尚未读取时展示空状态。
    private var resultPanel_confuse: some View {
        VStack(alignment: .leading, spacing: 14) {
            panelTitle_confuse(
                title_confuse: "项目资料",
                subtitle_confuse: "所有字段均按飞书原始内容直接显示，可单独复制。"
            )

            if let record_confuse = viewModel_confuse.record_confuse {
                LazyVGrid(columns: columns_confuse, alignment: .leading, spacing: 12) {
                    ForEach(MaterialField_confuse.allCases) { field_confuse in
                        materialItem_confuse(field_confuse: field_confuse, record_confuse: record_confuse)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "doc.text.fill")
                        .foregroundStyle(Color.confuseBlue_confuse)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(viewModel_confuse.profileStatusText_confuse)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.62))
                        if !viewModel_confuse.profilePathText_confuse.isEmpty {
                            Text(viewModel_confuse.profilePathText_confuse)
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.34))
                                .lineLimit(2)
                                .truncationMode(.middle)
                        }
                    }
                }
            } else {
                VStack(spacing: 10) {
                    Image(systemName: "tray")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(.white.opacity(0.24))
                    Text("尚未读取项目资料")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.54))
                    Text("输入完整 UI 编号并开始整理后，结果会显示在这里。")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.32))
                }
                .frame(maxWidth: .infinity, minHeight: 150)
            }
        }
        .materialPanelStyle_confuse()
        .animation(.easeInOut(duration: 0.24), value: viewModel_confuse.record_confuse)
    }

    /// 返回始终可用的协议生成面板；资料完成后额外支持确认生成 Profile。
    private var agreementResultPanel_confuse: some View {
        AgreementResultPanel_confuse(
            appName_confuse: $viewModel_confuse.appName_confuse,
            email_confuse: $viewModel_confuse.email_confuse,
            hasRecord_confuse: viewModel_confuse.record_confuse != nil,
            states_confuse: viewModel_confuse.agreementStates_confuse,
            messages_confuse: viewModel_confuse.agreementMessages_confuse,
            links_confuse: viewModel_confuse.agreementLinks_confuse,
            copyLink_confuse: { type_confuse in
                viewModel_confuse.copyAgreementLink_confuse(type_confuse: type_confuse)
            },
            openLink_confuse: { type_confuse in
                viewModel_confuse.openAgreementLink_confuse(type_confuse: type_confuse)
            },
            canGenerate_confuse: viewModel_confuse.canGenerateAgreement_confuse,
            generateLink_confuse: { type_confuse in
                viewModel_confuse.generateAgreement_confuse(type_confuse: type_confuse)
            },
            generateAll_confuse: {
                viewModel_confuse.generateAllAgreements_confuse()
            }
        )
        .transition(.opacity.combined(with: .move(edge: .bottom)))
        .animation(.easeInOut(duration: 0.24), value: viewModel_confuse.record_confuse)
    }

    /// 返回单项资料的图标、标题、值和操作按钮。
    /// - Parameters:
    ///   - field_confuse: 当前资料字段。
    ///   - record_confuse: 飞书返回的项目记录。
    /// - Returns: 单项资料卡片。
    private func materialItem_confuse(
        field_confuse: MaterialField_confuse,
        record_confuse: MaterialRecord_confuse
    ) -> some View {
        let value_confuse = record_confuse.value_confuse(field_confuse: field_confuse)
        return HStack(alignment: .center, spacing: 11) {
            Image(systemName: field_confuse.iconName_confuse)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.confuseBlue_confuse)
                .frame(width: 32, height: 32)
                .background(Color.confuseBlue_confuse.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 7))

            VStack(alignment: .leading, spacing: 4) {
                Text(field_confuse.displayName_confuse)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.42))
                Text(value_confuse.isEmpty ? "未填写" : value_confuse)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundStyle(value_confuse.isEmpty ? .white.opacity(0.28) : .white.opacity(0.82))
                    .lineLimit(2)
                    .truncationMode(.middle)
            }

            Spacer(minLength: 6)

            Button {
                viewModel_confuse.copy_confuse(field_confuse: field_confuse)
            } label: {
                Image(systemName: "doc.on.doc")
            }
            .buttonStyle(.plain)
            .disabled(value_confuse.isEmpty)
            .help("复制内容")
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 62)
        .background(Color.black.opacity(0.16))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.confuseBorder_confuse, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
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
}

/// 为整理资料页面的搜索、进度和结果区域提供统一面板样式。
private struct MaterialPanelStyle_confuse: ViewModifier {
    /// 应用整理资料页面的面板样式。
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

/// 为整理资料页面内容提供统一面板样式入口。
private extension View {
    /// 应用整理资料页面统一面板样式。
    /// - Returns: 添加面板样式后的视图。
    func materialPanelStyle_confuse() -> some View {
        modifier(MaterialPanelStyle_confuse())
    }
}
