import Foundation

/// 从资料文件夹中安全提取 App ID、Issuer ID、Key ID 和匹配的 `.p8` 私钥。
enum MonitoringProfileService_confuse {
    private static let PROFILE_EXTENSIONS_CONFUSE: Set<String> = [
        "txt", "json", "plist", "mobileprovision", "provisionprofile"
    ]

    /// 扫描资料文件夹并返回完整凭证字段。
    /// - Parameter folderURL_confuse: 包含 profile 与 `.p8` 文件的目录。
    /// - Returns: 经过白名单提取和私钥匹配的资料结果。
    /// - Throws: 目录无效、字段缺失、存在歧义或私钥缺失时抛出错误。
    static func readFolder_confuse(folderURL_confuse: URL) throws -> MonitoringProfileResult_confuse {
        var isDirectory_confuse: ObjCBool = false
        guard FileManager.default.fileExists(atPath: folderURL_confuse.path, isDirectory: &isDirectory_confuse),
              isDirectory_confuse.boolValue else {
            throw error_confuse(message_confuse: "请选择有效的资料文件夹。")
        }

        let allFiles_confuse = recursiveFiles_confuse(folderURL_confuse: folderURL_confuse)
        let profileFiles_confuse = allFiles_confuse.filter {
            PROFILE_EXTENSIONS_CONFUSE.contains($0.pathExtension.lowercased())
        }
        let parsedProfiles_confuse = profileFiles_confuse.compactMap { profileURL_confuse -> (URL, [String: String])? in
            let fields_confuse = readFields_confuse(profileURL_confuse: profileURL_confuse)
            return fields_confuse.isEmpty ? nil : (profileURL_confuse, fields_confuse)
        }
        guard !parsedProfiles_confuse.isEmpty else {
            throw error_confuse(message_confuse: "没有找到包含应用编号、发行者编号或密钥编号的资料文件。")
        }

        let completeProfiles_confuse = parsedProfiles_confuse.filter { profile_confuse in
            ["app_id", "issuer_id", "key_id"].allSatisfy { !(profile_confuse.1[$0] ?? "").isEmpty }
        }
        guard completeProfiles_confuse.count <= 1 else {
            throw error_confuse(message_confuse: "检测到多个完整资料文件，请仅保留当前应用的资料文件。")
        }
        let selectedProfile_confuse = completeProfiles_confuse.first ?? parsedProfiles_confuse[0]
        let fields_confuse = selectedProfile_confuse.1
        let missingFields_confuse = [
            ("app_id", "应用编号"),
            ("issuer_id", "发行者编号"),
            ("key_id", "密钥编号")
        ].compactMap { key_confuse, label_confuse in
            (fields_confuse[key_confuse] ?? "").isEmpty ? label_confuse : nil
        }
        guard missingFields_confuse.isEmpty else {
            throw error_confuse(message_confuse: "资料文件缺少字段：\(missingFields_confuse.joined(separator: "、"))。")
        }
        let appID_confuse = fields_confuse["app_id"] ?? ""
        guard appID_confuse.allSatisfy(\.isNumber) else {
            throw error_confuse(message_confuse: "资料文件中的应用编号必须全部为数字。")
        }

        let privateKeys_confuse = allFiles_confuse.filter { $0.pathExtension.lowercased() == "p8" }
        guard !privateKeys_confuse.isEmpty else {
            throw error_confuse(message_confuse: "资料文件夹中没有找到私钥文件。")
        }
        let keyID_confuse = fields_confuse["key_id"] ?? ""
        let matchingKeys_confuse = privateKeys_confuse.filter {
            $0.deletingPathExtension().lastPathComponent.localizedCaseInsensitiveContains(keyID_confuse)
        }
        let selectedKey_confuse: URL
        if matchingKeys_confuse.count == 1 {
            selectedKey_confuse = matchingKeys_confuse[0]
        } else if privateKeys_confuse.count == 1 {
            selectedKey_confuse = privateKeys_confuse[0]
        } else if matchingKeys_confuse.isEmpty {
            throw error_confuse(message_confuse: "检测到多个私钥文件，但没有文件与密钥编号 \(keyID_confuse) 匹配。")
        } else {
            throw error_confuse(message_confuse: "检测到多个与密钥编号 \(keyID_confuse) 匹配的私钥文件。")
        }

        return MonitoringProfileResult_confuse(
            profilePath_confuse: selectedProfile_confuse.0.path,
            privateKeyPath_confuse: selectedKey_confuse.path,
            appID_confuse: appID_confuse,
            issuerID_confuse: fields_confuse["issuer_id"] ?? "",
            keyID_confuse: keyID_confuse
        )
    }

