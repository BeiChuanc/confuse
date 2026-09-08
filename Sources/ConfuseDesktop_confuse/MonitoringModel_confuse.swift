import Foundation

/// 描述审核状态所属分类，用于筛选、统计和统一状态配色。
enum MonitoringStatusCategory_confuse: String, CaseIterable, Identifiable, Codable, Sendable {
    case all_confuse = "all"
    case pipeline_confuse = "pipeline"
    case approved_confuse = "approved"
    case rejected_confuse = "rejected"
    case delisted_confuse = "delisted"
    case custom_confuse = "custom"

    /// 返回 SwiftUI 列表使用的稳定标识。
    var id: String { rawValue }

    /// 返回分类的界面展示名称。
    var displayName_confuse: String {
        switch self {
        case .all_confuse: return "全部状态"
        case .pipeline_confuse: return "审核流程"
        case .approved_confuse: return "已通过"
        case .rejected_confuse: return "已拒绝"
        case .delisted_confuse: return "已下架"
        case .custom_confuse: return "其他状态"
        }
    }
}

/// 集中维护 App Store Connect 状态名称与分类规则。
enum MonitoringStateCatalog_confuse {
    static let PIPELINE_STATES_CONFUSE: Set<String> = [
        "IN_REVIEW", "WAITING_FOR_REVIEW", "READY_FOR_REVIEW",
        "PENDING_APPLE_RELEASE", "PROCESSING_FOR_APP_STORE",
        "PROCESSING_FOR_DISTRIBUTION", "PREPARE_FOR_SUBMISSION"
    ]
    static let APPROVED_STATES_CONFUSE: Set<String> = [
        "READY_FOR_SALE", "READY_FOR_DISTRIBUTION", "PENDING_DEVELOPER_RELEASE", "ACCEPTED"
    ]
    static let REJECTED_STATES_CONFUSE: Set<String> = [
        "REJECTED", "METADATA_REJECTED", "DEVELOPER_REJECTED", "INVALID_BINARY"
    ]
    static let DELISTED_STATES_CONFUSE: Set<String> = [
        "REMOVED_FROM_SALE", "DEVELOPER_REMOVED_FROM_SALE"
    ]

    /// 返回 Apple 原始状态对应的英文展示名称。
    /// - Parameter state_confuse: App Store Connect 返回的状态值。
    /// - Returns: 可直接展示的状态名称。
    static func label_confuse(for state_confuse: String) -> String {
        let labels_confuse: [String: String] = [
            "PREPARE_FOR_SUBMISSION": "准备提交",
            "READY_FOR_REVIEW": "准备审核",
            "WAITING_FOR_REVIEW": "等待审核",
            "IN_REVIEW": "正在审核",
            "PENDING_DEVELOPER_RELEASE": "等待开发者发布",
            "PENDING_APPLE_RELEASE": "等待苹果发布",
            "PROCESSING_FOR_APP_STORE": "应用商店处理中",
            "PROCESSING_FOR_DISTRIBUTION": "分发处理中",
            "READY_FOR_SALE": "已上架",
            "READY_FOR_DISTRIBUTION": "可供分发",
            "ACCEPTED": "已接受",
            "REJECTED": "审核被拒",
            "METADATA_REJECTED": "元数据被拒",
            "DEVELOPER_REJECTED": "开发者撤回",
            "INVALID_BINARY": "安装包无效",
            "REMOVED_FROM_SALE": "已下架",
            "DEVELOPER_REMOVED_FROM_SALE": "开发者已下架",
            "NO_VERSION": "暂无版本",
            "UNKNOWN": "未知状态"
        ]
        return labels_confuse[state_confuse] ?? "其他状态"
    }

