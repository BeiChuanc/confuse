#!/usr/bin/env python3
"""Confuse 桌面端使用的 Swift / Flutter 混淆与反混淆引擎。"""

import argparse
import json
import random
import re
import string
import sys
from pathlib import Path


SWIFT_KEYWORDS_CONFUSE = {
    "import", "class", "struct", "enum", "protocol", "extension", "typealias",
    "func", "var", "let", "if", "else", "switch", "case", "default", "for",
    "while", "repeat", "return", "break", "continue", "fallthrough", "guard",
    "defer", "do", "catch", "throw", "throws", "try", "as", "is", "in",
    "where", "public", "private", "fileprivate", "internal", "open", "static",
    "final", "lazy", "dynamic", "optional", "required", "convenience", "override",
    "mutating", "nonmutating", "indirect", "inout", "associatedtype", "self", "Self",
    "super", "init", "deinit", "subscript", "get", "set", "some", "any", "true",
    "false", "nil", "Type", "Protocol", "async", "await", "actor", "String", "Int",
    "Double", "Float", "Bool", "Array", "Dictionary", "Set", "Optional", "Result",
    "Error", "Void", "Never", "main", "print", "debugPrint",
}

SWIFT_FRAMEWORK_TYPES_CONFUSE = {
    "UIView", "UIViewController", "UILabel", "UIButton", "UIImageView", "UITableView",
    "UICollectionView", "UIScrollView", "View", "Text", "Image", "Button", "VStack",
    "HStack", "ZStack", "List", "NavigationView", "TabView", "Form", "Section", "Group",
    "ForEach", "State", "Binding", "ObservedObject", "StateObject", "EnvironmentObject",
    "Published", "ObservableObject", "Notification", "NotificationCenter", "UserDefaults",
    "URLSession", "Codable", "Encodable", "Decodable", "UIApplication", "Bundle",
    "FileManager", "DispatchQueue", "Task", "MainActor", "Sendable", "CGFloat", "CGRect",
    "CGSize", "CGPoint", "UIColor", "UIFont", "UIImage", "Data", "URL", "Date",
    "Calendar", "DateFormatter", "Locale", "NSObject", "Equatable", "Hashable", "Identifiable",
}

SKIP_DIRS_CONFUSE = {".git", ".build", "Pods", "DerivedData", ".swiftpm", "build", "JSON"}


class ConfuseError_confuse(Exception):
    """表示可直接反馈给桌面端的引擎业务异常。"""

    def __init__(self, message_confuse: str, code_confuse: str = "engine_error"):
        """保存中文错误信息和供桌面端判断的错误编码。"""
        super().__init__(message_confuse)
        self.code_confuse = code_confuse


def read_json_confuse(path_confuse: Path) -> dict:
    """读取 JSON 文件并返回字典。"""
    try:
        with path_confuse.open("r", encoding="utf-8") as file_confuse:
            value_confuse = json.load(file_confuse)
        return value_confuse if isinstance(value_confuse, dict) else {}
    except (OSError, json.JSONDecodeError) as error_confuse:
        raise ConfuseError_confuse("映射 JSON 无法读取。", "mapping_invalid") from error_confuse


def write_json_confuse(path_confuse: Path, value_confuse: dict) -> None:
    """把映射字典以 UTF-8 格式写回 JSON 文件。"""
    try:
        path_confuse.parent.mkdir(parents=True, exist_ok=True)
        with path_confuse.open("w", encoding="utf-8") as file_confuse:
            json.dump(value_confuse, file_confuse, indent=2, ensure_ascii=False)
    except OSError as error_confuse:
        raise ConfuseError_confuse("映射 JSON 无法写入。", "mapping_write_failed") from error_confuse


