# 应用工具

应用工具是一款使用 SwiftUI 开发的 macOS 桌面程序，集成项目初始化、Swift/Flutter 项目混淆、映射回归、增量混淆以及 App Store Connect 审核状态监控。应用界面、操作提示和状态信息均使用中文展示。

## 当前功能状态

| 一级菜单 | 二级菜单 | 当前状态 |
| --- | --- | --- |
| 初始化项目 | Swift、Flutter | Swift 已实现；Flutter 暂未支持 |
| 混淆程序 | 混淆项目、混淆回归、增量混淆 | 已实现 |
| 提交自动化 | 提交云端构建、整理资料、合包整理、填写后台 | 整理资料及协议处理、Swift 合包已实现；其他功能暂未接入 |
| 监控审核 | 审核状态、审核记录 | 已实现 |
| 设置 | 无 | 仅完成页面导航，暂未接入全局设置 |

左侧一级菜单支持展开和收起，页面切换带过渡动画。

## 环境要求

- macOS 13 或更高版本。
- Xcode Command Line Tools 或完整 Xcode。
- Swift 5.9 或更高版本。
- 系统可用的 Python 3，用于项目初始化和混淆脚本。
- Google Chrome，用于通过 App Tools 浏览器助手执行协议处理、资料整理和合包后台配置读取。
- 使用审核监控时，需要有效的 App Store Connect API 凭证和网络访问权限。

可通过以下命令确认基础环境：

```bash
swift --version
python3 --version
```

## 打包应用

在仓库根目录执行：

```bash
./build_confuse.command
```

构建脚本会执行 Release 编译、资源复制、应用图标配置、本地临时签名，并创建运行所需的数据目录：

```text
dist/
├── Confuse.app
├── JSON/
├── PROFILE/
├── PACKAGE/
└── AppMonitorData/
    ├── backups/
    ├── keys/
    └── logs/
```

`JSON` 保存混淆映射，`PROFILE` 保存整理资料生成的项目 profile 文本，`PACKAGE` 保存合包代码，`AppMonitorData` 保存监控配置、私钥副本、审核记录和配置备份。应用始终从 `Confuse.app` 同级目录读取这些数据，因此移动应用时应同时移动整个 `dist` 目录结构。

应用首次访问桌面上的同级数据目录时，macOS 可能显示文件访问授权弹窗。拒绝授权后，映射文件和监控数据将无法正常读取或写入。

公开分发时，需要使用 Apple Developer ID 对应用正式签名并完成公证。打包脚本当前使用本地临时签名，适合本机开发和验证。

## 初始化项目

初始化页面提供 Swift 和 Flutter 类型入口，当前仅支持创建 Swift 项目。

### 创建步骤

1. 打开“初始化项目”。
2. 选择“Swift”。
3. 输入项目名称。名称必须以英文字母开头，只能包含英文字母、数字和下划线。
4. 点击“选择目录”，指定新项目所在的父目录。
5. 点击“创建项目”，通过进度条查看七个初始化步骤。
6. 创建完成后点击“打开工程”。

目标目录中已存在同名文件夹时，应用会停止创建并显示提示，不会覆盖已有项目。

### 自动处理内容

创建过程使用应用内置的 `base_one` 模板，并自动完成以下操作：

- 创建以输入名称命名的源码目录、Xcode 工程和 Target。
- 生成 `com.ornaments.<项目名小写>` 格式的 Bundle Identifier，下划线会转换为连字符。
- 将所有 iOS Deployment Target 统一设置为 16.0。
- 将 Version 设置为 1.0.0，Build 保持为 1。
- 仅保留 iPhone 目标，关闭 iPad、Mac Designed for iPad 和 Apple Vision 支持。
- 移除 iPad 屏幕方向配置、场景清单、默认场景代理和默认控制器。
- 写入定位、相册、相册保存、相机、麦克风权限说明，以及允许任意网络加载的 ATS 配置。
- 将权限说明中的 `AppName` 替换为用户输入的项目名称。
- 复制 `Data`、`Extension`、`Model`、`Pages`、`Route`、`Utils`、`ViewModel`、`Views` 和 `AppDelegate.swift`。
- 在 `Assets.xcassets` 中创建 `Data`、`User`、`Pro`、`Store`、`App` 五个资源文件夹。
- 将 `rename_auto.py` 临时复制到项目根目录，执行源码标识符和文件名重命名，完成后自动删除脚本。

