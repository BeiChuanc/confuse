#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""在 Chrome 扩展与 App Tools 资料整理进程之间转发结构化消息。"""

import json as json_confuse
import os as os_confuse
import socket as socket_confuse
import struct as struct_confuse
import sys as sys_confuse
import threading as threading_confuse
import time as time_confuse


SOCKET_PATH_CONFUSE = os_confuse.path.join(
    "/private/tmp",
    f"com.apptools.confuse.material.{os_confuse.getuid()}.sock",
)
MAX_MESSAGE_SIZE_CONFUSE = 1024 * 1024
PENDING_SOCKETS_CONFUSE = {}
PENDING_LOCK_CONFUSE = threading_confuse.Lock()
OUTPUT_LOCK_CONFUSE = threading_confuse.Lock()


def read_exact_confuse(stream_confuse, length_confuse):
    """从二进制流读取指定长度的数据。

    参数：stream_confuse 为输入流，length_confuse 为需要读取的字节数。
    返回值：完整字节内容；输入结束时返回空值。
    异常：输入流读取异常由调用方处理。
    """
    data_confuse = bytearray()
    while len(data_confuse) < length_confuse:
        chunk_confuse = stream_confuse.read(length_confuse - len(data_confuse))
        if not chunk_confuse:
            return None
        data_confuse.extend(chunk_confuse)
    return bytes(data_confuse)


def read_native_message_confuse():
    """读取 Chrome 原生消息协议中的单条 JSON 消息。

    参数：无。
    返回值：解析后的字典；Chrome 关闭连接时返回空值。
    异常：消息尺寸或 JSON 格式无效时返回空值。
    """
    length_data_confuse = read_exact_confuse(sys_confuse.stdin.buffer, 4)
    if not length_data_confuse:
        return None
    length_confuse = struct_confuse.unpack("=I", length_data_confuse)[0]
    if length_confuse <= 0 or length_confuse > MAX_MESSAGE_SIZE_CONFUSE:
        return None
    payload_confuse = read_exact_confuse(sys_confuse.stdin.buffer, length_confuse)
    if not payload_confuse:
        return None
    try:
        return json_confuse.loads(payload_confuse.decode("utf-8"))
    except (UnicodeDecodeError, json_confuse.JSONDecodeError):
        return None


def write_native_message_confuse(message_confuse):
    """按 Chrome 原生消息协议写入一条 JSON 消息。

    参数：message_confuse 为需要发送给扩展的字典。
    返回值：写入成功时返回 true，连接不可写时返回 false。
    异常：输出错误会转换为 false。
    """
    payload_confuse = json_confuse.dumps(message_confuse, ensure_ascii=False).encode("utf-8")
    if len(payload_confuse) > MAX_MESSAGE_SIZE_CONFUSE:
        return False
    try:
        with OUTPUT_LOCK_CONFUSE:
            sys_confuse.stdout.buffer.write(struct_confuse.pack("=I", len(payload_confuse)))
            sys_confuse.stdout.buffer.write(payload_confuse)
            sys_confuse.stdout.buffer.flush()
        return True
    except (BrokenPipeError, OSError):
        return False


def receive_socket_line_confuse(connection_confuse):
    """从桌面进程套接字读取一行受限长度的 JSON。

    参数：connection_confuse 为已连接的本机套接字。
    返回值：解析后的任务字典；数据无效时返回空值。
    异常：套接字错误会转换为空值。
    """
    data_confuse = bytearray()
    try:
        connection_confuse.settimeout(10)
        while len(data_confuse) <= MAX_MESSAGE_SIZE_CONFUSE:
            chunk_confuse = connection_confuse.recv(4096)
            if not chunk_confuse:
                return None
            data_confuse.extend(chunk_confuse)
            if b"\n" in data_confuse:
                line_confuse = bytes(data_confuse).split(b"\n", 1)[0]
                return json_confuse.loads(line_confuse.decode("utf-8"))
    except (OSError, UnicodeDecodeError, json_confuse.JSONDecodeError):
        return None
    return None


def monitor_desktop_socket_confuse():
    """持续等待 App Tools 启动资料任务，并把任务发送给 Chrome 扩展。

    参数：无。
    返回值：无，随原生消息宿主进程结束。
    异常：连接失败会短暂等待后重试。
    """
    while True:
        with PENDING_LOCK_CONFUSE:
            has_pending_confuse = bool(PENDING_SOCKETS_CONFUSE)
        if has_pending_confuse:
            time_confuse.sleep(0.2)
            continue

        connection_confuse = socket_confuse.socket(socket_confuse.AF_UNIX, socket_confuse.SOCK_STREAM)
        try:
            connection_confuse.connect(SOCKET_PATH_CONFUSE)
            task_confuse = receive_socket_line_confuse(connection_confuse)
            if not isinstance(task_confuse, dict):
                connection_confuse.close()
                time_confuse.sleep(0.5)
                continue
            task_id_confuse = str(task_confuse.get("task_id_confuse", ""))
            if not task_id_confuse:
                connection_confuse.close()
                continue
            with PENDING_LOCK_CONFUSE:
                PENDING_SOCKETS_CONFUSE[task_id_confuse] = connection_confuse
            if not write_native_message_confuse(task_confuse):
                close_pending_socket_confuse(task_id_confuse)
                return
        except OSError:
            connection_confuse.close()
            time_confuse.sleep(0.5)


def close_pending_socket_confuse(task_id_confuse):
    """关闭并移除指定任务对应的桌面连接。

    参数：task_id_confuse 为任务唯一标识。
    返回值：无。
    异常：关闭失败会被忽略。
    """
    with PENDING_LOCK_CONFUSE:
        connection_confuse = PENDING_SOCKETS_CONFUSE.pop(task_id_confuse, None)
    if connection_confuse:
        try:
            connection_confuse.close()
        except OSError:
            pass


def forward_extension_message_confuse(message_confuse):
    """把扩展进度或结果转发给发起任务的桌面进程。

    参数：message_confuse 为 Chrome 扩展返回的事件字典。
    返回值：找到对应任务并成功发送时返回 true。
    异常：套接字错误会关闭当前任务并返回 false。
    """
    task_id_confuse = str(message_confuse.get("task_id_confuse", ""))
    with PENDING_LOCK_CONFUSE:
        connection_confuse = PENDING_SOCKETS_CONFUSE.get(task_id_confuse)
    if not connection_confuse:
        return False
    try:
        payload_confuse = json_confuse.dumps(message_confuse, ensure_ascii=False).encode("utf-8") + b"\n"
        connection_confuse.sendall(payload_confuse)
    except OSError:
        close_pending_socket_confuse(task_id_confuse)
        return False
    if message_confuse.get("event_confuse") == "result":
        close_pending_socket_confuse(task_id_confuse)
    return True


def main_confuse():
    """启动桌面套接字监听线程，并持续处理 Chrome 扩展消息。

    参数：无。
    返回值：Chrome 关闭原生消息连接时结束。
    异常：无效消息会被忽略。
    """
    monitor_thread_confuse = threading_confuse.Thread(
        target=monitor_desktop_socket_confuse,
        daemon=True,
        name="资料整理套接字监听_confuse",
    )
    monitor_thread_confuse.start()
    while True:
        message_confuse = read_native_message_confuse()
        if message_confuse is None:
            break
        if isinstance(message_confuse, dict):
            forward_extension_message_confuse(message_confuse)


if __name__ == "__main__":
    main_confuse()
