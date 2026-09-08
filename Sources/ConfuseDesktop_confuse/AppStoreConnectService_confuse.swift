import CFNetwork
import CryptoKit
import Foundation

/// 描述 App Store Connect 请求、鉴权和响应解析错误。
enum AppStoreConnectError_confuse: LocalizedError {
    case invalidPrivateKey_confuse
    case invalidResponse_confuse
    case strictProxyRequired_confuse
    case invalidProxy_confuse
    case api_confuse(statusCode_confuse: Int, detail_confuse: String)

    /// 返回可直接展示给用户的错误说明。
    var errorDescription: String? {
        switch self {
        case .invalidPrivateKey_confuse:
            return "所选私钥文件无效。"
        case .invalidResponse_confuse:
            return "苹果开发者后台返回了无效响应。"
        case .strictProxyRequired_confuse:
            return "严格代理模式需要先配置代理地址。"
        case .invalidProxy_confuse:
            return "代理地址格式无效。"
        case .api_confuse(let statusCode_confuse, let detail_confuse):
            return "苹果接口请求失败（状态码 \(statusCode_confuse)）：\(detail_confuse)"
        }
    }
}

/// 使用原生 URLSession 和 ES256 JWT 查询 App Store Connect 应用审核状态。
final class AppStoreConnectService_confuse: @unchecked Sendable {
    private let configuration_confuse: MonitoringConfiguration_confuse
    private let session_confuse: URLSession

    /// 创建绑定当前代理配置的独立网络会话。
    /// - Parameter configuration_confuse: 包含代理和轮询设置的监控配置。
    /// - Throws: 严格代理未配置地址或代理地址无效时抛出错误。
    init(configuration_confuse: MonitoringConfiguration_confuse) throws {
        self.configuration_confuse = configuration_confuse
        let sessionConfiguration_confuse = URLSessionConfiguration.ephemeral
        sessionConfiguration_confuse.timeoutIntervalForRequest = 20
        sessionConfiguration_confuse.timeoutIntervalForResource = 30
        sessionConfiguration_confuse.requestCachePolicy = .reloadIgnoringLocalCacheData
        let proxy_confuse = Self.normalizedProxy_confuse(configuration_confuse.proxy_confuse)
        if configuration_confuse.isStrictProxy_confuse && proxy_confuse.isEmpty {
            throw AppStoreConnectError_confuse.strictProxyRequired_confuse
        }
        if !proxy_confuse.isEmpty {
            sessionConfiguration_confuse.connectionProxyDictionary = try Self.proxyDictionary_confuse(proxy_confuse: proxy_confuse)
        }
        session_confuse = URLSession(configuration: sessionConfiguration_confuse)
    }

