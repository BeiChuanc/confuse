import Foundation
import UIKit
import SnapKit

// MARK: - VIP 订阅页面

/// VIP 订阅页面
/// 核心作用：展示 VIP 套餐列表，支持套餐选择、发起内购订阅及恢复购买
/// 设计思路：全屏青紫渐变背景（左上 #00FFF0 → 右下 #A678F1）+ 顶部 vip_top 装饰图 + 纵向套餐列表 + 底部操作区
/// 关键属性：
/// - vipItems_Base_one: 从 Store_Base_one 筛选出 goodIsVIP_Base_one 为 true 的套餐数组
/// - selectedItem_Base_one: 当前选中的 VIP 套餐（发起购买前校验）
/// - itemCells_Base_one: 所有套餐 Cell，用于统一切换选中态
class VIPSubscription_Base_one: UIViewController {

    // MARK: - 数据

    /// 所有 VIP 套餐
    private var vipItems_Base_one: [StoreModel_Base_one] = []
    /// 当前选中套餐
    private var selectedItem_Base_one: StoreModel_Base_one?
    /// 所有套餐 Cell 引用（统一更新选中态）
    private var itemCells_Base_one: [VIPItemCell_Base_one] = []

    // MARK: - UI · 背景渐变

    private var bgGradient_Base_one: CAGradientLayer?

    // MARK: - UI · 自定义导航栏

    private let navBar_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    private let backButton_Base_one: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Base_one = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(
            UIImage(systemName: "chevron.left", withConfiguration: cfg_Base_one)?
                .withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        b.tintColor = .white
        b.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        b.layer.cornerRadius = 18
        return b
    }()

    private let navTitleLabel_Base_one: UILabel = {
        let l = UILabel()
        l.text = "Subscription"
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = .white
        return l
    }()

    // MARK: - UI · 滚动容器

    private let scrollView_Base_one: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    private let contentView_Base_one = UIView()

    // MARK: - UI · 组件1：顶部装饰图

