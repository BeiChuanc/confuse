import AppKit
import Foundation

/// 管理 UI 编号、飞书资料读取、协议生成和 Profile 保存的生命周期。
///
/// 资料读取完成后只填充协议参数并等待用户确认；协议也可以在没有整理资料时
/// 直接使用手动输入的应用名和邮箱生成，避免两个流程互相阻塞。
@MainActor
final class MaterialAutomationViewModel_confuse: ObservableObject {
    @Published var uiNumber_confuse = ""
    @Published var appName_confuse = ""
    @Published var email_confuse = ""
    @Published var isRunning_confuse = false
    @Published var statusText_confuse = "等待整理"
    @Published var detailText_confuse = "输入 UI 编号后，从飞书项目表读取对应资料。"
    @Published var progress_confuse = 0.0
    @Published var record_confuse: MaterialRecord_confuse?
    @Published var agreementStates_confuse: [AgreementType_confuse: AgreementGenerationState_confuse] = [:]
    @Published var agreementMessages_confuse: [AgreementType_confuse: String] = [:]
    @Published var agreementLinks_confuse: [AgreementType_confuse: String] = [:]
    @Published var profileStatusText_confuse = "等待生成"
    @Published var profilePathText_confuse = ""
    @Published var isExtensionPrepared_confuse = false
    @Published var extensionStatusText_confuse = "尚未准备 Chrome 扩展"
    @Published var isShowingAlert_confuse = false
    @Published var alertMessage_confuse = ""
    @Published var isShowingAgreementConfirmation_confuse = false

    private let service_confuse = MaterialAutomationService_confuse()
    private let agreementService_confuse = AgreementAutomationService_confuse()
    private let feishuURL_confuse = URL(
        string: "https://xx1ch0v03wd.feishu.cn/wiki/U197wBclBiHpzVkTISEc9jb0nHb?table=tblxo7NzaOIzo7yz&view=vewMnpNgGD"
    )!

    /// 初始化整理资料状态，并检查扩展资源是否已经准备。
    init() {
        for type_confuse in AgreementType_confuse.allCases {
            agreementStates_confuse[type_confuse] = .pending_confuse
            agreementMessages_confuse[type_confuse] = "尚未生成"
        }
        isExtensionPrepared_confuse = service_confuse.isExtensionPrepared_confuse()
        extensionStatusText_confuse = isExtensionPrepared_confuse
            ? "扩展文件已准备，请确认 Chrome 中已启用"
            : "尚未准备 Chrome 扩展"
    }

    /// 返回当前输入是否允许开始读取资料。
    var canStart_confuse: Bool {
        !isRunning_confuse && isExtensionPrepared_confuse && !cleanUINumber_confuse.isEmpty
    }

    /// 返回当前是否可以使用当前协议参数开始生成。
    var canGenerateAgreement_confuse: Bool {
        !isRunning_confuse
            && isExtensionPrepared_confuse
            && !cleanAppName_confuse.isEmpty
            && isEmailValid_confuse
    }

    /// 准备扩展和原生消息宿主，并打开 Chrome 扩展管理页及访达目录。
    func prepareExtension_confuse() {
        do {
            _ = try service_confuse.prepareExtension_confuse()
            isExtensionPrepared_confuse = true
            extensionStatusText_confuse = "扩展文件已准备，请在 Chrome 中加载或重新加载"
            detailText_confuse = "在扩展管理页开启开发者模式，选择“加载已解压的扩展程序”。"
            try service_confuse.showExtensionDirectory_confuse()
            try service_confuse.openChromeExtensionManager_confuse()
        } catch {
            showAlert_confuse(message_confuse: error.localizedDescription)
        }
    }

    /// 在访达中重新显示扩展目录，供 Chrome 选择或检查文件。
    func showExtensionDirectory_confuse() {
        do {
            try service_confuse.showExtensionDirectory_confuse()
        } catch {
            showAlert_confuse(message_confuse: error.localizedDescription)
        }
    }

    /// 打开当前 Chrome 的扩展管理页面。
    func openChromeExtensionManager_confuse() {
        do {
            try service_confuse.openChromeExtensionManager_confuse()
        } catch {
            showAlert_confuse(message_confuse: error.localizedDescription)
        }
    }

