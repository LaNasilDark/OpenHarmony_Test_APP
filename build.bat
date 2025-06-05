@echo off
REM HarmonyOS监控应用构建脚本
echo ================================
echo HarmonyOS监控应用构建脚本
echo ================================

echo.
echo 1. 清理构建缓存...
call hvigorw clean

echo.
echo 2. 编译应用...
call hvigorw assembleHap
if %errorlevel% neq 0 (
    echo 编译失败!
    pause
    exit /b 1
)

echo.
echo 3. 运行单元测试...
call hvigorw testOhosTest
if %errorlevel% neq 0 (
    echo 测试失败!
    pause
    exit /b 1
)

echo.
echo ================================
echo 构建成功完成!
echo ================================
echo.
echo 生成的HAP文件位置:
echo   entry\build\default\outputs\default\entry-default-signed.hap
echo.
echo 可以使用以下命令安装到设备:
echo   hdc install entry\build\default\outputs\default\entry-default-signed.hap
echo.
echo 使用UDP监听器测试广播功能:
echo   python udp_listener.py
echo.
pause
