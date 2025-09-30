# 微服务部署指南

## 🚀 快速启动

### 1. 数据库准备

由于您已有MySQL实例和`monolith_db`数据，我们将创建独立的微服务数据库并迁移数据：

```bash
# 在您的MySQL中执行
# 脚本会自动：
# 1. 创建 user_db 和 product_db
# 2. 从 monolith_db 迁移现有数据
# 3. 如果没有数据，则插入测试数据
mysql -u root -p < init-microservices-db.sql
```

或者通过Navicat等工具直接执行 `init-microservices-db.sql` 文件。

**数据迁移结果**：
- `user_db.users` - 用户数据
- `product_db.products` - 商品数据
- `product_db.categories` - 商品分类
- `product_db.brands` - 品牌信息

### 2. 启动Redis（如果还没有）

```bash
# 仅启动Redis
docker-compose -f docker-compose-microservices.yml up redis -d
```

### 3. 本地启动微服务

#### 启动用户服务
```bash
cd user-service
mvn spring-boot:run
```
- 访问地址：http://localhost:8081
- API文档：http://localhost:8081/swagger-ui/index.html

#### 启动商品服务
```bash
cd product-service  
mvn spring-boot:run
```
- 访问地址：http://localhost:8082
- API文档：http://localhost:8082/swagger-ui/index.html

### 4. 测试服务间调用

```bash
# 测试用户服务
curl http://localhost:8081/users/1

# 测试商品服务
curl http://localhost:8082/products/1

# 测试服务间调用（重点！）
curl http://localhost:8082/products/1/with-user
```

## 🐳 Docker容器化部署（可选）

如果需要完全容器化部署：

```bash
# 构建并启动所有微服务
docker-compose -f docker-compose-microservices.yml up --build
```

## 📋 项目结构

```
monolith-app/
├── src/                          # 原始单体应用
├── user-service/                 # 用户微服务 (8081)
├── product-service/              # 商品微服务 (8082)
├── Dockerfile                    # 统一的构建文件
├── docker-compose-microservices.yml  # 微服务编排
└── init-microservices-db.sql     # 数据库初始化
```

## ✨ 核心特性

- ✅ **服务拆分**：用户服务 + 商品微服务
- ✅ **服务间调用**：OpenFeign声明式调用
- ✅ **独立数据库**：user_db + product_db
- ✅ **缓存集成**：Redis缓存支持
- ✅ **统一构建**：优化的通用Dockerfile支持所有微服务
- ✅ **现有MySQL**：无需额外MySQL容器
- ✅ **智能端口**：通过环境变量动态配置端口

## 🎯 学习要点

通过 `/products/{id}/with-user` 接口可以清晰看到：
1. 商品服务调用用户服务获取用户信息
2. OpenFeign的声明式服务调用
3. 异常处理和降级机制