    /// 校验 UI 编号并启动后台飞书自动化任务。
    func start_confuse() {
        guard !cleanUINumber_confuse.isEmpty else {
            showAlert_confuse(message_confuse: "请输入项目的 UI 编号。")
            return
        }
        guard isExtensionPrepared_confuse else {
            showAlert_confuse(message_confuse: "请先准备并在 Chrome 中启用 App Tools 浏览器助手。")
            return
        }
        guard !isRunning_confuse else { return }

        let request_confuse = MaterialAutomationRequest_confuse(uiNumber_confuse: cleanUINumber_confuse)
        isRunning_confuse = true
        statusText_confuse = "正在整理"
        detailText_confuse = "正在等待当前 Chrome 中的 App Tools 浏览器助手。"
        progress_confuse = 0.05
        record_confuse = nil
        appName_confuse = ""
        email_confuse = ""
        profileStatusText_confuse = "等待生成"
        profilePathText_confuse = ""
        resetAgreementState_confuse()
        let service_confuse = service_confuse
        Task { [weak self] in
            let result_confuse: Result<MaterialRecord_confuse, Error> = await Task.detached(
                priority: .userInitiated
            ) {
                do {
                    let record_confuse = try service_confuse.run_confuse(request_confuse: request_confuse) {
                        event_confuse in
                        Task { @MainActor [weak self] in
                            self?.applyMaterialEvent_confuse(event_confuse: event_confuse)
                        }
                    }
                    return .success(record_confuse)
                } catch {
                    return .failure(error)
                }
            }.value

            guard let self_confuse = self else { return }
            self_confuse.isRunning_confuse = false
            switch result_confuse {
            case .success(let record_confuse):
                self_confuse.applyFetchedRecord_confuse(record_confuse: record_confuse)
            case .failure(let error_confuse):
                self_confuse.statusText_confuse = "整理失败"
                self_confuse.detailText_confuse = error_confuse.localizedDescription
                if !self_confuse.isCancellationError_confuse(error_confuse: error_confuse) {
                    self_confuse.showAlert_confuse(message_confuse: error_confuse.localizedDescription)
                }
            }
        }
    }

    /// 请求停止当前飞书读取任务，不关闭 Chrome 或用户标签页。
    func cancel_confuse() {
        guard isRunning_confuse else { return }
        statusText_confuse = "正在停止"
        detailText_confuse = "正在结束资料整理任务。"
        service_confuse.cancel_confuse()
        agreementService_confuse.cancel_confuse()
    }

    /// 使用默认浏览器打开飞书项目管理页面，供用户查看原始记录。
    func openFeishu_confuse() {
        NSWorkspace.shared.open(feishuURL_confuse)
    }

    /// 将指定资料字段复制到系统剪贴板，并更新状态说明。
    /// - Parameter field_confuse: 需要复制的资料字段。
    func copy_confuse(field_confuse: MaterialField_confuse) {
        guard let value_confuse = record_confuse?.value_confuse(field_confuse: field_confuse),
              !value_confuse.isEmpty else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(value_confuse, forType: .string)
        statusText_confuse = "内容已复制"
        detailText_confuse = "\(field_confuse.displayName_confuse)已复制到剪贴板。"
    }

    /// 应用资料脚本发出的状态说明和进度数值，并映射到完整流程的前 65%。
    /// - Parameter event_confuse: Python 脚本输出的结构化进度事件。
    private func applyMaterialEvent_confuse(event_confuse: MaterialAutomationEvent_confuse) {
        if let message_confuse = event_confuse.message_confuse {
            detailText_confuse = message_confuse
        }
        if let progress_confuse = event_confuse.progress_confuse {
            self.progress_confuse = max(0, min(progress_confuse, 1)) * 0.65
        }
        if event_confuse.state_confuse == "waiting_extension" {
            statusText_confuse = "等待扩展连接"
        } else if event_confuse.state_confuse == "running" {
            statusText_confuse = "正在整理"
        }
    }

