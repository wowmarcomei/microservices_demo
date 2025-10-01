@echo off
chcp 65001 >nul
echo =====================================================
echo      Sentinel 集成测试指南
echo =====================================================
echo.

echo [步骤 1] 确认 Sentinel Dashboard 正在运行
echo 访问: http://localhost:8858
echo 登录: sentinel / sentinel
echo.
pause

echo [步骤 2] 启动用户服务 (新窗口)
echo 即将在新窗口启动 user-service...
start "User Service" cmd /k "cd /d user-service && mvn spring-boot:run"
echo 等待服务启动...
timeout /t 10 >nul

echo [步骤 3] 启动商品服务 (新窗口)  
echo 即将在新窗口启动 product-service...
start "Product Service" cmd /k "cd /d product-service && mvn spring-boot:run"
echo 等待服务启动...
timeout /t 10 >nul

echo.
echo =====================================================
echo           服务启动完成，开始测试
echo =====================================================
echo.

echo [测试 URL 列表]
echo.
echo 用户服务测试接口:
echo - 基础测试: http://localhost:8081/api/sentinel/test
echo - 慢调用:   http://localhost:8081/api/sentinel/slow?delay=1000
echo - 异常测试: http://localhost:8081/api/sentinel/exception?errorRate=50  
echo - 热点参数: http://localhost:8081/api/sentinel/hotkey/user123
echo - 服务状态: http://localhost:8081/api/sentinel/status
echo.
echo 商品服务测试接口:
echo - 基础测试: http://localhost:8082/api/sentinel/test
echo - 慢调用:   http://localhost:8082/api/sentinel/slow?delay=1500
echo - 异常测试: http://localhost:8082/api/sentinel/exception?errorRate=30
echo - 热点参数: http://localhost:8082/api/sentinel/hotkey/product456  
echo - 库存查询: http://localhost:8082/api/sentinel/inventory/product456
echo - 服务状态: http://localhost:8082/api/sentinel/status
echo.

echo [Sentinel Dashboard]
echo 访问控制台: http://localhost:8858
echo 查看实时监控和配置规则
echo.

echo =====================================================
echo              测试步骤建议
echo =====================================================
echo.
echo 1. 访问测试接口，在 Sentinel Dashboard 中查看资源
echo 2. 配置流控规则 (QPS=2)
echo 3. 快速刷新接口，观察限流效果
echo 4. 配置熔断规则 (慢调用比例)
echo 5. 访问慢调用接口，观察熔断效果
echo 6. 配置热点参数限流
echo 7. 测试不同参数的访问频率
echo.

echo 按任意键开始自动测试...
pause >nul

echo.
echo [自动测试] 开始发送测试请求...

echo 测试用户服务基础接口...
curl -s http://localhost:8081/api/sentinel/test
echo.

echo 测试商品服务基础接口...  
curl -s http://localhost:8082/api/sentinel/test
echo.

echo 测试用户服务慢调用...
curl -s "http://localhost:8081/api/sentinel/slow?delay=500"
echo.

echo 测试商品服务库存查询...
curl -s http://localhost:8082/api/sentinel/inventory/product123
echo.

echo.
echo =====================================================
echo    自动测试完成！请在 Sentinel Dashboard 中查看
echo    访问: http://localhost:8858
echo =====================================================
echo.
echo 现在可以手动配置规则并进行更多测试。
echo.
pause