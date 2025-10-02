#!/bin/bash

# 综合的本地构建测试脚本
# 合并了GitHub Actions构建测试和Docker构建测试
# 用法: ./test-build-comprehensive.sh [--skip-maven|--skip-docker|--wsl2-fix]

echo "🚀 综合构建测试脚本"
echo "🔧 支持Maven构建、Docker构建和WSL2权限修复"
echo ""

# 解析命令行参数
SKIP_MAVEN=false
SKIP_DOCKER=false
WSL2_FIX=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-maven)
            SKIP_MAVEN=true
            shift
            ;;
        --skip-docker)
            SKIP_DOCKER=true
            shift
            ;;
        --wsl2-fix)
            WSL2_FIX=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            echo "用法: $0 [选项]"
            echo ""
            echo "选项:"
            echo "  --skip-maven    跳过Maven构建测试"
            echo "  --skip-docker   跳过Docker构建测试"
            echo "  --wsl2-fix      启用WSL2权限修复"
            echo "  --verbose       显示详细输出"
            echo "  -h, --help      显示此帮助信息"
            echo ""
            echo "示例:"
            echo "  $0                    # 完整测试"
            echo "  $0 --skip-maven       # 只测试Docker构建"
            echo "  $0 --wsl2-fix         # 使用WSL2权限修复"
            exit 0
            ;;
        *)
            echo "未知参数: $1"
            echo "使用 $0 --help 查看帮助"
            exit 1
            ;;
    esac
done

# WSL2权限修复函数
fix_wsl2_permissions() {
    echo "🔧 修复WSL2文件权限问题..."
    find . -name "*.yml" -o -name "*.yaml" -o -name "*.properties" | xargs chmod 644 2>/dev/null || true
    find . -type d | xargs chmod 755 2>/dev/null || true
    chmod -R 755 . 2>/dev/null || true
    
    # 清理之前可能失败的构建
    echo "🧹 清理之前的构建文件..."
    mvn clean -q 2>/dev/null || true
    find . -name "target" -type d -exec rm -rf {} + 2>/dev/null || true
    echo "✅ WSL2权限修复完成"
    echo ""
}