模板包含使用 CocoaPods 的业务代码和 `Podfile`。初始化功能不会自动联网安装依赖，需要依赖时请在新项目根目录自行执行 `pod install`，之后使用生成的 `.xcworkspace`。

## 混淆程序

混淆程序支持选择项目目录，也支持将项目文件夹拖入窗口。应用会自动识别 Swift 或 Flutter 项目并读取项目后缀，也可以手动输入一个或多个后缀。

### 混淆项目

- 混淆 Swift、Dart 源文件名称及符合项目后缀的代码标识符。
- 混淆 Flutter `assets` 资源和代码引用。
- 混淆 Swift `.xcassets` 资源集以及 `.mp4`、`.mov`、`.m4v` 媒体资源。
- 更新工程内相关引用并生成可逆映射 JSON。

### 混淆回归

根据映射 JSON 反向恢复文件名、代码标识符、资源名和相关引用。映射不存在时，应用会显示“未找到映射 JSON”提示并停止处理，不会修改项目。

### 增量混淆

适用于已经混淆的项目新增代码或资源后的再次处理。应用保留已有映射，只为映射中不存在的内容生成新名称，并将新增映射写回原 JSON。

增量混淆要求工程当前处于混淆状态。已经执行混淆回归的工程需要先重新执行混淆项目。

### 使用步骤

1. 展开“混淆程序”，选择需要的二级模式。
2. 点击“选择文件夹”，或将项目文件夹拖入项目区域。
3. 检查自动识别的项目类型和项目后缀，必要时手动调整后缀。
4. 选择命名规则。
5. 检查页面展示的映射 JSON 路径。
6. 点击“执行操作”，等待状态显示完成。

混淆操作会直接修改所选项目。正式处理前应通过 Git 提交当前代码，或保留完整项目备份。

## 命名规则

文件、代码标识符和资源统一使用当前选择的命名规则：

| 规则 | 格式 | 示例 |
| --- | --- | --- |
| 经典 | 项目名 + 3 位数字 + 2 位小写字母 | `Wanderbell123ab` |
| 增强 | 项目名 + 8 位小写字母和数字 | `Wanderbella8k2m5q9` |
| 匿名 | 字母开头的 12 位随机字母和数字，不包含项目名 | `k8m2q5n7x4pz` |

生成名称会进行全局防重，所选规则会写入映射 JSON 的 `metadata.naming_rule` 字段。

## 映射 JSON

映射不会写入被处理的项目，统一保存在 `Confuse.app` 同级的 `JSON` 文件夹中。文件名格式为：

```text
项目后缀_项目类型.json
```

例如：

```text
JSON/wanderbell_swift.json
JSON/wanderbell_flutter.json
```

混淆项目、混淆回归和增量混淆都会根据项目后缀及项目类型计算映射文件名。需要读取映射时，应用只在同级 `JSON` 目录中精确查找。

不同项目如果使用相同后缀和项目类型，会对应同一个映射文件。应为不同项目设置不同后缀，避免映射相互覆盖。

Swift 项目会兼容后缀的原始写法、全小写写法和首字母大写写法，减少文件名与代码标识符大小写不一致导致的遗漏。

## 合包整理

“提交自动化”下的“合包整理”支持选择 Swift 或 Flutter，再选择 Video 2.0、Social 2.0 或 Social 4.0。应用会自动扫描 `Confuse.app` 同级 `PACKAGE` 文件夹中同时匹配语言和类型的代码文件，并支持选择或拖入合包目标项目。当前已实现 Swift 合包，Flutter 保留选择入口。

打包脚本会预建以下目录，后续可将对应合包代码放入其中：

```text
PACKAGE/
├── Swift/
│   ├── Video 2.0/
│   ├── Social 2.0/
│   └── Social 4.0/
└── Flutter/
    ├── Video 2.0/
    ├── Social 2.0/
    └── Social 4.0/
```

每个 Swift 合包类型目录需要提供 `Podfile`、`AppDelegate.swift`、`BendoBaseDefaultViewController.swift`、`BendoBaseShare.swift` 和 `BendoExtension.swift`。页面只展示这五个实际参与合包的文件，不展示模板工程中的其他文件。开始合包后应用会：

