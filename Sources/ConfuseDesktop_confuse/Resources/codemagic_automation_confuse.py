#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""通过本机套接字请求当前 Chrome 完成 Codemagic 签名配置。"""

import argparse as argparse_confuse
import json as json_confuse
import os as os_confuse
import signal as signal_confuse
import socket as socket_confuse
import subprocess as subprocess_confuse
import sys as sys_confuse
import uuid as uuid_confuse


SOCKET_PATH_CONFUSE = os_confuse.path.join(
    "/private/tmp",
    f"com.apptools.confuse.material.{os_confuse.getuid()}.sock",
)
MAX_MESSAGE_SIZE_CONFUSE = 1024 * 1024
SERVER_SOCKET_CONFUSE = None
CLIENT_SOCKET_CONFUSE = None


class CodeMagicAutomationFailure_confuse(Exception):
    """表示浏览器助手连接或 Codemagic 页面自动化失败。"""


def emit_event_confuse(event_confuse):
    """向桌面应用输出一条 JSON 事件。

    参数：event_confuse 为可序列化的事件字典。
    返回值：无。
    异常：标准输出不可写时由 Python 运行时处理。
    """
    print(json_confuse.dumps(event_confuse, ensure_ascii=False), flush=True)


def emit_progress_confuse(message_confuse, progress_confuse):
    """向桌面应用输出当前阶段和进度。

    参数：message_confuse 为中文页面说明，progress_confuse 为零到一进度。
    返回值：无。
    异常：标准输出不可写时由 Python 运行时处理。
    """
    emit_event_confuse({
        "event_confuse": "progress",
        "state_confuse": "running",
        "message_confuse": message_confuse,
        "progress_confuse": progress_confuse,
    })


def ensure_chrome_running_confuse():
    """确认 Google Chrome 已运行。

    参数：无。
    返回值：无。
    异常：Chrome 未运行时抛出自动化错误。
    """
    result_confuse = subprocess_confuse.run(
        ["/usr/bin/pgrep", "-x", "Google Chrome"],
        stdout=subprocess_confuse.DEVNULL,
        stderr=subprocess_confuse.DEVNULL,
        check=False,
    )
    if result_confuse.returncode != 0:
        raise CodeMagicAutomationFailure_confuse(
            "Google Chrome 尚未运行，请打开 Chrome 并启用 App Tools 浏览器助手。"
        )


def remove_socket_file_confuse():
    """删除当前任务创建的 Unix 套接字文件。

    参数：无。
    返回值：无。
    异常：路径不存在或删除失败时忽略。
    """
    try:
        if os_confuse.path.exists(SOCKET_PATH_CONFUSE):
            os_confuse.remove(SOCKET_PATH_CONFUSE)
    except OSError:
        pass


def close_sockets_confuse():
    """关闭服务端和浏览器助手连接并清理套接字路径。

    参数：无。
    返回值：无。
    异常：连接关闭失败时忽略。
    """
    global SERVER_SOCKET_CONFUSE, CLIENT_SOCKET_CONFUSE
    for connection_confuse in (CLIENT_SOCKET_CONFUSE, SERVER_SOCKET_CONFUSE):
        if connection_confuse:
            try:
                connection_confuse.close()
            except OSError:
                pass
    CLIENT_SOCKET_CONFUSE = None
    SERVER_SOCKET_CONFUSE = None
    remove_socket_file_confuse()


def receive_line_confuse(connection_confuse, buffer_confuse):
    """从浏览器助手读取一条受限长度的 JSON 消息。

    参数：connection_confuse 为套接字，buffer_confuse 为未解析字节。
    返回值：消息字典和剩余缓冲区。
    异常：连接中断、超时、消息过大或 JSON 无效时抛出自动化错误。
    """
    while b"\n" not in buffer_confuse:
        try:
            chunk_confuse = connection_confuse.recv(4096)
        except socket_confuse.timeout as error_confuse:
            raise CodeMagicAutomationFailure_confuse(
                "等待 Codemagic 返回结果超时，请检查当前 Chrome 标签页。"
            ) from error_confuse
        if not chunk_confuse:
            raise CodeMagicAutomationFailure_confuse(
                "App Tools 浏览器助手连接已断开，请重新执行任务。"
            )
        buffer_confuse += chunk_confuse
        if len(buffer_confuse) > MAX_MESSAGE_SIZE_CONFUSE:
            raise CodeMagicAutomationFailure_confuse("浏览器返回的数据超过允许大小。")
    line_confuse, remaining_confuse = buffer_confuse.split(b"\n", 1)
    try:
        message_confuse = json_confuse.loads(line_confuse.decode("utf-8"))
    except (UnicodeDecodeError, json_confuse.JSONDecodeError) as error_confuse:
        raise CodeMagicAutomationFailure_confuse("浏览器返回了无效数据。") from error_confuse
    if not isinstance(message_confuse, dict):
        raise CodeMagicAutomationFailure_confuse("浏览器返回了未知数据格式。")
    return message_confuse, remaining_confuse


