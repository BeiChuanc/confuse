import Foundation
import UIKit
import SnapKit

// MARK: - 视频通话界面

/// 视频通话界面
/// 核心功能：模拟视频通话界面，展示对方头像和操作按钮
/// 设计思路：纯黑背景，头像居中展示，以头像为圆心向外辐射多圈同心细纹水波纹动画，
///           随机模拟对方拒接（3秒）或无人应答（10秒）自动挂断场景
/// 关键属性：
/// - userModel_Base_one: 通话用户信息
/// - rippleAnimationLayers_Base_one: 同心圆细纹水波纹图层数组
/// - isSimulatingDecline_Base_one: 随机决定本次通话是否模拟拒接场景
/// 关键方法：
/// - setupAvatarWithRipples_Base_one: 构建头像与同心圆水波纹
/// - startRippleAnimation_Base_one: 启动由内向外依次显示的细纹动画
/// - startAutoHangUpTimers_Base_one: 启动自动挂断计时器
/// - hangUpCall_Base_one: 手动挂断通话
class VideoChat_Base_one: UIViewController {
    
    // MARK: - 属性
    
    /// 通话用户
    var userModel_Base_one: PrewUserModel_Base_one?
    
    /// 同心圆细纹水波纹图层数组（由内向外排列）
    private var rippleAnimationLayers_Base_one: [CAShapeLayer] = []
    
    /// 挂断按钮摇摆动画引用（用于停止）
    private var swayAnimationTimer_Base_one: Timer?
    
    /// 无人应答自动挂断计时器（10 秒后触发）
    private var noAnswerTimer_Base_one: Timer?
    
    /// 模拟拒接自动挂断计时器（3 秒后触发）
    private var declineTimer_Base_one: Timer?
    
    /// 随机决定本次通话场景：true = 3秒对方拒接；false = 10秒无人应答
    private let isSimulatingDecline_Base_one: Bool = Bool.random()
    
    // MARK: - UI 组件
    
    /// 头像容器视图（300×300，承载头像及同心圆水波纹图层）
    private let avatarContainerView_Base_one: UIView = {
        let view_Base_one = UIView()
        view_Base_one.backgroundColor = .clear
        return view_Base_one
    }()
    
    /// 用户头像
    private let avatarImageView_Base_one: UIImageView = {
        let imageView_Base_one = UIImageView()
        imageView_Base_one.contentMode = .scaleAspectFill
        imageView_Base_one.clipsToBounds = true
        imageView_Base_one.layer.cornerRadius = 63
        imageView_Base_one.layer.borderWidth = 3
        imageView_Base_one.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
        return imageView_Base_one
    }()
    
    /// 用户名标签
    private let usernameLabel_Base_one: UILabel = {
        let label_Base_one = UILabel()
        label_Base_one.textColor = .white
        label_Base_one.textAlignment = .center
        label_Base_one.font = UIFont.boldSystemFont(ofSize: 26)
        return label_Base_one
    }()
    
    /// 通话状态标签
    private let statusLabel_Base_one: UILabel = {
        let label_Base_one = UILabel()
        label_Base_one.text = "Calling..."
        label_Base_one.textColor = UIColor.white.withAlphaComponent(0.6)
        label_Base_one.textAlignment = .center
        label_Base_one.font = UIFont.systemFont(ofSize: 16)
        return label_Base_one
    }()
    
    /// 挂断按钮
    private let hangUpButton_Base_one: UIButton = {
        let button_Base_one = UIButton(type: .system)
        button_Base_one.backgroundColor = UIColor(hexstring_Base_one: "#BE92FD")
        button_Base_one.layer.cornerRadius = 25
        button_Base_one.layer.shadowColor = UIColor(hexstring_Base_one: "#FF6B9D").cgColor
        button_Base_one.layer.shadowOffset = CGSize(width: 0, height: 8)
        button_Base_one.layer.shadowOpacity = 0.4
        button_Base_one.layer.shadowRadius = 16
        
        let config_Base_one = UIImage.SymbolConfiguration(pointSize: 32, weight: .bold)
        let image_Base_one = UIImage(systemName: "phone.down.fill", withConfiguration: config_Base_one)
        button_Base_one.setImage(image_Base_one, for: .normal)
        button_Base_one.tintColor = .white
        
        return button_Base_one
    }()
    
