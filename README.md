# 微服务架构学习项目

本项目是一个完整的Spring Boot微服务架构学习项目，从单体应用演进到微服务架构，涵盖了服务注册发现、配置中心、网关、限流熔断等微服务核心组件。

## 📁 项目结构

### 🗂 核心业务模块
```
├── user-service/           # 用户服务
├── product-service/        # 商品服务
├── gateway-service/        # 网关服务
└── src/                   # 原单体应用代码
```

### 📚 文档目录 (docs/)
```
docs/
├── project/               # 项目相关文档
│   └── 项目总体说明.md     # 项目整体介绍和架构
├── tutorials/             # 教程文档
│   ├── 微服务开发完整课程.md # 完整的微服务开发教程
│   ├── 1-springboot-单体应用.md
│   └── 1-springboot-单体应用README-Docker.md
├── guides/                # 操作指南
│   ├── Docker部署指南.md   # Docker容器化部署
│   ├── Docker-Build-Guide.md # Docker构建完整指南
│   ├── Gateway-Learning-Guide.md # 网关学习指南
│   ├── Jenkins-Build-Fix-Guide.md
│   ├── Jenkins-GitHub-Quick-Setup.md
│   ├── Jenkins-Local-Git-Setup.md
│   └── Jenkins-Pipeline-Guide.md
└── microservices/         # 微服务专项文档
    ├── README-Nacos.md    # Nacos配置说明
    ├── microservice-startup-success.md
    ├── Nacos-Config-Guide.md
    ├── Nacos-Config-Test-Guide.md
    ├── Sentinel-Complete-Guide.md
    ├── Sentinel-Dashboard-Setup.md
    ├── Sentinel-Getting-Started.md
    ├── Sentinel-Integration-Summary.md
    └── Sentinel-Learning-Guide.md
```

### 🔧 脚本目录 (scripts/)
```
scripts/
├── build/                 # 构建相关脚本
│   ├── test-build-comprehensive.sh  # 综合构建测试脚本
│   └── test-pipeline.sh   # 流水线测试脚本
├── startup/               # 启动相关脚本
│   ├── start-sentinel-dashboard.bat
│   └── start-sentinel-docker.bat
├── test/                  # 测试相关脚本
└── windows/               # Windows批处理文件
    ├── test-gateway.bat
    ├── test-nacos-config-cn.bat
    ├── test-nacos-config.bat
    ├── test-sentinel-integration.bat
    └── verify-sentinel-config.bat
```

### 📦 配置文件
```
├── docker-compose.yml     # Docker Compose配置
├── docker-compose-microservices.yml
├── Dockerfile            # 多服务Docker构建
├── Jenkinsfile          # Jenkins流水线配置
├── init-microservices-db.sql  # 数据库初始化脚本
├── .github/workflows/    # GitHub Actions CI/CD
└── nacos-config-templates/ # Nacos配置模板
```

## 🚀 快速开始

### 0. 数据库初始化 📊

项目提供了完整的数据库初始化脚本 `init-microservices-db.sql`，用于：

#### 🗃️ 数据库结构
```sql
-- 创建两个独立的微服务数据库
user_db      # 用户服务数据库
product_db   # 商品服务数据库
```

#### 📋 数据表说明

**用户数据库 (user_db)**
- `users` - 用户信息表
  - 支持用户名、邮箱、手机号等完整用户信息
  - 包含状态管理和逻辑删除
  - 自动时间戳管理

**商品数据库 (product_db)**
- `categories` - 商品分类表（支持多级分类）
- `brands` - 品牌信息表
- `products` - 商品信息表
  - 完整的商品属性（名称、价格、库存、状态等）
  - 关联分类和品牌
  - category_id字段特殊用作创建者用户ID（演示服务间调用）

#### 🔧 初始化步骤

**方式1: 直接执行SQL脚本**
```bash
# 连接MySQL数据库
mysql -u root -p

# 执行初始化脚本
source init-microservices-db.sql
```

**方式2: 使用Docker MySQL**
```bash
# 启动MySQL容器
docker run -d --name mysql-microservices \
  -e MYSQL_ROOT_PASSWORD=123456 \
  -e MYSQL_DATABASE=user_db \
  -p 3306:3306 \
  mysql:8.0

# 等待MySQL启动完成
sleep 30

# 执行初始化脚本
docker exec -i mysql-microservices mysql -uroot -p123456 < init-microservices-db.sql
```

