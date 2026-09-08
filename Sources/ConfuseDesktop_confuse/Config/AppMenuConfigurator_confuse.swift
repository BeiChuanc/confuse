import AppKit

/// 接收应用生命周期事件，并在窗口创建后安装中文原生菜单。
final class AppDelegate_confuse: NSObject, NSApplicationDelegate {
    /// 在应用完成启动后配置中文菜单栏。
    /// - Parameter notification_confuse: 系统发送的应用启动完成通知。
    func applicationDidFinishLaunching(_ notification_confuse: Notification) {
        DispatchQueue.main.async {
            AppMenuConfigurator_confuse.configure_confuse()
        }
    }
}

/// 集中创建应用的中文原生菜单，保留常用系统命令及其标准快捷键。
enum AppMenuConfigurator_confuse {
    /// 创建并安装完整的中文菜单栏。
    static func configure_confuse() {
        let mainMenu_confuse = NSMenu()
        mainMenu_confuse.addItem(applicationMenu_confuse())
        mainMenu_confuse.addItem(fileMenu_confuse())
        mainMenu_confuse.addItem(editMenu_confuse())
        mainMenu_confuse.addItem(viewMenu_confuse())
        mainMenu_confuse.addItem(windowMenu_confuse())
        mainMenu_confuse.addItem(helpMenu_confuse())
        NSApp.mainMenu = mainMenu_confuse
    }

    /// 返回应用操作菜单。
    /// - Returns: 包含关于、隐藏和退出操作的菜单项。
    private static func applicationMenu_confuse() -> NSMenuItem {
        let rootItem_confuse = NSMenuItem(title: "应用工具", action: nil, keyEquivalent: "")
        let submenu_confuse = NSMenu(title: "应用工具")
        submenu_confuse.addItem(menuItem_confuse(
            title_confuse: "关于应用工具",
            action_confuse: #selector(NSApplication.orderFrontStandardAboutPanel(_:))
        ))
        submenu_confuse.addItem(.separator())
        submenu_confuse.addItem(menuItem_confuse(
            title_confuse: "隐藏应用工具",
            action_confuse: #selector(NSApplication.hide(_:)),
            keyEquivalent_confuse: "h"
        ))
        let hideOthersItem_confuse = menuItem_confuse(
            title_confuse: "隐藏其他应用",
            action_confuse: #selector(NSApplication.hideOtherApplications(_:)),
            keyEquivalent_confuse: "h"
        )
        hideOthersItem_confuse.keyEquivalentModifierMask = [.command, .option]
        submenu_confuse.addItem(hideOthersItem_confuse)
        submenu_confuse.addItem(menuItem_confuse(
            title_confuse: "全部显示",
            action_confuse: #selector(NSApplication.unhideAllApplications(_:))
        ))
        submenu_confuse.addItem(.separator())
        submenu_confuse.addItem(menuItem_confuse(
            title_confuse: "退出应用工具",
            action_confuse: #selector(NSApplication.terminate(_:)),
            keyEquivalent_confuse: "q"
        ))
        rootItem_confuse.submenu = submenu_confuse
        return rootItem_confuse
    }

    /// 返回文件菜单。
    /// - Returns: 包含关闭窗口操作的菜单项。
    private static func fileMenu_confuse() -> NSMenuItem {
        let rootItem_confuse = NSMenuItem(title: "文件", action: nil, keyEquivalent: "")
        let submenu_confuse = NSMenu(title: "文件")
        submenu_confuse.addItem(menuItem_confuse(
            title_confuse: "关闭窗口",
            action_confuse: #selector(NSWindow.performClose(_:)),
            keyEquivalent_confuse: "w"
        ))
        rootItem_confuse.submenu = submenu_confuse
        return rootItem_confuse
    }

