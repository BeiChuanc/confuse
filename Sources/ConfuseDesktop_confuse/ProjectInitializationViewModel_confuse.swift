import AppKit
import Foundation

/// 管理项目初始化表单、目录选择、执行状态和七步进度反馈。
@MainActor
final class ProjectInitializationViewModel_confuse: ObservableObject {
    @Published var projectType_confuse: ProjectType_confuse = .swift_confuse
    @Published var projectName_confuse = ""
    @Published var destinationDirectoryPath_confuse = ""
    @Published var progressValue_confuse = 0.0
    @Published var statusText_confuse = "等待创建"
    @Published var detailText_confuse = "请输入项目名称并选择保存目录。"
    @Published var activeStep_confuse: ProjectInitializationStep_confuse?
    @Published var completedSteps_confuse: Set<ProjectInitializationStep_confuse> = []
    @Published var isInitializing_confuse = false
    @Published var createdProjectPath_confuse = ""

    /// 返回当前表单是否可以开始创建项目。
    var canCreateProject_confuse: Bool {
        !isInitializing_confuse
            && projectType_confuse == .swift_confuse
            && isProjectNameValid_confuse
            && !destinationDirectoryPath_confuse.isEmpty
    }

    /// 返回项目名称是否符合 Xcode 工程与 Swift 标识符要求。
    var isProjectNameValid_confuse: Bool {
        let trimmedName_confuse = projectName_confuse.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedName_confuse.range(
            of: "^[A-Za-z][A-Za-z0-9_]*$",
            options: .regularExpression
        ) != nil
    }

    /// 打开保存目录选择器并记录用户选择的父目录。
    func chooseDestinationDirectory_confuse() {
        let panel_confuse = NSOpenPanel()
        panel_confuse.title = "选择项目保存目录"
        panel_confuse.prompt = "选择"
        panel_confuse.canChooseDirectories = true
        panel_confuse.canChooseFiles = false
        panel_confuse.allowsMultipleSelection = false
        if panel_confuse.runModal() == .OK, let url_confuse = panel_confuse.url {
            destinationDirectoryPath_confuse = url_confuse.path
            createdProjectPath_confuse = ""
        }
    }

    /// 校验表单并在后台执行完整的 Swift 项目初始化流程。
    func createProject_confuse() {
        let cleanName_confuse = projectName_confuse.trimmingCharacters(in: .whitespacesAndNewlines)
        guard projectType_confuse == .swift_confuse else {
            showAlert_confuse(title_confuse: "暂不支持", message_confuse: "Flutter 项目创建功能将在后续补全。")
            return
        }
        guard isProjectNameValid_confuse else {
            showAlert_confuse(
                title_confuse: "项目名称无效",
                message_confuse: "项目名称必须以英文字母开头，并且只能包含英文字母、数字和下划线。"
            )
            return
        }
        guard !destinationDirectoryPath_confuse.isEmpty else {
            showAlert_confuse(title_confuse: "缺少保存目录", message_confuse: "请先选择项目保存目录。")
            return
        }

        let request_confuse = ProjectInitializationRequest_confuse(
            projectName_confuse: cleanName_confuse,
            projectType_confuse: projectType_confuse,
            destinationDirectoryPath_confuse: destinationDirectoryPath_confuse
        )
        resetProgress_confuse()
        isInitializing_confuse = true
        statusText_confuse = "正在创建"
        detailText_confuse = "正在准备项目初始化流程。"

        Task { [weak self] in
            let result_confuse: Result<URL, Error> = await Task.detached(priority: .userInitiated) {
                do {
                    let projectURL_confuse = try ProjectInitializationService_confuse.createProject_confuse(
                        request_confuse: request_confuse
                    ) { progress_confuse in
                        Task { @MainActor [weak self] in
                            self?.applyProgress_confuse(progress_confuse: progress_confuse)
                        }
                    }
                    return .success(projectURL_confuse)
                } catch {
                    return .failure(error)
                }
            }.value

            guard let self_confuse = self else { return }
            self_confuse.isInitializing_confuse = false
            switch result_confuse {
            case .success(let projectURL_confuse):
                self_confuse.progressValue_confuse = 1
                self_confuse.activeStep_confuse = nil
                self_confuse.completedSteps_confuse = Set(ProjectInitializationStep_confuse.allCases)
                self_confuse.statusText_confuse = "创建完成"
                self_confuse.detailText_confuse = "项目已创建，可以直接打开工程检查配置。"
                self_confuse.createdProjectPath_confuse = projectURL_confuse.path
            case .failure(let error_confuse):
                self_confuse.activeStep_confuse = nil
                self_confuse.statusText_confuse = "创建失败"
                self_confuse.detailText_confuse = error_confuse.localizedDescription
                self_confuse.showAlert_confuse(
                    title_confuse: "项目创建失败",
                    message_confuse: error_confuse.localizedDescription
                )
            }
        }
    }

    /// 返回指定初始化步骤的当前状态。
    /// - Parameter step_confuse: 待查询的初始化步骤。
    /// - Returns: 待执行、执行中或已完成状态。
    func stepState_confuse(
        step_confuse: ProjectInitializationStep_confuse
    ) -> ProjectInitializationStepState_confuse {
        if completedSteps_confuse.contains(step_confuse) { return .completed_confuse }
        if activeStep_confuse == step_confuse { return .running_confuse }
        return .pending_confuse
    }

    /// 使用系统默认应用打开已创建的 Xcode 工程。
    func openCreatedProject_confuse() {
        guard !createdProjectPath_confuse.isEmpty else { return }
        let projectRootURL_confuse = URL(
            fileURLWithPath: createdProjectPath_confuse,
            isDirectory: true
        )
        let projectURL_confuse = projectRootURL_confuse
            .appendingPathComponent(projectRootURL_confuse.lastPathComponent)
            .appendingPathExtension("xcodeproj")
        NSWorkspace.shared.open(projectURL_confuse)
    }

    /// 应用初始化服务发送的单步进度。
    /// - Parameter progress_confuse: 当前步骤和状态说明。
    private func applyProgress_confuse(progress_confuse: ProjectInitializationProgress_confuse) {
        detailText_confuse = progress_confuse.detail_confuse
        switch progress_confuse.state_confuse {
        case .pending_confuse:
            break
        case .running_confuse:
            activeStep_confuse = progress_confuse.step_confuse
        case .completed_confuse:
            completedSteps_confuse.insert(progress_confuse.step_confuse)
            activeStep_confuse = nil
        }
        progressValue_confuse = Double(completedSteps_confuse.count)
            / Double(ProjectInitializationStep_confuse.allCases.count)
    }

    /// 清空上一次创建结果和步骤状态。
    private func resetProgress_confuse() {
        progressValue_confuse = 0
        activeStep_confuse = nil
        completedSteps_confuse = []
        createdProjectPath_confuse = ""
    }

    /// 显示统一的中文错误弹窗。
    /// - Parameters:
    ///   - title_confuse: 弹窗标题。
    ///   - message_confuse: 错误说明。
    private func showAlert_confuse(title_confuse: String, message_confuse: String) {
        let alert_confuse = NSAlert()
        alert_confuse.alertStyle = .warning
        alert_confuse.messageText = title_confuse
        alert_confuse.informativeText = message_confuse
        alert_confuse.addButton(withTitle: "确定")
        alert_confuse.runModal()
    }
}