def mapping_file_name_confuse(request_confuse: dict, project_type_confuse: str) -> str:
    """根据项目后缀和类型生成 JSON 文件名。"""
    values_confuse = request_confuse.get("suffixes_confuse") or []
    suffix_confuse = str(values_confuse[0]) if values_confuse else "project"
    suffix_confuse = suffix_confuse.strip().lstrip("_")
    suffix_confuse = re.sub(r"[^A-Za-z0-9$-]", "_", suffix_confuse) or "project"
    return f"{suffix_confuse}_{project_type_confuse}.json"


def detect_mapping_path_confuse(request_confuse: dict, project_type_confuse: str) -> Path:
    """在应用同级 JSON 目录中定位当前项目后缀对应的映射文件。"""
    mapping_directory_value_confuse = request_confuse.get("mappingDirectory_confuse")
    if not mapping_directory_value_confuse:
        raise ConfuseError_confuse("未配置应用映射 JSON 目录。", "mapping_directory_missing")
    mapping_directory_confuse = Path(mapping_directory_value_confuse).expanduser().resolve()
    default_path_confuse = mapping_directory_confuse / mapping_file_name_confuse(request_confuse, project_type_confuse)
    if default_path_confuse.exists():
        return default_path_confuse
    if request_confuse.get("operation_confuse") in {"deobfuscate", "merge"}:
        raise ConfuseError_confuse(
            f"应用同级 JSON 文件夹中未找到 {default_path_confuse.name}。",
            "mapping_missing",
        )
    return default_path_confuse


def load_mapping_confuse(path_confuse: Path) -> dict:
    """加载映射并补齐所有兼容字段。"""
    if not path_confuse.exists():
        return {"files": {}, "symbols": {}, "assets": {}, "image_assets": {}, "media_files": {}, "metadata": {}}
    value_confuse = read_json_confuse(path_confuse)
    for key_confuse in ("files", "symbols", "assets", "image_assets", "media_files"):
        if not isinstance(value_confuse.get(key_confuse), dict):
            value_confuse[key_confuse] = {}
    if not isinstance(value_confuse.get("metadata"), dict):
        value_confuse["metadata"] = {}
    return value_confuse


def project_name_confuse(root_confuse: Path, project_type_confuse: str) -> str:
    """读取 Flutter 名称或 Swift 工程名称，用于生成新标识。"""
    if project_type_confuse == "flutter":
        pubspec_confuse = root_confuse / "pubspec.yaml"
        if pubspec_confuse.exists():
            for line_confuse in pubspec_confuse.read_text(encoding="utf-8").splitlines():
                if line_confuse.strip().startswith("name:"):
                    return line_confuse.split(":", 1)[1].strip()
    xcode_projects_confuse = sorted(root_confuse.glob("*.xcodeproj"))
    if xcode_projects_confuse:
        return xcode_projects_confuse[0].stem
    return root_confuse.name or "project"


def is_skipped_path_confuse(path_confuse: Path, project_type_confuse: str) -> bool:
    """判断路径是否属于构建产物、依赖或隐藏目录。"""
    if any(part_confuse in SKIP_DIRS_CONFUSE for part_confuse in path_confuse.parts):
        return True
    if project_type_confuse == "swift" and path_confuse.name in {"Info.plist", "main.swift"}:
        return True
    return False


def is_skip_symbol_confuse(symbol_confuse: str, project_type_confuse: str) -> bool:
    """判断符号是否属于 Swift 关键字或系统类型。"""
    if project_type_confuse != "swift":
        return False
    return (
        symbol_confuse in SWIFT_KEYWORDS_CONFUSE
        or symbol_confuse in SWIFT_FRAMEWORK_TYPES_CONFUSE
        or symbol_confuse.startswith(("UI", "NS", "CG", "CF", "CA", "SK", "SC", "AV", "MT", "MK"))
        or (symbol_confuse.isupper() and len(symbol_confuse) > 1)
    )


