import Foundation
import UIKit
import AuthenticationServices
import SnapKit

// MARK: - Apple登录按钮组件

/// Apple登录按钮组件
class AppleLoginBt_Base_one: UIView {
    
    // MARK: - 回调闭包
    
    /// 点击回调
    private var onTap_Base_one: (() -> Void)?
    
    // MARK: - UI组件
    
    /// 容器视图
    private let containerView_Base_one: UIView = {
        let view_Base_one = UIView()
        view_Base_one.backgroundColor = .black
        view_Base_one.layer.cornerRadius = 12
        view_Base_one.layer.masksToBounds = true
        return view_Base_one
    }()
    
    /// 苹果图标
    private let appleIconView_Base_one: UIImageView = {
        let imageView_Base_one = UIImageView()
        imageView_Base_one.image = UIImage(systemName: "apple.logo")
        imageView_Base_one.tintColor = .white
        imageView_Base_one.contentMode = .scaleAspectFit
        return imageView_Base_one
    }()
    
    /// 文字标签
    private let titleLabel_Base_one: UILabel = {
        let label_Base_one = UILabel()
        label_Base_one.text = "Continue with Apple"
        label_Base_one.textColor = .white
        label_Base_one.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label_Base_one.textAlignment = .center
        return label_Base_one
    }()

    /// 图标+文字水平居中容器
    private let contentStack_Base_one: UIStackView = {
        let stack_Base_one = UIStackView()
        stack_Base_one.axis = .horizontal
        stack_Base_one.alignment = .center
        stack_Base_one.spacing = 10
        stack_Base_one.isUserInteractionEnabled = false
        return stack_Base_one
    }()
    
    // MARK: - 初始化
    
    /// 初始化方法
    init(onTap_Base_one: @escaping () -> Void) {
        self.onTap_Base_one = onTap_Base_one
        super.init(frame: .zero)
        setupUI_Base_one()
        setupGesture_Base_one()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Base_one() {
        addSubview(containerView_Base_one)
        containerView_Base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(50)
        }

        // 图标固定尺寸
        appleIconView_Base_one.snp.makeConstraints { make in
            make.width.height.equalTo(22)
        }

        // 将图标与文字放入 StackView，整体居中
        contentStack_Base_one.addArrangedSubview(appleIconView_Base_one)
        contentStack_Base_one.addArrangedSubview(titleLabel_Base_one)

        containerView_Base_one.addSubview(contentStack_Base_one)
        contentStack_Base_one.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    /// 设置手势
    private func setupGesture_Base_one() {
        let tapGesture_Base_one = UITapGestureRecognizer(target: self, action: #selector(handleTap_Base_one))
        containerView_Base_one.addGestureRecognizer(tapGesture_Base_one)
    }
    
    // MARK: - 事件处理
    
    /// 处理点击事件
    @objc private func handleTap_Base_one() {
        // 添加点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView_Base_one.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView_Base_one.transform = .identity
            }
        }
        
        // 调用回调
        onTap_Base_one?()
    }
}

// MARK: - Apple登录管理器

/// Apple登录管理器
@MainActor
class AppleLoginManager_Base_one: NSObject {
    
    // MARK: - 属性
    
    /// 当前视图控制器
    private weak var viewController_Base_one: UIViewController?
    
    /// 成功回调
    private var successCallback_Base_one: ((String) -> Void)?
    
    /// 失败回调
    private var failureCallback_Base_one: ((String) -> Void)?
    
    // MARK: - 初始化
    
    /// 初始化
    init(viewController_Base_one: UIViewController) {
        self.viewController_Base_one = viewController_Base_one
        super.init()
    }
    