    /// 返回 Apple 状态对应的业务分类。
    /// - Parameters:
    ///   - state_confuse: App Store Connect 返回的状态值。
    ///   - hasError_confuse: 当前应用是否存在查询错误。
    /// - Returns: 状态筛选分类。
    static func category_confuse(
        for state_confuse: String,
        hasError_confuse: Bool = false
    ) -> MonitoringStatusCategory_confuse {
        if hasError_confuse || state_confuse.isEmpty || ["NO_VERSION", "UNKNOWN"].contains(state_confuse) {
            return .custom_confuse
        }
        if PIPELINE_STATES_CONFUSE.contains(state_confuse) { return .pipeline_confuse }
        if APPROVED_STATES_CONFUSE.contains(state_confuse) { return .approved_confuse }
        if REJECTED_STATES_CONFUSE.contains(state_confuse) { return .rejected_confuse }
        if DELISTED_STATES_CONFUSE.contains(state_confuse) { return .delisted_confuse }
        return .custom_confuse
    }
}

/// 保存一个 App Store Connect 应用的凭证、监控开关和最近查询结果。
struct MonitoringApplication_confuse: Codable, Identifiable, Equatable, Sendable {
    var appID_confuse: String
    var issuerID_confuse: String
    var keyID_confuse: String
    var privateKeyPath_confuse: String
    var isEnabled_confuse: Bool
    var name_confuse: String
    var preferredVersion_confuse: String
    var version_confuse: String
    var state_confuse: String
    var label_confuse: String
    var checkedAt_confuse: String
    var stateChangedAt_confuse: String
    var error_confuse: String

    /// 返回以 App ID 为基础的稳定标识。
    var id: String { appID_confuse }

    /// 返回当前应用的审核状态分类。
    var category_confuse: MonitoringStatusCategory_confuse {
        MonitoringStateCatalog_confuse.category_confuse(
            for: state_confuse,
            hasError_confuse: !error_confuse.isEmpty
        )
    }

    /// 创建一个待监控应用并提供查询结果默认值。
    /// - Parameters:
    ///   - appID_confuse: Apple 数字 App ID。
    ///   - issuerID_confuse: App Store Connect Issuer ID。
    ///   - keyID_confuse: App Store Connect Key ID。
    ///   - privateKeyPath_confuse: 已导入的 `.p8` 私钥路径。
    ///   - isEnabled_confuse: 是否参与定时监控。
    init(
        appID_confuse: String,
        issuerID_confuse: String,
        keyID_confuse: String,
        privateKeyPath_confuse: String,
        isEnabled_confuse: Bool = true
    ) {
        self.appID_confuse = appID_confuse
        self.issuerID_confuse = issuerID_confuse
        self.keyID_confuse = keyID_confuse
        self.privateKeyPath_confuse = privateKeyPath_confuse
        self.isEnabled_confuse = isEnabled_confuse
        name_confuse = ""
        preferredVersion_confuse = ""
        version_confuse = ""
        state_confuse = ""
        label_confuse = "等待检查"
        checkedAt_confuse = ""
        stateChangedAt_confuse = ""
        error_confuse = ""
    }

