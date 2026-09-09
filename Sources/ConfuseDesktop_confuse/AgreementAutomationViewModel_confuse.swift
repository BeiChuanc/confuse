import AppKit
import Foundation

/// 管理协议表单输入、三类协议进度、结果链接以及 Chrome 自动化任务生命周期。
@MainActor
final class AgreementAutomationViewModel_confuse: ObservableObject {
    @Published var appName_confuse = ""
    @Published var email_confuse = ""
    @Published var isRunning_confuse = false
    @Published var statusText_confuse = "等待生成"
    @Published var detailText_confuse = "填写应用名称和邮箱后，可以单独生成或一键生成全部协议。"
    @Published var states_confuse: [AgreementType_confuse: AgreementGenerationState_confuse] = [:]
    @Published var messages_confuse: [AgreementType_confuse: String] = [:]
    @Published var links_confuse: [AgreementType_confuse: String] = [:]
    @Published var isShowingAlert_confuse = false
    @Published var alertMessage_confuse = ""

    private let service_confuse = AgreementAutomationService_confuse()

    /// 创建协议自动化视图模型并初始化三个协议状态。
    init() {
        for type_confuse in AgreementType_confuse.allCases {
            states_confuse[type_confuse] = .pending_confuse
            messages_confuse[type_confuse] = "尚未生成"
        }
    }

    /// 返回当前输入是否满足开始生成的条件。
    var canGenerate_confuse: Bool {
        !isRunning_confuse
            && !cleanAppName_confuse.isEmpty
            && isEmailValid_confuse
    }

    /// 返回当前邮箱格式是否有效。
    var isEmailValid_confuse: Bool {
        cleanEmail_confuse.range(
            of: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$",
            options: [.regularExpression, .caseInsensitive]
        ) != nil
    }

    /// 按隐私政策、使用条款和最终用户许可协议的顺序生成全部链接。
    func generateAll_confuse() {
        startGeneration_confuse(types_confuse: AgreementType_confuse.allCases)
    }

    /// 单独生成指定协议，适合首次分项生成或失败后重试。
    /// - Parameter type_confuse: 待生成的协议类型。
    func generate_confuse(type_confuse: AgreementType_confuse) {
        startGeneration_confuse(types_confuse: [type_confuse])
    }

    /// 请求停止当前脚本和浏览器自动化流程。
    func cancel_confuse() {
        guard isRunning_confuse else { return }
        statusText_confuse = "正在停止"
        detailText_confuse = "正在结束当前协议生成任务。"
        service_confuse.cancel_confuse()
    }

    /// 将指定协议链接复制到系统剪贴板。
    /// - Parameter type_confuse: 需要复制链接的协议类型。
    func copyLink_confuse(type_confuse: AgreementType_confuse) {
        guard let link_confuse = links_confuse[type_confuse] else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(link_confuse, forType: .string)
        statusText_confuse = "链接已复制"
        detailText_confuse = "\(type_confuse.displayName_confuse)链接已复制到剪贴板。"
    }

    /// 使用默认浏览器打开指定协议链接。
    /// - Parameter type_confuse: 需要打开链接的协议类型。
    func openLink_confuse(type_confuse: AgreementType_confuse) {
        guard let link_confuse = links_confuse[type_confuse],
              let url_confuse = URL(string: link_confuse) else { return }
        NSWorkspace.shared.open(url_confuse)
    }

    /// 返回指定协议当前的执行状态。
    /// - Parameter type_confuse: 待查询的协议类型。
    /// - Returns: 待执行、执行中、完成或失败状态。
    func state_confuse(type_confuse: AgreementType_confuse) -> AgreementGenerationState_confuse {
        states_confuse[type_confuse] ?? .pending_confuse
    }

