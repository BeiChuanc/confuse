import Foundation
import UIKit
import WebKit
import SnapKit

// MARK: - 协议助手类

/// 协议助手类
/// 功能：提供服务条款、隐私政策、EULA 等协议的展示功能
/// 设计：支持 WebView、本地文本、本地图片三种展示方式
class ProtocolHelper_Base_one {

    // MARK: - 协议类型枚举

    /// 协议类型
    enum ProtocolType_Base_one {
        case terms_Base_one
        case privacy_Base_one
        case eula_Base_one
        case custom_Base_one(String)

        /// 协议标题
        var title_Base_one: String {
            switch self {
            case .terms_Base_one:   return "Terms of Service"
            case .privacy_Base_one: return "Privacy Policy"
            case .eula_Base_one:    return "EULA"
            case .custom_Base_one(let title_Base_one): return title_Base_one
            }
        }
    }

    // MARK: - 协议文本配置

    /// 协议文本展示样式配置
    struct ProtocolTextConfig_Base_one {
        var textColor_Base_one: UIColor
        var linkColor_Base_one: UIColor
        var fontSize_Base_one: CGFloat
        var fontWeight_Base_one: UIFont.Weight
        var hasUnderline_Base_one: Bool
        var prefixText_Base_one: String
        var separatorText_Base_one: String

        init(
            textColor_Base_one: UIColor = UIColor.gray,
            linkColor_Base_one: UIColor = UIColor.black,
            fontSize_Base_one: CGFloat = 12,
            fontWeight_Base_one: UIFont.Weight = .regular,
            hasUnderline_Base_one: Bool = true,
            prefixText_Base_one: String = "By continuing you agree with ",
            separatorText_Base_one: String = " & "
        ) {
            self.textColor_Base_one = textColor_Base_one
            self.linkColor_Base_one = linkColor_Base_one
            self.fontSize_Base_one = fontSize_Base_one
            self.fontWeight_Base_one = fontWeight_Base_one
            self.hasUnderline_Base_one = hasUnderline_Base_one
            self.prefixText_Base_one = prefixText_Base_one
            self.separatorText_Base_one = separatorText_Base_one
        }

        /// 浅色主题配置
        static func light_Base_one() -> ProtocolTextConfig_Base_one {
            ProtocolTextConfig_Base_one(
                textColor_Base_one: UIColor(white: 0.2, alpha: 0.6),
                linkColor_Base_one: UIColor(white: 0.2, alpha: 1.0)
            )
        }

        /// 深色主题配置
        static func dark_Base_one() -> ProtocolTextConfig_Base_one {
            ProtocolTextConfig_Base_one(
                textColor_Base_one: UIColor(white: 1.0, alpha: 0.6),
                linkColor_Base_one: UIColor(white: 1.0, alpha: 1.0)
            )
        }
    }

    // MARK: - 公共方法

    /// 跳转到协议详情页
    /// 参数：
    /// - type_Base_one: 协议类型
    /// - content_Base_one: 协议内容（URL、本地文本或图片路径）
    /// - viewController_Base_one: 发起跳转的视图控制器
    static func showProtocol_Base_one(
        type_Base_one: ProtocolType_Base_one,
        content_Base_one: String,
        from viewController_Base_one: UIViewController
    ) {
        let vc_Base_one = ProtocolViewController_Base_one(type_Base_one: type_Base_one, content_Base_one: content_Base_one)
        viewController_Base_one.navigationController?.pushViewController(vc_Base_one, animated: true)
    }

