import AppKit
import Combine
import Foundation
import UniformTypeIdentifiers

/// 管理合包语言、类型、目标项目、后台配置和执行进度。
///
/// 视图模型负责用户输入与响应式状态，后台读取、Podfile、Xcode 工程、源码和
/// Info.plist 修改均委托给服务层，避免页面直接承载业务逻辑。
@MainActor
final class PackageAssemblyViewModel_confuse: ObservableObject {
    @Published var language_confuse: PackageLanguage_confuse = .swift_confuse
    @Published var type_confuse: PackageType_confuse = .video20_confuse
    @Published var packageFiles_confuse: [String] = []
    @Published var targetProjectPath_confuse = ""
    @Published var targetBundleID_confuse = ""
    @Published var backendAccount_confuse = ""
    @Published var backendPassword_confuse = ""
    @Published var backendTwoFactorCode_confuse = ""
    @Published var backendConfiguration_confuse: BackendConfiguration_confuse?
    @Published var backendProgress_confuse = 0.0
    @Published var backendStatusText_confuse = "等待获取"
    @Published var backendDetailText_confuse = "选择有效目标项目后获取后台配置。"
    @Published var isFetchingBackend_confuse = false
    @Published var isExtensionPrepared_confuse = false
    @Published var extensionStatusText_confuse = "尚未准备浏览器助手"
    @Published var hasFacebook_confuse = false
    @Published var missingFiles_confuse: [String] = []
    @Published var isTargetReady_confuse = false
    @Published var isRunning_confuse = false
    @Published var progress_confuse = 0.0
    @Published var statusText_confuse = "等待选择"
    @Published var detailText_confuse = "请选择或拖入目标项目。"
    @Published var directoryText_confuse = ""
    @Published var isShowingAlert_confuse = false
    @Published var alertMessage_confuse = ""

    private let backendService_confuse = BackendConfigurationService_confuse()
    private let browserService_confuse = MaterialAutomationService_confuse()
    private let requiredPackageDisplayNames_confuse = [
        "Podfile",
        "AppDelegate.swift",
        "BendoBaseDefaultViewController.swift",
        "BendoBaseShare.swift",
        "BendoExtension.swift"
    ]

    /// 创建合包整理视图模型，并立即读取默认选择对应的代码文件和浏览器助手状态。
    init() {
        isExtensionPrepared_confuse = browserService_confuse.isExtensionPrepared_confuse()
        extensionStatusText_confuse = isExtensionPrepared_confuse
            ? "浏览器助手已准备，请确认 Chrome 中已启用"
            : "尚未准备浏览器助手"
        refresh_confuse()
    }

    /// 返回后台读取或合包任务是否正在执行。
    var isBusy_confuse: Bool {
        isFetchingBackend_confuse || isRunning_confuse
    }

