import SwiftUI

/// 展示项目初始化表单、七步执行进度和创建结果，所有业务操作交由视图模型处理。
struct ProjectInitializationView_confuse: View {
    @ObservedObject var viewModel_confuse: ProjectInitializationViewModel_confuse

    /// 返回项目初始化页面。
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header_confuse
                configurationPanel_confuse
                progressPanel_confuse
                actionBar_confuse
            }
            .padding(.horizontal, 34)
            .padding(.vertical, 30)
        }
    }

    /// 返回页面标题和当前创建状态。
    private var header_confuse: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 7) {
                Text("初始化项目")
                    .font(.system(size: 27, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("根据内置基础模板创建并整理新的移动应用工程。")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.52))
            }
            Spacer()
            HStack(spacing: 7) {
                Circle()
                    .fill(viewModel_confuse.isInitializing_confuse ? Color.orange : Color.confuseAccent_confuse)
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

    /// 返回项目类型、名称和保存目录配置区域。
    private var configurationPanel_confuse: some View {
        VStack(alignment: .leading, spacing: 18) {
            sectionTitle_confuse(
                title_confuse: "项目配置",
                subtitle_confuse: "项目名称将同时用于工程、目标和源码标识后缀。"
            )

            VStack(alignment: .leading, spacing: 8) {
                Text("项目类型")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.52))
                Picker("项目类型", selection: $viewModel_confuse.projectType_confuse) {
                    Text("Swift").tag(ProjectType_confuse.swift_confuse)
                    Text("Flutter（暂未支持）").tag(ProjectType_confuse.flutter_confuse)
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("项目名称")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.52))
                TextField("请输入项目名称", text: $viewModel_confuse.projectName_confuse)
                    .textFieldStyle(.roundedBorder)
                    .disabled(viewModel_confuse.isInitializing_confuse)
                Text("名称必须以英文字母开头，只能包含英文字母、数字和下划线。")
                    .font(.system(size: 10))
                    .foregroundStyle(
                        viewModel_confuse.projectName_confuse.isEmpty || viewModel_confuse.isProjectNameValid_confuse
                            ? .white.opacity(0.34)
                            : Color.red.opacity(0.78)
                    )
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("保存位置")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.52))
                HStack(spacing: 10) {
                    Image(systemName: "folder.fill")
                        .foregroundStyle(Color.confuseBlue_confuse)
                    Text(viewModel_confuse.destinationDirectoryPath_confuse.isEmpty
                         ? "尚未选择保存目录"
                         : viewModel_confuse.destinationDirectoryPath_confuse)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.68))
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Spacer()
                    Button("选择目录") {
                        viewModel_confuse.chooseDestinationDirectory_confuse()
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewModel_confuse.isInitializing_confuse)
                }
                .padding(11)
                .background(Color.black.opacity(0.16))
                .clipShape(RoundedRectangle(cornerRadius: 7))
            }
        }
        .initializationPanelStyle_confuse()
    }

    /// 返回总进度和七个初始化步骤。
    private var progressPanel_confuse: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                sectionTitle_confuse(
                    title_confuse: "执行进度",
                    subtitle_confuse: viewModel_confuse.detailText_confuse
                )
                Spacer()
                Text("\(Int(viewModel_confuse.progressValue_confuse * 100))%")
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color.confuseAccent_confuse)
            }

            ProgressView(value: viewModel_confuse.progressValue_confuse)
                .progressViewStyle(.linear)
                .tint(Color.confuseAccent_confuse)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2),
                spacing: 10
            ) {
                ForEach(ProjectInitializationStep_confuse.allCases) { step_confuse in
                    stepRow_confuse(step_confuse: step_confuse)
                }
            }
        }
        .initializationPanelStyle_confuse()
    }

    /// 返回创建和打开工程操作栏。
    private var actionBar_confuse: some View {
        HStack {
            if !viewModel_confuse.createdProjectPath_confuse.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.confuseAccent_confuse)
                    Text(viewModel_confuse.createdProjectPath_confuse)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.52))
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                Button("打开工程") {
                    viewModel_confuse.openCreatedProject_confuse()
                }
                .buttonStyle(.bordered)
            }

            Spacer()

            Button {
                viewModel_confuse.createProject_confuse()
            } label: {
                HStack(spacing: 8) {
                    if viewModel_confuse.isInitializing_confuse {
                        ProgressView().controlSize(.small)
                    } else {
                        Image(systemName: "plus.square.fill")
                    }
                    Text(viewModel_confuse.isInitializing_confuse ? "正在创建" : "创建项目")
                }
                .font(.system(size: 13, weight: .semibold))
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.confuseAccent_confuse)
            .disabled(!viewModel_confuse.canCreateProject_confuse)
        }
    }

    /// 返回统一的区域标题。
    /// - Parameters:
    ///   - title_confuse: 区域标题。
    ///   - subtitle_confuse: 区域辅助说明。
    /// - Returns: 标题视图。
    private func sectionTitle_confuse(
        title_confuse: String,
        subtitle_confuse: String
    ) -> some View {
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

    /// 返回单个初始化步骤的状态行。
    /// - Parameter step_confuse: 当前展示的初始化步骤。
    /// - Returns: 包含状态图标和步骤名称的视图。
    private func stepRow_confuse(
        step_confuse: ProjectInitializationStep_confuse
    ) -> some View {
        let state_confuse = viewModel_confuse.stepState_confuse(step_confuse: step_confuse)
        return HStack(spacing: 10) {
            Group {
                switch state_confuse {
                case .pending_confuse:
                    Image(systemName: "circle")
                        .foregroundStyle(.white.opacity(0.22))
                case .running_confuse:
                    ProgressView().controlSize(.small)
                case .completed_confuse:
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.confuseAccent_confuse)
                }
            }
            .frame(width: 18, height: 18)

            Text(step_confuse.displayName_confuse)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(state_confuse == .pending_confuse ? .white.opacity(0.38) : .white.opacity(0.78))
            Spacer()
        }
        .padding(.horizontal, 11)
        .frame(height: 36)
        .background(Color.black.opacity(state_confuse == .running_confuse ? 0.25 : 0.12))
        .overlay(
            RoundedRectangle(cornerRadius: 7)
                .stroke(
                    state_confuse == .running_confuse
                        ? Color.confuseAccent_confuse.opacity(0.42)
                        : Color.white.opacity(0.05),
                    lineWidth: 1
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 7))
    }
}

/// 为初始化页面的配置和进度区域提供统一面板样式。
private struct InitializationPanelStyle_confuse: ViewModifier {
    /// 应用初始化页面面板样式。
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

/// 为初始化页面内容提供面板样式入口。
private extension View {
    /// 应用初始化页面面板样式。
    /// - Returns: 添加统一面板样式后的视图。
    func initializationPanelStyle_confuse() -> some View {
        modifier(InitializationPanelStyle_confuse())
    }
}
