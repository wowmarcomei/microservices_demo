#!/bin/bash

echo "==========================================="
echo "简化版 Jenkins Pipeline 测试脚本"
echo "==========================================="

# 模拟Jenkins环境变量
export BUILD_NUMBER="${BUILD_NUMBER:-1}"
export WORKSPACE="${WORKSPACE:-$(pwd)}"
export JOB_NAME="${JOB_NAME:-microservices-pipeline}"

echo "模拟Jenkins环境:"
echo "  BUILD_NUMBER: $BUILD_NUMBER"
echo "  WORKSPACE: $WORKSPACE"
echo "  JOB_NAME: $JOB_NAME"
echo ""

# 检查环境
echo "🔍 环境检查..."
echo "Java版本:"
java -version
echo ""
echo "Maven版本:"
mvn -version
echo ""
echo "Docker版本:"
docker --version
echo ""

# 检查项目结构
echo "📁 项目结构检查..."
ls -la
echo ""

# 清理和编译
echo "🧹 清理项目..."
mvn clean
echo ""

echo "🔨 编译项目..."
mvn compile
if [ $? -ne 0 ]; then
    echo "❌ 编译失败!"
    exit 1
fi
echo ""

# 运行测试（可选）
echo "🧪 运行测试（可选，按Ctrl+C跳过）..."
read -t 10 -p "是否运行测试? (y/N): " run_tests
if [[ "$run_tests" =~ ^[Yy]$ ]]; then
    mvn test || echo "⚠️ 测试可能失败，继续构建..."
else
    echo "跳过测试"
fi
echo ""

# 打包
echo "📦 打包应用..."
mvn package -DskipTests
if [ $? -ne 0 ]; then
    echo "❌ 打包失败!"
    exit 1
fi
echo ""

# 检查生成的JAR文件
echo "✅ 检查生成的JAR文件..."
find . -name "*.jar" -type f | while read jar_file; do
    echo "  📄 $jar_file ($(du -h "$jar_file" | cut -f1))"
done
echo ""

# 构建Docker镜像
echo "🐳 构建Docker镜像..."
services=("user-service" "product-service" "gateway-service")

for service in "${services[@]}"; do
    if [ -f "$service/Dockerfile" ]; then
        echo "构建 $service 镜像..."
        cd "$service"
        
        # 构建镜像
        image_name="microservices/${service}:${BUILD_NUMBER}"
        image_latest="microservices/${service}:latest"
        
        docker build -t "$image_name" .
        if [ $? -eq 0 ]; then
            docker tag "$image_name" "$image_latest"
            echo "✅ $service 镜像构建成功: $image_name"
        else
            echo "❌ $service 镜像构建失败"
        fi
        
        cd ..
    else
        echo "⚠️ $service/Dockerfile 不存在，跳过"
    fi
done
echo ""

# 显示构建的镜像
echo "📋 构建的Docker镜像:"
docker images | grep "microservices" || echo "未找到相关镜像"
echo ""

# 清理（可选）
echo "🧹 清理Docker资源..."
read -t 10 -p "是否清理无用的Docker镜像? (y/N): " cleanup
if [[ "$cleanup" =~ ^[Yy]$ ]]; then
    docker image prune -f
    echo "清理完成"
else
    echo "跳过清理"
fi

echo ""
echo "==========================================="
echo "✅ Pipeline 测试完成!"
echo "==========================================="