# Nacos Config 功能测试脚本

## 测试环境准备

1. **确保Nacos服务正常运行**
   ```bash
   # 检查Nacos服务状态
   curl http://localhost:8848/nacos/v1/ns/operator/metrics
   ```

2. **创建配置文件**
   
   在Nacos控制台（http://localhost:8848/nacos）创建以下配置：

   **配置1：common-config.yml**
   ```yaml
   # MySQL数据库配置
   spring:
     datasource:
       url: jdbc:mysql://172.24.238.72:3306/{database_name}?useSSL=false&serverTimezone=UTC
       username: root
       password: my-secret-pw
       driver-class-name: com.mysql.cj.jdbc.Driver

     # Redis配置
     redis:
       host: 172.24.238.72
       port: 6379

   # MyBatis Plus配置
   mybatis-plus:
     mapper-locations: classpath:/mapper/*.xml
     global-config:
       db-config:
         logic-delete-field: deleted # 全局逻辑删除字段

   # 应用动态配置（演示配置刷新功能）
   app:
     config:
       app-name: "微服务应用"
       version: "1.0.0"
       environment: "development"
       enable-caching: true
       cache-expire-minutes: 30
       max-connections: 100
   ```

   **配置2：user-service.yml**
   ```yaml
   # 用户服务数据库配置
   spring:
     datasource:
       url: jdbc:mysql://172.24.238.72:3306/user_db?useSSL=false&serverTimezone=UTC

   # 用户服务专用配置
   app:
     config:
       app-name: "用户服务"
   ```

   **配置3：product-service.yml**
   ```yaml
   # 商品服务数据库配置
   spring:
     datasource:
       url: jdbc:mysql://172.24.238.72:3306/product_db?useSSL=false&serverTimezone=UTC

   # 商品服务专用配置
   app:
     config:
       app-name: "商品服务"
       stock-warning-threshold: 10
   ```

## 功能测试步骤

### 1. 启动微服务
```bash
# 启动用户服务
cd user-service
mvn spring-boot:run

# 启动商品服务（新终端）
cd product-service
mvn spring-boot:run
```

### 2. 验证配置加载
```bash
# 检查用户服务配置
curl http://localhost:8081/users/config

# 检查商品服务配置
curl http://localhost:8082/products/config
```

### 3. 测试动态配置刷新

#### 步骤1：修改Nacos中的配置
在Nacos控制台修改 `common-config.yml`：
```yaml
app:
  config:
    app-name: "微服务应用-已更新"
    version: "1.0.1"
    environment: "production"
    enable-caching: false
    cache-expire-minutes: 60
    max-connections: 200
```

#### 步骤2：触发配置刷新
```bash
# 刷新用户服务配置
curl -X POST http://localhost:8081/actuator/refresh

# 刷新商品服务配置
curl -X POST http://localhost:8082/actuator/refresh
```

#### 步骤3：验证配置更新
```bash
# 再次检查配置是否更新
curl http://localhost:8081/users/config
curl http://localhost:8082/products/config
```

### 4. 验证数据库连接
```bash
# 测试用户服务数据库功能
curl http://localhost:8081/users

# 测试商品服务数据库功能
curl http://localhost:8082/products
```

### 5. 验证服务间调用
```bash
# 测试跨服务调用（商品服务调用用户服务）
curl http://localhost:8082/products/1/with-user
```

## 预期结果

1. **配置加载成功**：微服务启动时能够从Nacos加载配置
2. **动态刷新生效**：修改Nacos配置后，微服务能够实时获取最新配置
3. **数据库连接正常**：能够正常访问MySQL数据库
4. **Redis缓存可用**：缓存功能正常工作
5. **服务间通信正常**：OpenFeign调用成功

## 故障排除

### 常见问题1：配置加载失败
- 检查bootstrap.yml中的Nacos连接配置
- 确认Nacos中配置文件的Data ID和Group正确

### 常见问题2：动态刷新不生效
- 确保添加了@RefreshScope注解
- 检查/actuator/refresh端点是否可访问

### 常见问题3：数据库连接失败
- 验证数据库服务是否运行
- 检查IP地址和端口是否正确

### 常见问题4：服务发现失败
- 确认Nacos Discovery配置正确
- 检查服务是否在Nacos中注册成功