def validate_request_confuse(request_confuse):
    """校验桌面应用提交的项目、Profile 字段和 API 文件。

    参数：request_confuse 为请求字典。
    返回值：校验通过的步骤列表。
    异常：字段缺失或 API 文件无效时抛出自动化错误。
    """
    required_confuse = ["projectName_confuse", "issuerID_confuse", "keyID_confuse"]
    if any(not str(request_confuse.get(key_confuse, "")).strip() for key_confuse in required_confuse):
        raise CodeMagicAutomationFailure_confuse("缺少项目名称、Issuer ID 或 Key ID。")
    steps_confuse = request_confuse.get("steps_confuse", [])
    allowed_confuse = {"api_key", "certificate", "profile"}
    if not isinstance(steps_confuse, list) or not steps_confuse:
        raise CodeMagicAutomationFailure_confuse("请至少选择一个 Codemagic 执行步骤。")
    if any(step_confuse not in allowed_confuse for step_confuse in steps_confuse):
        raise CodeMagicAutomationFailure_confuse("请求中包含不支持的 Codemagic 步骤。")
    if "api_key" in steps_confuse:
        api_path_confuse = str(request_confuse.get("apiKeyPath_confuse", ""))
        if not os_confuse.path.isfile(api_path_confuse) or not api_path_confuse.lower().endswith(".p8"):
            raise CodeMagicAutomationFailure_confuse("请选择有效的 .p8 API 密钥文件。")
    return steps_confuse


def run_extension_task_confuse(request_confuse):
    """建立本机通信服务并把 Codemagic 任务发送给浏览器助手。

    参数：request_confuse 为完整自动化请求字典。
    返回值：无，浏览器进度和结果直接转发到标准输出。
    异常：连接、页面自动化或任务返回失败时抛出错误。
    """
    global SERVER_SOCKET_CONFUSE, CLIENT_SOCKET_CONFUSE
    validate_request_confuse(request_confuse)
    ensure_chrome_running_confuse()
    remove_socket_file_confuse()
    SERVER_SOCKET_CONFUSE = socket_confuse.socket(socket_confuse.AF_UNIX, socket_confuse.SOCK_STREAM)
    try:
        SERVER_SOCKET_CONFUSE.bind(SOCKET_PATH_CONFUSE)
        os_confuse.chmod(SOCKET_PATH_CONFUSE, 0o600)
        SERVER_SOCKET_CONFUSE.listen(1)
        SERVER_SOCKET_CONFUSE.settimeout(180)
    except OSError as error_confuse:
        raise CodeMagicAutomationFailure_confuse(
            "无法创建浏览器助手通信通道。"
        ) from error_confuse

    emit_progress_confuse("正在等待 Chrome 中的 App Tools 浏览器助手连接。", 0.05)
    try:
        CLIENT_SOCKET_CONFUSE, _address_confuse = SERVER_SOCKET_CONFUSE.accept()
    except socket_confuse.timeout as error_confuse:
        raise CodeMagicAutomationFailure_confuse(
            "浏览器助手未连接，请在 chrome://extensions 中重新加载。"
        ) from error_confuse

    task_id_confuse = uuid_confuse.uuid4().hex
    task_confuse = dict(request_confuse)
    task_confuse["command_confuse"] = "configure_codemagic_confuse"
    task_confuse["task_id_confuse"] = task_id_confuse
    CLIENT_SOCKET_CONFUSE.sendall(
        json_confuse.dumps(task_confuse, ensure_ascii=False).encode("utf-8") + b"\n"
    )
    CLIENT_SOCKET_CONFUSE.settimeout(1200)
    emit_progress_confuse("浏览器助手已连接，正在打开 Codemagic。", 0.10)

    buffer_confuse = b""
    while True:
        event_confuse, buffer_confuse = receive_line_confuse(CLIENT_SOCKET_CONFUSE, buffer_confuse)
        if str(event_confuse.get("task_id_confuse", "")) != task_id_confuse:
            continue
        event_confuse.pop("task_id_confuse", None)
        emit_event_confuse(event_confuse)
        if event_confuse.get("event_confuse") == "result":
            if event_confuse.get("ok_confuse") is True:
                return
            raise SystemExit(1)


def handle_termination_confuse(_signal_confuse, _frame_confuse):
    """收到桌面应用停止信号时关闭通信通道。

    参数：两个参数由系统信号回调提供。
    返回值：无。
    异常：清理后以状态码 130 结束。
    """
    close_sockets_confuse()
    raise SystemExit(130)


def main_confuse():
    """读取桌面请求并执行 Codemagic 浏览器自动化。

    参数：通过命令行 --request 接收请求 JSON 路径。
    返回值：无。
    异常：请求或自动化失败时输出结构化错误并返回非零状态。
    """
    parser_confuse = argparse_confuse.ArgumentParser(description="Codemagic 浏览器自动化")
    parser_confuse.add_argument("--request", required=True, help="请求 JSON 文件路径")
    arguments_confuse = parser_confuse.parse_args()
    with open(arguments_confuse.request, "r", encoding="utf-8") as file_confuse:
        request_confuse = json_confuse.load(file_confuse)
    run_extension_task_confuse(request_confuse)


if __name__ == "__main__":
    signal_confuse.signal(signal_confuse.SIGTERM, handle_termination_confuse)
    signal_confuse.signal(signal_confuse.SIGINT, handle_termination_confuse)
    try:
        main_confuse()
    except CodeMagicAutomationFailure_confuse as error_confuse:
        emit_event_confuse({
            "event_confuse": "error",
            "state_confuse": "failed",
            "message_confuse": str(error_confuse),
            "progress_confuse": 0,
            "ok_confuse": False,
            "error_confuse": str(error_confuse),
        })
        raise SystemExit(1)
    finally:
        close_sockets_confuse()