def new_name_confuse(project_name_confuse_value: str, used_confuse: set, naming_rule_confuse: str) -> str:
    """根据界面选择的规则生成合法且唯一的代码标识符。"""
    while True:
        if naming_rule_confuse == "extended":
            random_part_confuse = "".join(random.choices(string.ascii_lowercase + string.digits, k=8))
            candidate_confuse = f"{project_name_confuse_value}{random_part_confuse}"
        elif naming_rule_confuse == "anonymous":
            candidate_confuse = random.choice(string.ascii_lowercase) + "".join(
                random.choices(string.ascii_lowercase + string.digits, k=11)
            )
        else:
            candidate_confuse = f"{project_name_confuse_value}{random.randint(0, 999):03d}{''.join(random.choices(string.ascii_lowercase, k=2))}"
        if candidate_confuse not in used_confuse:
            used_confuse.add(candidate_confuse)
            return candidate_confuse


def suffixes_confuse(request_confuse: dict, project_type_confuse: str) -> list[str]:
    """读取后缀并为 Swift 补齐大小写变体，兼容 Xcode 常见文件命名方式。"""
    values_confuse = request_confuse.get("suffixes_confuse") or []
    normalized_confuse = [
        str(value_confuse) if str(value_confuse).startswith("_") else f"_{value_confuse}"
        for value_confuse in values_confuse
    ]
    if project_type_confuse != "swift":
        return normalized_confuse

    variants_confuse = []
    for suffix_confuse in normalized_confuse:
        stem_confuse = suffix_confuse.lstrip("_")
        variant_values_confuse = [
            suffix_confuse,
            f"_{stem_confuse.lower()}",
            f"_{stem_confuse[:1].upper()}{stem_confuse[1:].lower()}" if stem_confuse else suffix_confuse,
        ]
        for variant_confuse in variant_values_confuse:
            if variant_confuse not in variants_confuse:
                variants_confuse.append(variant_confuse)
    return variants_confuse


def token_pattern_confuse(project_type_confuse: str):
    """返回针对 Dart 或 Swift 的代码 token 正则。"""
    if project_type_confuse == "flutter":
        return re.compile(r"(?P<comment>//[^\n]*|/\*.*?\*/)|(?P<string>r?(?:\"\"\".*?\"\"\"|''' .*? '''|\"(?:[^\"\\]|\\.)*\"|'(?:[^'\\]|\\.)*'))|(?P<identifier>\b[_a-zA-Z$][_a-zA-Z0-9$]*\b)", re.VERBOSE | re.DOTALL)
    return re.compile(r'(?P<comment>//[^\n]*|/\*.*?\*/)|(?P<string>""".*?"""|"(?:[^"\\]|\\.)*?")|(?P<identifier>\b[_a-zA-Z][_a-zA-Z0-9]*\b)', re.VERBOSE | re.DOTALL)


def relative_path_confuse(path_confuse: Path, root_confuse: Path) -> str:
    """返回使用正斜杠的工程相对路径。"""
    return path_confuse.relative_to(root_confuse).as_posix()


def file_pairs_confuse(mapping_confuse: dict, root_confuse: Path) -> list[tuple[Path, Path]]:
    """把映射文件中的路径转换为当前工程内的物理路径。"""
    pairs_confuse = []
    for old_value_confuse, new_value_confuse in mapping_confuse.get("files", {}).items():
        old_path_confuse = Path(old_value_confuse)
        new_path_confuse = Path(new_value_confuse)
        if not old_path_confuse.is_absolute():
            old_path_confuse = root_confuse / old_path_confuse
        if not new_path_confuse.is_absolute():
            new_path_confuse = root_confuse / new_path_confuse
        pairs_confuse.append((old_path_confuse, new_path_confuse))
    return pairs_confuse


def build_used_names_confuse(mapping_confuse: dict) -> set:
    """从已有映射中收集所有新名称，避免增量混淆发生碰撞。"""
    used_confuse = set()
    for key_confuse in ("files", "symbols", "assets", "image_assets", "media_files"):
        for value_confuse in mapping_confuse.get(key_confuse, {}).values():
            used_confuse.add(Path(str(value_confuse)).stem)
    return used_confuse


