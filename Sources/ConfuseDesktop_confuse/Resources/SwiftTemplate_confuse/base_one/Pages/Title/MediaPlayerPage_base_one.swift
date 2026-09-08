import UIKit
import SnapKit
import Kingfisher
import AVFoundation

// MARK: - 全屏媒体浏览页

/// 全屏媒体浏览页
/// 核心作用：
///   - 图片模式：以沉浸式黑底全屏展示，支持双指缩放、双击放大/还原、下滑关闭
///   - 视频模式：通过 AVPlayer 播放 Bundle / Documents / 网络视频，支持播放/暂停、进度条、下滑关闭
/// 设计思路：
///   - 媒体路径与 MediaDisplayView_Base_one 加载策略完全对齐（Bundle → Documents → 网络）
///   - 顶部半透明导航条（关闭按钮 + 媒体类型标签）
///   - 背景 alpha 跟随下拉手势动态变化，松手回弹或关闭
/// 关键属性：
///   - mediaPath_Base_one:  媒体路径（支持 Assets / 网络 / Documents / Bundle 视频）
///   - isVideo_Base_one:    是否强制为视频模式（传 false 时由加载器自动检测）
class MediaPlayerPage_Base_one: UIViewController {

    // MARK: - 对外属性

    /// 媒体路径（支持 Assets 名 / https URL / Documents 文件名 / Bundle 资源名）
    var mediaPath_Base_one: String?

    /// 是否强制当作视频处理（false 时由加载流程自动检测）
    var isVideo_Base_one: Bool = false

    // MARK: - 私有属性

    /// 当前实际媒体类型（加载后确定）
    private var resolvedType_Base_one: MediaType_Base_one = .none_Base_one

    /// 下拉关闭时记录的起始偏移
    private var isDismissing_Base_one = false
    /// 图片原始尺寸（缩放布局用）
    private var imageSize_Base_one: CGSize = .zero

    // MARK: - AVPlayer（视频）

    private var player_Base_one: AVPlayer?
    private var playerLayer_Base_one: AVPlayerLayer?
    /// 视频进度观察者令牌
    private var timeObserverToken_Base_one: Any?
    /// 是否处于播放状态
    private var isPlaying_Base_one = false

    // MARK: - UI：黑色背景

