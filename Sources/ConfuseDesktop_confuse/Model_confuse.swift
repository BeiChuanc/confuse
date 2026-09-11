import Foundation

/// 描述当前支持的工程类别，并为界面提供稳定的展示值。
enum ProjectType_confuse: String, CaseIterable, Identifiable, Sendable {
    case swift_confuse = "swift"
    case flutter_confuse = "flutter"

    /// 返回用于 SwiftUI 列表稳定标识的工程类别值。
    var id: String { rawValue }

    /// 返回界面展示的中文名称。
    var displayName_confuse: String {
        switch self {
        case .swift_confuse: return "Swift"
        case .flutter_confuse: return "Flutter"
        }
    }
}

/// 描述 Swift 项目初始化流程中的固定步骤，用于进度展示和状态更新。
enum ProjectInitializationStep_confuse: Int, CaseIterable, Identifiable, Sendable {
    case createStructure_confuse
    case configureProject_confuse
    case cleanFiles_confuse
    case writeInformation_confuse
    case copyModules_confuse
    case createAssets_confuse
    case runRenameScript_confuse

    /// 返回步骤的稳定标识。
    var id: Int { rawValue }

    /// 返回步骤的中文展示名称。
    var displayName_confuse: String {
        switch self {
        case .createStructure_confuse: return "创建项目结构"
        case .configureProject_confuse: return "配置工程参数"
        case .cleanFiles_confuse: return "清理默认文件"
        case .writeInformation_confuse: return "写入应用信息"
        case .copyModules_confuse: return "复制基础模块"
        case .createAssets_confuse: return "创建资源目录"
        case .runRenameScript_confuse: return "执行重命名脚本"
        }
    }
}

/// 描述初始化步骤的运行状态。
enum ProjectInitializationStepState_confuse: Equatable, Sendable {
    case pending_confuse
    case running_confuse
    case completed_confuse
}

/// 保存一次项目初始化所需的名称、类型和目标目录。
struct ProjectInitializationRequest_confuse: Sendable {
    let projectName_confuse: String
    let projectType_confuse: ProjectType_confuse
    let destinationDirectoryPath_confuse: String
}

/// 描述初始化服务发出的单步进度更新。
struct ProjectInitializationProgress_confuse: Sendable {
    let step_confuse: ProjectInitializationStep_confuse
    let state_confuse: ProjectInitializationStepState_confuse
    let detail_confuse: String
}

/// 描述本次混淆任务的操作类型。
enum OperationMode_confuse: String, CaseIterable, Identifiable {
    case obfuscate_confuse = "obfuscate"
    case deobfuscate_confuse = "deobfuscate"
    case merge_confuse = "merge"

    /// 返回用于 SwiftUI 列表稳定标识的操作值。
    var id: String { rawValue }

    /// 返回界面展示的中文名称。
    var displayName_confuse: String {
        switch self {
        case .obfuscate_confuse: return "混淆项目"
        case .deobfuscate_confuse: return "混淆回归"
        case .merge_confuse: return "增量混淆"
        }
    }
}

/// 描述应用左侧的五个一级功能菜单。
enum PrimaryMenu_confuse: String, CaseIterable, Identifiable {
    case initialize_confuse = "initialize"
    case obfuscation_confuse = "obfuscation"
    case submission_confuse = "submission"
    case monitoring_confuse = "monitoring"
    case settings_confuse = "settings"

    /// 返回用于 SwiftUI 列表稳定标识的菜单值。
    var id: String { rawValue }

    /// 返回一级菜单的中文名称。
    var displayName_confuse: String {
        switch self {
        case .initialize_confuse: return "初始化项目"
        case .obfuscation_confuse: return "混淆程序"
        case .submission_confuse: return "提交自动化"
        case .monitoring_confuse: return "监控审核"
        case .settings_confuse: return "设置"
        }
    }

    /// 返回一级菜单对应的 SF Symbols 图标名称。
    var iconName_confuse: String {
        switch self {
        case .initialize_confuse: return "shippingbox"
        case .obfuscation_confuse: return "wand.and.stars"
        case .submission_confuse: return "arrow.up.doc"
        case .monitoring_confuse: return "checkmark.seal"
        case .settings_confuse: return "gearshape"
        }
    }

