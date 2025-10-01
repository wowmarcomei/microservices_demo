@echo off
chcp 65001 >nul
echo =====================================================
echo      Sentinel 配置验证工具
echo =====================================================
echo.

echo [检查 1] 验证 user-service 配置...
findstr "dashboard: localhost:8858" user-service\src\main\resources\bootstrap.yml >nul
if %errorlevel% equ 0 (
    echo ✅ user-service Dashboard 地址配置正确 (8858)
) else (
    echo ❌ user-service Dashboard 地址配置错误
    echo 应该是: dashboard: localhost:8858
)

findstr "port: 8719" user-service\src\main\resources\bootstrap.yml >nul
if %errorlevel% equ 0 (
    echo ✅ user-service 传输端口配置正确 (8719)
) else (
    echo ❌ user-service 传输端口配置错误
)

echo.
echo [检查 2] 验证 product-service 配置...
findstr "dashboard: localhost:8858" product-service\src\main\resources\bootstrap.yml >nul
if %errorlevel% equ 0 (
    echo ✅ product-service Dashboard 地址配置正确 (8858)
) else (
    echo ❌ product-service Dashboard 地址配置错误
    echo 应该是: dashboard: localhost:8858
)

findstr "port: 8720" product-service\src\main\resources\bootstrap.yml >nul
if %errorlevel% equ 0 (
    echo ✅ product-service 传输端口配置正确 (8720)
) else (
    echo ❌ product-service 传输端口配置错误
)

echo.
echo [检查 3] 验证 Sentinel Dashboard 可访问性...
curl -s http://localhost:8858 >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Sentinel Dashboard 运行正常 (http://localhost:8858)
) else (
    echo ❌ Sentinel Dashboard 无法访问
    echo 请确认:
    echo 1. Docker 容器是否启动: docker ps ^| findstr sentinel
    echo 2. 端口是否被占用: netstat -ano ^| findstr 8858
)

echo.
echo [检查 4] 验证微服务状态...
curl -s http://localhost:8081/actuator/health >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ user-service 运行正常 (8081)
) else (
    echo ⚠️ user-service 未启动或无法访问
)

curl -s http://localhost:8082/actuator/health >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ product-service 运行正常 (8082)
) else (
    echo ⚠️ product-service 未启动或无法访问
)

echo.
echo =====================================================
echo              配置验证完成
echo =====================================================
echo.
echo 如果所有检查都通过，可以开始测试 Sentinel 功能：
echo 1. 访问 http://localhost:8858 登录 Sentinel Dashboard
echo 2. 启动微服务并访问测试接口产生流量
echo 3. 在 Dashboard 中查看资源并配置规则
echo.

pause