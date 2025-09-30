package com.example.productservice.client;

import com.example.productservice.entity.User;
import com.example.productservice.common.Result;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(name = "user-service")
public interface UserClient {
    
    @GetMapping("/users/{id}")
    Result<User> getUserById(@PathVariable("id") Long id);
}