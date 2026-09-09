import AppKit
import Foundation

/// 描述飞书资料读取过程中可直接展示给用户的错误，并统一提供中文错误信息。
enum MaterialAutomationError_confuse: LocalizedError {
    case scriptMissing_confuse
    case extensionResourcesMissing_confuse
    case chromeMissing_confuse
    case cancelled_confuse
    case invalidResult_confuse
    case executionFailed_confuse(String)

    /// 返回飞书资料读取错误的中文说明。
    var errorDescription: String? {
        switch self {
        case .scriptMissing_confuse:
            return "整理资料脚本缺失，请重新打包应用。"
        case .extensionResourcesMissing_confuse:
            return "Chrome 扩展资源缺失，请重新打包应用。"
        case .chromeMissing_confuse:
            return "未找到 Google Chrome，请先安装 Chrome 浏览器。"
        case .cancelled_confuse:
            return "资料整理已停止。"
        case .invalidResult_confuse:
            return "飞书页面没有返回有效的项目资料。"
        case .executionFailed_confuse(let message_confuse):
            return message_confuse
        }
    }
}

/// 安装 Chrome 扩展通信资源，并调用内置脚本接收飞书读取进度和最终记录。
final class MaterialAutomationService_confuse: @unchecked Sendable {
    private let extensionID_confuse = "fonflfdhbnfoflmnbgliiijlpcfclgdb"
    private let nativeHostName_confuse = "com.apptools.confuse.material"
    private let processLock_confuse = NSLock()
    private var activeProcess_confuse: Process?
    private var isCancellationRequested_confuse = false

    /// 返回 Chrome 扩展和原生消息宿主是否已经准备到用户目录。
    /// - Returns: 两项资源均存在时返回 true。
    func isExtensionPrepared_confuse() -> Bool {
        let fileManager_confuse = FileManager.default
        guard let extensionURL_confuse = try? installedExtensionURL_confuse(),
              let manifestURL_confuse = try? nativeHostManifestURL_confuse() else {
            return false
        }
        return fileManager_confuse.fileExists(atPath: extensionURL_confuse.path)
            && fileManager_confuse.fileExists(atPath: manifestURL_confuse.path)
    }

