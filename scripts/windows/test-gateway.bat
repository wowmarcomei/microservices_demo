@echo off
chcp 65001 > nul
echo =====================================================
echo      Spring Cloud Gateway 完整功能测试
echo =====================================================
echo.

echo [检查 1] 验证网关服务健康状态...
echo.
curl -s http://localhost:9000/actuator/health
echo.
echo.

echo [检查 2] 查看已配置的路由规则...
echo.
curl -s http://localhost:9000/actuator/gateway/routes
echo.
echo.

echo [检查 3] 测试用户服务路由...
echo 直接访问用户服务:
curl -s http://localhost:8081/users
echo.
echo.
echo 通过网关访问用户服务:
curl -s http://localhost:9000/user-service/users
echo.
echo.

echo [检查 4] 测试商品服务路由...
echo 直接访问商品服务:
curl -s http://localhost:8082/products
echo.
echo.
echo 通过网关访问商品服务:
curl -s http://localhost:9000/product-service/products
echo.
echo.

echo [检查 5] 测试负载均衡功能...
echo 发送多个请求测试响应时间:
echo 请求 1:
curl -s -w "响应时间: %%{time_total}s" http://localhost:9000/user-service/users > nul
echo.
echo 请求 2:
curl -s -w "响应时间: %%{time_total}s" http://localhost:9000/user-service/users > nul
echo.
echo 请求 3:
curl -s -w "响应时间: %%{time_total}s" http://localhost:9000/user-service/users > nul
echo.
echo.

echo [检查 6] 验证Nacos服务发现...
echo 查询Nacos中注册的服务:
curl -s "http://localhost:8848/nacos/v1/ns/service/list?pageNo=1&pageSize=10"
echo.
echo.

echo [检查 7] 验证Gateway在Nacos中的注册状态...
curl -s "http://localhost:8848/nacos/v1/ns/instance/list?serviceName=gateway-service"
echo.
echo.

echo =====================================================
echo              测试结果总结
echo =====================================================
echo.
echo ✅ Gateway服务地址: http://localhost:9000
echo ✅ 用户服务地址: http://localhost:8081
echo ✅ 商品服务地址: http://localhost:8082
echo ✅ Nacos控制台: http://localhost:8848/nacos
echo ✅ Sentinel控制台: http://localhost:8858
echo.
echo 🏗️ 微服务架构:
echo 客户端 → Gateway (9000) → 后端微服务
echo        ↓
echo    Nacos (8848) ← 服务发现与配置
echo        ↓
echo   Sentinel (8858) ← 流量控制
echo.
echo 📋 可用的API路由:
echo - GET /user-service/users       - 获取用户列表
echo - GET /product-service/products - 获取商品列表
echo - GET /actuator/health          - 健康检查
echo - GET /actuator/gateway/routes  - 查看路由配置
echo.

pause