    /// 在资料读取成功后展示记录、填充协议参数，并等待用户确认生成。
    /// - Parameter record_confuse: 刚从飞书读取的项目记录。
    private func applyFetchedRecord_confuse(record_confuse: MaterialRecord_confuse) {
        self.record_confuse = record_confuse
        appName_confuse = record_confuse.softwareName_confuse.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        email_confuse = Self.extractEmail_confuse(
            value_confuse: record_confuse.developerAccount_confuse
        ) ?? ""
        progress_confuse = max(progress_confuse, 0.65)
        statusText_confuse = "资料整理完成"
        detailText_confuse = "资料已获取，请确认后生成协议并保存 Profile。"
        for type_confuse in AgreementType_confuse.allCases {
            agreementMessages_confuse[type_confuse] = "等待确认"
        }
    }

    /// 应用协议脚本发出的阶段状态、链接和后 35% 进度。
    /// - Parameter event_confuse: 协议脚本输出的结构化事件。
    private func applyAgreementEvent_confuse(event_confuse: AgreementAutomationEvent_confuse) {
        if let progress_confuse = event_confuse.progress_confuse {
            let progressBase_confuse = record_confuse == nil ? 0.0 : 0.65
            let progressScale_confuse = record_confuse == nil ? 1.0 : 0.35
            self.progress_confuse = progressBase_confuse
                + max(0, min(progress_confuse, 1)) * progressScale_confuse
        }
        guard let rawType_confuse = event_confuse.agreementType_confuse,
              let type_confuse = AgreementType_confuse(rawValue: rawType_confuse) else {
            if event_confuse.state_confuse == "waiting_extension" {
                statusText_confuse = "等待浏览器助手"
            } else if event_confuse.state_confuse == "running" {
                statusText_confuse = "正在处理协议"
            }
            if let message_confuse = event_confuse.message_confuse {
                detailText_confuse = message_confuse
            }
            return
        }
        if event_confuse.state_confuse == "running" {
            agreementStates_confuse[type_confuse] = .running_confuse
        } else if event_confuse.state_confuse == "completed" {
            agreementStates_confuse[type_confuse] = .completed_confuse
        } else if event_confuse.state_confuse == "failed" {
            agreementStates_confuse[type_confuse] = .failed_confuse
        }
        if let message_confuse = event_confuse.message_confuse {
            agreementMessages_confuse[type_confuse] = message_confuse
            detailText_confuse = message_confuse
        }
        if let link_confuse = event_confuse.link_confuse {
            agreementLinks_confuse[type_confuse] = link_confuse
        }
        if event_confuse.progress_confuse == nil && event_confuse.state_confuse == "running" {
            self.progress_confuse = max(self.progress_confuse, 0.68)
        }
        statusText_confuse = "正在处理协议"
    }

    /// 将协议链接复制到系统剪贴板，并更新整理页面状态。
    /// - Parameter type_confuse: 需要复制的协议类型。
    func copyAgreementLink_confuse(type_confuse: AgreementType_confuse) {
        guard let link_confuse = agreementLinks_confuse[type_confuse] else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(link_confuse, forType: .string)
        statusText_confuse = "链接已复制"
        detailText_confuse = "\(type_confuse.displayName_confuse)链接已复制到剪贴板。"
    }

    /// 使用默认浏览器打开指定协议链接。
    /// - Parameter type_confuse: 需要打开的协议类型。
    func openAgreementLink_confuse(type_confuse: AgreementType_confuse) {
        guard let link_confuse = agreementLinks_confuse[type_confuse],
              let url_confuse = URL(string: link_confuse) else { return }
        NSWorkspace.shared.open(url_confuse)
    }

    /// 单独生成指定协议；有整理资料时同步更新 Profile，没有资料时只生成协议。
    /// - Parameter type_confuse: 需要重新生成的协议类型。
    func generateAgreement_confuse(type_confuse: AgreementType_confuse) {
        startAgreementGeneration_confuse(
            types_confuse: [type_confuse],
            shouldSaveProfile_confuse: record_confuse != nil
        )
    }

