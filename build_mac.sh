#!/bin/bash

# 确保在虚拟环境中
source venv/bin/activate

# 安装打包所需的依赖
pip install pyinstaller

# 清理之前的构建
rm -rf build dist

# 使用 PyInstaller 打包应用
pyinstaller --clean \
    --name "OpenTranslator" \
    --icon "icon.icns" \
    --windowed \
    --add-data "icon.png:." \
    --add-data "icon.icns:." \
    --add-data "translator.py:." \
    --add-data "run.py:." \
    --hidden-import "PyQt6.QtCore" \
    --hidden-import "PyQt6.QtGui" \
    --hidden-import "PyQt6.QtWidgets" \
    --hidden-import "PyQt6.QtNetwork" \
    --hidden-import "PyQt6.QtWebEngineCore" \
    --hidden-import "PyQt6.QtWebEngineWidgets" \
    --collect-all "PyQt6" \
    --collect-all "PyQt6-Qt6" \
    --collect-all "PyQt6-sip" \
    --noconfirm \
    --onedir \
    run.py

# 获取 Qt 库路径
QT_LIB_PATH=$(python3 -c "from PyQt6.QtCore import QLibraryInfo; print(QLibraryInfo.path(QLibraryInfo.LibraryPath.LibrariesPath))")
QT_PLUGIN_PATH=$(python3 -c "from PyQt6.QtCore import QLibraryInfo; print(QLibraryInfo.path(QLibraryInfo.LibraryPath.PluginsPath))")
QT_QML_PATH=$(python3 -c "from PyQt6.QtCore import QLibraryInfo; print(QLibraryInfo.path(QLibraryInfo.LibraryPath.QmlModulesPath))")

# 创建应用程序包结构
mkdir -p "dist/OpenTranslator.app/Contents/MacOS"
mkdir -p "dist/OpenTranslator.app/Contents/Resources"
mkdir -p "dist/OpenTranslator.app/Contents/Frameworks"
mkdir -p "dist/OpenTranslator.app/Contents/PlugIns"
mkdir -p "dist/OpenTranslator.app/Contents/Qml"

# 复制可执行文件和资源
cp -r "dist/OpenTranslator"/* "dist/OpenTranslator.app/Contents/MacOS/"
cp "icon.icns" "dist/OpenTranslator.app/Contents/Resources/"

# 复制 Qt 框架和插件
cp -R "$QT_LIB_PATH"/* "dist/OpenTranslator.app/Contents/Frameworks/"
cp -R "$QT_PLUGIN_PATH"/* "dist/OpenTranslator.app/Contents/PlugIns/"
cp -R "$QT_QML_PATH"/* "dist/OpenTranslator.app/Contents/Qml/"

# 创建 qt.conf
cat > "dist/OpenTranslator.app/Contents/Resources/qt.conf" << EOF
[Paths]
Plugins = PlugIns
Libraries = Frameworks
Qml2Imports = Qml
EOF

# 创建 Info.plist
cat > "dist/OpenTranslator.app/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDisplayName</key>
    <string>OpenTranslator</string>
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
    <string>1.0.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>LSUIElement</key>
    <false/>
    <key>NSRequiresAquaSystemAppearance</key>
    <false/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSSupportsAutomaticGraphicsSwitching</key>
    <true/>
</dict>
</plist>
EOF

# 修复权限
chmod +x "dist/OpenTranslator.app/Contents/MacOS/OpenTranslator"

# 创建分发包
cd dist
zip -r OpenTranslator-macOS.zip OpenTranslator.app
cd ..

echo "应用程序已打包完成。"
echo "分发包已创建：dist/OpenTranslator-macOS.zip"
echo ""
echo "注意："
echo "1. 首次运行时，请右键点击应用程序，选择"打开"。"
echo "2. 如果提示安全性问题，请前往系统偏好设置 > 安全性与隐私 > 通用，点击"仍要打开"。"
echo "3. 如果应用程序仍然无法运行，请尝试在终端中运行以下命令来查看错误信息："
echo "   open -a OpenTranslator.app" 