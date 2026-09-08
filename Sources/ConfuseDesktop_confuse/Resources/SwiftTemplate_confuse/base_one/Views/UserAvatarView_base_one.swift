import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: - 用户头像组件

/// 用户头像视图
class UserAvatarView_Base_one: UIView {
    
    // MARK: - 静态常量
    
    /// 用户默认头像颜色数组
    static let defaultAvatarColors_Base_one: [UIColor] = [
        UIColor(hexstring_Base_one: "#B794F6"),
        UIColor(hexstring_Base_one: "#FBB6CE"),
        UIColor(hexstring_Base_one: "#63B3ED"),
        UIColor(hexstring_Base_one: "#F6AD55"),
        UIColor(hexstring_Base_one: "#FC8181")
    ]
    
    // MARK: - UI组件
    
    /// 头像图片视图
    let imageView_Base_one: UIImageView = {
        let imageView_Base_one = UIImageView()
        imageView_Base_one.contentMode = .scaleAspectFill
        imageView_Base_one.clipsToBounds = true
        imageView_Base_one.backgroundColor = UIColor(hexstring_Base_one: "#F7FAFC")
        return imageView_Base_one
    }()
    
    // MARK: - 属性
    
    var userId_Base_one: Int?
    var isCurrentUser_Base_one: Bool = false
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Base_one()
        observeUserState_Base_one()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 设置圆形
        imageView_Base_one.layer.cornerRadius = bounds.width / 2
    }
    
    // MARK: - UI设置
    
    /// 设置基础UI布局，子类可重写以自定义布局
    func setupUI_Base_one() {
        addSubview(imageView_Base_one)
        
        imageView_Base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    /// 监听用户状态变化
    func observeUserState_Base_one() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Base_one),
            name: UserViewModel_Base_one.userStateDidChangeNotification_Base_one,
            object: nil
        )
    }
    
    // MARK: - 公共方法
    
    /// 配置用户头像
    func configure_Base_one(userId_Base_one: Int) {
        self.userId_Base_one = userId_Base_one
        
        // 判断是否是当前登录用户
        let currentUser_Base_one = UserViewModel_Base_one.shared_Base_one.getCurrentUser_Base_one()
        isCurrentUser_Base_one = (currentUser_Base_one.userId_Base_one == userId_Base_one)
        
        // 加载头像
        if isCurrentUser_Base_one {
            loadCurrentUserAvatar_Base_one(user_Base_one: currentUser_Base_one)
        } else {
            loadOtherUserAvatar_Base_one(userId_Base_one: userId_Base_one)
        }
    }
    
    /// 加载当前登录用户头像
    private func loadCurrentUserAvatar_Base_one(user_Base_one: LoginUserModel_Base_one) {
        guard let headPath_Base_one = user_Base_one.userHead_Base_one, !headPath_Base_one.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Base_one(color_Base_one: UIColor(hexstring_Base_one: "#B794F6"))
            return
        }
        
        loadAvatarFromPath_Base_one(path_Base_one: headPath_Base_one, defaultColor_Base_one: UIColor(hexstring_Base_one: "#B794F6"))
    }
    
    /// 加载其他用户头像
    private func loadOtherUserAvatar_Base_one(userId_Base_one: Int) {
        let userInfo_Base_one = UserViewModel_Base_one.shared_Base_one.getUserById_Base_one(userId_base_one: userId_Base_one)
        let color_Base_one = Self.defaultAvatarColors_Base_one[userId_Base_one % Self.defaultAvatarColors_Base_one.count]
        
        guard let headPath_Base_one = userInfo_Base_one.userHead_Base_one, !headPath_Base_one.isEmpty else {
            // 使用默认头像，不同用户不同颜色
            setDefaultAvatar_Base_one(color_Base_one: color_Base_one)
            return
        }
        
        loadAvatarFromPath_Base_one(path_Base_one: headPath_Base_one, defaultColor_Base_one: color_Base_one)
    }
    
    /// 从路径加载头像
    func loadAvatarFromPath_Base_one(path_Base_one: String, defaultColor_Base_one: UIColor) {
        // 1. 尝试从Assets加载
        if let assetImage_Base_one = UIImage(named: path_Base_one) {
            imageView_Base_one.image = assetImage_Base_one
            imageView_Base_one.contentMode = .scaleAspectFill
            return
        }
        
        // 2. 尝试从相册路径加载
        if let localImage_Base_one = UIImage(contentsOfFile: path_Base_one) {
            imageView_Base_one.image = localImage_Base_one
            imageView_Base_one.contentMode = .scaleAspectFill
            return
        }
        
        // 3. 尝试从网络URL加载
        if path_Base_one.hasPrefix("http://") || path_Base_one.hasPrefix("https://") {
            if let url_Base_one = URL(string: path_Base_one) {
                imageView_Base_one.kf.setImage(
                    with: url_Base_one,
                    placeholder: createPlaceholderImage_Base_one(color_Base_one: defaultColor_Base_one),
                    options: [.transition(.fade(0.2))]
                )
            }
            return
        }
        
        // 4. 都失败则使用默认头像
        setDefaultAvatar_Base_one(color_Base_one: defaultColor_Base_one)
    }
    
    /// 设置默认头像（系统图标）
    /// - Parameter color_Base_one: 图标颜色
    func setDefaultAvatar_Base_one(color_Base_one: UIColor) {
        imageView_Base_one.image = UIImage(systemName: "person.circle.fill")
        imageView_Base_one.tintColor = color_Base_one
        imageView_Base_one.contentMode = .scaleAspectFit
    }
    
    /// 创建占位符图片
    func createPlaceholderImage_Base_one(color_Base_one: UIColor) -> UIImage? {
        let size_Base_one = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Base_one, false, 0)
        
        // 绘制圆形背景
        color_Base_one.withAlphaComponent(0.2).setFill()
        let circlePath_Base_one = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size_Base_one))
        circlePath_Base_one.fill()
        
        // 绘制人物图标
        if let icon_Base_one = UIImage(systemName: "person.fill") {
            color_Base_one.setFill()
            icon_Base_one.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Base_one = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Base_one
    }
    
    // MARK: - 事件处理
    
    /// 处理用户状态变化，子类可重写以自定义行为
    @objc func handleUserStateChange_Base_one() {
        if let userId_Base_one = userId_Base_one {
            configure_Base_one(userId_Base_one: userId_Base_one)
        }
    }
    
    // MARK: - 析构
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 登录用户头像组件

