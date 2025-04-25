#!/bin/bash

echo "========================================"
echo "OpenTranslator macOS 打包工具"
echo "========================================"
echo

# 检查 Python 环境
if ! command -v python3 &> /dev/null; then
    echo "[错误] 未找到 Python3，请先安装 Python3"
    exit 1
fi

# 检查 pip
if ! command -v pip3 &> /dev/null; then
    echo "[错误] 未找到 pip3，请先安装 pip3"
    exit 1
fi

# 检查 PyInstaller
if ! pip3 show pyinstaller &> /dev/null; then
    echo "[信息] 正在安装 PyInstaller..."
    pip3 install pyinstaller
fi

# 清理之前的构建
echo "[信息] 清理之前的构建..."
rm -rf build dist Output OpenTranslator.spec 2>/dev/null

# 创建输出目录
mkdir -p Output 2>/dev/null

# 使用 PyInstaller 打包应用
echo "[信息] 正在打包应用程序..."
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
    --exclude-module "PyQt6.QtBluetooth" \
    --exclude-module "PyQt6.Qt3DAnimation" \
    --exclude-module "PyQt6.Qt3DCore" \
    --exclude-module "PyQt6.Qt3DExtras" \
    --exclude-module "PyQt6.Qt3DInput" \
    --exclude-module "PyQt6.Qt3DLogic" \
    --exclude-module "PyQt6.Qt3DQuick" \
    --exclude-module "PyQt6.Qt3DRender" \
    --exclude-module "PyQt6.QtDesigner" \
    --exclude-module "PyQt6.QtHelp" \
    --exclude-module "PyQt6.QtMultimedia" \
    --exclude-module "PyQt6.QtMultimediaWidgets" \
    --exclude-module "PyQt6.QtNfc" \
    --exclude-module "PyQt6.QtOpenGL" \
    --exclude-module "PyQt6.QtOpenGLWidgets" \
    --exclude-module "PyQt6.QtPdf" \
    --exclude-module "PyQt6.QtPdfWidgets" \
    --exclude-module "PyQt6.QtPositioning" \
    --exclude-module "PyQt6.QtQml" \
    --exclude-module "PyQt6.QtQuick" \
    --exclude-module "PyQt6.QtQuick3D" \
    --exclude-module "PyQt6.QtQuickWidgets" \
    --exclude-module "PyQt6.QtRemoteObjects" \
    --exclude-module "PyQt6.QtSensors" \
    --exclude-module "PyQt6.QtSerialPort" \
    --exclude-module "PyQt6.QtSpatialAudio" \
    --exclude-module "PyQt6.QtSql" \
    --exclude-module "PyQt6.QtStateMachine" \
    --exclude-module "PyQt6.QtSvg" \
    --exclude-module "PyQt6.QtSvgWidgets" \
    --exclude-module "PyQt6.QtTest" \
    --exclude-module "PyQt6.QtTextToSpeech" \
    --exclude-module "PyQt6.QtWebEngineQuick" \
    --exclude-module "PyQt6.QtWebSockets" \
    --exclude-module "PyQt6.QtXml" \
    --noconfirm \
    --onedir \
    run.py

if [ $? -ne 0 ]; then
    echo "[错误] PyInstaller 打包失败！"
    exit 1
fi

# 创建应用程序包
echo "[信息] 创建应用程序包..."
mkdir -p "dist/OpenTranslator.app/Contents/MacOS"
mkdir -p "dist/OpenTranslator.app/Contents/Resources"
mkdir -p "dist/OpenTranslator.app/Contents/Frameworks"
mkdir -p "dist/OpenTranslator.app/Contents/PlugIns"

# 复制可执行文件和资源
cp -r "dist/OpenTranslator"/* "dist/OpenTranslator.app/Contents/MacOS/"
cp "icon.icns" "dist/OpenTranslator.app/Contents/Resources/"

# 创建启动脚本
cat > "dist/OpenTranslator.app/Contents/MacOS/launch.sh" << EOF
#!/bin/bash
cd "\$(dirname "\$0")"
export DYLD_LIBRARY_PATH="\$(dirname "\$0")/../Frameworks"
export QT_PLUGIN_PATH="\$(dirname "\$0")/../PlugIns"
exec ./OpenTranslator 2>&1 | tee ~/Library/Logs/OpenTranslator.log
EOF
chmod +x "dist/OpenTranslator.app/Contents/MacOS/launch.sh"

# 创建 Info.plist
cat > "dist/OpenTranslator.app/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDisplayName</key>
    <string>OpenTranslator</string>
    <key>CFBundleExecutable</key>
    <string>launch.sh</string>
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
chmod +x "dist/OpenTranslator.app/Contents/MacOS/launch.sh"

# 复制应用程序到输出目录
echo "[信息] 复制应用程序到输出目录..."
cp -R "dist/OpenTranslator.app" "Output/"

echo
echo "========================================"
echo "构建成功完成！"
echo
echo "应用程序位于: Output/OpenTranslator.app"
echo
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