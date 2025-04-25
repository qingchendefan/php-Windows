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
    
    # 创建主窗口
    window = TranslatorWindow()
    window.show()
    
    # 运行应用
    sys.exit(app.exec())

if __name__ == '__main__':
    main() 