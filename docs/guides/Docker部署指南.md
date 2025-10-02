# Docker 部署指南

本指南说明如何使用 Docker 和 Docker Compose 部署电商单体应用。

## 环境要求

- Docker 20.10+
- Docker Compose 1.29+

## 快速启动

### 1. 构建并启动所有服务

```bash
# 构建并启动所有服务
docker-compose up -d

# 查看服务状态
docker-compose ps
```

### 2. 查看日志

```bash
# 查看所有服务日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs -f monolith-app
```

### 3. 停止服务

```bash
# 停止所有服务
docker-compose down

# 停止服务并删除数据卷
docker-compose down -v
```

## 服务说明

### monolith-app
- **端口**: 8080
- **描述**: 电商单体应用主服务
- **健康检查**: 通过 `/actuator/health` 端点检查
- **访问地址**: http://localhost:8080
- **API文档**: http://localhost:8080/swagger-ui.html

### mysql
- **端口**: 3306
- **描述**: MySQL 数据库
- **数据库名**: monolith_db
- **用户名**: root
- **密码**: my-secret-pw
- **数据持久化**: mysql-data 卷

### redis
- **端口**: 6379
- **描述**: Redis 缓存服务
- **数据持久化**: redis-data 卷

### rabbitmq
- **端口**: 5672 (AMQP), 15672 (管理界面)
- **描述**: RabbitMQ 消息队列
- **用户名**: guest
- **密码**: guest
- **管理界面**: http://localhost:15672
- **数据持久化**: rabbitmq-data 卷

## 配置说明

### 应用配置
应用配置在 `docker-compose.yml` 中设置：
- 数据库连接: `jdbc:mysql://mysql:3306/monolith_db`
- Redis 连接: `redis:6379`
- RabbitMQ 连接: `rabbitmq:5672`

### 数据库初始化
数据库表结构通过以下方式初始化：
1. `schema_utf8.sql` 文件会自动挂载到 MySQL 的 `/docker-entrypoint-initdb.d/` 目录
2. 容器首次启动时会自动执行 SQL 脚本创建表结构

## 验证部署

### 1. 验证应用服务
```bash
# 测试应用是否正常运行
curl http://localhost:8080/hello

# 查看 API 文档
open http://localhost:8080/swagger-ui.html
```

### 2. 验证数据库
```bash
# 进入 MySQL 容器
docker exec -it mysql-db mysql -uroot -pmy-secret-pw

# 检查数据库
mysql> SHOW DATABASES;
mysql> USE monolith_db;
mysql> SHOW TABLES;
```

### 3. 验证 Redis
```bash
# 进入 Redis 容器
docker exec -it redis-cache redis-cli

# 测试连接
127.0.0.1:6379> PING
PONG
```

### 4. 验证 RabbitMQ
```bash
# 访问管理界面
open http://localhost:15672

# 使用 guest/guest 登录
```

## 开发模式

### 单独构建应用镜像
```bash
# 构建 Docker 镜像
docker build -t monolith-app:latest .

# 运行单个容器
docker run -p 8080:8080 monolith-app:latest
```

### 开发时热重载
```bash
# 挂载源代码进行开发
docker run -p 8080:8080 \
  -v $(pwd)/src:/app/src \
  monolith-app:latest
```

## 故障排除

### 常见问题

1. **端口被占用**
   ```bash
   # 检查端口占用
   netstat -an | grep 8080

   # 修改 docker-compose.yml 中的端口映射
   ports:
     - "8081:8080"  # 使用其他端口
   ```

2. **数据库连接失败**
   ```bash
   # 检查 MySQL 容器状态
   docker-compose logs mysql

   # 检查数据库初始化
   docker exec mysql-db mysql -uroot -pmy-secret-pw -e "SHOW DATABASES;"
   ```

3. **Redis 连接失败**
   ```bash
   # 检查 Redis 容器状态
   docker-compose logs redis

   # 测试 Redis 连接
   docker exec redis-cache redis-cli ping
   ```

4. **应用启动失败**
   ```bash
   # 查看应用日志
   docker-compose logs monolith-app

   # 检查应用健康状态
   curl http://localhost:8080/actuator/health
   ```

### 清理环境
```bash
# 停止所有服务并删除容器
docker-compose down

# 删除所有相关镜像
docker r monolith-app:latest

# 清理所有数据卷
docker volume rm monolith-app_mysql-data monolith-app_redis-data monolith-app_rabbitmq-data
```

## 性能优化

### Dockerfile 优化
- 使用多阶段构建减小镜像大小
- 利用 Docker 层缓存优化构建速度
- 设置合适的 JVM 参数

### 资源限制
```yaml
services:
  monolith-app:
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 1G
        reservations:
          cpus: '0.5'
          memory: 512M
```

## 安全注意事项

1. **修改默认密码**: 生产环境中修改 RabbitMQ 和 MySQL 的默认密码
2. **网络安全**: 使用自定义网络限制容器间通信
3. **数据安全**: 定期备份重要数据卷
4. **镜像安全**: 定期更新基础镜像和安全补丁