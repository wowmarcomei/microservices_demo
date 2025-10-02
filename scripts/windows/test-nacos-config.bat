@echo off
chcp 65001 > nul
echo === Nacos Config Test ===
echo.

echo 1. Check User Service Config:
curl -s http://localhost:8081/users/config
echo.
echo.

echo 2. Check Product Service Config:
curl -s http://localhost:8082/products/config
echo.
echo.

echo 3. Check User Service Health:
curl -s http://localhost:8081/actuator/health
echo.
echo.

echo 4. Check Product Service Health:
curl -s http://localhost:8082/actuator/health
echo.
echo.

echo 5. Test User List API:
curl -s http://localhost:8081/users
echo.
echo.

echo 6. Test Product List API:
curl -s http://localhost:8082/products
echo.
echo.

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