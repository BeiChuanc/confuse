import AppKit
import Foundation
import UniformTypeIdentifiers

/// 管理 Codemagic 项目、Profile、API 文件、步骤状态和浏览器任务生命周期。
///
/// 视图模型只维护响应式页面状态；Profile 解析和 Chrome 自动化分别交由专用服务，
/// 从而保持文件读取、进程控制和 SwiftUI 展示彼此独立。
@MainActor
final class CodeMagicAutomationViewModel_confuse: ObservableObject {
    @Published var projectPath_confuse = ""
    @Published var projectName_confuse = ""
    @Published var bundleID_confuse = ""
    @Published var issuerID_confuse = ""
    @Published var keyID_confuse = ""
    @Published var apiKeyPath_confuse = ""
    @Published var isExtensionPrepared_confuse = false
    @Published var isRunning_confuse = false
    @Published var progress_confuse = 0.0
    @Published var statusText_confuse = "等待开始"
    @Published var detailText_confuse = "请选择或拖入 iOS 项目。"
    @Published var stepStates_confuse: [CodeMagicStep_confuse: String] = [:]
    @Published var isShowingAlert_confuse = false
    @Published var alertMessage_confuse = ""

    private let automationService_confuse = CodeMagicAutomationService_confuse()
    private let browserService_confuse = MaterialAutomationService_confuse()

    /// 初始化步骤状态并检查浏览器助手是否已经安装。
    init() {
        isExtensionPrepared_confuse = browserService_confuse.isExtensionPrepared_confuse()
        for step_confuse in CodeMagicStep_confuse.allCases {
            stepStates_confuse[step_confuse] = "等待执行"
        }
    }

    /// 返回项目和 Profile 是否允许执行无需上传文件的步骤。
    var isProjectReady_confuse: Bool {
        !projectPath_confuse.isEmpty
            && !projectName_confuse.isEmpty
            && !issuerID_confuse.isEmpty
            && !keyID_confuse.isEmpty
            && isExtensionPrepared_confuse
    }

    /// 返回是否允许执行包含 API Key 创建的一键流程。
    var canRunAll_confuse: Bool {
        isProjectReady_confuse && !apiKeyPath_confuse.isEmpty && !isRunning_confuse
    }

    /// 打开系统选择器选择项目文件夹或 Xcode 工程。
    /// - Returns: 无返回值。
    func chooseProject_confuse() {
        let panel_confuse = NSOpenPanel()
        panel_confuse.title = "选择项目"
        panel_confuse.prompt = "选择"
        panel_confuse.canChooseFiles = true
        panel_confuse.canChooseDirectories = true
        panel_confuse.allowsMultipleSelection = false
        guard panel_confuse.runModal() == .OK, let url_confuse = panel_confuse.url else { return }
        acceptProject_confuse(url_confuse: url_confuse)
    }

    /// 接收选择或拖入的项目并读取其 Profile 字段。
    /// - Parameter url_confuse: 项目文件夹或 `.xcodeproj` URL。
    /// - Returns: 无返回值。
    func acceptProject_confuse(url_confuse: URL) {
        guard !isRunning_confuse else { return }
        do {
            let credentials_confuse = try CodeMagicProfileService_confuse.readCredentials_confuse(
                projectURL_confuse: url_confuse
            )
            projectPath_confuse = url_confuse.path
            projectName_confuse = CodeMagicProfileService_confuse.projectName_confuse(
                projectURL_confuse: url_confuse
            )
            bundleID_confuse = CodeMagicProfileService_confuse.bundleID_confuse(
                projectURL_confuse: url_confuse
            )
            issuerID_confuse = credentials_confuse.issuerID_confuse
            keyID_confuse = credentials_confuse.keyID_confuse
            statusText_confuse = "项目已就绪"
            detailText_confuse = "已从应用同级 PROFILE 目录读取项目配置。"
            progress_confuse = 0
            resetSteps_confuse()
        } catch {
            clearProject_confuse()
            showAlert_confuse(message_confuse: error.localizedDescription)
        }
    }

    /// 打开系统选择器选择 App Store Connect `.p8` API 文件。
    /// - Returns: 无返回值。
    func chooseAPIKey_confuse() {
        let panel_confuse = NSOpenPanel()
        panel_confuse.title = "选择 API 密钥"
        panel_confuse.prompt = "选择"
        panel_confuse.canChooseFiles = true
        panel_confuse.canChooseDirectories = false
        panel_confuse.allowsMultipleSelection = false
        panel_confuse.allowedContentTypes = [UTType(filenameExtension: "p8") ?? .data]
        guard panel_confuse.runModal() == .OK, let url_confuse = panel_confuse.url else { return }
        acceptAPIKey_confuse(url_confuse: url_confuse)
    }

    /// 接收选择或拖入的 `.p8` 文件。
    /// - Parameter url_confuse: App Store Connect API 私钥文件 URL。
    /// - Returns: 无返回值。
    func acceptAPIKey_confuse(url_confuse: URL) {
        guard !isRunning_confuse else { return }
        guard url_confuse.pathExtension.lowercased() == "p8",
              FileManager.default.fileExists(atPath: url_confuse.path) else {
            showAlert_confuse(message_confuse: "请选择有效的 .p8 API 密钥文件。")
            return
        }
        apiKeyPath_confuse = url_confuse.path
        detailText_confuse = "API 密钥已选择，可以执行完整流程。"
    }

