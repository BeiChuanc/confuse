# Confuse 混淆机

Confuse 是面向 macOS 的 SwiftUI 桌面工具，用于处理 Swift 和 Flutter 项目的文件名、代码标识符及资源引用。应用支持普通混淆、反混淆和合包增量混淆，并使用 JSON 文件保存可逆映射。

## 功能

- 自动识别 Swift 和 Flutter 项目。
- 自动读取项目后缀，也可以手动输入一个或多个后缀。
- 支持选择项目目录或将项目文件夹拖入窗口。
- 混淆 Swift、Dart 源文件名称及符合项目后缀的代码标识符。
- 混淆 Flutter `assets` 资源和引用。
- 混淆 Swift `.xcassets` 资源集以及 `.mp4`、`.mov`、`.m4v` 媒体资源。
- 根据映射 JSON 恢复文件名、资源名和代码引用。
- 扫描已有混淆项目中的新增文件，并将新增映射合并到原 JSON。
- 映射缺失时自动查找，仍未找到时显示提示弹窗并停止操作。

## 环境要求

- macOS 13 或更高版本。
- Xcode Command Line Tools 或完整 Xcode。
- Swift 5.9 或更高版本。
- 系统自带的 Python 3。

确认环境：

```bash
swift --version
python3 --version
```

## 从源码运行

进入项目目录后执行：

```bash
./run_confuse.command
```

也可以直接执行：

```bash
swift run -c debug
```

## 打包应用

执行：

```bash
./build_confuse.command
```

构建完成后会生成：

```text
dist/Confuse.app
```

构建脚本会完成 Release 编译、资源复制、应用图标配置和本地临时签名。公开分发时仍需使用 Apple Developer ID 完成正式签名与公证。

## 使用方法

1. 在左侧选择“混淆”“反混淆”或“合包混淆”。
2. 点击“选择文件夹”，或把项目文件夹拖入项目区域。
3. 检查自动识别的项目类型和项目后缀，必要时手动修改后缀。
4. 选择命名规则。
5. 反混淆或合包时可以手动选择映射 JSON；留空时应用会自动查找。
6. 点击“执行操作”，等待执行状态显示完成。

操作会直接修改所选项目。正式处理前应使用 Git 提交当前代码，或保留完整项目备份。

## 命名规则

应用提供三种命名规则，文件、代码符号和资源统一使用当前选择的规则：

| 规则 | 格式 | 示例 |
| --- | --- | --- |
| 经典 | 项目名 + 3 位数字 + 2 位小写字母 | `Wanderbell123ab` |
| 增强 | 项目名 + 8 位小写字母和数字 | `Wanderbella8k2m5q9` |
| 匿名 | 字母开头的 12 位随机字母和数字，不包含项目名 | `k8m2q5n7x4pz` |

生成名称会进行全局防重。所选规则会写入映射 JSON 的 `metadata.naming_rule` 字段。

## 映射 JSON

首次混淆时，应用会在项目根目录创建 `JSON` 文件夹。文件名格式为：

```text
项目后缀_项目类型.json
```

例如：

```text
JSON/wanderbell_swift.json
JSON/wanderbell_flutter.json
```

反混淆和合包混淆按以下顺序查找映射：

1. 界面中手动选择的 JSON 文件。
2. 项目 `JSON` 目录中与项目后缀及项目类型精确匹配的文件。
3. 项目根目录中的旧版 `mapping_swift.json` 或 `mapping_flutter.json`。

如果都不存在，应用会弹出“未找到映射 JSON”提示并停止处理。

## 操作说明

### 混淆

扫描工程并生成新的文件、符号和资源名称，更新工程引用，同时创建或更新映射 JSON。

### 反混淆

读取映射 JSON，反向恢复文件名、代码符号、资源名和相关引用。缺少映射时不会修改项目。

### 合包混淆

适用于已混淆工程加入新代码或资源后的增量处理。应用保留现有映射，只为映射中不存在的新内容生成名称，并写回同一个 JSON。

合包操作要求工程当前处于混淆状态。已经反混淆的工程需要先重新执行混淆。

## GitHub 发布

以下目录和文件属于源码仓库内容：

```text
Package.swift
Info_confuse.plist
Sources/
build_app_confuse.sh
build_confuse.command
run_confuse.command
README_confuse.md
.gitignore
```

`.build`、`.swiftpm`、`dist` 和 `.app` 均为本地生成内容，已经在 `.gitignore` 中排除。
