import Foundation

/// 描述后台配置读取过程中可以直接展示给用户的错误。
enum BackendConfigurationError_confuse: LocalizedError {
    case scriptMissing_confuse
    case cancelled_confuse
    case invalidResult_confuse
    case executionFailed_confuse(String)

    /// 返回后台配置读取错误的中文说明。
    var errorDescription: String? {
        switch self {
        case .scriptMissing_confuse:
            return "后台配置脚本缺失，请重新打包应用。"
        case .cancelled_confuse:
            return "后台配置获取已停止。"
        case .invalidResult_confuse:
            return "后台没有返回有效的项目配置。"
        case .executionFailed_confuse(let message_confuse):
            return message_confuse
        }
    }
}

/// 调用应用内置桥接脚本，通过当前 Chrome 读取苹果马甲包后台配置。
///
/// 服务只负责临时请求文件、脚本进程和结构化事件解析，浏览器页面操作由
/// App Tools 浏览器助手执行，登录凭据不会保存到应用配置或用户目录。
final class BackendConfigurationService_confuse: @unchecked Sendable {
    private let processLock_confuse = NSLock()
    private var activeProcess_confuse: Process?
    private var isCancellationRequested_confuse = false

    /// 按目标 Bundle ID 获取后台配置，并实时转发脚本进度。
    /// - Parameters:
    ///   - request_confuse: 后台账号、密码、2FA 和目标 Bundle ID。
    ///   - progressHandler_confuse: 收到脚本进度事件时执行的回调。
    /// - Returns: 后台返回的七项合包配置和 Facebook 标签状态。
    /// - Throws: 脚本缺失、浏览器助手未连接、登录失败或字段缺失时抛出错误。
    func run_confuse(
        request_confuse: BackendConfigurationRequest_confuse,
        progressHandler_confuse: @escaping (BackendConfigurationEvent_confuse) -> Void
    ) throws -> BackendConfiguration_confuse {
        guard let scriptURL_confuse = Bundle.module.url(
            forResource: "backend_configuration_confuse",
            withExtension: "py"
        ) else {
            throw BackendConfigurationError_confuse.scriptMissing_confuse
        }

        let requestURL_confuse = FileManager.default.temporaryDirectory
            .appendingPathComponent("backend_request_\(UUID().uuidString)_confuse.json")
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
            throw BackendConfigurationError_confuse.executionFailed_confuse("无法启动后台配置脚本。")
        }

        var outputBuffer_confuse = ""
        var resultEvent_confuse: BackendConfigurationEvent_confuse?
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
            throw BackendConfigurationError_confuse.cancelled_confuse
        }
        let errorData_confuse = errorPipe_confuse.fileHandleForReading.readDataToEndOfFile()
        let standardError_confuse = String(data: errorData_confuse, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard process_confuse.terminationStatus == 0,
              let resultEvent_confuse,
              resultEvent_confuse.ok_confuse == true else {
            let message_confuse = latestError_confuse.isEmpty ? standardError_confuse : latestError_confuse
            throw BackendConfigurationError_confuse.executionFailed_confuse(
                message_confuse.isEmpty ? "后台配置获取失败，请检查 Chrome、登录信息和网络状态。" : message_confuse
            )
        }
        guard let configuration_confuse = resultEvent_confuse.configuration_confuse else {
            throw BackendConfigurationError_confuse.invalidResult_confuse
        }
        return configuration_confuse
    }

    /// 停止当前后台配置脚本；没有运行任务时不执行操作。
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

    /// 清除已经结束的脚本进程引用。
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

    /// 从输出缓冲区解析完整 JSON 行并保留尚未结束的尾部数据。
    /// - Parameters:
    ///   - buffer_confuse: 当前标准输出文本缓冲区。
    ///   - resultEvent_confuse: 脚本最终结果事件。
    ///   - latestError_confuse: 最近一次脚本错误说明。
    ///   - progressHandler_confuse: 进度事件回调。
    private func consumeLines_confuse(
        buffer_confuse: inout String,
        resultEvent_confuse: inout BackendConfigurationEvent_confuse?,
        latestError_confuse: inout String,
        progressHandler_confuse: (BackendConfigurationEvent_confuse) -> Void
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
        resultEvent_confuse: inout BackendConfigurationEvent_confuse?,
        latestError_confuse: inout String,
        progressHandler_confuse: (BackendConfigurationEvent_confuse) -> Void
    ) {
        guard let data_confuse = line_confuse.data(using: .utf8),
              let event_confuse = try? JSONDecoder().decode(BackendConfigurationEvent_confuse.self, from: data_confuse) else {
            return
        }
        if event_confuse.event_confuse == "result" {
            resultEvent_confuse = event_confuse
            return
        }
        if event_confuse.event_confuse == "error" {
            latestError_confuse = event_confuse.error_confuse
                ?? event_confuse.message_confuse
                ?? "后台配置获取失败。"
        }
        progressHandler_confuse(event_confuse)
    }
}
