package com.example.productservice.controller;

import com.example.productservice.entity.Product;
import com.example.productservice.service.ProductService;
import com.example.productservice.common.Result;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
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
    public Result<List<Product>> getProducts() {
        return Result.success(productService.list());
    }

    @GetMapping("/{id}")
    @Operation(summary = "根据ID获取商品")
    @Cacheable(value = "products", key = "#id")
    public Result<Product> getProductById(@Parameter(description = "商品ID") @PathVariable Long id) {
        Product product = productService.getProductById(id);
        if (product != null) {
            return Result.success(product);
        }
        return Result.error("商品不存在");
    }

    @GetMapping("/{id}/with-user")
    @Operation(summary = "获取商品详情，包含用户信息")
    public Result<Object> getProductWithUserInfo(@Parameter(description = "商品ID") @PathVariable Long id) {
        Object result = productService.getProductWithUserInfo(id);
        if (result != null) {
            return Result.success(result);
        }
        return Result.error("商品不存在");
    }

    @PostMapping
    @Operation(summary = "创建商品")
    @CachePut(value = "products", key = "#result.data.id")
    public Result<Product> createProduct(@Parameter(description = "商品信息") @RequestBody Product product) {
        boolean success = productService.createProduct(product);
        if (success) {
            return Result.success(product);
        }
        return Result.error("创建商品失败");
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新商品")
    @CachePut(value = "products", key = "#id")
    public Result<Product> updateProduct(@Parameter(description = "商品ID") @PathVariable Long id,
                                @Parameter(description = "商品信息") @RequestBody Product product) {
        product.setId(id);
        boolean success = productService.updateProduct(product);
        if (success) {
            return Result.success(product);
        }
        return Result.error("更新商品失败");
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除商品")
    @CacheEvict(value = "products", key = "#id")
    public Result<Boolean> deleteProduct(@Parameter(description = "商品ID") @PathVariable Long id) {
        boolean success = productService.deleteProduct(id);
        if (success) {
            return Result.success(true);
        }
        return Result.error("删除商品失败");
    }
}