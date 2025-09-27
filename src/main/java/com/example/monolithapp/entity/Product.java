package com.example.monolithapp.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("products")
public class Product {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String name;

    private String description;

    private BigDecimal price;

    private Integer stock;

    private Long categoryId;

    @TableField(value = "created_time", fill = FieldFill.INSERT)
    private String createdTime;

    @TableField(value = "updated_time", fill = FieldFill.INSERT_UPDATE)
    private String updatedTime;

    @TableLogic
    private Integer deleted;
}