    /// 举报按钮
    private lazy var reportButton_Base_one: UIButton = {
        let button_Base_one = ReportDeleteHelper_Base_one.createUserReportButton_Base_one(
            size_Base_one: 44,
            backgroundColor_Base_one: UIColor.white.withAlphaComponent(0.15),
            tintColor_Base_one: .white,
            withShadow_Base_one: true
        )
        return button_Base_one
    }()
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI_Base_one()
        setupActions_Base_one()
        setupAnimations_Base_one()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startRippleAnimation_Base_one()
        startSwayAnimation_Base_one()
        startAutoHangUpTimers_Base_one()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAnimations_Base_one()
        cancelAutoHangUpTimers_Base_one()
    }
    
    deinit {
        swayAnimationTimer_Base_one?.invalidate()
        cancelAutoHangUpTimers_Base_one()
    }
    
    // MARK: - UI 设置
    
    /// 构建界面布局
    private func setupUI_Base_one() {
        view.addSubview(avatarContainerView_Base_one)
        view.addSubview(usernameLabel_Base_one)
        view.addSubview(statusLabel_Base_one)
        view.addSubview(hangUpButton_Base_one)
        
        setupAvatarWithRipples_Base_one()
        
        view.addSubview(reportButton_Base_one)
        
        // 填充用户数据
        if let userModel_Base_one = userModel_Base_one {
            usernameLabel_Base_one.text = userModel_Base_one.userName_Base_one
            if let imageName_Base_one = userModel_Base_one.userHead_Base_one {
                avatarImageView_Base_one.image = UIImage(named: imageName_Base_one)
            }
        }
        
        setupConstraints_Base_one()
    }
    
    /// 构建头像与同心圆水波纹图层
    /// 容器尺寸 300×300，头像居中，以头像圆心为基准向外依次创建 5 圈细纹
    private func setupAvatarWithRipples_Base_one() {
        avatarContainerView_Base_one.addSubview(avatarImageView_Base_one)
        
        // 容器中心坐标（300/2 = 150）
        let center_Base_one = CGPoint(x: 150, y: 150)
        
        // 头像半径 63，从外缘起步每隔 18pt 创建一圈细纹，共 5 圈
        let avatarRadius_Base_one: CGFloat = 63
        let ringSpacing_Base_one: CGFloat = 18
        let ringCount_Base_one = 5
        
        for i in 0..<ringCount_Base_one {
            let radius_Base_one = avatarRadius_Base_one + CGFloat(i + 1) * ringSpacing_Base_one
            
            let rippleLayer_Base_one = CAShapeLayer()
            let circlePath_Base_one = UIBezierPath(
                arcCenter: center_Base_one,
                radius: radius_Base_one,
                startAngle: 0,
                endAngle: CGFloat.pi * 2,
                clockwise: true
            )
            rippleLayer_Base_one.path = circlePath_Base_one.cgPath
            rippleLayer_Base_one.strokeColor = UIColor.white.withAlphaComponent(0.75).cgColor
            rippleLayer_Base_one.fillColor = UIColor.clear.cgColor
            rippleLayer_Base_one.lineWidth = 1.0
            rippleLayer_Base_one.opacity = 0
            
            // 插入到头像视图层级之下
            avatarContainerView_Base_one.layer.insertSublayer(rippleLayer_Base_one, at: 0)
            rippleAnimationLayers_Base_one.append(rippleLayer_Base_one)
        }
        
        avatarImageView_Base_one.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(126)
        }
    }
    
    /// 设置约束
    private func setupConstraints_Base_one() {
        // 头像容器：300×300，水波纹在此范围内完整展示
        avatarContainerView_Base_one.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(80)
            make.width.height.equalTo(300)
        }
        
        // 用户名
        usernameLabel_Base_one.snp.makeConstraints { make in
            make.top.equalTo(avatarContainerView_Base_one.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(40)
        }
        
        // 状态标签
        statusLabel_Base_one.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel_Base_one.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(40)
        }
        
        // 挂断按钮
        hangUpButton_Base_one.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-60)
            make.width.equalTo(120)
            make.height.equalTo(70)
        }
        
        // 举报按钮
        reportButton_Base_one.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(44)
        }
    }
    
    /// 绑定按钮事件
    private func setupActions_Base_one() {
        hangUpButton_Base_one.addTarget(self, action: #selector(hangUpCall_Base_one), for: .touchUpInside)
        reportButton_Base_one.addTarget(self, action: #selector(reportTapped_Base_one), for: .touchUpInside)
    }
    
    // MARK: - 动画设置
    
    /// 设置进场动画
    private func setupAnimations_Base_one() {
        // 头像容器弹性进场
        avatarContainerView_Base_one.alpha = 0
        avatarContainerView_Base_one.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        UIView.animate(withDuration: 0.6, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0) {
            self.avatarContainerView_Base_one.alpha = 1
            self.avatarContainerView_Base_one.transform = .identity
        }
        
        // 文字淡入
        usernameLabel_Base_one.alpha = 0
        statusLabel_Base_one.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0.4) {
            self.usernameLabel_Base_one.alpha = 1
            self.statusLabel_Base_one.alpha = 1
        }
        
        // 挂断按钮从下方滑入
        hangUpButton_Base_one.alpha = 0
        hangUpButton_Base_one.transform = CGAffineTransform(translationX: 0, y: 50)
        UIView.animate(withDuration: 0.5, delay: 0.6, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
            self.hangUpButton_Base_one.alpha = 1
            self.hangUpButton_Base_one.transform = .identity
        }
    }
    
    /// 启动水波纹动画：由内向外依次对各圈细纹做透明度脉冲
    /// 各圈之间错开 0.5 秒，形成涟漪向外扩散的视觉效果
    private func startRippleAnimation_Base_one() {
        let cycleDuration: Double = 2.5
        let staggerInterval: Double = 0.5
        
        for (index_Base_one, layer_Base_one) in rippleAnimationLayers_Base_one.enumerated() {
            // 透明度关键帧：快速亮起 → 缓慢消散
            let opacityAnim_Base_one = CAKeyframeAnimation(keyPath: "opacity")
            opacityAnim_Base_one.values = [0, 0.55, 0.22, 0]
            opacityAnim_Base_one.keyTimes = [0, 0.2, 0.65, 1.0]
            opacityAnim_Base_one.duration = cycleDuration
            opacityAnim_Base_one.repeatCount = .infinity
            opacityAnim_Base_one.beginTime = CACurrentMediaTime() + Double(index_Base_one) * staggerInterval
            opacityAnim_Base_one.isRemovedOnCompletion = false
            
            layer_Base_one.add(opacityAnim_Base_one, forKey: "rippleOpacity_Base_one")
        }
    }
    
    /// 启动挂断按钮左右摇摆动画
    private func startSwayAnimation_Base_one() {
        let swayAnimation_Base_one = CABasicAnimation(keyPath: "transform.rotation")
        swayAnimation_Base_one.fromValue = -0.05
        swayAnimation_Base_one.toValue = 0.05
        swayAnimation_Base_one.duration = 0.8
        swayAnimation_Base_one.autoreverses = true
        swayAnimation_Base_one.repeatCount = .infinity
        swayAnimation_Base_one.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        hangUpButton_Base_one.layer.add(swayAnimation_Base_one, forKey: "sway")
    }
    
    /// 停止所有图层动画
    private func stopAnimations_Base_one() {
        for layer_Base_one in rippleAnimationLayers_Base_one {
            layer_Base_one.removeAllAnimations()
        }
        hangUpButton_Base_one.layer.removeAllAnimations()
    }
    
    // MARK: - 自动挂断
    
    /// 启动自动挂断计时器
    /// 随机选择场景：对方 3 秒拒接 或 10 秒无人应答（仅一个计时器生效）
    private func startAutoHangUpTimers_Base_one() {
        if isSimulatingDecline_Base_one {
            // 模拟场景：对方 3 秒后主动拒接
            declineTimer_Base_one = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
                self?.autoHangUp_Base_one(reason_Base_one: "The other party declined your call")
            }
        } else {
            // 模拟场景：10 秒内无人应答
            noAnswerTimer_Base_one = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
                self?.autoHangUp_Base_one(reason_Base_one: "No answer")
            }
        }
    }
    
    /// 取消所有自动挂断计时器
    private func cancelAutoHangUpTimers_Base_one() {
        declineTimer_Base_one?.invalidate()
        declineTimer_Base_one = nil
        noAnswerTimer_Base_one?.invalidate()
        noAnswerTimer_Base_one = nil
    }
    
    /// 自动挂断并展示提示弹窗
    /// - Parameter reason_Base_one: 显示给用户的挂断原因
    private func autoHangUp_Base_one(reason_Base_one: String) {
        cancelAutoHangUpTimers_Base_one()
        stopAnimations_Base_one()
        
        let alert_Base_one = UIAlertController(title: nil, message: reason_Base_one, preferredStyle: .alert)
        let okAction_Base_one = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        }
        alert_Base_one.addAction(okAction_Base_one)
        present(alert_Base_one, animated: true)
    }
    
    // MARK: - 事件处理
    
    /// 手动挂断通话
    @objc private func hangUpCall_Base_one() {
        cancelAutoHangUpTimers_Base_one()
        
        // 按钮点击缩放反馈
        UIView.animate(withDuration: 0.1, animations: {
            self.hangUpButton_Base_one.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.hangUpButton_Base_one.transform = .identity
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.dismiss(animated: true)
        }
    }
    
    /// 举报按钮点击：拉黑该用户并清除导航堆栈中所有与该用户相关的页面
    @objc private func reportTapped_Base_one() {
        guard let userModel_Base_one = userModel_Base_one else { return }
        
        // 先取消自动挂断，避免与举报流程冲突
        cancelAutoHangUpTimers_Base_one()
        
        ReportDeleteHelper_Base_one.block_Base_one(
            user_Base_one: userModel_Base_one,
            from: self
        ) { [weak self] in
            guard let self = self else { return }
            // 拉黑成功：dismiss 当前视图并清除导航栈中的相关页面
            Navigation_Base_one.popToSafeStateAfterBlock_Base_one(from: self)
        }
    }
}
