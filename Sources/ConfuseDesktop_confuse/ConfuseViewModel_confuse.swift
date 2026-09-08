import AppKit
import Foundation
import SwiftUI

/// 管理工程选择、配置检测、任务执行状态和界面提示。
@MainActor
final class ConfuseViewModel_confuse: ObservableObject {
    @Published var primaryMenu_confuse: PrimaryMenu_confuse = .obfuscation_confuse
    @Published var expandedPrimaryMenu_confuse: PrimaryMenu_confuse? = .obfuscation_confuse
    @Published var submissionMenu_confuse: SubmissionAutomationMenu_confuse = .codeMagic_confuse
    @Published var monitoringMenu_confuse: MonitoringAuditMenu_confuse = .status_confuse
    @Published var projectType_confuse: ProjectType_confuse = .swift_confuse
    @Published var operation_confuse: OperationMode_confuse = .obfuscate_confuse
    @Published var namingRule_confuse: NamingRule_confuse = .classic_confuse
    @Published var projectPath_confuse = ""
    @Published var suffix_confuse = ""
    @Published var detectedSuffixes_confuse: [String] = []
    @Published var status_confuse = "就绪"
    @Published var detail_confuse = "请选择项目文件夹，或将项目拖入下方区域。"
    @Published var isRunning_confuse = false
    @Published var isDropTargeted_confuse = false
    @Published var lastResult_confuse: EngineResult_confuse?

    /// 返回当前内容页的稳定标识，用于驱动页面切换动画。
    var contentSelectionID_confuse: String {
        switch primaryMenu_confuse {
        case .obfuscation_confuse:
            return "\(primaryMenu_confuse.rawValue)_\(operation_confuse.rawValue)"
        case .submission_confuse:
            return "\(primaryMenu_confuse.rawValue)_\(submissionMenu_confuse.rawValue)"
        case .monitoring_confuse:
            return "\(primaryMenu_confuse.rawValue)_\(monitoringMenu_confuse.rawValue)"
        case .initialize_confuse, .settings_confuse:
            return primaryMenu_confuse.rawValue
        }
    }

    /// 选择一级菜单，并按单开模式切换其二级菜单展开状态。
    /// - Parameter menu_confuse: 用户点击的一级菜单。
    func selectPrimaryMenu_confuse(menu_confuse: PrimaryMenu_confuse) {
        guard menu_confuse.hasSubmenu_confuse else {
            primaryMenu_confuse = menu_confuse
            expandedPrimaryMenu_confuse = nil
            return
        }

        if primaryMenu_confuse == menu_confuse {
            expandedPrimaryMenu_confuse = expandedPrimaryMenu_confuse == menu_confuse ? nil : menu_confuse
        } else {
            primaryMenu_confuse = menu_confuse
            expandedPrimaryMenu_confuse = menu_confuse
        }
    }

    /// 判断指定一级菜单当前是否展开。
    /// - Parameter menu_confuse: 待检查的一级菜单。
    /// - Returns: 菜单已展开时返回 true。
    func isPrimaryMenuExpanded_confuse(menu_confuse: PrimaryMenu_confuse) -> Bool {
        expandedPrimaryMenu_confuse == menu_confuse
    }

    /// 切换混淆程序的二级模式。
    /// - Parameter mode_confuse: 用户选择的混淆模式。
    func selectOperationMode_confuse(mode_confuse: OperationMode_confuse) {
        operation_confuse = mode_confuse
    }

    /// 切换提交自动化的二级菜单。
    /// - Parameter menu_confuse: 用户选择的提交自动化菜单。
    func selectSubmissionMenu_confuse(menu_confuse: SubmissionAutomationMenu_confuse) {
        submissionMenu_confuse = menu_confuse
    }

    /// 切换监控审核的二级菜单。
    /// - Parameter menu_confuse: 用户选择的监控审核菜单。
    func selectMonitoringMenu_confuse(menu_confuse: MonitoringAuditMenu_confuse) {
        monitoringMenu_confuse = menu_confuse
    }

    /// 打开工程目录选择器并刷新项目配置。
    func chooseProject_confuse() {
        let panel_confuse = NSOpenPanel()
        panel_confuse.canChooseDirectories = true
        panel_confuse.canChooseFiles = false
        panel_confuse.allowsMultipleSelection = false
        panel_confuse.prompt = "选择"
        if panel_confuse.runModal() == .OK, let url_confuse = panel_confuse.url {
            acceptProject_confuse(url_confuse: url_confuse)
        }
    }

    /// 接收拖拽或外部传入的工程目录。
    /// - Parameter url_confuse: 工程目录 URL。
    func acceptProject_confuse(url_confuse: URL) {
        var isDirectory_confuse: ObjCBool = false
        guard FileManager.default.fileExists(atPath: url_confuse.path, isDirectory: &isDirectory_confuse),
              isDirectory_confuse.boolValue else {
            status_confuse = "项目无效"
            detail_confuse = "请拖入项目文件夹。"
            return
        }
        projectPath_confuse = url_confuse.path
        detectConfiguration_confuse()
    }