def scan_files_confuse(root_confuse: Path, project_type_confuse: str, suffixes_confuse_value: list[str], mapping_confuse: dict, used_confuse: set, project_name_confuse_value: str, naming_rule_confuse: str) -> dict:
    """扫描并记录符合后缀的 Swift 或 Dart 文件重命名计划。"""
    extension_confuse = ".dart" if project_type_confuse == "flutter" else ".swift"
    known_confuse = mapping_confuse["files"]
    for path_confuse in root_confuse.rglob(f"*{extension_confuse}"):
        if is_skipped_path_confuse(path_confuse, project_type_confuse) or path_confuse.name == "main.dart":
            continue
        old_key_confuse = str(path_confuse)
        if old_key_confuse in known_confuse or old_key_confuse in known_confuse.values():
            continue
        if path_confuse.name.startswith(project_name_confuse_value) and re.search(r"\d{3}[a-z]{2}" + re.escape(extension_confuse) + r"$", path_confuse.name):
            continue
        if not any(suffix_confuse in path_confuse.name for suffix_confuse in suffixes_confuse_value):
            continue
        new_path_confuse = path_confuse.with_name(new_name_confuse(project_name_confuse_value, used_confuse, naming_rule_confuse) + extension_confuse)
        known_confuse[old_key_confuse] = str(new_path_confuse)
    return mapping_confuse


def scan_assets_confuse(root_confuse: Path, project_type_confuse: str, mapping_confuse: dict, used_confuse: set, project_name_confuse_value: str, naming_rule_confuse: str) -> dict:
    """扫描 Flutter assets、Swift 资源集和独立媒体文件。"""
    if project_type_confuse == "flutter":
        assets_root_confuse = root_confuse / "assets"
        for path_confuse in assets_root_confuse.rglob("*") if assets_root_confuse.exists() else []:
            if not path_confuse.is_file() or path_confuse.name.startswith("."):
                continue
            relative_confuse = relative_path_confuse(path_confuse, root_confuse)
            if relative_confuse in mapping_confuse["assets"]:
                continue
            new_name_confuse_value = new_name_confuse(project_name_confuse_value, used_confuse, naming_rule_confuse) + path_confuse.suffix
            new_relative_confuse = (path_confuse.parent / new_name_confuse_value).relative_to(root_confuse).as_posix()
            mapping_confuse["assets"][relative_confuse] = new_relative_confuse
            mapping_confuse["files"][str(path_confuse)] = str(root_confuse / new_relative_confuse)
        return mapping_confuse

    for xcassets_confuse in root_confuse.rglob("*.xcassets"):
        if is_skipped_path_confuse(xcassets_confuse, project_type_confuse):
            continue
        for asset_dir_confuse in xcassets_confuse.rglob("*"):
            if not asset_dir_confuse.is_dir() or not asset_dir_confuse.name.endswith((".imageset", ".colorset", ".appiconset", ".launchimage")):
                continue
            asset_name_confuse = re.sub(r"\.(imageset|colorset|appiconset|launchimage)$", "", asset_dir_confuse.name)
            if asset_name_confuse in {"AppIcon", "AccentColor"} or asset_name_confuse in mapping_confuse["image_assets"]:
                continue
            if asset_name_confuse.startswith(project_name_confuse_value) and re.search(r"\d{3}[a-z]{2}$", asset_name_confuse):
                continue
            new_asset_confuse = new_name_confuse(project_name_confuse_value, used_confuse, naming_rule_confuse)
            mapping_confuse["image_assets"][asset_name_confuse] = new_asset_confuse
            mapping_confuse["files"][str(asset_dir_confuse)] = str(asset_dir_confuse.with_name(asset_dir_confuse.name.replace(asset_name_confuse, new_asset_confuse)))

    for path_confuse in root_confuse.rglob("*"):
        if not path_confuse.is_file() or path_confuse.suffix.lower() not in {".mp4", ".mov", ".m4v"} or is_skipped_path_confuse(path_confuse, project_type_confuse):
            continue
        stem_confuse = path_confuse.stem
        if stem_confuse in mapping_confuse["media_files"] or re.search(r"\d{3}[a-z]{2}$", stem_confuse):
            continue
        new_stem_confuse = new_name_confuse(project_name_confuse_value, used_confuse, naming_rule_confuse)
        mapping_confuse["media_files"][stem_confuse] = new_stem_confuse
        mapping_confuse["files"][str(path_confuse)] = str(path_confuse.with_name(new_stem_confuse + path_confuse.suffix))
    return mapping_confuse


