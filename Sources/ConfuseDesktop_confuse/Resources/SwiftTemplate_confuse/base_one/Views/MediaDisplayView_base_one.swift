import Foundation
import UIKit
import SnapKit
import Kingfisher
import AVFoundation

// MARK: 媒体展示组件

/// 媒体类型枚举
enum MediaType_Base_one {
    case image_Base_one
    case video_Base_one
    case none_Base_one
}

/// 媒体展示视图
/// 功能：展示图片或视频封面，支持 SF Symbols、Assets、网络图片、本地文件及视频缩略图
/// 设计：圆角、占位符、视频播放图标
class MediaDisplayView_Base_one: UIView {

    // MARK: - 静态常量

    /// 渐变色配置（用于 SF Symbols 背景，按哈希值循环选取）
    private static let gradientColors_Base_one: [(UIColor, UIColor)] = [
        (UIColor(hexstring_Base_one: "#667eea"), UIColor(hexstring_Base_one: "#764ba2")),
        (UIColor(hexstring_Base_one: "#f093fb"), UIColor(hexstring_Base_one: "#f5576c")),
        (UIColor(hexstring_Base_one: "#4facfe"), UIColor(hexstring_Base_one: "#00f2fe")),
        (UIColor(hexstring_Base_one: "#43e97b"), UIColor(hexstring_Base_one: "#38f9d7")),
        (UIColor(hexstring_Base_one: "#fa709a"), UIColor(hexstring_Base_one: "#fee140"))
    ]

    /// 占位符渐变色
    private static let placeholderGradientColors_Base_one: [CGColor] = [
        UIColor(hexstring_Base_one: "#667eea").withAlphaComponent(0.3).cgColor,
        UIColor(hexstring_Base_one: "#764ba2").withAlphaComponent(0.3).cgColor
    ]

    // MARK: - UI组件

