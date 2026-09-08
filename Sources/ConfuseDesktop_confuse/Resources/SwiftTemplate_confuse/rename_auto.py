#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
项目重命名脚本 - 自动检测版本
功能：自动检测项目类型（Swift/Flutter），并执行相应的重命名操作
支持：
  - Swift项目：检测 .xcodeproj，重命名 .swift 文件
  - Flutter项目：检测 pubspec.yaml，重命名 .dart 文件
"""

import os
import re
import subprocess
from pathlib import Path


# ============================================================
# 项目类型检测
# ============================================================

def detect_project_type_project1(project_dir_project1):
    """
    检测项目类型（Swift 或 Flutter）
    
    参数:
        project_dir_project1: 项目根目录路径
    返回:
        'swift' | 'flutter' | None
    """
    # 检测 Swift 项目标志：.xcodeproj 文件夹
    for item_project1 in os.listdir(project_dir_project1):
        if item_project1.endswith('.xcodeproj'):
            return 'swift'
    
    # 检测 Flutter 项目标志：pubspec.yaml 文件
    pubspec_path_project1 = os.path.join(project_dir_project1, 'pubspec.yaml')
    if os.path.exists(pubspec_path_project1):
        return 'flutter'
    
    return None


# ============================================================
# Swift 项目处理逻辑
# ============================================================

def detect_swift_new_name_project1(project_dir_project1):
    """
    从 .xcodeproj 文件夹名称检测 Swift 项目名称
    
    参数:
        project_dir_project1: 项目根目录路径
    返回:
        保留用户输入大小写的项目名称字符串
    """
    try:
        for item_project1 in os.listdir(project_dir_project1):
            if item_project1.endswith('.xcodeproj'):
                project_name_project1 = item_project1.replace('.xcodeproj', '')
                print(f"从 .xcodeproj 检测到项目名: {project_name_project1}")
                return project_name_project1
        return None
    except Exception as e_project1:
        print(f"检测 Swift 项目名失败: {e_project1}")
        return None


def detect_swift_old_name_project1(source_dir_project1):
    """
    从 Swift 源码目录前10个文件中检测旧项目名
    
    参数:
        source_dir_project1: 源码目录路径
    返回:
        旧项目名称字符串（小写形式）
    """
    swift_files_project1 = []
    
    # 递归遍历源码目录获取所有 .swift 文件
    for root_project1, dirs_project1, files_project1 in os.walk(source_dir_project1):
        for file_project1 in files_project1:
            if file_project1.endswith('.swift'):
                swift_files_project1.append(os.path.join(root_project1, file_project1))
                if len(swift_files_project1) >= 10:
                    break
        if len(swift_files_project1) >= 10:
            break
    
    # 从文件名中提取项目名（匹配 xxx_项目名.swift 格式）
    project_names_project1 = {}
    for file_path_project1 in swift_files_project1:
        filename_project1 = os.path.basename(file_path_project1)
        match_project1 = re.search(r'_([a-zA-Z0-9_]+)\.swift$', filename_project1)
        if match_project1:
            old_name_project1 = match_project1.group(1).lower()
            project_names_project1[old_name_project1] = project_names_project1.get(old_name_project1, 0) + 1
    
    # 选择出现次数最多的项目名
    if project_names_project1:
        old_name_project1 = max(project_names_project1, key=project_names_project1.get)
        print(f"从文件名检测到旧项目名: {old_name_project1} (出现 {project_names_project1[old_name_project1]} 次)")
        return old_name_project1
    
    print("未能从 Swift 文件名中检测到旧项目名")
    return None


def rename_swift_files_project1(source_dir_project1, old_name_project1, new_name_project1):
    """
    重命名 Swift 源码目录中所有包含旧项目名的文件
    
    参数:
        source_dir_project1: 源码目录路径
        old_name_project1: 旧项目名（小写）
        new_name_project1: 新项目名（小写）
    返回:
        重命名的文件数量
    """
    renamed_count_project1 = 0
    
    # 收集所有需要重命名的文件（从深层到浅层，避免路径问题）
    files_to_rename_project1 = []
    for root_project1, dirs_project1, files_project1 in os.walk(source_dir_project1):
        for file_project1 in files_project1:
            if old_name_project1 in file_project1.lower():
                old_path_project1 = os.path.join(root_project1, file_project1)
                files_to_rename_project1.append(old_path_project1)
    
    # 按路径深度排序（深的先处理）
    files_to_rename_project1.sort(key=lambda x: x.count(os.sep), reverse=True)
    
    # 执行重命名
    for old_path_project1 in files_to_rename_project1:
        old_filename_project1 = os.path.basename(old_path_project1)
        # 替换文件名中的旧项目名（保持原有大小写风格）
        new_filename_project1 = re.sub(
            f'_{old_name_project1}',
            f'_{new_name_project1}',
            old_filename_project1,
            flags=re.IGNORECASE
        )
        
        # 如果文件名没有变化，跳过
        if new_filename_project1 == old_filename_project1:
            continue
            
        new_path_project1 = os.path.join(os.path.dirname(old_path_project1), new_filename_project1)
        
        try:
            os.rename(old_path_project1, new_path_project1)
            print(f"重命名文件: {os.path.basename(old_path_project1)} -> {new_filename_project1}")
            renamed_count_project1 += 1
        except Exception as e_project1:
            print(f"重命名文件失败 {old_path_project1}: {e_project1}")
    
    return renamed_count_project1


def replace_swift_content_project1(source_dir_project1, old_name_project1, new_name_project1):
    """
    替换 Swift 源码目录中所有文件内容中的旧项目名
    支持替换各种大小写形式：小写、大写、首字母大写等
    
    参数:
        source_dir_project1: 源码目录路径
        old_name_project1: 旧项目名（小写）
        new_name_project1: 新项目名（小写）
    返回:
        修改的文件数量
    """
    modified_count_project1 = 0
    
    # 准备不同大小写形式的替换规则
    replacements_project1 = [
        (old_name_project1, new_name_project1),  # 全小写
        (old_name_project1.upper(), new_name_project1.upper()),  # 全大写
        (old_name_project1.capitalize(), new_name_project1.capitalize()),  # 首字母大写
    ]
    
    # 遍历所有 .swift 文件
    for root_project1, dirs_project1, files_project1 in os.walk(source_dir_project1):
        for file_project1 in files_project1:
            if file_project1.endswith('.swift'):
                file_path_project1 = os.path.join(root_project1, file_project1)
                
                try:
                    # 读取文件内容
                    with open(file_path_project1, 'r', encoding='utf-8') as f_project1:
                        content_project1 = f_project1.read()
                    
                    # 记录原始内容
                    original_content_project1 = content_project1
                    
                    # 应用所有替换规则
                    for old_form_project1, new_form_project1 in replacements_project1:
                        content_project1 = content_project1.replace(old_form_project1, new_form_project1)
                    
                    # 如果内容有变化，写回文件
                    if content_project1 != original_content_project1:
                        with open(file_path_project1, 'w', encoding='utf-8') as f_project1:
                            f_project1.write(content_project1)
                        print(f"替换内容: {os.path.basename(file_path_project1)}")
                        modified_count_project1 += 1
                        
                except Exception as e_project1:
                    print(f"处理文件失败 {file_path_project1}: {e_project1}")
    
    return modified_count_project1


def process_swift_project_project1(project_dir_project1):
    """
    处理 Swift 项目的重命名流程
    
    参数:
        project_dir_project1: 项目根目录路径
    返回:
        是否成功
    """
    print("\n" + "="*60)
    print("检测到 Swift 项目")
    print("="*60 + "\n")
    
    # 1. 检测新项目名
    print("步骤 1: 检测新项目名...")
    project_name_project1 = detect_swift_new_name_project1(project_dir_project1)
    if not project_name_project1:
        print("✗ 无法检测新项目名，退出")
        return False

    # 项目目录保留用户输入的大小写，源码标识后缀统一使用小写。
    new_name_project1 = project_name_project1.lower()
    
    # 确定源码目录（与项目名同名的目录）
    source_dir_name_project1 = project_name_project1
    # 优先按工程名原始大小写寻找源码目录，并兼容旧模板命名。
    possible_dirs_project1 = [
        source_dir_name_project1,
        source_dir_name_project1.capitalize(),
        source_dir_name_project1.lower()
    ]
    
    source_dir_project1 = None
    for dir_name_project1 in possible_dirs_project1:
        test_path_project1 = os.path.join(project_dir_project1, dir_name_project1)
        if os.path.exists(test_path_project1) and os.path.isdir(test_path_project1):
            source_dir_project1 = test_path_project1
            break
    
    if not source_dir_project1:
        print(f"✗ 源码目录不存在（尝试了: {', '.join(possible_dirs_project1)}）")
        return False
    
    print(f"源码目录: {source_dir_project1}\n")
    
    # 2. 检测旧项目名
    print("步骤 2: 检测旧项目名...")
    old_name_project1 = detect_swift_old_name_project1(source_dir_project1)
    if not old_name_project1:
        print("✗ 无法检测旧项目名，退出")
        return False
    
    print(f"旧项目名: {old_name_project1}")
    print(f"新项目名: {new_name_project1}\n")
    
    # 检查新旧项目名是否相同
    if old_name_project1 == new_name_project1:
        print(f"✓ 项目名已经是 {new_name_project1}，无需重命名")
        return True
    
    # 3. 替换文件内容
    print("步骤 3: 替换文件内容中的项目名...")
    modified_count_project1 = replace_swift_content_project1(
        source_dir_project1, 
        old_name_project1, 
        new_name_project1
    )
    print(f"✓ 共修改 {modified_count_project1} 个文件的内容\n")
    
    # 4. 重命名文件
    print("步骤 4: 重命名文件...")
    renamed_count_project1 = rename_swift_files_project1(
        source_dir_project1, 
        old_name_project1, 
        new_name_project1
    )
    print(f"✓ 共重命名 {renamed_count_project1} 个文件\n")
    
    print("="*60)
    print("Swift 项目重命名完成！")
    print("="*60)
    print(f"旧项目名: {old_name_project1}")
    print(f"新项目名: {new_name_project1}")
    print(f"修改文件内容: {modified_count_project1} 个")
    print(f"重命名文件: {renamed_count_project1} 个")
    print("\n提示：请手动在 Xcode 中检查项目配置是否正确")
    
    return True


# ============================================================
# Flutter 项目处理逻辑
# ============================================================

def detect_flutter_new_name_project1(project_dir_project1):
    """
    从 pubspec.yaml 读取 Flutter 项目名称
    
    参数:
        project_dir_project1: 项目根目录路径
    返回:
        项目名称字符串
    """
    yaml_path_project1 = os.path.join(project_dir_project1, 'pubspec.yaml')
    try:
        with open(yaml_path_project1, 'r', encoding='utf-8') as f_project1:
            # 简单解析 yaml（不依赖 yaml 库）
            for line_project1 in f_project1:
                if line_project1.startswith('name:'):
                    name_project1 = line_project1.split(':', 1)[1].strip()
                    print(f"从 pubspec.yaml 检测到项目名: {name_project1}")
                    return name_project1
        return None
    except Exception as e_project1:
        print(f"读取 pubspec.yaml 失败: {e_project1}")
        return None


def detect_flutter_old_name_project1(lib_dir_project1):
    """
    从 Flutter lib 目录前10个文件中检测旧项目名
    
    参数:
        lib_dir_project1: lib 目录路径
    返回:
        旧项目名称字符串
    """
    dart_files_project1 = []
    
    # 递归遍历 lib 目录获取所有 .dart 文件
    for root_project1, dirs_project1, files_project1 in os.walk(lib_dir_project1):
        for file_project1 in files_project1:
            if file_project1.endswith('.dart'):
                dart_files_project1.append(os.path.join(root_project1, file_project1))
                if len(dart_files_project1) >= 10:
                    break
        if len(dart_files_project1) >= 10:
            break
    
    # 从文件名中提取项目名（匹配 xxx_项目名.dart 格式）
    project_names_project1 = {}
    for file_path_project1 in dart_files_project1:
        filename_project1 = os.path.basename(file_path_project1)
        match_project1 = re.search(r'_([a-zA-Z0-9_]+)\.dart$', filename_project1)
        if match_project1:
            old_name_project1 = match_project1.group(1)
            project_names_project1[old_name_project1] = project_names_project1.get(old_name_project1, 0) + 1
    
    # 选择出现次数最多的项目名
    if project_names_project1:
        old_name_project1 = max(project_names_project1, key=project_names_project1.get)
        print(f"从文件名检测到旧项目名: {old_name_project1} (出现 {project_names_project1[old_name_project1]} 次)")
        return old_name_project1
    
    print("未能从 Flutter 文件名中检测到旧项目名")
    return None


def rename_flutter_files_project1(lib_dir_project1, old_name_project1, new_name_project1):
    """
    重命名 Flutter lib 目录中所有包含旧项目名的文件
    
    参数:
        lib_dir_project1: lib 目录路径
        old_name_project1: 旧项目名
        new_name_project1: 新项目名
    返回:
        重命名的文件数量
    """
    renamed_count_project1 = 0
    
    # 收集所有需要重命名的文件（从深层到浅层，避免路径问题）
    files_to_rename_project1 = []
    for root_project1, dirs_project1, files_project1 in os.walk(lib_dir_project1):
        for file_project1 in files_project1:
            if old_name_project1 in file_project1:
                old_path_project1 = os.path.join(root_project1, file_project1)
                files_to_rename_project1.append(old_path_project1)
    
    # 按路径深度排序（深的先处理）
    files_to_rename_project1.sort(key=lambda x: x.count(os.sep), reverse=True)
    
    # 执行重命名
    for old_path_project1 in files_to_rename_project1:
        new_filename_project1 = os.path.basename(old_path_project1).replace(old_name_project1, new_name_project1)
        new_path_project1 = os.path.join(os.path.dirname(old_path_project1), new_filename_project1)
        
        try:
            os.rename(old_path_project1, new_path_project1)
            print(f"重命名文件: {os.path.basename(old_path_project1)} -> {new_filename_project1}")
            renamed_count_project1 += 1
        except Exception as e_project1:
            print(f"重命名文件失败 {old_path_project1}: {e_project1}")
    
    return renamed_count_project1


def replace_flutter_content_project1(lib_dir_project1, old_name_project1, new_name_project1):
    """
    替换 Flutter lib 目录中所有文件内容中的旧项目名
    
    参数:
        lib_dir_project1: lib 目录路径
        old_name_project1: 旧项目名
        new_name_project1: 新项目名
    返回:
        修改的文件数量
    """
    modified_count_project1 = 0
    
    # 遍历所有 .dart 文件
    for root_project1, dirs_project1, files_project1 in os.walk(lib_dir_project1):
        for file_project1 in files_project1:
            if file_project1.endswith('.dart'):
                file_path_project1 = os.path.join(root_project1, file_project1)
                
                try:
                    # 读取文件内容
                    with open(file_path_project1, 'r', encoding='utf-8') as f_project1:
                        content_project1 = f_project1.read()
                    
                    # 替换所有出现的旧项目名
                    new_content_project1 = content_project1.replace(old_name_project1, new_name_project1)
                    
                    # 如果内容有变化，写回文件
                    if new_content_project1 != content_project1:
                        with open(file_path_project1, 'w', encoding='utf-8') as f_project1:
                            f_project1.write(new_content_project1)
                        print(f"替换内容: {os.path.basename(file_path_project1)}")
                        modified_count_project1 += 1
                        
                except Exception as e_project1:
                    print(f"处理文件失败 {file_path_project1}: {e_project1}")
    
    return modified_count_project1


def run_flutter_analyze_project1(project_dir_project1):
    """
    运行 flutter analyze 检查错误
    
    参数:
        project_dir_project1: 项目根目录路径
    """
    print("\n" + "="*60)
    print("运行 flutter analyze 检查...")
    print("="*60 + "\n")
    
    try:
        result_project1 = subprocess.run(
            ['flutter', 'analyze'],
            cwd=project_dir_project1,
            capture_output=True,
            text=True,
            timeout=60
        )
        
        # 输出结果
        if result_project1.stdout:
            print(result_project1.stdout)
        if result_project1.stderr:
            print(result_project1.stderr)
            
        if result_project1.returncode == 0:
            print("\n✓ flutter analyze 检查通过，没有发现错误")
        else:
            print(f"\n✗ flutter analyze 检查发现问题，退出码: {result_project1.returncode}")
            
    except subprocess.TimeoutExpired:
        print("✗ flutter analyze 执行超时")
    except FileNotFoundError:
        print("✗ 未找到 flutter 命令，请确保已安装 Flutter SDK")
    except Exception as e_project1:
        print(f"✗ 运行 flutter analyze 失败: {e_project1}")


def process_flutter_project_project1(project_dir_project1):
    """
    处理 Flutter 项目的重命名流程
    
    参数:
        project_dir_project1: 项目根目录路径
    返回:
        是否成功
    """
    print("\n" + "="*60)
    print("检测到 Flutter 项目")
    print("="*60 + "\n")
    
    lib_dir_project1 = os.path.join(project_dir_project1, 'lib')
    
    if not os.path.exists(lib_dir_project1):
        print(f"✗ lib 目录不存在: {lib_dir_project1}")
        return False
    
    # 1. 检测旧项目名
    print("步骤 1: 检测旧项目名...")
    old_name_project1 = detect_flutter_old_name_project1(lib_dir_project1)
    if not old_name_project1:
        print("✗ 无法检测旧项目名，退出")
        return False
    
    # 2. 读取新项目名
    print("\n步骤 2: 读取新项目名...")
    new_name_project1 = detect_flutter_new_name_project1(project_dir_project1)
    if not new_name_project1:
        print("✗ 无法读取新项目名，退出")
        return False
    
    print(f"旧项目名: {old_name_project1}")
    print(f"新项目名: {new_name_project1}\n")
    
    # 检查新旧项目名是否相同
    if old_name_project1 == new_name_project1:
        print(f"✓ 项目名已经是 {new_name_project1}，无需重命名")
        return True
    
    # 3. 替换文件内容
    print("步骤 3: 替换文件内容中的项目名...")
    modified_count_project1 = replace_flutter_content_project1(
        lib_dir_project1, 
        old_name_project1, 
        new_name_project1
    )
    print(f"✓ 共修改 {modified_count_project1} 个文件的内容\n")
    
    # 4. 重命名文件
    print("步骤 4: 重命名文件...")
    renamed_count_project1 = rename_flutter_files_project1(
        lib_dir_project1, 
        old_name_project1, 
        new_name_project1
    )
    print(f"✓ 共重命名 {renamed_count_project1} 个文件\n")
    
    # 5. 运行 flutter analyze
    print("步骤 5: 运行 flutter analyze 检查...")
    run_flutter_analyze_project1(project_dir_project1)
    
    print("\n" + "="*60)
    print("Flutter 项目重命名完成！")
    print("="*60)
    print(f"旧项目名: {old_name_project1}")
    print(f"新项目名: {new_name_project1}")
    print(f"修改文件内容: {modified_count_project1} 个")
    print(f"重命名文件: {renamed_count_project1} 个")
    
    return True


# ============================================================
# 主程序入口
# ============================================================

def main_project1():
    """
    主函数：自动检测项目类型并执行重命名流程
    """
    # 获取当前脚本所在目录（项目根目录）
    project_dir_project1 = os.path.dirname(os.path.abspath(__file__))
    
    print("="*60)
    print("项目重命名脚本 - 自动检测版本")
    print("="*60)
    print(f"项目目录: {project_dir_project1}\n")
    
    # 检测项目类型
    print("正在检测项目类型...")
    project_type_project1 = detect_project_type_project1(project_dir_project1)
    
    if project_type_project1 == 'swift':
        # 处理 Swift 项目
        success_project1 = process_swift_project_project1(project_dir_project1)
    elif project_type_project1 == 'flutter':
        # 处理 Flutter 项目
        success_project1 = process_flutter_project_project1(project_dir_project1)
    else:
        print("✗ 未能识别项目类型（不是 Swift 也不是 Flutter 项目）")
        print("提示：")
        print("  - Swift 项目应包含 .xcodeproj 文件夹")
        print("  - Flutter 项目应包含 pubspec.yaml 文件")
        return
    
    if not success_project1:
        print("\n✗ 重命名过程中出现错误")
    else:
        print("\n✓ 所有操作已完成")


if __name__ == '__main__':
    main_project1()