    /// 安装或更新浏览器助手并显示 Chrome 扩展管理页。
    /// - Returns: 无返回值。
    func prepareBrowserAssistant_confuse() {
        guard !isRunning_confuse else { return }
        do {
            _ = try browserService_confuse.prepareExtension_confuse()
            isExtensionPrepared_confuse = true
            try browserService_confuse.showExtensionDirectory_confuse()
            try browserService_confuse.openChromeExtensionManager_confuse()
            detailText_confuse = "请在 Chrome 中重新加载 App Tools 浏览器助手后执行。"
        } catch {
            showAlert_confuse(message_confuse: "无法准备浏览器助手，请检查应用资源和 Chrome 安装状态。")
        }
    }

    /// 执行三个 Codemagic 步骤。
    /// - Returns: 无返回值。
    func runAll_confuse() {
        run_confuse(steps_confuse: CodeMagicStep_confuse.allCases)
    }

    /// 执行单个 Codemagic 步骤。
    /// - Parameter step_confuse: 用户选择的自动化步骤。
    /// - Returns: 无返回值。
    func runStep_confuse(step_confuse: CodeMagicStep_confuse) {
        run_confuse(steps_confuse: [step_confuse])
    }

    /// 停止当前 Codemagic 浏览器任务。
    /// - Returns: 无返回值。
    func cancel_confuse() {
        guard isRunning_confuse else { return }
        detailText_confuse = "正在停止 Codemagic 自动化。"
        automationService_confuse.cancel_confuse()
    }

    /// 校验输入并在后台执行指定步骤。
    /// - Parameter steps_confuse: 需要按顺序执行的步骤。
    /// - Returns: 无返回值。
    private func run_confuse(steps_confuse: [CodeMagicStep_confuse]) {
        guard isProjectReady_confuse else {
            showAlert_confuse(message_confuse: "请先选择包含有效 Profile 的项目，并准备浏览器助手。")
            return
        }
        if steps_confuse.contains(.apiKey_confuse) && apiKeyPath_confuse.isEmpty {
            showAlert_confuse(message_confuse: "创建集成前，请选择或拖入 .p8 API 密钥。")
            return
        }
        guard !isRunning_confuse else { return }
        let request_confuse = CodeMagicAutomationRequest_confuse(
            projectPath_confuse: projectPath_confuse,
            projectName_confuse: projectName_confuse,
            bundleID_confuse: bundleID_confuse,
            issuerID_confuse: issuerID_confuse,
            keyID_confuse: keyID_confuse,
            apiKeyPath_confuse: apiKeyPath_confuse,
            steps_confuse: steps_confuse.map(\.rawValue)
        )
        let service_confuse = automationService_confuse
        isRunning_confuse = true
        statusText_confuse = "正在执行"
        progress_confuse = 0.02
        for step_confuse in steps_confuse { stepStates_confuse[step_confuse] = "等待执行" }
        Task { [weak self] in
            let result_confuse: Result<Bool, Error> = await Task.detached(priority: .userInitiated) {
                do {
                    return .success(try service_confuse.run_confuse(request_confuse: request_confuse) {
                        event_confuse in
                        Task { @MainActor [weak self] in
                            self?.applyEvent_confuse(event_confuse: event_confuse)
                        }
                    })
                } catch {
                    return .failure(error)
                }
            }.value
            guard let self_confuse = self else { return }
            self_confuse.isRunning_confuse = false
            switch result_confuse {
            case .success:
                self_confuse.progress_confuse = 1
                self_confuse.statusText_confuse = "执行完成"
                self_confuse.detailText_confuse = "所选 Codemagic 步骤已全部完成。"
                for step_confuse in steps_confuse { self_confuse.stepStates_confuse[step_confuse] = "已完成" }
            case .failure(let error_confuse):
                self_confuse.statusText_confuse = "执行失败"
                self_confuse.detailText_confuse = error_confuse.localizedDescription
                self_confuse.showAlert_confuse(message_confuse: error_confuse.localizedDescription)
            }
        }
    }

    /// 将浏览器助手进度映射到页面总进度和单步状态。
    /// - Parameter event_confuse: Codemagic 脚本输出的结构化事件。
    /// - Returns: 无返回值。
    private func applyEvent_confuse(event_confuse: CodeMagicAutomationEvent_confuse) {
        if let progress_confuse = event_confuse.progress_confuse {
            self.progress_confuse = max(0, min(progress_confuse, 1))
        }
        if let message_confuse = event_confuse.message_confuse {
            detailText_confuse = message_confuse
        }
        if let rawStep_confuse = event_confuse.step_confuse,
           let step_confuse = CodeMagicStep_confuse(rawValue: rawStep_confuse) {
            if event_confuse.state_confuse == "completed" {
                stepStates_confuse[step_confuse] = "已完成"
            } else if event_confuse.state_confuse == "running" {
                stepStates_confuse[step_confuse] = "正在执行"
            } else if event_confuse.state_confuse == "skipped" {
                stepStates_confuse[step_confuse] = "已存在"
            } else if event_confuse.state_confuse == "failed" {
                stepStates_confuse[step_confuse] = "执行失败"
            }
        }
    }

    /// 清空无效项目关联的全部 Profile 字段。
    /// - Returns: 无返回值。
    private func clearProject_confuse() {
        projectPath_confuse = ""
        projectName_confuse = ""
        bundleID_confuse = ""
        issuerID_confuse = ""
        keyID_confuse = ""
    }

    /// 将三个步骤恢复为等待状态。
    /// - Returns: 无返回值。
    private func resetSteps_confuse() {
        for step_confuse in CodeMagicStep_confuse.allCases { stepStates_confuse[step_confuse] = "等待执行" }
    }

    /// 显示云端构建页面统一错误弹窗。
    /// - Parameter message_confuse: 需要展示的中文错误说明。
    /// - Returns: 无返回值。
    private func showAlert_confuse(message_confuse: String) {
        alertMessage_confuse = message_confuse
        isShowingAlert_confuse = true
    }
}
