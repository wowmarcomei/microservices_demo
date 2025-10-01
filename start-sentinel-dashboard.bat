@echo off
chcp 65001 >nul
echo =====================================================
echo      Sentinel Dashboard Startup Script
echo =====================================================
echo.

REM Check if Sentinel Dashboard jar exists
if not exist "sentinel-dashboard-1.8.6.jar" (
    echo [ERROR] sentinel-dashboard-1.8.6.jar not found!
    echo.
    echo Please download Sentinel Dashboard manually:
    echo 1. Visit: https://github.com/alibaba/Sentinel/releases/tag/1.8.6
    echo 2. Download: sentinel-dashboard-1.8.6.jar
    echo 3. Place the jar file in this directory: %cd%
    echo.
    echo Alternative download methods:
    echo - Maven Repository: https://repo1.maven.org/maven2/com/alibaba/csp/sentinel-dashboard/1.8.6/
    echo - Direct link: https://github.com/alibaba/Sentinel/releases/download/1.8.6/sentinel-dashboard-1.8.6.jar
    echo.
    echo [INFO] You can also use Docker to start Sentinel Dashboard:
    echo docker run -d -p 8858:8080 --name sentinel-dashboard bladex/sentinel-dashboard:1.8.6
    echo.
    pause
    exit /b 1
)

echo [INFO] Starting Sentinel Dashboard...
echo [INFO] Dashboard URL: http://localhost:8858
echo [INFO] Default Login: sentinel / sentinel
echo [INFO] Press Ctrl+C to stop
echo.

java -Dserver.port=8858 -Dcsp.sentinel.dashboard.server=localhost:8858 -Dproject.name=sentinel-dashboard -jar sentinel-dashboard-1.8.6.jar

pause