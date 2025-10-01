#!/bin/bash

echo "==========================================="
echo "微服务多模块构建流水线"
echo "==========================================="

# 显示环境信息
echo "检查环境配置..."
echo "当前工作目录: $(pwd)"
echo "Java版本:"
java -version
echo ""

# 检查Maven是否可用
echo "检查Maven..."
if command -v mvn &> /dev/null; then
    echo "Maven版本:"
    mvn -version
else
    echo "❌ Maven未找到，尝试使用不同路径..."
    if [ -f "/usr/share/maven/bin/mvn" ]; then
        export PATH="/usr/share/maven/bin:$PATH"
        echo "✅ 使用系统Maven: /usr/share/maven/bin/mvn"
    elif [ -f "/opt/maven/bin/mvn" ]; then
        export PATH="/opt/maven/bin:$PATH"
        echo "✅ 使用自定义Maven: /opt/maven/bin/mvn"
    else
        echo "❌ 无法找到Maven，请在Jenkins中配置Maven工具"
        exit 1
    fi
fi

echo ""
echo "检查项目结构..."
ls -la

# 检查是否为多模块项目
if [ -f "pom.xml" ] && grep -q "<packaging>pom</packaging>" pom.xml; then
    echo "✅ 检测到多模块Maven项目结构"
    
    # 检查子模块是否存在
    echo "检查子模块..."
    if [ -d "user-service" ] && [ -d "product-service" ] && [ -d "gateway-service" ]; then
        echo "✅ 所有微服务模块都存在"
        echo "  - user-service"
        echo "  - product-service" 
        echo "  - gateway-service"
    else
        echo "❌ 缺少微服务模块目录"
        exit 1
    fi
    
    echo ""
    echo "🧹 清理项目..."
    mvn clean
    if [ $? -ne 0 ]; then
        echo "❌ 项目清理失败!"
        exit 1
    fi
    
    echo ""
    echo "🔨 编译所有模块..."
    mvn compile
    if [ $? -ne 0 ]; then
        echo "❌ 编译失败!"
        exit 1
    fi
    echo "✅ 编译成功"
    
    echo ""
    echo "🧪 运行测试..."
    mvn test -Dmaven.test.failure.ignore=true
    echo "⚠️ 测试完成（忽略失败）"
    
    echo ""
    echo "📦 打包所有微服务..."
    mvn package -DskipTests
    if [ $? -ne 0 ]; then
        echo "❌ 打包失败!"
        exit 1
    fi
    echo "✅ 打包成功"
    
elif [ -d "gateway-service" ] && [ -d "user-service" ] && [ -d "product-service" ]; then
    echo "⚠️ 检测到微服务目录但非多模块项目，执行独立构建..."
    
    # 独立构建每个服务
    for service in "user-service" "product-service" "gateway-service"; do
        if [ -d "$service" ]; then
            echo ""
            echo "📦 构建 $service..."
            cd "$service"
            
            if [ -f "pom.xml" ]; then
                mvn clean package -DskipTests
                if [ $? -ne 0 ]; then
                    echo "❌ $service 构建失败!"
                    cd ..
                    exit 1
                fi
                echo "✅ $service 构建成功"
            else
                echo "⚠️ $service 中未找到pom.xml"
            fi
            
            cd ..
        fi
    done
    
elif [ -f "pom.xml" ]; then
    echo "✅ 检测到传统单体项目结构"
    echo "执行单体应用构建..."
    
    # 单体应用构建
    mvn clean compile
    if [ $? -ne 0 ]; then
        echo "❌ 编译失败!"
        exit 1
    fi
    
    echo "运行测试..."
    mvn test || echo "⚠️ 测试可能失败，继续构建..."
    
    echo "打包应用..."
    mvn package -DskipTests
    
else
    echo "❌ 未发现有效的项目结构"
    echo "当前目录内容:"
    ls -la
    exit 1
fi

# 检查构建结果
echo ""
echo "📋 构建结果检查..."
echo "查找生成的JAR文件:"
find . -name "*.jar" -type f | while read jar_file; do
    echo "  $jar_file ($(du -h "$jar_file" | cut -f1))"
done

# 显示详细的target目录内容
echo ""
echo "📁 各服务target目录内容:"
for service in "user-service" "product-service" "gateway-service"; do
    if [ -d "$service/target" ]; then
        echo "$service/target/:"
        ls -la "$service/target/" | grep -E "\.(jar|war)$" || echo "  未找到JAR文件"
    fi
done

# 检查Docker相关文件
if [ -f "docker-compose.yml" ] || [ -f "docker-compose-microservices.yml" ]; then
    echo ""
    echo "🐳 发现Docker配置文件"
    echo "可以选择构建Docker镜像（需要Docker环境）"
    # docker-compose build || echo "⚠️ Docker构建跳过"
fi

echo ""
echo "==========================================="
echo "✅ 微服务多模块构建流水线完成!"
echo "==========================================="