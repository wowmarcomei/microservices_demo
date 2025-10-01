package com.example.productservice.controller;

import com.alibaba.csp.sentinel.annotation.SentinelResource;
import com.alibaba.csp.sentinel.slots.block.BlockException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.concurrent.ThreadLocalRandom;
import java.util.concurrent.TimeUnit;

/**
 * Sentinel 功能演示控制器
 * 用于展示流控、熔断、降级等功能
 */
@RestController
@RequestMapping("/api/sentinel")
@Slf4j
public class SentinelDemoController {

    /**
     * 基础测试接口 - 用于测试流控
     */
    @GetMapping("/test")
    @SentinelResource(value = "product-test", blockHandler = "testBlockHandler")
    public String test() {
        log.info("商品服务 - 测试接口被调用");
        return "商品服务正常响应 - " + System.currentTimeMillis();
    }

    /**
     * 流控阻塞处理方法
     */
    public String testBlockHandler(BlockException ex) {
        log.warn("商品服务 - 测试接口被流控: {}", ex.getMessage());
        return "商品服务繁忙，请稍后重试！";
    }

    /**
     * 慢调用接口 - 用于测试熔断
     */
    @GetMapping("/slow")
    @SentinelResource(value = "product-slow", 
                      blockHandler = "slowBlockHandler", 
                      fallback = "slowFallback")
    public String slowCall(@RequestParam(defaultValue = "1500") Integer delay) {
        log.info("商品服务 - 慢调用接口被调用，延迟: {}ms", delay);
        
        try {
            // 模拟慢调用
            TimeUnit.MILLISECONDS.sleep(delay);
            return "商品服务慢调用完成 - 延迟" + delay + "ms";
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new RuntimeException("调用被中断", e);
        }
    }

    /**
     * 慢调用流控处理
     */
    public String slowBlockHandler(Integer delay, BlockException ex) {
        log.warn("商品服务 - 慢调用接口被流控: {}", ex.getMessage());
        return "商品服务慢调用被流控，请稍后重试！";
    }

    /**
     * 慢调用降级处理
     */
    public String slowFallback(Integer delay, Throwable ex) {
        log.warn("商品服务 - 慢调用接口触发降级: {}", ex.getMessage());
        return "商品服务慢调用降级响应 - 系统繁忙";
    }

    /**
     * 异常接口 - 用于测试异常比例熔断
     */
    @GetMapping("/exception")
    @SentinelResource(value = "product-exception", 
                      blockHandler = "exceptionBlockHandler", 
                      fallback = "exceptionFallback")
    public String exceptionCall(@RequestParam(defaultValue = "30") Integer errorRate) {
        log.info("商品服务 - 异常接口被调用，错误率: {}%", errorRate);
        
        // 根据错误率随机抛出异常
        int random = ThreadLocalRandom.current().nextInt(100);
        if (random < errorRate) {
            throw new RuntimeException("模拟商品服务异常 - 随机数: " + random);
        }
        
        return "商品服务异常接口正常响应 - 随机数: " + random;
    }

    /**
     * 异常接口流控处理
     */
    public String exceptionBlockHandler(Integer errorRate, BlockException ex) {
        log.warn("商品服务 - 异常接口被流控: {}", ex.getMessage());
        return "商品服务异常接口被流控，请稍后重试！";
    }

    /**
     * 异常接口降级处理
     */
    public String exceptionFallback(Integer errorRate, Throwable ex) {
        log.warn("商品服务 - 异常接口触发降级: {}", ex.getMessage());
        return "商品服务异常接口降级响应 - 服务暂时不可用";
    }

    /**
     * 热点参数限流接口
     */
    @GetMapping("/hotkey/{productId}")
    @SentinelResource(value = "product-hotkey", blockHandler = "hotkeyBlockHandler")
    public String hotkeyCall(@PathVariable String productId) {
        log.info("商品服务 - 热点商品查询: {}", productId);
        return "商品信息查询成功 - 商品ID: " + productId;
    }

    /**
     * 热点参数限流处理
     */
    public String hotkeyBlockHandler(String productId, BlockException ex) {
        log.warn("商品服务 - 热点商品查询被限流: productId={}, error={}", productId, ex.getMessage());
        return "商品 " + productId + " 查询过于频繁，请稍后重试！";
    }

    /**
     * 获取当前系统状态
     */
    @GetMapping("/status")
    public String getStatus() {
        return "商品服务运行正常 - " + System.currentTimeMillis();
    }

    /**
     * 商品库存查询 - 模拟数据库查询
     */
    @GetMapping("/inventory/{productId}")
    @SentinelResource(value = "product-inventory", 
                      blockHandler = "inventoryBlockHandler",
                      fallback = "inventoryFallback")
    public String getInventory(@PathVariable String productId) {
        log.info("商品服务 - 库存查询: {}", productId);
        
        // 模拟数据库查询延迟
        try {
            TimeUnit.MILLISECONDS.sleep(ThreadLocalRandom.current().nextInt(100, 500));
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        
        // 模拟偶发异常
        if (ThreadLocalRandom.current().nextInt(100) < 5) {
            throw new RuntimeException("数据库连接异常");
        }
        
        return "商品库存: " + ThreadLocalRandom.current().nextInt(0, 1000);
    }

    public String inventoryBlockHandler(String productId, BlockException ex) {
        return "库存查询被限流，商品ID: " + productId;
    }

    public String inventoryFallback(String productId, Throwable ex) {
        return "库存查询暂时不可用，商品ID: " + productId;
    }
}