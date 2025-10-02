# Jenkins Pipeline as Code 配置指南

## 第5课第3章：Jenkins Pipeline as Code 实战

### 📋 学习目标

- 理解 Pipeline as Code 的优势
- 掌握 Jenkinsfile 的声明式流水线语法
- 编写 Jenkinsfile 实现应用的自动化构建和 Docker 镜像打包
- 将镜像推送到私有仓库，并管理凭证

### 🎯 Pipeline as Code 的核心优势

1. **版本控制**: 流水线定义与代码一起存储在Git仓库中
2. **可复用性**: 可以创建模板化的流水线
3. **可恢复性**: Jenkins服务器宕机后可快速恢复
4. **团队协作**: 团队成员都可以查看和修改流水线定义

### 🛠 环境准备

#### 1. Jenkins工具配置

在Jenkins中配置以下工具（Manage Jenkins > Global Tool Configuration）：

- **JDK**: 配置JDK 8，命名为 `JDK8`
- **Maven**: 配置Maven 3.8+，命名为 `Maven3.8`
- **Docker**: 确保Jenkins所在机器已安装Docker

#### 2. 插件安装

必需插件：
- Pipeline插件组（通常已默认安装）
- Docker Pipeline插件
- Blue Ocean插件（可选，提供更好的可视化）

### 📝 在Jenkins中创建Pipeline项目

#### 步骤1：创建新项目

1. 点击 "New Item"
2. 输入项目名称：`microservices-pipeline`
3. 选择 "Pipeline"
4. 点击 "OK"

#### 步骤2：配置Pipeline

**General配置**：
- ✅ 勾选 "GitHub project"（如果使用GitHub）
- 项目URL：`https://github.com/your-username/monolith-app`

**Build Triggers**：
- ✅ 勾选 "Poll SCM"
- Schedule: `H/5 * * * *` （每5分钟检查一次代码变更）

**Pipeline配置**：
- Definition: `Pipeline script from SCM`
- SCM: `Git`
- Repository URL: `https://github.com/your-username/monolith-app.git`
- Credentials: 添加你的Git凭证
- Branch: `*/main` 或 `*/master`
- Script Path: `Jenkinsfile`

#### 步骤3：高级配置

**参数化构建**：
已在Jenkinsfile中通过parameters块定义：
- `BUILD_TYPE`: 构建环境类型
- `SKIP_TESTS`: 是否跳过测试
- `PUSH_IMAGES`: 是否推送镜像

### 🔐 凭证管理

#### 添加Docker Registry凭证

1. 进入 "Manage Jenkins" > "Manage Credentials"
2. 选择 "Global" domain
3. 点击 "Add Credentials"
4. 类型选择 "Username with password"
5. 配置：
   - Username: Docker Registry用户名
   - Password: Docker Registry密码
   - ID: `docker-registry-creds`
   - Description: Docker Registry凭证

#### 添加Git凭证（如果需要）

类似步骤，ID设置为 `git-credentials`

### 🐳 Docker Registry配置

#### 选项1：使用Docker Hub
修改Jenkinsfile中的环境变量：
```groovy
environment {
    DOCKER_REGISTRY = 'docker.io'
    DOCKER_NAMESPACE = 'your-dockerhub-username'
}
```

#### 选项2：使用Harbor私有仓库
保持当前配置，需要先部署Harbor：

```bash
# 使用Docker Compose部署Harbor
wget https://github.com/goharbor/harbor/releases/download/v2.7.0/harbor-offline-installer-v2.7.0.tgz
tar xvf harbor-offline-installer-v2.7.0.tgz
cd harbor
# 编辑harbor.yml配置文件
sudo ./install.sh
```

### 🚀 运行Pipeline

#### 方法1：手动触发
1. 进入项目页面
2. 点击 "Build with Parameters"
3. 选择参数值
4. 点击 "Build"

#### 方法2：代码提交自动触发
提交代码到Git仓库，Jenkins会自动检测并触发构建

### 📊 监控和调试

#### 查看构建日志
- 点击构建编号
- 选择 "Console Output" 查看详细日志

#### 使用Blue Ocean界面
- 安装Blue Ocean插件
- 点击 "Open Blue Ocean" 获得更好的可视化体验

#### 常见问题排查

1. **Maven找不到**
   ```
   解决：在Global Tool Configuration中正确配置Maven
   ```

2. **Docker命令失败**
   ```
   解决：确保Jenkins用户有权限访问Docker daemon
   sudo usermod -aG docker jenkins
   sudo systemctl restart jenkins
   ```

3. **Git凭证问题**
   ```
   解决：检查凭证配置是否正确，确保有仓库访问权限
   ```

### 🔧 Jenkinsfile关键配置说明

#### 环境变量定义
```groovy
environment {
    MAVEN_HOME = tool 'Maven3.8'
    PATH = "${MAVEN_HOME}/bin:${env.PATH}"
    DOCKER_REGISTRY = 'harbor.example.com'
    IMAGE_TAG = "${env.BUILD_NUMBER}"
}
```

#### 参数化构建
```groovy
parameters {
    choice(name: 'BUILD_TYPE', choices: ['development', 'testing', 'production'])
    booleanParam(name: 'SKIP_TESTS', defaultValue: false)
}
```

#### 多阶段构建
```groovy
stages {
    stage('环境检查') { /* ... */ }
    stage('代码检出') { /* ... */ }
    stage('单元测试') { /* ... */ }
    stage('打包应用') { /* ... */ }
    stage('构建Docker镜像') { /* ... */ }
}
```

#### 构建后操作
```groovy
post {
    always { /* 总是执行 */ }
    success { /* 成功时执行 */ }
    failure { /* 失败时执行 */ }
}
```

### 📈 下一步优化

1. **集成SonarQube**：代码质量检查
2. **添加邮件通知**：构建结果通知
3. **集成Kubernetes部署**：自动部署到K8s集群
4. **添加安全扫描**：容器镜像安全检查

### 🎉 总结

通过本章学习，我们实现了：
- ✅ 创建了完整的声明式Pipeline
- ✅ 实现了多阶段构建流程
- ✅ 集成了Docker镜像构建
- ✅ 配置了参数化构建
- ✅ 添加了错误处理和通知

这标志着我们成功实现了"Pipeline as Code"，为后续的持续集成和持续部署打下了坚实的基础！