    private let backgroundView_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        return v
    }()

    // MARK: - UI：图片模式

    private let scrollView_Base_one: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator   = false
        sv.showsHorizontalScrollIndicator = false
        sv.contentInsetAdjustmentBehavior = .never
        sv.bouncesZoom      = true
        sv.minimumZoomScale = 1.0
        sv.maximumZoomScale = 4.0
        sv.backgroundColor  = .clear
        return sv
    }()

    private let imageView_Base_one: UIImageView = {
        let iv = UIImageView()
        iv.contentMode   = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .clear
        return iv
    }()

    // MARK: - UI：视频模式

    /// 视频渲染容器（AVPlayerLayer 附着此 View）
    private let videoContainerView_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        v.isHidden        = true
        return v
    }()

    /// 播放/暂停中央大按钮（覆盖在视频上）
    private let playPauseButton_Base_one: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Base_one = UIImage.SymbolConfiguration(pointSize: 36, weight: .bold)
        b.setImage(UIImage(systemName: "play.circle.fill",  withConfiguration: cfg_Base_one), for: .normal)
        b.setImage(UIImage(systemName: "pause.circle.fill", withConfiguration: cfg_Base_one), for: .selected)
        b.tintColor       = .white
        b.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        b.layer.cornerRadius = 40
        b.alpha = 0   // 初始隐藏，加载完成后淡入
        return b
    }()

    /// 底部进度条背景
    private let progressBg_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor    = UIColor.white.withAlphaComponent(0.25)
        v.layer.cornerRadius = 2
        v.isHidden           = true
        return v
    }()

    /// 底部进度条前景
    private let progressFill_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor    = .white
        v.layer.cornerRadius = 2
        return v
    }()

    /// 进度条宽度约束（实时更新）
    private var progressWidthCon_Base_one: Constraint?

    // MARK: - UI：共用

    private let loadingIndicator_Base_one: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = .white
        ai.hidesWhenStopped = true
        return ai
    }()

    private let topBar_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        return v
    }()

    private let closeButton_Base_one: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Base_one = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        b.setImage(UIImage(systemName: "xmark", withConfiguration: cfg_Base_one), for: .normal)
        b.tintColor          = .white
        b.backgroundColor    = UIColor.white.withAlphaComponent(0.15)
        b.layer.cornerRadius = 18
        b.layer.borderWidth  = 1
        b.layer.borderColor  = UIColor.white.withAlphaComponent(0.25).cgColor
        return b
    }()

    private let mediaTypeLabel_Base_one: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor     = UIColor.white.withAlphaComponent(0.75)
        l.textAlignment = .center
        return l
    }()

    private let bottomHint_Base_one: UILabel = {
        let l = UILabel()
        l.text          = "Swipe down to close"
        l.font          = .systemFont(ofSize: 11, weight: .regular)
        l.textColor     = UIColor.white.withAlphaComponent(0.45)
        l.textAlignment = .center
        return l
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI_Base_one()
        buildConstraints_Base_one()
        bindGestures_Base_one()
        loadMedia_Base_one()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 进场前预设透明，由 viewDidAppear 统一淡入，避免与系统转场动画叠加导致闪烁
        view.alpha = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.25) { self.view.alpha = 1 }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cleanupPlayer_Base_one()
    }

    deinit {
        cleanupPlayer_Base_one()
    }

    // MARK: - UI 搭建

    private func buildUI_Base_one() {
        view.backgroundColor = .black

        view.addSubview(backgroundView_Base_one)

        // 图片容器
        view.addSubview(scrollView_Base_one)
        scrollView_Base_one.addSubview(imageView_Base_one)
        scrollView_Base_one.delegate = self

        // 视频容器
        view.addSubview(videoContainerView_Base_one)
        videoContainerView_Base_one.addSubview(playPauseButton_Base_one)
        videoContainerView_Base_one.addSubview(progressBg_Base_one)
        progressBg_Base_one.addSubview(progressFill_Base_one)

        // 通用
        view.addSubview(loadingIndicator_Base_one)
        view.addSubview(topBar_Base_one)
        topBar_Base_one.addSubview(closeButton_Base_one)
        topBar_Base_one.addSubview(mediaTypeLabel_Base_one)
        view.addSubview(bottomHint_Base_one)
    }

    private func buildConstraints_Base_one() {
        backgroundView_Base_one.snp.makeConstraints { $0.edges.equalToSuperview() }
        scrollView_Base_one.snp.makeConstraints     { $0.edges.equalToSuperview() }
        imageView_Base_one.frame = view.bounds

        videoContainerView_Base_one.snp.makeConstraints { $0.edges.equalToSuperview() }
        playPauseButton_Base_one.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(80)
        }

        progressBg_Base_one.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(60)
            $0.height.equalTo(4)
        }
        progressFill_Base_one.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            progressWidthCon_Base_one = $0.width.equalTo(0).constraint
        }

        loadingIndicator_Base_one.snp.makeConstraints { $0.center.equalToSuperview() }

        topBar_Base_one.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        closeButton_Base_one.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(12)
            $0.width.height.equalTo(36)
        }
        mediaTypeLabel_Base_one.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(14)
        }
        bottomHint_Base_one.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topBar_Base_one.snp.updateConstraints {
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        playerLayer_Base_one?.frame = videoContainerView_Base_one.bounds
        updateImageLayout_Base_one()
    }

    // MARK: - 手势

    private func bindGestures_Base_one() {
        // 双击缩放（图片）
        let doubleTap_Base_one = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap_Base_one(_:)))
        doubleTap_Base_one.numberOfTapsRequired = 2
        scrollView_Base_one.addGestureRecognizer(doubleTap_Base_one)

        // 单击关闭 / 视频播放切换
        let singleTap_Base_one = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap_Base_one))
        singleTap_Base_one.numberOfTapsRequired = 1
        singleTap_Base_one.require(toFail: doubleTap_Base_one)
        scrollView_Base_one.addGestureRecognizer(singleTap_Base_one)

        // 视频区单击切换播放/暂停
        let videoTap_Base_one = UITapGestureRecognizer(target: self, action: #selector(handleVideoTap_Base_one))
        videoContainerView_Base_one.addGestureRecognizer(videoTap_Base_one)

        // 下滑关闭
        let pan_Base_one = UIPanGestureRecognizer(target: self, action: #selector(handlePan_Base_one(_:)))
        pan_Base_one.delegate = self
        view.addGestureRecognizer(pan_Base_one)

        // 播放/暂停按钮
        playPauseButton_Base_one.addTarget(self, action: #selector(togglePlayPause_Base_one), for: .touchUpInside)
        closeButton_Base_one.addTarget(self, action: #selector(closeTapped_Base_one), for: .touchUpInside)
    }

    // MARK: - 媒体加载

    /// 根据 mediaPath_Base_one 和 isVideo_Base_one 加载媒体
    private func loadMedia_Base_one() {
        guard let path_Base_one = mediaPath_Base_one, !path_Base_one.isEmpty else { showEmpty_Base_one(); return }
        loadingIndicator_Base_one.startAnimating()

        // 若外部明确为视频，或路径在 Bundle 中找到视频文件 → 进入视频流程
        if isVideo_Base_one, let url_Base_one = resolveVideoURL_Base_one(path_Base_one) {
            setupVideoPlayer_Base_one(url_Base_one: url_Base_one)
            return
        }
        // 自动检测：先查 Bundle 视频
        if let url_Base_one = resolveVideoURL_Base_one(path_Base_one) {
            setupVideoPlayer_Base_one(url_Base_one: url_Base_one)
            return
        }

        // 图片加载流程
        resolvedType_Base_one = .image_Base_one
        loadImage_Base_one(path_Base_one: path_Base_one)
    }

    /// 解析路径对应的视频 URL（Bundle / Documents / 网络）
    /// - Parameter path_Base_one: 媒体路径或名称
    /// - Returns: 找到时返回 URL，否则返回 nil
    private func resolveVideoURL_Base_one(_ path_Base_one: String) -> URL? {
        // Bundle 资源
        if let url_Base_one = MediaDisplayView_Base_one.bundleVideoURL_Base_one(named: path_Base_one) {
            return url_Base_one
        }
        // Documents 目录视频文件
        let docs_Base_one = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        for ext_Base_one in ["mp4", "mov", "m4v"] {
            let url_Base_one = docs_Base_one.appendingPathComponent("\(path_Base_one).\(ext_Base_one)")
            if FileManager.default.fileExists(atPath: url_Base_one.path) { return url_Base_one }
        }
        // 已带扩展名的文档目录文件
        let direct_Base_one = docs_Base_one.appendingPathComponent(path_Base_one)
        if FileManager.default.fileExists(atPath: direct_Base_one.path) { return direct_Base_one }
        // 网络视频 URL
        if (path_Base_one.hasPrefix("http://") || path_Base_one.hasPrefix("https://")),
           let url_Base_one = URL(string: path_Base_one) {
            let ext_Base_one = (path_Base_one as NSString).pathExtension.lowercased()
            if ["mp4", "mov", "m4v", "m3u8"].contains(ext_Base_one) { return url_Base_one }
        }
        return nil
    }

    /// 加载图片（与 MediaDisplayView_Base_one 策略对齐）
    /// - Parameter path_Base_one: 媒体路径
    private func loadImage_Base_one(path_Base_one: String) {
        // SF Symbols
        if let img_Base_one = UIImage(systemName: path_Base_one) { applyImage_Base_one(img_Base_one); return }
        // Assets
        if let img_Base_one = UIImage(named: path_Base_one) { applyImage_Base_one(img_Base_one); return }
        // 网络
        if path_Base_one.hasPrefix("http://") || path_Base_one.hasPrefix("https://") {
            guard let url_Base_one = URL(string: path_Base_one) else { showEmpty_Base_one(); return }
            imageView_Base_one.kf.setImage(with: url_Base_one, options: [.transition(.fade(0.3))]) { [weak self] result in
                self?.loadingIndicator_Base_one.stopAnimating()
                if case .success(let v_Base_one) = result { self?.onImageLoaded_Base_one(v_Base_one.image) }
                else { self?.showEmpty_Base_one() }
            }
            return
        }
        // Documents 文件名
        let docs_Base_one = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let docURL_Base_one = docs_Base_one.appendingPathComponent(path_Base_one)
        if let img_Base_one = UIImage(contentsOfFile: docURL_Base_one.path) { applyImage_Base_one(img_Base_one); return }
        // 完整路径
        if let img_Base_one = UIImage(contentsOfFile: path_Base_one) { applyImage_Base_one(img_Base_one); return }
        showEmpty_Base_one()
    }

    // MARK: - 视频播放器

    /// 初始化并启动 AVPlayer
    /// - Parameter url_Base_one: 视频文件 URL
    private func setupVideoPlayer_Base_one(url_Base_one: URL) {
        resolvedType_Base_one = .video_Base_one

        // 切换到视频容器
        scrollView_Base_one.isHidden         = true
        videoContainerView_Base_one.isHidden = false
        progressBg_Base_one.isHidden         = false

        mediaTypeLabel_Base_one.text = "Video"

        let player_Base_one  = AVPlayer(url: url_Base_one)
        self.player_Base_one = player_Base_one
        let layer_Base_one   = AVPlayerLayer(player: player_Base_one)
        layer_Base_one.videoGravity  = .resizeAspect
        layer_Base_one.frame         = videoContainerView_Base_one.bounds
        layer_Base_one.backgroundColor = UIColor.black.cgColor
        videoContainerView_Base_one.layer.insertSublayer(layer_Base_one, at: 0)
        playerLayer_Base_one = layer_Base_one

        // 视频就绪后淡入播放按钮
        player_Base_one.addObserver(self, forKeyPath: "status", options: [.new], context: nil)

        // 进度更新（每 0.1 秒）
        let interval_Base_one = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserverToken_Base_one = player_Base_one.addPeriodicTimeObserver(
            forInterval: interval_Base_one,
            queue: .main
        ) { [weak self] time_Base_one in
            self?.updateProgress_Base_one(currentTime_Base_one: time_Base_one)
        }

        // 播放完毕回到开头
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinish_Base_one),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player_Base_one.currentItem
        )

        loadingIndicator_Base_one.stopAnimating()
        player_Base_one.play()
        isPlaying_Base_one = true
        playPauseButton_Base_one.isSelected = true
        UIView.animate(withDuration: 0.3) { self.playPauseButton_Base_one.alpha = 1 }
    }

    /// 更新底部进度条
    /// - Parameter currentTime_Base_one: AVPlayer 当前时间
    private func updateProgress_Base_one(currentTime_Base_one: CMTime) {
        guard let duration_Base_one = player_Base_one?.currentItem?.duration,
              duration_Base_one.isNumeric, duration_Base_one.seconds > 0 else { return }
        let progress_Base_one = CGFloat(currentTime_Base_one.seconds / duration_Base_one.seconds)
        let totalW_Base_one   = progressBg_Base_one.bounds.width
        progressWidthCon_Base_one?.update(offset: totalW_Base_one * min(max(progress_Base_one, 0), 1))
    }

    /// 播放结束时回到开头并切换按钮状态
    @objc private func playerDidFinish_Base_one() {
        player_Base_one?.seek(to: .zero)
        isPlaying_Base_one = false
        playPauseButton_Base_one.isSelected = false
        progressWidthCon_Base_one?.update(offset: 0)
    }

    /// 清理 AVPlayer 资源（防止内存泄漏）
    private func cleanupPlayer_Base_one() {
        if let token_Base_one = timeObserverToken_Base_one {
            player_Base_one?.removeTimeObserver(token_Base_one)
            timeObserverToken_Base_one = nil
        }
        player_Base_one?.removeObserver(self, forKeyPath: "status")
        player_Base_one?.pause()
        player_Base_one = nil
        playerLayer_Base_one?.removeFromSuperlayer()
        playerLayer_Base_one = nil
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard keyPath == "status",
              let player_Base_one = object as? AVPlayer,
              player_Base_one.status == .failed else { return }
        DispatchQueue.main.async { self.showEmpty_Base_one() }
    }

    // MARK: - 图片辅助

    private func applyImage_Base_one(_ image_Base_one: UIImage) {
        loadingIndicator_Base_one.stopAnimating()
        imageView_Base_one.image = image_Base_one
        imageSize_Base_one       = image_Base_one.size
        mediaTypeLabel_Base_one.text = "Photo"
        updateImageLayout_Base_one()
    }

    private func onImageLoaded_Base_one(_ image_Base_one: UIImage) {
        imageSize_Base_one = image_Base_one.size
        mediaTypeLabel_Base_one.text = "Photo"
        updateImageLayout_Base_one()
    }

    private func showEmpty_Base_one() {
        loadingIndicator_Base_one.stopAnimating()
        imageView_Base_one.image       = UIImage(systemName: "photo.slash")
        imageView_Base_one.tintColor   = UIColor.white.withAlphaComponent(0.4)
        imageView_Base_one.contentMode = .center
    }

    private func updateImageLayout_Base_one() {
        guard imageSize_Base_one != .zero else {
            imageView_Base_one.frame = view.bounds
            scrollView_Base_one.contentSize = view.bounds.size
            return
        }
        let screenW_Base_one = view.bounds.width
        let screenH_Base_one = view.bounds.height
        let ratio_Base_one   = imageSize_Base_one.height / imageSize_Base_one.width
        let imgH_Base_one    = screenW_Base_one * ratio_Base_one
        let y_Base_one       = max(0, (screenH_Base_one - imgH_Base_one) / 2)
        imageView_Base_one.frame        = CGRect(x: 0, y: y_Base_one, width: screenW_Base_one, height: imgH_Base_one)
        scrollView_Base_one.contentSize = CGSize(width: screenW_Base_one,
                                              height: max(imgH_Base_one + y_Base_one * 2, screenH_Base_one))
        scrollView_Base_one.zoomScale   = 1.0
        centerImageIfNeeded_Base_one()
    }

    private func centerImageIfNeeded_Base_one() {
        let offX_Base_one = max(0, (scrollView_Base_one.bounds.width  - scrollView_Base_one.contentSize.width)  / 2)
        let offY_Base_one = max(0, (scrollView_Base_one.bounds.height - scrollView_Base_one.contentSize.height) / 2)
        imageView_Base_one.center = CGPoint(
            x: scrollView_Base_one.contentSize.width  / 2 + offX_Base_one,
            y: scrollView_Base_one.contentSize.height / 2 + offY_Base_one
        )
    }

    // MARK: - 手势响应

    @objc private func handleDoubleTap_Base_one(_ gesture_Base_one: UITapGestureRecognizer) {
        guard resolvedType_Base_one == .image_Base_one else { return }
        if scrollView_Base_one.zoomScale > 1.0 {
            scrollView_Base_one.setZoomScale(1.0, animated: true)
        } else {
            let pt_Base_one    = gesture_Base_one.location(in: imageView_Base_one)
            let rect_Base_one  = zoomRect_Base_one(scale_Base_one: 2.5, center_Base_one: pt_Base_one)
            scrollView_Base_one.zoom(to: rect_Base_one, animated: true)
        }
    }

    @objc private func handleSingleTap_Base_one() {
        guard resolvedType_Base_one != .video_Base_one,
              scrollView_Base_one.zoomScale <= 1.01 else { return }
        dismissPage_Base_one(velocity_Base_one: 0)
    }

    /// 视频区点击：切换播放/暂停
    @objc private func handleVideoTap_Base_one() {
        togglePlayPause_Base_one()
    }

    /// 播放/暂停切换
    @objc private func togglePlayPause_Base_one() {
        guard let player_Base_one = player_Base_one else { return }
        if isPlaying_Base_one {
            player_Base_one.pause()
            isPlaying_Base_one = false
            playPauseButton_Base_one.isSelected = false
        } else {
            player_Base_one.play()
            isPlaying_Base_one = true
            playPauseButton_Base_one.isSelected = true
        }
        // 短暂显示后淡出按钮
        UIView.animate(withDuration: 0.2) { self.playPauseButton_Base_one.alpha = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            guard self.isPlaying_Base_one else { return }
            UIView.animate(withDuration: 0.4) { self.playPauseButton_Base_one.alpha = 0.2 }
        }
    }

    @objc private func closeTapped_Base_one() {
        dismissPage_Base_one(velocity_Base_one: 0)
    }

    @objc private func handlePan_Base_one(_ gesture_Base_one: UIPanGestureRecognizer) {
        guard scrollView_Base_one.zoomScale <= 1.01 else { return }
        let translation_Base_one = gesture_Base_one.translation(in: view)
        let velocity_Base_one    = gesture_Base_one.velocity(in: view).y
        switch gesture_Base_one.state {
        case .changed:
            let progress_Base_one         = max(0, translation_Base_one.y / view.bounds.height)
            backgroundView_Base_one.alpha = max(0, 1 - progress_Base_one * 1.5)
            topBar_Base_one.alpha         = max(0, 1 - progress_Base_one * 2)
            bottomHint_Base_one.alpha     = max(0, 1 - progress_Base_one * 2)
            let activeView_Base_one: UIView = resolvedType_Base_one == .video_Base_one
                ? videoContainerView_Base_one : scrollView_Base_one
            activeView_Base_one.transform = CGAffineTransform(
                translationX: translation_Base_one.x * 0.3,
                y: max(0, translation_Base_one.y)
            )
        case .ended, .cancelled:
            let shouldDismiss_Base_one = translation_Base_one.y > view.bounds.height * 0.25 || velocity_Base_one > 900
            if shouldDismiss_Base_one {
                dismissPage_Base_one(velocity_Base_one: velocity_Base_one)
            } else {
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               usingSpringWithDamping: 0.85,
                               initialSpringVelocity: 0.5) {
                    self.scrollView_Base_one.transform         = .identity
                    self.videoContainerView_Base_one.transform = .identity
                    self.backgroundView_Base_one.alpha  = 1
                    self.topBar_Base_one.alpha           = 1
                    self.bottomHint_Base_one.alpha       = 1
                }
            }
        default: break
        }
    }

    // MARK: - 关闭页面

    /// 执行关闭动画并 dismiss（暂停视频）
    /// - Parameter velocity_Base_one: 下拉速度（影响动画时长）
    private func dismissPage_Base_one(velocity_Base_one: CGFloat) {
        guard !isDismissing_Base_one else { return }
        isDismissing_Base_one = true
        player_Base_one?.pause()
        let duration_Base_one = velocity_Base_one > 1200 ? 0.2 : 0.3
        UIView.animate(withDuration: duration_Base_one, animations: {
            self.view.alpha = 0
            let activeView_Base_one: UIView = self.resolvedType_Base_one == .video_Base_one
                ? self.videoContainerView_Base_one : self.scrollView_Base_one
            activeView_Base_one.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        }) { _ in
            self.dismiss(animated: false)
        }
    }

    // MARK: - 工具

    private func zoomRect_Base_one(scale_Base_one: CGFloat, center_Base_one: CGPoint) -> CGRect {
        let w_Base_one = scrollView_Base_one.bounds.width  / scale_Base_one
        let h_Base_one = scrollView_Base_one.bounds.height / scale_Base_one
        return CGRect(x: center_Base_one.x - w_Base_one / 2,
                      y: center_Base_one.y - h_Base_one / 2,
                      width: w_Base_one, height: h_Base_one)
    }
}

// MARK: - UIScrollViewDelegate（图片缩放）

extension MediaPlayerPage_Base_one: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView_Base_one }
    func scrollViewDidZoom(_ scrollView: UIScrollView) { centerImageIfNeeded_Base_one() }
}

// MARK: - UIGestureRecognizerDelegate（下拉与缩放共存）

extension MediaPlayerPage_Base_one: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan_Base_one = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        guard scrollView_Base_one.zoomScale <= 1.01 else { return false }
        let vel_Base_one = pan_Base_one.velocity(in: view)
        return abs(vel_Base_one.y) > abs(vel_Base_one.x) && vel_Base_one.y > 0
    }
}
