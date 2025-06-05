@echo off
REM GitHub上传脚本
echo ================================
echo HarmonyOS监控应用 - GitHub上传脚本
echo ================================

echo.
echo 请确保您已经：
echo 1. 在GitHub上创建了一个新的仓库
echo 2. 获得了仓库的HTTPS克隆地址
echo.

set /p REPO_URL="请输入GitHub仓库地址 (例如: https://github.com/username/harmonyos-monitor-app.git): "

if "%REPO_URL%"=="" (
    echo 错误：仓库地址不能为空
    pause
    exit /b 1
)

echo.
echo 正在配置远程仓库...
git remote remove origin 2>nul
git remote add origin %REPO_URL%
if %errorlevel% neq 0 (
    echo 配置远程仓库失败!
    pause
    exit /b 1
)

echo.
echo 正在推送到GitHub...
git push -u origin main
if %errorlevel% neq 0 (
    echo 推送失败! 可能需要先进行身份验证
    echo.
    echo 如果是第一次推送，请确保：
    echo 1. 已安装Git凭据管理器
    echo 2. GitHub仓库已创建且为空
    echo 3. 网络连接正常
    echo.
    echo 您也可以尝试手动推送：
    echo git push -u origin main
    pause
    exit /b 1
)

echo.
echo ================================
echo 上传成功！
echo ================================
echo.
echo 您的HarmonyOS监控应用已成功上传到GitHub
echo 仓库地址: %REPO_URL%
echo.
echo 接下来您可以：
echo 1. 在GitHub上查看您的项目
echo 2. 编辑README.md文件
echo 3. 设置项目描述和标签
echo 4. 邀请协作者
echo.
pause
