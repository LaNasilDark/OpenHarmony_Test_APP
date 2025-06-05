@echo off
REM 快速构建和安装脚本
echo 快速构建HarmonyOS监控应用...

REM 构建应用
call hvigorw assembleHap
if %errorlevel% neq 0 (
    echo 构建失败!
    exit /b 1
)

REM 检查设备连接
hdc list targets
if %errorlevel% neq 0 (
    echo 未检测到HarmonyOS设备，请确保设备已连接并开启开发者模式
    pause
    exit /b 1
)

REM 安装应用
echo 正在安装应用到设备...
hdc install entry\build\default\outputs\default\entry-default-signed.hap
if %errorlevel% neq 0 (
    echo 安装失败!
    pause
    exit /b 1
)

echo.
echo ================================
echo 应用安装成功!
echo ================================
echo.
echo 现在可以在设备上启动"监控应用"
echo 然后运行以下命令监听UDP广播:
echo   python udp_listener.py
echo.
pause
