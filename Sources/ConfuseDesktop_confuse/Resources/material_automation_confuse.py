#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""通过本机套接字请求 Chrome 扩展读取飞书项目资料。"""

import argparse as argparse_confuse
import json as json_confuse
import os as os_confuse
import signal as signal_confuse
import socket as socket_confuse
import subprocess as subprocess_confuse
import sys as sys_confuse
import time as time_confuse
import uuid as uuid_confuse


SOCKET_PATH_CONFUSE = os_confuse.path.join(
    "/private/tmp",
    f"com.apptools.confuse.material.{os_confuse.getuid()}.sock",
)
MAX_MESSAGE_SIZE_CONFUSE = 1024 * 1024
SERVER_SOCKET_CONFUSE = None
CLIENT_SOCKET_CONFUSE = None


class MaterialAutomationFailure_confuse(Exception):
    """表示 Chrome 扩展连接、飞书查找或字段读取出现可恢复错误。"""


def emit_event_confuse(event_confuse):
    """向桌面应用输出一条 JSON 事件。

    参数：event_confuse 为可 JSON 序列化的事件字典。
    返回值：无。
    异常：标准输出不可写时由 Python 运行时处理。
    """
    print(json_confuse.dumps(event_confuse, ensure_ascii=False), flush=True)


def emit_progress_confuse(state_confuse, message_confuse, progress_confuse):
    """向桌面应用输出当前阶段和进度。

    参数：state_confuse 为状态，message_confuse 为中文说明，progress_confuse 为零到一进度。
    返回值：无。
    异常：标准输出不可写时由 Python 运行时处理。
    """
    emit_event_confuse({
        "event_confuse": "progress",
        "state_confuse": state_confuse,
        "message_confuse": message_confuse,
        "progress_confuse": progress_confuse,
    })


def ensure_chrome_running_confuse():
    """确认 Google Chrome 已运行，避免无意义等待扩展连接。

    参数：无。
    返回值：无。
    异常：Chrome 未运行时抛出资料整理错误。
    """
    result_confuse = subprocess_confuse.run(
        ["/usr/bin/pgrep", "-x", "Google Chrome"],
        stdout=subprocess_confuse.DEVNULL,
        stderr=subprocess_confuse.DEVNULL,
        check=False,
    )
    if result_confuse.returncode != 0:
        raise MaterialAutomationFailure_confuse(
            "Google Chrome 尚未运行，请先打开 Chrome 并确认 App Tools 浏览器助手已启用。"
        )


def remove_socket_file_confuse():
    """删除当前任务创建的 Unix 套接字文件。

    参数：无。
    返回值：无。
    异常：文件不存在或删除失败时忽略。
    """
    try:
        if os_confuse.path.exists(SOCKET_PATH_CONFUSE):
            os_confuse.remove(SOCKET_PATH_CONFUSE)
    except OSError:
        pass