    /// 将扩展和原生消息宿主复制到用户目录，并写入仅允许固定扩展连接的清单。
    /// - Returns: 可在 Chrome 中加载的扩展目录。
    /// - Throws: 打包资源缺失、目录创建或文件写入失败时抛出错误。
    func prepareExtension_confuse() throws -> URL {
        let fileManager_confuse = FileManager.default
        guard let bundledExtensionURL_confuse = bundledExtensionURL_confuse(),
              let bundledHostURL_confuse = Bundle.module.url(
                forResource: "material_native_host_confuse",
                withExtension: "py"
              ) else {
            throw MaterialAutomationError_confuse.extensionResourcesMissing_confuse
        }

        let extensionURL_confuse = try installedExtensionURL_confuse()
        let bridgeDirectoryURL_confuse = try installedBridgeDirectoryURL_confuse()
        let hostURL_confuse = bridgeDirectoryURL_confuse
            .appendingPathComponent("material_native_host_confuse.py")
        try removeLegacyExtensionInstallation_confuse()
        try fileManager_confuse.createDirectory(
            at: extensionURL_confuse.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        if fileManager_confuse.fileExists(atPath: extensionURL_confuse.path) {
            try fileManager_confuse.removeItem(at: extensionURL_confuse)
        }
        try fileManager_confuse.copyItem(at: bundledExtensionURL_confuse, to: extensionURL_confuse)

        try fileManager_confuse.createDirectory(
            at: bridgeDirectoryURL_confuse,
            withIntermediateDirectories: true
        )
        if fileManager_confuse.fileExists(atPath: hostURL_confuse.path) {
            try fileManager_confuse.removeItem(at: hostURL_confuse)
        }
        try fileManager_confuse.copyItem(at: bundledHostURL_confuse, to: hostURL_confuse)
        try fileManager_confuse.setAttributes(
            [.posixPermissions: 0o700],
            ofItemAtPath: hostURL_confuse.path
        )

        let manifestURL_confuse = try nativeHostManifestURL_confuse()
        try fileManager_confuse.createDirectory(
            at: manifestURL_confuse.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        let manifest_confuse: [String: Any] = [
            "name": nativeHostName_confuse,
            "description": "App Tools 浏览器自动化本机通信服务",
            "path": hostURL_confuse.path,
            "type": "stdio",
            "allowed_origins": ["chrome-extension://\(extensionID_confuse)/"]
        ]
        let manifestData_confuse = try JSONSerialization.data(
            withJSONObject: manifest_confuse,
            options: [.prettyPrinted, .sortedKeys]
        )
        try manifestData_confuse.write(to: manifestURL_confuse, options: [.atomic])
        try fileManager_confuse.setAttributes(
            [.posixPermissions: 0o600],
            ofItemAtPath: manifestURL_confuse.path
        )
        return extensionURL_confuse
    }

    /// 在访达中显示已经准备好的扩展目录。
    /// - Throws: 扩展尚未准备时抛出资源缺失错误。
    func showExtensionDirectory_confuse() throws {
        let extensionURL_confuse = try installedExtensionURL_confuse()
        guard FileManager.default.fileExists(atPath: extensionURL_confuse.path) else {
            throw MaterialAutomationError_confuse.extensionResourcesMissing_confuse
        }
        NSWorkspace.shared.activateFileViewerSelecting([extensionURL_confuse])
    }

    /// 使用当前 Google Chrome 打开扩展管理页面。
    /// - Throws: 系统未安装 Google Chrome 时抛出错误。
    func openChromeExtensionManager_confuse() throws {
        guard let chromeURL_confuse = NSWorkspace.shared.urlForApplication(
            withBundleIdentifier: "com.google.Chrome"
        ) else {
            throw MaterialAutomationError_confuse.chromeMissing_confuse
        }
        let configuration_confuse = NSWorkspace.OpenConfiguration()
        configuration_confuse.arguments = ["chrome://extensions"]
        NSWorkspace.shared.openApplication(
            at: chromeURL_confuse,
            configuration: configuration_confuse
        ) { _, _ in }
    }

    /// 根据 UI 编号读取飞书记录，并实时转发脚本进度。
    /// - Parameters:
    ///   - request_confuse: 包含 UI 编号的资料整理请求。
    ///   - progressHandler_confuse: 收到脚本进度事件时执行的回调。
    /// - Returns: 包含 UI 编号和八项指定字段的飞书项目记录。
    /// - Throws: 脚本缺失、用户停止、扩展未连接或网页结构变化时抛出错误。
    func run_confuse(
        request_confuse: MaterialAutomationRequest_confuse,
        progressHandler_confuse: @escaping (MaterialAutomationEvent_confuse) -> Void
    ) throws -> MaterialRecord_confuse {
        guard let scriptURL_confuse = Bundle.module.url(
            forResource: "material_automation_confuse",
            withExtension: "py"
        ) else {
            throw MaterialAutomationError_confuse.scriptMissing_confuse
        }

        let requestURL_confuse = FileManager.default.temporaryDirectory
            .appendingPathComponent("material_request_\(UUID().uuidString)_confuse.json")
        let requestData_confuse = try JSONEncoder().encode(request_confuse)
        try requestData_confuse.write(to: requestURL_confuse, options: [.atomic])
        defer { try? FileManager.default.removeItem(at: requestURL_confuse) }

        let process_confuse = Process()
        let outputPipe_confuse = Pipe()
        let errorPipe_confuse = Pipe()
        process_confuse.executableURL = URL(fileURLWithPath: "/usr/bin/python3")
        process_confuse.arguments = [scriptURL_confuse.path, "--request", requestURL_confuse.path]
        process_confuse.standardOutput = outputPipe_confuse
        process_confuse.standardError = errorPipe_confuse
        registerProcess_confuse(process_confuse: process_confuse)
        defer { clearProcess_confuse(process_confuse: process_confuse) }

        do {
            try process_confuse.run()
        } catch {
            throw MaterialAutomationError_confuse.executionFailed_confuse("无法启动整理资料脚本。")
        }

        var outputBuffer_confuse = ""
        var resultEvent_confuse: MaterialAutomationEvent_confuse?
        var latestError_confuse = ""
        while true {
            let data_confuse = outputPipe_confuse.fileHandleForReading.availableData
            guard !data_confuse.isEmpty else { break }
            outputBuffer_confuse += String(data: data_confuse, encoding: .utf8) ?? ""
            consumeLines_confuse(
                buffer_confuse: &outputBuffer_confuse,
                resultEvent_confuse: &resultEvent_confuse,
                latestError_confuse: &latestError_confuse,
                progressHandler_confuse: progressHandler_confuse
            )
        }
        if !outputBuffer_confuse.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            consumeLine_confuse(
                line_confuse: outputBuffer_confuse,
                resultEvent_confuse: &resultEvent_confuse,
                latestError_confuse: &latestError_confuse,
                progressHandler_confuse: progressHandler_confuse
            )
        }
        process_confuse.waitUntilExit()

        if cancellationRequested_confuse() {
            throw MaterialAutomationError_confuse.cancelled_confuse
        }
        let errorData_confuse = errorPipe_confuse.fileHandleForReading.readDataToEndOfFile()
        let standardError_confuse = String(data: errorData_confuse, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard process_confuse.terminationStatus == 0,
              let resultEvent_confuse,
              resultEvent_confuse.ok_confuse == true else {
            let message_confuse = latestError_confuse.isEmpty ? standardError_confuse : latestError_confuse
            throw MaterialAutomationError_confuse.executionFailed_confuse(
                message_confuse.isEmpty ? "资料整理失败，请检查网络、Chrome 和飞书登录状态。" : message_confuse
            )
        }
        guard let record_confuse = resultEvent_confuse.record_confuse else {
            throw MaterialAutomationError_confuse.invalidResult_confuse
        }
        return record_confuse
    }

    /// 停止当前资料整理脚本；没有运行任务时不执行操作。
    func cancel_confuse() {
        processLock_confuse.lock()
        isCancellationRequested_confuse = true
        let process_confuse = activeProcess_confuse
        processLock_confuse.unlock()
        if process_confuse?.isRunning == true {
            process_confuse?.terminate()
        }
    }

    /// 注册正在运行的脚本进程并清空上一次停止标记。
    /// - Parameter process_confuse: 即将启动的脚本进程。
    private func registerProcess_confuse(process_confuse: Process) {
        processLock_confuse.lock()
        isCancellationRequested_confuse = false
        activeProcess_confuse = process_confuse
        processLock_confuse.unlock()
    }

    /// 清除已结束的脚本进程引用。
    /// - Parameter process_confuse: 刚刚结束的脚本进程。
    private func clearProcess_confuse(process_confuse: Process) {
        processLock_confuse.lock()
        if activeProcess_confuse === process_confuse {
            activeProcess_confuse = nil
        }
        processLock_confuse.unlock()
    }

    /// 返回用户是否请求停止当前任务。
    /// - Returns: 已请求停止时返回 true。
    private func cancellationRequested_confuse() -> Bool {
        processLock_confuse.lock()
        let result_confuse = isCancellationRequested_confuse
        processLock_confuse.unlock()
        return result_confuse
    }

    /// 从输出缓冲区逐行解析完整 JSON，并保留尚未结束的尾部数据。
    /// - Parameters:
    ///   - buffer_confuse: 当前标准输出文本缓冲区。
    ///   - resultEvent_confuse: 脚本最终结果事件。
    ///   - latestError_confuse: 最近一次脚本错误说明。
    ///   - progressHandler_confuse: 进度事件回调。
    private func consumeLines_confuse(
        buffer_confuse: inout String,
        resultEvent_confuse: inout MaterialAutomationEvent_confuse?,
        latestError_confuse: inout String,
        progressHandler_confuse: (MaterialAutomationEvent_confuse) -> Void
    ) {
        while let newlineRange_confuse = buffer_confuse.range(of: "\n") {
            let line_confuse = String(buffer_confuse[..<newlineRange_confuse.lowerBound])
            buffer_confuse.removeSubrange(...newlineRange_confuse.lowerBound)
            consumeLine_confuse(
                line_confuse: line_confuse,
                resultEvent_confuse: &resultEvent_confuse,
                latestError_confuse: &latestError_confuse,
                progressHandler_confuse: progressHandler_confuse
            )
        }
    }

    /// 解析单行脚本事件，并保存结果、错误或转发进度。
    /// - Parameters:
    ///   - line_confuse: 单行 JSON 文本。
    ///   - resultEvent_confuse: 脚本最终结果事件。
    ///   - latestError_confuse: 最近一次脚本错误说明。
    ///   - progressHandler_confuse: 进度事件回调。
    private func consumeLine_confuse(
        line_confuse: String,
        resultEvent_confuse: inout MaterialAutomationEvent_confuse?,
        latestError_confuse: inout String,
        progressHandler_confuse: (MaterialAutomationEvent_confuse) -> Void
    ) {
        guard let data_confuse = line_confuse.data(using: .utf8),
              let event_confuse = try? JSONDecoder().decode(MaterialAutomationEvent_confuse.self, from: data_confuse) else {
            return
        }
        if event_confuse.event_confuse == "result" {
            resultEvent_confuse = event_confuse
            return
        }
        if event_confuse.event_confuse == "error" {
            latestError_confuse = event_confuse.error_confuse
                ?? event_confuse.message_confuse
                ?? "资料整理失败。"
        }
        progressHandler_confuse(event_confuse)
    }

    /// 查找应用包内的 Chrome 扩展目录，并兼容 Swift Package 的两种资源布局。
    /// - Returns: 找到时返回扩展目录，否则返回空值。
    private func bundledExtensionURL_confuse() -> URL? {
        let candidates_confuse = [
            Bundle.module.url(forResource: "ChromeExtension_confuse", withExtension: nil),
            Bundle.module.resourceURL?.appendingPathComponent("ChromeExtension_confuse", isDirectory: true),
            Bundle.module.resourceURL?.appendingPathComponent(
                "Resources/ChromeExtension_confuse",
                isDirectory: true
            )
        ].compactMap { $0 }
        return candidates_confuse.first { url_confuse in
            var isDirectory_confuse: ObjCBool = false
            return FileManager.default.fileExists(
                atPath: url_confuse.path,
                isDirectory: &isDirectory_confuse
            ) && isDirectory_confuse.boolValue
        }
    }

    /// 返回“文稿”目录中固定且可在 Chrome 文件选择器直接进入的扩展路径。
    /// - Returns: 扩展安装目录 URL。
    /// - Throws: 系统无法提供文稿目录时抛出文件错误。
    private func installedExtensionURL_confuse() throws -> URL {
        guard let documentsURL_confuse = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            throw CocoaError(.fileNoSuchFile)
        }
        return documentsURL_confuse
            .appendingPathComponent("AppTools", isDirectory: true)
            .appendingPathComponent("ChromeExtension_confuse", isDirectory: true)
    }

    /// 返回应用支持目录中的原生消息桥接路径，避免 Chrome 访问“文稿”时触发额外权限。
    /// - Returns: 原生消息桥接目录 URL。
    /// - Throws: 系统无法提供应用支持目录时抛出文件错误。
    private func installedBridgeDirectoryURL_confuse() throws -> URL {
        guard let applicationSupportURL_confuse = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            throw CocoaError(.fileNoSuchFile)
        }
        return applicationSupportURL_confuse
            .appendingPathComponent("AppTools", isDirectory: true)
            .appendingPathComponent("ChromeBridge_confuse", isDirectory: true)
    }

