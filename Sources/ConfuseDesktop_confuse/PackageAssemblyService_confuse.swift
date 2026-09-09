import Foundation

/// 负责定位应用同级 PACKAGE 目录，并按语言和合包类型读取可用代码文件。
///
/// 当前服务只完成目录扫描和文件清单返回，不执行代码合包，便于后续接入具体合包流程。
final class PackageAssemblyService_confuse: Sendable {
    /// 返回打包应用同级的 PACKAGE 目录。
    /// - Returns: `Confuse.app` 同级的 PACKAGE 文件夹；非应用环境下返回当前目录中的 PACKAGE。
    static func packageDirectoryURL_confuse() -> URL {
        let bundleURL_confuse = Bundle.main.bundleURL
        if bundleURL_confuse.pathExtension.lowercased() == "app" {
            return bundleURL_confuse
                .deletingLastPathComponent()
                .appendingPathComponent("PACKAGE", isDirectory: true)
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent("PACKAGE", isDirectory: true)
    }

    /// 按语言和合包类型扫描 PACKAGE 中匹配的普通文件。
    /// - Parameters:
    ///   - language_confuse: 选择的项目语言。
    ///   - type_confuse: 选择的合包类型。
    /// - Returns: 按路径排序的匹配文件 URL；目录不存在或没有匹配时返回空数组。
    static func matchingFiles_confuse(
        language_confuse: PackageLanguage_confuse,
        type_confuse: PackageType_confuse
    ) -> [URL] {
        let directoryURL_confuse = packageDirectoryURL_confuse()
        guard let enumerator_confuse = FileManager.default.enumerator(
            at: directoryURL_confuse,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        let languageKey_confuse = language_confuse.rawValue.lowercased()
        let typeKey_confuse = type_confuse.rawValue.lowercased().replacingOccurrences(of: " ", with: "")
        return enumerator_confuse.compactMap { item_confuse in
            guard let fileURL_confuse = item_confuse as? URL,
                  (try? fileURL_confuse.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) == true else {
                return nil
            }
            let normalizedPath_confuse = fileURL_confuse.path
                .lowercased()
                .replacingOccurrences(of: " ", with: "")
            guard normalizedPath_confuse.contains(languageKey_confuse),
                  normalizedPath_confuse.contains(typeKey_confuse) else {
                return nil
            }
            return fileURL_confuse
        }
        .sorted { $0.path.localizedStandardCompare($1.path) == .orderedAscending }
    }
}
