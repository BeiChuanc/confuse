import Foundation

/// 负责把任务参数交给随应用打包的 Python 引擎，并解析结构化结果。
final class EngineService_confuse {
    /// 执行一次混淆、反混淆或合包任务。
    /// - Parameter request_confuse: 任务目录、类别、后缀和操作配置。
    /// - Returns: 引擎返回的执行统计结果。
    /// - Throws: 引擎资源缺失、请求文件无法写入或进程执行失败时抛出错误。
    static func run_confuse(request_confuse: EngineRequest_confuse) throws -> EngineResult_confuse {
        guard let scriptURL_confuse = Bundle.module.url(
            forResource: "confuse_engine",
            withExtension: "py"
        ) else {
            throw NSError(domain: "ConfuseEngine", code: 1, userInfo: [NSLocalizedDescriptionKey: "Engine resource is missing."])
        }

        let requestData_confuse = try JSONEncoder().encode(request_confuse)
        let requestURL_confuse = URL(fileURLWithPath: request_confuse.projectPath_confuse)
            .appendingPathComponent(".confuse_request_confuse.json")
        try requestData_confuse.write(to: requestURL_confuse, options: [.atomic])
        defer { try? FileManager.default.removeItem(at: requestURL_confuse) }

        let process_confuse = Process()
        let outputPipe_confuse = Pipe()
        let errorPipe_confuse = Pipe()
        process_confuse.executableURL = URL(fileURLWithPath: "/usr/bin/python3")
        process_confuse.arguments = [scriptURL_confuse.path, "--request", requestURL_confuse.path]
        process_confuse.standardOutput = outputPipe_confuse
        process_confuse.standardError = errorPipe_confuse
        try process_confuse.run()
        process_confuse.waitUntilExit()

        let outputData_confuse = outputPipe_confuse.fileHandleForReading.readDataToEndOfFile()
        let errorData_confuse = errorPipe_confuse.fileHandleForReading.readDataToEndOfFile()
        let output_confuse = String(data: outputData_confuse, encoding: .utf8) ?? ""
        let error_confuse = String(data: errorData_confuse, encoding: .utf8) ?? ""
        guard let resultData_confuse = output_confuse.data(using: .utf8),
              let result_confuse = try? JSONDecoder().decode(EngineResult_confuse.self, from: resultData_confuse) else {
            let message_confuse = error_confuse.isEmpty ? "引擎返回了无效结果。" : error_confuse
            throw NSError(domain: "ConfuseEngine", code: Int(process_confuse.terminationStatus), userInfo: [NSLocalizedDescriptionKey: message_confuse])
        }
        return result_confuse
    }
}
