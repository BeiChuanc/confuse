import Foundation

/// 描述项目初始化过程中可直接展示给用户的错误。
enum ProjectInitializationError_confuse: LocalizedError {
    case unsupportedType_confuse
    case templateMissing_confuse
    case invalidTemplate_confuse
    case destinationExists_confuse
    case renameFailed_confuse
    case operationFailed_confuse

    /// 返回中文错误说明。
    var errorDescription: String? {
        switch self {
        case .unsupportedType_confuse:
            return "当前仅支持创建 Swift 项目。"
        case .templateMissing_confuse:
            return "应用内置的 Swift 项目模板缺失，请重新打包应用。"
        case .invalidTemplate_confuse:
            return "Swift 项目模板结构不完整。"
        case .destinationExists_confuse:
            return "保存位置中已存在同名项目，请更换项目名称或目录。"
        case .renameFailed_confuse:
            return "项目重命名脚本执行失败，请检查 Python 环境。"
        case .operationFailed_confuse:
            return "项目创建失败，请检查目录权限和磁盘空间。"
        }
    }
}

/// 使用内置模板创建 Swift 工程，并按固定顺序完成配置、资源和源码整理。
enum ProjectInitializationService_confuse {
    private static let TEMPLATE_PROJECT_NAME_CONFUSE = "base_one"
    private static let MODULE_NAMES_CONFUSE = [
        "Data", "Extension", "Model", "Pages", "Route", "Utils", "ViewModel", "Views"
    ]
    private static let ASSET_FOLDER_NAMES_CONFUSE = ["Data", "User", "Pro", "Store", "App"]

    /// 创建完整的 Swift 项目并发送每一步的执行进度。
    /// - Parameters:
    ///   - request_confuse: 项目名称、类型和保存目录。
    ///   - progressHandler_confuse: 单步开始或完成时调用的进度回调。
    /// - Returns: 新项目根目录 URL。
    /// - Throws: 类型不支持、模板缺失、目标冲突、文件操作或脚本执行失败时抛出错误。
    static func createProject_confuse(
        request_confuse: ProjectInitializationRequest_confuse,
        progressHandler_confuse: @escaping (ProjectInitializationProgress_confuse) -> Void
    ) throws -> URL {
        guard request_confuse.projectType_confuse == .swift_confuse else {
            throw ProjectInitializationError_confuse.unsupportedType_confuse
        }

        let fileManager_confuse = FileManager.default
        let templateURL_confuse = try templateDirectoryURL_confuse()
        let destinationRootURL_confuse = URL(
            fileURLWithPath: request_confuse.destinationDirectoryPath_confuse,
            isDirectory: true
        ).appendingPathComponent(request_confuse.projectName_confuse, isDirectory: true)
        guard !fileManager_confuse.fileExists(atPath: destinationRootURL_confuse.path) else {
            throw ProjectInitializationError_confuse.destinationExists_confuse
        }

        do {
            try performStep_confuse(
                step_confuse: .createStructure_confuse,
                runningDetail_confuse: "正在创建项目目录和 Xcode 工程。",
                completedDetail_confuse: "项目目录和 Xcode 工程已创建。",
                progressHandler_confuse: progressHandler_confuse
            ) {
                try createStructure_confuse(
                    templateURL_confuse: templateURL_confuse,
                    destinationRootURL_confuse: destinationRootURL_confuse,
                    projectName_confuse: request_confuse.projectName_confuse
                )
            }

            try performStep_confuse(
                step_confuse: .configureProject_confuse,
                runningDetail_confuse: "正在设置 iOS 16.0、版本号和设备范围。",
                completedDetail_confuse: "工程参数已设置为 iPhone、iOS 16.0 和 1.0.0。",
                progressHandler_confuse: progressHandler_confuse
            ) {
                try configureProject_confuse(
                    destinationRootURL_confuse: destinationRootURL_confuse,
                    projectName_confuse: request_confuse.projectName_confuse
                )
            }

            try performStep_confuse(
                step_confuse: .cleanFiles_confuse,
                runningDetail_confuse: "正在移除场景代理、默认控制器和用户数据。",
                completedDetail_confuse: "默认文件和场景配置已清理。",
                progressHandler_confuse: progressHandler_confuse
            ) {
                try cleanGeneratedFiles_confuse(
                    destinationRootURL_confuse: destinationRootURL_confuse,
                    projectName_confuse: request_confuse.projectName_confuse
                )
            }

            try performStep_confuse(
                step_confuse: .writeInformation_confuse,
                runningDetail_confuse: "正在写入隐私权限和网络访问配置。",
                completedDetail_confuse: "应用信息和隐私权限已写入。",
                progressHandler_confuse: progressHandler_confuse
            ) {
                try writeInformationPropertyList_confuse(
                    destinationRootURL_confuse: destinationRootURL_confuse,
                    projectName_confuse: request_confuse.projectName_confuse
                )
            }

            try performStep_confuse(
                step_confuse: .copyModules_confuse,
                runningDetail_confuse: "正在复制基础业务模块和应用代理。",
                completedDetail_confuse: "基础业务模块和应用代理已复制。",
                progressHandler_confuse: progressHandler_confuse
            ) {
                try copyModules_confuse(
                    templateURL_confuse: templateURL_confuse,
                    destinationRootURL_confuse: destinationRootURL_confuse,
                    projectName_confuse: request_confuse.projectName_confuse
                )
            }

            try performStep_confuse(
                step_confuse: .createAssets_confuse,
                runningDetail_confuse: "正在创建五个资源文件夹。",
                completedDetail_confuse: "Data、User、Pro、Store、App 资源文件夹已创建。",
                progressHandler_confuse: progressHandler_confuse
            ) {
                try createAssetFolders_confuse(
                    destinationRootURL_confuse: destinationRootURL_confuse,
                    projectName_confuse: request_confuse.projectName_confuse
                )
            }

            try performStep_confuse(
                step_confuse: .runRenameScript_confuse,
                runningDetail_confuse: "正在执行源码重命名脚本。",
                completedDetail_confuse: "源码重命名完成，临时脚本已删除。",
                progressHandler_confuse: progressHandler_confuse
            ) {
                try runRenameScript_confuse(
                    templateURL_confuse: templateURL_confuse,
                    destinationRootURL_confuse: destinationRootURL_confuse
                )
            }
            return destinationRootURL_confuse
        } catch let error_confuse as ProjectInitializationError_confuse {
            try? fileManager_confuse.removeItem(at: destinationRootURL_confuse)
            throw error_confuse
        } catch {
            try? fileManager_confuse.removeItem(at: destinationRootURL_confuse)
            throw ProjectInitializationError_confuse.operationFailed_confuse
        }
    }