def scan_symbols_confuse(root_confuse: Path, project_type_confuse: str, suffixes_confuse_value: list[str], mapping_confuse: dict, used_confuse: set, project_name_confuse_value: str, naming_rule_confuse: str) -> dict:
    """扫描源码中的项目符号并生成新名称映射。"""
    extension_confuse = ".dart" if project_type_confuse == "flutter" else ".swift"
    pattern_confuse = token_pattern_confuse(project_type_confuse)
    for path_confuse in root_confuse.rglob(f"*{extension_confuse}"):
        if is_skipped_path_confuse(path_confuse, project_type_confuse):
            continue
        try:
            content_confuse = path_confuse.read_text(encoding="utf-8")
        except (OSError, UnicodeDecodeError):
            continue
        for match_confuse in pattern_confuse.finditer(content_confuse):
            if match_confuse.lastgroup != "identifier":
                continue
            symbol_confuse = match_confuse.group()
            if symbol_confuse in mapping_confuse["symbols"].values():
                continue
            if symbol_confuse.startswith(project_name_confuse_value) and re.search(r"\d{3}[a-z]{2}$", symbol_confuse):
                continue
            if any(suffix_confuse in symbol_confuse for suffix_confuse in suffixes_confuse_value) and not is_skip_symbol_confuse(symbol_confuse, project_type_confuse):
                if symbol_confuse not in mapping_confuse["symbols"]:
                    mapping_confuse["symbols"][symbol_confuse] = new_name_confuse(project_name_confuse_value, used_confuse, naming_rule_confuse)
    return mapping_confuse


def replace_content_confuse(content_confuse: str, mapping_confuse: dict, project_type_confuse: str, reverse_confuse: bool = False) -> str:
    """按正向或反向映射替换源码、配置和资源引用。"""
    def pairs_confuse(key_confuse: str):
        values_confuse = mapping_confuse.get(key_confuse, {})
        return [(str(value_confuse), str(key_value_confuse)) for key_value_confuse, value_confuse in values_confuse.items()] if reverse_confuse else [(str(key_value_confuse), str(value_confuse)) for key_value_confuse, value_confuse in values_confuse.items()]

    for old_confuse, new_confuse_value in sorted(pairs_confuse("image_assets"), key=lambda item_confuse: len(item_confuse[0]), reverse=True):
        if project_type_confuse == "swift":
            content_confuse = re.sub(rf'(["\']){re.escape(old_confuse)}\1', rf"\1{new_confuse_value}\1", content_confuse)
    for old_confuse, new_confuse_value in sorted(pairs_confuse("media_files"), key=lambda item_confuse: len(item_confuse[0]), reverse=True):
        if project_type_confuse == "swift":
            content_confuse = re.sub(rf'(["\']){re.escape(old_confuse)}\1', rf"\1{new_confuse_value}\1", content_confuse)
    for old_confuse, new_confuse_value in sorted(pairs_confuse("assets"), key=lambda item_confuse: len(item_confuse[0]), reverse=True):
        content_confuse = content_confuse.replace(old_confuse.replace("\\", "/"), new_confuse_value.replace("\\", "/"))
    for old_confuse, new_confuse_value in sorted(pairs_confuse("assets"), key=lambda item_confuse: len(Path(item_confuse[0]).name), reverse=True):
        content_confuse = content_confuse.replace(Path(old_confuse).name, Path(new_confuse_value).name)
    for old_confuse, new_confuse_value in sorted(pairs_confuse("files"), key=lambda item_confuse: len(Path(item_confuse[0]).name), reverse=True):
        content_confuse = content_confuse.replace(Path(old_confuse).name, Path(new_confuse_value).name)
    for old_confuse, new_confuse_value in sorted(pairs_confuse("symbols"), key=lambda item_confuse: len(item_confuse[0]), reverse=True):
        content_confuse = re.sub(rf"\b{re.escape(old_confuse)}\b", new_confuse_value, content_confuse)
    return content_confuse


