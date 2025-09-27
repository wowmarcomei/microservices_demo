package com.example.monolithapp.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.monolithapp.entity.User;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface UserMapper extends BaseMapper<User> {

}