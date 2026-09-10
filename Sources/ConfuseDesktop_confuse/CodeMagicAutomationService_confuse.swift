import Foundation

/// 描述 Codemagic 浏览器自动化过程中可以直接展示给用户的错误。
enum CodeMagicAutomationError_confuse: LocalizedError {
    case scriptMissing_confuse
    case cancelled_confuse
    case invalidResult_confuse
    case executionFailed_confuse(String)

    /// 返回云端构建自动化错误的中文说明，供页面直接展示。
    var errorDescription: String? {
        switch self {
        case .scriptMissing_confuse:
            return "Codemagic 自动化脚本缺失，请重新打包应用。"
        case .cancelled_confuse:
            return "Codemagic 自动化已停止。"
        case .invalidResult_confuse:
            return "Codemagic 没有返回有效结果。"
        case .executionFailed_confuse(let message_confuse):
            return message_confuse
        }
    }
}

/// 调用内置桥接脚本，通过浏览器助手在当前 Chrome 中执行 Codemagic 配置。
///
/// 服务负责临时请求文件、脚本进程和结构化事件解析；页面查找、表单填写、
/// API 文件上传和弹窗等待统一由浏览器扩展处理。
final class CodeMagicAutomationService_confuse: @unchecked Sendable {
    private let processLock_confuse = NSLock()
    private var activeProcess_confuse: Process?
    private var isCancellationRequested_confuse = false

    /// 执行请求中的 Codemagic 步骤并实时转发进度。
    /// - Parameters:
    ///   - request_confuse: 项目、Profile 字段、API 文件和待执行步骤。
    ///   - progressHandler_confuse: 收到浏览器进度事件时执行的回调。
    /// - Returns: 全部所选步骤完成时返回 true。
    /// - Throws: 脚本缺失、浏览器助手未连接、页面操作失败或用户停止时抛出错误。
    func run_confuse(
        request_confuse: CodeMagicAutomationRequest_confuse,
        progressHandler_confuse: @escaping (CodeMagicAutomationEvent_confuse) -> Void
    ) throws -> Bool {
        guard let scriptURL_confuse = Bundle.module.url(
            forResource: "codemagic_automation_confuse",
            withExtension: "py"
        ) else {
            throw CodeMagicAutomationError_confuse.scriptMissing_confuse
        }

        let requestURL_confuse = FileManager.default.temporaryDirectory
            .appendingPathComponent("codemagic_request_\(UUID().uuidString)_confuse.json")
        try JSONEncoder().encode(request_confuse).write(to: requestURL_confuse, options: [.atomic])
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
            throw CodeMagicAutomationError_confuse.executionFailed_confuse(
                "无法启动 Codemagic 自动化脚本。"
            )
        }

        var buffer_confuse = ""
        var resultEvent_confuse: CodeMagicAutomationEvent_confuse?
        var latestError_confuse = ""
        while true {
            let data_confuse = outputPipe_confuse.fileHandleForReading.availableData
            guard !data_confuse.isEmpty else { break }
            buffer_confuse += String(data: data_confuse, encoding: .utf8) ?? ""
            consumeLines_confuse(
                buffer_confuse: &buffer_confuse,
                resultEvent_confuse: &resultEvent_confuse,
                latestError_confuse: &latestError_confuse,
                progressHandler_confuse: progressHandler_confuse
            )
        }
        if !buffer_confuse.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            consumeLine_confuse(
                line_confuse: buffer_confuse,
                resultEvent_confuse: &resultEvent_confuse,
                latestError_confuse: &latestError_confuse,
                progressHandler_confuse: progressHandler_confuse
            )
        }
        process_confuse.waitUntilExit()

        if cancellationRequested_confuse() {
            throw CodeMagicAutomationError_confuse.cancelled_confuse
        }
        let errorData_confuse = errorPipe_confuse.fileHandleForReading.readDataToEndOfFile()
        let standardError_confuse = String(data: errorData_confuse, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard process_confuse.terminationStatus == 0,
              let resultEvent_confuse,
              resultEvent_confuse.ok_confuse == true else {
            let message_confuse = latestError_confuse.isEmpty ? standardError_confuse : latestError_confuse
            throw CodeMagicAutomationError_confuse.executionFailed_confuse(
                message_confuse.isEmpty
                    ? "Codemagic 自动化失败，请检查 Chrome、登录状态和网络连接。"
                    : message_confuse
            )
        }
        return true
    }

    /// 停止当前 Codemagic 自动化脚本。
    /// - Returns: 无返回值。
    func cancel_confuse() {
        processLock_confuse.lock()
        isCancellationRequested_confuse = true
        let process_confuse = activeProcess_confuse
        processLock_confuse.unlock()
        if process_confuse?.isRunning == true { process_confuse?.terminate() }
    }

    /// 注册正在运行的脚本进程并清空停止标记。
    /// - Parameter process_confuse: 即将启动的脚本进程。
    /// - Returns: 无返回值。
    private func registerProcess_confuse(process_confuse: Process) {
        processLock_confuse.lock()
        isCancellationRequested_confuse = false
        activeProcess_confuse = process_confuse
        processLock_confuse.unlock()
    }

    /// 清除已经结束的脚本进程引用。
    /// - Parameter process_confuse: 刚刚结束的脚本进程。
    /// - Returns: 无返回值。
    private func clearProcess_confuse(process_confuse: Process) {
        processLock_confuse.lock()
        if activeProcess_confuse === process_confuse { activeProcess_confuse = nil }
        processLock_confuse.unlock()
    }

    /// 返回用户是否已经请求停止任务。
    /// - Returns: 已请求停止时返回 true。
    private func cancellationRequested_confuse() -> Bool {
        processLock_confuse.lock()
        let value_confuse = isCancellationRequested_confuse
        processLock_confuse.unlock()
        return value_confuse
    }

    /// 从标准输出缓冲区解析所有完整 JSON 行。
    /// - Parameters:
    ///   - buffer_confuse: 尚未完整消费的标准输出文本。
    ///   - resultEvent_confuse: 最终结果事件引用。
    ///   - latestError_confuse: 最近错误说明引用。
    ///   - progressHandler_confuse: 进度事件回调。
    /// - Returns: 无返回值。
    private func consumeLines_confuse(
        buffer_confuse: inout String,
        resultEvent_confuse: inout CodeMagicAutomationEvent_confuse?,
        latestError_confuse: inout String,
        progressHandler_confuse: (CodeMagicAutomationEvent_confuse) -> Void
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
    ///   - resultEvent_confuse: 最终结果事件引用。
    ///   - latestError_confuse: 最近错误说明引用。
    ///   - progressHandler_confuse: 进度事件回调。
    /// - Returns: 无返回值。
    private func consumeLine_confuse(
        line_confuse: String,
        resultEvent_confuse: inout CodeMagicAutomationEvent_confuse?,
        latestError_confuse: inout String,
        progressHandler_confuse: (CodeMagicAutomationEvent_confuse) -> Void
    ) {
        guard let data_confuse = line_confuse.data(using: .utf8),
              let event_confuse = try? JSONDecoder().decode(
                CodeMagicAutomationEvent_confuse.self,
                from: data_confuse
              ) else { return }
        if event_confuse.event_confuse == "result" {
            resultEvent_confuse = event_confuse
        } else {
            if event_confuse.event_confuse == "error" {
                latestError_confuse = event_confuse.error_confuse
                    ?? event_confuse.message_confuse
                    ?? "Codemagic 自动化失败。"
            }
            progressHandler_confuse(event_confuse)
        }
    }
}