def update_references_confuse(root_confuse: Path, project_type_confuse: str, mapping_confuse: dict, reverse_confuse: bool = False) -> int:
    """更新工程源码和配置文件中的所有引用，并返回修改文件数。"""
    extensions_confuse = {".dart", ".yaml"} if project_type_confuse == "flutter" else {".swift", ".plist", ".pbxproj"}
    changed_count_confuse = 0
    for path_confuse in root_confuse.rglob("*"):
        if not path_confuse.is_file() or path_confuse.suffix not in extensions_confuse or is_skipped_path_confuse(path_confuse, project_type_confuse):
            continue
        try:
            original_confuse = path_confuse.read_text(encoding="utf-8")
            updated_confuse = replace_content_confuse(original_confuse, mapping_confuse, project_type_confuse, reverse_confuse)
            if updated_confuse != original_confuse:
                path_confuse.write_text(updated_confuse, encoding="utf-8")
                changed_count_confuse += 1
        except (OSError, UnicodeDecodeError):
            continue
    return changed_count_confuse


def rename_pairs_confuse(pairs_confuse: list[tuple[Path, Path]], reverse_confuse: bool = False) -> int:
    """按映射执行物理重命名，并避免目标文件覆盖。"""
    count_confuse = 0
    ordered_confuse = sorted(pairs_confuse, key=lambda pair_confuse: len(str(pair_confuse[0])), reverse=True)
    for old_path_confuse, new_path_confuse in ordered_confuse:
        source_confuse, target_confuse = (new_path_confuse, old_path_confuse) if reverse_confuse else (old_path_confuse, new_path_confuse)
        if not source_confuse.exists() or source_confuse == target_confuse:
            continue
        if target_confuse.exists():
            continue
        target_confuse.parent.mkdir(parents=True, exist_ok=True)
        try:
            source_confuse.rename(target_confuse)
            count_confuse += 1
        except OSError:
            continue
    return count_confuse