    /// 发送单步开始和完成事件并执行对应操作。
    /// - Parameters:
    ///   - step_confuse: 当前执行步骤。
    ///   - runningDetail_confuse: 步骤运行中的说明。
    ///   - completedDetail_confuse: 步骤完成后的说明。
    ///   - progressHandler_confuse: 进度回调。
    ///   - operation_confuse: 当前步骤的文件操作。
    /// - Throws: 当前步骤操作失败时原样抛出错误。
    private static func performStep_confuse(
        step_confuse: ProjectInitializationStep_confuse,
        runningDetail_confuse: String,
        completedDetail_confuse: String,
        progressHandler_confuse: (ProjectInitializationProgress_confuse) -> Void,
        operation_confuse: () throws -> Void
    ) throws {
        progressHandler_confuse(ProjectInitializationProgress_confuse(
            step_confuse: step_confuse,
            state_confuse: .running_confuse,
            detail_confuse: runningDetail_confuse
        ))
        try operation_confuse()
        progressHandler_confuse(ProjectInitializationProgress_confuse(
            step_confuse: step_confuse,
            state_confuse: .completed_confuse,
            detail_confuse: completedDetail_confuse
        ))
    }

    /// 返回应用包内的 Swift 模板目录。
    /// - Returns: 可读取的模板目录 URL。
    /// - Throws: 打包资源中不存在模板目录时抛出错误。
    private static func templateDirectoryURL_confuse() throws -> URL {
        let candidates_confuse = [
            Bundle.module.url(
                forResource: "SwiftTemplate_confuse",
                withExtension: nil,
                subdirectory: "Resources"
            ),
            Bundle.module.resourceURL?.appendingPathComponent("Resources/SwiftTemplate_confuse", isDirectory: true),
            Bundle.module.resourceURL?.appendingPathComponent("SwiftTemplate_confuse", isDirectory: true)
        ].compactMap { $0 }
        guard let templateURL_confuse = candidates_confuse.first(where: {
            FileManager.default.fileExists(atPath: $0.path)
        }) else {
            throw ProjectInitializationError_confuse.templateMissing_confuse
        }
        return templateURL_confuse
    }