    /// 查询一个应用的名称、目标版本和当前审核状态。
    /// - Parameter application_confuse: 包含 API 凭证和 App ID 的应用配置。
    /// - Returns: 可写回应用列表的查询结果。
    /// - Throws: 私钥、网络、Apple API 或响应解析失败时抛出错误。
    func check_confuse(
        application_confuse: MonitoringApplication_confuse
    ) async throws -> MonitoringCheckResult_confuse {
        let token_confuse = try Self.token_confuse(application_confuse: application_confuse)
        let appObject_confuse = try await requestObject_confuse(
            url_confuse: URL(string: "https://api.appstoreconnect.apple.com/v1/apps/\(application_confuse.appID_confuse)")!,
            token_confuse: token_confuse
        )
        let appData_confuse = appObject_confuse["data"] as? [String: Any]
        let appAttributes_confuse = appData_confuse?["attributes"] as? [String: Any]
        let name_confuse = appAttributes_confuse?["name"] as? String
            ?? (application_confuse.name_confuse.isEmpty ? application_confuse.appID_confuse : application_confuse.name_confuse)

        var versionComponents_confuse = URLComponents(
            string: "https://api.appstoreconnect.apple.com/v1/apps/\(application_confuse.appID_confuse)/appStoreVersions"
        )!
        versionComponents_confuse.queryItems = [URLQueryItem(name: "limit", value: "50")]
        let versionObject_confuse = try await requestObject_confuse(
            url_confuse: versionComponents_confuse.url!,
            token_confuse: token_confuse
        )
        let versions_confuse = versionObject_confuse["data"] as? [[String: Any]] ?? []
        let formatter_confuse = DateFormatter()
        formatter_confuse.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let checkedAt_confuse = formatter_confuse.string(from: Date())
        guard !versions_confuse.isEmpty else {
            return MonitoringCheckResult_confuse(
                name_confuse: name_confuse,
                version_confuse: "-",
                state_confuse: "NO_VERSION",
                label_confuse: MonitoringStateCatalog_confuse.label_confuse(for: "NO_VERSION"),
                checkedAt_confuse: checkedAt_confuse
            )
        }
        let version_confuse = Self.pickVersion_confuse(
            versions_confuse: versions_confuse,
            preferredVersion_confuse: application_confuse.preferredVersion_confuse
        )
        let attributes_confuse = version_confuse["attributes"] as? [String: Any] ?? [:]
        let state_confuse = attributes_confuse["appStoreState"] as? String
            ?? attributes_confuse["appVersionState"] as? String
            ?? "UNKNOWN"
        return MonitoringCheckResult_confuse(
            name_confuse: name_confuse,
            version_confuse: attributes_confuse["versionString"] as? String ?? "-",
            state_confuse: state_confuse,
            label_confuse: MonitoringStateCatalog_confuse.label_confuse(for: state_confuse),
            checkedAt_confuse: checkedAt_confuse
        )
    }

    /// 从版本列表中优先选择指定版本、审核中版本、拒绝版本或最新可售版本。
    /// - Parameters:
    ///   - versions_confuse: Apple API 返回的版本对象列表。
    ///   - preferredVersion_confuse: 用户指定的优先版本号。
    /// - Returns: 最符合监控优先级的版本对象。
    static func pickVersion_confuse(
        versions_confuse: [[String: Any]],
        preferredVersion_confuse: String
    ) -> [String: Any] {
        if !preferredVersion_confuse.isEmpty,
           let preferred_confuse = versions_confuse.first(where: { version_confuse in
               let attributes_confuse = version_confuse["attributes"] as? [String: Any] ?? [:]
               let versionString_confuse = attributes_confuse["versionString"] as? String ?? ""
               return versionString_confuse == preferredVersion_confuse
                   && state_confuse(version_confuse: version_confuse) != "REPLACED_WITH_NEW_VERSION"
           }) {
            return preferred_confuse
        }
        for states_confuse in [
            MonitoringStateCatalog_confuse.PIPELINE_STATES_CONFUSE,
            MonitoringStateCatalog_confuse.REJECTED_STATES_CONFUSE,
            MonitoringStateCatalog_confuse.APPROVED_STATES_CONFUSE
        ] {
            if let match_confuse = versions_confuse.first(where: {
                states_confuse.contains(state_confuse(version_confuse: $0))
            }) {
                return match_confuse
            }
        }
        return versions_confuse[0]
    }

