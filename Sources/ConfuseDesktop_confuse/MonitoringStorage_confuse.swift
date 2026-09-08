import Foundation

/// 管理 AppMonitorData 目录、监控配置、私钥副本、历史记录和配置备份。
final class MonitoringStorage_confuse: @unchecked Sendable {
    let rootURL_confuse: URL
    let keysURL_confuse: URL
    let logsURL_confuse: URL
    let backupsURL_confuse: URL
    private let configurationURL_confuse: URL
    private let recordsURL_confuse: URL
    private let fileManager_confuse: FileManager

    /// 创建监控存储并确保所需目录均可写。
    /// - Parameter rootURL_confuse: 可选的数据根目录，未传入时使用应用同级 AppMonitorData。
    /// - Throws: 目录无法创建或写入时抛出文件系统错误。
    init(rootURL_confuse: URL? = nil) throws {
        fileManager_confuse = .default
        self.rootURL_confuse = rootURL_confuse ?? Self.dataDirectoryURL_confuse()
        keysURL_confuse = self.rootURL_confuse.appendingPathComponent("keys", isDirectory: true)
        logsURL_confuse = self.rootURL_confuse.appendingPathComponent("logs", isDirectory: true)
        backupsURL_confuse = self.rootURL_confuse.appendingPathComponent("backups", isDirectory: true)
        configurationURL_confuse = self.rootURL_confuse.appendingPathComponent("config.json")
        recordsURL_confuse = logsURL_confuse.appendingPathComponent("records.json")
        try ensureDirectories_confuse()
    }

    /// 返回打包应用同级的数据目录。
    /// - Returns: `Confuse.app` 同级 AppMonitorData；非应用环境下返回当前目录中的 AppMonitorData。
    static func dataDirectoryURL_confuse() -> URL {
        let bundleURL_confuse = Bundle.main.bundleURL
        if bundleURL_confuse.pathExtension.lowercased() == "app" {
            return bundleURL_confuse
                .deletingLastPathComponent()
                .appendingPathComponent("AppMonitorData", isDirectory: true)
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent("AppMonitorData", isDirectory: true)
    }

    /// 读取监控配置，配置不存在时返回默认值。
    /// - Returns: 已保存配置或默认配置。
    /// - Throws: 配置存在但无法读取或解码时抛出错误。
    func loadConfiguration_confuse() throws -> MonitoringConfiguration_confuse {
        guard fileManager_confuse.fileExists(atPath: configurationURL_confuse.path) else {
            return .default_confuse
        }
        let data_confuse = try Data(contentsOf: configurationURL_confuse)
        return try JSONDecoder().decode(MonitoringConfiguration_confuse.self, from: data_confuse)
    }

    /// 原子保存监控配置，并保留最近十份配置备份。
    /// - Parameter configuration_confuse: 待保存的完整监控配置。
    /// - Throws: 编码、备份或写入失败时抛出错误。
    func saveConfiguration_confuse(_ configuration_confuse: MonitoringConfiguration_confuse) throws {
        try backupConfiguration_confuse()
        let encoder_confuse = JSONEncoder()
        encoder_confuse.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let data_confuse = try encoder_confuse.encode(configuration_confuse)
        try data_confuse.write(to: configurationURL_confuse, options: [.atomic])
        try setPrivatePermissions_confuse(url_confuse: configurationURL_confuse)
    }

    /// 读取结构化审核记录，并兼容旧版文本日志。
    /// - Returns: 按保存顺序排列的审核记录。
    /// - Throws: 记录文件存在但无法读取或解码时抛出错误。
    func loadRecords_confuse() throws -> [MonitoringRecord_confuse] {
        if fileManager_confuse.fileExists(atPath: recordsURL_confuse.path) {
            let data_confuse = try Data(contentsOf: recordsURL_confuse)
            return try JSONDecoder().decode([MonitoringRecord_confuse].self, from: data_confuse)
        }
        return try loadLegacyRecords_confuse()
    }

    /// 保存最多一千条审核记录，并同步写入兼容文本日志。
    /// - Parameters:
    ///   - records_confuse: 当前完整记录列表。
    ///   - latestRecord_confuse: 本次新增记录；传入 nil 时不追加文本日志。
    /// - Throws: 编码或文件写入失败时抛出错误。
    func saveRecords_confuse(
        _ records_confuse: [MonitoringRecord_confuse],
        latestRecord_confuse: MonitoringRecord_confuse? = nil
    ) throws {
        let retainedRecords_confuse = Array(records_confuse.suffix(1000))
        let encoder_confuse = JSONEncoder()
        encoder_confuse.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let data_confuse = try encoder_confuse.encode(retainedRecords_confuse)
        try data_confuse.write(to: recordsURL_confuse, options: [.atomic])
        try setPrivatePermissions_confuse(url_confuse: recordsURL_confuse)
        if let latestRecord_confuse {
            try appendLegacyLog_confuse(record_confuse: latestRecord_confuse)
        }
    }

    /// 将用户选择的 `.p8` 私钥复制到受管 keys 目录。
    /// - Parameters:
    ///   - sourceURL_confuse: 原始私钥文件 URL。
    ///   - appID_confuse: Apple 数字 App ID。
    ///   - keyID_confuse: App Store Connect Key ID。
    /// - Returns: 受管私钥副本 URL。
    /// - Throws: 文件无效、复制失败或权限设置失败时抛出错误。
    func importPrivateKey_confuse(
        sourceURL_confuse: URL,
        appID_confuse: String,
        keyID_confuse: String
    ) throws -> URL {
        guard sourceURL_confuse.pathExtension.lowercased() == "p8",
              fileManager_confuse.fileExists(atPath: sourceURL_confuse.path) else {
            throw NSError(
                domain: "MonitoringStorage_confuse",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "请选择有效的 .p8 私钥文件。"]
            )
        }
        let safeKeyID_confuse = keyID_confuse.filter { character_confuse in
            character_confuse.isLetter || character_confuse.isNumber || character_confuse == "-" || character_confuse == "_"
        }
        let destinationURL_confuse = keysURL_confuse
            .appendingPathComponent("AuthKey_\(safeKeyID_confuse)_\(appID_confuse).p8")
        if sourceURL_confuse.standardizedFileURL != destinationURL_confuse.standardizedFileURL {
            if fileManager_confuse.fileExists(atPath: destinationURL_confuse.path) {
                try fileManager_confuse.removeItem(at: destinationURL_confuse)
            }
            try fileManager_confuse.copyItem(at: sourceURL_confuse, to: destinationURL_confuse)
        }
        try setPrivatePermissions_confuse(url_confuse: destinationURL_confuse)
        return destinationURL_confuse
    }