    /// 从兼容 `app-monitor` 的配置字段解码应用数据。
    /// - Parameter decoder_confuse: JSON 解码器。
    /// - Throws: JSON 字段类型不合法时抛出解码错误。
    init(from decoder_confuse: Decoder) throws {
        let container_confuse = try decoder_confuse.container(keyedBy: CodingKeys.self)
        appID_confuse = try container_confuse.decodeIfPresent(String.self, forKey: .appID_confuse) ?? ""
        issuerID_confuse = try container_confuse.decodeIfPresent(String.self, forKey: .issuerID_confuse) ?? ""
        keyID_confuse = try container_confuse.decodeIfPresent(String.self, forKey: .keyID_confuse) ?? ""
        privateKeyPath_confuse = try container_confuse.decodeIfPresent(String.self, forKey: .privateKeyPath_confuse) ?? ""
        isEnabled_confuse = try container_confuse.decodeIfPresent(Bool.self, forKey: .isEnabled_confuse) ?? true
        name_confuse = try container_confuse.decodeIfPresent(String.self, forKey: .name_confuse) ?? ""
        preferredVersion_confuse = try container_confuse.decodeIfPresent(String.self, forKey: .preferredVersion_confuse) ?? ""
        version_confuse = try container_confuse.decodeIfPresent(String.self, forKey: .version_confuse) ?? ""
        state_confuse = try container_confuse.decodeIfPresent(String.self, forKey: .state_confuse) ?? ""
        let savedLabel_confuse = try container_confuse.decodeIfPresent(String.self, forKey: .label_confuse) ?? ""
        checkedAt_confuse = try container_confuse.decodeIfPresent(String.self, forKey: .checkedAt_confuse) ?? ""
        stateChangedAt_confuse = try container_confuse.decodeIfPresent(String.self, forKey: .stateChangedAt_confuse) ?? ""
        error_confuse = try container_confuse.decodeIfPresent(String.self, forKey: .error_confuse) ?? ""
        if !error_confuse.isEmpty {
            label_confuse = "检查失败"
        } else if !state_confuse.isEmpty {
            label_confuse = MonitoringStateCatalog_confuse.label_confuse(for: state_confuse)
        } else if savedLabel_confuse == "Check Failed" {
            label_confuse = "检查失败"
        } else {
            label_confuse = savedLabel_confuse.isEmpty || savedLabel_confuse == "Waiting for Check"
                ? "等待检查"
                : savedLabel_confuse
        }
    }

    private enum CodingKeys: String, CodingKey {
        case appID_confuse = "app_id"
        case issuerID_confuse = "issuer_id"
        case keyID_confuse = "key_id"
        case privateKeyPath_confuse = "p8_path"
        case isEnabled_confuse = "enabled"
        case name_confuse = "name"
        case preferredVersion_confuse = "preferred_version"
        case version_confuse = "version"
        case state_confuse = "state"
        case label_confuse = "label"
        case checkedAt_confuse = "checked_at"
        case stateChangedAt_confuse = "state_changed_at"
        case error_confuse = "error"
    }
}

/// 保存监控服务的应用列表、网络设置、通知设置和轮询间隔。
struct MonitoringConfiguration_confuse: Codable, Equatable, Sendable {
    var applications_confuse: [MonitoringApplication_confuse]
    var isMonitoringEnabled_confuse: Bool
    var proxy_confuse: String
    var isStrictProxy_confuse: Bool
    var pushPlusToken_confuse: String
    var feishuWebhook_confuse: String
    var defaultInterval_confuse: Int
    var reviewInterval_confuse: Int
    var approvedInterval_confuse: Int

    /// 返回监控配置的默认值。
    static var default_confuse: MonitoringConfiguration_confuse {
        MonitoringConfiguration_confuse(
            applications_confuse: [],
            isMonitoringEnabled_confuse: false,
            proxy_confuse: "",
            isStrictProxy_confuse: false,
            pushPlusToken_confuse: "",
            feishuWebhook_confuse: "",
            defaultInterval_confuse: 600,
            reviewInterval_confuse: 180,
            approvedInterval_confuse: 3600
        )
    }

    /// 从兼容 `app-monitor` 的配置字段解码监控设置。
    /// - Parameter decoder_confuse: JSON 解码器。
    /// - Throws: JSON 字段类型不合法时抛出解码错误。
    init(from decoder_confuse: Decoder) throws {
        let container_confuse = try decoder_confuse.container(keyedBy: CodingKeys.self)
        applications_confuse = try container_confuse.decodeIfPresent([MonitoringApplication_confuse].self, forKey: .applications_confuse) ?? []
        isMonitoringEnabled_confuse = try container_confuse.decodeIfPresent(Bool.self, forKey: .isMonitoringEnabled_confuse) ?? false
        proxy_confuse = try container_confuse.decodeIfPresent(String.self, forKey: .proxy_confuse) ?? ""
        isStrictProxy_confuse = try container_confuse.decodeIfPresent(Bool.self, forKey: .isStrictProxy_confuse) ?? false
        pushPlusToken_confuse = try container_confuse.decodeIfPresent(String.self, forKey: .pushPlusToken_confuse) ?? ""
        feishuWebhook_confuse = try container_confuse.decodeIfPresent(String.self, forKey: .feishuWebhook_confuse) ?? ""
        defaultInterval_confuse = try container_confuse.decodeIfPresent(Int.self, forKey: .defaultInterval_confuse) ?? 600
        reviewInterval_confuse = try container_confuse.decodeIfPresent(Int.self, forKey: .reviewInterval_confuse) ?? 180
        approvedInterval_confuse = try container_confuse.decodeIfPresent(Int.self, forKey: .approvedInterval_confuse) ?? 3600
    }

