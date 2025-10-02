# 🚀 开始 Sentinel 学习之旅

欢迎来到《微服务治理核心》第3章：**服务容错保护 - Sentinel**！

## 📋 学习准备清单

### ✅ 已完成项目
- [x] 单体应用拆分为微服务
- [x] Nacos 服务注册与发现
- [x] Nacos Config 配置中心
- [x] OpenFeign 服务间调用
- [x] 微服务正常运行

### 🎯 本章学习目标

1. **理解服务容错的重要性** - 为什么需要Sentinel？
2. **掌握Sentinel核心概念** - 流控、熔断、降级
3. **实战Sentinel集成** - 保护我们的微服务
4. **配置可视化管理** - Sentinel Dashboard的使用
5. **服务间容错** - OpenFeign + Sentinel

## 🛠️ 环境准备

### 第一步：下载 Sentinel Dashboard

由于网络原因，请手动下载 Sentinel Dashboard：

1. **访问控制台**：https://github.com/alibaba/Sentinel/releases/tag/1.8.6
2. **下载文件**：`sentinel-dashboard-1.8.6.jar` (约19MB)
3. **保存位置**：`d:\workstation\training\monolith-app\` 目录下

**或者使用 Docker 启动（推荐）**：
```bash
docker run -d -p 8858:8080 --name sentinel-dashboard bladex/sentinel-dashboard:1.8.6
```

**备用下载链接**：
- Maven Central: https://repo1.maven.org/maven2/com/alibaba/csp/sentinel-dashboard/1.8.6/sentinel-dashboard-1.8.6.jar

### 第二步：启动 Sentinel Dashboard

下载完成后，运行启动脚本：
```bash
# Docker 方式（推荐）
docker run -d -p 8858:8080 --name sentinel-dashboard bladex/sentinel-dashboard:1.8.6

# 或使用 Jar 包方式
.\start-sentinel-dashboard.bat
```

或手动启动：
```bash
java -Dserver.port=8858 -jar sentinel-dashboard-1.8.6.jar
```

### 第三步：验证启动成功

1. 打开浏览器访问：http://localhost:8858
2. 登录信息：
   - 用户名：`sentinel`
   - 密码：`sentinel`

## 🔧 微服务集成准备

接下来我们将为现有的微服务集成 Sentinel：

### user-service 集成计划
- ✨ 添加 Sentinel 依赖
- 🔧 配置 Dashboard 连接
- 🛡️ 保护用户查询接口
- 📊 配置流控规则

### product-service 集成计划  
- ✨ 添加 Sentinel 依赖
- 🔧 配置 Dashboard 连接
- 🛡️ 保护商品接口
- 🔥 配置熔断规则

### 服务间调用保护
- 🤝 OpenFeign + Sentinel 集成
- 💔 服务降级处理
- 🔄 容错恢复机制

## 🎯 实战演示场景

我们将通过以下场景学习 Sentinel：

1. **正常访问** → 观察请求通过
2. **高并发访问** → 触发流量控制  
3. **服务异常** → 触发熔断保护
4. **网络故障** → 服务降级处理

## 📚 理论基础回顾

### 什么是雪崩效应？
在微服务架构中，当一个服务出现故障时：
```
用户请求 → 网关 → 用户服务 → 商品服务 → 数据库
                      ↓
                  商品服务故障
                      ↓
            用户服务请求堆积，消耗资源
                      ↓
              用户服务也开始出现问题
                      ↓
                整个系统不可用 💥
```

### Sentinel 如何解决？
```
用户请求 → 网关 → 用户服务 → [Sentinel保护] → 商品服务
                      ↓
                  检测到商品服务异常
                      ↓
                  触发熔断，返回降级响应
                      ↓
              保护整个调用链路稳定 ✅
```

## ⏭️ 开始学习！

完成 Sentinel Dashboard 下载和启动后，我们将开始实际的代码集成工作。

**准备好了吗？让我们开始构建稳定可靠的微服务系统！** 🚀

---

### 💡 小贴士

- 确保 Nacos 服务器正在运行 (172.24.238.72:8848)
- 确保 user-service 和 product-service 正常启动
- 保持 Sentinel Dashboard 运行状态
- 准备好测试工具(浏览器、Postman等)

### 🆘 如需帮助

如果在下载或启动过程中遇到问题，请告诉我，我会提供详细的解决方案！