    // MARK: - 公共方法
    func startAppleLogin_Base_one(
        success_Base_one: @escaping (String) -> Void,
        failure_Base_one: @escaping (String) -> Void
    ) {
        self.successCallback_Base_one = success_Base_one
        self.failureCallback_Base_one = failure_Base_one
        
        // 创建Apple ID授权请求
        let appleIDProvider_Base_one = ASAuthorizationAppleIDProvider()
        let request_Base_one = appleIDProvider_Base_one.createRequest()
        request_Base_one.requestedScopes = [.fullName, .email]
        
        // 创建授权控制器
        let authorizationController_Base_one = ASAuthorizationController(authorizationRequests: [request_Base_one])
        authorizationController_Base_one.delegate = self
        authorizationController_Base_one.presentationContextProvider = self
        authorizationController_Base_one.performRequests()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleLoginManager_Base_one: ASAuthorizationControllerDelegate {
    
    /// 授权成功
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            switch authorization.credential {
                
            case let appleIDCredential_Base_one as ASAuthorizationAppleIDCredential:
                // 获取邮箱
                let email_Base_one = appleIDCredential_Base_one.email
                
                // 生成用户账号
                var userAcc_Base_one = ""
                if email_Base_one == nil || email_Base_one == "" {
                    userAcc_Base_one = "appleId"
                } else {
                    userAcc_Base_one = email_Base_one ?? ""
                }
                
                print("✅ Apple登录成功，用户账号：\(userAcc_Base_one)")
                
                // 调用成功回调
                successCallback_Base_one?(userAcc_Base_one)
                
            case let userCredential_Base_one as ASPasswordCredential:
                // 密码凭证
                let user_Base_one = userCredential_Base_one.user
                _ = userCredential_Base_one.password
                
                print("✅ 密码凭证登录成功，用户：\(user_Base_one)")
                
                // 调用成功回调
                successCallback_Base_one?(user_Base_one)
                
            default:
                print("❌ 未知授权类型")
                failureCallback_Base_one?("Unknown authorization type")
            }
        }
    }
    
    /// 授权失败
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        Task { @MainActor in
            if let authError_Base_one = error as? ASAuthorizationError {
                
                var errorMessage_Base_one = ""

                switch authError_Base_one.code {
                case .unknown:
                    errorMessage_Base_one = "Unknown error"
                    print("❌ 授权未知错误")
                case .canceled:
                    errorMessage_Base_one = "Authorization canceled"
                    print("⚠️ 授权取消")
                case .invalidResponse:
                    errorMessage_Base_one = "Invalid response"
                    print("❌ 授权无效请求")
                case .notHandled:
                    errorMessage_Base_one = "Not handled"
                    print("❌ 授权未能处理")
                case .failed:
                    errorMessage_Base_one = "Authorization failed"
                    print("❌ 授权失败")
                case .notInteractive:
                    errorMessage_Base_one = "Not interactive"
                    print("❌ 授权非交互式")
                case .matchedExcludedCredential:
                    errorMessage_Base_one = "Matched excluded credential"
                    print("❌ 该凭证属于被排除的范围")
                case .credentialImport:
                    errorMessage_Base_one = "Credential import"
                    print("❌ 凭证导入")
                case .credentialExport:
                    errorMessage_Base_one = "Credential export"
                    print("❌ 凭证导出")
                case .preferSignInWithApple:
                    errorMessage_Base_one = "Prefer sign in with Apple"
                    print("❌ 偏好使用Apple登录")
                case .deviceNotConfiguredForPasskeyCreation:
                    errorMessage_Base_one = "Device not configured for Passkey creation"
                    print("❌ 设备未配置用于创建Passkey")
                @unknown default:
                    errorMessage_Base_one = "Unknown error"
                    print("❌ 授权其他原因")
                }
                
                // 调用失败回调
                failureCallback_Base_one?(errorMessage_Base_one)
            }
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleLoginManager_Base_one: ASAuthorizationControllerPresentationContextProviding {
    
    /// 提供展示窗口
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // 获取当前的 keyWindow
        if let windowScene_Base_one = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window_Base_one = windowScene_Base_one.windows.first(where: { $0.isKeyWindow }) {
            return window_Base_one
        }
        
        // 备选方案：返回第一个窗口
        if let window_Base_one = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first {
            return window_Base_one
        }
        
        // 最终备选方案
        return ASPresentationAnchor()
    }
}