    /// 生成 App Store Connect 使用的十分钟 ES256 JWT。
    /// - Parameter application_confuse: 包含 Issuer ID、Key ID 和私钥路径的应用。
    /// - Returns: Bearer Token 字符串。
    /// - Throws: 私钥读取、PEM 解析、JSON 编码或签名失败时抛出错误。
    static func token_confuse(application_confuse: MonitoringApplication_confuse) throws -> String {
        let keyText_confuse = try String(
            contentsOf: URL(fileURLWithPath: application_confuse.privateKeyPath_confuse),
            encoding: .utf8
        ).trimmingCharacters(in: .whitespacesAndNewlines)
        guard let privateKey_confuse = try? P256.Signing.PrivateKey(pemRepresentation: keyText_confuse) else {
            throw AppStoreConnectError_confuse.invalidPrivateKey_confuse
        }
        let now_confuse = Int(Date().timeIntervalSince1970)
        let header_confuse: [String: Any] = [
            "alg": "ES256",
            "kid": application_confuse.keyID_confuse,
            "typ": "JWT"
        ]
        let payload_confuse: [String: Any] = [
            "iss": application_confuse.issuerID_confuse,
            "iat": now_confuse,
            "exp": now_confuse + 600,
            "aud": "appstoreconnect-v1"
        ]
        let headerData_confuse = try JSONSerialization.data(withJSONObject: header_confuse, options: [.sortedKeys])
        let payloadData_confuse = try JSONSerialization.data(withJSONObject: payload_confuse, options: [.sortedKeys])
        let signingInput_confuse = "\(base64URL_confuse(data_confuse: headerData_confuse)).\(base64URL_confuse(data_confuse: payloadData_confuse))"
        let signature_confuse = try privateKey_confuse.signature(for: Data(signingInput_confuse.utf8))
        return "\(signingInput_confuse).\(base64URL_confuse(data_confuse: signature_confuse.rawRepresentation))"
    }

    /// 请求 JSON 对象，并对限流和服务端错误执行指数退避重试。
    /// - Parameters:
    ///   - url_confuse: Apple API URL。
    ///   - token_confuse: ES256 Bearer Token。
    /// - Returns: JSON 根对象。
    /// - Throws: 网络失败、HTTP 失败或 JSON 无效时抛出错误。
    private func requestObject_confuse(
        url_confuse: URL,
        token_confuse: String
    ) async throws -> [String: Any] {
        var latestData_confuse = Data()
        var latestResponse_confuse: HTTPURLResponse?
        for attempt_confuse in 0..<5 {
            var request_confuse = URLRequest(url: url_confuse)
            request_confuse.httpMethod = "GET"
            request_confuse.timeoutInterval = 20
            request_confuse.setValue("Bearer \(token_confuse)", forHTTPHeaderField: "Authorization")
            request_confuse.setValue("application/json", forHTTPHeaderField: "Accept")
            do {
                let (data_confuse, response_confuse) = try await session_confuse.data(for: request_confuse)
                guard let httpResponse_confuse = response_confuse as? HTTPURLResponse else {
                    throw AppStoreConnectError_confuse.invalidResponse_confuse
                }
                latestData_confuse = data_confuse
                latestResponse_confuse = httpResponse_confuse
                if httpResponse_confuse.statusCode == 429 || (500...599).contains(httpResponse_confuse.statusCode) {
                    if attempt_confuse < 4 {
                        let delay_confuse = UInt64(min(24.0, 1.5 * pow(2.0, Double(attempt_confuse))) * 1_000_000_000)
                        try await Task.sleep(nanoseconds: delay_confuse)
                        continue
                    }
                }
                break
            } catch {
                if configuration_confuse.isStrictProxy_confuse {
                    throw NSError(
                        domain: "AppStoreConnectService_confuse",
                        code: 2,
                        userInfo: [NSLocalizedDescriptionKey: "严格代理请求失败：\(error.localizedDescription)"]
                    )
                }
                throw error
            }
        }
        guard let response_confuse = latestResponse_confuse else {
            throw AppStoreConnectError_confuse.invalidResponse_confuse
        }
        guard (200...299).contains(response_confuse.statusCode) else {
            throw AppStoreConnectError_confuse.api_confuse(
                statusCode_confuse: response_confuse.statusCode,
                detail_confuse: Self.errorDetail_confuse(data_confuse: latestData_confuse)
            )
        }
        guard let object_confuse = try JSONSerialization.jsonObject(with: latestData_confuse) as? [String: Any] else {
            throw AppStoreConnectError_confuse.invalidResponse_confuse
        }
        return object_confuse
    }