    /// 创建完整监控配置。
    /// - Parameters:
    ///   - applications_confuse: 待监控应用。
    ///   - isMonitoringEnabled_confuse: 是否启用定时监控。
    ///   - proxy_confuse: Apple API 代理地址。
    ///   - isStrictProxy_confuse: 是否强制通过代理访问。
    ///   - pushPlusToken_confuse: PushPlus 通知令牌。
    ///   - feishuWebhook_confuse: 飞书机器人 Webhook。
    ///   - defaultInterval_confuse: 普通状态轮询秒数。
    ///   - reviewInterval_confuse: 审核中轮询秒数。
    ///   - approvedInterval_confuse: 已通过状态轮询秒数。
    init(
        applications_confuse: [MonitoringApplication_confuse],
        isMonitoringEnabled_confuse: Bool,
        proxy_confuse: String,
        isStrictProxy_confuse: Bool,
        pushPlusToken_confuse: String,
        feishuWebhook_confuse: String,
        defaultInterval_confuse: Int,
        reviewInterval_confuse: Int,
        approvedInterval_confuse: Int
    ) {
        self.applications_confuse = applications_confuse
        self.isMonitoringEnabled_confuse = isMonitoringEnabled_confuse
        self.proxy_confuse = proxy_confuse
        self.isStrictProxy_confuse = isStrictProxy_confuse
        self.pushPlusToken_confuse = pushPlusToken_confuse
        self.feishuWebhook_confuse = feishuWebhook_confuse
        self.defaultInterval_confuse = defaultInterval_confuse
        self.reviewInterval_confuse = reviewInterval_confuse
        self.approvedInterval_confuse = approvedInterval_confuse
    }

    private enum CodingKeys: String, CodingKey {
        case applications_confuse = "apps"
        case isMonitoringEnabled_confuse = "monitoring_enabled"
        case proxy_confuse = "proxy"
        case isStrictProxy_confuse = "strict_proxy"
        case pushPlusToken_confuse = "pushplus_token"
        case feishuWebhook_confuse = "feishu_webhook"
        case defaultInterval_confuse = "default_interval"
        case reviewInterval_confuse = "review_interval"
        case approvedInterval_confuse = "approved_interval"
    }
}

/// 描述一次 App Store Connect 状态查询的有效结果。
struct MonitoringCheckResult_confuse: Equatable, Sendable {
    let name_confuse: String
    let version_confuse: String
    let state_confuse: String
    let label_confuse: String
    let checkedAt_confuse: String
}

/// 描述一条审核查询或状态变化记录。
struct MonitoringRecord_confuse: Codable, Identifiable, Equatable, Sendable {
    let id: UUID
    let timestamp_confuse: String
    let applicationName_confuse: String
    let appID_confuse: String
    let event_confuse: String
    let state_confuse: String
    let isError_confuse: Bool
}

/// 保存添加或编辑应用表单的临时状态。
struct MonitoringApplicationEditor_confuse: Equatable, Sendable {
    var appID_confuse = ""
    var issuerID_confuse = ""
    var keyID_confuse = ""
    var privateKeyPath_confuse = ""
    var isEnabled_confuse = true
    var importedProfileName_confuse = ""
}

/// 保存从资料文件夹中提取的白名单凭证字段。
struct MonitoringProfileResult_confuse: Equatable, Sendable {
    let profilePath_confuse: String
    let privateKeyPath_confuse: String
    let appID_confuse: String
    let issuerID_confuse: String
    let keyID_confuse: String
}
