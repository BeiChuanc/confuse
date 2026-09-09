import Foundation

/// 执行 Swift 合包整理的文件和工程配置操作。
///
/// 服务负责读取 PACKAGE 中的合包代码，更新目标工程的 Podfile、源码引用、
/// AppDelegate.swift、Info.plist，并通过进度回调向界面报告每个阶段的结果。
enum SwiftPackageAssemblyService_confuse {
    /// 保存合包前单个受管文件的原始状态，用于失败回滚。
    private struct FileSnapshot_confuse {
        let url_confuse: URL
        let data_confuse: Data?
    }

    /// 合包要求的源码文件名称。
    private static let REQUIRED_SOURCE_NAMES_CONFUSE = [
        "BendoBaseDefaultViewController.swift",
        "BendoBaseShare.swift",
        "BendoExtension.swift"
    ]

    /// 合包要求检查的 CocoaPods 依赖名称。
    private static let REQUIRED_POD_NAMES_CONFUSE = [
        "SVProgressHUD",
        "FBSDKLoginKit",
        "FirebaseCore",
        "FirebaseAnalytics",
        "MBProgressHUD"
    ]

    /// 创建 Swift 合包前的目标工程和代码检查结果。
    /// - Parameters:
    ///   - targetURL_confuse: 用户选择的工程目录或 xcodeproj 路径。
    ///   - type_confuse: 当前合包类型。
    ///   - packageRootURL_confuse: 可选 PACKAGE 根目录，测试或独立调用时使用。
    /// - Returns: 目标工程与 PACKAGE 代码检查结果。
    /// - Throws: 目标不是有效 Swift 工程或 PACKAGE 目录无法读取时抛出错误。
    static func inspect_confuse(
        targetURL_confuse: URL,
        type_confuse: PackageType_confuse,
        packageRootURL_confuse: URL? = nil
    ) throws -> SwiftPackageInspection_confuse {
        let targetRootURL_confuse = try targetRootURL_confuse(targetURL_confuse: targetURL_confuse)
        let appDelegateURL_confuse = try findRequiredFile_confuse(
            name_confuse: "AppDelegate.swift",
            rootURL_confuse: targetRootURL_confuse,
            missingMessage_confuse: "目标 Swift 项目中未找到 AppDelegate.swift。"
        )
        let targetPodfileURL_confuse = findFirstFile_confuse(
            name_confuse: "Podfile",
            rootURL_confuse: targetRootURL_confuse
        )
        let projectFileURL_confuse = try projectFileURL_confuse(rootURL_confuse: targetRootURL_confuse)
        let bundleID_confuse = try bundleID_confuse(projectFileURL_confuse: projectFileURL_confuse)
        let packageDirectoryURL_confuse = (packageRootURL_confuse
            ?? PackageAssemblyService_confuse.packageDirectoryURL_confuse())
            .appendingPathComponent("Swift", isDirectory: true)
            .appendingPathComponent(type_confuse.rawValue, isDirectory: true)
        let packageFiles_confuse = regularFiles_confuse(rootURL_confuse: packageDirectoryURL_confuse)
        let packagePodfileURL_confuse = packageFiles_confuse.first {
            $0.lastPathComponent.caseInsensitiveCompare("Podfile") == .orderedSame
        }
        let sourceFiles_confuse = REQUIRED_SOURCE_NAMES_CONFUSE.map { name_confuse in
            packageFiles_confuse.first {
                $0.lastPathComponent.caseInsensitiveCompare(name_confuse) == .orderedSame
            }
        }
        let packageAppDelegateURL_confuse = packageFiles_confuse.first {
            $0.lastPathComponent.caseInsensitiveCompare("AppDelegate.swift") == .orderedSame
        }
        let missingPackageFiles_confuse = sourceFiles_confuse.enumerated().compactMap { index_confuse, fileURL_confuse in
            fileURL_confuse == nil ? REQUIRED_SOURCE_NAMES_CONFUSE[index_confuse] : nil
        } + (packagePodfileURL_confuse == nil ? ["Podfile"] : [])
            + (packageAppDelegateURL_confuse == nil ? ["AppDelegate.swift"] : [])
        let hasFacebook_confuse = hasFacebookCode_confuse(
            packageFiles_confuse: packageFiles_confuse,
            packagePodfileURL_confuse: packagePodfileURL_confuse
        )

        return SwiftPackageInspection_confuse(
            targetRootPath_confuse: targetRootURL_confuse.path,
            appDelegatePath_confuse: appDelegateURL_confuse.path,
            targetPodfilePath_confuse: targetPodfileURL_confuse?.path ?? "",
            bundleID_confuse: bundleID_confuse,
            packageFiles_confuse: packageFiles_confuse.map(\.path),
            missingPackageFiles_confuse: missingPackageFiles_confuse,
            hasFacebook_confuse: hasFacebook_confuse
        )
    }

