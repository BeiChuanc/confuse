import Foundation

/// 读取 Codemagic 所需的项目 Profile 文本。
///
/// 服务按项目目录名称定位应用同级 PROFILE 文件夹，并只解析云端构建需要的
/// IssuerID 和 KeyID，避免让页面层直接处理文件格式和路径规则。
enum CodeMagicProfileService_confuse {
    /// 描述可提交给 Codemagic 的 App Store Connect API 标识。
    struct Credentials_confuse: Sendable {
        let issuerID_confuse: String
        let keyID_confuse: String
    }

    /// 返回项目名称，支持项目文件夹和 `.xcodeproj` 包。
    /// - Parameter projectURL_confuse: 用户选择或拖入的项目 URL。
    /// - Returns: 用于 Profile 文件名和 Codemagic 引用名称的项目名称。
    static func projectName_confuse(projectURL_confuse: URL) -> String {
        let projectFileURL_confuse = primaryProjectFileURL_confuse(projectURL_confuse: projectURL_confuse)
        let rawName_confuse = projectFileURL_confuse?.deletingPathExtension().lastPathComponent
            ?? projectURL_confuse.lastPathComponent
        let invalidCharacters_confuse = CharacterSet(charactersIn: "/\\:*?\"<>|\n\r\t")
        let cleanName_confuse = rawName_confuse
            .components(separatedBy: invalidCharacters_confuse)
            .joined(separator: "_")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return cleanName_confuse.isEmpty ? "项目" : cleanName_confuse
    }

    /// 从项目对应的 Profile 文件中读取 IssuerID 和 KeyID。
    /// - Parameter projectURL_confuse: 用户选择或拖入的项目 URL。
    /// - Returns: Profile 中的 App Store Connect API 标识。
    /// - Throws: 项目无效、Profile 不存在或字段缺失时抛出错误。
    static func readCredentials_confuse(projectURL_confuse: URL) throws -> Credentials_confuse {
        guard isProjectURL_confuse(projectURL_confuse: projectURL_confuse) else {
            throw CodeMagicProfileError_confuse.invalidProject_confuse
        }
        let projectName_confuse = projectName_confuse(projectURL_confuse: projectURL_confuse)
        let profileURL_confuse = ProfileFileService_confuse.profileDirectoryURL_confuse()
            .appendingPathComponent("\(projectName_confuse)_profile.txt")
        guard FileManager.default.fileExists(atPath: profileURL_confuse.path) else {
            throw CodeMagicProfileError_confuse.profileMissing_confuse(profileURL_confuse.path)
        }
        let content_confuse = try String(contentsOf: profileURL_confuse, encoding: .utf8)
        let fields_confuse = fields_confuse(content_confuse: content_confuse)
        let issuerID_confuse = fields_confuse["IssuerID"] ?? ""
        let keyID_confuse = fields_confuse["KeyID"] ?? ""
        guard !issuerID_confuse.isEmpty, !keyID_confuse.isEmpty else {
            throw CodeMagicProfileError_confuse.credentialsMissing_confuse(profileURL_confuse.path)
        }
        return Credentials_confuse(
            issuerID_confuse: issuerID_confuse,
            keyID_confuse: keyID_confuse
        )
    }

