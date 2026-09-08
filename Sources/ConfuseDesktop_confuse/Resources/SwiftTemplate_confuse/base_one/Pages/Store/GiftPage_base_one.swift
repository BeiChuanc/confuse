import Foundation
import UIKit
import SnapKit

// MARK: - 送礼界面

/// 送礼模态弹起界面
/// 核心作用：展示礼物商品列表，用户选择后发起内购
/// 设计思路：
///   半透明遮罩 + gift_bg 背景卡片居中；
///   组件1：顶级一次性礼物横向卡片（HStack）；
///   组件2：普通礼物2行×4列网格；
///   底部购买按钮（gift_buy 图片）；
///   点击遮罩区域关闭，bgCard 外部区域可关闭。
/// 关键属性/方法：
///   - selectedGift_Base_one：当前选中的礼物
///   - refreshSelectionUI_Base_one：刷新选中态背景色
class GiftPage_Base_one: UIViewController {

    // MARK: - 布局常量

    private var screenW_Base_one: CGFloat { UIScreen.main.bounds.width }
    private var screenH_Base_one: CGFloat { UIScreen.main.bounds.height }
    /// bgCard 宽 = 屏幕宽 - 32
    private var bgCardW_Base_one: CGFloat { screenW_Base_one - 32 }
    /// bgCard 高 = 屏幕高 × 0.6
    private var bgCardH_Base_one: CGFloat { screenH_Base_one * 0.65 }
    /// 组件1/2 宽 = 屏幕宽 - 68，在 bgCard 内两侧对称内缩
    private var contentW_Base_one: CGFloat { screenW_Base_one - 68 }
    private var contentInset_Base_one: CGFloat { (bgCardW_Base_one - contentW_Base_one) / 2 }

    // MARK: - 数据

    /// 顶级礼物（goodIsTop = true，一次性购买）
    private var topGift_Base_one: StoreModel_Base_one?
    /// 普通礼物（非顶级，非VIP），最多取 8 个
    private var normalGifts_Base_one: [StoreModel_Base_one] = []
    /// 当前选中的礼物
    private var selectedGift_Base_one: StoreModel_Base_one?

    // MARK: - UI 组件

