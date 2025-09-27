package com.example.monolithapp.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("users")
public class User {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String username;

    private String password;

    private String email;

    @TableField(value = "created_time", fill = FieldFill.INSERT)
    private String createdTime;

    @TableField(value = "updated_time", fill = FieldFill.INSERT_UPDATE)
    private String updatedTime;

    @TableLogic
    private Integer deleted;
}