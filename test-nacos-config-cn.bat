@echo off
chcp 65001 > nul

REM === Nacos Config 配置中心功能测试 ===
echo === Nacos Config Test ===
echo.

REM 1. 检查用户服务配置信息
echo 1. Check User Service Config:
curl -s http://localhost:8081/users/config
echo.
echo.

REM 2. 检查商品服务配置信息
echo 2. Check Product Service Config:
curl -s http://localhost:8082/products/config
echo.
echo.

REM 3. 检查用户服务健康状态
echo 3. Check User Service Health:
curl -s http://localhost:8081/actuator/health
echo.
echo.

REM 4. 检查商品服务健康状态
echo 4. Check Product Service Health:
curl -s http://localhost:8082/actuator/health
echo.
echo.

REM 5. 测试用户列表接口
echo 5. Test User List API:
curl -s http://localhost:8081/users
echo.
echo.

REM 6. 测试商品列表接口
echo 6. Test Product List API:
curl -s http://localhost:8082/products
echo.
echo.

REM 7. 测试跨服务调用
echo 7. Test Cross-Service Call:
curl -s http://localhost:8082/products/1/with-user
echo.
echo.

echo === Test Completed ===
echo.
echo To test dynamic config refresh:
echo 1. Modify config in Nacos console
echo 2. Run: curl -X POST http://localhost:8081/actuator/refresh
echo 3. Run: curl -X POST http://localhost:8082/actuator/refresh
echo 4. Check config again: curl http://localhost:8081/users/config

pause