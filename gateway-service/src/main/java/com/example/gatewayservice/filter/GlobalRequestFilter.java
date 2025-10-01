package com.example.gatewayservice.filter;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

/**
 * 全局请求过滤器
 * 统一处理请求日志记录和认证
 */
@Component
public class GlobalRequestFilter implements GlobalFilter, Ordered {
    
    private static final Logger logger = LoggerFactory.getLogger(GlobalRequestFilter.class);
    
    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        ServerHttpRequest request = exchange.getRequest();
        
        // 记录请求信息
        logger.info("=== 全局过滤器 - 请求开始 ===");
        logger.info("请求方法: {}", request.getMethod());
        logger.info("请求路径: {}", request.getPath().value());
        logger.info("请求URI: {}", request.getURI());
        logger.info("远程地址: {}", request.getRemoteAddress());
        
        // 添加自定义请求头
        ServerHttpRequest modifiedRequest = request.mutate()
                .header("X-Gateway-Source", "gateway-service")
                .header("X-Request-Time", String.valueOf(System.currentTimeMillis()))
                .build();
        
        // 记录处理时间
        long startTime = System.currentTimeMillis();
        
        return chain.filter(exchange.mutate().request(modifiedRequest).build())
                .doFinally(signalType -> {
                    long endTime = System.currentTimeMillis();
                    logger.info("=== 全局过滤器 - 请求完成 ===");
                    logger.info("处理时间: {}ms", endTime - startTime);
                    logger.info("响应状态: {}", exchange.getResponse().getStatusCode());
                });
    }
    
    @Override
    public int getOrder() {
        // 设置较高的优先级，确保最先执行
        return -100;
    }
}