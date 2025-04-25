#!/usr/bin/env python3
import sys
import os
from PyQt6.QtWidgets import QApplication
from PyQt6.QtNetwork import QLocalServer, QLocalSocket
from translator import TranslatorWindow

def is_running():
    """检查程序是否已经在运行"""
    socket = QLocalSocket()
    socket.connectToServer("OpenTranslatorApp")
    is_running = socket.waitForConnected(500)
    if is_running:
        socket.disconnectFromServer()
    return is_running

def main():
    # 创建应用实例
    app = QApplication(sys.argv)
    
    # 检查是否已经有实例在运行
    if is_running():
        print("程序已经在运行中")
        return
    
    # 创建并启动本地服务器
    server = QLocalServer()
    server.removeServer("OpenTranslatorApp")  # 移除可能存在的旧服务器
    server.listen("OpenTranslatorApp")
    
    # 创建主窗口
    window = TranslatorWindow()
    window.show()
    
    # 当收到新的连接请求时，显示已存在的窗口
    def new_connection():
        window.show()
        window.raise_()
        window.activateWindow()
        if window.is_hidden:
            window.show_window()
    
    server.newConnection.connect(new_connection)
    
    # 运行应用
    sys.exit(app.exec())

if __name__ == '__main__':
    main() 