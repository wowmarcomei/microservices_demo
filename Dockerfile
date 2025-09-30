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

# 从上一个阶段 (builder) 中，复制打包好的 jar 文件
# 使用通配符支持不同的微服务名称
COPY --from=builder /app/target/*.jar app.jar

# 暴露端口（可通过环境变量覆盖）
EXPOSE 8080

# 设置JVM参数
ENV JAVA_OPTS="-Xmx512m -Xms256m"

# 启动应用
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]