    /// 返回当前一级菜单是否包含可展开的二级菜单。
    var hasSubmenu_confuse: Bool {
        switch self {
        case .obfuscation_confuse, .submission_confuse, .monitoring_confuse:
            return true
        case .initialize_confuse, .settings_confuse:
            return false
        }
    }
}

/// 描述主题强调色的组合方式，单色模式统一使用主色，混色模式同时使用主色与辅助色。
enum ThemeColorMode_confuse: String, CaseIterable, Identifiable {
    case solid_confuse = "solid"
    case blended_confuse = "blended"

    /// 返回用于 SwiftUI 列表稳定标识的主题模式值。
    var id: String { rawValue }

    /// 返回主题模式的中文名称。
    var displayName_confuse: String {
        switch self {
        case .solid_confuse: return "单色"
        case .blended_confuse: return "混色"
        }
    }
}

/// 描述侧边栏底部可展示的桌宠，保留关闭状态并接入用户选定的轨道探针。
enum SidebarPet_confuse: String, CaseIterable, Identifiable {
    case hidden_confuse = "hidden"
    case orbitProbe_confuse = "orbit_probe"

    /// 返回用于 SwiftUI 列表稳定标识的桌宠值。
    var id: String { rawValue }

    /// 返回桌宠的中文名称。
    var displayName_confuse: String {
        switch self {
        case .hidden_confuse: return "不显示"
        case .orbitProbe_confuse: return "轨道探针"
        }
    }
}

/// 保存一组可复用的主题预设颜色，供设置页面快速应用。
struct ThemePreset_confuse: Identifiable, Hashable {
    let id_confuse: String
    let name_confuse: String
    let primaryHex_confuse: String
    let secondaryHex_confuse: String

    /// 返回主题预设的稳定标识。
    var id: String { id_confuse }
}

/// 描述提交自动化下的二级菜单，用于导航已实现与待接入功能。
enum SubmissionAutomationMenu_confuse: String, CaseIterable, Identifiable {
    case codeMagic_confuse = "code_magic"
    case materials_confuse = "materials"
    case package_confuse = "package"
    case backend_confuse = "backend"

    /// 返回用于 SwiftUI 列表稳定标识的菜单值。
    var id: String { rawValue }

    /// 返回提交自动化二级菜单的中文名称。
    var displayName_confuse: String {
        switch self {
        case .codeMagic_confuse: return "云端构建"
        case .materials_confuse: return "整理资料"
        case .package_confuse: return "合包整理"
        case .backend_confuse: return "填写后台"
        }
    }
}

/// 描述合包整理支持的项目语言，并提供中文显示名称。
enum PackageLanguage_confuse: String, CaseIterable, Identifiable, Sendable {
    case swift_confuse = "Swift"
    case flutter_confuse = "Flutter"

    /// 返回用于 SwiftUI 列表稳定标识的语言值。
    var id: String { rawValue }

    /// 返回语言的中文显示名称。
    var displayName_confuse: String { rawValue }
}

/// 描述合包整理支持的业务类型，并提供目录匹配名称。
enum PackageType_confuse: String, CaseIterable, Identifiable, Sendable {
    case video20_confuse = "Video 2.0"
    case social20_confuse = "Social 2.0"
    case social40_confuse = "Social 4.0"

    /// 返回用于 SwiftUI 列表稳定标识的合包类型值。
    var id: String { rawValue }

    /// 返回合包类型的中文显示名称。
    var displayName_confuse: String {
        switch self {
        case .video20_confuse: return "视频 2.0"
        case .social20_confuse: return "社交 2.0"
        case .social40_confuse: return "社交 4.0"
        }
    }
}

/// 描述 Swift 合包前对目标工程和合包代码的检查结果。
struct SwiftPackageInspection_confuse: Sendable {
    let targetRootPath_confuse: String
    let appDelegatePath_confuse: String
    let targetPodfilePath_confuse: String
    let bundleID_confuse: String
    let packageFiles_confuse: [String]
    let missingPackageFiles_confuse: [String]
    let hasFacebook_confuse: Bool