    /// 创建项目根目录、源码目录和基础 Xcode 文件。
    /// - Parameters:
    ///   - templateURL_confuse: 内置模板目录。
    ///   - destinationRootURL_confuse: 新项目根目录。
    ///   - projectName_confuse: 用户输入的项目名称。
    /// - Throws: 模板结构缺失或复制失败时抛出错误。
    private static func createStructure_confuse(
        templateURL_confuse: URL,
        destinationRootURL_confuse: URL,
        projectName_confuse: String
    ) throws {
        let fileManager_confuse = FileManager.default
        let templateSourceURL_confuse = templateURL_confuse.appendingPathComponent(TEMPLATE_PROJECT_NAME_CONFUSE)
        let templateProjectURL_confuse = templateURL_confuse
            .appendingPathComponent(TEMPLATE_PROJECT_NAME_CONFUSE)
            .appendingPathExtension("xcodeproj")
        guard fileManager_confuse.fileExists(atPath: templateSourceURL_confuse.path),
              fileManager_confuse.fileExists(atPath: templateProjectURL_confuse.path) else {
            throw ProjectInitializationError_confuse.invalidTemplate_confuse
        }

        try fileManager_confuse.createDirectory(
            at: destinationRootURL_confuse,
            withIntermediateDirectories: true
        )
        let destinationSourceURL_confuse = destinationRootURL_confuse
            .appendingPathComponent(projectName_confuse, isDirectory: true)
        try fileManager_confuse.createDirectory(
            at: destinationSourceURL_confuse,
            withIntermediateDirectories: true
        )
        try fileManager_confuse.copyItem(
            at: templateProjectURL_confuse,
            to: destinationRootURL_confuse
                .appendingPathComponent(projectName_confuse)
                .appendingPathExtension("xcodeproj")
        )
        for itemName_confuse in ["Assets.xcassets", "Base.lproj", "Info.plist"] {
            try fileManager_confuse.copyItem(
                at: templateSourceURL_confuse.appendingPathComponent(itemName_confuse),
                to: destinationSourceURL_confuse.appendingPathComponent(itemName_confuse)
            )
        }
        let templatePodfileURL_confuse = templateURL_confuse.appendingPathComponent("Podfile")
        if fileManager_confuse.fileExists(atPath: templatePodfileURL_confuse.path) {
            try fileManager_confuse.copyItem(
                at: templatePodfileURL_confuse,
                to: destinationRootURL_confuse.appendingPathComponent("Podfile")
            )
        }
    }