def close_sockets_confuse():
    """关闭当前服务端和扩展连接，并清理套接字路径。

    参数：无。
    返回值：无。
    异常：关闭失败时忽略。
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
    """从扩展桥接连接读取一条受限长度的 JSON 消息。

    参数：connection_confuse 为套接字，buffer_confuse 为尚未解析的数据缓冲区。
    返回值：消息字典和剩余缓冲区。
    异常：连接中断、消息过大或 JSON 无效时抛出资料整理错误。
    """
    while b"\n" not in buffer_confuse:
        try:
            chunk_confuse = connection_confuse.recv(4096)
        except socket_confuse.timeout as error_confuse:
            raise MaterialAutomationFailure_confuse(
                "等待 Chrome 扩展返回资料超时，请确认飞书页面可以正常访问。"
            ) from error_confuse
        if not chunk_confuse:
            raise MaterialAutomationFailure_confuse("Chrome 扩展连接已断开，请重新开始整理。")
        buffer_confuse += chunk_confuse
        if len(buffer_confuse) > MAX_MESSAGE_SIZE_CONFUSE:
            raise MaterialAutomationFailure_confuse("Chrome 扩展返回的数据超过允许大小。")
    line_confuse, remaining_confuse = buffer_confuse.split(b"\n", 1)
    try:
        message_confuse = json_confuse.loads(line_confuse.decode("utf-8"))
    except (UnicodeDecodeError, json_confuse.JSONDecodeError) as error_confuse:
        raise MaterialAutomationFailure_confuse("Chrome 扩展返回了无效数据。") from error_confuse
    if not isinstance(message_confuse, dict):
        raise MaterialAutomationFailure_confuse("Chrome 扩展返回了未知数据格式。")
    return message_confuse, remaining_confuse


def run_extension_task_confuse(ui_number_confuse):
    """建立本机通信服务，等待已安装扩展读取指定项目。

    参数：ui_number_confuse 为飞书表格中的完整 UI 编号。
    返回值：无，扩展进度和结果直接转发至标准输出。
    异常：扩展未连接、返回超时或自动化失败时抛出错误。
    """
    global SERVER_SOCKET_CONFUSE, CLIENT_SOCKET_CONFUSE
    ensure_chrome_running_confuse()
    remove_socket_file_confuse()
    SERVER_SOCKET_CONFUSE = socket_confuse.socket(socket_confuse.AF_UNIX, socket_confuse.SOCK_STREAM)
    try:
        SERVER_SOCKET_CONFUSE.bind(SOCKET_PATH_CONFUSE)
        os_confuse.chmod(SOCKET_PATH_CONFUSE, 0o600)
        SERVER_SOCKET_CONFUSE.listen(1)
        SERVER_SOCKET_CONFUSE.settimeout(60)
    except OSError as error_confuse:
        raise MaterialAutomationFailure_confuse("无法创建 Chrome 扩展本机通信通道。") from error_confuse

    emit_progress_confuse(
        "waiting_extension",
        "正在等待 Chrome 中的 App Tools 浏览器助手连接。",
        0.12,
    )
    try:
        CLIENT_SOCKET_CONFUSE, _address_confuse = SERVER_SOCKET_CONFUSE.accept()
    except socket_confuse.timeout as error_confuse:
        raise MaterialAutomationFailure_confuse(
            "Chrome 扩展未连接。请先点击“准备扩展”，在 chrome://extensions 加载并启用 App Tools 浏览器助手。"
        ) from error_confuse

    task_id_confuse = uuid_confuse.uuid4().hex
    request_confuse = {
        "command_confuse": "read_material_confuse",
        "task_id_confuse": task_id_confuse,
        "uiNumber_confuse": ui_number_confuse,
    }
    CLIENT_SOCKET_CONFUSE.sendall(
        json_confuse.dumps(request_confuse, ensure_ascii=False).encode("utf-8") + b"\n"
    )
    CLIENT_SOCKET_CONFUSE.settimeout(240)
    emit_progress_confuse("running", "Chrome 扩展已连接，正在处理资料。", 0.18)

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
    """收到桌面应用停止信号时关闭本机通信通道。

    参数：两个参数由系统信号回调提供，不参与业务处理。
    返回值：无。
    异常：清理完成后以状态码 130 结束进程。
    """
    close_sockets_confuse()
    raise SystemExit(130)


def main_confuse():
    """读取桌面请求并交由 Chrome 扩展完成飞书资料整理。

    参数：通过命令行 --request 接收请求 JSON 路径。
    返回值：无。
    异常：请求无效或扩展任务失败时抛出资料整理错误。
    """
    parser_confuse = argparse_confuse.ArgumentParser(description="飞书资料整理")
    parser_confuse.add_argument("--request", required=True, help="请求 JSON 文件路径")
    arguments_confuse = parser_confuse.parse_args()
    with open(arguments_confuse.request, "r", encoding="utf-8") as file_confuse:
        request_confuse = json_confuse.load(file_confuse)
    ui_number_confuse = str(request_confuse.get("uiNumber_confuse", "")).strip()
    if not ui_number_confuse:
        raise MaterialAutomationFailure_confuse("资料整理请求缺少项目 UI 编号。")
    run_extension_task_confuse(ui_number_confuse)


if __name__ == "__main__":
    signal_confuse.signal(signal_confuse.SIGTERM, handle_termination_confuse)
    try:
        main_confuse()
    except MaterialAutomationFailure_confuse as error_confuse:
        message_confuse = str(error_confuse) or "资料整理失败。"
        emit_event_confuse({
            "event_confuse": "error",
            "state_confuse": "failed",
            "message_confuse": message_confuse,
            "progress_confuse": 0,
            "ok_confuse": False,
            "error_confuse": message_confuse,
        })
        emit_event_confuse({
            "event_confuse": "result",
            "state_confuse": "failed",
            "message_confuse": message_confuse,
            "progress_confuse": 0,
            "ok_confuse": False,
            "error_confuse": message_confuse,
        })
        raise SystemExit(1)
    finally:
        close_sockets_confuse()
