# ---- 构建阶段 (Build Stage) ----
FROM maven:3.8-openjdk-8 AS builder

# 设置工作目录
WORKDIR /app

# 复制 pom.xml 和 src 目录
COPY pom.xml .
COPY src ./src

# 执行打包命令
RUN mvn clean package -DskipTests

# ---- 运行阶段 (Runtime Stage) ----
FROM openjdk:8-jre-slim

WORKDIR /app

# 从构建阶段复制jar文件
COPY --from=builder /app/target/product-service-*.jar app.jar

# 暴露端口
EXPOSE 8082

# 设置JVM参数
ENV JAVA_OPTS="-Xmx512m -Xms256m"

# 启动应用
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]