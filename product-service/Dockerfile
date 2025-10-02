# Product Service Dockerfile - 简化构建版本
# 适用于在项目根目录构建：docker build -f product-service/Dockerfile .

# 构建阶段
FROM maven:3.8-openjdk-8 AS builder

WORKDIR /app

# 复制父项目pom.xml
COPY pom.xml .

# 复制所有子模块的pom.xml先（优化缓存）
COPY user-service/pom.xml ./user-service/
COPY product-service/pom.xml ./product-service/
COPY gateway-service/pom.xml ./gateway-service/

# 下载依赖（缓存层）
RUN mvn dependency:go-offline -pl product-service

# 复制product-service源码
COPY product-service/src ./product-service/src

# 构建当前服务
RUN mvn clean package -DskipTests -pl product-service

# 运行阶段 - 使用轻量级的OpenJDK 8运行时
FROM openjdk:8-jre-slim

# 设置维护者信息
LABEL maintainer="microservices-team"
LABEL service="product-service"
LABEL version="1.0.0"

# 创建非root用户
RUN groupadd -r appuser && useradd -r -g appuser appuser

# 设置工作目录
WORKDIR /app

# 从构建阶段复制JAR文件
COPY --from=builder /app/product-service/target/product-service-*.jar app.jar

# 修改文件权限
RUN chown appuser:appuser app.jar

# 暴露端口
EXPOSE 8082

# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 设置JVM参数
ENV JAVA_OPTS="-Xmx512m -Xms256m -XX:+UseG1GC -XX:+PrintGCDetails -XX:+PrintGCTimeStamps"

# 切换到非root用户
USER appuser

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8082/actuator/health || exit 1

# 启动应用
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]