    private let imageView_Base_one: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.backgroundColor = UIColor(hexstring_Base_one: "#F7FAFC")
        v.isUserInteractionEnabled = true
        return v
    }()

    /// 系统图标容器（不拦截触摸）
    private let iconContainerView_Base_one: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 视频播放遮罩
    private let playIconView_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        v.layer.cornerRadius = 30
        v.isHidden = true
        return v
    }()

    private let playIconImageView_Base_one: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(systemName: "play.fill")
        v.tintColor = .white
        v.contentMode = .scaleAspectFit
        return v
    }()

    /// 无媒体时的占位图标
    private let placeholderIconView_Base_one: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(systemName: "photo.on.rectangle.angled")
        v.tintColor = UIColor(hexstring_Base_one: "#A0AEC0")
        v.contentMode = .scaleAspectFit
        return v
    }()

    // MARK: - 属性

    private var mediaType_Base_one: MediaType_Base_one = .none_Base_one

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Base_one()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI设置

    private func setupUI_Base_one() {
        layer.cornerRadius = 12
        clipsToBounds = true

        addSubview(imageView_Base_one)
        addSubview(iconContainerView_Base_one)
        addSubview(placeholderIconView_Base_one)
        addSubview(playIconView_Base_one)
        playIconView_Base_one.addSubview(playIconImageView_Base_one)

        imageView_Base_one.snp.makeConstraints { $0.edges.equalToSuperview() }
        iconContainerView_Base_one.snp.makeConstraints { $0.edges.equalToSuperview() }
        placeholderIconView_Base_one.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(48)
        }
        playIconView_Base_one.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(60)
        }
        playIconImageView_Base_one.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(28)
        }
    }

    // MARK: - 公共方法

    /// 直接展示 UIImage（相册选图后使用，无需路径）
    /// 参数：
    /// - image_Base_one: 要展示的图片对象
    func configureWithImage_Base_one(image_Base_one: UIImage) {
        mediaType_Base_one = .image_Base_one
        clearOldContent_Base_one()
        imageView_Base_one.image = image_Base_one
        placeholderIconView_Base_one.isHidden = true
        playIconView_Base_one.isHidden = true
    }

    /// 配置媒体展示
    /// 参数：
    /// - mediaPath_Base_one: 媒体路径（nil 或空字符串时显示占位符）
    /// - isVideo_Base_one: 是否为视频，默认 false
    func configure_Base_one(mediaPath_Base_one: String?, isVideo_Base_one: Bool = false) {
        guard let path_Base_one = mediaPath_Base_one, !path_Base_one.isEmpty else {
            showPlaceholder_Base_one()
            return
        }
        mediaType_Base_one = isVideo_Base_one ? .video_Base_one : .image_Base_one
        playIconView_Base_one.isHidden = !isVideo_Base_one
        loadMedia_Base_one(path_Base_one: path_Base_one, isVideo_Base_one: isVideo_Base_one)
    }

    // MARK: - 私有方法 - 媒体加载

    /// 按优先级依次尝试各来源加载媒体
    private func loadMedia_Base_one(path_Base_one: String, isVideo_Base_one: Bool) {
        // 1. SF Symbols
        if let sysImg_Base_one = UIImage(systemName: path_Base_one) {
            loadSystemIcon_Base_one(image_Base_one: sysImg_Base_one, path_Base_one: path_Base_one)
            return
        }

        // 2. Assets
        if let assetImg_Base_one = UIImage(named: path_Base_one) {
            loadImageSuccess_Base_one(image_Base_one: assetImg_Base_one)
            return
        }

        // 3. 网络图片
        if path_Base_one.hasPrefix("http://") || path_Base_one.hasPrefix("https://") {
            loadNetworkImage_Base_one(urlString_Base_one: path_Base_one)
            return
        }

        let docsDir_Base_one = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

        // 4. 文档目录（文件名）
        let docFile_Base_one = docsDir_Base_one.appendingPathComponent(path_Base_one)
        if let img_Base_one = UIImage(contentsOfFile: docFile_Base_one.path) {
            loadImageSuccess_Base_one(image_Base_one: img_Base_one)
            print("✅ 从文档目录加载媒体: \(path_Base_one)")
            return
        }

        // 5. 完整本地路径
        if let img_Base_one = UIImage(contentsOfFile: path_Base_one) {
            loadImageSuccess_Base_one(image_Base_one: img_Base_one)
            return
        }

        // 6. Bundle 视频
        if let url_Base_one = Self.bundleVideoURL_Base_one(named: path_Base_one) {
            showVideoThumbnail_Base_one(url_Base_one: url_Base_one)
            return
        }

        // 7. 文档目录视频
        for ext_Base_one in ["mp4", "mov", "m4v"] {
            let videoFile_Base_one = docsDir_Base_one.appendingPathComponent("\(path_Base_one).\(ext_Base_one)")
            if FileManager.default.fileExists(atPath: videoFile_Base_one.path) {
                showVideoThumbnail_Base_one(url_Base_one: videoFile_Base_one)
                return
            }
        }

        // 8. 所有来源均失败
        print("⚠️ 无法加载媒体: \(path_Base_one)")
        showPlaceholder_Base_one()
    }

    /// 清理旧内容（图片、渐变图层、图标子视图）
    private func clearOldContent_Base_one() {
        imageView_Base_one.image = nil
        imageView_Base_one.layer.sublayers?.removeAll()
        iconContainerView_Base_one.subviews.forEach { $0.removeFromSuperview() }
    }

    /// 展示 SF Symbol 图标（带哈希选色渐变背景）
    private func loadSystemIcon_Base_one(image_Base_one: UIImage, path_Base_one: String) {
        clearOldContent_Base_one()

        let gradient_Base_one = Self.gradientColors_Base_one[abs(path_Base_one.hashValue) % Self.gradientColors_Base_one.count]
        addGradientLayer_Base_one(colors_Base_one: [gradient_Base_one.0.cgColor, gradient_Base_one.1.cgColor])

        let icon_Base_one = UIImageView(image: image_Base_one)
        icon_Base_one.tintColor = .white
        icon_Base_one.contentMode = .scaleAspectFit
        icon_Base_one.alpha = 0.9
        iconContainerView_Base_one.addSubview(icon_Base_one)
        icon_Base_one.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(80)
        }
        placeholderIconView_Base_one.isHidden = true
    }

    /// 使用 Kingfisher 加载网络图片
    private func loadNetworkImage_Base_one(urlString_Base_one: String) {
        clearOldContent_Base_one()
        if let url_Base_one = URL(string: urlString_Base_one) {
            imageView_Base_one.kf.setImage(
                with: url_Base_one,
                placeholder: createPlaceholderImage_Base_one(),
                options: [.transition(.fade(0.3))]
            )
        }
        placeholderIconView_Base_one.isHidden = true
    }

    /// 图片加载成功后更新 imageView
    private func loadImageSuccess_Base_one(image_Base_one: UIImage) {
        clearOldContent_Base_one()
        imageView_Base_one.image = image_Base_one
        placeholderIconView_Base_one.isHidden = true
    }

    /// 设置视频类型状态并触发缩略图生成
    /// 参数：
    /// - url_Base_one: 视频文件 URL
    private func showVideoThumbnail_Base_one(url_Base_one: URL) {
        mediaType_Base_one = .video_Base_one
        playIconView_Base_one.isHidden = false
        generateVideoThumbnail_Base_one(url_Base_one: url_Base_one)
    }

    /// 在 imageView 下方插入渐变图层
    private func addGradientLayer_Base_one(colors_Base_one: [CGColor]) {
        let layer_Base_one = CAGradientLayer()
        layer_Base_one.frame = bounds
        layer_Base_one.colors = colors_Base_one
        layer_Base_one.startPoint = CGPoint(x: 0, y: 0)
        layer_Base_one.endPoint = CGPoint(x: 1, y: 1)
        imageView_Base_one.layer.insertSublayer(layer_Base_one, at: 0)
    }

    /// 显示占位符状态（带渐变背景）
    private func showPlaceholder_Base_one() {
        mediaType_Base_one = .none_Base_one
        clearOldContent_Base_one()
        placeholderIconView_Base_one.isHidden = false
        playIconView_Base_one.isHidden = true
        addGradientLayer_Base_one(colors_Base_one: Self.placeholderGradientColors_Base_one)
    }

    /// 生成 Kingfisher 占位图（纯色背景块）
    private func createPlaceholderImage_Base_one() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 100, height: 100), false, 0)
        UIColor(hexstring_Base_one: "#F7FAFC").setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 100, height: 100))
        let img_Base_one = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img_Base_one
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if mediaType_Base_one == .none_Base_one {
            imageView_Base_one.layer.sublayers?.first?.frame = bounds
        }
    }

    // MARK: - 视频工具方法

    /// 在 Bundle 中查找视频文件（依次尝试 mp4 / mov / m4v）
    /// 参数：
    /// - named_Base_one: 不含扩展名的资源名
    /// 返回值：找到时返回 URL，否则 nil
    static func bundleVideoURL_Base_one(named named_Base_one: String) -> URL? {
        ["mp4", "mov", "m4v"].lazy
            .compactMap { Bundle.main.url(forResource: named_Base_one, withExtension: $0) }
            .first
    }

    /// 从视频 URL 异步提取第一帧作为缩略图
    /// 参数：
    /// - url_Base_one: 视频文件 URL
    private func generateVideoThumbnail_Base_one(url_Base_one: URL) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let generator_Base_one = AVAssetImageGenerator(asset: AVURLAsset(url: url_Base_one))
            generator_Base_one.appliesPreferredTrackTransform = true
            generator_Base_one.maximumSize = CGSize(width: 600, height: 600)
            do {
                let cgImage_Base_one = try generator_Base_one.copyCGImage(
                    at: CMTime(seconds: 0.1, preferredTimescale: 600),
                    actualTime: nil
                )
                DispatchQueue.main.async {
                    self?.loadImageSuccess_Base_one(image_Base_one: UIImage(cgImage: cgImage_Base_one))
                    self?.playIconView_Base_one.isHidden = false
                }
            } catch {
                print("⚠️ 视频缩略图提取失败: \(error.localizedDescription)")
                DispatchQueue.main.async { self?.showPlaceholder_Base_one() }
            }
        }
    }
}