    /// 返回当前输入是否允许获取后台配置。
    var canFetchBackendConfiguration_confuse: Bool {
        !isBusy_confuse
            && language_confuse == .swift_confuse
            && isTargetReady_confuse
            && isExtensionPrepared_confuse
            && !targetBundleID_confuse.isEmpty
            && !backendAccount_confuse.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !backendPassword_confuse.isEmpty
            && !backendTwoFactorCode_confuse.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// 返回当前选择和后台配置是否允许执行合包。
    var canAssemble_confuse: Bool {
        !isBusy_confuse
            && language_confuse == .swift_confuse
            && !targetProjectPath_confuse.isEmpty
            && isTargetReady_confuse
            && missingFiles_confuse.isEmpty
            && backendConfiguration_confuse?.bundleID_confuse == targetBundleID_confuse
    }

    /// 切换合包语言并刷新当前代码和目标检查结果。
    /// - Parameter language_confuse: 新选择的项目语言。
    func selectLanguage_confuse(language_confuse: PackageLanguage_confuse) {
        self.language_confuse = language_confuse
        invalidateBackendConfiguration_confuse()
        refresh_confuse()
    }

    /// 切换合包类型并刷新当前代码和目标检查结果。
    /// - Parameter type_confuse: 新选择的合包类型。
    func selectType_confuse(type_confuse: PackageType_confuse) {
        self.type_confuse = type_confuse
        refresh_confuse()
    }

    /// 打开系统选择器选择 Swift 工程目录或 xcodeproj。
    func chooseTargetProject_confuse() {
        let panel_confuse = NSOpenPanel()
        panel_confuse.title = "选择目标项目"
        panel_confuse.prompt = "选择"
        panel_confuse.canChooseFiles = true
        panel_confuse.canChooseDirectories = true
        panel_confuse.allowsMultipleSelection = false
        panel_confuse.allowedContentTypes = [.folder, .package]
        guard panel_confuse.runModal() == .OK, let url_confuse = panel_confuse.url else { return }
        acceptTargetProject_confuse(url_confuse: url_confuse)
    }

    /// 接收拖入或选择的目标工程并执行结构检查。
    /// - Parameter url_confuse: 目标工程目录或 xcodeproj URL。
    func acceptTargetProject_confuse(url_confuse: URL) {
        guard !isBusy_confuse else { return }
        targetProjectPath_confuse = url_confuse.path
        targetBundleID_confuse = ""
        invalidateBackendConfiguration_confuse()
        inspectTarget_confuse()
    }

    /// 读取当前语言与合包类型对应的 PACKAGE 文件并刷新检查结果。
    func refresh_confuse() {
        let selectedDirectoryURL_confuse = PackageAssemblyService_confuse.packageDirectoryURL_confuse()
            .appendingPathComponent(language_confuse.rawValue, isDirectory: true)
            .appendingPathComponent(type_confuse.rawValue, isDirectory: true)
        directoryText_confuse = selectedDirectoryURL_confuse.path
        let files_confuse = PackageAssemblyService_confuse.matchingFiles_confuse(
            language_confuse: language_confuse,
            type_confuse: type_confuse
        )
        packageFiles_confuse = displayPackageFiles_confuse(paths_confuse: files_confuse.map(\.path))
        if language_confuse == .flutter_confuse {
            hasFacebook_confuse = false
            missingFiles_confuse = []
            isTargetReady_confuse = false
            targetBundleID_confuse = ""
            statusText_confuse = "Flutter 待支持"
            detailText_confuse = "Flutter 合包功能暂未开放。"
            return
        }
        inspectTarget_confuse()
    }

    /// 安装或更新浏览器助手资源，并打开当前 Chrome 的扩展管理页。
    func prepareBrowserAssistant_confuse() {
        guard !isBusy_confuse else { return }
        do {
            _ = try browserService_confuse.prepareExtension_confuse()
            isExtensionPrepared_confuse = true
            extensionStatusText_confuse = "浏览器助手已更新，请在 Chrome 中重新加载"
            try browserService_confuse.showExtensionDirectory_confuse()
            try browserService_confuse.openChromeExtensionManager_confuse()
        } catch {
            showAlert_confuse(message_confuse: error.localizedDescription)
        }
    }

    /// 校验后台凭据和目标 Bundle ID，并通过当前 Chrome 获取后台配置。
    func fetchBackendConfiguration_confuse() {
        guard language_confuse == .swift_confuse, isTargetReady_confuse, !targetBundleID_confuse.isEmpty else {
            showAlert_confuse(message_confuse: "请先选择有效的目标 Swift 项目。")
            return
        }
        guard isExtensionPrepared_confuse else {
            showAlert_confuse(message_confuse: "请先更新并启用 App Tools 浏览器助手。")
            return
        }
        let account_confuse = backendAccount_confuse.trimmingCharacters(in: .whitespacesAndNewlines)
        let password_confuse = backendPassword_confuse
        let twoFactorCode_confuse = backendTwoFactorCode_confuse.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !account_confuse.isEmpty, !password_confuse.isEmpty, !twoFactorCode_confuse.isEmpty else {
            showAlert_confuse(message_confuse: "请完整填写后台账号、密码和 2FA。")
            return
        }
        guard !isBusy_confuse else { return }

        let request_confuse = BackendConfigurationRequest_confuse(
            account_confuse: account_confuse,
            password_confuse: password_confuse,
            twoFactorCode_confuse: twoFactorCode_confuse,
            bundleID_confuse: targetBundleID_confuse
        )
        let service_confuse = backendService_confuse
        isFetchingBackend_confuse = true
        backendConfiguration_confuse = nil
        backendProgress_confuse = 0.02
        backendStatusText_confuse = "正在获取"
        backendDetailText_confuse = "正在等待当前 Chrome 中的浏览器助手。"

        Task { [weak self] in
            let result_confuse: Result<BackendConfiguration_confuse, Error> = await Task.detached(
                priority: .userInitiated
            ) {
                do {
                    let configuration_confuse = try service_confuse.run_confuse(
                        request_confuse: request_confuse
                    ) { event_confuse in
                        Task { @MainActor [weak self] in
                            if let progress_confuse = event_confuse.progress_confuse {
                                self?.backendProgress_confuse = progress_confuse
                            }
                            if let message_confuse = event_confuse.message_confuse, !message_confuse.isEmpty {
                                self?.backendDetailText_confuse = message_confuse
                            }
                        }
                    }
                    return .success(configuration_confuse)
                } catch {
                    return .failure(error)
                }
            }.value

            guard let self_confuse = self else { return }
            self_confuse.isFetchingBackend_confuse = false
            self_confuse.backendPassword_confuse = ""
            self_confuse.backendTwoFactorCode_confuse = ""
            switch result_confuse {
            case .success(let configuration_confuse):
                guard configuration_confuse.bundleID_confuse == self_confuse.targetBundleID_confuse else {
                    self_confuse.backendStatusText_confuse = "配置不匹配"
                    self_confuse.backendDetailText_confuse = "目标项目已改变，请重新获取后台配置。"
                    self_confuse.showAlert_confuse(message_confuse: "后台配置与当前目标项目不一致，请重新获取。")
                    return
                }
                self_confuse.backendConfiguration_confuse = configuration_confuse
                self_confuse.backendProgress_confuse = 1
                self_confuse.backendStatusText_confuse = "获取完成"
                self_confuse.backendDetailText_confuse = configuration_confuse.hasFacebook_confuse
                    ? "已读取 AppsFlyer、域名和 Facebook 配置。"
                    : "后台标签无 FB，Facebook 三项配置已设为 0。"
            case .failure(let error_confuse):
                self_confuse.backendProgress_confuse = 0
                self_confuse.backendStatusText_confuse = "获取失败"
                self_confuse.backendDetailText_confuse = error_confuse.localizedDescription
                self_confuse.showAlert_confuse(message_confuse: error_confuse.localizedDescription)
            }
        }
    }

    /// 停止当前后台配置读取任务。
    func stopBackendConfiguration_confuse() {
        guard isFetchingBackend_confuse else { return }
        backendService_confuse.cancel_confuse()
        backendDetailText_confuse = "正在停止后台配置读取。"
    }

    /// 校验后台配置并在后台执行 Swift 合包整理。
    func assemble_confuse() {
        guard language_confuse == .swift_confuse else {
            showAlert_confuse(message_confuse: "Flutter 合包功能暂未开放。")
            return
        }
        guard !targetProjectPath_confuse.isEmpty, isTargetReady_confuse else {
            showAlert_confuse(message_confuse: "请选择或拖入有效的目标 Swift 项目。")
            return
        }
        guard missingFiles_confuse.isEmpty else {
            showAlert_confuse(message_confuse: "缺少合包文件：\(missingFiles_confuse.joined(separator: ", "))。")
            return
        }
        guard let backendConfiguration_confuse,
              backendConfiguration_confuse.bundleID_confuse == targetBundleID_confuse else {
            showAlert_confuse(message_confuse: "请先获取与当前目标项目匹配的后台配置。")
            return
        }
        guard !isBusy_confuse else { return }

        let targetURL_confuse = URL(fileURLWithPath: targetProjectPath_confuse, isDirectory: true)
        let type_confuse = type_confuse
        isRunning_confuse = true
        progress_confuse = 0.02
        statusText_confuse = "处理中"
        detailText_confuse = "正在检查目标项目。"

        Task { [weak self] in
            let result_confuse: Result<URL, Error> = await Task.detached(priority: .userInitiated) {
                do {
                    let outputURL_confuse = try SwiftPackageAssemblyService_confuse.assemble_confuse(
                        targetURL_confuse: targetURL_confuse,
                        type_confuse: type_confuse,
                        backendConfiguration_confuse: backendConfiguration_confuse
                    ) { progress_confuse in
                        Task { @MainActor [weak self] in
                            self?.progress_confuse = progress_confuse.progress_confuse
                            self?.detailText_confuse = progress_confuse.detail_confuse
                        }
                    }
                    return .success(outputURL_confuse)
                } catch {
                    return .failure(error)
                }
            }.value

            guard let self_confuse = self else { return }
            self_confuse.isRunning_confuse = false
            switch result_confuse {
            case .success:
                self_confuse.progress_confuse = 1
                self_confuse.statusText_confuse = "已完成"
                self_confuse.detailText_confuse = "Swift 合包整理已完成，请在构建前执行 pod install。"
                self_confuse.inspectTarget_confuse()
            case .failure(let error_confuse):
                self_confuse.statusText_confuse = "失败"
                self_confuse.detailText_confuse = error_confuse.localizedDescription
                self_confuse.showAlert_confuse(message_confuse: error_confuse.localizedDescription)
            }
        }
    }

    /// 检查目标工程、Bundle ID、必需合包文件和 Facebook 使用状态。
    private func inspectTarget_confuse() {
        guard language_confuse == .swift_confuse else { return }
        guard !targetProjectPath_confuse.isEmpty else {
            missingFiles_confuse = []
            hasFacebook_confuse = false
            isTargetReady_confuse = false
            targetBundleID_confuse = ""
            statusText_confuse = packageFiles_confuse.isEmpty ? "无合包代码" : "等待选择"
            detailText_confuse = packageFiles_confuse.isEmpty
                ? "请将 Swift 合包代码放入当前选择的 PACKAGE 目录。"
                : "请选择或拖入目标 Swift 项目。"
            return
        }
        do {
            let inspection_confuse = try SwiftPackageAssemblyService_confuse.inspect_confuse(
                targetURL_confuse: URL(fileURLWithPath: targetProjectPath_confuse, isDirectory: true),
                type_confuse: type_confuse
            )
            if !targetBundleID_confuse.isEmpty, targetBundleID_confuse != inspection_confuse.bundleID_confuse {
                invalidateBackendConfiguration_confuse()
            }
            targetProjectPath_confuse = inspection_confuse.targetRootPath_confuse
            targetBundleID_confuse = inspection_confuse.bundleID_confuse
            packageFiles_confuse = displayPackageFiles_confuse(paths_confuse: inspection_confuse.packageFiles_confuse)
            missingFiles_confuse = inspection_confuse.missingPackageFiles_confuse
            hasFacebook_confuse = inspection_confuse.hasFacebook_confuse
            isTargetReady_confuse = inspection_confuse.isReady_confuse
            statusText_confuse = inspection_confuse.isReady_confuse ? "已就绪" : "文件不完整"
            detailText_confuse = inspection_confuse.isReady_confuse
                ? "目标项目和合包代码已准备完成。"
                : "请补齐缺少的合包文件后再执行。"
            if backendConfiguration_confuse == nil {
                backendDetailText_confuse = "目标 Bundle ID：\(inspection_confuse.bundleID_confuse)"
            }
        } catch {
            missingFiles_confuse = []
            hasFacebook_confuse = false
            isTargetReady_confuse = false
            targetBundleID_confuse = ""
            invalidateBackendConfiguration_confuse()
            statusText_confuse = "项目无效"
            detailText_confuse = error.localizedDescription
        }
    }

    /// 从 PACKAGE 扫描结果中按固定顺序提取合包真正使用的五个文件。
    /// - Parameter paths_confuse: PACKAGE 目录下扫描得到的完整文件路径。
    /// - Returns: 固定顺序且去重后的必需文件路径。
    private func displayPackageFiles_confuse(paths_confuse: [String]) -> [String] {
        requiredPackageDisplayNames_confuse.compactMap { name_confuse in
            paths_confuse.first {
                URL(fileURLWithPath: $0).lastPathComponent.caseInsensitiveCompare(name_confuse) == .orderedSame
            }
        }
    }

    /// 清除与当前项目绑定的后台配置，并恢复等待获取状态。
    private func invalidateBackendConfiguration_confuse() {
        backendConfiguration_confuse = nil
        backendProgress_confuse = 0
        backendStatusText_confuse = "等待获取"
        backendDetailText_confuse = targetBundleID_confuse.isEmpty
            ? "选择有效目标项目后获取后台配置。"
            : "目标 Bundle ID：\(targetBundleID_confuse)"
    }

    /// 显示合包流程统一错误弹窗。
    /// - Parameter message_confuse: 需要展示的错误说明。
    private func showAlert_confuse(message_confuse: String) {
        alertMessage_confuse = message_confuse
        isShowingAlert_confuse = true
    }
}
