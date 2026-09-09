import Foundation

/// 根据整理资料和协议结果生成项目 profile 文本，并保存到应用同级 PROFILE 目录。
///
/// 文件字段顺序和分隔标记沿用用户提供的 profile 模板；当前资料中没有对应值的字段保留为空，
/// 这样后续流程仍可继续补充同一个文本文件。
enum ProfileFileService_confuse {
    /// 返回打包应用同级的 PROFILE 目录。
    /// - Returns: `Confuse.app` 同级的 PROFILE 文件夹；非应用环境下返回当前目录中的 PROFILE。
    static func profileDirectoryURL_confuse() -> URL {
        let bundleURL_confuse = Bundle.main.bundleURL
        if bundleURL_confuse.pathExtension.lowercased() == "app" {
            return bundleURL_confuse
                .deletingLastPathComponent()
                .appendingPathComponent("PROFILE", isDirectory: true)
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent("PROFILE", isDirectory: true)
    }

    /// 生成并保存一个项目 profile 文件。
    /// - Parameters:
    ///   - record_confuse: 整理资料读取到的项目记录。
    ///   - agreementLinks_confuse: 已生成的协议链接，可以为空。
    /// - Returns: 写入完成的 profile 文件 URL。
    /// - Throws: PROFILE 目录无法创建、文件名无效或文本无法写入时抛出错误。
    static func writeProfile_confuse(
        record_confuse: MaterialRecord_confuse,
        agreementLinks_confuse: [AgreementType_confuse: String]
    ) throws -> URL {
        let directoryURL_confuse = profileDirectoryURL_confuse()
        try FileManager.default.createDirectory(
            at: directoryURL_confuse,
            withIntermediateDirectories: true
        )
        try? FileManager.default.setAttributes(
            [.posixPermissions: 0o700],
            ofItemAtPath: directoryURL_confuse.path
        )

        let projectName_confuse = sanitizedProjectName_confuse(
            value_confuse: record_confuse.softwareName_confuse.isEmpty
                ? record_confuse.uiNumber_confuse
                : record_confuse.softwareName_confuse
        )
        let fileURL_confuse = directoryURL_confuse
            .appendingPathComponent("\(projectName_confuse)_profile.txt")
        let content_confuse = profileContent_confuse(
            record_confuse: record_confuse,
            agreementLinks_confuse: agreementLinks_confuse
        )
        try content_confuse.write(to: fileURL_confuse, atomically: true, encoding: .utf8)
        try? FileManager.default.setAttributes(
            [.posixPermissions: 0o600],
            ofItemAtPath: fileURL_confuse.path
        )
        return fileURL_confuse
    }

    /// 按模板顺序构建 profile 文本。
    /// - Parameters:
    ///   - record_confuse: 项目资料记录。
    ///   - agreementLinks_confuse: 协议类型到链接的映射。
    /// - Returns: 可直接写入 txt 文件的 UTF-8 文本。
    private static func profileContent_confuse(
        record_confuse: MaterialRecord_confuse,
        agreementLinks_confuse: [AgreementType_confuse: String]
    ) -> String {
        let credential_confuse = reviewCredentials_confuse(
            value_confuse: record_confuse.storeReviewCredential_confuse
        )
        let developerEmail_confuse = extractEmail_confuse(
            value_confuse: record_confuse.developerAccount_confuse
        )
        let developerName_confuse = record_confuse.developerAccount_confuse.contains("@")
            ? ""
            : record_confuse.developerAccount_confuse

        let description_confuse = record_confuse.softwareName_confuse.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        return """
        ***Description-start***
        \(description_confuse)
        ***Description-end***

        PrivacyURL: \(agreementLinks_confuse[.privacy_confuse] ?? "")
        TermsURL: \(agreementLinks_confuse[.terms_confuse] ?? "")
        EULAURL: \(agreementLinks_confuse[.eula_confuse] ?? "")
        Keywords: 

        VersionString: 
        Copyright: 

        IssuerID: 
        KeyID: 
        APPID: \(record_confuse.appID_confuse)
        TeamID: 

        Name: \(developerName_confuse)
        Phone: \(record_confuse.phoneNumber_confuse)
        Email: \(developerEmail_confuse)
        TestUsername: \(credential_confuse.username_confuse)
        TestPassword: \(credential_confuse.password_confuse)
        """
    }

    /// 从商店审核账号字段中提取测试账号和密码。
    /// - Parameter value_confuse: 飞书返回的商店审核账号密码原始文本。
    /// - Returns: 按模板字段拆分后的账号和密码。
    private static func reviewCredentials_confuse(value_confuse: String) -> (username_confuse: String, password_confuse: String) {
        let lines_confuse = value_confuse
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        var username_confuse = ""
        var password_confuse = ""
        for line_confuse in lines_confuse {
            let lowerLine_confuse = line_confuse.lowercased()
            if lowerLine_confuse.contains("username") || lowerLine_confuse.contains("账号") {
                username_confuse = valueAfterSeparator_confuse(line_confuse: line_confuse)
            } else if lowerLine_confuse.contains("password") || lowerLine_confuse.contains("密码") {
                password_confuse = valueAfterSeparator_confuse(line_confuse: line_confuse)
            }
        }
        if username_confuse.isEmpty, password_confuse.isEmpty, lines_confuse.count >= 2 {
            username_confuse = lines_confuse[0]
            password_confuse = lines_confuse[1]
        }
        if username_confuse.isEmpty, password_confuse.isEmpty {
            let values_confuse = value_confuse.split(whereSeparator: { $0 == " " || $0 == "\t" })
            if values_confuse.count >= 2 {
                username_confuse = String(values_confuse[0])
                password_confuse = String(values_confuse[1])
            }
        }
        return (username_confuse, password_confuse)
    }

    /// 读取一行字段分隔符后的值。
    /// - Parameter line_confuse: 包含字段名和值的文本行。
    /// - Returns: 去除字段名和空白后的值。
    private static func valueAfterSeparator_confuse(line_confuse: String) -> String {
        let separators_confuse: [Character] = [":", "=", "："]
        guard let separator_confuse = line_confuse.firstIndex(where: { separators_confuse.contains($0) }) else {
            return line_confuse
        }
        return String(line_confuse[line_confuse.index(after: separator_confuse)...])
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// 从开发者账号字段中提取邮箱地址。
    /// - Parameter value_confuse: 开发者账号原始文本。
    /// - Returns: 提取到的邮箱或空字符串。
    private static func extractEmail_confuse(value_confuse: String) -> String {
        let pattern_confuse = "[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}"
        guard let range_confuse = value_confuse.range(
            of: pattern_confuse,
            options: [.regularExpression, .caseInsensitive]
        ) else {
            return ""
        }
        return String(value_confuse[range_confuse])
    }

    /// 清理项目名，确保可以安全用于 profile 文件名。
    /// - Parameter value_confuse: 原始项目名。
    /// - Returns: 不包含路径分隔符和控制字符的文件名主体。
    private static func sanitizedProjectName_confuse(value_confuse: String) -> String {
        let invalidCharacters_confuse = CharacterSet(charactersIn: "/\\:*?\"<>|\n\r\t")
        let sanitized_confuse = value_confuse
            .components(separatedBy: invalidCharacters_confuse)
            .joined(separator: "_")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return sanitized_confuse.isEmpty ? "项目" : sanitized_confuse
    }
}
