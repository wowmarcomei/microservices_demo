package com.example.monolithapp.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.monolithapp.entity.User;
import com.example.monolithapp.mapper.UserMapper;
import com.example.monolithapp.service.UserService;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

@Service
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {

    @Override
    @Cacheable(value = "users", key = "#id")
    public User getUserById(Long id) {
        return baseMapper.selectById(id);
    }

    @Override
    public boolean createUser(User user) {
        return baseMapper.insert(user) > 0;
    }

    @Override
    public boolean updateUser(User user) {
        return baseMapper.updateById(user) > 0;
    }

    @Override
    public boolean deleteUser(Long id) {
        return baseMapper.deleteById(id) > 0;
    }
}