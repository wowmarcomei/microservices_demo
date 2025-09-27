package com.example.monolithapp.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.monolithapp.entity.Product;

public interface ProductService extends IService<Product> {

    Product getProductById(Long id);

    boolean createProduct(Product product);

    boolean updateProduct(Product product);

    boolean deleteProduct(Long id);

}