    /// 执行 Swift 合包整理的全部步骤。
    /// - Parameters:
    ///   - targetURL_confuse: 用户选择的工程目录或 xcodeproj 路径。
    ///   - type_confuse: 当前合包类型。
    ///   - backendConfiguration_confuse: 从后台读取并与目标 Bundle ID 匹配的合包配置。
    ///   - packageRootURL_confuse: 可选 PACKAGE 根目录，测试或独立调用时使用。
    ///   - progressHandler_confuse: 合包进度回调。
    /// - Returns: 处理完成后的目标工程目录。
    /// - Throws: 目标工程、合包代码或任一步骤写入失败时抛出错误。
    static func assemble_confuse(
        targetURL_confuse: URL,
        type_confuse: PackageType_confuse,
        backendConfiguration_confuse: BackendConfiguration_confuse,
        packageRootURL_confuse: URL? = nil,
        progressHandler_confuse: @escaping (PackageAssemblyProgress_confuse) -> Void
    ) throws -> URL {
        let inspection_confuse = try inspect_confuse(
            targetURL_confuse: targetURL_confuse,
            type_confuse: type_confuse,
            packageRootURL_confuse: packageRootURL_confuse
        )
        guard inspection_confuse.isReady_confuse else {
            if !inspection_confuse.targetPodfilePath_confuse.isEmpty {
                throw SwiftPackageAssemblyError_confuse.missingPackageFiles_confuse(
                    inspection_confuse.missingPackageFiles_confuse
                )
            }
            throw SwiftPackageAssemblyError_confuse.targetPodfileMissing_confuse
        }
        guard backendConfiguration_confuse.bundleID_confuse == inspection_confuse.bundleID_confuse else {
            throw SwiftPackageAssemblyError_confuse.message_confuse(
                "后台配置的 Bundle ID 与目标项目不一致，请重新获取后台配置。"
            )
        }

        let targetRootURL_confuse = URL(fileURLWithPath: inspection_confuse.targetRootPath_confuse, isDirectory: true)
        let appDelegateURL_confuse = URL(fileURLWithPath: inspection_confuse.appDelegatePath_confuse)
        let targetPodfileURL_confuse = URL(fileURLWithPath: inspection_confuse.targetPodfilePath_confuse)
        let packageDirectoryURL_confuse = (packageRootURL_confuse
            ?? PackageAssemblyService_confuse.packageDirectoryURL_confuse())
            .appendingPathComponent("Swift", isDirectory: true)
            .appendingPathComponent(type_confuse.rawValue, isDirectory: true)
        let packageFiles_confuse = regularFiles_confuse(rootURL_confuse: packageDirectoryURL_confuse)
        let packagePodfileURL_confuse = packageFiles_confuse.first {
            $0.lastPathComponent.caseInsensitiveCompare("Podfile") == .orderedSame
        }!
        let projectFileURL_confuse = try projectFileURL_confuse(rootURL_confuse: targetRootURL_confuse)
        let tabBarClassName_confuse = try tabBarControllerClassName_confuse(rootURL_confuse: targetRootURL_confuse)
        let launchImageName_confuse = try launchImageName_confuse(rootURL_confuse: targetRootURL_confuse)
        let infoURL_confuse = try infoPropertyListURL_confuse(
            rootURL_confuse: targetRootURL_confuse,
            appDelegateURL_confuse: appDelegateURL_confuse
        )
        let appDelegateDirectoryURL_confuse = appDelegateURL_confuse.deletingLastPathComponent()
        let mixDirectoryURL_confuse = appDelegateDirectoryURL_confuse.appendingPathComponent("Mix", isDirectory: true)
        let managedMixURLs_confuse = REQUIRED_SOURCE_NAMES_CONFUSE.map {
            mixDirectoryURL_confuse.appendingPathComponent($0)
        }
        let snapshots_confuse = try fileSnapshots_confuse(
            urls_confuse: [targetPodfileURL_confuse, projectFileURL_confuse, appDelegateURL_confuse, infoURL_confuse]
                + managedMixURLs_confuse
        )

        do {
            progressHandler_confuse(PackageAssemblyProgress_confuse(
                progress_confuse: 0.08,
                detail_confuse: "目标项目和合包代码校验通过。"
            ))
            try mergePodfile_confuse(
                targetURL_confuse: targetPodfileURL_confuse,
                packageURL_confuse: packagePodfileURL_confuse
            )
            progressHandler_confuse(PackageAssemblyProgress_confuse(
                progress_confuse: 0.25,
                detail_confuse: "已添加 Podfile 中缺少的依赖。"
            ))

            let sourceURLs_confuse = REQUIRED_SOURCE_NAMES_CONFUSE.map { name_confuse in
                packageFiles_confuse.first {
                    $0.lastPathComponent.caseInsensitiveCompare(name_confuse) == .orderedSame
                }!
            }
            try FileManager.default.createDirectory(at: mixDirectoryURL_confuse, withIntermediateDirectories: true)
            var copiedURLs_confuse: [URL] = []
            for sourceURL_confuse in sourceURLs_confuse {
                let destinationURL_confuse = mixDirectoryURL_confuse.appendingPathComponent(sourceURL_confuse.lastPathComponent)
                try replaceItem_confuse(sourceURL_confuse: sourceURL_confuse, destinationURL_confuse: destinationURL_confuse)
                copiedURLs_confuse.append(destinationURL_confuse)
            }
            progressHandler_confuse(PackageAssemblyProgress_confuse(
                progress_confuse: 0.45,
                detail_confuse: "已将所需的 Bendo 源文件复制到 Mix。"
            ))

            try registerSwiftFiles_confuse(
                projectFileURL_confuse: projectFileURL_confuse,
                fileURLs_confuse: copiedURLs_confuse
            )
            progressHandler_confuse(PackageAssemblyProgress_confuse(
                progress_confuse: 0.62,
                detail_confuse: "已将 Mix 源文件添加到 Xcode 项目。"
            ))

            let packageAppDelegateURL_confuse = packageFiles_confuse.first {
                $0.lastPathComponent.caseInsensitiveCompare("AppDelegate.swift") == .orderedSame
            }
            try mergeAppDelegate_confuse(
                targetURL_confuse: appDelegateURL_confuse,
                packageURL_confuse: packageAppDelegateURL_confuse,
                backendConfiguration_confuse: backendConfiguration_confuse,
                tabBarClassName_confuse: tabBarClassName_confuse,
                launchImageName_confuse: launchImageName_confuse
            )
            progressHandler_confuse(PackageAssemblyProgress_confuse(
                progress_confuse: 0.78,
                detail_confuse: "已将合包启动代码合并到 AppDelegate。"
            ))

            try updateInfoPropertyList_confuse(
                infoURL_confuse: infoURL_confuse,
                type_confuse: type_confuse,
                backendConfiguration_confuse: backendConfiguration_confuse
            )
            progressHandler_confuse(PackageAssemblyProgress_confuse(
                progress_confuse: 1,
                detail_confuse: "Info.plist 已更新，Swift 合包整理完成。"
            ))
            return targetRootURL_confuse
        } catch {
            try? restoreFileSnapshots_confuse(snapshots_confuse: snapshots_confuse)
            throw error
        }
    }

    /// 将选择路径规范化为包含 xcodeproj 的 Swift 工程目录。
    /// - Parameter targetURL_confuse: 用户选择的目录或 xcodeproj 路径。
    /// - Returns: Swift 工程根目录。
    /// - Throws: 目录不存在或未找到 xcodeproj 时抛出错误。
    private static func targetRootURL_confuse(targetURL_confuse: URL) throws -> URL {
        var rootURL_confuse = targetURL_confuse.standardizedFileURL
        if rootURL_confuse.pathExtension.lowercased() == "xcodeproj" {
            rootURL_confuse.deleteLastPathComponent()
        }
        guard FileManager.default.fileExists(atPath: rootURL_confuse.path),
              findFirstFile_confuse(name_confuse: "project.pbxproj", rootURL_confuse: rootURL_confuse) != nil else {
            throw SwiftPackageAssemblyError_confuse.invalidTargetProject_confuse
        }
        return rootURL_confuse
    }

    /// 从 Xcode 工程配置中读取主应用 Bundle ID。
    /// - Parameter projectFileURL_confuse: project.pbxproj 文件 URL。
    /// - Returns: 去除引号后的主应用 Bundle ID。
    /// - Throws: 工程文件无法读取或不存在有效 Bundle ID 时抛出错误。
    private static func bundleID_confuse(projectFileURL_confuse: URL) throws -> String {
        let content_confuse = try String(contentsOf: projectFileURL_confuse, encoding: .utf8)
        guard let expression_confuse = try? NSRegularExpression(
            pattern: #"PRODUCT_BUNDLE_IDENTIFIER\s*=\s*\"?([^\";\n]+)\"?;"#
        ) else {
            throw SwiftPackageAssemblyError_confuse.message_confuse("无法解析目标项目的 Bundle ID。")
        }
        let matches_confuse = expression_confuse.matches(
            in: content_confuse,
            range: NSRange(content_confuse.startIndex..<content_confuse.endIndex, in: content_confuse)
        )
        let candidates_confuse = matches_confuse.compactMap { match_confuse -> String? in
            guard let range_confuse = Range(match_confuse.range(at: 1), in: content_confuse) else { return nil }
            let value_confuse = String(content_confuse[range_confuse])
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return value_confuse.contains("$(") || value_confuse.localizedCaseInsensitiveContains("Tests")
                ? nil
                : value_confuse
        }
        guard let bundleID_confuse = candidates_confuse.first, bundleID_confuse.contains(".") else {
            throw SwiftPackageAssemblyError_confuse.message_confuse("目标项目中未找到有效的 Bundle ID。")
        }
        return bundleID_confuse
    }