    /// 修改项目名称、部署版本、应用版本、设备范围和依赖配置。
    /// - Parameters:
    ///   - destinationRootURL_confuse: 新项目根目录。
    ///   - projectName_confuse: 用户输入的项目名称。
    /// - Throws: 工程配置文件无法读取或写入时抛出错误。
    private static func configureProject_confuse(
        destinationRootURL_confuse: URL,
        projectName_confuse: String
    ) throws {
        let projectFileURL_confuse = destinationRootURL_confuse
            .appendingPathComponent(projectName_confuse)
            .appendingPathExtension("xcodeproj")
            .appendingPathComponent("project.pbxproj")
        var projectContent_confuse = try String(contentsOf: projectFileURL_confuse, encoding: .utf8)
        projectContent_confuse = projectContent_confuse.replacingOccurrences(
            of: TEMPLATE_PROJECT_NAME_CONFUSE,
            with: projectName_confuse
        )
        let bundleSuffix_confuse = projectName_confuse.lowercased().replacingOccurrences(of: "_", with: "-")
        projectContent_confuse = replacingMatches_confuse(
            pattern_confuse: "IPHONEOS_DEPLOYMENT_TARGET = [^;]+;",
            content_confuse: projectContent_confuse,
            replacement_confuse: "IPHONEOS_DEPLOYMENT_TARGET = 16.0;"
        )
        projectContent_confuse = replacingMatches_confuse(
            pattern_confuse: "MARKETING_VERSION = [^;]+;",
            content_confuse: projectContent_confuse,
            replacement_confuse: "MARKETING_VERSION = 1.0.0;"
        )
        projectContent_confuse = replacingMatches_confuse(
            pattern_confuse: "PRODUCT_BUNDLE_IDENTIFIER = [^;]+;",
            content_confuse: projectContent_confuse,
            replacement_confuse: "PRODUCT_BUNDLE_IDENTIFIER = \"com.ornaments.\(bundleSuffix_confuse)\";"
        )
        projectContent_confuse = replacingMatches_confuse(
            pattern_confuse: "TARGETED_DEVICE_FAMILY = [^;]+;",
            content_confuse: projectContent_confuse,
            replacement_confuse: "TARGETED_DEVICE_FAMILY = 1;"
        )
        projectContent_confuse = replacingMatches_confuse(
            pattern_confuse: "[\\t ]*INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = [^;]+;\\n",
            content_confuse: projectContent_confuse,
            replacement_confuse: ""
        )
        try projectContent_confuse.write(to: projectFileURL_confuse, atomically: true, encoding: .utf8)
        try configurePodfile_confuse(
            destinationRootURL_confuse: destinationRootURL_confuse,
            projectName_confuse: projectName_confuse
        )
    }

    /// 清理场景代理、默认控制器和 Xcode 用户数据目录。
    /// - Parameters:
    ///   - destinationRootURL_confuse: 新项目根目录。
    ///   - projectName_confuse: 用户输入的项目名称。
    /// - Throws: 文件删除失败时抛出错误。
    private static func cleanGeneratedFiles_confuse(
        destinationRootURL_confuse: URL,
        projectName_confuse: String
    ) throws {
        let fileManager_confuse = FileManager.default
        let sourceURL_confuse = destinationRootURL_confuse.appendingPathComponent(projectName_confuse)
        for fileName_confuse in ["SceneDelegate.swift", "ViewController.swift"] {
            let fileURL_confuse = sourceURL_confuse.appendingPathComponent(fileName_confuse)
            if fileManager_confuse.fileExists(atPath: fileURL_confuse.path) {
                try fileManager_confuse.removeItem(at: fileURL_confuse)
            }
        }
        let userDataURLs_confuse = recursiveURLs_confuse(rootURL_confuse: destinationRootURL_confuse)
            .filter { $0.lastPathComponent == "xcuserdata" }
            .sorted { $0.pathComponents.count > $1.pathComponents.count }
        for userDataURL_confuse in userDataURLs_confuse {
            if fileManager_confuse.fileExists(atPath: userDataURL_confuse.path) {
                try fileManager_confuse.removeItem(at: userDataURL_confuse)
            }
        }
    }

    /// 写入用户要求的隐私用途说明和网络安全配置，并移除场景清单。
    /// - Parameters:
    ///   - destinationRootURL_confuse: 新项目根目录。
    ///   - projectName_confuse: 用户输入的项目名称。
    /// - Throws: 属性列表序列化或写入失败时抛出错误。
    private static func writeInformationPropertyList_confuse(
        destinationRootURL_confuse: URL,
        projectName_confuse: String
    ) throws {
        let information_confuse: [String: Any] = [
            "NSLocationWhenInUseUsageDescription": "\(projectName_confuse) requires your consent to obtain location information when using it in order to upload photos or update avatars. If prohibited, you will not be able to publish works/update avatars.",
            "NSPhotoLibraryUsageDescription": "\(projectName_confuse) needs your consent to access the album to select photos to upload/publish works/update avatars. If prohibited, you will not be able to upload selected photos to upload/publish works/update avatars.",
            "NSLocationAlwaysAndWhenInUseUsageDescription": "\(projectName_confuse) requires your consent to obtain location information when using it in order to upload photos or update avatars. If prohibited, you will not be able to publish works/update avatars.",
            "NSLocationAlwaysUsageDescription": "\(projectName_confuse) requires your consent to obtain location information when using it in order to upload photos or update avatars. If prohibited, you will not be able to publish works/update avatars.",
            "NSPhotoLibraryAddUsageDescription": "\(projectName_confuse) needs your consent to access the album in order to save the work. If it is prohibited, you will not be able to save your work to the album.",
            "NSAppTransportSecurity": ["NSAllowsArbitraryLoads": true],
            "NSCameraUsageDescription": "\(projectName_confuse) needs your consent to access the camera to shoot personal works/personal portraits. If prohibited, you will not be able to take photos or update information.",
            "NSMicrophoneUsageDescription": "\(projectName_confuse) needs your permission to access the microphone. If blocked, you will not be able to send audio messages to users."
        ]
        let data_confuse = try PropertyListSerialization.data(
            fromPropertyList: information_confuse,
            format: .xml,
            options: 0
        )
        let informationURL_confuse = destinationRootURL_confuse
            .appendingPathComponent(projectName_confuse)
            .appendingPathComponent("Info.plist")
        try data_confuse.write(to: informationURL_confuse, options: [.atomic])
    }

