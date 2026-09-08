import Foundation
import UIKit
import SnapKit

// MARK: 导航器

/// 屏幕高宽
enum APPSCREEN_Base_one {
    
    static let WIDTH_Base_one = UIScreen.main.bounds.width
    
    static let HEIGHT_Base_one = UIScreen.main.bounds.height
}

/// 底部导航页面
class TabBar_Base_one: UITabBarController {
    
    /// 黄色背景视图
    private var tabBgView_Base_one = UIView()
    
    /// 按钮容器栈视图
    private var tabStackView_Base_one = UIStackView()
    
    /// 首页按钮
    private var btnHome_Base_one = UIButton(type: .custom)
    
    /// 发现页按钮
    private var btnDiscover_Base_one = UIButton(type: .custom)
    
    /// 发布按钮
    private var btnRelease_Base_one = UIButton(type: .custom)
    
    /// 消息按钮
    private var btnMessage_Base_one = UIButton(type: .custom)
    
    /// 我的按钮
    private var btnMe_Base_one = UIButton(type: .custom)
    
    /// 当前选中索引
    private var currentIndex_Base_one: Int = 0
    
    // MARK: - 生命周期方法
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置视图控制器
        viewControllers = [Home_Base_one(), Discover_Base_one(), Release_Base_one(), MessageList_Base_one(), Me_Base_one()]
        
        setupUI_Base_one()
        setupConstraints_Base_one()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tabBar.isHidden = true
    }
    
    // MARK: - UI设置
    private func setupUI_Base_one() {
        // 配置黄色背景视图
        tabBgView_Base_one.backgroundColor = UIColor(hexstring_Base_one: "#FFD700")
        tabBgView_Base_one.layer.masksToBounds = true
        view.addSubview(tabBgView_Base_one)
        
        // 配置StackView
        tabStackView_Base_one.axis = .horizontal
        tabStackView_Base_one.distribution = .equalSpacing
        tabStackView_Base_one.alignment = .center
        tabStackView_Base_one.spacing = 20
        view.addSubview(tabStackView_Base_one)
        
        // 配置首页按钮
        btnHome_Base_one.setImage(UIImage(named: "front_select"), for: .selected)
        btnHome_Base_one.setImage(UIImage(named: "front_select")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnHome_Base_one.tintColor = .gray
        btnHome_Base_one.tag = 0
        btnHome_Base_one.addTarget(self, action: #selector(tabButtonTapped_Base_one(_:)), for: .touchUpInside)
        tabStackView_Base_one.addArrangedSubview(btnHome_Base_one)
        
        // 配置发现页按钮
        btnDiscover_Base_one.setImage(UIImage(named: "pu_select"), for: .selected)
        btnDiscover_Base_one.setImage(UIImage(named: "pu_select")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnDiscover_Base_one.tintColor = .gray
        btnDiscover_Base_one.tag = 1
        btnDiscover_Base_one.addTarget(self, action: #selector(tabButtonTapped_Base_one(_:)), for: .touchUpInside)
        tabStackView_Base_one.addArrangedSubview(btnDiscover_Base_one)
        
        // 配置发布按钮
        btnRelease_Base_one.setImage(UIImage(named: "publish"), for: .normal)
        btnRelease_Base_one.tag = 2
        btnRelease_Base_one.addTarget(self, action: #selector(tabButtonTapped_Base_one(_:)), for: .touchUpInside)
        tabStackView_Base_one.addArrangedSubview(btnRelease_Base_one)
        
        // 配置消息按钮
        btnMessage_Base_one.setImage(UIImage(named: "mes_select"), for: .selected)
        btnMessage_Base_one.setImage(UIImage(named: "mes_select")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnMessage_Base_one.tintColor = .gray
        btnMessage_Base_one.tag = 3
        btnMessage_Base_one.addTarget(self, action: #selector(tabButtonTapped_Base_one(_:)), for: .touchUpInside)
        tabStackView_Base_one.addArrangedSubview(btnMessage_Base_one)
        
        // 配置我的按钮
        btnMe_Base_one.setImage(UIImage(named: "me_select"), for: .selected)
        btnMe_Base_one.setImage(UIImage(named: "me_select")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnMe_Base_one.tintColor = .gray
        btnMe_Base_one.tag = 4
        btnMe_Base_one.addTarget(self, action: #selector(tabButtonTapped_Base_one(_:)), for: .touchUpInside)
        tabStackView_Base_one.addArrangedSubview(btnMe_Base_one)
        
        // 设置初始选中状态
        btnHome_Base_one.isSelected = true
    }
    
    /// 设置约束布局
    private func setupConstraints_Base_one() {
        // StackView约束
        tabStackView_Base_one.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.bottom.equalToSuperview().offset(-50)
            make.height.equalTo(50)
        }
        
        // 按钮尺寸约束
        btnHome_Base_one.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        btnDiscover_Base_one.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        btnRelease_Base_one.snp.makeConstraints { make in
            make.width.height.equalTo(45)
        }
        
        btnMessage_Base_one.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        btnMe_Base_one.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        // 黄色背景视图约束（上下各距离StackView 15）
        tabBgView_Base_one.snp.makeConstraints { make in
            make.leading.trailing.equalTo(tabStackView_Base_one)
            make.top.equalTo(tabStackView_Base_one).offset(-15)
            make.bottom.equalTo(tabStackView_Base_one).offset(15)
        }
        
        // 设置圆角为高度的一半
        tabBgView_Base_one.layoutIfNeeded()
        let bgHeight = 50 + 30 // StackView高度50 + 上下各15
        tabBgView_Base_one.layer.cornerRadius = CGFloat(bgHeight) / 2.0
    }
    
    @objc private func tabButtonTapped_Base_one(_ sender: UIButton) {
        let index = sender.tag
        
        // 更新选中状态
        currentIndex_Base_one = index
        selectedIndex = index
        
        // 更新所有按钮的选中状态
        btnHome_Base_one.isSelected = (index == 0)
        btnDiscover_Base_one.isSelected = (index == 1)
        btnRelease_Base_one.isSelected = (index == 2)
        btnMessage_Base_one.isSelected = (index == 3)
        btnMe_Base_one.isSelected = (index == 4)
    }
}
