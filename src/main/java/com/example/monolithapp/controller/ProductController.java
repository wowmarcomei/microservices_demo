package com.example.monolithapp.controller;

import com.example.monolithapp.entity.Product;
import com.example.monolithapp.service.ProductService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.CachePut;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/products")
@RequiredArgsConstructor
@Tag(name = "商品管理", description = "商品相关接口")
public class ProductController {

    private final ProductService productService;

    @GetMapping
    @Operation(summary = "获取商品列表")
    public List<Product> getProducts() {
        return productService.list();
    }

    @GetMapping("/{id}")
    @Operation(summary = "根据ID获取商品")
    @Cacheable(value = "products", key = "#id")
    public Product getProductById(@Parameter(description = "商品ID") @PathVariable Long id) {
        return productService.getProductById(id);
    }

    @PostMapping
    @Operation(summary = "创建商品")
    @CachePut(value = "products", key = "#result.id")
    public Product createProduct(@Parameter(description = "商品信息") @RequestBody Product product) {
        productService.createProduct(product);
        return product;
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新商品")
    @CachePut(value = "products", key = "#id")
    public Product updateProduct(@Parameter(description = "商品ID") @PathVariable Long id,
                                @Parameter(description = "商品信息") @RequestBody Product product) {
        product.setId(id);
        productService.updateProduct(product);
        return product;
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除商品")
    @CacheEvict(value = "products", key = "#id")
    public boolean deleteProduct(@Parameter(description = "商品ID") @PathVariable Long id) {
        return productService.deleteProduct(id);
    }
}