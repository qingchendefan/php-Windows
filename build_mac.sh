#!/bin/bash

echo "========================================"
echo "OpenTranslator macOS 打包工具"
echo "========================================"
echo

# 检查 Python 环境
if ! command -v python3 &> /dev/null; then
    echo "错误: 未找到 Python3，请先安装 Python3"
    exit 1
fi

# 检查 pip
if ! command -v pip3 &> /dev/null; then
    echo "错误: 未找到 pip3，请先安装 pip3"
    exit 1
fi

# 检查 PyInstaller
if ! pip3 show pyinstaller &> /dev/null; then
    echo "正在安装 PyInstaller..."
    pip3 install pyinstaller
fi

# 清理之前的构建
echo "清理之前的构建..."
rm -rf build dist Output

# 创建输出目录
mkdir -p Output

# 使用 PyInstaller 打包
echo "正在打包应用程序..."
pyinstaller --noconfirm --onedir --windowed \
    --name "OpenTranslator" \
    --icon "icon.icns" \
    --add-data "icon.icns:." \
    --add-data "icon.png:." \
    --add-data "translator.py:." \
    --add-data "requirements.txt:." \
    --add-data "install_mac.sh:." \
    "run.py"

# 创建应用程序包
echo "创建应用程序包..."
mkdir -p "Output/OpenTranslator.app/Contents/MacOS"
mkdir -p "Output/OpenTranslator.app/Contents/Resources"

# 复制必要的文件
cp -r "dist/OpenTranslator/"* "Output/OpenTranslator.app/Contents/MacOS/"
cp "icon.icns" "Output/OpenTranslator.app/Contents/Resources/"
cp "install_mac.sh" "Output/OpenTranslator.app/Contents/MacOS/"

# 创建 Info.plist
cat > "Output/OpenTranslator.app/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>OpenTranslator</string>
    <key>CFBundleIconFile</key>
    <string>icon.icns</string>
    <key>CFBundleIdentifier</key>
    <string>com.opentranslator.app</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>OpenTranslator</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.15</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

echo "构建完成！应用程序位于 Output/OpenTranslator.app"
echo "请将 Output 目录下的文件打包成 zip 文件分发给用户"
echo
echo "========================================"
echo "使用说明："
echo "1. 将 OpenTranslator.app 拖到 Applications 文件夹"
echo "2. 双击应用程序即可运行"
echo "3. 首次运行时，如果提示安全性问题，请："
echo "   - 右键点击应用程序，选择"打开""
echo "   - 或在系统偏好设置 > 安全性与隐私 > 通用 中允许运行"
echo "4. 如果应用程序仍然无法运行，请检查日志文件："
echo "   ~/Library/Logs/OpenTranslator.log"
echo "========================================"
echo 