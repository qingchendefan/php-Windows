@echo off
echo ========================================
echo OpenTranslator Windows 打包工具
echo ========================================
echo.

REM 检查 Python 环境
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误: 未找到 Python，请先安装 Python
    exit /b 1
)

REM 检查 pip
pip --version >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误: 未找到 pip，请先安装 pip
    exit /b 1
)

REM 检查 PyInstaller
pip show pyinstaller >nul 2>&1
if %errorlevel% neq 0 (
    echo 正在安装 PyInstaller...
    pip install pyinstaller
)

REM 清理之前的构建
echo 清理之前的构建...
if exist build rmdir /s /q build
if exist dist rmdir /s /q dist
if exist Output rmdir /s /q Output
if exist OpenTranslator.spec del OpenTranslator.spec

REM 创建输出目录
mkdir Output

REM 使用 PyInstaller 打包
echo 正在打包应用程序...
pyinstaller --noconfirm --onefile --windowed ^
    --name "OpenTranslator" ^
    --icon "icon.ico" ^
    --add-data "icon.ico;." ^
    --add-data "icon.png;." ^
    --add-data "translator.py;." ^
    --hidden-import "PyQt6.QtCore" ^
    --hidden-import "PyQt6.QtGui" ^
    --hidden-import "PyQt6.QtWidgets" ^
    --hidden-import "PyQt6.QtNetwork" ^
    --hidden-import "PyQt6.QtWebEngineCore" ^
    --hidden-import "PyQt6.QtWebEngineWidgets" ^
    --collect-all "PyQt6" ^
    --collect-all "PyQt6-Qt6" ^
    --collect-all "PyQt6-sip" ^
    --collect-all "PyQt6-WebEngine" ^
    "run.py"

REM 复制文件到输出目录
echo 复制文件到输出目录...
copy "dist\OpenTranslator.exe" "Output\"
copy "icon.ico" "Output\"

echo 构建完成！应用程序位于 Output 目录
echo 请将 Output 目录下的文件打包成 zip 文件分发给用户
echo.
echo ========================================
echo 使用说明：
echo 1. 解压下载的 zip 文件到任意目录
echo 2. 双击 OpenTranslator.exe 运行程序
echo 3. 如果遇到安全警告，请点击"更多信息"，然后选择"仍要运行"
echo ========================================
echo. 