    /// 创建带可点击协议链接的富文本 Label
    /// 参数：
    /// - firstProtocol_Base_one: 第一个协议类型，默认服务条款
    /// - firstContent_Base_one: 第一个协议内容
    /// - secondProtocol_Base_one: 第二个协议类型，默认隐私政策
    /// - secondContent_Base_one: 第二个协议内容
    /// - config_Base_one: 文本样式配置，默认浅色
    /// - viewController_Base_one: 点击跳转的目标控制器
    /// 返回值：配置好手势的富文本 UILabel
    static func createProtocolTextLabel_Base_one(
        firstProtocol_Base_one: ProtocolType_Base_one = .terms_Base_one,
        firstContent_Base_one: String,
        secondProtocol_Base_one: ProtocolType_Base_one = .privacy_Base_one,
        secondContent_Base_one: String,
        config_Base_one: ProtocolTextConfig_Base_one = .light_Base_one(),
        from viewController_Base_one: UIViewController
    ) -> UILabel {
        let label_Base_one = UILabel()
        label_Base_one.numberOfLines = 0
        label_Base_one.textAlignment = .center
        label_Base_one.isUserInteractionEnabled = true

        // 共享字体（前缀、分隔符、链接均使用同一字体）
        let font_Base_one = UIFont.systemFont(ofSize: config_Base_one.fontSize_Base_one, weight: config_Base_one.fontWeight_Base_one)

        let prefixAttrs_Base_one: [NSAttributedString.Key: Any] = [
            .font: font_Base_one,
            .foregroundColor: config_Base_one.textColor_Base_one
        ]

        var linkAttrs_Base_one: [NSAttributedString.Key: Any] = [
            .font: font_Base_one,
            .foregroundColor: config_Base_one.linkColor_Base_one
        ]
        if config_Base_one.hasUnderline_Base_one {
            linkAttrs_Base_one[.underlineStyle] = NSUnderlineStyle.single.rawValue
            linkAttrs_Base_one[.underlineColor] = config_Base_one.linkColor_Base_one
        }

        let text_Base_one = NSMutableAttributedString()
        text_Base_one.append(NSAttributedString(string: config_Base_one.prefixText_Base_one, attributes: prefixAttrs_Base_one))
        text_Base_one.append(NSAttributedString(string: firstProtocol_Base_one.title_Base_one, attributes: linkAttrs_Base_one))
        text_Base_one.append(NSAttributedString(string: config_Base_one.separatorText_Base_one, attributes: prefixAttrs_Base_one))
        text_Base_one.append(NSAttributedString(string: secondProtocol_Base_one.title_Base_one + ".", attributes: linkAttrs_Base_one))
        label_Base_one.attributedText = text_Base_one

        label_Base_one.addGestureRecognizer(ProtocolTextTapGesture_Base_one(
            firstProtocol_Base_one: firstProtocol_Base_one,
            firstContent_Base_one: firstContent_Base_one,
            secondProtocol_Base_one: secondProtocol_Base_one,
            secondContent_Base_one: secondContent_Base_one,
            prefixLength_Base_one: config_Base_one.prefixText_Base_one.count,
            firstTitleLength_Base_one: firstProtocol_Base_one.title_Base_one.count,
            separatorLength_Base_one: config_Base_one.separatorText_Base_one.count,
            secondTitleLength_Base_one: secondProtocol_Base_one.title_Base_one.count + 1,
            viewController_Base_one: viewController_Base_one
        ))
        return label_Base_one
    }
}

// MARK: - 协议文本点击手势

/// 协议文本点击手势识别器
/// 功能：识别点击位置所属的协议链接并跳转到对应详情页
class ProtocolTextTapGesture_Base_one: UITapGestureRecognizer {

    private let firstProtocol_Base_one: ProtocolHelper_Base_one.ProtocolType_Base_one
    private let firstContent_Base_one: String
    private let secondProtocol_Base_one: ProtocolHelper_Base_one.ProtocolType_Base_one
    private let secondContent_Base_one: String
    private let prefixLength_Base_one: Int
    private let firstTitleLength_Base_one: Int
    private let separatorLength_Base_one: Int
    private let secondTitleLength_Base_one: Int
    private weak var viewController_Base_one: UIViewController?

