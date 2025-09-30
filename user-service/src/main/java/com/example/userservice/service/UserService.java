package com.example.userservice.service;

import com.example.userservice.entity.User;
import java.util.List;

public interface UserService {

    List<User> list();
    
    User getUserById(Long id);

    boolean createUser(User user);

    boolean updateUser(User user);

    boolean deleteUser(Long id);

}