    /// 返回目标工程是否具备执行 Swift 合包的基本条件。
    var isReady_confuse: Bool {
        !targetRootPath_confuse.isEmpty
            && !appDelegatePath_confuse.isEmpty
            && !targetPodfilePath_confuse.isEmpty
            && !bundleID_confuse.isEmpty
            && missingPackageFiles_confuse.isEmpty
    }
}

/// 描述合包流程中的一个进度事件。
struct PackageAssemblyProgress_confuse: Sendable {
    let progress_confuse: Double
    let detail_confuse: String
}

/// 保存后台登录凭据和目标项目 Bundle ID，仅用于单次后台配置读取任务。
struct BackendConfigurationRequest_confuse: Codable, Sendable {
    let account_confuse: String
    let password_confuse: String
    let twoFactorCode_confuse: String
    let bundleID_confuse: String
}

/// 保存从苹果马甲包后台读取的合包配置，并作为工程写入的唯一数据来源。
struct BackendConfiguration_confuse: Codable, Equatable, Sendable {
    let bundleID_confuse: String
    let appsFlyerDevKey_confuse: String
    let appleAppID_confuse: String
    let configurationDomain_confuse: String
    let requestDomain_confuse: String
    let facebookAppID_confuse: String
    let facebookClientToken_confuse: String
    let facebookDisplayName_confuse: String
    let hasFacebook_confuse: Bool
}

/// 描述后台配置自动化脚本输出的进度、配置结果或错误事件。
struct BackendConfigurationEvent_confuse: Codable, Sendable {
    let event_confuse: String
    let state_confuse: String?
    let message_confuse: String?
    let progress_confuse: Double?
    let ok_confuse: Bool?
    let configuration_confuse: BackendConfiguration_confuse?
    let error_confuse: String?
}

/// 保存一次 Codemagic 云端构建自动化需要提交的项目、密钥和 API 文件信息。
struct CodeMagicAutomationRequest_confuse: Codable, Sendable {
    let projectPath_confuse: String
    let projectName_confuse: String
    let bundleID_confuse: String
    let issuerID_confuse: String
    let keyID_confuse: String
    let apiKeyPath_confuse: String
    let steps_confuse: [String]
}

/// 描述 Codemagic 云端构建自动化的三个可独立执行步骤。
enum CodeMagicStep_confuse: String, CaseIterable, Identifiable, Codable, Sendable {
    case apiKey_confuse = "api_key"
    case certificate_confuse = "certificate"
    case profile_confuse = "profile"

    /// 返回 SwiftUI 列表使用的稳定标识。
    var id: String { rawValue }

    /// 返回步骤在云端构建页面中的中文名称。
    var displayName_confuse: String {
        switch self {
        case .apiKey_confuse: return "创建 API 密钥"
        case .certificate_confuse: return "生成证书"
        case .profile_confuse: return "获取描述文件"
        }
    }

    /// 返回步骤用途的英文说明。
    var description_confuse: String {
        switch self {
        case .apiKey_confuse: return "将 App Store Connect API 密钥添加到开发者门户集成。"
        case .certificate_confuse: return "生成 Apple Distribution 分发证书。"
        case .profile_confuse: return "获取并保存与项目匹配的 App Store 描述文件。"
        }
    }

    /// 返回步骤对应的 SF Symbols 图标名称。
    var iconName_confuse: String {
        switch self {
        case .apiKey_confuse: return "key.fill"
        case .certificate_confuse: return "checkmark.seal.fill"
        case .profile_confuse: return "doc.badge.arrow.up.fill"
        }
    }
}

/// 描述 Codemagic 自动化脚本输出的进度、完成状态或错误事件。
struct CodeMagicAutomationEvent_confuse: Codable, Sendable {
    let event_confuse: String
    let step_confuse: String?
    let state_confuse: String?
    let message_confuse: String?
    let progress_confuse: Double?
    let ok_confuse: Bool?
    let error_confuse: String?
}

