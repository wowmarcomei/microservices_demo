package com.example.productservice.config;

import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * 动态配置管理类
 */
@Configuration
@EnableConfigurationProperties
public class DynamicConfigManager {

    @Bean
    @RefreshScope
    public DynamicConfigProperties dynamicConfigProperties() {
        return new DynamicConfigProperties();
    }
}