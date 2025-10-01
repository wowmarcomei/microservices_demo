@echo off
chcp 65001 >nul
echo =====================================================
echo      Docker Sentinel Dashboard 快速启动
echo =====================================================
echo.

echo [检查] 检查 Docker 是否运行...
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker 未安装或未启动！
    echo 请先安装并启动 Docker Desktop
    pause
    exit /b 1
)

echo [INFO] Docker 运行正常
echo.

echo [启动] 启动 Sentinel Dashboard (端口 8858)...
docker run -d -p 8858:8080 --name sentinel-dashboard bladex/sentinel-dashboard:1.8.6

if %errorlevel% equ 0 (
    echo [SUCCESS] Sentinel Dashboard 启动成功！
    echo.
    echo 访问信息:
    echo - URL: http://localhost:8858
    echo - 用户名: sentinel
    echo - 密码: sentinel
    echo.
    echo 等待服务启动完成...
    timeout /t 10 >nul
    echo.
    echo [INFO] 可以开始使用 Sentinel Dashboard 了！
) else (
    echo [ERROR] 启动失败！可能是容器已存在或端口被占用
    echo.
    echo 尝试删除已有容器并重新启动...
    docker rm -f sentinel-dashboard
    docker run -d -p 8858:8080 --name sentinel-dashboard bladex/sentinel-dashboard:1.8.6
    
    if %errorlevel% equ 0 (
        echo [SUCCESS] 重新启动成功！
        echo 访问 URL: http://localhost:8858
    ) else (
        echo [ERROR] 重新启动也失败了，请检查端口占用情况
        echo 可以尝试修改端口: docker run -d -p 8859:8080 --name sentinel-dashboard bladex/sentinel-dashboard:1.8.6
    )
)

echo.
echo =====================================================
echo              Sentinel Dashboard 管理命令
echo =====================================================
echo.
echo 查看容器状态: docker ps -a | findstr sentinel
echo 查看容器日志: docker logs sentinel-dashboard
echo 停止容器:     docker stop sentinel-dashboard
echo 启动容器:     docker start sentinel-dashboard
echo 删除容器:     docker rm -f sentinel-dashboard
echo.

pause