# Spring Cloud Alibaba - Nacos 服务治理

本项目演示了使用Nacos实现微服务的服务注册发现和配置中心功能。

## 项目结构

```
monolith-app/
├── user-service/           # 用户微服务
├── product-service/        # 商品微服务
├── nacos-config-templates/ # Nacos配置模板
├── docs/                   # 文档目录
│   ├── Nacos-Config-Guide.md
│   └── Nacos-Config-Test-Guide.md
├── test-nacos-config.sh   # Linux/Mac测试脚本
└── test-nacos-config.bat  # Windows测试脚本
```

## 功能特性

### 1. 服务注册与发现
- ✅ 用户服务注册到Nacos
- ✅ 商品服务注册到Nacos  
- ✅ OpenFeign服务间调用
- ✅ 负载均衡支持

### 2. 配置中心
- ✅ 统一配置管理
- ✅ 动态配置刷新
- ✅ 配置分层管理
- ✅ 多环境配置支持

### 3. 监控与管理
- ✅ Actuator健康检查
- ✅ 配置刷新端点
- ✅ 服务状态监控

## 技术栈

- Spring Boot 2.7.5
- Spring Cloud 2021.0.4
- Spring Cloud Alibaba 2021.0.4.0
- Nacos 2.2.3
- MyBatis Plus 3.5.2
- MySQL 8.0
- Redis 6.0
- Docker

## 快速开始

### 1. 环境准备

**启动Nacos服务**
```bash
# 使用Docker启动Nacos
docker run -d \
  --name nacos \
  -p 8848:8848 \
  -e MODE=standalone \
  nacos/nacos-server:v2.2.3
```

**访问Nacos控制台**
- 地址：http://localhost:8848/nacos
- 用户名：nacos
- 密码：nacos

### 2. 配置Nacos Config

按照 `docs/Nacos-Config-Guide.md` 文档在Nacos控制台创建配置文件：

1. **common-config.yml** - 公共配置
2. **user-service.yml** - 用户服务配置
3. **product-service.yml** - 商品服务配置

配置模板位于 `nacos-config-templates/` 目录。

### 3. 启动微服务

**启动用户服务**
```bash
cd user-service
mvn spring-boot:run
```

**启动商品服务**
```bash
cd product-service
mvn spring-boot:run
```

### 4. 功能验证

**方式1：使用测试脚本**
```bash
# Linux/Mac
./test-nacos-config.sh

# Windows
test-nacos-config.bat
```

**方式2：手动测试**
```bash
# 检查服务配置
curl http://localhost:8081/users/config
curl http://localhost:8082/products/config

# 测试服务功能
curl http://localhost:8081/users
curl http://localhost:8082/products

# 测试跨服务调用
curl http://localhost:8082/products/1/with-user
```

## 动态配置刷新测试

1. **修改Nacos配置**
   - 在Nacos控制台修改 `common-config.yml`
   - 例如：将 `app.config.version` 从 "1.0.0" 改为 "1.0.1"

2. **刷新服务配置**
   ```bash
   curl -X POST http://localhost:8081/actuator/refresh
   curl -X POST http://localhost:8082/actuator/refresh
   ```

3. **验证配置更新**
   ```bash
   curl http://localhost:8081/users/config
   curl http://localhost:8082/products/config
   ```

## API 接口

### 用户服务 (8081)
- `GET /users` - 获取用户列表
- `GET /users/{id}` - 获取用户详情
- `GET /users/config` - 获取当前配置
- `POST /users` - 创建用户
- `PUT /users/{id}` - 更新用户
- `DELETE /users/{id}` - 删除用户

### 商品服务 (8082)
- `GET /products` - 获取商品列表
- `GET /products/{id}` - 获取商品详情
- `GET /products/{id}/with-user` - 获取商品和用户信息
- `GET /products/config` - 获取当前配置
- `POST /products` - 创建商品
- `PUT /products/{id}` - 更新商品
- `DELETE /products/{id}` - 删除商品

### 管理端点
- `GET /actuator/health` - 健康检查
- `POST /actuator/refresh` - 刷新配置
- `GET /actuator/info` - 应用信息

## 文档参考

- [Nacos Config 配置指南](docs/Nacos-Config-Guide.md)
- [Nacos Config 测试指南](docs/Nacos-Config-Test-Guide.md)
- [Spring Cloud Alibaba 官方文档](https://spring-cloud-alibaba-group.github.io/github-pages/greenwich/spring-cloud-alibaba.html)
- [Nacos 官方文档](https://nacos.io/zh-cn/docs/what-is-nacos.html)

## 故障排除

### 常见问题

1. **服务注册失败**
   - 检查Nacos服务是否启动
   - 验证bootstrap.yml中的连接配置

2. **配置加载失败**
   - 确认Data ID和Group配置正确
   - 检查配置文件格式是否正确

3. **动态刷新不生效**
   - 确保添加了@RefreshScope注解
   - 检查actuator端点是否开放

4. **服务间调用失败**
   - 验证LoadBalancer依赖
   - 检查OpenFeign客户端配置

更多详细信息请参考文档目录中的相关文档。