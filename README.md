# 电商单体应用 - 从单体到微服务实战

## 项目简介

本项目是"从单体到微服务 —— Spring Boot 应用重构实战"课程的第二章实战项目，实现了一个完整的电商单体应用。该应用包含用户管理、商品管理、Redis缓存集成、API文档等功能。

## 技术栈

- **框架**: Spring Boot 2.7.5
- **数据库**: MySQL 5.7
- **缓存**: Redis 6-alpine
- **消息队列**: RabbitMQ 3-management
- **ORM框架**: MyBatis Plus 3.5.2
- **API文档**: SpringDoc OpenAPI
- **构建工具**: Maven 3.6.3
- **开发工具**: Lombok

## 项目结构

```
monolith-app/
├── src/main/java/com/example/monolithapp/
│   ├── controller/          # 控制器层
│   │   ├── UserController.java
│   │   ├── ProductController.java
│   │   └── ConfigController.java
│   ├── service/            # 服务层
│   │   ├── UserService.java
│   │   ├── ProductService.java
│   │   └── impl/
│   ├── mapper/             # 数据访问层
│   │   ├── UserMapper.java
│   │   └── ProductMapper.java
│   ├── entity/             # 实体类
│   │   ├── User.java
│   │   └── Product.java
│   ├── config/             # 配置类
│   │   ├── RedisConfig.java
│   │   └── MybatisPlusConfig.java
│   ├── common/             # 通用类
│   │   └── Result.java
│   └── MonolithAppApplication.java
├── src/main/resources/
│   ├── application.yml     # 应用配置
│   └── db/
│       ├── schema.sql      # 数据库结构脚本
│       └── schema_utf8.sql # UTF-8编码数据库结构脚本
└── pom.xml                 # Maven依赖配置
```

## 环境要求

### 必需软件
- JDK 1.8+
- Maven 3.6+
- Docker 20+
- MySQL 客户端 (如 Navicat)

### 中间件服务
通过 Docker 启动以下服务：

#### 1. MySQL 数据库
```bash
docker run --name my-mysql \
  -v mysql-data:/var/lib/mysql \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=my-secret-pw \
  -d mysql:5.7
```

#### 2. Redis 缓存
```bash
docker run --name my-redis \
  -p 6379:6379 \
  -d redis:6-alpine
```

#### 3. RabbitMQ 消息队列
```bash
docker run --name my-rabbitmq \
  -p 5672:5672 \
  -p 15672:15672 \
  -d rabbitmq:3-management
```

## 项目启动

### 1. 数据库初始化

使用 Navicat 或 MySQL 命令行工具执行 `src/main/resources/db/schema_utf8.sql` 脚本创建数据库和表结构。

### 2. 启动中间件服务

确保上述 Docker 容器都已正常运行。

### 3. 修改配置文件

根据您的环境修改 `application.yml` 中的连接配置：

```yaml
datasource:
  url: jdbc:mysql://172.24.238.72:3306/monolith_db?useSSL=false&serverTimezone=UTC
  username: root
  password: my-secret-pw
  driver-class-name: com.mysql.cj.jdbc.Driver

redis:
  host: 172.24.238.72
  port: 6379

rabbitmq:
  host: 172.24.238.72
  port: 5672
  username: guest
  password: guest
```

### 4. 编译和运行应用

```bash
# 编译项目
mvn compile

# 运行应用
mvn spring-boot:run
```

应用启动后，可以通过以下地址访问：
- 应用主页: http://localhost:8080
- API文档: http://localhost:8080/swagger-ui/index.html
- RabbitMQ管理界面: http://localhost:15672 (guest/guest)

## API 接口

### 用户管理接口

#### 获取用户列表
```bash
GET /users
```

#### 根据ID获取用户
```bash
GET /users/{id}
```

#### 创建用户
```bash
POST /users
Content-Type: application/json

{
  "username": "testuser",
  "password": "password",
  "email": "test@example.com"
}
```

#### 更新用户
```bash
PUT /users/{id}
Content-Type: application/json

{
  "username": "updateduser",
  "email": "updated@example.com"
}
```

#### 删除用户
```bash
DELETE /users/{id}
```

### 商品管理接口

#### 获取商品列表
```bash
GET /products
```

#### 根据ID获取商品
```bash
GET /products/{id}
```

#### 创建商品
```bash
POST /products
Content-Type: application/json

{
  "name": "新商品",
  "description": "商品描述",
  "price": 99.99,
  "stock": 100,
  "categoryId": 1,
  "brandId": 1
}
```

#### 更新商品
```bash
PUT /products/{id}
Content-Type: application/json

{
  "name": "更新后的商品",
  "price": 199.99,
  "stock": 50
}
```

#### 删除商品
```bash
DELETE /products/{id}
```

### 配置管理接口

#### 获取配置信息
```bash
GET /config/greeting
GET /config/feature-status
```

### 响应格式

所有接口都返回统一格式的 JSON 响应：

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    // 具体数据
  }
}
```

## Redis 缓存

### 缓存配置
- 用户信息缓存键名: `users:{id}`
- 默认缓存过期时间: 30分钟

### 缓存注解
- `@Cacheable`: 缓存查询结果
- `@CachePut`: 更新缓存
- `@CacheEvict`: 删除缓存

## 数据库设计

### 用户表 (users)
| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT | 用户ID (主键) |
| username | VARCHAR(50) | 用户名 |
| password | VARCHAR(255) | 密码 |
| email | VARCHAR(100) | 邮箱 |
| created_time | DATETIME | 创建时间 |
| updated_time | DATETIME | 更新时间 |
| deleted | TINYINT | 逻辑删除标记 |

### 商品表 (products)
| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT | 商品ID (主键) |
| name | VARCHAR(100) | 商品名称 |
| description | TEXT | 商品描述 |
| price | DECIMAL(10,2) | 商品价格 |
| stock | INT | 库存数量 |
| category_id | BIGINT | 分类ID |
| brand_id | BIGINT | 品牌ID |
| created_time | DATETIME | 创建时间 |
| updated_time | DATETIME | 更新时间 |
| deleted | TINYINT | 逻辑删除标记 |

## 开发指南

### 添加新模块
1. 在 `entity` 包中创建实体类
2. 在 `mapper` 包中创建 Mapper 接口
3. 在 `service` 包中创建 Service 接口和实现
4. 在 `controller` 包中创建 Controller
5. 添加对应的缓存注解和 API 文档注解

### 数据库迁移
1. 修改 `schema_utf8.sql` 文件
2. 使用 Navicat 执行更新脚本

### 配置管理
修改 `application.yml` 文件中的配置项，重启应用即可生效。

## 常见问题

### 1. 数据库连接失败
- 检查 Docker 容器是否运行
- 确认数据库连接参数是否正确
- 检查防火墙设置

### 2. Redis 连接失败
- 检查 Redis 容器是否运行
- 确认 Redis 连接参数

### 3. 应用启动失败
- 检查端口 8080 是否被占用
- 检查依赖是否完整
- 查看 application.yml 配置

### 4. 中文乱码
- 确保使用 UTF-8 编码
- 执行 schema_utf8.sql 脚本而非 schema.sql

## 课程学习

本项目对应"从单体到微服务 —— Spring Boot 应用重构实战"课程的第二章，后续课程将介绍如何将此单体应用逐步重构为微服务架构。

## 许可证

本项目仅供学习使用。