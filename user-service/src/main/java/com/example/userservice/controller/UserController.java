package com.example.userservice.controller;

import com.example.userservice.entity.User;
import com.example.userservice.service.UserService;
import com.example.userservice.common.Result;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.CachePut;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
@Tag(name = "用户管理", description = "用户相关接口")
public class UserController {

    private final UserService userService;

    @GetMapping
    @Operation(summary = "获取用户列表")
    public Result<List<User>> getUsers() {
        return Result.success(userService.list());
    }

    @GetMapping("/{id}")
    @Operation(summary = "根据ID获取用户")
    @Cacheable(value = "users", key = "#id")
    public Result<User> getUserById(@Parameter(description = "用户ID") @PathVariable Long id) {
        User user = userService.getUserById(id);
        if (user != null) {
            return Result.success(user);
        }
        return Result.error("用户不存在");
    }

    @PostMapping
    @Operation(summary = "创建用户")
    @CachePut(value = "users", key = "#result.data.id")
    public Result<User> createUser(@Parameter(description = "用户信息") @RequestBody User user) {
        boolean success = userService.createUser(user);
        if (success) {
            return Result.success(user);
        }
        return Result.error("创建用户失败");
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新用户")
    @CachePut(value = "users", key = "#id")
    public Result<User> updateUser(@Parameter(description = "用户ID") @PathVariable Long id,
                         @Parameter(description = "用户信息") @RequestBody User user) {
        user.setId(id);
        boolean success = userService.updateUser(user);
        if (success) {
            return Result.success(user);
        }
        return Result.error("更新用户失败");
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除用户")
    @CacheEvict(value = "users", key = "#id")
    public Result<Boolean> deleteUser(@Parameter(description = "用户ID") @PathVariable Long id) {
        boolean success = userService.deleteUser(id);
        if (success) {
            return Result.success(true);
        }
        return Result.error("删除用户失败");
    }
}