    /// vip_top 装饰图（组件1），紧贴导航栏底部，左右内边距20，完整展示图片内容
    private let vipTopImage_Base_one: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "vip_top")
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        return iv
    }()

    // MARK: - UI · 组件2：套餐纵向列表

    /// 套餐纵向 StackView，间距 12
    private let itemsVStack_Base_one: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()

    // MARK: - UI · 组件3：恢复购买

    private let restoreButton_Base_one: UIButton = {
        let b = UIButton(type: .system)
        let attrs_Base_one: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .regular),
            .foregroundColor: UIColor.black,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.black
        ]
        let title_Base_one = NSAttributedString(string: "Restore Purchases", attributes: attrs_Base_one)
        b.setAttributedTitle(title_Base_one, for: .normal)
        b.backgroundColor = .clear
        return b
    }()

    // MARK: - UI · 组件4：订阅按钮

    private let subscribeButton_Base_one: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(named: "vip_sub"), for: .normal)
        b.imageView?.contentMode = .scaleAspectFit
        b.clipsToBounds = true
        return b
    }()

    // MARK: - UI · 组件5：协议标签

    private var protocolLabel_Base_one: UILabel?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData_Base_one()
        setupUI_Base_one()
        buildItemCells_Base_one()
        setupActions_Base_one()
        // 默认选中第一项
        if let first_Base_one = vipItems_Base_one.first {
            updateSelection_Base_one(model: first_Base_one)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 只有被 pop 出栈时才恢复导航栏，避免 modal 弹出时错误地改变导航栏状态
        if isMovingFromParent {
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgGradient_Base_one?.frame = view.bounds
    }

    // MARK: - 数据加载

    /// 从 Store_Base_one 筛选 VIP 套餐
    private func loadData_Base_one() {
        vipItems_Base_one = Store_Base_one.shared_Base_one.goodsList_Base_one.filter { $0.goodIsVIP_Base_one == true }
    }

    // MARK: - UI 搭建

    private func setupUI_Base_one() {
        setupBgGradient_Base_one()

        view.addSubview(scrollView_Base_one)
        scrollView_Base_one.addSubview(contentView_Base_one)

        // 组件1
        contentView_Base_one.addSubview(vipTopImage_Base_one)
        // 组件2：纵向列表
        contentView_Base_one.addSubview(itemsVStack_Base_one)
        // 组件4
        contentView_Base_one.addSubview(subscribeButton_Base_one)

        // 组件5：协议标签（terms + eula，黑色文字）
        let proto_Base_one = ProtocolHelper_Base_one.createProtocolTextLabel_Base_one(
            firstProtocol_Base_one: .terms_Base_one,
            firstContent_Base_one: "terms.png",
            secondProtocol_Base_one: .eula_Base_one,
            secondContent_Base_one: "eula.png",
            config_Base_one: ProtocolHelper_Base_one.ProtocolTextConfig_Base_one(
                textColor_Base_one: UIColor(hexstring_Base_one: "#111111"),
                linkColor_Base_one: UIColor(hexstring_Base_one: "#111111"),
                fontSize_Base_one: 13,
                fontWeight_Base_one: .regular,
                hasUnderline_Base_one: true
            ),
            from: self
        )
        contentView_Base_one.addSubview(proto_Base_one)
        protocolLabel_Base_one = proto_Base_one

        // 导航栏（最顶层）
        view.addSubview(navBar_Base_one)
        navBar_Base_one.addSubview(backButton_Base_one)
        navBar_Base_one.addSubview(navTitleLabel_Base_one)
        navBar_Base_one.addSubview(restoreButton_Base_one)

        setupConstraints_Base_one(protoLabel: proto_Base_one)
    }

    /// 全屏渐变背景：#7297F9（顶部居中）→ #4A8EFF（底部居中）
    private func setupBgGradient_Base_one() {
        let gl_Base_one = CAGradientLayer()
        gl_Base_one.colors = [
            UIColor(hexstring_Base_one: "#7297F9").cgColor,
            UIColor(hexstring_Base_one: "#4A8EFF").cgColor
        ]
        gl_Base_one.startPoint = CGPoint(x: 0.5, y: 0.0)
        gl_Base_one.endPoint   = CGPoint(x: 0.5, y: 1.0)
        view.layer.insertSublayer(gl_Base_one, at: 0)
        bgGradient_Base_one = gl_Base_one
    }

    // MARK: - 构建套餐 Cell

    /// 遍历 vipItems_Base_one 生成 VIPItemCell_Base_one 并加入纵向列表
    private func buildItemCells_Base_one() {
        itemCells_Base_one.removeAll()
        vipItems_Base_one.forEach { model_Base_one in
            let cell_Base_one = VIPItemCell_Base_one()
            cell_Base_one.configure_Base_one(model: model_Base_one)
            cell_Base_one.onTap_Base_one = { [weak self] selected_Base_one in
                self?.updateSelection_Base_one(model: selected_Base_one)
            }
            itemsVStack_Base_one.addArrangedSubview(cell_Base_one)
            cell_Base_one.snp.makeConstraints {
                $0.height.equalTo(50)
            }
            itemCells_Base_one.append(cell_Base_one)
        }
    }

    // MARK: - 约束

    private func setupConstraints_Base_one(protoLabel: UILabel) {
        let screenW_Base_one = UIScreen.main.bounds.width
        // 图片宽度 = 屏幕宽 - 左右各20内边距，高度按图片实际比例自适应（scaleAspectFit）
        let imgW_Base_one: CGFloat = screenW_Base_one - 40
        let img_Base_one = UIImage(named: "vip_top")
        let aspect_Base_one = img_Base_one.map { $0.size.height / $0.size.width } ?? 0.75
        let vipTopH_Base_one: CGFloat = imgW_Base_one * aspect_Base_one

        // 导航栏
        navBar_Base_one.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(56)
        }
        backButton_Base_one.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.width.height.equalTo(36)
        }
        navTitleLabel_Base_one.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton_Base_one)
        }
        restoreButton_Base_one.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalTo(backButton_Base_one)
            $0.height.equalTo(22)
        }

        // 滚动容器：顶部从导航栏底部开始，确保内容可正常滚动
        scrollView_Base_one.snp.makeConstraints {
            $0.top.equalTo(navBar_Base_one.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        contentView_Base_one.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        // 组件1：vip_top，左右内边距20，高度按缩小比例展示完整图片
        vipTopImage_Base_one.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(vipTopH_Base_one)
        }

        // 组件2：纵向套餐列表，距 vip_top 下方 20，左右内边距16
        itemsVStack_Base_one.snp.makeConstraints {
            $0.top.equalTo(vipTopImage_Base_one.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }

        // 组件4：订阅按钮，距套餐列表下方 20，屏幕宽-32，高 62
        subscribeButton_Base_one.snp.makeConstraints {
            $0.top.equalTo(itemsVStack_Base_one.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(62)
        }

        // 组件5：协议，距订阅按钮下方 15
        protoLabel.snp.makeConstraints {
            $0.top.equalTo(subscribeButton_Base_one.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().offset(-30)
        }
    }

    // MARK: - 选中状态更新

    /// 更新所有 Cell 的选中态，并记录当前选中套餐
    /// - Parameter model: 被选中的套餐模型
    private func updateSelection_Base_one(model: StoreModel_Base_one) {
        selectedItem_Base_one = model
        itemCells_Base_one.forEach { cell_Base_one in
            cell_Base_one.setSelected_Base_one(cell_Base_one.model_Base_one?.id_Base_one == model.id_Base_one)
        }
    }

    // MARK: - 事件绑定

    private func setupActions_Base_one() {
        backButton_Base_one.addTarget(self, action: #selector(backTapped_Base_one), for: .touchUpInside)
        restoreButton_Base_one.addTarget(self, action: #selector(restoreTapped_Base_one), for: .touchUpInside)
        subscribeButton_Base_one.addTarget(self, action: #selector(subscribeTapped_Base_one), for: .touchUpInside)
    }

    @objc private func backTapped_Base_one() {
        Navigation_Base_one.pop_Base_one(from: self)
    }

    /// 恢复购买按钮回调
    @objc private func restoreTapped_Base_one() {
        Subscribe_Base_one.shared_Base_one.RestorePurchase_Base_one { [weak self] in
            guard let self_Base_one = self else { return }
            _ = self_Base_one
        }
    }

    /// 订阅按钮回调：发起 VIP 内购
    @objc private func subscribeTapped_Base_one() {
        guard let item_Base_one = selectedItem_Base_one,
              let gid_Base_one  = item_Base_one.goodsId_Base_one else {
            Load_Base_one.showWarning_Base_one(message_Base_one: "Please select a subscription plan.")
            return
        }
        Subscribe_Base_one.shared_Base_one.PurchaseStoreVIP_Base_one(vipId_Base_one: gid_Base_one) { [weak self] in
            guard let self_Base_one = self else { return }
            Navigation_Base_one.pop_Base_one(from: self_Base_one)
        }
    }
}

// MARK: - VIPItemCell_Base_one

/// VIP 套餐单元格视图
/// 核心作用：展示单个 VIP 套餐信息（选中图标 + 套餐名 + 价格），支持点击回调
/// 设计思路：高度50的圆角10横向卡片，未选中白底蓝字，选中蓝底白字并显示24x24圆形状态图标
/// 关键方法：
/// - configure_Base_one: 注入套餐数据（价格 + 套餐名）
/// - setSelected_Base_one: 切换选中态（背景透明度 + 套餐名颜色）
private class VIPItemCell_Base_one: UIView {

    // MARK: - 属性

    /// 当前套餐数据（外部只读，内部赋值）
    private(set) var model_Base_one: StoreModel_Base_one?

    /// 点击回调，回传选中的套餐模型
    var onTap_Base_one: ((StoreModel_Base_one) -> Void)?

    // MARK: - UI

    /// 选中状态圆形指示器
    private let selectCircle_Base_one: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 12
        v.layer.borderWidth = 2
        v.layer.borderColor = UIColor(hexstring_Base_one: "#2353E4").cgColor
        v.backgroundColor = .clear
        v.isHidden = true
        return v
    }()
    private let selectInnerDot_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Base_one: "#2353E4")
        v.layer.cornerRadius = 6
        v.isHidden = true
        return v
    }()

    /// 价格文本，字号20加粗
    private let priceLabel_Base_one: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 20, weight: .bold)
        l.textColor     = UIColor(hexstring_Base_one: "#2353E4")
        l.textAlignment = .right
        return l
    }()

    /// 套餐名：默认蓝色，选中白色，字号18加粗
    private let nameLabel_Base_one: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 18, weight: .bold)
        l.textColor     = UIColor(hexstring_Base_one: "#2353E4")
        l.textAlignment = .left
        return l
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Base_one()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    private func setupUI_Base_one() {
        backgroundColor = UIColor.white
        layer.cornerRadius = 10
        layer.masksToBounds = true

        addSubview(selectCircle_Base_one)
        selectCircle_Base_one.addSubview(selectInnerDot_Base_one)
        addSubview(nameLabel_Base_one)
        addSubview(priceLabel_Base_one)

        selectCircle_Base_one.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(14)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        selectInnerDot_Base_one.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(12)
        }
        nameLabel_Base_one.snp.makeConstraints {
            $0.leading.equalTo(selectCircle_Base_one.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(priceLabel_Base_one.snp.leading).offset(-12)
        }
        priceLabel_Base_one.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-14)
            $0.centerY.equalToSuperview()
        }

        // 点击手势
        let tap_Base_one = UITapGestureRecognizer(target: self, action: #selector(handleTap_Base_one))
        addGestureRecognizer(tap_Base_one)
        isUserInteractionEnabled = true
    }

    // MARK: - 数据填充

    /// 注入套餐数据
    /// - Parameter model: VIP 套餐模型（读取 goodsPrice_Base_one 和 goodsName_Base_one）
    func configure_Base_one(model: StoreModel_Base_one) {
        self.model_Base_one = model
        priceLabel_Base_one.text = model.goodsPrice_Base_one
        nameLabel_Base_one.text = model.goodsName_Base_one
    }

    // MARK: - 选中态切换

    /// 切换选中状态：选中时蓝底白字，未选中时白底蓝字，并同步圆形指示器
    /// - Parameter selected: true 为选中态，false 为未选中态
    func setSelected_Base_one(_ selected: Bool) {
        backgroundColor = selected ? UIColor(hexstring_Base_one: "#2353E4") : UIColor.white
        nameLabel_Base_one.textColor = selected ? UIColor.white : UIColor(hexstring_Base_one: "#2353E4")
        priceLabel_Base_one.textColor = selected ? UIColor.white : UIColor(hexstring_Base_one: "#2353E4")
        selectCircle_Base_one.layer.borderColor = selected ? UIColor.white.cgColor : UIColor(hexstring_Base_one: "#2353E4").cgColor
        selectInnerDot_Base_one.backgroundColor = selected ? UIColor.white : UIColor(hexstring_Base_one: "#2353E4")
        selectCircle_Base_one.isHidden = !selected
        selectInnerDot_Base_one.isHidden = !selected
    }

    // MARK: - 点击处理

    @objc private func handleTap_Base_one() {
        guard let model_Base_one = model_Base_one else { return }
        onTap_Base_one?(model_Base_one)
    }
}
