pipeline {
    agent any
    
    // 定义环境变量
    environment {
        // Maven工具（需要在Jenkins中配置）
        MAVEN_HOME = tool 'Maven3.8'
        PATH = "${MAVEN_HOME}/bin:${env.PATH}"
        
        // Docker配置
        DOCKER_REGISTRY = 'harbor.example.com' // 替换为你的私有镜像仓库地址
        DOCKER_NAMESPACE = 'microservices'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        
        // 项目信息
        PROJECT_NAME = 'monolith-app'
        GIT_COMMIT_SHORT = sh(
            script: "git rev-parse --short HEAD",
            returnStdout: true
        ).trim()
    }
    
    // 参数化构建
    parameters {
        choice(
            name: 'BUILD_TYPE',
            choices: ['development', 'testing', 'production'],
            description: '选择构建环境类型'
        )
        booleanParam(
            name: 'SKIP_TESTS',
            defaultValue: false,
            description: '是否跳过单元测试'
        )
        booleanParam(
            name: 'PUSH_IMAGES',
            defaultValue: true,
            description: '是否推送Docker镜像'
        )
    }
    
    stages {
        stage('环境检查') {
            steps {
                script {
                    echo "=========================================="
                    echo "🔍 Jenkins Pipeline 环境检查"
                    echo "=========================================="
                    echo "工作目录: ${env.WORKSPACE}"
                    echo "构建编号: ${env.BUILD_NUMBER}"
                    echo "Git提交: ${GIT_COMMIT_SHORT}"
                    echo "构建类型: ${params.BUILD_TYPE}"
                    echo "跳过测试: ${params.SKIP_TESTS}"
                    echo "推送镜像: ${params.PUSH_IMAGES}"
                    echo "=========================================="
                    
                    // 检查工具版本
                    sh 'java -version'
                    sh 'mvn -version'
                    sh 'docker --version'
                    
                    // 检查项目结构
                    echo "📁 检查项目结构..."
                    sh 'ls -la'
                    sh 'ls -la user-service/ || echo "user-service目录不存在"'
                    sh 'ls -la product-service/ || echo "product-service目录不存在"'
                    sh 'ls -la gateway-service/ || echo "gateway-service目录不存在"'
                }
            }
        }
        
        stage('代码检出') {
            steps {
                echo "📥 检出代码..."
                // 如果使用Git仓库，这里会自动检出代码
                // 对于本地测试，代码已经在工作空间中
                script {
                    // 显示Git信息
                    try {
                        sh 'git log --oneline -5'
                        sh 'git status'
                    } catch (Exception e) {
                        echo "警告: 无法获取Git信息 - ${e.getMessage()}"
                    }
                }
            }
        }
        
        stage('代码质量检查') {
            steps {
                echo "🔍 执行代码质量检查..."
                script {
                    // 简单的代码检查
                    echo "检查pom.xml文件..."
                    sh 'find . -name "pom.xml" -exec echo "发现POM文件: {}" \\;'
                    
                    // 检查Java源代码
                    echo "检查Java源代码..."
                    sh 'find . -name "*.java" | wc -l | xargs echo "Java文件总数:"'
                    
                    // 这里可以集成SonarQube等代码质量工具
                    // sh 'mvn sonar:sonar'
                }
            }
        }
        
        stage('清理与编译') {
            steps {
                echo "🧹 清理项目..."
                sh 'mvn clean'
                
                echo "🔨 编译项目..."
                sh 'mvn compile'
            }
        }
        
        stage('单元测试') {
            when {
                not { params.SKIP_TESTS }
            }
            steps {
                echo "🧪 执行单元测试..."
                script {
                    try {
                        sh 'mvn test'
                    } catch (Exception e) {
                        echo "⚠️ 单元测试失败，但继续构建: ${e.getMessage()}"
                        currentBuild.result = 'UNSTABLE'
                    }
                }
            }
            post {
                always {
                    // 收集测试报告
                    echo "📊 收集测试报告..."
                    script {
                        try {
                            // 查找并显示测试结果
                            sh 'find . -name "TEST-*.xml" -exec echo "测试报告: {}" \\;'
                            
                            // Jenkins可以解析JUnit XML报告
                            // junit '**/target/surefire-reports/TEST-*.xml'
                        } catch (Exception e) {
                            echo "无法收集测试报告: ${e.getMessage()}"
                        }
                    }
                }
            }
        }
        
        stage('打包应用') {
            steps {
                echo "📦 打包微服务应用..."
                sh 'mvn package -DskipTests'
                
                script {
                    echo "✅ 检查生成的JAR文件..."
                    sh '''
                        echo "🔍 查找生成的JAR文件:"
                        find . -name "*.jar" -type f | while read jar_file; do
                            echo "  📄 $jar_file ($(du -h "$jar_file" | cut -f1))"
                        done
                    '''
                }
            }
            post {
                success {
                    echo "✅ 应用打包成功！"
                    // 归档构建产物
                    archiveArtifacts artifacts: '**/target/*.jar', 
                                   fingerprint: true,
                                   allowEmptyArchive: true
                }
                failure {
                    echo "❌ 应用打包失败！"
                }
            }
        }
        
        stage('构建Docker镜像') {
            steps {
                script {
                    echo "🐳 构建Docker镜像..."
                    
                    // 构建各个微服务的Docker镜像
                    def services = ['user-service', 'product-service', 'gateway-service']
                    
                    services.each { service ->
                        echo "构建 ${service} 镜像..."
                        
                        // 检查Dockerfile是否存在
                        if (fileExists("${service}/Dockerfile")) {
                            // 构建镜像
                            def imageName = "${DOCKER_REGISTRY}/${DOCKER_NAMESPACE}/${service}:${IMAGE_TAG}"
                            def imageNameLatest = "${DOCKER_REGISTRY}/${DOCKER_NAMESPACE}/${service}:latest"
                            
                            sh """
                                cd ${service}
                                docker build -t ${imageName} .
                                docker tag ${imageName} ${imageNameLatest}
                                echo "✅ ${service} 镜像构建完成: ${imageName}"
                            """
                        } else {
                            echo "⚠️ ${service}/Dockerfile 不存在，跳过镜像构建"
                        }
                    }
                    
                    // 显示本地镜像
                    echo "📋 本地Docker镜像列表:"
                    sh "docker images | grep '${DOCKER_NAMESPACE}' || echo '未找到相关镜像'"
                }
            }
        }
        
        stage('推送镜像到仓库') {
            when {
                expression { params.PUSH_IMAGES }
            }
            steps {
                script {
                    echo "📤 推送Docker镜像到私有仓库..."
                    
                    // 这里需要配置Docker Registry的认证
                    // withCredentials([usernamePassword(credentialsId: 'docker-registry-creds', 
                    //                                  usernameVariable: 'DOCKER_USER', 
                    //                                  passwordVariable: 'DOCKER_PASS')]) {
                    //     sh 'echo $DOCKER_PASS | docker login $DOCKER_REGISTRY -u $DOCKER_USER --password-stdin'
                    //     
                    //     def services = ['user-service', 'product-service', 'gateway-service']
                    //     services.each { service ->
                    //         sh "docker push ${DOCKER_REGISTRY}/${DOCKER_NAMESPACE}/${service}:${IMAGE_TAG}"
                    //         sh "docker push ${DOCKER_REGISTRY}/${DOCKER_NAMESPACE}/${service}:latest"
                    //     }
                    // }
                    
                    echo "⚠️ 镜像推送功能需要配置Docker Registry认证信息"
                    echo "请在Jenkins中添加docker-registry-creds凭证"
                }
            }
        }
        
        stage('清理资源') {
            steps {
                script {
                    echo "🧹 清理Docker资源..."
                    
                    // 清理无用的Docker镜像（可选）
                    try {
                        sh '''
                            echo "清理无标签的镜像..."
                            docker image prune -f || true
                            
                            echo "显示当前镜像使用情况..."
                            docker system df
                        '''
                    } catch (Exception e) {
                        echo "清理过程中出现警告: ${e.getMessage()}"
                    }
                }
            }
        }
    }
    
    post {
        always {
            echo "🏁 Pipeline执行完成"
            script {
                // 计算构建时长
                def duration = currentBuild.durationString.replace(' and counting', '')
                echo "⏱️ 总构建时间: ${duration}"
            }
        }
        success {
            echo "✅ Pipeline执行成功！"
            script {
                // 这里可以发送成功通知
                // emailext (
                //     subject: "✅ 构建成功: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                //     body: "构建成功完成！详情请查看: ${env.BUILD_URL}",
                //     to: "dev-team@company.com"
                // )
                echo "💌 可以在这里配置成功通知（邮件、钉钉、企业微信等）"
            }
        }
        failure {
            echo "❌ Pipeline执行失败！"
            script {
                // 这里可以发送失败通知
                echo "💌 可以在这里配置失败通知（邮件、钉钉、企业微信等）"
                echo "📋 失败原因请查看构建日志: ${env.BUILD_URL}console"
            }
        }
        unstable {
            echo "⚠️ Pipeline执行不稳定（通常是测试失败）"
        }
        cleanup {
            echo "🧹 执行清理工作..."
            // 清理工作空间等操作
        }
    }
}