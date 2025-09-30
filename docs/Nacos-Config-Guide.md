# Nacos Config 配置中心使用指南

## 1. 在Nacos控制台创建配置文件

请按照以下步骤在Nacos控制台创建配置文件：

### 1.1 访问Nacos控制台
- 地址：http://localhost:8848/nacos
- 用户名：nacos
- 密码：nacos

### 1.2 创建共享配置文件

**步骤1：** 点击"配置管理" -> "配置列表"

**步骤2：** 点击"+"按钮创建新配置

**配置1：公共配置**
- Data ID: `common-config.yml`
- Group: `DEFAULT_GROUP`
- 配置格式: `YAML`
- 配置内容: 复制 `nacos-config-templates/common-config.yml` 文件内容

**配置2：用户服务配置**
- Data ID: `user-service.yml`
- Group: `DEFAULT_GROUP`
- 配置格式: `YAML`
- 配置内容: 复制 `nacos-config-templates/user-service.yml` 文件内容

**配置3：商品服务配置**
- Data ID: `product-service.yml`
- Group: `DEFAULT_GROUP`
- 配置格式: `YAML`
- 配置内容: 复制 `nacos-config-templates/product-service.yml` 文件内容

## 2. 配置中心功能验证

### 2.1 启动顺序
1. 确保Nacos服务运行正常
2. 启动user-service微服务
3. 启动product-service微服务

### 2.2 验证配置加载
- 观察启动日志，查看是否成功从Nacos加载配置
- 检查数据库连接是否正常
- 验证Redis连接是否可用

### 2.3 动态配置刷新
- 在Nacos控制台修改配置
- 观察微服务是否自动刷新配置（需要添加@RefreshScope注解）

## 3. 配置文件说明

### 3.1 Bootstrap配置
- `bootstrap.yml` 在应用启动时优先加载
- 配置Nacos连接信息和共享配置

### 3.2 Application配置
- `application.yml` 保留本地必要配置
- 主要配置已迁移到Nacos中心化管理

### 3.3 配置优先级
1. Nacos远程配置（highest）
2. bootstrap.yml
3. application.yml（lowest）

## 4. 最佳实践

1. **配置分层管理**
   - 公共配置：common-config.yml
   - 服务特定配置：{service-name}.yml

2. **敏感信息处理**
   - 数据库密码等敏感信息应使用Nacos的加密功能
   - 生产环境建议使用独立的namespace

3. **配置版本管理**
   - Nacos支持配置历史版本管理
   - 可以回滚到任意历史版本

4. **环境隔离**
   - 使用namespace实现不同环境的配置隔离
   - dev、test、prod环境独立管理