/// 描述协议自动化支持的三种协议类型及其生成顺序。
enum AgreementType_confuse: String, CaseIterable, Identifiable, Codable, Sendable {
    case privacy_confuse = "privacy"
    case terms_confuse = "terms"
    case eula_confuse = "eula"

    /// 返回 SwiftUI 使用的稳定标识。
    var id: String { rawValue }

    /// 返回协议类型的中文名称。
    var displayName_confuse: String {
        switch self {
        case .privacy_confuse: return "隐私政策"
        case .terms_confuse: return "使用条款"
        case .eula_confuse: return "最终用户许可协议"
        }
    }

    /// 返回协议用途的简短中文说明。
    var description_confuse: String {
        switch self {
        case .privacy_confuse: return "说明用户数据、设备权限和隐私处理方式。"
        case .terms_confuse: return "说明用户使用应用时需要遵守的服务条款。"
        case .eula_confuse: return "说明移动应用许可范围和知识产权约定。"
        }
    }

    /// 返回协议类型对应的 SF Symbols 图标名称。
    var iconName_confuse: String {
        switch self {
        case .privacy_confuse: return "hand.raised.fill"
        case .terms_confuse: return "doc.text.fill"
        case .eula_confuse: return "signature"
        }
    }
}

/// 描述单项协议自动化当前所处的运行状态。
enum AgreementGenerationState_confuse: Equatable, Sendable {
    case pending_confuse
    case running_confuse
    case completed_confuse
    case failed_confuse
}

/// 保存一次协议自动化需要提交给生成器的应用信息和协议范围。
struct AgreementAutomationRequest_confuse: Codable, Sendable {
    let appName_confuse: String
    let email_confuse: String
    let agreementTypes_confuse: [String]
}

/// 描述协议自动化脚本输出的进度、链接或最终结果事件。
struct AgreementAutomationEvent_confuse: Codable, Sendable {
    let event_confuse: String
    let agreementType_confuse: String?
    let state_confuse: String?
    let message_confuse: String?
    let progress_confuse: Double?
    let link_confuse: String?
    let ok_confuse: Bool?
    let links_confuse: [String: String]?
    let error_confuse: String?
}

/// 描述整理资料页面需要从飞书记录中读取的字段，并提供统一标题和图标。
enum MaterialField_confuse: String, CaseIterable, Identifiable, Sendable {
    case uiNumber_confuse
    case developerAccount_confuse
    case softwareName_confuse
    case bundleID_confuse
    case appID_confuse
    case storeReviewCredential_confuse
    case phoneNumber_confuse
    case bankCard_confuse
    case routingABA_confuse

    /// 返回 SwiftUI 列表使用的稳定标识。
    var id: String { rawValue }

    /// 返回资料字段的中文名称。
    var displayName_confuse: String {
        switch self {
        case .uiNumber_confuse: return "UI 编号"
        case .developerAccount_confuse: return "开发者账号"
        case .softwareName_confuse: return "软件名"
        case .bundleID_confuse: return "Bundle ID"
        case .appID_confuse: return "App ID"
        case .storeReviewCredential_confuse: return "商店审核账号密码"
        case .phoneNumber_confuse: return "手机号"
        case .bankCard_confuse: return "银行卡"
        case .routingABA_confuse: return "路由 ABA"
        }
    }

    /// 返回资料字段对应的 SF Symbols 图标名称。
    var iconName_confuse: String {
        switch self {
        case .uiNumber_confuse: return "number.square"
        case .developerAccount_confuse: return "person.crop.circle"
        case .softwareName_confuse: return "app"
        case .bundleID_confuse: return "shippingbox"
        case .appID_confuse: return "number"
        case .storeReviewCredential_confuse: return "key"
        case .phoneNumber_confuse: return "phone"
        case .bankCard_confuse: return "creditcard"
        case .routingABA_confuse: return "building.columns"
        }
    }

}

/// 保存从飞书项目记录中读取的 UI 编号和八项提交资料，数据仅在当前应用进程内使用。
struct MaterialRecord_confuse: Codable, Equatable, Sendable {
    let uiNumber_confuse: String
    let developerAccount_confuse: String
    let softwareName_confuse: String
    let bundleID_confuse: String
    let appID_confuse: String
    let storeReviewCredential_confuse: String
    let phoneNumber_confuse: String
    let bankCard_confuse: String
    let routingABA_confuse: String

