#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""通过本机消息桥接请求当前 Chrome 生成三类应用协议。"""

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


class AgreementAutomationFailure_confuse(Exception):
    """表示浏览器助手连接、协议页面或协议生成流程出现可恢复错误。"""


def emit_event_confuse(event_confuse):
    """向桌面应用输出一条 JSON 事件。

    参数：event_confuse 为可 JSON 序列化的事件字典。
    返回值：无。
    异常：标准输出不可写时由 Python 运行时处理。
    """
    print(json_confuse.dumps(event_confuse, ensure_ascii=False), flush=True)


def ensure_chrome_running_confuse():
    """确认当前用户已经运行 Google Chrome。

    参数：无。
    返回值：无。
    异常：Chrome 未运行时抛出协议自动化错误。
    """
    result_confuse = subprocess_confuse.run(
        ["/usr/bin/pgrep", "-x", "Google Chrome"],
        stdout=subprocess_confuse.DEVNULL,
        stderr=subprocess_confuse.DEVNULL,
        check=False,
    )
    if result_confuse.returncode != 0:
        raise AgreementAutomationFailure_confuse(
            "Google Chrome 尚未运行，请先打开当前 Chrome 并确认 App Tools 浏览器助手已启用。"
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
    """关闭协议任务的服务端和浏览器助手连接。

    参数：无。
    返回值：无。
    异常：关闭失败时忽略并继续清理套接字文件。
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

    参数：connection_confuse 为套接字连接，buffer_confuse 为尚未解析的数据。
    返回值：包含消息字典和剩余缓冲区的元组。
    异常：连接中断、返回超时、消息过大或 JSON 无效时抛出协议自动化错误。
    """
    while b"\n" not in buffer_confuse:
        try:
            chunk_confuse = connection_confuse.recv(4096)
        except socket_confuse.timeout as error_confuse:
            raise AgreementAutomationFailure_confuse(
                "等待 Chrome 返回协议结果超时，请检查协议生成页面。"
            ) from error_confuse
        if not chunk_confuse:
            raise AgreementAutomationFailure_confuse("Chrome 浏览器助手连接已断开，请重新生成协议。")
        buffer_confuse += chunk_confuse
        if len(buffer_confuse) > MAX_MESSAGE_SIZE_CONFUSE:
            raise AgreementAutomationFailure_confuse("Chrome 返回的协议结果超过允许大小。")
    line_confuse, remaining_confuse = buffer_confuse.split(b"\n", 1)
    try:
        message_confuse = json_confuse.loads(line_confuse.decode("utf-8"))
    except (UnicodeDecodeError, json_confuse.JSONDecodeError) as error_confuse:
        raise AgreementAutomationFailure_confuse("Chrome 浏览器助手返回了无效数据。") from error_confuse
    if not isinstance(message_confuse, dict):
        raise AgreementAutomationFailure_confuse("Chrome 浏览器助手返回了未知数据格式。")
    return message_confuse, remaining_confuse


def run_extension_task_confuse(request_confuse):
    """建立本机通信服务并请求当前 Chrome 顺序生成协议。

    参数：request_confuse 为经过校验的应用名称、邮箱和协议类型字典。
    返回值：无，扩展进度和最终链接直接转发至标准输出。
    异常：浏览器助手未连接、任务超时或协议生成失败时抛出协议自动化错误。
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
        raise AgreementAutomationFailure_confuse("无法创建 Chrome 浏览器助手本机通信通道。") from error_confuse

    emit_event_confuse({
        "event_confuse": "status",
        "state_confuse": "waiting_extension",
        "message_confuse": "正在等待当前 Chrome 中的 App Tools 浏览器助手连接。",
    })
    try:
        CLIENT_SOCKET_CONFUSE, _address_confuse = SERVER_SOCKET_CONFUSE.accept()
    except socket_confuse.timeout as error_confuse:
        raise AgreementAutomationFailure_confuse(
            "Chrome 浏览器助手未连接。请先在整理资料页面准备扩展，并在 chrome://extensions 中加载或重新加载。"
        ) from error_confuse

    task_id_confuse = uuid_confuse.uuid4().hex
    task_confuse = {
        "command_confuse": "generate_agreements_confuse",
        "task_id_confuse": task_id_confuse,
        "appName_confuse": request_confuse["appName_confuse"],
        "email_confuse": request_confuse["email_confuse"],
        "agreementTypes_confuse": request_confuse["agreementTypes_confuse"],
    }
    CLIENT_SOCKET_CONFUSE.sendall(
        json_confuse.dumps(task_confuse, ensure_ascii=False).encode("utf-8") + b"\n"
    )
    CLIENT_SOCKET_CONFUSE.settimeout(900)

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
    """读取桌面请求并交由当前 Chrome 中的浏览器助手生成协议。

    参数：通过命令行 --request 接收请求 JSON 路径。
    返回值：无。
    异常：请求缺少应用名称、邮箱或协议类型时抛出协议自动化错误。
    """
    parser_confuse = argparse_confuse.ArgumentParser(description="协议自动化")
    parser_confuse.add_argument("--request", required=True, help="请求 JSON 文件路径")
    arguments_confuse = parser_confuse.parse_args()
    with open(arguments_confuse.request, "r", encoding="utf-8") as file_confuse:
        request_confuse = json_confuse.load(file_confuse)
    app_name_confuse = str(request_confuse.get("appName_confuse", "")).strip()
    email_confuse = str(request_confuse.get("email_confuse", "")).strip()
    requested_types_confuse = request_confuse.get("agreementTypes_confuse", [])
    valid_types_confuse = ["privacy", "terms", "eula"]
    agreement_types_confuse = [
        value_confuse for value_confuse in requested_types_confuse
        if value_confuse in valid_types_confuse
    ]
    if not app_name_confuse or not email_confuse or not agreement_types_confuse:
        raise AgreementAutomationFailure_confuse("协议请求缺少应用名称、邮箱或协议类型。")
    run_extension_task_confuse({
        "appName_confuse": app_name_confuse,
        "email_confuse": email_confuse,
        "agreementTypes_confuse": agreement_types_confuse,
    })


if __name__ == "__main__":
    signal_confuse.signal(signal_confuse.SIGTERM, handle_termination_confuse)
    try:
        main_confuse()
    except AgreementAutomationFailure_confuse as error_confuse:
        message_confuse = str(error_confuse) or "协议生成失败。"
        emit_event_confuse({
            "event_confuse": "error",
            "state_confuse": "failed",
            "message_confuse": message_confuse,
            "ok_confuse": False,
            "links_confuse": {},
            "error_confuse": message_confuse,
        })
        emit_event_confuse({
            "event_confuse": "result",
            "state_confuse": "failed",
            "message_confuse": message_confuse,
            "ok_confuse": False,
            "links_confuse": {},
            "error_confuse": message_confuse,
        })
        raise SystemExit(1)
    finally:
        close_sockets_confuse()
