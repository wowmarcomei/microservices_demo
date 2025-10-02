# ---- 构建阶段 (Build Stage) ----
# 使用包含 Maven 和 JDK 的镜像作为构建环境
FROM maven:3.8-openjdk-8 AS builder

# 设置工作目录
WORKDIR /app

# 复制父项目pom.xml
COPY pom.xml .

# 复制所有子模块目录
COPY user-service/ ./user-service/
COPY product-service/ ./product-service/
COPY gateway-service/ ./gateway-service/

# 复制根目录的src（单体应用源码）
COPY src/ ./src/

# 执行打包命令 - 只打包子模块，跳过父项目
RUN mvn clean package -DskipTests -pl user-service,product-service,gateway-service


# ---- 运行阶段 (Runtime Stage) ----
# 使用一个非常小的 JRE 镜像作为最终的运行环境
FROM openjdk:8-jre-slim

WORKDIR /app

# 从构建阶段复制所有微服务的jar文件
# 创建一个启动脚本来选择要运行的服务
COPY --from=builder /app/user-service/target/*.jar user-service.jar
COPY --from=builder /app/product-service/target/*.jar product-service.jar
COPY --from=builder /app/gateway-service/target/*.jar gateway-service.jar

# 创建启动脚本
RUN cat > start.sh << 'EOF'
#!/bin/bash
SERVICE_NAME=${SERVICE_NAME:-user-service}
case $SERVICE_NAME in
  "user-service")
    echo "Starting User Service..."
    exec java $JAVA_OPTS -jar user-service.jar
    ;;
  "product-service")
    echo "Starting Product Service..."
    exec java $JAVA_OPTS -jar product-service.jar
    ;;
  "gateway-service")
    echo "Starting Gateway Service..."
    exec java $JAVA_OPTS -jar gateway-service.jar
    ;;
  *)
    echo "Unknown service: $SERVICE_NAME"
    echo "Available services: user-service, product-service, gateway-service"
    exit 1
    ;;
esac
EOF

# 设置脚本权限
RUN chmod +x start.sh

# 暴露端口（可通过环境变量覆盖）
# 默认暴露user-service端口，其他服务通过端口映射
EXPOSE 8080

# 设置JVM参数
ENV JAVA_OPTS="-Xmx512m -Xms256m"
ENV SERVICE_NAME="user-service"

# 启动应用
ENTRYPOINT ["./start.sh"]