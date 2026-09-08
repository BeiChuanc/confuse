import AppKit
import Foundation
import UniformTypeIdentifiers

/// 管理审核监控配置、应用凭证、定时巡检、历史记录和界面弹窗状态。
@MainActor
final class MonitoringViewModel_confuse: ObservableObject {
    @Published var configuration_confuse = MonitoringConfiguration_confuse.default_confuse
    @Published var records_confuse: [MonitoringRecord_confuse] = []
    @Published var editor_confuse = MonitoringApplicationEditor_confuse()
    @Published var settingsDraft_confuse = MonitoringConfiguration_confuse.default_confuse
    @Published var searchText_confuse = ""
    @Published var recordSearchText_confuse = ""
    @Published var selectedCategory_confuse: MonitoringStatusCategory_confuse = .all_confuse
    @Published var isMonitoring_confuse = false
    @Published var isChecking_confuse = false
    @Published var statusText_confuse = "监控已停止"
    @Published var isShowingEditor_confuse = false
    @Published var isShowingSettings_confuse = false
    @Published var isShowingAlert_confuse = false
    @Published var alertTitle_confuse = "监控审核"
    @Published var alertMessage_confuse = ""

    private var editingAppID_confuse: String?
    private var monitoringTask_confuse: Task<Void, Never>?
    private var nextDueDates_confuse: [String: Date] = [:]
    private var storage_confuse: MonitoringStorage_confuse?

    /// 读取应用同级监控数据，并恢复上次的自动监控状态。
    init() {
        do {
            let storage_confuse = try MonitoringStorage_confuse()
            self.storage_confuse = storage_confuse
            configuration_confuse = try storage_confuse.loadConfiguration_confuse()
            settingsDraft_confuse = configuration_confuse
            records_confuse = try storage_confuse.loadRecords_confuse()
            if configuration_confuse.isMonitoringEnabled_confuse && !configuration_confuse.applications_confuse.isEmpty {
                Task { [weak self] in
                    self?.startMonitoring_confuse()
                }
            }
        } catch {
            storage_confuse = nil
            alertTitle_confuse = "存储错误"
            alertMessage_confuse = error.localizedDescription
            isShowingAlert_confuse = true
            statusText_confuse = "监控数据目录不可用"
        }
    }

    /// 返回符合当前搜索文本和状态分类的应用列表。
    var filteredApplications_confuse: [MonitoringApplication_confuse] {
        configuration_confuse.applications_confuse
            .filter { application_confuse in
                let matchesSearch_confuse = searchText_confuse.isEmpty
                    || application_confuse.name_confuse.localizedCaseInsensitiveContains(searchText_confuse)
                    || application_confuse.appID_confuse.localizedCaseInsensitiveContains(searchText_confuse)
                let matchesCategory_confuse = selectedCategory_confuse == .all_confuse
                    || application_confuse.category_confuse == selectedCategory_confuse
                return matchesSearch_confuse && matchesCategory_confuse
            }
            .sorted { first_confuse, second_confuse in
                if first_confuse.stateChangedAt_confuse == second_confuse.stateChangedAt_confuse {
                    return first_confuse.name_confuse < second_confuse.name_confuse
                }
                return first_confuse.stateChangedAt_confuse > second_confuse.stateChangedAt_confuse
            }
    }

    /// 返回符合记录搜索文本的历史记录，并按时间倒序排列。
    var filteredRecords_confuse: [MonitoringRecord_confuse] {
        records_confuse
            .filter { record_confuse in
                recordSearchText_confuse.isEmpty
                    || record_confuse.applicationName_confuse.localizedCaseInsensitiveContains(recordSearchText_confuse)
                    || record_confuse.appID_confuse.localizedCaseInsensitiveContains(recordSearchText_confuse)
                    || record_confuse.event_confuse.localizedCaseInsensitiveContains(recordSearchText_confuse)
            }
            .sorted { $0.timestamp_confuse > $1.timestamp_confuse }
    }

    /// 返回全部监控应用数量。
    var totalCount_confuse: Int { configuration_confuse.applications_confuse.count }

    /// 返回审核流程中的应用数量。
    var pipelineCount_confuse: Int {
        configuration_confuse.applications_confuse.filter { $0.category_confuse == .pipeline_confuse }.count
    }

    /// 返回已通过或可发布的应用数量。
    var approvedCount_confuse: Int {
        configuration_confuse.applications_confuse.filter { $0.category_confuse == .approved_confuse }.count
    }