    /// 返回目录中所有非隐藏文件。
    /// - Parameter folderURL_confuse: 扫描根目录。
    /// - Returns: 递归发现的普通文件 URL。
    private static func recursiveFiles_confuse(folderURL_confuse: URL) -> [URL] {
        guard let enumerator_confuse = FileManager.default.enumerator(
            at: folderURL_confuse,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else { return [] }
        return enumerator_confuse.compactMap { item_confuse in
            guard let fileURL_confuse = item_confuse as? URL,
                  (try? fileURL_confuse.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) == true else {
                return nil
            }
            return fileURL_confuse
        }
    }

    /// 根据文件格式读取白名单凭证字段。
    /// - Parameter profileURL_confuse: profile 文件 URL。
    /// - Returns: 仅包含 app_id、issuer_id、key_id 的字典。
    private static func readFields_confuse(profileURL_confuse: URL) -> [String: String] {
        guard let attributes_confuse = try? FileManager.default.attributesOfItem(atPath: profileURL_confuse.path),
              let size_confuse = attributes_confuse[.size] as? NSNumber,
              size_confuse.intValue <= 2 * 1024 * 1024 else { return [:] }
        let extension_confuse = profileURL_confuse.pathExtension.lowercased()
        do {
            switch extension_confuse {
            case "json":
                let object_confuse = try JSONSerialization.jsonObject(with: Data(contentsOf: profileURL_confuse))
                return fieldsFromMapping_confuse(object_confuse: object_confuse)
            case "plist":
                let object_confuse = try PropertyListSerialization.propertyList(
                    from: Data(contentsOf: profileURL_confuse),
                    options: [],
                    format: nil
                )
                return fieldsFromMapping_confuse(object_confuse: object_confuse)
            case "mobileprovision", "provisionprofile":
                return fieldsFromProvisioningProfile_confuse(profileURL_confuse: profileURL_confuse)
            default:
                let text_confuse = try String(contentsOf: profileURL_confuse, encoding: .utf8)
                return fieldsFromText_confuse(text_confuse: text_confuse)
            }
        } catch {
            return [:]
        }
    }

    /// 解码 provisioning profile 后读取白名单字段。
    /// - Parameter profileURL_confuse: provisioning profile 文件 URL。
    /// - Returns: 解码成功时返回白名单字段，否则返回空字典。
    private static func fieldsFromProvisioningProfile_confuse(profileURL_confuse: URL) -> [String: String] {
        let process_confuse = Process()
        let outputPipe_confuse = Pipe()
        process_confuse.executableURL = URL(fileURLWithPath: "/usr/bin/security")
        process_confuse.arguments = ["cms", "-D", "-i", profileURL_confuse.path]
        process_confuse.standardOutput = outputPipe_confuse
        process_confuse.standardError = Pipe()
        do {
            try process_confuse.run()
            process_confuse.waitUntilExit()
            guard process_confuse.terminationStatus == 0 else { return [:] }
            let data_confuse = outputPipe_confuse.fileHandleForReading.readDataToEndOfFile()
            let object_confuse = try PropertyListSerialization.propertyList(from: data_confuse, options: [], format: nil)
            return fieldsFromMapping_confuse(object_confuse: object_confuse)
        } catch {
            return [:]
        }
    }

    /// 从文本行中提取白名单凭证字段。
    /// - Parameter text_confuse: profile 文本内容。
    /// - Returns: 标准字段名称到字段值的映射。
    private static func fieldsFromText_confuse(text_confuse: String) -> [String: String] {
        var fields_confuse: [String: String] = [:]
        for line_confuse in text_confuse.components(separatedBy: .newlines) {
            let separators_confuse = [":", "="]
            guard let separator_confuse = separators_confuse.compactMap({ line_confuse.firstIndex(of: Character($0)) }).min() else {
                continue
            }
            let rawKey_confuse = String(line_confuse[..<separator_confuse])
            let valueStart_confuse = line_confuse.index(after: separator_confuse)
            let rawValue_confuse = String(line_confuse[valueStart_confuse...])
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
            if let key_confuse = mappedFieldName_confuse(rawName_confuse: rawKey_confuse), !rawValue_confuse.isEmpty {
                fields_confuse[key_confuse] = rawValue_confuse
            }
        }
        return fields_confuse
    }

    /// 从 JSON 或 plist 根字典中提取白名单凭证字段。
    /// - Parameter object_confuse: 已解析的结构化对象。
    /// - Returns: 标准字段名称到字段值的映射。
    private static func fieldsFromMapping_confuse(object_confuse: Any) -> [String: String] {
        guard let mapping_confuse = object_confuse as? [String: Any] else { return [:] }
        var fields_confuse: [String: String] = [:]
        for (rawKey_confuse, value_confuse) in mapping_confuse {
            guard let key_confuse = mappedFieldName_confuse(rawName_confuse: rawKey_confuse) else { continue }
            if let string_confuse = value_confuse as? String {
                fields_confuse[key_confuse] = string_confuse.trimmingCharacters(in: .whitespacesAndNewlines)
            } else if let number_confuse = value_confuse as? NSNumber {
                fields_confuse[key_confuse] = number_confuse.stringValue
            }
        }
        return fields_confuse
    }

    /// 将不同书写形式的字段名映射到标准白名单名称。
    /// - Parameter rawName_confuse: 原始字段名称。
    /// - Returns: 支持的标准名称，不支持时返回 nil。
    private static func mappedFieldName_confuse(rawName_confuse: String) -> String? {
        let normalizedName_confuse = rawName_confuse.lowercased().filter(\.isLetter)
        switch normalizedName_confuse {
        case "appid", "applicationid": return "app_id"
        case "issuerid": return "issuer_id"
        case "keyid": return "key_id"
        default: return nil
        }
    }

    /// 创建统一的资料读取错误。
    /// - Parameter message_confuse: 面向用户的错误说明。
    /// - Returns: 带有本地化文本的错误对象。
    private static func error_confuse(message_confuse: String) -> Error {
        NSError(
            domain: "MonitoringProfileService_confuse",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: message_confuse]
        )
    }
}