    /// 返回版本对象中的 Apple 原始状态。
    /// - Parameter version_confuse: Apple 版本对象。
    /// - Returns: App Store 状态或 UNKNOWN。
    private static func state_confuse(version_confuse: [String: Any]) -> String {
        let attributes_confuse = version_confuse["attributes"] as? [String: Any] ?? [:]
        return attributes_confuse["appStoreState"] as? String
            ?? attributes_confuse["appVersionState"] as? String
            ?? "UNKNOWN"
    }

    /// 从 Apple 错误响应中提取简洁错误详情。
    /// - Parameter data_confuse: Apple API 响应数据。
    /// - Returns: 最多两条错误详情。
    private static func errorDetail_confuse(data_confuse: Data) -> String {
        guard let object_confuse = try? JSONSerialization.jsonObject(with: data_confuse) as? [String: Any],
              let errors_confuse = object_confuse["errors"] as? [[String: Any]] else {
            return String(data: data_confuse, encoding: .utf8)?.prefix(180).description ?? "请求失败"
        }
        let details_confuse = errors_confuse.prefix(2).compactMap { error_confuse in
            error_confuse["detail"] as? String ?? error_confuse["title"] as? String
        }
        return details_confuse.isEmpty ? "请求失败" : details_confuse.joined(separator: " | ")
    }

    /// 将普通 Base64 转换为 JWT 使用的 Base64URL。
    /// - Parameter data_confuse: 待编码数据。
    /// - Returns: 不带填充的 Base64URL 字符串。
    private static func base64URL_confuse(data_confuse: Data) -> String {
        data_confuse.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    /// 将纯端口代理转换为本机 HTTP 代理地址。
    /// - Parameter proxy_confuse: 用户输入的代理值。
    /// - Returns: 标准代理 URL 文本或空字符串。
    private static func normalizedProxy_confuse(_ proxy_confuse: String) -> String {
        let trimmedProxy_confuse = proxy_confuse.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedProxy_confuse.isEmpty && trimmedProxy_confuse.allSatisfy(\.isNumber) {
            return "http://127.0.0.1:\(trimmedProxy_confuse)"
        }
        return trimmedProxy_confuse
    }

    /// 根据 HTTP 或 SOCKS URL 创建 URLSession 代理字典。
    /// - Parameter proxy_confuse: 标准代理 URL 字符串。
    /// - Returns: URLSessionConfiguration 使用的代理字典。
    /// - Throws: 地址缺少协议、主机或端口时抛出错误。
    private static func proxyDictionary_confuse(proxy_confuse: String) throws -> [AnyHashable: Any] {
        guard let components_confuse = URLComponents(string: proxy_confuse),
              let scheme_confuse = components_confuse.scheme?.lowercased(),
              let host_confuse = components_confuse.host,
              let port_confuse = components_confuse.port else {
            throw AppStoreConnectError_confuse.invalidProxy_confuse
        }
        if scheme_confuse.hasPrefix("socks") {
            return [
                kCFNetworkProxiesSOCKSEnable as String: true,
                kCFNetworkProxiesSOCKSProxy as String: host_confuse,
                kCFNetworkProxiesSOCKSPort as String: port_confuse
            ]
        }
        guard ["http", "https"].contains(scheme_confuse) else {
            throw AppStoreConnectError_confuse.invalidProxy_confuse
        }
        return [
            kCFNetworkProxiesHTTPEnable as String: true,
            kCFNetworkProxiesHTTPProxy as String: host_confuse,
            kCFNetworkProxiesHTTPPort as String: port_confuse,
            kCFNetworkProxiesHTTPSEnable as String: true,
            kCFNetworkProxiesHTTPSProxy as String: host_confuse,
            kCFNetworkProxiesHTTPSPort as String: port_confuse
        ]
    }
}
