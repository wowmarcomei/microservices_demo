package com.example.monolithapp.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.monolithapp.entity.User;

public interface UserService extends IService<User> {

    User getUserById(Long id);

    boolean createUser(User user);

    boolean updateUser(User user);

    boolean deleteUser(Long id);

}