package com.example.monolithapp.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/config")
@Tag(name = "配置测试", description = "配置测试接口")
public class ConfigController {

    @Value("${app.greeting:Hello, Default!}")
    private String greeting;

    @Value("${app.feature.enabled:false}")
    private Boolean featureEnabled;

    @GetMapping("/greeting")
    @Operation(summary = "获取问候语")
    public String getGreeting() {
        return greeting;
    }

    @GetMapping("/feature-status")
    @Operation(summary = "获取功能开关状态")
    public Boolean getFeatureStatus() {
        return featureEnabled;
    }
}