    /// 返回被拒绝或无效的应用数量。
    var rejectedCount_confuse: Int {
        configuration_confuse.applications_confuse.filter { $0.category_confuse == .rejected_confuse }.count
    }

    /// 打开空白的添加应用表单。
    func presentAddApplication_confuse() {
        editingAppID_confuse = nil
        editor_confuse = MonitoringApplicationEditor_confuse()
        isShowingEditor_confuse = true
    }

    /// 打开指定应用的编辑表单。
    /// - Parameter application_confuse: 待编辑应用。
    func presentEditApplication_confuse(application_confuse: MonitoringApplication_confuse) {
        editingAppID_confuse = application_confuse.appID_confuse
        editor_confuse = MonitoringApplicationEditor_confuse(
            appID_confuse: application_confuse.appID_confuse,
            issuerID_confuse: application_confuse.issuerID_confuse,
            keyID_confuse: application_confuse.keyID_confuse,
            privateKeyPath_confuse: application_confuse.privateKeyPath_confuse,
            isEnabled_confuse: application_confuse.isEnabled_confuse,
            importedProfileName_confuse: ""
        )
        isShowingEditor_confuse = true
    }

    /// 打开 `.p8` 私钥选择器并写入编辑表单。
    func choosePrivateKey_confuse() {
        let panel_confuse = NSOpenPanel()
        panel_confuse.canChooseDirectories = false
        panel_confuse.canChooseFiles = true
        panel_confuse.allowsMultipleSelection = false
        panel_confuse.allowedContentTypes = [UTType(filenameExtension: "p8") ?? .data]
        panel_confuse.prompt = "选择"
        panel_confuse.message = "请选择 App Store Connect 的 .p8 私钥。"
        if panel_confuse.runModal() == .OK, let url_confuse = panel_confuse.url {
            editor_confuse.privateKeyPath_confuse = url_confuse.path
        }
    }

    /// 选择资料文件夹并自动读取白名单凭证字段。
    func chooseProfileFolder_confuse() {
        let panel_confuse = NSOpenPanel()
        panel_confuse.canChooseDirectories = true
        panel_confuse.canChooseFiles = false
        panel_confuse.allowsMultipleSelection = false
        panel_confuse.prompt = "读取文件夹"
        panel_confuse.message = "请选择同时包含资料文件和 .p8 私钥的文件夹。"
        guard panel_confuse.runModal() == .OK, let url_confuse = panel_confuse.url else { return }
        importProfileFolder_confuse(folderURL_confuse: url_confuse)
    }

    /// 从拖入或选择的资料文件夹更新编辑表单。
    /// - Parameter folderURL_confuse: 包含 profile 与私钥的文件夹。
    func importProfileFolder_confuse(folderURL_confuse: URL) {
        do {
            let result_confuse = try MonitoringProfileService_confuse.readFolder_confuse(folderURL_confuse: folderURL_confuse)
            editor_confuse.appID_confuse = result_confuse.appID_confuse
            editor_confuse.issuerID_confuse = result_confuse.issuerID_confuse
            editor_confuse.keyID_confuse = result_confuse.keyID_confuse
            editor_confuse.privateKeyPath_confuse = result_confuse.privateKeyPath_confuse
            editor_confuse.importedProfileName_confuse = URL(fileURLWithPath: result_confuse.profilePath_confuse).lastPathComponent
        } catch {
            showAlert_confuse(title_confuse: "资料读取失败", message_confuse: error.localizedDescription)
        }
    }

