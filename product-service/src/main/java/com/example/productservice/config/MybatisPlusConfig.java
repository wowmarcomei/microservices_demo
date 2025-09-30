package com.example.productservice.config;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.context.annotation.Configuration;

@Configuration
@MapperScan("com.example.productservice.mapper")
public class MybatisPlusConfig {
}