# Nacos服务发现测试指南

## 🚀 启动步骤

### 1. 确保Nacos已启动
```bash
# 检查Nacos是否正常运行
curl http://localhost:8848/nacos/
```

### 2. 编译并启动服务

#### 启动用户服务
```bash
cd user-service
mvn clean compile
mvn spring-boot:run
```

#### 启动商品服务
```bash
cd product-service  
mvn clean compile
mvn spring-boot:run
```

### 3. 验证服务注册

访问Nacos控制台：http://localhost:8848/nacos
- 用户名/密码：nacos/nacos
- 查看"服务管理" -> "服务列表"
- 应该能看到：user-service 和 product-service

### 4. 测试服务发现

```bash
# 测试用户服务
curl http://localhost:8081/users/1

# 测试商品服务
curl http://localhost:8082/products/1

# 🎯 关键测试：服务间调用（通过服务名）
curl http://localhost:8082/products/1/with-user
```

### 5. 验证负载均衡

#### 启动第二个用户服务实例
```bash
cd user-service
mvn spring-boot:run -Dspring-boot.run.arguments="--server.port=8083"
```

#### 测试负载均衡
```bash
# 多次调用，观察日志切换
for i in {1..10}; do
    curl http://localhost:8082/products/1/with-user
    echo ""
    sleep 1
done
```

## 🎯 期望结果

1. ✅ 两个服务成功注册到Nacos
2. ✅ OpenFeign通过服务名调用成功  
3. ✅ 多实例自动负载均衡
4. ✅ 服务下线后自动从注册中心移除

## 🔍 问题排查

如果遇到问题，检查：
1. Nacos是否正常启动（8848端口）
2. 服务启动日志是否有错误
3. application.yml中Nacos地址是否正确