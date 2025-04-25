@echo off
setlocal EnableDelayedExpansion

echo ========================================
echo OpenTranslator Windows 打包工具
echo ========================================
echo.

:: 检查 Inno Setup
if not exist "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" (
    echo [错误] 未找到 Inno Setup 6！
    echo 请先安装 Inno Setup 6
    echo 下载地址：https://jrsoftware.org/isdl.php
    echo 注意：请安装到默认位置 C:\Program Files (x86)\Inno Setup 6
    pause
    exit /b 1
)

:: 清理之前的构建
echo [信息] 清理之前的构建...
rmdir /s /q build dist Output 2>nul
del /f /q OpenTranslator.spec installer.iss 2>nul

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
    --noconfirm ^
    --onefile ^
    --runtime-hook add_dll_directory.py ^
    run.py

if errorlevel 1 (
    echo [错误] PyInstaller 打包失败！
    pause
    exit /b 1
)

:: 创建运行时钩子文件
echo [信息] 创建运行时钩子...
(
echo import os
echo import sys
echo if hasattr(sys, '_MEIPASS^):
echo     os.add_dll_directory(sys._MEIPASS^)
) > add_dll_directory.py

:: 创建 Inno Setup 脚本
echo [信息] 正在创建安装程序脚本...
(
echo #define MyAppName "OpenTranslator"
echo #define MyAppVersion "1.0.0"
echo #define MyAppPublisher "OpenTranslator"
echo #define MyAppExeName "OpenTranslator.exe"
echo.
echo [Setup]
echo AppId={{8F4E37D1-CD72-4F33-B2E3-99BF3B9F1C76}
echo AppName={#MyAppName}
echo AppVersion={#MyAppVersion}
echo AppPublisher={#MyAppPublisher}
echo DefaultDirName={autopf}\{#MyAppName}
echo DefaultGroupName={#MyAppName}
echo OutputDir=Output
echo OutputBaseFilename=OpenTranslator_Setup
echo Compression=lzma2/ultra64
echo SolidCompression=yes
echo WizardStyle=modern
echo PrivilegesRequired=lowest
echo DisableProgramGroupPage=yes
echo DisableWelcomePage=no
echo DisableDirPage=no
echo DisableFinishedPage=no
echo.
echo [Languages]
echo Name: "english"; MessagesFile: "compiler:Default.isl"
echo Name: "chinesesimplified"; MessagesFile: "compiler:Languages\ChineseSimplified.isl"
echo.
echo [Tasks]
echo Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
echo Name: "startupicon"; Description: "开机自动启动"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
echo.
echo [Files]
echo Source: "dist\OpenTranslator.exe"; DestDir: "{app}"; Flags: ignoreversion
echo Source: "icon.ico"; DestDir: "{app}"; Flags: ignoreversion
echo.
echo [Icons]
echo Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\icon.ico"
echo Name: "{group}\卸载 {#MyAppName}"; Filename: "{uninstallexe}"
echo Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\icon.ico"; Tasks: desktopicon
echo Name: "{commonstartup}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\icon.ico"; Tasks: startupicon
echo.
echo [Run]
echo Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
echo.
echo [UninstallDelete]
echo Type: filesandordirs; Name: "{app}"
) > installer.iss

:: 编译安装程序
echo [信息] 正在创建安装程序...
"C:\Program Files (x86)\Inno Setup 6\ISCC.exe" installer.iss
if errorlevel 1 (
    echo [错误] 创建安装程序失败！
    pause
    exit /b 1
)

echo.
echo ========================================
echo 构建成功完成！
echo.
echo 安装程序位于: Output\OpenTranslator_Setup.exe
echo ========================================
echo.

pause 