1. 从合包 Podfile 中读取 SVProgressHUD、FBSDKLoginKit、FirebaseCore、FirebaseAnalytics、MBProgressHUD，并把目标项目缺少的依赖加入 Podfile。
2. 在目标 AppDelegate.swift 同级创建 `Mix`，复制三个 Bendo Swift 文件；对于 Xcode 16 的同步文件夹工程会自动加入目标，对于旧式工程会写入文件引用和 Sources 编译阶段。
3. 自动识别目标工程中继承 `UITabBarController` 的底部导航控制器，以及 `LaunchScreen.storyboard` 引用的开屏图片资源。
4. 删除目标 AppDelegate 中原有的窗口初始化代码，合并合包 AppDelegate 的 import、启动代码、委托协议和扩展方法，并写入 AppsFlyer 开发者密钥、Apple App ID、底部导航入口、配置域名、请求域名和开屏图片。重复执行会替换上一次受管代码，不会重复累加。
5. 将后台读取的 Facebook App ID、Client Token 和 Display Name 写入 Info.plist，同时更新广告归因地址、内购历史开关和 `fb+FacebookAppID` URL Scheme。后台标签无 FB 时，三项 Facebook 配置按 `0` 处理。
6. Video 2.0 合包会移除目标 Info.plist 中的定位用途说明。

