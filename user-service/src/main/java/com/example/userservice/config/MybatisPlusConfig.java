package com.example.userservice.config;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.context.annotation.Configuration;

@Configuration
@MapperScan("com.example.userservice.mapper")
public class MybatisPlusConfig {
}