/// 登录用户头像组件
class CurrentUserAvatarView_Base_one: UserAvatarView_Base_one {

    // MARK: - 属性

    /// 点击回调
    var onTapped_Base_one: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadCurrentUserAvatar_Base_one()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置（重写）
    
    override func setupUI_Base_one() {
        super.setupUI_Base_one()
        
        // 启用用户交互
        isUserInteractionEnabled = true
        imageView_Base_one.isUserInteractionEnabled = true

        // 添加点击手势（绑定到整个头像组件，避免局部区域点击失效）
        let tapSelfGesture_Base_one = UITapGestureRecognizer(target: self, action: #selector(handleTap_Base_one))
        addGestureRecognizer(tapSelfGesture_Base_one)
        let tapGesture_Base_one = UITapGestureRecognizer(target: self, action: #selector(handleTap_Base_one))
        imageView_Base_one.addGestureRecognizer(tapGesture_Base_one)
    }
    
    // MARK: - 加载头像
    
    /// 加载当前登录用户头像
    func loadCurrentUserAvatar_Base_one() {
        let currentUser_Base_one = UserViewModel_Base_one.shared_Base_one.getCurrentUser_Base_one()
        isCurrentUser_Base_one = true
        userId_Base_one = currentUser_Base_one.userId_Base_one
        
        guard let headPath_Base_one = currentUser_Base_one.userHead_Base_one, !headPath_Base_one.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Base_one(color_Base_one: UIColor(hexstring_Base_one: "#B794F6"))
            return
        }
        
        loadAvatarFromPath_Base_one(path_Base_one: headPath_Base_one, defaultColor_Base_one: UIColor(hexstring_Base_one: "#B794F6"))
    }
    
    /// 创建渐变占位符图片（重写父类方法，使用渐变效果）
    override func createPlaceholderImage_Base_one(color_Base_one: UIColor) -> UIImage? {
        let size_Base_one = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Base_one, false, 0)
        
        // 绘制渐变背景
        let context_Base_one = UIGraphicsGetCurrentContext()
        let colors_Base_one = [
            UIColor(hexstring_Base_one: "#B794F6").cgColor,
            UIColor(hexstring_Base_one: "#90CDF4").cgColor
        ]
        let colorSpace_Base_one = CGColorSpaceCreateDeviceRGB()
        let gradient_Base_one = CGGradient(colorsSpace: colorSpace_Base_one, colors: colors_Base_one as CFArray, locations: nil)
        
        context_Base_one?.drawLinearGradient(
            gradient_Base_one!,
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: size_Base_one.width, y: size_Base_one.height),
            options: []
        )
        
        // 绘制人物图标
        if let icon_Base_one = UIImage(systemName: "person.fill") {
            UIColor.white.setFill()
            icon_Base_one.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Base_one = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Base_one
    }
    
    // MARK: - 事件处理
    
    /// 处理头像点击事件
    @objc private func handleTap_Base_one() {
        
        // 触觉反馈
        let generator_Base_one = UIImpactFeedbackGenerator(style: .light)
        generator_Base_one.impactOccurred()
        
        // 触发回调
        onTapped_Base_one?()
    }
    
    /// 重写用户状态变化处理（重新加载当前用户头像）
    @objc override func handleUserStateChange_Base_one() {
        loadCurrentUserAvatar_Base_one()
    }
}
