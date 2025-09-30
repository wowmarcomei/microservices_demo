package com.example.userservice.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * 动态配置属性类 - 演示Nacos Config动态刷新功能
 */
@Data
@ConfigurationProperties(prefix = "app.config")
public class DynamicConfigProperties {
    
    /**
     * 应用名称
     */
    private String appName = "User Service";
    
    /**
     * 版本号
     */
    private String version = "1.0.0";
    
    /**
     * 环境信息
     */
    private String environment = "development";
    
    /**
     * 功能开关
     */
    private boolean enableCaching = true;
    
    /**
     * 缓存过期时间（分钟）
     */
    private int cacheExpireMinutes = 30;
    
    /**
     * 最大连接数
     */
    private int maxConnections = 100;
}