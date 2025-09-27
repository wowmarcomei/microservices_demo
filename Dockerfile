# ---- 构建阶段 (Build Stage) ----
# 使用包含 Maven 和 JDK 的镜像作为构建环境
FROM maven:3.8-openjdk-8 AS builder

# 设置工作目录
WORKDIR /app

# 复制 pom.xml 和 src 目录
COPY pom.xml .
COPY src ./src

# 执行打包命令
RUN mvn clean package -DskipTests


# ---- 运行阶段 (Runtime Stage) ----
# 使用一个非常小的 JRE 镜像作为最终的运行环境
FROM openjdk:8-jre-slim

WORKDIR /app

# 从上一个阶段 (builder) 中，只复制打包好的 jar 文件
COPY --from=builder /app/target/monolith-app-*.jar app.jar

# 暴露端口
EXPOSE 8080

# 设置JVM参数
ENV JAVA_OPTS="-Xmx512m -Xms256m"

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# 启动应用
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]