    /// 复制指定业务目录和模板应用代理。
    /// - Parameters:
    ///   - templateURL_confuse: 内置模板目录。
    ///   - destinationRootURL_confuse: 新项目根目录。
    ///   - projectName_confuse: 用户输入的项目名称。
    /// - Throws: 模板目录缺失或复制失败时抛出错误。
    private static func copyModules_confuse(
        templateURL_confuse: URL,
        destinationRootURL_confuse: URL,
        projectName_confuse: String
    ) throws {
        let fileManager_confuse = FileManager.default
        let templateSourceURL_confuse = templateURL_confuse.appendingPathComponent(TEMPLATE_PROJECT_NAME_CONFUSE)
        let destinationSourceURL_confuse = destinationRootURL_confuse.appendingPathComponent(projectName_confuse)
        for itemName_confuse in MODULE_NAMES_CONFUSE + ["AppDelegate.swift"] {
            let sourceURL_confuse = templateSourceURL_confuse.appendingPathComponent(itemName_confuse)
            guard fileManager_confuse.fileExists(atPath: sourceURL_confuse.path) else {
                throw ProjectInitializationError_confuse.invalidTemplate_confuse
            }
            try fileManager_confuse.copyItem(
                at: sourceURL_confuse,
                to: destinationSourceURL_confuse.appendingPathComponent(itemName_confuse)
            )
        }
    }

    /// 在资源目录中创建 Data、User、Pro、Store 和 App 五个实体文件夹。
    /// - Parameters:
    ///   - destinationRootURL_confuse: 新项目根目录。
    ///   - projectName_confuse: 用户输入的项目名称。
    /// - Throws: 目录或资源描述文件创建失败时抛出错误。
    private static func createAssetFolders_confuse(
        destinationRootURL_confuse: URL,
        projectName_confuse: String
    ) throws {
        let fileManager_confuse = FileManager.default
        let assetCatalogURL_confuse = destinationRootURL_confuse
            .appendingPathComponent(projectName_confuse)
            .appendingPathComponent("Assets.xcassets")
        let contents_confuse: [String: Any] = [
            "info": ["author": "xcode", "version": 1]
        ]
        let contentsData_confuse = try JSONSerialization.data(
            withJSONObject: contents_confuse,
            options: [.prettyPrinted, .sortedKeys]
        )
        for folderName_confuse in ASSET_FOLDER_NAMES_CONFUSE {
            let folderURL_confuse = assetCatalogURL_confuse
                .appendingPathComponent(folderName_confuse, isDirectory: true)
            try fileManager_confuse.createDirectory(
                at: folderURL_confuse,
                withIntermediateDirectories: true
            )
            try contentsData_confuse.write(
                to: folderURL_confuse.appendingPathComponent("Contents.json"),
                options: [.atomic]
            )
        }
    }

