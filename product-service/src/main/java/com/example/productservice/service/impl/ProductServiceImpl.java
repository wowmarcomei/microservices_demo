package com.example.productservice.service.impl;

import com.example.productservice.entity.Product;
import com.example.productservice.entity.User;
import com.example.productservice.mapper.ProductMapper;
import com.example.productservice.service.ProductService;
import com.example.productservice.client.UserClient;
import com.example.productservice.common.Result;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class ProductServiceImpl implements ProductService {

    @Autowired
    private ProductMapper productMapper;
    
    @Autowired
    private UserClient userClient;
    
    @Override
    public List<Product> list() {
        return productMapper.selectList(null);
    }

    @Override
    @Cacheable(value = "products", key = "#id")
    public Product getProductById(Long id) {
        return productMapper.selectById(id);
    }

    @Override
    public boolean createProduct(Product product) {
        return productMapper.insert(product) > 0;
    }

    @Override
    public boolean updateProduct(Product product) {
        return productMapper.updateById(product) > 0;
    }

    @Override
    public boolean deleteProduct(Long id) {
        return productMapper.deleteById(id) > 0;
    }

    @Override
    public Object getProductWithUserInfo(Long id) {
        // 获取商品信息
        Product product = productMapper.selectById(id);
        if (product == null) {
            return null;
        }

        // 模拟调用用户服务获取用户信息（假设商品有创建者ID）
        // 这里我们假设商品的categoryId实际上是用户ID（为了演示服务间调用）
        try {
            Result<User> userResult = userClient.getUserById(product.getCategoryId());
            
            Map<String, Object> result = new HashMap<>();
            result.put("product", product);
            
            if (userResult != null && userResult.getCode() == 200) {
                result.put("user", userResult.getData());
            } else {
                result.put("user", null);
                result.put("userError", "无法获取用户信息");
            }
            
            return result;
        } catch (Exception e) {
            // 服务调用失败时的降级处理
            Map<String, Object> result = new HashMap<>();
            result.put("product", product);
            result.put("user", null);
            result.put("userError", "用户服务暂时不可用: " + e.getMessage());
            return result;
        }
    }
}