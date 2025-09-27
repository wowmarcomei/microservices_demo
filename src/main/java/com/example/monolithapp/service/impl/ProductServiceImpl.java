package com.example.monolithapp.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.monolithapp.entity.Product;
import com.example.monolithapp.mapper.ProductMapper;
import com.example.monolithapp.service.ProductService;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

@Service
public class ProductServiceImpl extends ServiceImpl<ProductMapper, Product> implements ProductService {

    @Override
    @Cacheable(value = "products", key = "#id")
    public Product getProductById(Long id) {
        return baseMapper.selectById(id);
    }

    @Override
    public boolean createProduct(Product product) {
        return baseMapper.insert(product) > 0;
    }

    @Override
    public boolean updateProduct(Product product) {
        return baseMapper.updateById(product) > 0;
    }

    @Override
    public boolean deleteProduct(Long id) {
        return baseMapper.deleteById(id) > 0;
    }
}