    /// 将重命名脚本复制到项目根目录执行，并在结束后删除临时脚本。
    /// - Parameters:
    ///   - templateURL_confuse: 内置模板目录。
    ///   - destinationRootURL_confuse: 新项目根目录。
    /// - Throws: 脚本缺失、无法执行或返回失败结果时抛出错误。
    private static func runRenameScript_confuse(
        templateURL_confuse: URL,
        destinationRootURL_confuse: URL
    ) throws {
        let fileManager_confuse = FileManager.default
        let sourceScriptURL_confuse = templateURL_confuse.appendingPathComponent("rename_auto.py")
        guard fileManager_confuse.fileExists(atPath: sourceScriptURL_confuse.path) else {
            throw ProjectInitializationError_confuse.invalidTemplate_confuse
        }
        let destinationScriptURL_confuse = destinationRootURL_confuse.appendingPathComponent("rename_auto.py")
        try fileManager_confuse.copyItem(at: sourceScriptURL_confuse, to: destinationScriptURL_confuse)
        defer { try? fileManager_confuse.removeItem(at: destinationScriptURL_confuse) }

        let process_confuse = Process()
        let outputPipe_confuse = Pipe()
        let errorPipe_confuse = Pipe()
        process_confuse.executableURL = URL(fileURLWithPath: "/usr/bin/python3")
        process_confuse.arguments = [destinationScriptURL_confuse.path]
        process_confuse.currentDirectoryURL = destinationRootURL_confuse
        process_confuse.standardOutput = outputPipe_confuse
        process_confuse.standardError = errorPipe_confuse
        do {
            try process_confuse.run()
        } catch {
            throw ProjectInitializationError_confuse.renameFailed_confuse
        }
        process_confuse.waitUntilExit()
        let outputData_confuse = outputPipe_confuse.fileHandleForReading.readDataToEndOfFile()
        let output_confuse = String(data: outputData_confuse, encoding: .utf8) ?? ""
        guard process_confuse.terminationStatus == 0,
              output_confuse.contains("所有操作已完成") else {
            throw ProjectInitializationError_confuse.renameFailed_confuse
        }
    }

    /// 更新项目根目录中的 Podfile 名称和最低系统版本。
    /// - Parameters:
    ///   - destinationRootURL_confuse: 新项目根目录。
    ///   - projectName_confuse: 用户输入的项目名称。
    /// - Throws: Podfile 无法读取或写入时抛出错误。
    private static func configurePodfile_confuse(
        destinationRootURL_confuse: URL,
        projectName_confuse: String
    ) throws {
        let podfileURL_confuse = destinationRootURL_confuse.appendingPathComponent("Podfile")
        guard FileManager.default.fileExists(atPath: podfileURL_confuse.path) else { return }
        var podfileContent_confuse = try String(contentsOf: podfileURL_confuse, encoding: .utf8)
        podfileContent_confuse = podfileContent_confuse.replacingOccurrences(
            of: "target '\(TEMPLATE_PROJECT_NAME_CONFUSE)'",
            with: "target '\(projectName_confuse)'"
        )
        podfileContent_confuse = podfileContent_confuse.replacingOccurrences(
            of: "'15.0'",
            with: "'16.0'"
        )
        if !podfileContent_confuse.contains("platform :ios") {
            podfileContent_confuse = "platform :ios, '16.0'\n\n\(podfileContent_confuse)"
        }
        try podfileContent_confuse.write(to: podfileURL_confuse, atomically: true, encoding: .utf8)
    }

    /// 返回根目录下的全部子目录和文件 URL。
    /// - Parameter rootURL_confuse: 递归扫描的根目录。
    /// - Returns: 枚举成功时返回全部 URL，否则返回空数组。
    private static func recursiveURLs_confuse(rootURL_confuse: URL) -> [URL] {
        guard let enumerator_confuse = FileManager.default.enumerator(
            at: rootURL_confuse,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else { return [] }
        return enumerator_confuse.compactMap { $0 as? URL }
    }

    /// 使用正则表达式替换工程配置中的目标字段。
    /// - Parameters:
    ///   - pattern_confuse: 需要匹配的正则表达式。
    ///   - content_confuse: 原始工程配置文本。
    ///   - replacement_confuse: 替换后的配置文本。
    /// - Returns: 替换后的完整工程配置。
    private static func replacingMatches_confuse(
        pattern_confuse: String,
        content_confuse: String,
        replacement_confuse: String
    ) -> String {
        guard let expression_confuse = try? NSRegularExpression(pattern: pattern_confuse) else {
            return content_confuse
        }
        let range_confuse = NSRange(content_confuse.startIndex..., in: content_confuse)
        return expression_confuse.stringByReplacingMatches(
            in: content_confuse,
            range: range_confuse,
            withTemplate: replacement_confuse
        )
    }
}
