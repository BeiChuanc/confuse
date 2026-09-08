import SwiftUI

/// 应用入口，创建混淆机主窗口并设置默认尺寸。
@main
struct ConfuseApp_confuse: App {
    @NSApplicationDelegateAdaptor(AppDelegate_confuse.self) private var appDelegate_confuse

    /// 返回应用场景。
    var body: some Scene {
        WindowGroup {
            ContentView_confuse()
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 980, height: 760)
    }
}