# 检查WSL2环境
check_wsl2_environment() {
    if [[ "$PWD" == /mnt/* ]]; then
        echo "⚠️  检测到您在Windows文件系统中运行 ($PWD)"
        echo ""
        if [ "$WSL2_FIX" = true ]; then
            fix_wsl2_permissions
        else
            echo "💡 建议选项："
            echo "1. 使用 --wsl2-fix 参数自动修复权限"
            echo "2. 复制项目到WSL2文件系统："
            echo "   cp -r '$PWD' ~/monolith-app"
            echo "   cd ~/monolith-app"
            echo "   ./test-build-comprehensive.sh"
            echo ""
            read -p "是否继续当前位置的构建？(y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        fi
    else
        echo "✅ 在WSL2原生文件系统中运行"
        echo ""
    fi
}

# 环境检查函数
check_dependencies() {
    echo "🔍 检查依赖工具..."
    local deps_ok=true
    
    if ! command -v docker &> /dev/null; then
        echo "❌ Docker未安装"
        deps_ok=false
    else
        echo "✅ Docker已安装: $(docker --version | cut -d' ' -f3)"
    fi
    
    if ! command -v mvn &> /dev/null; then
        echo "❌ Maven未安装"
        deps_ok=false
    else
        echo "✅ Maven已安装: $(mvn --version | head -1 | cut -d' ' -f3)"
    fi
    
    if [ "$deps_ok" = false ]; then
        echo ""
        echo "❌ 依赖检查失败，请安装缺失的工具"
        exit 1
    fi
    
    echo "✅ 所有依赖检查通过"
    echo ""
}

# 项目结构分析
analyze_project_structure() {
    echo "📁 分析项目结构..."
    
    # 显示当前目录内容
    if [ "$VERBOSE" = true ]; then
        echo "📋 当前目录内容:"
        ls -la
        echo ""
    fi
    
    # 检查项目类型
    if [ -f "user-service/pom.xml" ]; then
        PROJECT_TYPE="multi-module"
        MODULES="user-service,product-service,gateway-service"
        echo "✅ 检测到多模块Maven项目"
        echo "📦 子模块: $MODULES"
        
        # 显示子模块信息
        echo "🔍 子模块详情:"
        for service in user-service product-service gateway-service; do
            if [ -d "$service" ]; then
                echo "  ✅ $service/"
                if [ -f "$service/Dockerfile" ]; then
                    echo "      - Dockerfile: ✅"
                else
                    echo "      - Dockerfile: ❌"
                fi
                if [ -f "$service/pom.xml" ]; then
                    echo "      - pom.xml: ✅"
                else
                    echo "      - pom.xml: ❌"
                fi
            else
                echo "  ❌ $service/ (不存在)"
            fi
        done
    else
        PROJECT_TYPE="single-module"
        MODULES=""
        echo "✅ 检测到单模块Maven项目"
    fi
    
    echo ""
}

# Maven构建测试
maven_build_test() {
    if [ "$SKIP_MAVEN" = true ]; then
        echo "⏭️  跳过Maven构建测试"
        return 0
    fi
    
    echo "🔨 Maven构建测试"
    echo "=================="
    
    # 设置Maven环境
    export MAVEN_OPTS="-Dmaven.repo.local=$HOME/.m2/repository"
    
    # 编译阶段
    echo "📝 执行Maven编译..."
    if [ -n "$MODULES" ]; then
        if [ "$VERBOSE" = true ]; then
            mvn clean compile -B -DskipTests=true -T 1C -pl "$MODULES"
        else
            mvn clean compile -B -DskipTests=true -T 1C -pl "$MODULES" -q
        fi
    else
        if [ "$VERBOSE" = true ]; then
            mvn clean compile -B -DskipTests=true -T 1C
        else
            mvn clean compile -B -DskipTests=true -T 1C -q
        fi
    fi
    
    if [ $? -ne 0 ]; then
        echo "❌ Maven编译失败"
        if [[ "$PWD" == /mnt/* ]] && [ "$WSL2_FIX" = false ]; then
            echo ""
            echo "💡 可能的解决方案:"
            echo "1. 重新运行并添加 --wsl2-fix 参数"
            echo "2. 复制项目到WSL2文件系统"
            echo "3. 检查Java版本兼容性"
        fi
        return 1
    fi
    echo "✅ Maven编译成功"
    
    # 打包阶段
    echo "📦 执行Maven打包..."
    if [ -n "$MODULES" ]; then
        if [ "$VERBOSE" = true ]; then
            mvn package -B -DskipTests=true -T 1C -pl "$MODULES"
        else
            mvn package -B -DskipTests=true -T 1C -pl "$MODULES" -q
        fi
    else
        if [ "$VERBOSE" = true ]; then
            mvn package -B -DskipTests=true -T 1C
        else
            mvn package -B -DskipTests=true -T 1C -q
        fi
    fi
    
    if [ $? -ne 0 ]; then
        echo "❌ Maven打包失败"
        return 1
    fi
    echo "✅ Maven打包成功"
    
    # 显示生成的JAR文件
    echo ""
    echo "📋 生成的JAR文件:"
    find . -name "*.jar" -path "*/target/*" | head -10
    echo ""
    
    return 0
}

# Docker构建测试
docker_build_test() {
    if [ "$SKIP_DOCKER" = true ]; then
        echo "⏭️  跳过Docker构建测试"
        return 0
    fi
    
    echo "🐳 Docker构建测试"
    echo "=================="
    
    local build_success=false
    
    # 方案1: 根目录多服务Dockerfile测试
    if [ "$PROJECT_TYPE" = "multi-module" ] && [ -f "Dockerfile" ]; then
        echo "🔨 测试方案1: 根目录多服务Dockerfile"
        
        if [ "$VERBOSE" = true ]; then
            docker build -t test-multi-service:latest . --no-cache
        else
            docker build -t test-multi-service:latest . --no-cache --quiet
        fi
        
        if [ $? -eq 0 ]; then
            echo "✅ 多服务Docker镜像构建成功"
            build_success=true
            
            # 测试服务启动
            echo ""
            echo "🧪 测试服务启动:"
            test_service_startup "user-service" "8081" "test-multi-service:latest"
            test_service_startup "product-service" "8082" "test-multi-service:latest"
            test_service_startup "gateway-service" "9090" "test-multi-service:latest"
        else
            echo "❌ 多服务Docker镜像构建失败"
        fi
        echo ""
    fi
    
    # 方案2: 独立微服务Dockerfile测试
    if [ "$PROJECT_TYPE" = "multi-module" ]; then
        echo "🔨 测试方案2: 独立微服务Dockerfile"
        
        for service in user-service product-service gateway-service; do
            if [ -f "$service/Dockerfile" ]; then
                echo "  构建 $service..."
                
                # 从项目根目录构建，指定Dockerfile路径
                if [ "$VERBOSE" = true ]; then
                    docker build -f "$service/Dockerfile" -t "test-$service:latest" . --no-cache
                else
                    docker build -f "$service/Dockerfile" -t "test-$service:latest" . --no-cache --quiet
                fi
                
                if [ $? -eq 0 ]; then
                    echo "  ✅ $service 独立Docker镜像构建成功"
                    build_success=true
                else
                    echo "  ❌ $service 独立Docker镜像构建失败"
                fi
            else
                echo "  ⚠️  $service/Dockerfile 不存在"
            fi
        done
        echo ""
    fi
    
    # 方案3: 单模块项目测试
    if [ "$PROJECT_TYPE" = "single-module" ] && [ -f "Dockerfile" ]; then
        echo "🔨 测试单模块Docker构建"
        
        if [ "$VERBOSE" = true ]; then
            docker build -t test-monolith:latest .
        else
            docker build -t test-monolith:latest . --quiet
        fi
        
        if [ $? -eq 0 ]; then
            echo "✅ 单模块Docker镜像构建成功"
            build_success=true
        else
            echo "❌ 单模块Docker镜像构建失败"
        fi
        echo ""
    fi
    
    if [ "$build_success" = false ]; then
        echo "❌ 所有Docker构建方案均失败"
        echo ""
        echo "🔍 故障排查建议:"
        echo "1. 检查Dockerfile语法"
        echo "2. 确保Maven构建成功"
        echo "3. 检查项目结构和文件路径"
        echo "4. 使用 --verbose 参数查看详细输出"
        return 1
    fi
    
    return 0
}

# 测试服务启动
test_service_startup() {
    local service_name=$1
    local port=$2
    local image=$3
    local container_name="test-$service_name"
    
    echo "    测试 $service_name..."
    
    # 清理可能存在的容器
    docker rm -f "$container_name" >/dev/null 2>&1
    
    # 启动容器
    docker run --rm -d --name "$container_name" \
        -e SERVICE_NAME="$service_name" \
        -p "$port:8080" \
        "$image" >/dev/null 2>&1
    
    # 等待启动
    sleep 8
    
    # 检查容器状态
    if docker ps | grep -q "$container_name"; then
        echo "    ✅ $service_name 启动成功"
        # 停止容器
        docker stop "$container_name" >/dev/null 2>&1
    else
        echo "    ❌ $service_name 启动失败"
        if [ "$VERBOSE" = true ]; then
            echo "    📋 容器日志:"
            docker logs "$container_name" 2>/dev/null | tail -5 | sed 's/^/        /'
        fi
        # 清理失败的容器
        docker rm -f "$container_name" >/dev/null 2>&1
    fi
}

# 显示构建结果
show_build_results() {
    echo "📊 构建结果摘要"
    echo "=================="
    
    echo "🐳 Docker镜像:"
    local images=$(docker images | grep "test-.*:latest")
    if [ -n "$images" ]; then
        echo "$images"
    else
        echo "  无成功构建的测试镜像"
    fi
    
    echo ""
    echo "📦 JAR文件:"
    local jars=$(find . -name "*.jar" -path "*/target/*" | head -5)
    if [ -n "$jars" ]; then
        echo "$jars"
    else
        echo "  无成功构建的JAR文件"
    fi
    
    echo ""
}

# 显示下一步建议
show_next_steps() {
    echo "💡 下一步建议"
    echo "=============="
    echo "1. 如果本地测试成功，可以推送到GitHub触发Actions"
    echo "2. 检查GitHub仓库的Actions权限设置:"
    echo "   - Settings > Actions > General"
    echo "   - 启用 'Read and write permissions'"
    echo "3. 确保GitHub Container Registry权限正确"
    echo "4. 推送代码触发自动构建:"
    echo "   git add ."
    echo "   git commit -m 'ci: 优化Docker构建配置'"
    echo "   git push origin main"
    echo ""
    echo "🔧 脚本用法提示:"
    echo "  ./test-build-comprehensive.sh --help    # 查看所有选项"
    echo "  ./test-build-comprehensive.sh --verbose # 详细输出模式"
    echo "  ./test-build-comprehensive.sh --wsl2-fix # WSL2权限修复"
    echo ""
}

# 主函数
main() {
    echo "开始时间: $(date)"
    echo ""
    
    # 检查WSL2环境
    check_wsl2_environment
    
    # 应用WSL2修复（如果需要）
    if [ "$WSL2_FIX" = true ]; then
        fix_wsl2_permissions
    fi
    
    # 依赖检查
    check_dependencies
    
    # 项目结构分析
    analyze_project_structure
    
    # Maven构建测试
    if ! maven_build_test; then
        echo ""
        echo "❌ Maven构建测试失败，停止后续测试"
        exit 1
    fi
    
    # Docker构建测试
    if ! docker_build_test; then
        echo ""
        echo "❌ Docker构建测试失败"
        # 不退出，继续显示结果
    fi
    
    # 显示结果
    echo ""
    show_build_results
    show_next_steps
    
    echo "🎉 综合构建测试完成！"
    echo "结束时间: $(date)"
}

# 执行主函数
main "$@"