    /// 半透明遮罩（点击关闭）
    private let dimView_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.50)
        return v
    }()

    /// 背景卡片容器（gift_bg 图片作背景）
    private let bgCard_Base_one = UIView()

    /// gift_bg 背景图片
    private let bgImageView_Base_one: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "gift_bg")?.withRenderingMode(.alwaysOriginal)
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()

    /// 组件1：顶级礼物横向卡片
    private let comp1View_Base_one = UIView()
    /// 组件1内部白色卡片（存储引用以更新选中态）
    private weak var comp1Card_Base_one: UIView?
    private weak var comp1PriceLabel_Base_one: UILabel?
    private weak var comp1SubLabel_Base_one: UILabel?

    /// 组件2：普通礼物网格
    private let comp2View_Base_one = UIView()
    /// 组件2所有 GiftItemView（存储引用以更新选中态）
    private var comp2Items_Base_one: [GiftItemView_Base_one] = []

    /// 购买按钮（gift_buy 图片）
    private let buyBtn_Base_one: UIButton = {
        let btn = UIButton(type: .custom)
        let img = UIImage(named: "gift_buy")?.withRenderingMode(.alwaysOriginal)
        btn.setImage(img, for: .normal)
        btn.imageView?.contentMode = .scaleAspectFill
        btn.imageView?.clipsToBounds = true
        btn.clipsToBounds = true
        return btn
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        loadGiftData_Base_one()
        buildDimAndCard_Base_one()
        buildComp1_Base_one()
        buildComp2_Base_one()
        buildBuyBtn_Base_one()
        setupConstraints_Base_one()
    }

    // MARK: - 数据加载

    /// 加载礼物数据：区分顶级礼物与普通礼物
    private func loadGiftData_Base_one() {
        let all = Store_Base_one.shared_Base_one.goodsList_Base_one
            .filter { !($0.goodIsVIP_Base_one ?? false) }
        topGift_Base_one    = all.first { $0.goodIsTop_Base_one ?? false }
        normalGifts_Base_one = Array(
            all.filter { !($0.goodIsTop_Base_one ?? false) }.prefix(8)
        )
    }

    // MARK: - UI 搭建

    /// 搭建遮罩与背景卡片
    private func buildDimAndCard_Base_one() {
        view.addSubview(dimView_Base_one)
        /// 点击遮罩区域（bgCard 之外）关闭界面
        let dimTap = UITapGestureRecognizer(target: self, action: #selector(dimTapped_Base_one))
        dimView_Base_one.addGestureRecognizer(dimTap)

        view.addSubview(bgCard_Base_one)
        bgCard_Base_one.clipsToBounds = true
        bgCard_Base_one.addSubview(bgImageView_Base_one)
        /// bgCard 内容视图阻止触摸穿透到遮罩
        bgCard_Base_one.addSubview(comp1View_Base_one)
        bgCard_Base_one.addSubview(comp2View_Base_one)
    }

    // MARK: - 组件1：顶级礼物横向卡片

    /// 构建组件1（HStack：左侧价格+文字 / 右侧 gift_one 图片）
    /// 已购时禁用点击并显示 Already Purchased
    private func buildComp1_Base_one() {
        guard let top = topGift_Base_one else { return }

        /// 白色圆角卡片背景
        let card_Base_one = UIView()
        card_Base_one.backgroundColor = UIColor(hexstring_Base_one: "#2353E4")
        card_Base_one.layer.cornerRadius = 15
        card_Base_one.layer.masksToBounds = true
        comp1View_Base_one.addSubview(card_Base_one)
        card_Base_one.snp.makeConstraints { make in make.edges.equalToSuperview() }
        comp1Card_Base_one = card_Base_one

        /// 禁用/降透
        card_Base_one.alpha = 1.0
        card_Base_one.isUserInteractionEnabled = true

        /// 左侧价格文字栈
        let priceLabel_Base_one = UILabel()
        priceLabel_Base_one.text      = top.goodsPrice_Base_one ?? ""
        priceLabel_Base_one.font      = UIFont.systemFont(ofSize: 14, weight: .regular)
        priceLabel_Base_one.textColor = .white
        comp1PriceLabel_Base_one = priceLabel_Base_one

        let subLabel_Base_one = UILabel()
        subLabel_Base_one.text      = "Can only be purchased once"
        subLabel_Base_one.font      = UIFont.systemFont(ofSize: 10, weight: .regular)
        subLabel_Base_one.textColor = .white
        comp1SubLabel_Base_one = subLabel_Base_one

        let textStack_Base_one = UIStackView(arrangedSubviews: [priceLabel_Base_one, subLabel_Base_one])
        textStack_Base_one.axis      = .vertical
        textStack_Base_one.spacing   = 5
        textStack_Base_one.alignment = .leading

        /// 右侧礼物图（gift_one，72×72）
        let giftIV_Base_one = UIImageView()
        giftIV_Base_one.image       = UIImage(named: "gift_one")?.withRenderingMode(.alwaysOriginal)
        giftIV_Base_one.contentMode = .scaleAspectFit
        giftIV_Base_one.snp.makeConstraints { make in make.width.height.equalTo(72) }

        /// HStack：文字 + 图片，间距 8，居中
        let hStack_Base_one = UIStackView(arrangedSubviews: [textStack_Base_one, giftIV_Base_one])
        hStack_Base_one.axis      = .horizontal
        hStack_Base_one.spacing   = 8
        hStack_Base_one.alignment = .center

        card_Base_one.addSubview(hStack_Base_one)
        hStack_Base_one.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(16)
            make.trailing.lessThanOrEqualToSuperview().offset(-8)
        }
    }

    // MARK: - 组件2：普通礼物网格

    /// 构建组件2（2行×4列网格，行1用 gift_two，行2用 gift_three）
    private func buildComp2_Base_one() {
        comp2View_Base_one.backgroundColor = .clear
        comp2Items_Base_one.removeAll()

        let row1_Base_one = Array(normalGifts_Base_one.prefix(4))
        let row2_Base_one: [StoreModel_Base_one] = normalGifts_Base_one.count > 4
            ? Array(normalGifts_Base_one[4...].prefix(4)) : []

        let rowStack1_Base_one = buildGridRow_Base_one(gifts: row1_Base_one, iconName: "gift_two")
        let rowStack2_Base_one = buildGridRow_Base_one(gifts: row2_Base_one, iconName: "gift_three")

        let outerStack_Base_one = UIStackView(arrangedSubviews: [rowStack1_Base_one, rowStack2_Base_one])
        outerStack_Base_one.axis         = .vertical
        outerStack_Base_one.spacing      = 12
        outerStack_Base_one.distribution = .fillEqually

        comp2View_Base_one.addSubview(outerStack_Base_one)
        outerStack_Base_one.snp.makeConstraints { make in make.edges.equalToSuperview() }
    }

    /// 构建网格一行（4 个 GiftItemView，左右间距 5）
    /// - Parameters:
    ///   - gifts: 该行礼物数据（不足4个时用透明占位）
    ///   - iconName: 该行礼物图标名称
    /// - Returns: 横向 UIStackView
    private func buildGridRow_Base_one(gifts: [StoreModel_Base_one], iconName: String) -> UIStackView {
        var items_Base_one: [UIView] = []
        for i in 0..<4 {
            let gift_Base_one = i < gifts.count ? gifts[i] : nil
            let itemView_Base_one = GiftItemView_Base_one(iconName: iconName)
            if let gift_Base_one = gift_Base_one {
                itemView_Base_one.configure_Base_one(gift: gift_Base_one)
                comp2Items_Base_one.append(itemView_Base_one)
                let tap_Base_one = GiftItemTap_Base_one(
                    gift: gift_Base_one,
                    target: self,
                    action: #selector(gridItemTapped_Base_one(_:))
                )
                itemView_Base_one.isUserInteractionEnabled = true
                itemView_Base_one.addGestureRecognizer(tap_Base_one)
            } else {
                /// 空位透明占位
                itemView_Base_one.alpha = 0
                itemView_Base_one.isUserInteractionEnabled = false
            }
            items_Base_one.append(itemView_Base_one)
        }
        let stack_Base_one = UIStackView(arrangedSubviews: items_Base_one)
        stack_Base_one.axis         = .horizontal
        stack_Base_one.spacing      = 5
        stack_Base_one.distribution = .fillEqually
        return stack_Base_one
    }

    // MARK: - 购买按钮

    /// 搭建底部购买按钮（gift_buy 图片全宽）
    private func buildBuyBtn_Base_one() {
        bgCard_Base_one.addSubview(buyBtn_Base_one)
        buyBtn_Base_one.addTarget(self, action: #selector(buyTapped_Base_one), for: .touchUpInside)
    }

    // MARK: - 约束布局

    /// 设置所有 SnapKit 约束
    private func setupConstraints_Base_one() {
        let inset_Base_one = contentInset_Base_one
        /// 组件2高度 = 2行×109 + 行间距12
        let comp2H_Base_one: CGFloat = 109 * 2 + 12

        /// 全屏遮罩
        dimView_Base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        /// bgCard 居中
        bgCard_Base_one.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(bgCardW_Base_one)
            make.height.equalTo(bgCardH_Base_one)
        }

        /// 背景图铺满 bgCard
        bgImageView_Base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        /// 购买按钮：全宽，高62，距 bgCard 底部 50
        buyBtn_Base_one.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(62)
            make.bottom.equalToSuperview().offset(-50)
        }

        /// 组件2：宽 = contentW，高 = comp2H，位于购买按钮上方 10
        comp2View_Base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(inset_Base_one)
            make.trailing.equalToSuperview().offset(-inset_Base_one)
            make.height.equalTo(comp2H_Base_one)
            make.bottom.equalTo(buyBtn_Base_one.snp.top).offset(-10)
        }

        /// 组件1：宽 = contentW，高 72，位于组件2上方 10
        comp1View_Base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(inset_Base_one)
            make.trailing.equalToSuperview().offset(-inset_Base_one)
            make.height.equalTo(72)
            make.bottom.equalTo(comp2View_Base_one.snp.top).offset(-10)
        }
    }

    // MARK: - 事件处理

    /// 点击遮罩关闭界面
    @objc private func dimTapped_Base_one() {
        dismiss(animated: true)
    }

    /// 点击组件1（顶级礼物）
    @objc private func comp1Tapped_Base_one() {
        guard let top = topGift_Base_one else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        selectedGift_Base_one = top
        refreshSelectionUI_Base_one(selectedId: top.goodsId_Base_one)
    }

    /// 点击组件2网格某个礼物
    /// - Parameter tap: 携带礼物数据的自定义手势
    @objc private func gridItemTapped_Base_one(_ tap: GiftItemTap_Base_one) {
        guard let gift = tap.gift_Base_one else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        selectedGift_Base_one = gift
        refreshSelectionUI_Base_one(selectedId: gift.goodsId_Base_one)
    }

    /// 点击购买按钮发起内购
    @objc private func buyTapped_Base_one() {
        guard let gift_Base_one = selectedGift_Base_one,
              let gid_Base_one  = gift_Base_one.goodsId_Base_one else {
            Load_Base_one.showWarning_Base_one(message_Base_one: "Please select a gift first")
            return
        }
        Store_Base_one.shared_Base_one.PurchaseStoreGift_Base_one(gid_Base_one: gid_Base_one) { [weak self] in
            self?.dismiss(animated: true)
        }
    }

    // MARK: - 选中态刷新

    /// 刷新所有礼物条目的选中背景色
    /// - Parameter selectedId: 当前选中商品的 goodsId
    private func refreshSelectionUI_Base_one(selectedId: String?) {
        let normalBgColor_Base_one = UIColor(hexstring_Base_one: "#2353E4")
        let selectedBgColor_Base_one = UIColor.white
        let normalTextColor_Base_one = UIColor.white
        let selectedTextColor_Base_one = UIColor.black

        /// 组件1
        let isComp1_Base_one = selectedId == topGift_Base_one?.goodsId_Base_one
        UIView.animate(withDuration: 0.18) {
            self.comp1Card_Base_one?.backgroundColor = isComp1_Base_one ? selectedBgColor_Base_one : normalBgColor_Base_one
            self.comp1PriceLabel_Base_one?.textColor = isComp1_Base_one ? selectedTextColor_Base_one : normalTextColor_Base_one
            self.comp1SubLabel_Base_one?.textColor = isComp1_Base_one ? selectedTextColor_Base_one : normalTextColor_Base_one
        }

        /// 组件2
        comp2Items_Base_one.forEach { item_Base_one in
            let isSel_Base_one = item_Base_one.gift_Base_one?.goodsId_Base_one == selectedId
            UIView.animate(withDuration: 0.18) {
                item_Base_one.applySelectionState_Base_one(
                    isSelected_Base_one: isSel_Base_one,
                    normalBgColor_Base_one: normalBgColor_Base_one,
                    selectedBgColor_Base_one: selectedBgColor_Base_one,
                    normalTextColor_Base_one: normalTextColor_Base_one,
                    selectedTextColor_Base_one: selectedTextColor_Base_one
                )
            }
        }
    }
}