    /// 校验输入并启动后台 Chrome 自动化任务。
    /// - Parameter types_confuse: 本次需要生成的协议类型列表。
    private func startGeneration_confuse(types_confuse: [AgreementType_confuse]) {
        guard !cleanAppName_confuse.isEmpty else {
            showAlert_confuse(message_confuse: "请输入应用名称。")
            return
        }
        guard isEmailValid_confuse else {
            showAlert_confuse(message_confuse: "请输入有效的邮箱地址。")
            return
        }
        guard !isRunning_confuse else { return }

        let request_confuse = AgreementAutomationRequest_confuse(
            appName_confuse: cleanAppName_confuse,
            email_confuse: cleanEmail_confuse,
            agreementTypes_confuse: types_confuse.map(\.rawValue)
        )
        for type_confuse in types_confuse {
            states_confuse[type_confuse] = .pending_confuse
            messages_confuse[type_confuse] = "等待 Chrome 处理"
            links_confuse.removeValue(forKey: type_confuse)
        }
        isRunning_confuse = true
        statusText_confuse = "正在生成"
        detailText_confuse = "正在等待当前 Chrome 中的 App Tools 浏览器助手。"

        let service_confuse = service_confuse
        Task { [weak self] in
            let result_confuse: Result<[AgreementType_confuse: String], Error> = await Task.detached(
                priority: .userInitiated
            ) {
                do {
                    let links_confuse = try service_confuse.run_confuse(request_confuse: request_confuse) {
                        event_confuse in
                        Task { @MainActor [weak self] in
                            self?.applyEvent_confuse(event_confuse: event_confuse)
                        }
                    }
                    return .success(links_confuse)
                } catch {
                    return .failure(error)
                }
            }.value

            guard let self_confuse = self else { return }
            self_confuse.isRunning_confuse = false
            switch result_confuse {
            case .success(let links_confuse):
                for (type_confuse, link_confuse) in links_confuse {
                    self_confuse.links_confuse[type_confuse] = link_confuse
                    self_confuse.states_confuse[type_confuse] = .completed_confuse
                    self_confuse.messages_confuse[type_confuse] = "链接已生成"
                }
                self_confuse.statusText_confuse = "生成完成"
                self_confuse.detailText_confuse = "协议链接已显示，可以复制或在浏览器中打开。"
            case .failure(let error_confuse):
                for type_confuse in types_confuse where self_confuse.states_confuse[type_confuse] == .running_confuse {
                    self_confuse.states_confuse[type_confuse] = .failed_confuse
                    self_confuse.messages_confuse[type_confuse] = "生成失败"
                }
                self_confuse.statusText_confuse = "生成失败"
                self_confuse.detailText_confuse = error_confuse.localizedDescription
                if !(error_confuse is AgreementAutomationError_confuse)
                    || error_confuse.localizedDescription != AgreementAutomationError_confuse.cancelled_confuse.localizedDescription {
                    self_confuse.showAlert_confuse(message_confuse: error_confuse.localizedDescription)
                }
            }
        }
    }

    /// 应用脚本发出的单项协议状态与链接事件。
    /// - Parameter event_confuse: 脚本输出的结构化事件。
    private func applyEvent_confuse(event_confuse: AgreementAutomationEvent_confuse) {
        guard let rawType_confuse = event_confuse.agreementType_confuse,
              let type_confuse = AgreementType_confuse(rawValue: rawType_confuse) else { return }
        if event_confuse.state_confuse == "running" {
            states_confuse[type_confuse] = .running_confuse
        } else if event_confuse.state_confuse == "completed" {
            states_confuse[type_confuse] = .completed_confuse
        } else if event_confuse.state_confuse == "failed" {
            states_confuse[type_confuse] = .failed_confuse
        }
        if let message_confuse = event_confuse.message_confuse {
            messages_confuse[type_confuse] = message_confuse
            detailText_confuse = message_confuse
        }
        if let link_confuse = event_confuse.link_confuse {
            links_confuse[type_confuse] = link_confuse
        }
    }

    /// 显示协议自动化统一错误弹窗。
    /// - Parameter message_confuse: 需要展示的错误说明。
    private func showAlert_confuse(message_confuse: String) {
        alertMessage_confuse = message_confuse
        isShowingAlert_confuse = true
    }

    /// 返回去除首尾空白后的应用名称。
    private var cleanAppName_confuse: String {
        appName_confuse.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// 返回去除首尾空白后的邮箱地址。
    private var cleanEmail_confuse: String {
        email_confuse.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
