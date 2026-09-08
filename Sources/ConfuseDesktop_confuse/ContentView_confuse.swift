import SwiftUI
import UniformTypeIdentifiers

/// 构建混淆机主窗口，负责展示配置、拖拽区域、执行控制和结果摘要。
struct ContentView_confuse: View {
    @StateObject private var viewModel_confuse = ConfuseViewModel_confuse()
    @State private var isDropTargeted_confuse = false

    /// 返回混淆机主界面。
    var body: some View {
        HStack(spacing: 0) {
            sidebar_confuse
            Divider().overlay(Color.confuseBorder_confuse)
            mainContent_confuse
        }
        .frame(minWidth: 920, minHeight: 660)
        .background(Color.confuseBackground_confuse)
        .preferredColorScheme(.dark)
    }

    /// 返回左侧品牌和操作导航区域。
    private var sidebar_confuse: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(Color.confuseAccent_confuse)
                Text("混淆机")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("Swift / Flutter 工程混淆工具")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.52))
            }
            .padding(.top, 34)
            .padding(.horizontal, 26)

            Spacer().frame(height: 42)
            Text("操作流程")
                .font(.system(size: 10, weight: .bold))
                .tracking(1.4)
                .foregroundStyle(.white.opacity(0.35))
                .padding(.horizontal, 26)

            VStack(spacing: 8) {
                ForEach(OperationMode_confuse.allCases) { mode_confuse in
                    Button {
                        viewModel_confuse.operation_confuse = mode_confuse
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: icon_confuse(for: mode_confuse))
                                .frame(width: 18)
                            Text(mode_confuse.displayName_confuse)
                            Spacer()
                        }
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(viewModel_confuse.operation_confuse == mode_confuse ? .white : .white.opacity(0.62))
                        .padding(.vertical, 11)
                        .padding(.horizontal, 13)
                        .background(viewModel_confuse.operation_confuse == mode_confuse ? Color.confuseAccent_confuse.opacity(0.18) : .clear)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 14)
            .padding(.horizontal, 16)

            Spacer()
            VStack(alignment: .leading, spacing: 7) {
                Text("引擎信息")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.4)
                    .foregroundStyle(.white.opacity(0.35))
                Text("Swift / Flutter 项目")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))
                Text("支持映射 JSON")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.35))
            }
            .padding(.horizontal, 26)
            .padding(.bottom, 28)
        }
        .frame(width: 218)
        .background(Color.black.opacity(0.16))
    }

    /// 返回右侧主配置内容。
    private var mainContent_confuse: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header_confuse
                projectCard_confuse
                configurationCard_confuse
                actionBar_confuse
                resultCard_confuse
            }
            .padding(.horizontal, 34)
            .padding(.vertical, 30)
        }
    }

    /// 返回页面标题和当前状态。
    private var header_confuse: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 7) {
                Text("项目混淆机")
                    .font(.system(size: 27, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("一次完成源代码名称、资源和引用的处理。")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.52))
            }
            Spacer()
            statusBadge_confuse
        }
    }

    /// 返回工程路径选择和拖拽区域。
    private var projectCard_confuse: some View {
        VStack(alignment: .leading, spacing: 13) {
            cardTitle_confuse(title_confuse: "项目", subtitle_confuse: "选择项目文件夹，或将项目拖入下方区域。")
            HStack(spacing: 10) {
                Image(systemName: "folder.fill")
                    .foregroundStyle(Color.confuseBlue_confuse)
                Text(viewModel_confuse.projectPath_confuse.isEmpty ? "尚未选择项目" : viewModel_confuse.projectPath_confuse)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(viewModel_confuse.projectPath_confuse.isEmpty ? .white.opacity(0.36) : .white.opacity(0.8))
                Spacer()
                Button("选择文件夹") { viewModel_confuse.chooseProject_confuse() }
                    .buttonStyle(.bordered)
                    .tint(Color.confuseBlue_confuse)
            }
            .padding(13)
            .background(Color.black.opacity(0.18))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(isDropTargeted_confuse ? Color.confuseAccent_confuse : Color.white.opacity(0.15), style: StrokeStyle(lineWidth: 1.2, dash: [6]))
                    .background(Color.white.opacity(isDropTargeted_confuse ? 0.06 : 0.025).clipShape(RoundedRectangle(cornerRadius: 10)))
                VStack(spacing: 7) {
                    Image(systemName: "arrow.down.to.line.compact")
                        .font(.system(size: 21, weight: .medium))
                        .foregroundStyle(isDropTargeted_confuse ? Color.confuseAccent_confuse : .white.opacity(0.58))
                    Text("将项目文件夹拖到这里")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.72))
                    Text("支持 Swift / Flutter")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.34))
                }
            }
            .frame(height: 106)
            .onDrop(of: [UTType.fileURL.identifier], isTargeted: $isDropTargeted_confuse) { providers_confuse in
                guard let provider_confuse = providers_confuse.first else { return false }
                provider_confuse.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item_confuse, _ in
                    guard let data_confuse = item_confuse as? Data,
                          let url_confuse = URL(dataRepresentation: data_confuse, relativeTo: nil) else { return }
                    Task { @MainActor in viewModel_confuse.acceptProject_confuse(url_confuse: url_confuse) }
                }
                return true
            }
        }
        .cardStyle_confuse()
    }

    /// 返回工程类型、后缀和映射文件配置。
    private var configurationCard_confuse: some View {
        VStack(alignment: .leading, spacing: 16) {
            cardTitle_confuse(title_confuse: "配置", subtitle_confuse: "自动识别的配置可以在执行前调整。")
            HStack(spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("项目类型")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.52))
                    Picker("项目类型", selection: $viewModel_confuse.projectType_confuse) {
                        ForEach(ProjectType_confuse.allCases) { type_confuse in
                            Text(type_confuse.displayName_confuse).tag(type_confuse)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text("项目后缀")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.52))
                    HStack(spacing: 8) {
                        TextField("_项目后缀", text: $viewModel_confuse.suffix_confuse)
                            .textFieldStyle(.roundedBorder)
                        Button {
                            viewModel_confuse.detectConfiguration_confuse()
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                        .help("从项目读取后缀")
                        .buttonStyle(.bordered)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("命名规则")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.52))
                Picker("命名规则", selection: $viewModel_confuse.namingRule_confuse) {
                    ForEach(NamingRule_confuse.allCases) { rule_confuse in
                        Text(rule_confuse.displayName_confuse).tag(rule_confuse)
                    }
                }
                .pickerStyle(.segmented)

                HStack(spacing: 8) {
                    Image(systemName: "character.cursor.ibeam")
                        .foregroundStyle(Color.confuseBlue_confuse)
                    Text(viewModel_confuse.namingRule_confuse.description_confuse)
                        .foregroundStyle(.white.opacity(0.52))
                    Spacer()
                    Text(viewModel_confuse.namingRule_confuse.example_confuse)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(Color.confuseAccent_confuse)
                }
                .font(.system(size: 11))
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 7))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("映射 JSON")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.52))
                HStack(spacing: 9) {
                    Image(systemName: "doc.text.fill")
                        .foregroundStyle(Color.confuseAccent_confuse)
                    Text(viewModel_confuse.mappingDisplayPath_confuse)
                        .font(.system(size: 11, design: .monospaced))
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .foregroundStyle(.white.opacity(0.72))
                    Spacer()
                }
                .padding(10)
                .background(Color.black.opacity(0.16))
                .clipShape(RoundedRectangle(cornerRadius: 7))
            }
        }
        .cardStyle_confuse()
    }

    /// 返回执行按钮和任务说明。
    private var actionBar_confuse: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(viewModel_confuse.operation_confuse.displayName_confuse)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                Text("操作会直接修改选中的项目目录。")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.4))
            }
            Spacer()
            Button {
                viewModel_confuse.runOperation_confuse()
            } label: {
                HStack(spacing: 8) {
                    if viewModel_confuse.isRunning_confuse {
                        ProgressView().controlSize(.small)
                    } else {
                        Image(systemName: "play.fill")
                    }
                    Text(viewModel_confuse.isRunning_confuse ? "执行中..." : "执行操作")
                }
                .font(.system(size: 13, weight: .semibold))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.confuseAccent_confuse)
            .disabled(viewModel_confuse.isRunning_confuse)
        }
    }

    /// 返回任务状态和统计结果。
    private var resultCard_confuse: some View {
        VStack(alignment: .leading, spacing: 13) {
            cardTitle_confuse(title_confuse: "执行状态", subtitle_confuse: viewModel_confuse.detail_confuse)
            HStack(spacing: 0) {
                metric_confuse(title_confuse: "文件数", value_confuse: viewModel_confuse.lastResult_confuse?.renamedFiles_confuse.map(String.init) ?? "—")
                Divider().frame(height: 32).overlay(Color.confuseBorder_confuse)
                metric_confuse(title_confuse: "已更新", value_confuse: viewModel_confuse.lastResult_confuse?.updatedFiles_confuse.map(String.init) ?? "—")
                Divider().frame(height: 32).overlay(Color.confuseBorder_confuse)
                metric_confuse(title_confuse: "符号数", value_confuse: viewModel_confuse.lastResult_confuse?.symbolCount_confuse.map(String.init) ?? "—")
                Spacer()
            }
            .padding(.top, 2)
        }
        .cardStyle_confuse()
    }

    /// 返回状态徽章。
    private var statusBadge_confuse: some View {
        HStack(spacing: 7) {
            Circle()
                .fill(viewModel_confuse.isRunning_confuse ? Color.orange : Color.confuseAccent_confuse)
                .frame(width: 7, height: 7)
            Text(viewModel_confuse.status_confuse)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.75))
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 7)
        .background(Color.white.opacity(0.07))
        .clipShape(Capsule())
    }

    /// 返回卡片标题组件。
    /// - Parameters:
    ///   - title_confuse: 标题文本。
    ///   - subtitle_confuse: 辅助说明文本。
    /// - Returns: 标题视图。
    private func cardTitle_confuse(title_confuse: String, subtitle_confuse: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title_confuse)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
            Text(subtitle_confuse)
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.4))
        }
    }

    /// 返回统计数字组件。
    /// - Parameters:
    ///   - title_confuse: 统计项名称。
    ///   - value_confuse: 统计项数值。
    /// - Returns: 统计视图。
    private func metric_confuse(title_confuse: String, value_confuse: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value_confuse)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(title_confuse)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.4))
        }
        .frame(width: 118, alignment: .leading)
    }

    /// 返回操作对应的系统图标名称。
    /// - Parameter mode_confuse: 操作类型。
    /// - Returns: SF Symbols 图标名称。
    private func icon_confuse(for mode_confuse: OperationMode_confuse) -> String {
        switch mode_confuse {
        case .obfuscate_confuse: return "wand.and.stars"
        case .deobfuscate_confuse: return "arrow.uturn.backward"
        case .merge_confuse: return "square.stack.3d.up"
        }
    }
}

/// 为主界面卡片统一提供背景、边框和内边距。
private struct CardStyle_confuse: ViewModifier {
    /// 应用卡片样式。
    /// - Parameter content_confuse: 被修饰的内容。
    /// - Returns: 具有统一视觉样式的内容。
    func body(content: Content) -> some View {
        content
            .padding(18)
            .background(Color.confusePanel_confuse)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.confuseBorder_confuse, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

/// 为 SwiftUI 内容提供统一的混淆机卡片样式。
private extension View {
    /// 应用混淆机卡片样式。
    /// - Returns: 添加卡片样式后的视图。
    func cardStyle_confuse() -> some View {
        modifier(CardStyle_confuse())
    }
}