    /// 从项目文件中读取用于匹配 Provisioning Profile 的 Bundle ID。
    /// - Parameter projectURL_confuse: 用户选择或拖入的项目 URL。
    /// - Returns: 项目中的 PRODUCT_BUNDLE_IDENTIFIER；无法识别时返回空字符串。
    static func bundleID_confuse(projectURL_confuse: URL) -> String {
        if let projectFileURL_confuse = primaryProjectFileURL_confuse(projectURL_confuse: projectURL_confuse),
           let bundleID_confuse = bundleIDFromProjectFile_confuse(projectFileURL_confuse: projectFileURL_confuse) {
            return bundleID_confuse
        }
        let rootURL_confuse = projectURL_confuse.pathExtension.lowercased() == "xcodeproj"
            ? projectURL_confuse.deletingLastPathComponent()
            : projectURL_confuse
        guard let enumerator_confuse = FileManager.default.enumerator(
            at: rootURL_confuse,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else { return "" }
        for case let fileURL_confuse as URL in enumerator_confuse {
            guard fileURL_confuse.lastPathComponent == "project.pbxproj" else { continue }
            let xcodeProjectURL_confuse = fileURL_confuse.deletingLastPathComponent()
            if let bundleID_confuse = bundleIDFromProjectFile_confuse(
                projectFileURL_confuse: xcodeProjectURL_confuse
            ) {
                return bundleID_confuse
            }
        }
        return ""
    }

    /// 返回用户选择项所对应的主要 Xcode 工程包。
    /// - Parameter projectURL_confuse: 项目文件夹或 `.xcodeproj` URL。
    /// - Returns: 明确选择的工程包，或项目目录直属的首个工程包。
    private static func primaryProjectFileURL_confuse(projectURL_confuse: URL) -> URL? {
        if projectURL_confuse.pathExtension.lowercased() == "xcodeproj" {
            return projectURL_confuse
        }
        let children_confuse = try? FileManager.default.contentsOfDirectory(
            at: projectURL_confuse,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )
        return children_confuse?
            .filter { $0.pathExtension.lowercased() == "xcodeproj" }
            .sorted { $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending }
            .first
    }

    /// 从指定 Xcode 工程包的 pbxproj 文件读取 Bundle ID。
    /// - Parameter projectFileURL_confuse: `.xcodeproj` 工程包 URL。
    /// - Returns: 首个有效 PRODUCT_BUNDLE_IDENTIFIER；字段不存在时返回空值。
    private static func bundleIDFromProjectFile_confuse(projectFileURL_confuse: URL) -> String? {
        let configurationURL_confuse = projectFileURL_confuse.appendingPathComponent("project.pbxproj")
        guard let content_confuse = try? String(contentsOf: configurationURL_confuse, encoding: .utf8) else {
            return nil
        }
        let pattern_confuse = "PRODUCT_BUNDLE_IDENTIFIER\\s*=\\s*([^;]+);"
        guard let range_confuse = content_confuse.range(of: pattern_confuse, options: .regularExpression) else {
            return nil
        }
        let assignment_confuse = String(content_confuse[range_confuse])
        guard let equalIndex_confuse = assignment_confuse.firstIndex(of: "=") else { return nil }
        let value_confuse = String(assignment_confuse[assignment_confuse.index(after: equalIndex_confuse)...])
            .replacingOccurrences(of: ";", with: "")
            .replacingOccurrences(of: "\"", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return value_confuse.isEmpty ? nil : value_confuse
    }

    /// 判断用户选择的 URL 是否为文件夹或 Xcode 工程包。
    /// - Parameter projectURL_confuse: 待判断的项目 URL。
    /// - Returns: 为可处理项目时返回 true。
    private static func isProjectURL_confuse(projectURL_confuse: URL) -> Bool {
        if projectURL_confuse.pathExtension.lowercased() == "xcodeproj" {
            return true
        }
        var isDirectory_confuse: ObjCBool = false
        return FileManager.default.fileExists(
            atPath: projectURL_confuse.path,
            isDirectory: &isDirectory_confuse
        ) && isDirectory_confuse.boolValue
    }

    /// 将 Profile 文本按字段名解析成字典。
    /// - Parameter content_confuse: Profile 文件文本。
    /// - Returns: 字段名到字段值的映射。
    private static func fields_confuse(content_confuse: String) -> [String: String] {
        var result_confuse: [String: String] = [:]
        for line_confuse in content_confuse.components(separatedBy: .newlines) {
            let parts_confuse = line_confuse.split(
                maxSplits: 1,
                whereSeparator: { $0 == ":" || $0 == "=" || $0 == "：" }
            )
            guard parts_confuse.count == 2 else { continue }
            let key_confuse = String(parts_confuse[0]).trimmingCharacters(in: .whitespacesAndNewlines)
            let value_confuse = String(parts_confuse[1]).trimmingCharacters(in: .whitespacesAndNewlines)
            if !key_confuse.isEmpty { result_confuse[key_confuse] = value_confuse }
        }
        return result_confuse
    }
}

/// 描述读取 Codemagic Profile 时的可恢复错误。
enum CodeMagicProfileError_confuse: LocalizedError {
    case invalidProject_confuse
    case profileMissing_confuse(String)
    case credentialsMissing_confuse(String)

    /// 返回可以直接展示给用户的错误说明。
    var errorDescription: String? {
        switch self {
        case .invalidProject_confuse:
            return "选择的内容不是有效的项目文件夹或 Xcode 工程。"
        case .profileMissing_confuse(let path_confuse):
            return "未找到项目 Profile 文件：\(path_confuse)"
        case .credentialsMissing_confuse(let path_confuse):
            return "项目 Profile 文件缺少 IssuerID 或 KeyID：\(path_confuse)"
        }
    }
}
