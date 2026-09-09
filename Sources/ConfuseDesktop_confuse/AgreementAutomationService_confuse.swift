import Foundation

/// 描述协议自动化执行过程中可以直接展示给用户的错误。
enum AgreementAutomationError_confuse: LocalizedError {
    case scriptMissing_confuse
    case chromeMissing_confuse
    case cancelled_confuse
    case invalidResult_confuse
    case executionFailed_confuse(String)

    /// 返回协议自动化错误的中文说明。
    var errorDescription: String? {
        switch self {
        case .scriptMissing_confuse:
            return "协议自动化脚本缺失，请重新打包应用。"
        case .chromeMissing_confuse:
            return "未找到 Google Chrome，请先安装 Chrome 浏览器。"
        case .cancelled_confuse:
            return "协议生成已停止。"
        case .invalidResult_confuse:
            return "协议生成器没有返回有效结果。"
        case .executionFailed_confuse(let message_confuse):
            return message_confuse
        }
    }
}

/// 调用应用内置 Python 桥接脚本，通过浏览器助手控制当前 Chrome，并返回协议进度和链接。
final class AgreementAutomationService_confuse: @unchecked Sendable {
    private let processLock_confuse = NSLock()
    private var activeProcess_confuse: Process?
    private var isCancellationRequested_confuse = false

    /// 顺序生成请求中指定的协议，并实时转发脚本事件。
    /// - Parameters:
    ///   - request_confuse: 应用名称、邮箱和待生成协议类型。
    ///   - progressHandler_confuse: 收到阶段进度或链接时执行的回调。
    /// - Returns: 按协议类型索引的生成链接。
    /// - Throws: 脚本缺失、Chrome 缺失、用户停止或脚本执行失败时抛出错误。
    func run_confuse(
        request_confuse: AgreementAutomationRequest_confuse,
        progressHandler_confuse: @escaping (AgreementAutomationEvent_confuse) -> Void
    ) throws -> [AgreementType_confuse: String] {
        guard let scriptURL_confuse = Bundle.module.url(
            forResource: "agreement_automation_confuse",
            withExtension: "py"
        ) else {
            throw AgreementAutomationError_confuse.scriptMissing_confuse
        }

        let requestURL_confuse = FileManager.default.temporaryDirectory
            .appendingPathComponent("agreement_request_\(UUID().uuidString)_confuse.json")
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
            throw AgreementAutomationError_confuse.executionFailed_confuse("无法启动协议自动化脚本。")
        }

        var outputBuffer_confuse = ""
        var resultEvent_confuse: AgreementAutomationEvent_confuse?
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
            throw AgreementAutomationError_confuse.cancelled_confuse
        }
        let standardErrorData_confuse = errorPipe_confuse.fileHandleForReading.readDataToEndOfFile()
        let standardError_confuse = String(data: standardErrorData_confuse, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard process_confuse.terminationStatus == 0,
              let resultEvent_confuse,
              resultEvent_confuse.ok_confuse == true else {
            let message_confuse = latestError_confuse.isEmpty ? standardError_confuse : latestError_confuse
            if message_confuse.localizedCaseInsensitiveContains("未找到 Google Chrome") {
                throw AgreementAutomationError_confuse.chromeMissing_confuse
            }
            throw AgreementAutomationError_confuse.executionFailed_confuse(
                message_confuse.isEmpty ? "协议生成失败，请检查网络和 Chrome 状态。" : message_confuse
            )
        }

        var links_confuse: [AgreementType_confuse: String] = [:]
        for (rawType_confuse, link_confuse) in resultEvent_confuse.links_confuse ?? [:] {
            if let agreementType_confuse = AgreementType_confuse(rawValue: rawType_confuse) {
                links_confuse[agreementType_confuse] = link_confuse
            }
        }
        guard !links_confuse.isEmpty else {
            throw AgreementAutomationError_confuse.invalidResult_confuse
        }
        return links_confuse
    }

    /// 停止当前协议自动化脚本；没有运行任务时不执行操作。
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

    /// 从输出缓冲区逐行解析完整 JSON 事件，并保留尚未结束的尾部数据。
    /// - Parameters:
    ///   - buffer_confuse: 当前标准输出文本缓冲区。
    ///   - resultEvent_confuse: 脚本最终结果事件。
    ///   - latestError_confuse: 最近一次脚本错误说明。
    ///   - progressHandler_confuse: 阶段事件回调。
    private func consumeLines_confuse(
        buffer_confuse: inout String,
        resultEvent_confuse: inout AgreementAutomationEvent_confuse?,
        latestError_confuse: inout String,
        progressHandler_confuse: (AgreementAutomationEvent_confuse) -> Void
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

    /// 解析一行脚本 JSON，并按事件类型保存结果或转发进度。
    /// - Parameters:
    ///   - line_confuse: 单行 JSON 文本。
    ///   - resultEvent_confuse: 脚本最终结果事件。
    ///   - latestError_confuse: 最近一次脚本错误说明。
    ///   - progressHandler_confuse: 阶段事件回调。
    private func consumeLine_confuse(
        line_confuse: String,
        resultEvent_confuse: inout AgreementAutomationEvent_confuse?,
        latestError_confuse: inout String,
        progressHandler_confuse: (AgreementAutomationEvent_confuse) -> Void
    ) {
        guard let data_confuse = line_confuse.data(using: .utf8),
              let event_confuse = try? JSONDecoder().decode(AgreementAutomationEvent_confuse.self, from: data_confuse) else {
            return
        }
        if event_confuse.event_confuse == "result" {
            resultEvent_confuse = event_confuse
        } else {
            if event_confuse.event_confuse == "error" {
                latestError_confuse = event_confuse.error_confuse
                    ?? event_confuse.message_confuse
                    ?? "协议生成失败。"
            }
            progressHandler_confuse(event_confuse)
        }
    }
}