    /// 校验并保存当前添加或编辑的应用。
    func saveApplication_confuse() {
        let cleanAppID_confuse = editor_confuse.appID_confuse.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanIssuerID_confuse = editor_confuse.issuerID_confuse.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanKeyID_confuse = editor_confuse.keyID_confuse.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanKeyPath_confuse = editor_confuse.privateKeyPath_confuse.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanAppID_confuse.isEmpty, cleanAppID_confuse.allSatisfy(\.isNumber) else {
            showAlert_confuse(title_confuse: "应用编号无效", message_confuse: "应用编号必须全部为数字。")
            return
        }
        guard !cleanIssuerID_confuse.isEmpty, !cleanKeyID_confuse.isEmpty else {
            showAlert_confuse(title_confuse: "凭证不完整", message_confuse: "发行者编号和密钥编号不能为空。")
            return
        }
        guard FileManager.default.fileExists(atPath: cleanKeyPath_confuse), let storage_confuse else {
            showAlert_confuse(title_confuse: "缺少私钥", message_confuse: "请选择有效的私钥文件。")
            return
        }
        if configuration_confuse.applications_confuse.contains(where: {
            $0.appID_confuse == cleanAppID_confuse && $0.appID_confuse != editingAppID_confuse
        }) {
            showAlert_confuse(title_confuse: "应用已存在", message_confuse: "该应用编号已经添加。")
            return
        }
        do {
            let managedKeyURL_confuse = try storage_confuse.importPrivateKey_confuse(
                sourceURL_confuse: URL(fileURLWithPath: cleanKeyPath_confuse),
                appID_confuse: cleanAppID_confuse,
                keyID_confuse: cleanKeyID_confuse
            )
            var application_confuse = MonitoringApplication_confuse(
                appID_confuse: cleanAppID_confuse,
                issuerID_confuse: cleanIssuerID_confuse,
                keyID_confuse: cleanKeyID_confuse,
                privateKeyPath_confuse: managedKeyURL_confuse.path,
                isEnabled_confuse: editor_confuse.isEnabled_confuse
            )
            if let editingAppID_confuse,
               let index_confuse = configuration_confuse.applications_confuse.firstIndex(where: {
                   $0.appID_confuse == editingAppID_confuse
               }) {
                let current_confuse = configuration_confuse.applications_confuse[index_confuse]
                application_confuse.name_confuse = current_confuse.name_confuse
                application_confuse.preferredVersion_confuse = current_confuse.preferredVersion_confuse
                application_confuse.version_confuse = current_confuse.version_confuse
                application_confuse.state_confuse = current_confuse.state_confuse
                application_confuse.label_confuse = current_confuse.label_confuse
                application_confuse.checkedAt_confuse = current_confuse.checkedAt_confuse
                application_confuse.stateChangedAt_confuse = current_confuse.stateChangedAt_confuse
                application_confuse.error_confuse = current_confuse.error_confuse
                configuration_confuse.applications_confuse[index_confuse] = application_confuse
            } else {
                configuration_confuse.applications_confuse.append(application_confuse)
            }
            isShowingEditor_confuse = false
            nextDueDates_confuse.removeAll()
            saveConfiguration_confuse()
        } catch {
            showAlert_confuse(title_confuse: "私钥导入失败", message_confuse: error.localizedDescription)
        }
    }

    /// 请求确认后移除一个监控应用，受管私钥副本会保留。
    /// - Parameter application_confuse: 待移除应用。
    func removeApplication_confuse(application_confuse: MonitoringApplication_confuse) {
        let alert_confuse = NSAlert()
        alert_confuse.alertStyle = .warning
        alert_confuse.messageText = "移除应用"
        let name_confuse = application_confuse.name_confuse.isEmpty
            ? application_confuse.appID_confuse
            : application_confuse.name_confuse
        alert_confuse.informativeText = "确定停止监控 \(name_confuse) 吗？已复制的私钥文件会继续保留。"
        alert_confuse.addButton(withTitle: "移除")
        alert_confuse.addButton(withTitle: "取消")
        guard alert_confuse.runModal() == .alertFirstButtonReturn else { return }
        configuration_confuse.applications_confuse.removeAll { $0.appID_confuse == application_confuse.appID_confuse }
        nextDueDates_confuse.removeValue(forKey: application_confuse.appID_confuse)
        saveConfiguration_confuse()
        if configuration_confuse.applications_confuse.isEmpty {
            stopMonitoring_confuse()
        }
    }

    /// 更新一个应用是否参与定时监控。
    /// - Parameters:
    ///   - application_confuse: 待更新应用。
    ///   - isEnabled_confuse: 新的启用状态。
    func setApplicationEnabled_confuse(
        application_confuse: MonitoringApplication_confuse,
        isEnabled_confuse: Bool
    ) {
        guard let index_confuse = configuration_confuse.applications_confuse.firstIndex(where: {
            $0.appID_confuse == application_confuse.appID_confuse
        }) else { return }
        configuration_confuse.applications_confuse[index_confuse].isEnabled_confuse = isEnabled_confuse
        nextDueDates_confuse.removeValue(forKey: application_confuse.appID_confuse)
        saveConfiguration_confuse()
    }