    /// 根据所选工程重新检测类别、项目名称和可用后缀。
    func detectConfiguration_confuse() {
        guard !projectPath_confuse.isEmpty else { return }
        let projectURL_confuse = URL(fileURLWithPath: projectPath_confuse)
        guard let detectedType_confuse = ProjectScanner_confuse.detectType_confuse(projectURL_confuse: projectURL_confuse) else {
            status_confuse = "项目类型不支持"
            detail_confuse = "无法将该文件夹识别为 Swift 或 Flutter 项目。"
            return
        }
        projectType_confuse = detectedType_confuse
        let configuration_confuse = ProjectScanner_confuse.configuration_confuse(
            projectURL_confuse: projectURL_confuse,
            projectType_confuse: detectedType_confuse
        )
        detectedSuffixes_confuse = configuration_confuse.suffixes_confuse
        suffix_confuse = configuration_confuse.suffixes_confuse.first ?? ""
        status_confuse = "已识别项目"
        detail_confuse = "\(detectedType_confuse.displayName_confuse) 项目：\(configuration_confuse.name_confuse)"
    }

    /// 执行当前配置对应的任务，并将耗时引擎放入后台任务。
    func runOperation_confuse() {
        guard !projectPath_confuse.isEmpty else {
            status_confuse = "需要项目"
            detail_confuse = "请先选择项目再执行操作。"
            return
        }
        let suffixes_confuse = normalizedSuffixes_confuse()
        guard !suffixes_confuse.isEmpty else {
            status_confuse = "需要项目后缀"
            detail_confuse = "请至少输入一个源代码后缀。"
            return
        }

        let request_confuse = EngineRequest_confuse(
            projectPath_confuse: projectPath_confuse,
            projectType_confuse: projectType_confuse.rawValue,
            suffixes_confuse: suffixes_confuse,
            operation_confuse: operation_confuse.rawValue,
            namingRule_confuse: namingRule_confuse.rawValue,
            mappingDirectory_confuse: EngineService_confuse.mappingDirectoryURL_confuse().path
        )
        isRunning_confuse = true
        status_confuse = operation_confuse.displayName_confuse
        detail_confuse = "正在处理项目，请稍候。"
        lastResult_confuse = nil

        Task { [weak self] in
            let result_confuse: Result<EngineResult_confuse, Error> = await Task.detached {
                do {
                    return .success(try EngineService_confuse.run_confuse(request_confuse: request_confuse))
                } catch {
                    return .failure(error)
                }
            }.value

            guard let self_confuse = self else { return }
            self_confuse.isRunning_confuse = false
            switch result_confuse {
            case .success(let engineResult_confuse) where engineResult_confuse.ok_confuse:
                self_confuse.lastResult_confuse = engineResult_confuse
                self_confuse.status_confuse = "已完成"
                self_confuse.detail_confuse = engineResult_confuse.message_confuse ?? "操作已完成。"
            case .success(let engineResult_confuse):
                self_confuse.status_confuse = "失败"
                self_confuse.detail_confuse = engineResult_confuse.error_confuse ?? "操作失败。"
                if engineResult_confuse.errorCode_confuse == "mapping_missing" {
                    self_confuse.showMappingMissingAlert_confuse()
                }
            case .failure(let error_confuse):
                self_confuse.status_confuse = "失败"
                self_confuse.detail_confuse = error_confuse.localizedDescription
            }
        }
    }

    /// 返回清洗后的后缀数组，兼容用户输入带下划线或逗号分隔的形式。
    /// - Returns: 可传给引擎的后缀数组。
    private func normalizedSuffixes_confuse() -> [String] {
        let values_confuse = suffix_confuse
            .split(whereSeparator: { $0 == "," || $0 == "\n" || $0 == " " })
            .map(String.init)
            .filter { !$0.isEmpty }
        return values_confuse.map { $0.hasPrefix("_") ? $0 : "_\($0)" }
    }

    /// 根据项目后缀和项目类型生成映射 JSON 文件名。
    /// - Returns: 形如 `项目后缀_swift.json` 的文件名。
    private func mappingFileName_confuse() -> String {
        let firstSuffix_confuse = suffix_confuse
            .split(whereSeparator: { $0 == "," || $0 == "\n" || $0 == " " })
            .first
            .map(String.init) ?? "project"
        let cleanSuffix_confuse = firstSuffix_confuse
            .trimmingCharacters(in: CharacterSet(charactersIn: "_"))
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "\\", with: "_")
        let safeSuffix_confuse = cleanSuffix_confuse.isEmpty ? "project" : cleanSuffix_confuse
        return "\(safeSuffix_confuse)_\(projectType_confuse.rawValue).json"
    }

    /// 返回当前项目映射文件的预期路径，供界面展示自动查找位置。
    /// - Returns: JSON 文件夹中的预期路径文本。
    var mappingDisplayPath_confuse: String {
        return EngineService_confuse.mappingDirectoryURL_confuse()
            .appendingPathComponent(mappingFileName_confuse())
            .path
    }

    /// 弹出映射文件缺失提示，告诉用户自动查找过的目录。
    func showMappingMissingAlert_confuse() {
        let alert_confuse = NSAlert()
        alert_confuse.alertStyle = .warning
        alert_confuse.messageText = "未找到映射文件"
        alert_confuse.informativeText = "应用同级的映射目录中没有找到 \(mappingFileName_confuse())。请先使用相同项目后缀完成混淆。"
        alert_confuse.addButton(withTitle: "确定")
        alert_confuse.runModal()
    }
}