def run_engine_confuse(request_confuse: dict) -> dict:
    """执行桌面端请求并返回可序列化的结果对象。"""
    root_confuse = Path(request_confuse.get("projectPath_confuse", "")).expanduser().resolve()
    if not root_confuse.is_dir():
        raise ConfuseError_confuse("选择的项目文件夹不存在。", "project_missing")
    project_type_confuse = request_confuse.get("projectType_confuse")
    if project_type_confuse not in {"swift", "flutter"}:
        raise ConfuseError_confuse("不支持的项目类型。", "project_type_invalid")
    operation_confuse = request_confuse.get("operation_confuse", "obfuscate")
    naming_rule_confuse = request_confuse.get("namingRule_confuse", "classic")
    if naming_rule_confuse not in {"classic", "extended", "anonymous"}:
        raise ConfuseError_confuse("不支持的命名规则。", "naming_rule_invalid")
    mapping_path_confuse = detect_mapping_path_confuse(request_confuse, project_type_confuse)
    mapping_confuse = load_mapping_confuse(mapping_path_confuse)
    project_name_confuse_value = project_name_confuse(root_confuse, project_type_confuse)
    suffixes_confuse_value = suffixes_confuse(request_confuse, project_type_confuse)
    used_confuse = build_used_names_confuse(mapping_confuse)

    if operation_confuse == "deobfuscate":
        if not mapping_path_confuse.exists():
            raise ConfuseError_confuse("反混淆需要映射 JSON。", "mapping_missing")
        updated_count_confuse = update_references_confuse(root_confuse, project_type_confuse, mapping_confuse, True)
        renamed_count_confuse = rename_pairs_confuse(file_pairs_confuse(mapping_confuse, root_confuse), True)
        return {
            "ok_confuse": True, "operation_confuse": operation_confuse, "mappingPath_confuse": str(mapping_path_confuse),
            "renamedFiles_confuse": renamed_count_confuse, "updatedFiles_confuse": updated_count_confuse,
            "symbolCount_confuse": len(mapping_confuse["symbols"]), "message_confuse": "项目已根据映射 JSON 完成反混淆。",
        }

    if operation_confuse == "merge" and mapping_confuse["files"]:
        pairs_confuse = file_pairs_confuse(mapping_confuse, root_confuse)
        old_present_confuse = sum(1 for old_path_confuse, _ in pairs_confuse if old_path_confuse.exists())
        new_present_confuse = sum(1 for _, new_path_confuse in pairs_confuse if new_path_confuse.exists())
        if old_present_confuse > 0 and new_present_confuse == 0:
            raise ConfuseError_confuse("项目当前处于反混淆状态，请先混淆后再进行合包。", "project_state_invalid")

    scan_files_confuse(root_confuse, project_type_confuse, suffixes_confuse_value, mapping_confuse, used_confuse, project_name_confuse_value, naming_rule_confuse)
    scan_assets_confuse(root_confuse, project_type_confuse, mapping_confuse, used_confuse, project_name_confuse_value, naming_rule_confuse)
    scan_symbols_confuse(root_confuse, project_type_confuse, suffixes_confuse_value, mapping_confuse, used_confuse, project_name_confuse_value, naming_rule_confuse)
    mapping_confuse["metadata"]["naming_rule"] = naming_rule_confuse
    write_json_confuse(mapping_path_confuse, mapping_confuse)
    updated_count_confuse = update_references_confuse(root_confuse, project_type_confuse, mapping_confuse)
    renamed_count_confuse = rename_pairs_confuse(file_pairs_confuse(mapping_confuse, root_confuse))
    operation_message_confuse = "项目混淆完成，映射 JSON 已更新。" if operation_confuse == "obfuscate" else "新增文件已完成混淆，映射 JSON 已更新。"
    return {
        "ok_confuse": True, "operation_confuse": operation_confuse, "mappingPath_confuse": str(mapping_path_confuse),
        "renamedFiles_confuse": renamed_count_confuse, "updatedFiles_confuse": updated_count_confuse,
        "symbolCount_confuse": len(mapping_confuse["symbols"]), "message_confuse": operation_message_confuse,
    }


def main_confuse() -> int:
    """读取请求文件、执行引擎并输出唯一一行 JSON 结果。"""
    parser_confuse = argparse.ArgumentParser()
    parser_confuse.add_argument("--request", required=True)
    arguments_confuse = parser_confuse.parse_args()
    try:
        request_confuse = read_json_confuse(Path(arguments_confuse.request))
        result_confuse = run_engine_confuse(request_confuse)
        print(json.dumps(result_confuse, ensure_ascii=False))
        return 0
    except ConfuseError_confuse as error_confuse:
        print(json.dumps({"ok_confuse": False, "error_confuse": str(error_confuse), "errorCode_confuse": error_confuse.code_confuse}, ensure_ascii=False))
        return 1
    except Exception as error_confuse:
        print(json.dumps({"ok_confuse": False, "error_confuse": "混淆引擎执行出现异常。", "errorCode_confuse": "engine_error"}, ensure_ascii=False))
        return 1


if __name__ == "__main__":
    sys.exit(main_confuse())
