import UIKit
import PhotosUI
import AVFoundation
import UniformTypeIdentifiers

// MARK: 媒体选择工具类

/// 媒体选择工具类
/// 功能：封装 PHPicker，支持图片、视频及混合选择
/// 设计：单例 + 代理回调，视频自动复制到临时目录
class MediaPickerHelper_Base_one: NSObject {

    // MARK: - 枚举

    /// 媒体类型
    enum MediaType_Base_one {
        case photo_Base_one
        case video_Base_one
        case photoAndVideo_Base_one

        /// 对应的 PHPicker 过滤器
        var pickerFilter_Base_one: PHPickerFilter {
            switch self {
            case .photo_Base_one:         return .images
            case .video_Base_one:         return .videos
            case .photoAndVideo_Base_one: return .any(of: [.images, .videos])
            }
        }
    }

    /// 选择结果
    enum PickerResult_Base_one {
        case photo_Base_one(image_Base_one: UIImage)
        case video_Base_one(url_Base_one: URL)
        case cancelled_Base_one
    }

    // MARK: - 属性

    static let shared_Base_one = MediaPickerHelper_Base_one()

    /// 临时视频文件前缀
    private static let tempVideoPrefix_Base_one = "picked_video_"

    private var completion_Base_one: ((PickerResult_Base_one) -> Void)?

    // MARK: - 公开方法

    /// 显示媒体选择器
    /// 参数：
    /// - viewController_Base_one: 发起选择的视图控制器
    /// - mediaType_Base_one: 允许的媒体类型，默认仅图片
    /// - selectionLimit_Base_one: 最大选择数量，默认 1
    /// - completion_Base_one: 选择完成回调
    func showPicker_Base_one(
        from viewController_Base_one: UIViewController,
        mediaType_Base_one: MediaType_Base_one = .photo_Base_one,
        selectionLimit_Base_one: Int = 1,
        completion_Base_one: @escaping (PickerResult_Base_one) -> Void
    ) {
        self.completion_Base_one = completion_Base_one

        var config_Base_one = PHPickerConfiguration()
        config_Base_one.selectionLimit = selectionLimit_Base_one
        config_Base_one.filter = mediaType_Base_one.pickerFilter_Base_one

        let picker_Base_one = PHPickerViewController(configuration: config_Base_one)
        picker_Base_one.delegate = self
        viewController_Base_one.present(picker_Base_one, animated: true)
    }

    /// 快捷方法：选择单张图片
    static func pickImage_Base_one(from viewController_Base_one: UIViewController, completion_Base_one: @escaping (UIImage?) -> Void) {
        shared_Base_one.showPicker_Base_one(from: viewController_Base_one, mediaType_Base_one: .photo_Base_one) { result in
            if case .photo_Base_one(let image) = result { completion_Base_one(image) } else { completion_Base_one(nil) }
        }
    }

    /// 快捷方法：选择单个视频
    static func pickVideo_Base_one(from viewController_Base_one: UIViewController, completion_Base_one: @escaping (URL?) -> Void) {
        shared_Base_one.showPicker_Base_one(from: viewController_Base_one, mediaType_Base_one: .video_Base_one) { result in
            if case .video_Base_one(let url) = result { completion_Base_one(url) } else { completion_Base_one(nil) }
        }
    }

    /// 快捷方法：选择图片或视频
    static func pickMedia_Base_one(
        from viewController_Base_one: UIViewController,
        completion_Base_one: @escaping (PickerResult_Base_one) -> Void
    ) {
        shared_Base_one.showPicker_Base_one(
            from: viewController_Base_one,
            mediaType_Base_one: .photoAndVideo_Base_one,
            completion_Base_one: completion_Base_one
        )
    }

    // MARK: - 私有方法

    /// 在主线程回调结果
    private func callCompletion_Base_one(_ result_Base_one: PickerResult_Base_one) {
        DispatchQueue.main.async { [weak self] in
            self?.completion_Base_one?(result_Base_one)
        }
    }

    /// 处理选中的图片
    private func handleImageSelection_Base_one(itemProvider_Base_one: NSItemProvider) {
        itemProvider_Base_one.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            guard let self else { return }
            if let error {
                print("❌ 加载图片失败: \(error)")
                return callCompletion_Base_one(.cancelled_Base_one)
            }
            guard let image = object as? UIImage else {
                return callCompletion_Base_one(.cancelled_Base_one)
            }
            callCompletion_Base_one(.photo_Base_one(image_Base_one: image))
        }
    }

    /// 处理选中的视频
    private func handleVideoSelection_Base_one(itemProvider_Base_one: NSItemProvider) {
        itemProvider_Base_one.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url, error in
            guard let self else { return }
            if let error {
                print("❌ 加载视频失败: \(error)")
                return callCompletion_Base_one(.cancelled_Base_one)
            }
            guard let url else {
                print("❌ 视频URL为空")
                return callCompletion_Base_one(.cancelled_Base_one)
            }
            copyVideoToTemp_Base_one(sourceURL_Base_one: url)
        }
    }

    /// 复制视频到临时目录（避免系统清理原始文件）
    /// 参数：
    /// - sourceURL_Base_one: 原始视频 URL
    private func copyVideoToTemp_Base_one(sourceURL_Base_one: URL) {
        let tempURL_Base_one = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(Self.tempVideoPrefix_Base_one)\(Date().timeIntervalSince1970)")
            .appendingPathExtension(sourceURL_Base_one.pathExtension)

        do {
            if FileManager.default.fileExists(atPath: tempURL_Base_one.path) {
                try FileManager.default.removeItem(at: tempURL_Base_one)
            }
            try FileManager.default.copyItem(at: sourceURL_Base_one, to: tempURL_Base_one)
            print("✅ 视频已复制到临时目录: \(tempURL_Base_one.path)")
            callCompletion_Base_one(.video_Base_one(url_Base_one: tempURL_Base_one))
        } catch {
            print("❌ 复制视频失败: \(error)")
            callCompletion_Base_one(.cancelled_Base_one)
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

extension MediaPickerHelper_Base_one: PHPickerViewControllerDelegate {

    /// 用户完成选择（选中或取消）
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let itemProvider_Base_one = results.first?.itemProvider else {
            print("⚠️ 用户取消选择")
            callCompletion_Base_one(.cancelled_Base_one)
            return
        }

        if itemProvider_Base_one.canLoadObject(ofClass: UIImage.self) {
            handleImageSelection_Base_one(itemProvider_Base_one: itemProvider_Base_one)
        } else if itemProvider_Base_one.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            handleVideoSelection_Base_one(itemProvider_Base_one: itemProvider_Base_one)
        } else {
            print("⚠️ 不支持的媒体类型")
            callCompletion_Base_one(.cancelled_Base_one)
        }
    }
}