    /// 在目标 Swift 源码中识别底部导航控制器类名。
    /// - Parameter rootURL_confuse: 目标项目根目录。
    /// - Returns: 继承 UITabBarController 的首个业务类名。
    /// - Throws: 项目中不存在底部导航控制器时抛出错误。
    private static func tabBarControllerClassName_confuse(rootURL_confuse: URL) throws -> String {
        guard let expression_confuse = try? NSRegularExpression(
            pattern: #"class\s+([A-Za-z_][A-Za-z0-9_]*)\s*:\s*UITabBarController"#
        ) else {
            throw SwiftPackageAssemblyError_confuse.message_confuse("无法创建底部导航控制器解析规则。")
        }
        for fileURL_confuse in regularFiles_confuse(rootURL_confuse: rootURL_confuse)
        where fileURL_confuse.pathExtension.lowercased() == "swift" {
            guard let content_confuse = try? String(contentsOf: fileURL_confuse, encoding: .utf8),
                  let match_confuse = expression_confuse.firstMatch(
                    in: content_confuse,
                    range: NSRange(content_confuse.startIndex..<content_confuse.endIndex, in: content_confuse)
                  ), let range_confuse = Range(match_confuse.range(at: 1), in: content_confuse) else {
                continue
            }
            return String(content_confuse[range_confuse])
        }
        throw SwiftPackageAssemblyError_confuse.message_confuse(
            "目标项目中未找到继承 UITabBarController 的底部导航控制器。"
        )
    }

    /// 从目标 LaunchScreen.storyboard 中读取实际展示的图片资源名称。
    /// - Parameter rootURL_confuse: 目标项目根目录。
    /// - Returns: 首个 imageView 引用的图片资源名称。
    /// - Throws: 启动页不存在、XML 无法解析或没有图片资源时抛出错误。
    private static func launchImageName_confuse(rootURL_confuse: URL) throws -> String {
        guard let storyboardURL_confuse = findFirstFile_confuse(
            name_confuse: "LaunchScreen.storyboard",
            rootURL_confuse: rootURL_confuse
        ) else {
            throw SwiftPackageAssemblyError_confuse.message_confuse("目标项目中未找到 LaunchScreen.storyboard。")
        }
        let document_confuse = try XMLDocument(contentsOf: storyboardURL_confuse, options: [])
        let imageNodes_confuse = try document_confuse.nodes(forXPath: "//imageView[@image]")
        for node_confuse in imageNodes_confuse {
            guard let element_confuse = node_confuse as? XMLElement,
                  let name_confuse = element_confuse.attribute(forName: "image")?.stringValue?
                    .trimmingCharacters(in: .whitespacesAndNewlines),
                  !name_confuse.isEmpty else {
                continue
            }
            return name_confuse
        }
        throw SwiftPackageAssemblyError_confuse.message_confuse(
            "目标 LaunchScreen.storyboard 中未找到开屏图片资源。"
        )
    }

    /// 返回目标工程中的第一个指定名称文件，忽略依赖和构建缓存目录。
    /// - Parameters:
    ///   - name_confuse: 文件名。
    ///   - rootURL_confuse: 搜索根目录。
    /// - Returns: 找到的文件 URL。
    private static func findFirstFile_confuse(name_confuse: String, rootURL_confuse: URL) -> URL? {
        regularFiles_confuse(rootURL_confuse: rootURL_confuse).first {
            $0.lastPathComponent.caseInsensitiveCompare(name_confuse) == .orderedSame
        }
    }

    /// 查找必需文件并在缺失时抛出指定错误。
    /// - Parameters:
    ///   - name_confuse: 文件名。
    ///   - rootURL_confuse: 搜索根目录。
    ///   - missingMessage_confuse: 缺失提示。
    /// - Returns: 找到的文件 URL。
    /// - Throws: 文件不存在时抛出错误。
    private static func findRequiredFile_confuse(
        name_confuse: String,
        rootURL_confuse: URL,
        missingMessage_confuse: String
    ) throws -> URL {
        guard let fileURL_confuse = findFirstFile_confuse(
            name_confuse: name_confuse,
            rootURL_confuse: rootURL_confuse
        ) else {
            throw SwiftPackageAssemblyError_confuse.message_confuse(missingMessage_confuse)
        }
        return fileURL_confuse
    }

