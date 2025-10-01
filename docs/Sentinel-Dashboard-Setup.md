# Sentinel Dashboard 下载和启动指南

## 方法一：直接下载（推荐）

### 从 GitHub Releases 下载
1. 访问：https://github.com/alibaba/Sentinel/releases/tag/1.8.6
2. 下载文件：`sentinel-dashboard-1.8.6.jar`
3. 将文件保存到项目根目录：`d:\workstation\training\monolith-app\`

### 从 Maven 中央仓库下载
```bash
# 使用 wget (如果安装了)
wget https://repo1.maven.org/maven2/com/alibaba/csp/sentinel-dashboard/1.8.6/sentinel-dashboard-1.8.6.jar

# 或使用 curl
curl -O https://repo1.maven.org/maven2/com/alibaba/csp/sentinel-dashboard/1.8.6/sentinel-dashboard-1.8.6.jar
```

## 方法二：使用 Maven 下载

在任意目录执行：
```bash
mvn dependency:get -Dartifact=com.alibaba.csp:sentinel-dashboard:1.8.6:jar -Dtransitive=false
```

然后从 Maven 本地仓库复制文件：
```
%USERPROFILE%\.m2\repository\com\alibaba\csp\sentinel-dashboard\1.8.6\sentinel-dashboard-1.8.6.jar
```

## 启动 Sentinel Dashboard

### 使用提供的脚本
```bash
.\start-sentinel-dashboard.bat
```

### 手动启动
```bash
java -Dserver.port=8858 -Dcsp.sentinel.dashboard.server=localhost:8858 -Dproject.name=sentinel-dashboard -jar sentinel-dashboard-1.8.6.jar
```

### Docker 启动方式（推荐）
```bash
# 启动 Sentinel Dashboard
docker run -d -p 8858:8080 --name sentinel-dashboard bladex/sentinel-dashboard:1.8.6

# 查看运行状态
docker logs sentinel-dashboard
```

## 访问控制台

- **URL**: http://localhost:8858
- **用户名**: sentinel
- **密码**: sentinel

## 验证启动成功

1. 打开浏览器访问 http://localhost:8080
2. 使用用户名 `sentinel` 和密码 `sentinel` 登录
3. 看到 Sentinel 控制台首页

## 常见问题

### 端口被占用
如果 8858 端口被占用，可以修改端口：
```bash
# Jar 包方式
java -Dserver.port=8859 -Dcsp.sentinel.dashboard.server=localhost:8859 -Dproject.name=sentinel-dashboard -jar sentinel-dashboard-1.8.6.jar

# Docker 方式
docker run -d -p 8859:8080 --name sentinel-dashboard bladex/sentinel-dashboard:1.8.6
```

### Java 版本要求
- 需要 JDK 8 或更高版本
- 检查 Java 版本：`java -version`

### 下载失败
如果网络问题导致下载失败，可以：
1. 使用VPN或代理
2. 从国内镜像站下载
3. 请其他人代为下载后传输

## 下一步

成功启动 Sentinel Dashboard 后，我们将开始集成 Sentinel 到微服务中。