    /// 返回编辑菜单。
    /// - Returns: 包含撤销、剪切、复制、粘贴和全选操作的菜单项。
    private static func editMenu_confuse() -> NSMenuItem {
        let rootItem_confuse = NSMenuItem(title: "编辑", action: nil, keyEquivalent: "")
        let submenu_confuse = NSMenu(title: "编辑")
        submenu_confuse.addItem(menuItem_confuse(
            title_confuse: "撤销",
            action_confuse: Selector(("undo:")),
            keyEquivalent_confuse: "z"
        ))
        let redoItem_confuse = menuItem_confuse(
            title_confuse: "重做",
            action_confuse: Selector(("redo:")),
            keyEquivalent_confuse: "z"
        )
        redoItem_confuse.keyEquivalentModifierMask = [.command, .shift]
        submenu_confuse.addItem(redoItem_confuse)
        submenu_confuse.addItem(.separator())
        submenu_confuse.addItem(menuItem_confuse(
            title_confuse: "剪切",
            action_confuse: #selector(NSText.cut(_:)),
            keyEquivalent_confuse: "x"
        ))
        submenu_confuse.addItem(menuItem_confuse(
            title_confuse: "复制",
            action_confuse: #selector(NSText.copy(_:)),
            keyEquivalent_confuse: "c"
        ))
        submenu_confuse.addItem(menuItem_confuse(
            title_confuse: "粘贴",
            action_confuse: #selector(NSText.paste(_:)),
            keyEquivalent_confuse: "v"
        ))
        submenu_confuse.addItem(menuItem_confuse(
            title_confuse: "全选",
            action_confuse: #selector(NSText.selectAll(_:)),
            keyEquivalent_confuse: "a"
        ))
        rootItem_confuse.submenu = submenu_confuse
        return rootItem_confuse
    }

    /// 返回显示菜单。
    /// - Returns: 包含全屏切换操作的菜单项。
    private static func viewMenu_confuse() -> NSMenuItem {
        let rootItem_confuse = NSMenuItem(title: "显示", action: nil, keyEquivalent: "")
        let submenu_confuse = NSMenu(title: "显示")
        let fullScreenItem_confuse = menuItem_confuse(
            title_confuse: "进入全屏",
            action_confuse: #selector(NSWindow.toggleFullScreen(_:)),
            keyEquivalent_confuse: "f"
        )
        fullScreenItem_confuse.keyEquivalentModifierMask = [.command, .control]
        submenu_confuse.addItem(fullScreenItem_confuse)
        rootItem_confuse.submenu = submenu_confuse
        return rootItem_confuse
    }

    /// 返回窗口菜单。
    /// - Returns: 包含最小化、缩放和窗口前置操作的菜单项。
    private static func windowMenu_confuse() -> NSMenuItem {
        let rootItem_confuse = NSMenuItem(title: "窗口", action: nil, keyEquivalent: "")
        let submenu_confuse = NSMenu(title: "窗口")
        submenu_confuse.addItem(menuItem_confuse(
            title_confuse: "最小化",
            action_confuse: #selector(NSWindow.miniaturize(_:)),
            keyEquivalent_confuse: "m"
        ))
        submenu_confuse.addItem(menuItem_confuse(
            title_confuse: "缩放",
            action_confuse: #selector(NSWindow.performZoom(_:))
        ))
        submenu_confuse.addItem(.separator())
        submenu_confuse.addItem(menuItem_confuse(
            title_confuse: "前置全部窗口",
            action_confuse: #selector(NSApplication.arrangeInFront(_:))
        ))
        rootItem_confuse.submenu = submenu_confuse
        return rootItem_confuse
    }

    /// 返回帮助菜单。
    /// - Returns: 包含中文帮助入口的菜单项。
    private static func helpMenu_confuse() -> NSMenuItem {
        let rootItem_confuse = NSMenuItem(title: "帮助", action: nil, keyEquivalent: "")
        let submenu_confuse = NSMenu(title: "帮助")
        let helpItem_confuse = NSMenuItem(title: "应用工具帮助", action: nil, keyEquivalent: "")
        helpItem_confuse.isEnabled = false
        submenu_confuse.addItem(helpItem_confuse)
        rootItem_confuse.submenu = submenu_confuse
        return rootItem_confuse
    }

    /// 创建使用响应链执行的标准菜单项。
    /// - Parameters:
    ///   - title_confuse: 菜单显示标题。
    ///   - action_confuse: 系统响应链选择器。
    ///   - keyEquivalent_confuse: 键盘快捷键字符。
    /// - Returns: 已配置的原生菜单项。
    private static func menuItem_confuse(
        title_confuse: String,
        action_confuse: Selector?,
        keyEquivalent_confuse: String = ""
    ) -> NSMenuItem {
        NSMenuItem(
            title: title_confuse,
            action: action_confuse,
            keyEquivalent: keyEquivalent_confuse
        )
    }
}
