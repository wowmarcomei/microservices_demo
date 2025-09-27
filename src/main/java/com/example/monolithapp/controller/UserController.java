package com.example.monolithapp.controller;

import com.example.monolithapp.entity.User;
import com.example.monolithapp.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
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
    public List<User> getUsers() {
        return userService.list();
    }

    @GetMapping("/{id}")
    @Operation(summary = "根据ID获取用户")
    @Cacheable(value = "users", key = "#id")
    public User getUserById(@Parameter(description = "用户ID") @PathVariable Long id) {
        return userService.getUserById(id);
    }

    @PostMapping
    @Operation(summary = "创建用户")
    @CachePut(value = "users", key = "#result.id")
    public User createUser(@Parameter(description = "用户信息") @RequestBody User user) {
        userService.createUser(user);
        return user;
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新用户")
    @CachePut(value = "users", key = "#id")
    public User updateUser(@Parameter(description = "用户ID") @PathVariable Long id,
                         @Parameter(description = "用户信息") @RequestBody User user) {
        user.setId(id);
        userService.updateUser(user);
        return user;
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除用户")
    @CacheEvict(value = "users", key = "#id")
    public boolean deleteUser(@Parameter(description = "用户ID") @PathVariable Long id) {
        return userService.deleteUser(id);
    }
}