    /// 请求按固定顺序生成全部协议；有整理资料时先要求用户确认并保存 Profile。
    func generateAllAgreements_confuse() {
        guard record_confuse != nil else {
            startAgreementGeneration_confuse(
                types_confuse: AgreementType_confuse.allCases,
                shouldSaveProfile_confuse: false
            )
            return
        }
        guard canGenerateAgreement_confuse else {
            validateAgreementInput_confuse()
            return
        }
        isShowingAgreementConfirmation_confuse = true
    }

    /// 在用户确认后生成全部协议并写入当前项目的 Profile。
    func confirmGenerateAllAgreements_confuse() {
        isShowingAgreementConfirmation_confuse = false
        startAgreementGeneration_confuse(
            types_confuse: AgreementType_confuse.allCases,
            shouldSaveProfile_confuse: true
        )
    }

    /// 初始化本次整理任务的协议状态，确保旧链接不会混入新项目。
    private func resetAgreementState_confuse() {
        for type_confuse in AgreementType_confuse.allCases {
            agreementStates_confuse[type_confuse] = .pending_confuse
            agreementMessages_confuse[type_confuse] = "尚未生成"
            agreementLinks_confuse.removeValue(forKey: type_confuse)
        }
    }

    /// 使用资料参数或手动参数启动单项或全部协议生成。
    /// - Parameters:
    ///   - types_confuse: 本次需要生成的协议类型。
    ///   - shouldSaveProfile_confuse: 成功后是否使用整理资料写入 Profile。
    private func startAgreementGeneration_confuse(
        types_confuse: [AgreementType_confuse],
        shouldSaveProfile_confuse: Bool
    ) {
        guard !isRunning_confuse else { return }
        guard isExtensionPrepared_confuse else {
            showAlert_confuse(message_confuse: "请先准备并在 Chrome 中启用 App Tools 浏览器助手。")
            return
        }
        guard !cleanAppName_confuse.isEmpty else {
            showAlert_confuse(message_confuse: "请输入应用名称。")
            return
        }
        guard isEmailValid_confuse else {
            showAlert_confuse(message_confuse: "请输入有效的邮箱地址。")
            return
        }

        let request_confuse = AgreementAutomationRequest_confuse(
            appName_confuse: cleanAppName_confuse,
            email_confuse: cleanEmail_confuse,
            agreementTypes_confuse: types_confuse.map(\.rawValue)
        )
        for type_confuse in types_confuse {
            agreementStates_confuse[type_confuse] = .pending_confuse
            agreementMessages_confuse[type_confuse] = "等待 Chrome 处理"
            agreementLinks_confuse.removeValue(forKey: type_confuse)
        }
        isRunning_confuse = true
        statusText_confuse = "正在处理协议"
        detailText_confuse = "正在等待当前 Chrome 中的 App Tools 浏览器助手。"
        progress_confuse = record_confuse == nil ? 0 : max(progress_confuse, 0.65)
        let agreementService_confuse = agreementService_confuse

        Task { [weak self] in
            let result_confuse: Result<[AgreementType_confuse: String], Error> = await Task.detached(
                priority: .userInitiated
            ) {
                do {
                    let links_confuse = try agreementService_confuse.run_confuse(
                        request_confuse: request_confuse
                    ) { event_confuse in
                        Task { @MainActor [weak self] in
                            self?.applyAgreementEvent_confuse(event_confuse: event_confuse)
                        }
                    }
                    return .success(links_confuse)
                } catch {
                    return .failure(error)
                }
            }.value

            guard let self_confuse = self else { return }
            self_confuse.isRunning_confuse = false
            switch result_confuse {
            case .success(let links_confuse):
                for (type_confuse, link_confuse) in links_confuse {
                    self_confuse.agreementLinks_confuse[type_confuse] = link_confuse
                    self_confuse.agreementStates_confuse[type_confuse] = .completed_confuse
                    self_confuse.agreementMessages_confuse[type_confuse] = "链接已生成"
                }
                self_confuse.progress_confuse = 1
                self_confuse.statusText_confuse = "协议处理完成"
                self_confuse.detailText_confuse = "协议链接已更新，可以复制或打开。"
                if shouldSaveProfile_confuse, let record_confuse = self_confuse.record_confuse {
                    self_confuse.saveProfile_confuse(
                        record_confuse: record_confuse,
                        agreementLinks_confuse: self_confuse.agreementLinks_confuse
                    )
                }
            case .failure(let error_confuse):
                for type_confuse in types_confuse {
                    self_confuse.agreementStates_confuse[type_confuse] = .failed_confuse
                    self_confuse.agreementMessages_confuse[type_confuse] = "生成失败"
                }
                self_confuse.statusText_confuse = "协议处理失败"
                self_confuse.detailText_confuse = error_confuse.localizedDescription
                if !self_confuse.isCancellationError_confuse(error_confuse: error_confuse) {
                    self_confuse.showAlert_confuse(message_confuse: error_confuse.localizedDescription)
                }
            }
        }
    }