    /// 返回指定资料字段的当前值。
    /// - Parameter field_confuse: 需要读取的字段类型。
    /// - Returns: 飞书记录中的字段值；未填写时返回空字符串。
    func value_confuse(field_confuse: MaterialField_confuse) -> String {
        switch field_confuse {
        case .uiNumber_confuse: return uiNumber_confuse
        case .developerAccount_confuse: return developerAccount_confuse
        case .softwareName_confuse: return softwareName_confuse
        case .bundleID_confuse: return bundleID_confuse
        case .appID_confuse: return appID_confuse
        case .storeReviewCredential_confuse: return storeReviewCredential_confuse
        case .phoneNumber_confuse: return phoneNumber_confuse
        case .bankCard_confuse: return bankCard_confuse
        case .routingABA_confuse: return routingABA_confuse
        }
    }
}

/// 保存一次飞书资料整理请求中的 UI 编号。
struct MaterialAutomationRequest_confuse: Codable, Sendable {
    let uiNumber_confuse: String
}

/// 描述飞书资料自动化脚本输出的进度、记录或错误事件。
struct MaterialAutomationEvent_confuse: Codable, Sendable {
    let event_confuse: String
    let state_confuse: String?
    let message_confuse: String?
    let progress_confuse: Double?
    let ok_confuse: Bool?
    let record_confuse: MaterialRecord_confuse?
    let error_confuse: String?
}

/// 描述监控审核下的二级菜单，目前仅用于导航展示。
enum MonitoringAuditMenu_confuse: String, CaseIterable, Identifiable {
    case status_confuse = "status"
    case records_confuse = "records"

    /// 返回用于 SwiftUI 列表稳定标识的菜单值。
    var id: String { rawValue }

    /// 返回监控审核二级菜单的中文名称。
    var displayName_confuse: String {
        switch self {
        case .status_confuse: return "审核状态"
        case .records_confuse: return "审核记录"
        }
    }
}

/// 描述混淆后标识符的生成规则，并提供界面说明和预览文本。
enum NamingRule_confuse: String, CaseIterable, Identifiable {
    case classic_confuse = "classic"
    case extended_confuse = "extended"
    case anonymous_confuse = "anonymous"

    /// 返回用于 SwiftUI 列表稳定标识的规则值。
    var id: String { rawValue }

    /// 返回界面展示的规则名称。
    var displayName_confuse: String {
        switch self {
        case .classic_confuse: return "经典"
        case .extended_confuse: return "增强"
        case .anonymous_confuse: return "匿名"
        }
    }

    /// 返回规则用途和生成格式说明。
    var description_confuse: String {
        switch self {
        case .classic_confuse: return "项目名 + 3 位数字 + 2 位小写字母"
        case .extended_confuse: return "项目名 + 8 位小写字母和数字"
        case .anonymous_confuse: return "字母开头的 12 位随机字母和数字，不包含项目名"
        }
    }

    /// 返回用于界面快速理解规则的示例。
    var example_confuse: String {
        switch self {
        case .classic_confuse: return "Wanderbell123ab"
        case .extended_confuse: return "Wanderbella8k2m5q9"
        case .anonymous_confuse: return "k8m2q5n7x4pz"
        }
    }
}

/// 描述传递给 Python 混淆引擎的完整任务参数。
struct EngineRequest_confuse: Codable, Sendable {
    let projectPath_confuse: String
    let projectType_confuse: String
    let suffixes_confuse: [String]
    let operation_confuse: String
    let namingRule_confuse: String
    let mappingDirectory_confuse: String
}

/// 描述 Python 混淆引擎执行后的统计信息和错误信息。
struct EngineResult_confuse: Codable, Sendable {
    let ok_confuse: Bool
    let operation_confuse: String?
    let mappingPath_confuse: String?
    let renamedFiles_confuse: Int?
    let updatedFiles_confuse: Int?
    let symbolCount_confuse: Int?
    let message_confuse: String?
    let error_confuse: String?
    let errorCode_confuse: String?
}
