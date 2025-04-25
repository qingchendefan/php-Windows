#!/bin/bash

# 检查是否安装了 Homebrew
if ! command -v brew &> /dev/null; then
    echo "正在安装 Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# 检查是否安装了 Python
if ! command -v python3 &> /dev/null; then
    echo "正在安装 Python..."
    brew install python
fi

# 检查是否安装了 pip
if ! command -v pip3 &> /dev/null; then
    echo "正在安装 pip..."
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    python3 get-pip.py
    rm get-pip.py
fi

# 安装 PyQt6
echo "正在安装 PyQt6..."
pip3 install PyQt6

# 安装其他依赖
echo "正在安装其他依赖..."
pip3 install -r requirements.txt

echo "安装完成！现在你可以运行 OpenTranslator 了。"
echo "使用方法："
echo "1. 双击 OpenTranslator.app 运行"
echo "2. 如果遇到安全警告，请右键点击应用程序，选择'打开'" 