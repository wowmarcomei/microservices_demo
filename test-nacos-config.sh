#!/bin/bash

echo "=== Nacos Config 配置中心功能测试 ==="
echo

echo "1. 检查用户服务配置信息："
curl -s http://localhost:8081/users/config | jq '.'
echo

echo "2. 检查商品服务配置信息："
curl -s http://localhost:8082/products/config | jq '.'
echo

echo "3. 检查用户服务健康状态："
curl -s http://localhost:8081/actuator/health | jq '.'
echo

echo "4. 检查商品服务健康状态："
curl -s http://localhost:8082/actuator/health | jq '.'
echo

echo "5. 测试用户列表接口："
curl -s http://localhost:8081/users | jq '.'
echo

echo "6. 测试商品列表接口："
curl -s http://localhost:8082/products | jq '.'
echo

echo "7. 测试跨服务调用："
curl -s http://localhost:8082/products/1/with-user | jq '.'
echo

echo "=== 测试完成 ==="
echo
echo "如需测试动态配置刷新，请："
echo "1. 在Nacos控制台修改配置"
echo "2. 执行: curl -X POST http://localhost:8081/actuator/refresh"
echo "3. 执行: curl -X POST http://localhost:8082/actuator/refresh"
echo "4. 重新检查配置: curl http://localhost:8081/users/config"