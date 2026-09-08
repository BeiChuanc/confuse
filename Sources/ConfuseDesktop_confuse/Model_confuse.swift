import Foundation

/// 描述当前支持的工程类别，并为界面提供稳定的展示值。
enum ProjectType_confuse: String, CaseIterable, Identifiable {
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
        case .obfuscate_confuse: return "混淆"
        case .deobfuscate_confuse: return "反混淆"
        case .merge_confuse: return "合包混淆"
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