    /// 递归读取普通文件，跳过 Pods、Git 和构建缓存。
    /// - Parameter rootURL_confuse: 搜索根目录。
    /// - Returns: 按路径排序的文件 URL。
    private static func regularFiles_confuse(rootURL_confuse: URL) -> [URL] {
        guard let enumerator_confuse = FileManager.default.enumerator(
            at: rootURL_confuse,
            includingPropertiesForKeys: [.isRegularFileKey, .isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else { return [] }
        let skippedNames_confuse: Set<String> = ["Pods", ".git", ".build", "DerivedData", "xcuserdata"]
        return enumerator_confuse.compactMap { item_confuse in
            guard let url_confuse = item_confuse as? URL else { return nil }
            if url_confuse.pathComponents.contains(where: { skippedNames_confuse.contains($0) }) {
                enumerator_confuse.skipDescendants()
                return nil
            }
            return (try? url_confuse.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) == true
                ? url_confuse
                : nil
        }.sorted { $0.path.localizedStandardCompare($1.path) == .orderedAscending }
    }

    /// 判断合包代码是否使用 Facebook 相关能力。
    /// - Parameters:
    ///   - packageFiles_confuse: 合包目录中的文件。
    ///   - packagePodfileURL_confuse: 合包 Podfile。
    /// - Returns: 找到 Facebook 依赖、导入或调用时返回 true。
    private static func hasFacebookCode_confuse(
        packageFiles_confuse: [URL],
        packagePodfileURL_confuse: URL?
    ) -> Bool {
        let urls_confuse = packageFiles_confuse.filter {
            $0.pathExtension.lowercased() == "swift" || $0.lastPathComponent == "Podfile"
        }
        let sourceHasFacebook_confuse = urls_confuse.contains { url_confuse in
            guard let content_confuse = try? String(contentsOf: url_confuse, encoding: .utf8) else { return false }
            return content_confuse.range(of: "FBSDK|ApplicationDelegate|FacebookAppID", options: .regularExpression) != nil
        }
        let podfileHasFacebook_confuse = packagePodfileURL_confuse.flatMap {
            try? String(contentsOf: $0, encoding: .utf8)
        }?.range(of: #"pod\s+['"]FBSDKLoginKit['"]"#, options: .regularExpression) != nil
        return sourceHasFacebook_confuse || podfileHasFacebook_confuse
    }

    /// 合并目标 Podfile 中缺少的合包依赖。
    /// - Parameters:
    ///   - targetURL_confuse: 目标 Podfile。
    ///   - packageURL_confuse: 合包 Podfile。
    /// - Throws: Podfile 无法读取或写入时抛出错误。
    private static func mergePodfile_confuse(targetURL_confuse: URL, packageURL_confuse: URL) throws {
        var targetContent_confuse = try String(contentsOf: targetURL_confuse, encoding: .utf8)
        let packageContent_confuse = try String(contentsOf: packageURL_confuse, encoding: .utf8)
        let podLines_confuse = packageContent_confuse.components(separatedBy: .newlines).filter { line_confuse in
            guard let podName_confuse = podName_confuse(line_confuse: line_confuse) else { return false }
            return REQUIRED_POD_NAMES_CONFUSE.contains(podName_confuse)
        }
        let missingLines_confuse = podLines_confuse.filter { line_confuse in
            guard let dependencyName_confuse = podName_confuse(line_confuse: line_confuse) else { return false }
            return !targetContent_confuse.components(separatedBy: .newlines).contains {
                self.podName_confuse(line_confuse: $0) == dependencyName_confuse
            }
        }
        guard !missingLines_confuse.isEmpty else { return }
        let insertionMarker_confuse = "\nend"
        guard let insertionRange_confuse = targetContent_confuse.range(of: insertionMarker_confuse) else {
            throw SwiftPackageAssemblyError_confuse.message_confuse("目标 Podfile 中未找到可插入依赖的结束位置。")
        }
        let insertion_confuse = "\n  # 合包依赖\n" + missingLines_confuse.map {
            "  \($0.trimmingCharacters(in: CharacterSet.whitespaces))"
        }.joined(separator: "\n")
        targetContent_confuse.insert(contentsOf: insertion_confuse, at: insertionRange_confuse.lowerBound)
        try targetContent_confuse.write(to: targetURL_confuse, atomically: true, encoding: .utf8)
    }

    /// 从 Podfile 行中提取依赖名称。
    /// - Parameter line_confuse: Podfile 单行文本。
    /// - Returns: 依赖名称；不是 pod 行时返回 nil。
    private static func podName_confuse(line_confuse: String) -> String? {
        guard let expression_confuse = try? NSRegularExpression(
            pattern: #"pod\s+['"]([^'"]+)['"]"#
        ), let match_confuse = expression_confuse.firstMatch(
            in: line_confuse,
            range: NSRange(line_confuse.startIndex..<line_confuse.endIndex, in: line_confuse)
        ), let nameRange_confuse = Range(match_confuse.range(at: 1), in: line_confuse) else {
            return nil
        }
        return String(line_confuse[nameRange_confuse])
    }

    /// 用合包源文件替换目标 Mix 目录中同名文件。
    /// - Parameters:
    ///   - sourceURL_confuse: 合包源文件。
    ///   - destinationURL_confuse: 目标文件。
    /// - Throws: 文件无法替换时抛出错误。
    private static func replaceItem_confuse(sourceURL_confuse: URL, destinationURL_confuse: URL) throws {
        let fileManager_confuse = FileManager.default
        if fileManager_confuse.fileExists(atPath: destinationURL_confuse.path) {
            try fileManager_confuse.removeItem(at: destinationURL_confuse)
        }
        try fileManager_confuse.copyItem(at: sourceURL_confuse, to: destinationURL_confuse)
    }

    /// 合并合包 AppDelegate 中的导入、启动代码和委托扩展。
    /// - Parameters:
    ///   - targetURL_confuse: 目标 AppDelegate.swift。
    ///   - packageURL_confuse: 合包 AppDelegate.swift，可为空。
    ///   - backendConfiguration_confuse: 后台合包配置。
    ///   - tabBarClassName_confuse: 目标底部导航控制器类名。
    ///   - launchImageName_confuse: 目标启动页图片资源名。
    /// - Throws: 文件无法读取或写入时抛出错误。
    private static func mergeAppDelegate_confuse(
        targetURL_confuse: URL,
        packageURL_confuse: URL?,
        backendConfiguration_confuse: BackendConfiguration_confuse,
        tabBarClassName_confuse: String,
        launchImageName_confuse: String
    ) throws {
        guard let packageURL_confuse else { return }
        var targetContent_confuse = try String(contentsOf: targetURL_confuse, encoding: .utf8)
        let rawPackageContent_confuse = try String(contentsOf: packageURL_confuse, encoding: .utf8)
        let packageContent_confuse = try configuredPackageContent_confuse(
            content_confuse: rawPackageContent_confuse,
            backendConfiguration_confuse: backendConfiguration_confuse,
            tabBarClassName_confuse: tabBarClassName_confuse,
            launchImageName_confuse: launchImageName_confuse
        )
        targetContent_confuse = removeManagedLaunchCode_confuse(content_confuse: targetContent_confuse)
        targetContent_confuse = mergeImports_confuse(
            targetContent_confuse: targetContent_confuse,
            packageContent_confuse: packageContent_confuse
        )
        targetContent_confuse = removeOriginalWindowSetup_confuse(content_confuse: targetContent_confuse)
        let packageBody_confuse = launchBody_confuse(content_confuse: packageContent_confuse)
            .replacingOccurrences(
                of: #"(?m)^\s*return\s+true\s*$"#,
                with: "",
                options: .regularExpression
            )
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if !packageBody_confuse.isEmpty {
            let insertion_confuse = "\n        // 合包代码开始\n"
                + packageBody_confuse
                + "\n        // 合包代码结束\n\n        "
            targetContent_confuse = insertBeforeLaunchReturn_confuse(
                content_confuse: targetContent_confuse,
                insertion_confuse: insertion_confuse
            )
        }
        if packageContent_confuse.contains("UNUserNotificationCenter.current()") {
            targetContent_confuse = addProtocol_confuse(
                protocolName_confuse: "UNUserNotificationCenterDelegate",
                toClassDeclaration_confuse: targetContent_confuse
            )
        }
        targetContent_confuse = removeManagedDelegateExtension_confuse(content_confuse: targetContent_confuse)
        if let extensionRange_confuse = packageContent_confuse.range(of: "extension AppDelegate") {
            let extensionContent_confuse = String(packageContent_confuse[extensionRange_confuse.lowerBound...])
            targetContent_confuse += "\n\n// 合包委托扩展开始\n"
                + extensionContent_confuse.trimmingCharacters(in: .whitespacesAndNewlines)
                + "\n// 合包委托扩展结束\n"
        }
        try targetContent_confuse.write(to: targetURL_confuse, atomically: true, encoding: .utf8)
    }

    /// 将后台配置和目标项目入口替换到合包 AppDelegate 模板中。
    /// - Parameters:
    ///   - content_confuse: 合包模板源码。
    ///   - backendConfiguration_confuse: 后台读取结果。
    ///   - tabBarClassName_confuse: 底部导航控制器类名。
    ///   - launchImageName_confuse: 启动页图片资源名。
    /// - Returns: 完成五类变量替换后的模板源码。
    /// - Throws: 模板缺少 AppsFlyer 或 Bendo 启动代码时抛出错误。
    private static func configuredPackageContent_confuse(
        content_confuse: String,
        backendConfiguration_confuse: BackendConfiguration_confuse,
        tabBarClassName_confuse: String,
        launchImageName_confuse: String
    ) throws -> String {
        var result_confuse = content_confuse
        result_confuse = try replacingRequiredPattern_confuse(
            content_confuse: result_confuse,
            pattern_confuse: #"AppsFlyerLib\.shared\(\)\.appsFlyerDevKey\s*=\s*\"[^\"]*\""#,
            replacement_confuse: "AppsFlyerLib.shared().appsFlyerDevKey = \"\(swiftEscaped_confuse(value_confuse: backendConfiguration_confuse.appsFlyerDevKey_confuse))\"",
            missingMessage_confuse: "合包 AppDelegate 中未找到 appsFlyerDevKey 配置。"
        )
        result_confuse = try replacingRequiredPattern_confuse(
            content_confuse: result_confuse,
            pattern_confuse: #"AppsFlyerLib\.shared\(\)\.appleAppID\s*=\s*\"[^\"]*\""#,
            replacement_confuse: "AppsFlyerLib.shared().appleAppID = \"\(swiftEscaped_confuse(value_confuse: backendConfiguration_confuse.appleAppID_confuse))\"",
            missingMessage_confuse: "合包 AppDelegate 中未找到 appleAppID 配置。"
        )
        let openWindowLine_confuse = "BendoBaseShare.shared.bendoOpenWindow("
            + "self.window ?? UIWindow(frame: UIScreen.main.bounds), "
            + "\(tabBarClassName_confuse)(), "
            + "\"\(swiftEscaped_confuse(value_confuse: backendConfiguration_confuse.configurationDomain_confuse))\", "
            + "\"\(swiftEscaped_confuse(value_confuse: backendConfiguration_confuse.requestDomain_confuse))\", "
            + "\"\(swiftEscaped_confuse(value_confuse: launchImageName_confuse))\")"
        result_confuse = try replacingRequiredPattern_confuse(
            content_confuse: result_confuse,
            pattern_confuse: #"(?m)^\s*BendoBaseShare\s*\.\s*shared\s*\.\s*bendoOpenWindow\(.*\)\s*$"#,
            replacement_confuse: openWindowLine_confuse,
            missingMessage_confuse: "合包 AppDelegate 中未找到 Bendo 启动入口。"
        )
        return result_confuse
    }

    /// 替换模板中必须存在的首个正则匹配项。
    /// - Parameters:
    ///   - content_confuse: 原始源码。
    ///   - pattern_confuse: 正则表达式。
    ///   - replacement_confuse: 替换文本。
    ///   - missingMessage_confuse: 未匹配时的错误说明。
    /// - Returns: 替换后的源码。
    /// - Throws: 正则无效或模板缺少目标内容时抛出错误。
    private static func replacingRequiredPattern_confuse(
        content_confuse: String,
        pattern_confuse: String,
        replacement_confuse: String,
        missingMessage_confuse: String
    ) throws -> String {
        guard let expression_confuse = try? NSRegularExpression(pattern: pattern_confuse),
              let match_confuse = expression_confuse.firstMatch(
                in: content_confuse,
                range: NSRange(content_confuse.startIndex..<content_confuse.endIndex, in: content_confuse)
              ), let range_confuse = Range(match_confuse.range, in: content_confuse) else {
            throw SwiftPackageAssemblyError_confuse.message_confuse(missingMessage_confuse)
        }
        return content_confuse.replacingCharacters(in: range_confuse, with: replacement_confuse)
    }

    /// 转义写入 Swift 字符串字面量的后台配置值。
    /// - Parameter value_confuse: 原始后台字段值。
    /// - Returns: 已转义反斜杠、双引号和换行符的字符串。
    private static func swiftEscaped_confuse(value_confuse: String) -> String {
        value_confuse
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "")
    }

    /// 删除上一次由合包流程插入的启动代码，保证重复执行不会累加。
    /// - Parameter content_confuse: 目标 AppDelegate 源码。
    /// - Returns: 删除受管代码块后的源码。
    private static func removeManagedLaunchCode_confuse(content_confuse: String) -> String {
        content_confuse.replacingOccurrences(
            of: #"(?s)\s*// 合包代码开始.*?// 合包代码结束\s*"#,
            with: "\n        ",
            options: .regularExpression
        )
    }

    /// 删除上一次合包写入的委托扩展，保证重复执行可以更新代码。
    /// - Parameter content_confuse: 目标 AppDelegate 源码。
    /// - Returns: 删除受管扩展后的源码。
    private static func removeManagedDelegateExtension_confuse(content_confuse: String) -> String {
        content_confuse.replacingOccurrences(
            of: #"(?s)\s*// 合包委托扩展开始.*?// 合包委托扩展结束\s*"#,
            with: "\n",
            options: .regularExpression
        )
    }

    /// 合并合包 AppDelegate 中没有出现在目标文件的 import 行。
    /// - Parameters:
    ///   - targetContent_confuse: 目标源码。
    ///   - packageContent_confuse: 合包源码。
    /// - Returns: 合并 import 后的源码。
    private static func mergeImports_confuse(
        targetContent_confuse: String,
        packageContent_confuse: String
    ) -> String {
        let imports_confuse = packageContent_confuse.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { $0.hasPrefix("import ") }
            .filter { !targetContent_confuse.contains("\n\($0)\n") && !targetContent_confuse.hasPrefix("\($0)\n") }
        guard !imports_confuse.isEmpty else { return targetContent_confuse }
        return imports_confuse.joined(separator: "\n") + "\n" + targetContent_confuse
    }

    /// 提取合包 AppDelegate 的启动方法主体。
    /// - Parameter content_confuse: 合包 AppDelegate 源码。
    /// - Returns: 启动方法中的代码文本。
    private static func launchBody_confuse(content_confuse: String) -> String {
        guard let startRange_confuse = content_confuse.range(
            of: #"func application\(_ application: UIApplication, didFinishLaunchingWithOptions"#,
            options: .regularExpression
        ) else { return "" }
        let suffix_confuse = content_confuse[startRange_confuse.lowerBound...]
        guard let openingBraceOffset_confuse = suffix_confuse.firstIndex(of: "{") else { return "" }
        let bodyStart_confuse = suffix_confuse.index(after: openingBraceOffset_confuse)
        var depth_confuse = 1
        var cursor_confuse = bodyStart_confuse
        while cursor_confuse < suffix_confuse.endIndex {
            let character_confuse = suffix_confuse[cursor_confuse]
            if character_confuse == "{" { depth_confuse += 1 }
            if character_confuse == "}" {
                depth_confuse -= 1
                if depth_confuse == 0 {
                    return String(suffix_confuse[bodyStart_confuse..<cursor_confuse])
                }
            }
            cursor_confuse = suffix_confuse.index(after: cursor_confuse)
        }
        return ""
    }

    /// 删除模板中原有的窗口设置代码块。
    /// - Parameter content_confuse: 目标 AppDelegate 源码。
    /// - Returns: 删除窗口代码后的源码。
    private static func removeOriginalWindowSetup_confuse(content_confuse: String) -> String {
        let lines_confuse = content_confuse.components(separatedBy: .newlines)
        var result_confuse: [String] = []
        var skipping_confuse = false
        for line_confuse in lines_confuse {
            if line_confuse.contains("// 设置窗口") {
                skipping_confuse = true
                continue
            }
            if skipping_confuse {
                if line_confuse.contains("Navigation_") && line_confuse.contains("setRootToTabbar") {
                    skipping_confuse = false
                }
                continue
            }
            let trimmedLine_confuse = line_confuse.trimmingCharacters(in: .whitespaces)
            if trimmedLine_confuse.range(
                of: #"^(self\.)?window\??\s*=\s*UIWindow\("#,
                options: .regularExpression
            ) != nil
                || trimmedLine_confuse.range(
                    of: #"^(self\.)?window\?\.backgroundColor\s*="#,
                    options: .regularExpression
                ) != nil
                || trimmedLine_confuse.contains("setRootToTabbar") {
                continue
            }
            result_confuse.append(line_confuse)
        }
        return result_confuse.joined(separator: "\n")
    }

    /// 将合包启动代码插入目标启动方法的 return true 前。
    /// - Parameters:
    ///   - content_confuse: 目标 AppDelegate 源码。
    ///   - insertion_confuse: 待插入代码。
    /// - Returns: 插入后的源码。
    private static func insertBeforeLaunchReturn_confuse(content_confuse: String, insertion_confuse: String) -> String {
        guard let launchRange_confuse = content_confuse.range(
            of: #"func application\(_ application: UIApplication, didFinishLaunchingWithOptions"#,
            options: .regularExpression
        ), let returnRange_confuse = content_confuse.range(
            of: "return true",
            range: launchRange_confuse.upperBound..<content_confuse.endIndex
        ) else { return content_confuse }
        return String(content_confuse[..<returnRange_confuse.lowerBound])
            + insertion_confuse
            + String(content_confuse[returnRange_confuse.lowerBound...])
    }

    /// 为目标 AppDelegate 类声明补充缺失协议。
    /// - Parameters:
    ///   - protocolName_confuse: 协议名称。
    ///   - toClassDeclaration_confuse: 目标源码。
    /// - Returns: 补充协议后的源码。
    private static func addProtocol_confuse(
        protocolName_confuse: String,
        toClassDeclaration_confuse content_confuse: String
    ) -> String {
        guard !content_confuse.contains(protocolName_confuse) else {
            return content_confuse
        }
        guard let declarationRange_confuse = content_confuse.range(
            of: #"class\s+AppDelegate\s*:[^{]+\{"#,
            options: .regularExpression
        ) else { return content_confuse }
        var declaration_confuse = String(content_confuse[declarationRange_confuse])
        declaration_confuse = declaration_confuse.replacingOccurrences(
            of: "{",
            with: ", \(protocolName_confuse) {"
        )
        return content_confuse.replacingCharacters(in: declarationRange_confuse, with: declaration_confuse)
    }

    /// 返回目标工程的 project.pbxproj 文件。
    /// - Parameter rootURL_confuse: 工程根目录。
    /// - Returns: project.pbxproj URL。
    /// - Throws: 工程文件不存在时抛出错误。
    private static func projectFileURL_confuse(rootURL_confuse: URL) throws -> URL {
        guard let projectURL_confuse = regularFiles_confuse(rootURL_confuse: rootURL_confuse).first(where: {
            $0.lastPathComponent == "project.pbxproj"
        }) else {
            throw SwiftPackageAssemblyError_confuse.projectFileMissing_confuse
        }
        return projectURL_confuse
    }

    /// 将 Mix 下的 Swift 文件注册到 Xcode 工程文件和 Sources 阶段。
    /// - Parameters:
    ///   - projectFileURL_confuse: project.pbxproj URL。
    ///   - fileURLs_confuse: 已复制到 Mix 的源码文件。
    /// - Throws: pbxproj 结构无法识别或写入失败时抛出错误。
    private static func registerSwiftFiles_confuse(
        projectFileURL_confuse: URL,
        fileURLs_confuse: [URL]
    ) throws {
        var content_confuse = try String(contentsOf: projectFileURL_confuse, encoding: .utf8)
        let sourceDirectoryName_confuse = fileURLs_confuse.first?
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .lastPathComponent
        if content_confuse.contains("PBXFileSystemSynchronizedRootGroup"),
           let sourceDirectoryName_confuse,
           content_confuse.contains("path = \(sourceDirectoryName_confuse);") {
            return
        }
        let existingCount_confuse = fileURLs_confuse.filter {
            content_confuse.contains("/* \($0.lastPathComponent) */")
        }.count
        if existingCount_confuse == fileURLs_confuse.count {
            return
        }
        if existingCount_confuse > 0 {
            throw SwiftPackageAssemblyError_confuse.message_confuse(
                "Xcode 项目中存在不完整的 Mix 文件引用，请删除失效引用后重试。"
            )
        }
        let fileReferenceIDs_confuse = fileURLs_confuse.map { _ in makeIdentifier_confuse() }
        let buildFileIDs_confuse = fileURLs_confuse.map { _ in makeIdentifier_confuse() }
        let groupID_confuse = makeIdentifier_confuse()
        let fileReferenceEntries_confuse = zip(fileURLs_confuse, fileReferenceIDs_confuse).map { fileURL_confuse, id_confuse in
            "\t\t\(id_confuse) /* \(fileURL_confuse.lastPathComponent) */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = \(fileURL_confuse.lastPathComponent); sourceTree = \"<group>\";};\n"
        }.joined()
        let buildFileEntries_confuse = zip(fileURLs_confuse, zip(fileReferenceIDs_confuse, buildFileIDs_confuse)).map {
            fileURL_confuse, ids_confuse in
            "\t\t\(ids_confuse.1) /* \(fileURL_confuse.lastPathComponent) in Sources */ = {isa = PBXBuildFile; fileRef = \(ids_confuse.0) /* \(fileURL_confuse.lastPathComponent) */; };\n"
        }.joined()
        let groupChildren_confuse = fileURLs_confuse.enumerated().map { index_confuse, fileURL_confuse in
            "\t\t\t\(fileReferenceIDs_confuse[index_confuse]) /* \(fileURL_confuse.lastPathComponent) */,\n"
        }.joined()
        let groupEntry_confuse = "\t\t\(groupID_confuse) /* Mix */ = {\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n\(groupChildren_confuse)\t\t\t);\n\t\t\tpath = Mix;\n\t\t\tsourceTree = \"<group>\";\n\t\t};\n"

        content_confuse = try insertPBXEntries_confuse(
            entries_confuse: fileReferenceEntries_confuse,
            sectionName_confuse: "PBXFileReference",
            content_confuse: content_confuse
        )
        content_confuse = try insertPBXEntries_confuse(
            entries_confuse: buildFileEntries_confuse,
            sectionName_confuse: "PBXBuildFile",
            content_confuse: content_confuse
        )
        content_confuse = try insertPBXEntries_confuse(
            entries_confuse: groupEntry_confuse,
            sectionName_confuse: "PBXGroup",
            content_confuse: content_confuse
        )
        content_confuse = try addGroupToAppDelegateParent_confuse(
            groupID_confuse: groupID_confuse,
            appDelegateName_confuse: "AppDelegate.swift",
            content_confuse: content_confuse
        )
        content_confuse = try addBuildFilesToSourcesPhase_confuse(
            buildFileIDs_confuse: buildFileIDs_confuse,
            fileURLs_confuse: fileURLs_confuse,
            content_confuse: content_confuse
        )
        try content_confuse.write(to: projectFileURL_confuse, atomically: true, encoding: .utf8)
    }

    /// 在指定 pbxproj 段落结束前插入对象。
    /// - Parameters:
    ///   - entries_confuse: 待插入对象文本。
    ///   - sectionName_confuse: pbxproj 段落名称。
    ///   - content_confuse: pbxproj 文本。
    /// - Returns: 插入后的 pbxproj 文本。
    /// - Throws: 段落结束标记不存在时抛出错误。
    private static func insertPBXEntries_confuse(
        entries_confuse: String,
        sectionName_confuse: String,
        content_confuse: String
    ) throws -> String {
        let marker_confuse = "/* End \(sectionName_confuse) section */"
        guard let range_confuse = content_confuse.range(of: marker_confuse) else {
            throw SwiftPackageAssemblyError_confuse.message_confuse("Xcode 项目缺少 \(sectionName_confuse) 区段。")
        }
        return String(content_confuse[..<range_confuse.lowerBound])
            + entries_confuse
            + String(content_confuse[range_confuse.lowerBound...])
    }

    /// 把 Mix 组添加到包含 AppDelegate 文件引用的父分组。
    /// - Parameters:
    ///   - groupID_confuse: 新建 Mix 分组 ID。
    ///   - appDelegateName_confuse: 用于定位父分组的文件名。
    ///   - content_confuse: pbxproj 文本。
    /// - Returns: 更新后的 pbxproj 文本。
    /// - Throws: 找不到 AppDelegate 父分组时抛出错误。
    private static func addGroupToAppDelegateParent_confuse(
        groupID_confuse: String,
        appDelegateName_confuse: String,
        content_confuse: String
    ) throws -> String {
        guard let appDelegateID_confuse = fileReferenceID_confuse(
            fileName_confuse: appDelegateName_confuse,
            content_confuse: content_confuse
        ) else {
            throw SwiftPackageAssemblyError_confuse.message_confuse("Xcode 项目中未找到 AppDelegate 文件引用。")
        }
        guard let sectionRange_confuse = content_confuse.range(of: "/* Begin PBXGroup section */") else {
            throw SwiftPackageAssemblyError_confuse.message_confuse("Xcode 项目缺少 PBXGroup 区段。")
        }
        guard let endRange_confuse = content_confuse.range(
            of: "/* End PBXGroup section */",
            range: sectionRange_confuse.upperBound..<content_confuse.endIndex
        ) else {
            throw SwiftPackageAssemblyError_confuse.message_confuse("PBXGroup 区段不完整。")
        }
        let section_confuse = String(content_confuse[sectionRange_confuse.upperBound..<endRange_confuse.lowerBound])
        let objectPattern_confuse = #"(?s)\t\t[0-9A-F]+ /\*.*?\*/ = \{.*?\n\t\t\};"#
        guard let expression_confuse = try? NSRegularExpression(pattern: objectPattern_confuse) else {
            throw SwiftPackageAssemblyError_confuse.message_confuse("无法解析 Xcode 项目分组。")
        }
        let matches_confuse = expression_confuse.matches(
            in: section_confuse,
            range: NSRange(section_confuse.startIndex..<section_confuse.endIndex, in: section_confuse)
        )
        guard let match_confuse = matches_confuse.first(where: {
            let block_confuse = String(section_confuse[Range($0.range, in: section_confuse)!])
            return block_confuse.contains("\(appDelegateID_confuse) /* \(appDelegateName_confuse) */")
        }), let blockRange_confuse = Range(match_confuse.range, in: section_confuse) else {
            throw SwiftPackageAssemblyError_confuse.message_confuse("无法定位包含 AppDelegate 的 Xcode 分组。")
        }
        let block_confuse = String(section_confuse[blockRange_confuse])
        guard let childrenRange_confuse = block_confuse.range(of: "children = (\n") else {
            throw SwiftPackageAssemblyError_confuse.message_confuse("AppDelegate 的父分组缺少子项列表。")
        }
        let updatedBlock_confuse = String(block_confuse[..<childrenRange_confuse.upperBound])
            + "\t\t\t\(groupID_confuse) /* Mix */,\n"
            + String(block_confuse[childrenRange_confuse.upperBound...])
        let updatedSection_confuse = String(section_confuse[..<blockRange_confuse.lowerBound])
            + updatedBlock_confuse
            + String(section_confuse[blockRange_confuse.upperBound...])
        return String(content_confuse[..<sectionRange_confuse.upperBound])
            + updatedSection_confuse
            + String(content_confuse[endRange_confuse.lowerBound...])
    }

    /// 查找指定 Swift 文件引用在 pbxproj 中的 ID。
    /// - Parameters:
    ///   - fileName_confuse: 文件名。
    ///   - content_confuse: pbxproj 文本。
    /// - Returns: 文件引用 ID。
    private static func fileReferenceID_confuse(fileName_confuse: String, content_confuse: String) -> String? {
        let pattern_confuse = "(?m)^(\\t\\t[0-9A-F]+) /\\* \\(NSRegularExpression.escapedPattern(for: fileName_confuse)) \\*/ = \\{"
        guard let expression_confuse = try? NSRegularExpression(pattern: pattern_confuse),
              let match_confuse = expression_confuse.firstMatch(
                in: content_confuse,
                range: NSRange(content_confuse.startIndex..<content_confuse.endIndex, in: content_confuse)
              ), let idRange_confuse = Range(match_confuse.range(at: 1), in: content_confuse) else {
            return nil
        }
        return String(content_confuse[idRange_confuse]).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// 把新建源文件的 BuildFile 引用加入第一个 Sources 阶段。
    /// - Parameters:
    ///   - buildFileIDs_confuse: BuildFile ID 列表。
    ///   - fileURLs_confuse: 对应源码文件。
    ///   - content_confuse: pbxproj 文本。
    /// - Returns: 更新后的 pbxproj 文本。
    /// - Throws: Sources 阶段不存在时抛出错误。
    private static func addBuildFilesToSourcesPhase_confuse(
        buildFileIDs_confuse: [String],
        fileURLs_confuse: [URL],
        content_confuse: String
    ) throws -> String {
        guard let sectionRange_confuse = content_confuse.range(of: "/* Begin PBXSourcesBuildPhase section */"),
              let phaseEndRange_confuse = content_confuse.range(
                of: "/* End PBXSourcesBuildPhase section */",
                range: sectionRange_confuse.upperBound..<content_confuse.endIndex
              ) else {
            throw SwiftPackageAssemblyError_confuse.message_confuse("Xcode 项目缺少 Sources 构建阶段。")
        }
        let phaseSection_confuse = String(content_confuse[sectionRange_confuse.upperBound..<phaseEndRange_confuse.lowerBound])
        guard let filesRange_confuse = phaseSection_confuse.range(of: "files = (\n") else {
            throw SwiftPackageAssemblyError_confuse.message_confuse("Sources 构建阶段缺少文件列表。")
        }
        let sourceEntries_confuse = zip(buildFileIDs_confuse, fileURLs_confuse).map { id_confuse, fileURL_confuse in
            "\t\t\t\(id_confuse) /* \(fileURL_confuse.lastPathComponent) in Sources */,\n"
        }.joined()
        let updatedPhase_confuse = String(phaseSection_confuse[..<filesRange_confuse.upperBound])
            + sourceEntries_confuse
            + String(phaseSection_confuse[filesRange_confuse.upperBound...])
        return String(content_confuse[..<sectionRange_confuse.upperBound])
            + updatedPhase_confuse
            + String(content_confuse[phaseEndRange_confuse.lowerBound...])
    }

    /// 查找目标 Info.plist。
    /// - Parameters:
    ///   - rootURL_confuse: 工程根目录。
    ///   - appDelegateURL_confuse: 目标 AppDelegate URL。
    /// - Returns: Info.plist URL。
    /// - Throws: 找不到 Info.plist 时抛出错误。
    private static func infoPropertyListURL_confuse(
        rootURL_confuse: URL,
        appDelegateURL_confuse: URL
    ) throws -> URL {
        let nearbyURL_confuse = appDelegateURL_confuse.deletingLastPathComponent().appendingPathComponent("Info.plist")
        if FileManager.default.fileExists(atPath: nearbyURL_confuse.path) {
            return nearbyURL_confuse
        }
        guard let infoURL_confuse = findFirstFile_confuse(name_confuse: "Info.plist", rootURL_confuse: rootURL_confuse) else {
            throw SwiftPackageAssemblyError_confuse.infoPlistMissing_confuse
        }
        return infoURL_confuse
    }

    /// 更新 Facebook、SKAdNetwork、URL Scheme 和视频包定位权限配置。
    /// - Parameters:
    ///   - infoURL_confuse: 目标 Info.plist URL。
    ///   - type_confuse: 合包类型。
    ///   - backendConfiguration_confuse: 后台读取的 Facebook 和 AppsFlyer 配置。
    /// - Throws: 属性列表无法解析或写入时抛出错误。
    private static func updateInfoPropertyList_confuse(
        infoURL_confuse: URL,
        type_confuse: PackageType_confuse,
        backendConfiguration_confuse: BackendConfiguration_confuse
    ) throws {
        let data_confuse = try Data(contentsOf: infoURL_confuse)
        guard var info_confuse = try PropertyListSerialization.propertyList(
            from: data_confuse,
            options: [],
            format: nil
        ) as? [String: Any] else {
            throw SwiftPackageAssemblyError_confuse.infoPlistInvalid_confuse
        }
        let facebookAppID_confuse = backendConfiguration_confuse.facebookAppID_confuse
            .trimmingCharacters(in: .whitespacesAndNewlines)
        info_confuse["FacebookAppID"] = facebookAppID_confuse
        info_confuse["FacebookClientToken"] = backendConfiguration_confuse.facebookClientToken_confuse
            .trimmingCharacters(in: .whitespacesAndNewlines)
        info_confuse["FacebookDisplayName"] = backendConfiguration_confuse.facebookDisplayName_confuse
            .trimmingCharacters(in: .whitespacesAndNewlines)
        info_confuse["NSAdvertisingAttributionReportEndpoint"] = "https://appsflyer-skadnetwork.com/"
        info_confuse["SKIncludeConsumableInAppPurchaseHistory"] = true
        let scheme_confuse = "fb\(facebookAppID_confuse)"
        var urlTypes_confuse = info_confuse["CFBundleURLTypes"] as? [[String: Any]] ?? []
        if let facebookIndex_confuse = urlTypes_confuse.firstIndex(where: { item_confuse in
            (item_confuse["CFBundleURLName"] as? String) == "Facebook"
                || (item_confuse["CFBundleURLSchemes"] as? [String])?.contains(where: {
                    $0.lowercased().hasPrefix("fb")
                }) == true
        }) {
            urlTypes_confuse[facebookIndex_confuse]["CFBundleURLName"] = "Facebook"
            urlTypes_confuse[facebookIndex_confuse]["CFBundleURLSchemes"] = [scheme_confuse]
        } else {
            urlTypes_confuse.append([
                "CFBundleURLName": "Facebook",
                "CFBundleURLSchemes": [scheme_confuse]
            ])
        }
        info_confuse["CFBundleURLTypes"] = urlTypes_confuse
        if type_confuse == .video20_confuse {
            for key_confuse in [
                "NSLocationWhenInUseUsageDescription",
                "NSLocationAlwaysAndWhenInUseUsageDescription",
                "NSLocationAlwaysUsageDescription",
                "NSLocationUsageDescription"
            ] {
                info_confuse.removeValue(forKey: key_confuse)
            }
        }
        let outputData_confuse = try PropertyListSerialization.data(
            fromPropertyList: info_confuse,
            format: .xml,
            options: 0
        )
        try outputData_confuse.write(to: infoURL_confuse, options: [.atomic])
    }

    /// 读取合包会修改或创建的文件原始状态。
    /// - Parameter urls_confuse: 需要保护的文件 URL 列表。
    /// - Returns: 包含原始数据或不存在状态的快照。
    /// - Throws: 已存在文件无法读取时抛出错误。
    private static func fileSnapshots_confuse(urls_confuse: [URL]) throws -> [FileSnapshot_confuse] {
        try urls_confuse.map { url_confuse in
            let data_confuse = FileManager.default.fileExists(atPath: url_confuse.path)
                ? try Data(contentsOf: url_confuse)
                : nil
            return FileSnapshot_confuse(url_confuse: url_confuse, data_confuse: data_confuse)
        }
    }

    /// 在合包失败时恢复所有受管文件。
    /// - Parameter snapshots_confuse: 合包前创建的文件快照。
    /// - Throws: 任一文件无法恢复时抛出错误。
    private static func restoreFileSnapshots_confuse(
        snapshots_confuse: [FileSnapshot_confuse]
    ) throws {
        let fileManager_confuse = FileManager.default
        for snapshot_confuse in snapshots_confuse {
            if let data_confuse = snapshot_confuse.data_confuse {
                try fileManager_confuse.createDirectory(
                    at: snapshot_confuse.url_confuse.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )
                try data_confuse.write(to: snapshot_confuse.url_confuse, options: [.atomic])
            } else if fileManager_confuse.fileExists(atPath: snapshot_confuse.url_confuse.path) {
                try fileManager_confuse.removeItem(at: snapshot_confuse.url_confuse)
            }
        }
    }

    /// 生成一个适合 Xcode 工程文件的唯一 ID。
    /// - Returns: 24 位大写十六进制 ID。
    private static func makeIdentifier_confuse() -> String {
        String(UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(24)).uppercased()
    }
}

/// 描述 Swift 合包整理失败的具体原因。
enum SwiftPackageAssemblyError_confuse: LocalizedError {
    case invalidTargetProject_confuse
    case targetPodfileMissing_confuse
    case projectFileMissing_confuse
    case infoPlistMissing_confuse
    case infoPlistInvalid_confuse
    case facebookInformationMissing_confuse
    case missingPackageFiles_confuse([String])
    case message_confuse(String)

    /// 返回面向用户的中文错误说明。
    var errorDescription: String? {
        switch self {
        case .invalidTargetProject_confuse:
            return "所选目录不是有效的 Swift Xcode 项目。"
        case .targetPodfileMissing_confuse:
            return "目标 Swift 项目中未找到 Podfile。"
        case .projectFileMissing_confuse:
            return "目标项目中未找到 project.pbxproj。"
        case .infoPlistMissing_confuse:
            return "目标项目中未找到 Info.plist。"
        case .infoPlistInvalid_confuse:
            return "无法解析目标项目的 Info.plist。"
        case .facebookInformationMissing_confuse:
            return "检测到 Facebook 功能，请完整填写应用编号、客户端令牌和显示名称。"
        case .missingPackageFiles_confuse(let names_confuse):
            return "缺少必需的 PACKAGE 文件：\(names_confuse.joined(separator: ", "))。"
        case .message_confuse(let message_confuse):
            return message_confuse
        }
    }
}
