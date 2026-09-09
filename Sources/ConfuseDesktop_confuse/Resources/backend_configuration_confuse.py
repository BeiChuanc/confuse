#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""通过本机套接字请求当前 Chrome 读取苹果马甲包后台配置。"""

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


class BackendConfigurationFailure_confuse(Exception):
    """表示浏览器助手连接、后台登录、项目搜索或字段读取失败。"""


def emit_event_confuse(event_confuse):
    """向桌面应用输出一条 JSON 事件。

    参数：event_confuse 为可序列化的事件字典。
    返回值：无。
    异常：标准输出不可写时由 Python 运行时处理。
    """
    print(json_confuse.dumps(event_confuse, ensure_ascii=False), flush=True)


def emit_progress_confuse(message_confuse, progress_confuse):
    """向桌面应用输出当前阶段和进度。

    参数：message_confuse 为中文说明，progress_confuse 为零到一进度。
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
    异常：Chrome 未运行时抛出后台配置错误。
    """
    result_confuse = subprocess_confuse.run(
        ["/usr/bin/pgrep", "-x", "Google Chrome"],
        stdout=subprocess_confuse.DEVNULL,
        stderr=subprocess_confuse.DEVNULL,
        check=False,
    )
    if result_confuse.returncode != 0:
        raise BackendConfigurationFailure_confuse(
            "Google Chrome 尚未运行，请先打开 Chrome 并启用 App Tools 浏览器助手。"
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
    """从浏览器助手连接读取一条受限长度的 JSON 消息。

    参数：connection_confuse 为套接字，buffer_confuse 为未解析字节。
    返回值：消息字典和剩余缓冲区。
    异常：连接中断、超时、消息过大或 JSON 无效时抛出后台配置错误。
    """
    while b"\n" not in buffer_confuse:
        try:
            chunk_confuse = connection_confuse.recv(4096)
        except socket_confuse.timeout as error_confuse:
            raise BackendConfigurationFailure_confuse(
                "等待 Chrome 返回后台配置超时，请检查后台页面和登录状态。"
            ) from error_confuse
        if not chunk_confuse:
            raise BackendConfigurationFailure_confuse("Chrome 浏览器助手连接已断开，请重新获取配置。")
        buffer_confuse += chunk_confuse
        if len(buffer_confuse) > MAX_MESSAGE_SIZE_CONFUSE:
            raise BackendConfigurationFailure_confuse("Chrome 返回的后台配置超过允许大小。")
    line_confuse, remaining_confuse = buffer_confuse.split(b"\n", 1)
    try:
        message_confuse = json_confuse.loads(line_confuse.decode("utf-8"))
    except (UnicodeDecodeError, json_confuse.JSONDecodeError) as error_confuse:
        raise BackendConfigurationFailure_confuse("Chrome 返回了无效的后台配置数据。") from error_confuse
    if not isinstance(message_confuse, dict):
        raise BackendConfigurationFailure_confuse("Chrome 返回了未知的后台配置格式。")
    return message_confuse, remaining_confuse


def run_extension_task_confuse(request_confuse):
    """建立本机通信服务并将后台读取任务发送给浏览器助手。

    参数：request_confuse 为包含登录凭据和 Bundle ID 的请求字典。
    返回值：无，浏览器进度和最终结果直接转发至标准输出。
    异常：浏览器助手未连接、返回超时或自动化失败时抛出后台配置错误。
    """
    global SERVER_SOCKET_CONFUSE, CLIENT_SOCKET_CONFUSE
    ensure_chrome_running_confuse()
    remove_socket_file_confuse()
    SERVER_SOCKET_CONFUSE = socket_confuse.socket(socket_confuse.AF_UNIX, socket_confuse.SOCK_STREAM)
    try:
        SERVER_SOCKET_CONFUSE.bind(SOCKET_PATH_CONFUSE)
        os_confuse.chmod(SOCKET_PATH_CONFUSE, 0o600)
        SERVER_SOCKET_CONFUSE.listen(1)
        SERVER_SOCKET_CONFUSE.settimeout(180)
    except OSError as error_confuse:
        raise BackendConfigurationFailure_confuse("无法创建 Chrome 浏览器助手通信通道。") from error_confuse

    emit_progress_confuse("正在等待 Chrome 中的 App Tools 浏览器助手连接。", 0.08)
    try:
        CLIENT_SOCKET_CONFUSE, _address_confuse = SERVER_SOCKET_CONFUSE.accept()
    except socket_confuse.timeout as error_confuse:
        raise BackendConfigurationFailure_confuse(
            "Chrome 浏览器助手未连接，请先更新扩展并在 chrome://extensions 中重新加载。"
        ) from error_confuse

    task_id_confuse = uuid_confuse.uuid4().hex
    task_confuse = {
        "command_confuse": "read_backend_configuration_confuse",
        "task_id_confuse": task_id_confuse,
        "account_confuse": request_confuse["account_confuse"],
        "password_confuse": request_confuse["password_confuse"],
        "twoFactorCode_confuse": request_confuse["twoFactorCode_confuse"],
        "bundleID_confuse": request_confuse["bundleID_confuse"],
    }
    CLIENT_SOCKET_CONFUSE.sendall(
        json_confuse.dumps(task_confuse, ensure_ascii=False).encode("utf-8") + b"\n"
    )
    # 后台列表、域名配置和配置表都可能等待接口返回，统一预留十分钟。
    CLIENT_SOCKET_CONFUSE.settimeout(600)
    emit_progress_confuse("浏览器助手已连接，正在获取后台配置。", 0.12)

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
    异常：清理完成后以状态码 130 结束进程。
    """
    close_sockets_confuse()
    raise SystemExit(130)


def main_confuse():
    """读取桌面请求并交由当前 Chrome 获取后台配置。

    参数：通过命令行 --request 接收请求 JSON 路径。
    返回值：无。
    异常：字段缺失或浏览器任务失败时抛出后台配置错误。
    """
    parser_confuse = argparse_confuse.ArgumentParser(description="后台配置读取")
    parser_confuse.add_argument("--request", required=True, help="请求 JSON 文件路径")
    arguments_confuse = parser_confuse.parse_args()
    with open(arguments_confuse.request, "r", encoding="utf-8") as file_confuse:
        request_confuse = json_confuse.load(file_confuse)
    required_keys_confuse = [
        "account_confuse",
        "password_confuse",
        "twoFactorCode_confuse",
        "bundleID_confuse",
    ]
    if any(not str(request_confuse.get(key_confuse, "")).strip() for key_confuse in required_keys_confuse):
        raise BackendConfigurationFailure_confuse("后台配置请求缺少账号、密码、2FA 或 Bundle ID。")
    run_extension_task_confuse(request_confuse)


if __name__ == "__main__":
    signal_confuse.signal(signal_confuse.SIGTERM, handle_termination_confuse)
    try:
        main_confuse()
    except BackendConfigurationFailure_confuse as error_confuse:
        message_confuse = str(error_confuse) or "后台配置获取失败。"
        for event_name_confuse in ("error", "result"):
            emit_event_confuse({
                "event_confuse": event_name_confuse,
                "state_confuse": "failed",
                "message_confuse": message_confuse,
                "progress_confuse": 0,
                "ok_confuse": False,
                "error_confuse": message_confuse,
            })
        raise SystemExit(1)
    finally:
        close_sockets_confuse()