    /// 将资料和当前协议结果写入应用同级 PROFILE 目录。
    /// - Parameters:
    ///   - record_confuse: 已读取的项目资料。
    ///   - agreementLinks_confuse: 已成功生成的协议链接。
    private func saveProfile_confuse(
        record_confuse: MaterialRecord_confuse,
        agreementLinks_confuse: [AgreementType_confuse: String]
    ) {
        do {
            let profileURL_confuse = try ProfileFileService_confuse.writeProfile_confuse(
                record_confuse: record_confuse,
                agreementLinks_confuse: agreementLinks_confuse
            )
            profileStatusText_confuse = "Profile 已保存"
            profilePathText_confuse = profileURL_confuse.path
        } catch {
            profileStatusText_confuse = "Profile 保存失败"
            profilePathText_confuse = ""
            showAlert_confuse(message_confuse: "Profile 文件保存失败：\(error.localizedDescription)")
        }
    }

    /// 从开发者账号字段中提取第一个邮箱地址。
    /// - Parameter value_confuse: 飞书返回的开发者账号原始文本。
    /// - Returns: 提取成功时返回邮箱，否则返回 nil。
    nonisolated private static func extractEmail_confuse(value_confuse: String) -> String? {
        let pattern_confuse = "[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}"
        guard let range_confuse = value_confuse.range(
            of: pattern_confuse,
            options: [.regularExpression, .caseInsensitive]
        ) else {
            return nil
        }
        return String(value_confuse[range_confuse])
    }

    /// 判断错误是否由用户主动停止任务产生。
    /// - Parameter error_confuse: 后台任务返回的错误。
    /// - Returns: 用户主动停止时返回 true。
    private func isCancellationError_confuse(error_confuse: Error) -> Bool {
        if let materialError_confuse = error_confuse as? MaterialAutomationError_confuse,
           case .cancelled_confuse = materialError_confuse {
            return true
        }
        if let agreementError_confuse = error_confuse as? AgreementAutomationError_confuse,
           case .cancelled_confuse = agreementError_confuse {
            return true
        }
        return false
    }

    /// 显示资料整理统一错误弹窗。
    /// - Parameter message_confuse: 需要展示的错误说明。
    private func showAlert_confuse(message_confuse: String) {
        alertMessage_confuse = message_confuse
        isShowingAlert_confuse = true
    }

    /// 返回去除首尾空白后的项目 UI 编号。
    private var cleanUINumber_confuse: String {
        uiNumber_confuse.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// 返回去除首尾空白后的协议应用名称。
    private var cleanAppName_confuse: String {
        appName_confuse.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// 返回去除首尾空白后的协议邮箱。
    private var cleanEmail_confuse: String {
        email_confuse.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// 返回当前协议邮箱是否符合基本邮箱格式。
    private var isEmailValid_confuse: Bool {
        cleanEmail_confuse.range(
            of: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$",
            options: [.regularExpression, .caseInsensitive]
        ) != nil
    }

    /// 根据当前输入内容显示协议生成所需的校验提示。
    private func validateAgreementInput_confuse() {
        guard isExtensionPrepared_confuse else {
            showAlert_confuse(message_confuse: "请先准备并在 Chrome 中启用 App Tools 浏览器助手。")
            return
        }
        guard !cleanAppName_confuse.isEmpty else {
            showAlert_confuse(message_confuse: "请输入应用名称。")
            return
        }
        guard isEmailValid_confuse else {
            showAlert_confuse(message_confuse: "请输入有效的邮箱地址。")
            return
        }
    }
}
