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

/// 描述提交自动化下的二级菜单，目前仅用于导航展示。
enum SubmissionAutomationMenu_confuse: String, CaseIterable, Identifiable {
    case codeMagic_confuse = "code_magic"
    case agreement_confuse = "agreement"
    case materials_confuse = "materials"
    case backend_confuse = "backend"

    /// 返回用于 SwiftUI 列表稳定标识的菜单值。
    var id: String { rawValue }

    /// 返回提交自动化二级菜单的中文名称。
    var displayName_confuse: String {
        switch self {
        case .codeMagic_confuse: return "提交云端构建"
        case .agreement_confuse: return "协议处理"
        case .materials_confuse: return "整理资料"
        case .backend_confuse: return "填写后台"
        }
    }
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
