# Gateway Service Dockerfile - 优化版
# 使用轻量级的OpenJDK 8运行时
FROM openjdk:8-jre-slim

# 设置维护者信息
LABEL maintainer="microservices-team"
LABEL service="gateway-service"
LABEL version="1.0.0"

# 创建非root用户
RUN groupadd -r appuser && useradd -r -g appuser appuser

# 设置工作目录
WORKDIR /app

# 复制构建好的JAR文件（从Jenkins的target目录）
COPY target/gateway-service-*.jar app.jar

# 修改文件权限
RUN chown appuser:appuser app.jar

# 暴露端口
EXPOSE 8080

# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 设置JVM参数
ENV JAVA_OPTS="-Xmx512m -Xms256m -XX:+UseG1GC -XX:+PrintGCDetails -XX:+PrintGCTimeStamps"

# 切换到非root用户
USER appuser

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# 启动应用
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]