    /// 创建数据根目录及 keys、logs、backups 子目录并验证可写性。
    /// - Throws: 任意目录无法创建或写入时抛出错误。
    private func ensureDirectories_confuse() throws {
        for directoryURL_confuse in [rootURL_confuse, keysURL_confuse, logsURL_confuse, backupsURL_confuse] {
            try fileManager_confuse.createDirectory(
                at: directoryURL_confuse,
                withIntermediateDirectories: true,
                attributes: [.posixPermissions: 0o700]
            )
            try fileManager_confuse.setAttributes([.posixPermissions: 0o700], ofItemAtPath: directoryURL_confuse.path)
        }
        let probeURL_confuse = rootURL_confuse.appendingPathComponent(".write-test")
        try Data("ok".utf8).write(to: probeURL_confuse, options: [.atomic])
        try fileManager_confuse.removeItem(at: probeURL_confuse)
    }

    /// 备份现有配置并清理超出十份的旧备份。
    /// - Throws: 复制或清理备份失败时抛出错误。
    private func backupConfiguration_confuse() throws {
        guard fileManager_confuse.fileExists(atPath: configurationURL_confuse.path) else { return }
        let formatter_confuse = DateFormatter()
        formatter_confuse.dateFormat = "yyyyMMdd-HHmmss-SSS"
        let backupURL_confuse = backupsURL_confuse
            .appendingPathComponent("config-\(formatter_confuse.string(from: Date())).json")
        try fileManager_confuse.copyItem(at: configurationURL_confuse, to: backupURL_confuse)
        let backupURLs_confuse = try fileManager_confuse.contentsOfDirectory(
            at: backupsURL_confuse,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsHiddenFiles]
        )
        .filter { $0.lastPathComponent.hasPrefix("config-") && $0.pathExtension == "json" }
        .sorted { $0.lastPathComponent > $1.lastPathComponent }
        for staleURL_confuse in backupURLs_confuse.dropFirst(10) {
            try fileManager_confuse.removeItem(at: staleURL_confuse)
        }
    }

    /// 为配置、记录和私钥设置仅当前用户可读写权限。
    /// - Parameter url_confuse: 待设置权限的文件 URL。
    /// - Throws: 权限设置失败时抛出文件系统错误。
    private func setPrivatePermissions_confuse(url_confuse: URL) throws {
        try fileManager_confuse.setAttributes([.posixPermissions: 0o600], ofItemAtPath: url_confuse.path)
    }

    /// 将新增记录追加到旧版 monitor.log 文本日志。
    /// - Parameter record_confuse: 待追加记录。
    /// - Throws: 日志文件创建或写入失败时抛出错误。
    private func appendLegacyLog_confuse(record_confuse: MonitoringRecord_confuse) throws {
        let logURL_confuse = logsURL_confuse.appendingPathComponent("monitor.log")
        let safeEvent_confuse = record_confuse.event_confuse.replacingOccurrences(of: "\n", with: " ")
        let line_confuse = "\(record_confuse.timestamp_confuse) | \(record_confuse.applicationName_confuse) | \(safeEvent_confuse)\n"
        let data_confuse = Data(line_confuse.utf8)
        if fileManager_confuse.fileExists(atPath: logURL_confuse.path) {
            let handle_confuse = try FileHandle(forWritingTo: logURL_confuse)
            defer { try? handle_confuse.close() }
            try handle_confuse.seekToEnd()
            try handle_confuse.write(contentsOf: data_confuse)
        } else {
            try data_confuse.write(to: logURL_confuse, options: [.atomic])
        }
        try setPrivatePermissions_confuse(url_confuse: logURL_confuse)
    }

    /// 从旧版文本日志构建历史记录。
    /// - Returns: 可在审核记录页面展示的兼容记录。
    /// - Throws: 日志读取失败时抛出错误。
    private func loadLegacyRecords_confuse() throws -> [MonitoringRecord_confuse] {
        let logURL_confuse = logsURL_confuse.appendingPathComponent("monitor.log")
        guard fileManager_confuse.fileExists(atPath: logURL_confuse.path) else { return [] }
        let content_confuse = try String(contentsOf: logURL_confuse, encoding: .utf8)
        return content_confuse.split(separator: "\n").compactMap { line_confuse in
            let parts_confuse = line_confuse.split(separator: "|", maxSplits: 2).map {
                $0.trimmingCharacters(in: .whitespaces)
            }
            guard parts_confuse.count == 3 else { return nil }
            return MonitoringRecord_confuse(
                id: UUID(),
                timestamp_confuse: parts_confuse[0],
                applicationName_confuse: parts_confuse[1],
                appID_confuse: "",
                event_confuse: parts_confuse[2],
                state_confuse: "",
                isError_confuse: parts_confuse[2].localizedCaseInsensitiveContains("error")
            )
        }
    }
}
