@echo off
setlocal EnableDelayedExpansion

echo ========================================
echo OpenTranslator Windows 打包工具
echo ========================================
echo.

:: 检查 PyInstaller
pip show pyinstaller >nul 2>&1
if errorlevel 1 (
    echo [信息] 正在安装 PyInstaller...
    pip install pyinstaller
)

:: 检查 Inno Setup
where iscc >nul 2>&1
if errorlevel 1 (
    echo [错误] 未找到 Inno Setup 编译器！
    echo 请从 https://jrsoftware.org/isdl.php 下载并安装 Inno Setup
    pause
    exit /b 1
)

:: 清理之前的构建
echo [信息] 清理之前的构建...
rmdir /s /q build dist Output 2>nul
del /f /q OpenTranslator.spec 2>nul

:: 创建输出目录
mkdir Output 2>nul

:: 使用 PyInstaller 打包应用
echo [信息] 正在打包应用程序...
pyinstaller --clean ^
    --name "OpenTranslator" ^
    --icon "icon.ico" ^
    --windowed ^
    --add-data "icon.png;." ^
    --add-data "icon.ico;." ^
    --add-data "translator.py;." ^
    --add-data "run.py;." ^
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
    --noconfirm ^
    --onefile ^
    run.py

if errorlevel 1 (
    echo [错误] PyInstaller 打包失败！
    pause
    exit /b 1
)

:: 创建 Inno Setup 脚本
echo [信息] 创建安装程序...
(
echo #define MyAppName "OpenTranslator"
echo #define MyAppVersion "1.0"
echo #define MyAppPublisher "OpenTranslator Team"
echo #define MyAppURL "https://github.com/yourusername/OpenTranslator"
echo #define MyAppExeName "OpenTranslator.exe"
echo.
echo [Setup]
echo AppId=^\{A1B2C3D4-E5F6-4A5B-8C7D-9E0F1A2B3C4D^}
echo AppName=^#MyAppName
echo AppVersion=^#MyAppVersion
echo AppPublisher=^#MyAppPublisher
echo AppPublisherURL=^#MyAppURL
echo AppSupportURL=^#MyAppURL
echo AppUpdatesURL=^#MyAppURL
echo DefaultDirName=^\{autopf^}\^#MyAppName
echo DefaultGroupName=^#MyAppName
echo AllowNoIcons=yes
echo OutputDir=Output
echo OutputBaseFilename=OpenTranslator-Setup
echo Compression=lzma
echo SolidCompression=yes
echo WizardStyle=modern
echo.
echo [Languages]
echo Name: "english"; MessagesFile: "compiler:Default.isl"
echo Name: "chinesesimplified"; MessagesFile: "compiler:Languages\ChineseSimplified.isl"
echo.
echo [Tasks]
echo Name: "desktopicon"; Description: "^\{cm:CreateDesktopIcon^}"; GroupDescription: "^\{cm:AdditionalIcons^}"; Flags: unchecked
echo.
echo [Files]
echo Source: "dist\OpenTranslator.exe"; DestDir: "^\{app^}"; Flags: ignoreversion
echo Source: "icon.ico"; DestDir: "^\{app^}"; Flags: ignoreversion
echo.
echo [Icons]
echo Name: "^\{group^}\^#MyAppName"; Filename: "^\{app^}\^#MyAppExeName"
echo Name: "^\{group^}\^\{cm:UninstallProgram,^#MyAppName^}"; Filename: "^\{uninstallexe^}"
echo Name: "^\{commondesktop^}\^#MyAppName"; Filename: "^\{app^}\^#MyAppExeName"; Tasks: desktopicon
echo.
echo [Run]
echo Filename: "^\{app^}\^#MyAppExeName"; Description: "^\{cm:LaunchProgram,^#StringChange(MyAppName, '&', '&&')^^}"; Flags: nowait postinstall skipifsilent
) > installer.iss

:: 编译安装程序
iscc installer.iss

if errorlevel 1 (
    echo [错误] 安装程序创建失败！
    pause
    exit /b 1
)

echo.
echo ========================================
echo 构建成功完成！
echo.
echo 安装程序位于: Output\OpenTranslator-Setup.exe
echo ========================================
echo.

pause 