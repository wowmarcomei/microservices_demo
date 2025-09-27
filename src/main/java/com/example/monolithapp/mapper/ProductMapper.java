package com.example.monolithapp.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.monolithapp.entity.Product;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface ProductMapper extends BaseMapper<Product> {

}