    /// 打开监控设置表单并复制当前配置作为草稿。
    func presentSettings_confuse() {
        settingsDraft_confuse = configuration_confuse
        isShowingSettings_confuse = true
    }

    /// 校验并保存代理、通知和轮询间隔设置。
    func saveSettings_confuse() {
        if settingsDraft_confuse.isStrictProxy_confuse
            && settingsDraft_confuse.proxy_confuse.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            showAlert_confuse(title_confuse: "需要代理", message_confuse: "严格代理模式需要先配置代理地址。")
            return
        }
        settingsDraft_confuse.defaultInterval_confuse = max(30, settingsDraft_confuse.defaultInterval_confuse)
        settingsDraft_confuse.reviewInterval_confuse = max(30, settingsDraft_confuse.reviewInterval_confuse)
        settingsDraft_confuse.approvedInterval_confuse = max(30, settingsDraft_confuse.approvedInterval_confuse)
        settingsDraft_confuse.applications_confuse = configuration_confuse.applications_confuse
        settingsDraft_confuse.isMonitoringEnabled_confuse = configuration_confuse.isMonitoringEnabled_confuse
        configuration_confuse = settingsDraft_confuse
        nextDueDates_confuse.removeAll()
        isShowingSettings_confuse = false
        saveConfiguration_confuse()
        if isMonitoring_confuse {
            restartMonitoring_confuse()
        }
    }

    /// 切换定时监控运行状态。
    func toggleMonitoring_confuse() {
        isMonitoring_confuse ? stopMonitoring_confuse() : startMonitoring_confuse()
    }

    /// 启动定时审核监控。
    func startMonitoring_confuse() {
        guard !configuration_confuse.applications_confuse.isEmpty else {
            showAlert_confuse(title_confuse: "尚无应用", message_confuse: "请先添加需要监控的应用。")
            return
        }
        guard !(configuration_confuse.isStrictProxy_confuse
            && configuration_confuse.proxy_confuse.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) else {
            showAlert_confuse(title_confuse: "需要代理", message_confuse: "启用严格代理模式前请先配置代理地址。")
            return
        }
        monitoringTask_confuse?.cancel()
        configuration_confuse.isMonitoringEnabled_confuse = true
        isMonitoring_confuse = true
        statusText_confuse = "监控运行中"
        nextDueDates_confuse.removeAll()
        saveConfiguration_confuse()
        monitoringTask_confuse = Task { [weak self] in
            guard let self_confuse = self else { return }
            while !Task.isCancelled {
                await self_confuse.runCycle_confuse(force_confuse: false)
                do {
                    try await Task.sleep(nanoseconds: 30_000_000_000)
                } catch {
                    return
                }
            }
        }
    }

    /// 停止定时审核监控并保存开关状态。
    func stopMonitoring_confuse() {
        monitoringTask_confuse?.cancel()
        monitoringTask_confuse = nil
        isMonitoring_confuse = false
        configuration_confuse.isMonitoringEnabled_confuse = false
        statusText_confuse = "监控已停止"
        saveConfiguration_confuse()
    }

    /// 立即检查全部启用应用，已有检查运行时忽略重复请求。
    func checkNow_confuse() {
        guard !configuration_confuse.applications_confuse.isEmpty else {
            showAlert_confuse(title_confuse: "尚无应用", message_confuse: "请先添加应用再检查审核状态。")
            return
        }
        guard !isChecking_confuse else {
            statusText_confuse = "当前已有巡检任务正在执行"
            return
        }
        Task { [weak self] in
            await self?.runCycle_confuse(force_confuse: true)
        }
    }

    /// 立即检查一个指定应用。
    /// - Parameter application_confuse: 待查询应用。
    func checkApplication_confuse(application_confuse: MonitoringApplication_confuse) {
        guard !isChecking_confuse else {
            statusText_confuse = "当前已有巡检任务正在执行"
            return
        }
        Task { [weak self] in
            await self?.runApplications_confuse(appIDs_confuse: [application_confuse.appID_confuse])
        }
    }

    /// 使用 Finder 打开应用同级 AppMonitorData 目录。
    func openDataDirectory_confuse() {
        guard let storage_confuse else {
            showAlert_confuse(title_confuse: "存储错误", message_confuse: "监控数据目录不可用。")
            return
        }
        NSWorkspace.shared.open(storage_confuse.rootURL_confuse)
    }

    /// 关闭当前提示弹窗。
    func dismissAlert_confuse() {
        isShowingAlert_confuse = false
    }

    /// 重启监控任务以应用配置变化。
    private func restartMonitoring_confuse() {
        monitoringTask_confuse?.cancel()
        monitoringTask_confuse = nil
        isMonitoring_confuse = false
        startMonitoring_confuse()
    }

    /// 执行一轮到期应用检查。
    /// - Parameter force_confuse: 是否忽略下一次检查时间并强制检查。
    private func runCycle_confuse(force_confuse: Bool) async {
        let now_confuse = Date()
        let appIDs_confuse = configuration_confuse.applications_confuse
            .filter { application_confuse in
                application_confuse.isEnabled_confuse
                    && (force_confuse || now_confuse >= nextDueDates_confuse[application_confuse.appID_confuse] ?? .distantPast)
            }
            .map(\.appID_confuse)
        guard !appIDs_confuse.isEmpty else { return }
        await runApplications_confuse(appIDs_confuse: appIDs_confuse)
    }

    /// 顺序查询指定应用并持久化每项结果。
    /// - Parameter appIDs_confuse: 待查询的 App ID 列表。
    private func runApplications_confuse(appIDs_confuse: [String]) async {
        guard !isChecking_confuse else { return }
        isChecking_confuse = true
        statusText_confuse = "正在检查 App Store Connect..."
        defer {
            isChecking_confuse = false
            statusText_confuse = "最近巡检：\(timestamp_confuse())"
        }
        let service_confuse: AppStoreConnectService_confuse
        do {
            service_confuse = try AppStoreConnectService_confuse(configuration_confuse: configuration_confuse)
        } catch {
            showAlert_confuse(title_confuse: "网络配置错误", message_confuse: error.localizedDescription)
            return
        }
        for appID_confuse in appIDs_confuse {
            if Task.isCancelled { return }
            guard let index_confuse = configuration_confuse.applications_confuse.firstIndex(where: {
                $0.appID_confuse == appID_confuse
            }) else { continue }
            let application_confuse = configuration_confuse.applications_confuse[index_confuse]
            do {
                let result_confuse = try await service_confuse.check_confuse(application_confuse: application_confuse)
                applyResult_confuse(appID_confuse: appID_confuse, result_confuse: result_confuse)
            } catch {
                applyFailure_confuse(appID_confuse: appID_confuse, error_confuse: error)
            }
            saveConfiguration_confuse()
        }
    }

    /// 将成功查询结果写回应用并记录状态变化。
    /// - Parameters:
    ///   - appID_confuse: 被查询的 App ID。
    ///   - result_confuse: Apple API 查询结果。
    private func applyResult_confuse(
        appID_confuse: String,
        result_confuse: MonitoringCheckResult_confuse
    ) {
        guard let index_confuse = configuration_confuse.applications_confuse.firstIndex(where: {
            $0.appID_confuse == appID_confuse
        }) else { return }
        let oldState_confuse = configuration_confuse.applications_confuse[index_confuse].state_confuse
        configuration_confuse.applications_confuse[index_confuse].name_confuse = result_confuse.name_confuse
        configuration_confuse.applications_confuse[index_confuse].version_confuse = result_confuse.version_confuse
        configuration_confuse.applications_confuse[index_confuse].state_confuse = result_confuse.state_confuse
        configuration_confuse.applications_confuse[index_confuse].label_confuse = result_confuse.label_confuse
        configuration_confuse.applications_confuse[index_confuse].checkedAt_confuse = result_confuse.checkedAt_confuse
        configuration_confuse.applications_confuse[index_confuse].error_confuse = ""
        let didChange_confuse = !oldState_confuse.isEmpty && oldState_confuse != result_confuse.state_confuse
        if didChange_confuse {
            configuration_confuse.applications_confuse[index_confuse].stateChangedAt_confuse = result_confuse.checkedAt_confuse
        }
        let event_confuse = didChange_confuse
            ? "状态变化：\(MonitoringStateCatalog_confuse.label_confuse(for: oldState_confuse)) -> \(result_confuse.label_confuse)"
            : "检查完成：\(result_confuse.label_confuse)"
        appendRecord_confuse(
            application_confuse: configuration_confuse.applications_confuse[index_confuse],
            event_confuse: event_confuse,
            isError_confuse: false
        )
        nextDueDates_confuse[appID_confuse] = Date().addingTimeInterval(
            interval_confuse(for: result_confuse.state_confuse)
        )
        if didChange_confuse {
            let title_confuse = "\(result_confuse.name_confuse) 状态变化"
            let message_confuse = "版本 \(result_confuse.version_confuse)：\(result_confuse.label_confuse)"
            let configuration_confuse = configuration_confuse
            Task {
                await MonitoringNotificationService_confuse.send_confuse(
                    title_confuse: title_confuse,
                    message_confuse: message_confuse,
                    configuration_confuse: configuration_confuse
                )
            }
        }
    }

    /// 将查询失败信息写回应用并记录错误。
    /// - Parameters:
    ///   - appID_confuse: 查询失败的 App ID。
    ///   - error_confuse: 网络、鉴权或响应错误。
    private func applyFailure_confuse(appID_confuse: String, error_confuse: Error) {
        guard let index_confuse = configuration_confuse.applications_confuse.firstIndex(where: {
            $0.appID_confuse == appID_confuse
        }) else { return }
        configuration_confuse.applications_confuse[index_confuse].error_confuse = error_confuse.localizedDescription
        configuration_confuse.applications_confuse[index_confuse].label_confuse = "检查失败"
        configuration_confuse.applications_confuse[index_confuse].checkedAt_confuse = timestamp_confuse()
        appendRecord_confuse(
            application_confuse: configuration_confuse.applications_confuse[index_confuse],
            event_confuse: error_confuse.localizedDescription,
            isError_confuse: true
        )
        nextDueDates_confuse[appID_confuse] = Date().addingTimeInterval(300)
    }

    /// 根据当前审核状态返回下一次轮询秒数。
    /// - Parameter state_confuse: Apple 原始状态。
    /// - Returns: 不小于三十秒的轮询间隔。
    private func interval_confuse(for state_confuse: String) -> TimeInterval {
        if state_confuse == "IN_REVIEW" {
            return TimeInterval(max(30, configuration_confuse.reviewInterval_confuse))
        }
        if MonitoringStateCatalog_confuse.APPROVED_STATES_CONFUSE.contains(state_confuse) {
            return TimeInterval(max(30, configuration_confuse.approvedInterval_confuse))
        }
        return TimeInterval(max(30, configuration_confuse.defaultInterval_confuse))
    }

    /// 新增审核记录并同步到结构化和文本日志。
    /// - Parameters:
    ///   - application_confuse: 记录关联的应用。
    ///   - event_confuse: 查询或状态变化说明。
    ///   - isError_confuse: 是否为错误事件。
    private func appendRecord_confuse(
        application_confuse: MonitoringApplication_confuse,
        event_confuse: String,
        isError_confuse: Bool
    ) {
        let record_confuse = MonitoringRecord_confuse(
            id: UUID(),
            timestamp_confuse: timestamp_confuse(),
            applicationName_confuse: application_confuse.name_confuse.isEmpty
                ? application_confuse.appID_confuse
                : application_confuse.name_confuse,
            appID_confuse: application_confuse.appID_confuse,
            event_confuse: event_confuse,
            state_confuse: application_confuse.state_confuse,
            isError_confuse: isError_confuse
        )
        records_confuse.append(record_confuse)
        records_confuse = Array(records_confuse.suffix(1000))
        do {
            try storage_confuse?.saveRecords_confuse(records_confuse, latestRecord_confuse: record_confuse)
        } catch {
            showAlert_confuse(title_confuse: "日志写入失败", message_confuse: error.localizedDescription)
        }
    }

    /// 将当前监控配置写入磁盘。
    private func saveConfiguration_confuse() {
        do {
            try storage_confuse?.saveConfiguration_confuse(configuration_confuse)
        } catch {
            showAlert_confuse(title_confuse: "配置保存失败", message_confuse: error.localizedDescription)
        }
    }

    /// 更新统一提示弹窗内容并显示弹窗。
    /// - Parameters:
    ///   - title_confuse: 弹窗标题。
    ///   - message_confuse: 详细说明。
    private func showAlert_confuse(title_confuse: String, message_confuse: String) {
        alertTitle_confuse = title_confuse
        alertMessage_confuse = message_confuse
        isShowingAlert_confuse = true
    }

    /// 返回统一格式的当前本地时间。
    /// - Returns: `yyyy-MM-dd HH:mm:ss` 时间文本。
    private func timestamp_confuse() -> String {
        let formatter_confuse = DateFormatter()
        formatter_confuse.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter_confuse.string(from: Date())
    }
}