    /// 删除旧版本在应用支持目录中创建的扩展副本，避免 Chrome 加载过期资源。
    /// - Throws: 系统无法提供应用支持目录或旧目录删除失败时抛出文件错误。
    private func removeLegacyExtensionInstallation_confuse() throws {
        guard let applicationSupportURL_confuse = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            throw CocoaError(.fileNoSuchFile)
        }
        let legacyExtensionURL_confuse = applicationSupportURL_confuse
            .appendingPathComponent("AppTools", isDirectory: true)
            .appendingPathComponent("ChromeExtension_confuse", isDirectory: true)
        if FileManager.default.fileExists(atPath: legacyExtensionURL_confuse.path) {
            try FileManager.default.removeItem(at: legacyExtensionURL_confuse)
        }
    }

    /// 返回 Chrome 原生消息宿主清单的标准用户目录路径。
    /// - Returns: 原生消息清单文件 URL。
    /// - Throws: 系统无法提供应用支持目录时抛出文件错误。
    private func nativeHostManifestURL_confuse() throws -> URL {
        guard let applicationSupportURL_confuse = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            throw CocoaError(.fileNoSuchFile)
        }
        return applicationSupportURL_confuse
            .appendingPathComponent("Google/Chrome/NativeMessagingHosts", isDirectory: true)
            .appendingPathComponent("\(nativeHostName_confuse).json")
    }
}
