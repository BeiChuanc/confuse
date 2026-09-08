import Foundation

/// 负责识别工程类别、工程名称和可用于混淆的项目后缀。
final class ProjectScanner_confuse {
    /// 根据工程根目录识别 Swift 或 Flutter 项目。
    /// - Parameter projectURL_confuse: 待识别的工程目录。
    /// - Returns: 识别出的工程类别；无法识别时返回 nil。
    static func detectType_confuse(projectURL_confuse: URL) -> ProjectType_confuse? {
        let fileManager_confuse = FileManager.default
        let pubspecURL_confuse = projectURL_confuse.appendingPathComponent("pubspec.yaml")
        if fileManager_confuse.fileExists(atPath: pubspecURL_confuse.path) {
            return .flutter_confuse
        }

        let children_confuse = (try? fileManager_confuse.contentsOfDirectory(
            at: projectURL_confuse,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        )) ?? []
        if children_confuse.contains(where: { $0.pathExtension == "xcodeproj" }) {
            return .swift_confuse
        }
        if containsFile_confuse(projectURL_confuse: projectURL_confuse, extension_confuse: "swift") {
            return .swift_confuse
        }
        return nil
    }

    /// 读取工程配置并生成与原混淆脚本兼容的后缀集合。
    /// - Parameters:
    ///   - projectURL_confuse: 工程根目录。
    ///   - projectType_confuse: 工程类别。
    /// - Returns: 工程名称以及用于匹配的后缀集合。
    static func configuration_confuse(
        projectURL_confuse: URL,
        projectType_confuse: ProjectType_confuse
    ) -> (name_confuse: String, suffixes_confuse: [String]) {
        let fileManager_confuse = FileManager.default
        var projectName_confuse = projectURL_confuse.lastPathComponent

        if projectType_confuse == .flutter_confuse {
            let pubspecURL_confuse = projectURL_confuse.appendingPathComponent("pubspec.yaml")
            if let content_confuse = try? String(contentsOf: pubspecURL_confuse, encoding: .utf8),
               let nameLine_confuse = content_confuse.split(separator: "\n").first(where: {
                   $0.trimmingCharacters(in: .whitespaces).hasPrefix("name:")
               }) {
                projectName_confuse = nameLine_confuse
                    .split(separator: ":", maxSplits: 1)
                    .last?
                    .trimmingCharacters(in: .whitespacesAndNewlines) ?? projectName_confuse
            }
            return (projectName_confuse, ["_\(projectName_confuse)"])
        }

        let children_confuse = (try? fileManager_confuse.contentsOfDirectory(
            at: projectURL_confuse,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        )) ?? []
        if let xcodeprojURL_confuse = children_confuse.first(where: { $0.pathExtension == "xcodeproj" }) {
            projectName_confuse = xcodeprojURL_confuse.deletingPathExtension().lastPathComponent
        }

        let capitalizedLower_confuse = projectName_confuse.isEmpty
            ? projectName_confuse
            : projectName_confuse.prefix(1).uppercased() + projectName_confuse.dropFirst().lowercased()
        return (
            projectName_confuse,
            ["_\(projectName_confuse)", "_\(projectName_confuse.lowercased())", "_\(capitalizedLower_confuse)"]
        )
    }

    /// 在工程目录中递归查找指定后缀文件。
    /// - Parameters:
    ///   - projectURL_confuse: 待扫描的目录。
    ///   - extension_confuse: 不含点号的文件后缀。
    /// - Returns: 是否找到匹配文件。
    private static func containsFile_confuse(
        projectURL_confuse: URL,
        extension_confuse: String
    ) -> Bool {
        let enumerator_confuse = FileManager.default.enumerator(
            at: projectURL_confuse,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        )
        while let item_confuse = enumerator_confuse?.nextObject() as? URL {
            if item_confuse.pathExtension == extension_confuse {
                return true
            }
        }
        return false
    }
}
