package com.example.gatewayservice.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Mono;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

/**
 * Gateway 健康检查控制器
 */
@RestController
@RequestMapping("/gateway")
public class GatewayController {

    /**
     * 网关健康检查接口
     */
    @GetMapping("/health")
    public Mono<Map<String, Object>> health() {
        Map<String, Object> result = new HashMap<>();
        result.put("service", "gateway-service");
        result.put("status", "UP");
        result.put("timestamp", LocalDateTime.now());
        result.put("message", "Gateway is running normally");
        return Mono.just(result);
    }

    /**
     * 网关信息接口
     */
    @GetMapping("/info")
    public Mono<Map<String, Object>> info() {
        Map<String, Object> result = new HashMap<>();
        result.put("name", "API Gateway Service");
        result.put("version", "1.0.0");
        result.put("description", "统一 API 入口，提供路由、过滤、负载均衡等功能");
        result.put("port", 9000);
        return Mono.just(result);
    }
}