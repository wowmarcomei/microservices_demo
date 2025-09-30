package com.example.productservice.service;

import com.example.productservice.entity.Product;
import java.util.List;

public interface ProductService {

    List<Product> list();
    
    Product getProductById(Long id);

    boolean createProduct(Product product);

    boolean updateProduct(Product product);

    boolean deleteProduct(Long id);

    /**
     * 获取商品详情，包含用户信息
     */
    Object getProductWithUserInfo(Long id);

}