执行 Swift 合包前，先选择或拖入目标项目。应用会从 Xcode 工程读取 Bundle ID，然后在“获取后台配置”区域输入苹果马甲包后台账号、密码和当前 2FA。点击“获取后台配置”后，浏览器助手会复用当前 Google Chrome，登录 [苹果马甲包后台](https://admin.joyhappier.com/login)，进入“苹果马甲包”并按目标 Bundle ID 精确查找项目。

后台读取结果会在页面展示 AppsFlyerDevKey、AppsFlyerAppId、配置域名、网页域名、FacebookAppID、FacebookClientToken 和 FacebookDisplayName。配置域名来自后台“域名配置”，其余项目来自“配置”；网页域名在合包代码中作为请求域名。后台配置必须与当前目标 Bundle ID 一致，目标项目改变后需要重新获取。密码和 2FA 只用于当前任务，读取结束后会立即从页面清空，不会保存到应用目录或配置文件。

首次使用或应用更新后，点击“更新浏览器助手”，在打开的 `chrome://extensions` 页面重新加载扩展。扩展版本需要为 1.3.0 或更高版本，否则无法执行后台配置读取。

流程修改失败时会恢复本次操作涉及的 Podfile、AppDelegate、Info.plist、project.pbxproj 和 Mix 文件。完成后需要在目标项目根目录执行 `pod install` 再编译工程。

## 整理资料与协议处理

“提交自动化”下的“整理资料”会通过 App Tools 浏览器助手在当前已登录的 Google Chrome 中根据 UI 编号读取唯一项目记录，并在同一页面提供协议生成入口。协议包含以下三类公开链接：

- 隐私政策。
- 使用条款。
- 最终用户许可协议。

使用时输入完整 UI 编号即可整理资料。资料读取完成后，应用会从“软件名”填充应用名称，从“开发者账号”字段提取邮箱，等待用户确认后再按“隐私政策 → 使用条款 → 最终用户许可协议”的顺序生成全部协议。未执行资料整理时，也可以直接在协议区域填写应用名称和邮箱，单独生成某一项协议或一键生成全部协议。生成成功后可以复制链接或使用默认浏览器打开链接；资料整理完成后确认生成全部协议时，会同时写入项目 Profile。资料和协议共用一个流程进度条，任务执行期间可以点击“停止”结束当前流程。

协议自动化不会启动独立 Chrome。任务开始后，浏览器助手会在当前聚焦的 Chrome 窗口新建一个普通标签页，并在该标签页中依次生成所选协议。它会复用当前 Chrome 配置、Cookie 和登录状态，不关闭或修改用户原有标签页；任务结束后保留最后一个协议页面供检查。

应用会按照固定规则填写生成器：应用类型选择 App，实体类型选择个人，国家选择美国、地区选择纽约州，语言选择英文。隐私政策仅选择邮箱地址和相机图片信息，其余跟踪、邮件、广告、支付、再营销及合规项目选择否；使用条款和最终用户许可协议中的可选业务能力按预设选择否。

扩展会同时服务于飞书资料读取和协议生成。首次使用按以下步骤准备扩展：

1. 在“整理资料”页面点击“准备扩展”。应用会安装受限的本机通信服务，并同时打开扩展目录和 `chrome://extensions`。
2. 在 Chrome 扩展管理页开启“开发者模式”。
3. 点击“加载已解压的扩展程序”，依次进入“文稿 → AppTools”，选择 `ChromeExtension_confuse` 文件夹。
4. 扩展名称显示为“App Tools 浏览器助手”。安装后进入“整理资料”即可执行完整流程。

应用更新后再次点击“更新扩展”，再在 Chrome 扩展管理页点击该扩展的重新加载按钮。若公司策略禁止加载本地扩展，Chrome 会在扩展管理页直接提示，当前方案将无法使用。

读取成功后，页面会展示 UI 编号、开发者账号、软件名、Bundle ID、App ID、商店审核账号密码、手机号、银行卡和路由 ABA。全部字段直接显示且可以单独复制；未填写的飞书字段显示为“未填写”。资料展示完成后，协议区域会显示“生成协议并生成 Profile”按钮，确认后生成的链接显示在同一页面，并在 `PROFILE` 文件夹生成 `项目名_profile.txt`。Profile 按模板填写可取得的协议链接、App ID、手机号、邮箱、测试账号和测试密码等字段；无法取得的字段保持为空。软件名为空或开发者账号中没有有效邮箱时，资料仍会保留，用户可以手动补充协议参数后再生成。

扩展仅声明原生消息、标签页、调试接口和指定飞书及协议生成器域名权限。资料值通过当前用户专属的本机 Unix 套接字传回应用，仅在当前进程内显示，不会写入应用目录、JSON 映射或日志。任务执行期间可以停止；扩展未连接、项目不存在、查找结果不唯一、登录超时、飞书页面结构变化、协议页面结构变化或第三方服务不可用时，应用会显示具体错误并停止当前阶段。

## 监控审核

监控审核通过 App Store Connect API 查询应用名称、目标版本和审核状态，并提供“审核状态”和“审核记录”两个页面。

### 添加监控应用

可以手动填写以下内容：

- App Store Connect 数字应用编号。
- Issuer ID。
- Key ID。
- 对应的 `.p8` 私钥文件。

也可以选择或拖入资料文件夹，应用会递归读取 `txt`、`json`、`plist`、`mobileprovision`、`provisionprofile` 文件，并匹配对应的 `.p8` 私钥。资料不完整、存在多份完整配置或私钥匹配不明确时，应用会停止导入并显示具体原因。

### 状态监控

- 支持立即检查全部已启用应用。
- 支持单独检查、编辑、启用、停用和移除应用。
- 支持按应用名称搜索和按审核状态筛选。
- 展示全部应用、审核流程、已通过和已拒绝数量。
- 支持分别设置普通状态、审核中和已过审状态的巡检间隔。
- 支持 HTTP、HTTPS 和 SOCKS5 代理地址，并可启用严格代理模式。
- 状态发生变化时可发送 macOS 本地通知、PushPlus 消息和飞书机器人消息。

### 审核记录

审核记录页面保存检查结果和状态变化，最多保留最近 1000 条结构化记录，同时兼容旧版文本日志。记录仅包含查询结果和事件信息，不写入私钥内容。

### 监控数据

监控数据保存在：

```text
AppMonitorData/
├── config.json
├── keys/
├── logs/
│   └── records.json
└── backups/
```

导入的私钥会复制到 `keys` 目录，配置、私钥和日志会设置为仅当前用户可访问。每次保存配置前会创建备份，并保留最近十份配置备份。移除监控应用时，受管私钥副本不会自动删除。

发布源码前不得提交 `dist/AppMonitorData`、`.p8` 私钥、监控配置或日志。

## GitHub 发布

应提交以下源码和配置：

```text
Package.swift
Info_confuse.plist
Sources/
build_app_confuse.sh
build_confuse.command
README.md
.gitignore
```

以下内容为本地生成或包含运行数据，不应提交：

```text
.build/
.swiftpm/
dist/
*.app/
AppMonitorData/
```

仓库不提供源码运行说明，使用者通过 `build_confuse.command` 构建应用。