    init(
        firstProtocol_Base_one: ProtocolHelper_Base_one.ProtocolType_Base_one,
        firstContent_Base_one: String,
        secondProtocol_Base_one: ProtocolHelper_Base_one.ProtocolType_Base_one,
        secondContent_Base_one: String,
        prefixLength_Base_one: Int,
        firstTitleLength_Base_one: Int,
        separatorLength_Base_one: Int,
        secondTitleLength_Base_one: Int,
        viewController_Base_one: UIViewController
    ) {
        self.firstProtocol_Base_one = firstProtocol_Base_one
        self.firstContent_Base_one = firstContent_Base_one
        self.secondProtocol_Base_one = secondProtocol_Base_one
        self.secondContent_Base_one = secondContent_Base_one
        self.prefixLength_Base_one = prefixLength_Base_one
        self.firstTitleLength_Base_one = firstTitleLength_Base_one
        self.separatorLength_Base_one = separatorLength_Base_one
        self.secondTitleLength_Base_one = secondTitleLength_Base_one
        self.viewController_Base_one = viewController_Base_one
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(handleTap_Base_one(_:)))
    }

    @objc private func handleTap_Base_one(_ gesture: UITapGestureRecognizer) {
        guard let label_Base_one = gesture.view as? UILabel,
              let attrText_Base_one = label_Base_one.attributedText,
              let vc_Base_one = viewController_Base_one else { return }

        // 构建文本布局以确定点击字符索引
        let storage_Base_one = NSTextStorage(attributedString: attrText_Base_one)
        let layoutManager_Base_one = NSLayoutManager()
        let container_Base_one = NSTextContainer(size: label_Base_one.bounds.size)
        container_Base_one.lineFragmentPadding = 0
        container_Base_one.maximumNumberOfLines = label_Base_one.numberOfLines
        container_Base_one.lineBreakMode = label_Base_one.lineBreakMode
        layoutManager_Base_one.addTextContainer(container_Base_one)
        storage_Base_one.addLayoutManager(layoutManager_Base_one)

        let charIndex_Base_one = layoutManager_Base_one.characterIndex(
            for: gesture.location(in: label_Base_one),
            in: container_Base_one,
            fractionOfDistanceBetweenInsertionPoints: nil
        )

        let firstStart_Base_one  = prefixLength_Base_one
        let firstEnd_Base_one    = firstStart_Base_one + firstTitleLength_Base_one
        let secondStart_Base_one = firstEnd_Base_one + separatorLength_Base_one
        let secondEnd_Base_one   = secondStart_Base_one + secondTitleLength_Base_one

        if (firstStart_Base_one..<firstEnd_Base_one).contains(charIndex_Base_one) {
            ProtocolHelper_Base_one.showProtocol_Base_one(
                type_Base_one: firstProtocol_Base_one,
                content_Base_one: firstContent_Base_one,
                from: vc_Base_one
            )
        } else if (secondStart_Base_one..<secondEnd_Base_one).contains(charIndex_Base_one) {
            ProtocolHelper_Base_one.showProtocol_Base_one(
                type_Base_one: secondProtocol_Base_one,
                content_Base_one: secondContent_Base_one,
                from: vc_Base_one
            )
        }
    }
}

// MARK: - 协议视图控制器

/// 协议视图控制器
/// 功能：展示协议内容，根据 content 自动判断展示方式（WebView / 图片 / 文本）
class ProtocolViewController_Base_one: UIViewController {

    // MARK: - 属性

    private let protocolType_Base_one: ProtocolHelper_Base_one.ProtocolType_Base_one
    private let content_Base_one: String

    private var webView_Base_one: WKWebView?
    private var scrollView_Base_one: UIScrollView?
    private var activityIndicator_Base_one: UIActivityIndicatorView?

    /// 是否为远程 URL
    private var isRemoteURL_Base_one: Bool { content_Base_one.hasPrefix("http") }

    /// 是否为图片路径
    private var isImage_Base_one: Bool {
        ["png", "jpg", "jpeg"].contains { content_Base_one.hasSuffix(".\($0)") }
    }

    // MARK: - 初始化

