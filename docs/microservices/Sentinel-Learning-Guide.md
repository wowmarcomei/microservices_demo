# Sentinel 学习指南 - 服务容错保护

## 章节概述

欢迎学习《微服务治理核心 —— Spring Cloud Alibaba 全家桶精讲》第3章：**服务容错保护 - Sentinel**

在微服务架构中，服务间的网络调用随时可能失败，单个服务的故障会引发雪崩效应，影响整个系统的稳定性。Sentinel 作为阿里巴巴开源的流控熔断组件，为我们提供了完整的服务容错保护解决方案。

## 学习目标

通过本章学习，您将掌握：

1. **理解分布式系统的雪崩效应**和服务容错的重要性
2. **掌握Sentinel核心概念**：资源、流控、熔断、降级
3. **熟练使用Sentinel Dashboard** 进行可视化配置管理
4. **实现流量控制规则**，保护系统资源
5. **配置熔断降级机制**，提升系统稳定性
6. **集成Sentinel与OpenFeign**，实现服务间容错
7. **应用热点参数限流**，保护热点数据

## 核心知识点

### 3.1 分布式系统的雪崩效应

在微服务架构中，服务间相互依赖，当某个服务出现故障时：
- **故障传播**：下游服务故障会影响上游服务
- **资源耗尽**：大量请求堆积，消耗系统资源
- **连锁反应**：整个调用链路都可能受到影响
- **系统崩溃**：最终导致整个系统不可用

### 3.2 Sentinel 核心概念

#### 资源 (Resource)
- 可以是任何东西，服务、方法、代码块等
- Sentinel 通过对资源的保护来实现系统稳定性

#### 流量控制 (Flow Control)
- **QPS 限流**：每秒查询率限制
- **线程数限流**：并发线程数限制
- **关联限流**：关联资源达到阈值时限流
- **链路限流**：针对特定调用链路限流

#### 熔断降级 (Circuit Breaking)
- **慢调用比例**：响应时间过长的调用达到一定比例
- **异常比例**：异常调用达到一定比例
- **异常数**：异常调用数达到阈值

#### 系统自适应保护
- **Load**：系统负载
- **CPU 使用率**：CPU 使用率
- **平均 RT**：所有入口流量的平均响应时间
- **入口 QPS**：所有入口流量的 QPS

### 3.3 技术栈版本

- **Spring Boot**: 2.7.5
- **Spring Cloud Alibaba**: 2021.0.4.0  
- **Sentinel Core**: 1.8.6
- **Sentinel Dashboard**: 1.8.6

## 环境要求

### 系统要求
- JDK 8 或更高版本
- Maven 3.6+
- 已启动的 Nacos 服务器 (172.24.238.72:8848)
- 已运行的微服务项目 (user-service, product-service)

### 端口规划
- **Sentinel Dashboard**: 8858
- **user-service**: 8081 (Sentinel端口: 8719)
- **product-service**: 8082 (Sentinel端口: 8720)

## 学习路径

### 第一步：理论学习 (15分钟)
1. 理解雪崩效应的危害
2. 学习Sentinel的核心概念
3. 了解流控、熔断、降级的区别

### 第二步：环境搭建 (20分钟)
1. 下载并启动 Sentinel Dashboard
2. 为微服务集成 Sentinel 依赖
3. 配置 Sentinel 与 Dashboard 的连接

### 第三步：流量控制实战 (30分钟)
1. 配置 QPS 限流规则
2. 配置线程数限流规则
3. 测试流控效果

### 第四步：熔断降级实战 (30分钟)
1. 配置慢调用比例熔断
2. 配置异常比例熔断
3. 实现自定义降级逻辑

### 第五步：服务间容错 (25分钟)
1. 集成 Sentinel 与 OpenFeign
2. 配置 Feign 客户端容错
3. 测试服务间调用保护

### 第六步：高级特性 (20分钟)
1. 热点参数限流
2. 系统自适应保护
3. 规则持久化

## 实战项目说明

我们将基于现有的微服务项目进行 Sentinel 集成：

### 保护场景
1. **用户服务保护**
   - 用户查询接口的 QPS 限流
   - 用户注册接口的熔断保护

2. **商品服务保护**  
   - 商品列表接口的流量控制
   - 热点商品查询的参数限流

3. **服务间调用保护**
   - user-service 调用 product-service 的容错
   - 网络异常时的降级处理

### 测试工具
- **压测工具**: Apache JMeter 或 curl 脚本
- **监控工具**: Sentinel Dashboard
- **日志分析**: 微服务日志输出

## 下一步行动

1. ✅ 确认 Nacos 服务正常运行
2. ✅ 确认 user-service 和 product-service 正常运行
3. 🔄 下载并启动 Sentinel Dashboard
4. ⏭️ 开始 Sentinel 集成实战

---

**准备好了吗？让我们开始 Sentinel 的精彩之旅！**

## 相关资源

- [Sentinel 官方文档](https://sentinelguard.io/zh-cn/)
- [Spring Cloud Alibaba Sentinel](https://github.com/alibaba/spring-cloud-alibaba/wiki/Sentinel)
- [Sentinel Dashboard 用户指南](https://sentinelguard.io/zh-cn/docs/dashboard.html)