**方式3: 使用数据库管理工具**
- 使用Navicat、DBeaver、phpMyAdmin等工具
- 导入 `init-microservices-db.sql` 文件
- 执行脚本完成初始化

#### 📊 测试数据

脚本会自动插入测试数据：

**用户数据 (3条)**
- admin (管理员) - admin@example.com
- testuser (测试用户) - test@example.com  
- john (普通用户) - john@example.com

**商品数据 (5条)**
- iPhone 14 Pro - ¥7999.00
- Samsung Galaxy S23 - ¥6999.00
- 华为Mate 50 Pro - ¥6499.00
- iPhone 14 - ¥5999.00
- MacBook Pro - ¥14999.00

**分类数据 (3条)**
- 电子产品、手机数码、服装鞋包

**品牌数据 (3条)**
- Apple、Samsung、Huawei

#### 🔍 数据验证

初始化完成后，脚本会自动显示数据统计：
```sql
-- 验证结果示例
用户数据库 - 用户数量: 3
商品数据库 - 商品数量: 5  
商品数据库 - 分类数量: 3
商品数据库 - 品牌数量: 3
```

#### ⚠️ 注意事项

1. **数据迁移支持** - 如果已有 `monolith_db` 数据库，脚本会自动迁移现有数据
2. **数据安全** - 使用 `INSERT IGNORE` 避免重复插入
3. **字符编码** - 统一使用 `utf8mb4` 支持emoji和特殊字符
4. **索引优化** - 为查询字段创建了必要的索引
5. **逻辑删除** - 支持软删除，数据安全性更高

### 1. 构建测试
```bash
# 运行综合构建测试
chmod +x scripts/build/test-build-comprehensive.sh
./scripts/build/test-build-comprehensive.sh
```

### 2. 服务启动
```bash
# 启动Nacos服务注册中心
docker run -d --name nacos -p 8848:8848 nacos/nacos-server

# 启动Sentinel控制台
./scripts/startup/start-sentinel-dashboard.bat

# 使用Docker Compose启动所有微服务
docker-compose -f docker-compose-microservices.yml up -d
```

### 3. 验证服务
- **Nacos控制台**: http://localhost:8848/nacos (nacos/nacos)
- **Sentinel控制台**: http://localhost:8080 (sentinel/sentinel)  
- **用户服务**: http://localhost:8081
- **商品服务**: http://localhost:8082
- **网关服务**: http://localhost:9090

## 📖 学习路径

### 阶段1: 基础准备
1. 阅读 `docs/project/项目总体说明.md` 了解项目架构
2. 学习 `docs/tutorials/微服务开发完整课程.md` 掌握理论基础
3. **执行 `init-microservices-db.sql` 初始化数据库** 📊

### 阶段2: 环境搭建
1. 参考 `docs/guides/Docker部署指南.md` 配置Docker环境
2. 使用 `scripts/build/test-build-comprehensive.sh` 验证构建环境

### 阶段3: 微服务开发
1. 服务注册发现: `docs/microservices/README-Nacos.md`
2. 服务网关: `docs/guides/Gateway-Learning-Guide.md`
3. 流量控制: `docs/microservices/Sentinel-Complete-Guide.md`

### 阶段4: DevOps实践
1. CI/CD流水线: `docs/guides/Jenkins-Pipeline-Guide.md`
2. 容器化部署: `docs/guides/Docker-Build-Guide.md`

## 🛠 开发工具

- **IDE**: IntelliJ IDEA 推荐
- **Java**: JDK 8+
- **构建工具**: Maven 3.6+
- **容器**: Docker + Docker Compose
- **注册中心**: Nacos
- **网关**: Spring Cloud Gateway
- **限流熔断**: Sentinel
- **CI/CD**: Jenkins / GitHub Actions

## 📞 技术支持

如遇到问题，请参考相应的文档：
- 构建问题: `docs/guides/Docker-Build-Guide.md`
- 配置问题: `docs/microservices/Nacos-Config-Guide.md`
- 部署问题: `docs/guides/Jenkins-Build-Fix-Guide.md`

## 🎯 项目特色

- ✅ **完整的微服务架构演进路径**
- ✅ **详细的学习文档和操作指南**
- ✅ **自动化构建和部署脚本**
- ✅ **Docker容器化支持**
- ✅ **CI/CD流水线集成**
- ✅ **生产级配置和最佳实践**

---

> 这是一个学习项目，适合初学者掌握微服务架构的设计理念和实现技术。通过实践操作，可以深入理解微服务架构的核心概念和关键技术。