// MARK: - 礼物 Item 视图

/// 礼物商品单元视图（VStack：图标60×60 → 名称10pt → 价格14pt）
/// 功能：用于组件2网格，支持根据选中状态切换背景与文字颜色
/// 关键属性：gift_Base_one（绑定数据，供外部判断选中态）
class GiftItemView_Base_one: UIView {

    // MARK: - 属性

    /// 绑定的礼物数据（通过 configure 注入）
    private(set) var gift_Base_one: StoreModel_Base_one?

    // MARK: - UI 组件

    private let iconIV_Base_one: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 礼物名称：不加粗，10pt，#111111
    private let nameLabel_Base_one: UILabel = {
        let l = UILabel()
        l.font      = UIFont.systemFont(ofSize: 10, weight: .regular)
        l.textColor = .white
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    /// 礼物价格：14pt，#111111
    private let priceLabel_Base_one: UILabel = {
        let l = UILabel()
        l.font      = UIFont.systemFont(ofSize: 14, weight: .regular)
        l.textColor = .white
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    // MARK: - 初始化

    /// - Parameter iconName: 礼物图标 Assets 名称（gift_two / gift_three）
    init(iconName: String) {
        super.init(frame: .zero)
        iconIV_Base_one.image = UIImage(named: iconName)?.withRenderingMode(.alwaysOriginal)
        buildUI_Base_one()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    private func buildUI_Base_one() {
        backgroundColor = UIColor(hexstring_Base_one: "#2353E4")
        layer.cornerRadius = 15
        layer.masksToBounds = true

        /// VStack：图标 → 名称（间距5）→ 价格
        let vStack_Base_one = UIStackView(arrangedSubviews: [iconIV_Base_one, nameLabel_Base_one, priceLabel_Base_one])
        vStack_Base_one.axis         = .vertical
        vStack_Base_one.spacing      = 5
        vStack_Base_one.alignment    = .center
        vStack_Base_one.distribution = .fill

        addSubview(vStack_Base_one)
        vStack_Base_one.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(4)
            make.trailing.lessThanOrEqualToSuperview().offset(-4)
        }
        iconIV_Base_one.snp.makeConstraints { make in
            make.width.height.equalTo(60)
        }
    }

    // MARK: - 数据配置

    /// 绑定礼物数据到视图
    /// - Parameter gift: StoreModel_Base_one 礼物模型
    func configure_Base_one(gift: StoreModel_Base_one) {
        self.gift_Base_one     = gift
        nameLabel_Base_one.text  = gift.goodsName_Base_one  ?? ""
        priceLabel_Base_one.text = gift.goodsPrice_Base_one ?? ""
    }

    /// 应用礼物项选中态样式
    /// 参数：
    /// - isSelected_Base_one: 当前是否选中
    /// - normalBgColor_Base_one: 未选中背景色
    /// - selectedBgColor_Base_one: 选中背景色
    /// - normalTextColor_Base_one: 未选中文字色
    /// - selectedTextColor_Base_one: 选中文字色
    /// 返回值：无
    func applySelectionState_Base_one(isSelected_Base_one: Bool,
                                  normalBgColor_Base_one: UIColor,
                                  selectedBgColor_Base_one: UIColor,
                                  normalTextColor_Base_one: UIColor,
                                  selectedTextColor_Base_one: UIColor) {
        backgroundColor = isSelected_Base_one ? selectedBgColor_Base_one : normalBgColor_Base_one
        nameLabel_Base_one.textColor = isSelected_Base_one ? selectedTextColor_Base_one : normalTextColor_Base_one
        priceLabel_Base_one.textColor = isSelected_Base_one ? selectedTextColor_Base_one : normalTextColor_Base_one
    }
}

// MARK: - 携带礼物数据的点击手势

/// 携带礼物模型数据的自定义点击手势，用于网格 Item 回调
private class GiftItemTap_Base_one: UITapGestureRecognizer {

    /// 关联的礼物数据
    var gift_Base_one: StoreModel_Base_one?

    /// - Parameters:
    ///   - gift: 对应的礼物模型
    ///   - target: 响应者
    ///   - action: 响应方法
    convenience init(gift: StoreModel_Base_one, target: Any?, action: Selector?) {
        self.init(target: target, action: action)
        self.gift_Base_one = gift
    }
}