    init(type_Base_one: ProtocolHelper_Base_one.ProtocolType_Base_one, content_Base_one: String) {
        self.protocolType_Base_one = type_Base_one
        self.content_Base_one = content_Base_one
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Base_one()
        loadContent_Base_one()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    // MARK: - UI设置

    private func setupUI_Base_one() {
        view.backgroundColor = .white
        title = protocolType_Base_one.title_Base_one
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped_Base_one)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black

        if isRemoteURL_Base_one {
            setupWebView_Base_one()
            setupActivityIndicator_Base_one()
        } else {
            setupScrollView_Base_one()
        }
    }

    /// 设置 WebView
    private func setupWebView_Base_one() {
        let wv_Base_one = WKWebView()
        wv_Base_one.navigationDelegate = self
        view.addSubview(wv_Base_one)
        wv_Base_one.snp.makeConstraints { $0.edges.equalToSuperview() }
        webView_Base_one = wv_Base_one
    }

    /// 设置 ScrollView（文本和图片共用）
    private func setupScrollView_Base_one() {
        let sv_Base_one = UIScrollView()
        sv_Base_one.showsVerticalScrollIndicator = true
        sv_Base_one.alwaysBounceVertical = true
        view.addSubview(sv_Base_one)
        sv_Base_one.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        scrollView_Base_one = sv_Base_one
    }

    /// 设置加载指示器
    private func setupActivityIndicator_Base_one() {
        let indicator_Base_one = UIActivityIndicatorView(style: .large)
        indicator_Base_one.color = .gray
        view.addSubview(indicator_Base_one)
        indicator_Base_one.snp.makeConstraints { $0.center.equalToSuperview() }
        activityIndicator_Base_one = indicator_Base_one
    }

    // MARK: - 加载内容

    private func loadContent_Base_one() {
        if isRemoteURL_Base_one {
            loadWebContent_Base_one()
        } else if isImage_Base_one {
            loadImageContent_Base_one()
        } else {
            loadTextContent_Base_one()
        }
    }

    /// 加载远程网页
    private func loadWebContent_Base_one() {
        guard let url_Base_one = URL(string: content_Base_one) else { return }
        activityIndicator_Base_one?.startAnimating()
        webView_Base_one?.load(URLRequest(url: url_Base_one))
    }

    /// 加载本地图片（按屏幕宽度等比缩放）
    private func loadImageContent_Base_one() {
        guard let sv_Base_one = scrollView_Base_one,
              let img_Base_one = UIImage(named: content_Base_one) else { return }

        let iv_Base_one = UIImageView()
        iv_Base_one.contentMode = .scaleAspectFit
        iv_Base_one.image = img_Base_one
        sv_Base_one.addSubview(iv_Base_one)

        let screenWidth_Base_one = view.bounds.width
        let displayHeight_Base_one = screenWidth_Base_one * img_Base_one.size.height / img_Base_one.size.width
        iv_Base_one.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.width.equalTo(screenWidth_Base_one)
            $0.height.equalTo(displayHeight_Base_one)
            $0.bottom.equalToSuperview()
        }
    }

    /// 加载本地文本
    private func loadTextContent_Base_one() {
        guard let sv_Base_one = scrollView_Base_one else { return }

        let label_Base_one = UILabel()
        label_Base_one.text = content_Base_one
        label_Base_one.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label_Base_one.textColor = .black
        label_Base_one.numberOfLines = 0
        sv_Base_one.addSubview(label_Base_one)
        label_Base_one.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(20)
            $0.width.equalTo(view.snp.width).offset(-40)
        }
    }

    // MARK: - 事件处理

    @objc private func backTapped_Base_one() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - WKNavigationDelegate

extension ProtocolViewController_Base_one: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator_Base_one?.startAnimating()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator_Base_one?.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator_Base_one?.stopAnimating()
        Load_Base_one.showError_Base_one(message_Base_one: "Failed to load content")
    }
}
