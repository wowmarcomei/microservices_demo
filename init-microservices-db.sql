-- 微服务数据库初始化脚本
-- 基于现有monolith_db数据迁移到微服务架构

-- 创建用户数据库
CREATE DATABASE IF NOT EXISTS user_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 创建商品数据库
CREATE DATABASE IF NOT EXISTS product_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 使用用户数据库
USE user_db;

-- 从monolith_db迁移用户表结构
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    password VARCHAR(255) NOT NULL COMMENT '密码',
    email VARCHAR(100) UNIQUE COMMENT '邮箱',
    phone VARCHAR(20) COMMENT '手机号',
    real_name VARCHAR(50) COMMENT '真实姓名',
    avatar VARCHAR(255) COMMENT '头像URL',
    status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT DEFAULT 0 COMMENT '逻辑删除：0-未删除，1-已删除'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- 创建索引
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);

-- 从monolith_db复制用户数据（如果存在）
INSERT IGNORE INTO users (id, username, password, email, phone, real_name, avatar, status, created_time, updated_time, deleted)
SELECT id, username, password, email, phone, real_name, avatar, status, created_time, updated_time, deleted 
FROM monolith_db.users WHERE deleted = 0;

-- 如果monolith_db没有数据，插入测试数据
INSERT IGNORE INTO users (username, password, email, real_name, status) VALUES
('admin', '$2a$10$7JB720yubVSZv0IiSrwLGOjQ9N8RBKrZ3Ixd.WStfQqKUi.KriOQ6', 'admin@example.com', '管理员', 1),
('testuser', 'password123', 'test@example.com', '测试用户', 1),
('john', 'password123', 'john@example.com', 'John Doe', 1);

-- 使用商品数据库
USE product_db;

-- 创建商品分类表
CREATE TABLE IF NOT EXISTS categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL COMMENT '分类名称',
    parent_id BIGINT DEFAULT 0 COMMENT '父分类ID',
    level INT DEFAULT 1 COMMENT '层级',
    sort_order INT DEFAULT 0 COMMENT '排序',
    status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT DEFAULT 0 COMMENT '逻辑删除：0-未删除，1-已删除'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='商品分类表';

-- 创建品牌表
CREATE TABLE IF NOT EXISTS brands (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL COMMENT '品牌名称',
    logo VARCHAR(255) COMMENT '品牌Logo',
    description TEXT COMMENT '品牌描述',
    status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT DEFAULT 0 COMMENT '逻辑删除：0-未删除，1-已删除'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='品牌表';

-- 创建商品表
CREATE TABLE IF NOT EXISTS products (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL COMMENT '商品名称',
    description TEXT COMMENT '商品描述',
    price DECIMAL(10,2) NOT NULL COMMENT '商品价格',
    stock INT DEFAULT 0 COMMENT '库存数量',
    category_id BIGINT COMMENT '分类ID（这里用作用户ID用于演示服务间调用）',
    brand_id BIGINT COMMENT '品牌ID',
    image_url VARCHAR(255) COMMENT '主图URL',
    status TINYINT DEFAULT 1 COMMENT '状态：0-下架，1-上架',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT DEFAULT 0 COMMENT '逻辑删除：0-未删除，1-已删除'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='商品表';

-- 创建索引
CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_status ON products(status);

-- 从monolith_db复制商品相关数据（如果存在）
INSERT IGNORE INTO categories (id, name, parent_id, level, sort_order, status, created_time, updated_time, deleted)
SELECT id, name, parent_id, level, sort_order, status, created_time, updated_time, deleted 
FROM monolith_db.categories WHERE deleted = 0;

INSERT IGNORE INTO brands (id, name, logo, description, status, created_time, updated_time, deleted)
SELECT id, name, logo, description, status, created_time, updated_time, deleted 
FROM monolith_db.brands WHERE deleted = 0;

INSERT IGNORE INTO products (id, name, description, price, stock, category_id, brand_id, image_url, status, created_time, updated_time, deleted)
SELECT id, name, description, price, stock, category_id, brand_id, image_url, status, created_time, updated_time, deleted 
FROM monolith_db.products WHERE deleted = 0;

-- 如果monolith_db没有数据，插入测试数据
INSERT IGNORE INTO categories (name, parent_id, level, sort_order) VALUES
('电子产品', 0, 1, 1),
('手机数码', 0, 1, 2),
('服装鞋包', 0, 1, 3);

INSERT IGNORE INTO brands (name, logo, description, status) VALUES
('Apple', 'https://example.com/apple-logo.png', 'Apple Inc.', 1),
('Samsung', 'https://example.com/samsung-logo.png', 'Samsung Electronics', 1),
('Huawei', 'https://example.com/huawei-logo.png', 'Huawei Technologies', 1);

-- 插入测试商品数据（category_id作为创建者用户ID用于演示服务间调用）
INSERT IGNORE INTO products (name, description, price, stock, category_id, brand_id, status) VALUES
('iPhone 14 Pro', '苹果iPhone 14 Pro 256GB 深空黑色', 7999.00, 100, 1, 1, 1),
('Samsung Galaxy S23', '三星Galaxy S23 256GB 幻影黑', 6999.00, 80, 2, 2, 1),
('华为Mate 50 Pro', '华为Mate 50 Pro 256GB 昆仑青', 6499.00, 120, 1, 3, 1),
('iPhone 14', '苹果iPhone 14 128GB 蓝色', 5999.00, 150, 3, 1, 1),
('MacBook Pro', '苹果MacBook Pro 14英寸 M2芯片', 14999.00, 50, 1, 1, 1);

-- 验证迁移结果
SELECT '用户数据库 - 用户数量:' as info, COUNT(*) as count FROM user_db.users WHERE deleted = 0;
SELECT '商品数据库 - 商品数量:' as info, COUNT(*) as count FROM product_db.products WHERE deleted = 0;
SELECT '商品数据库 - 分类数量:' as info, COUNT(*) as count FROM product_db.categories WHERE deleted = 0;
SELECT '商品数据库 - 品牌数量:' as info, COUNT(*) as count FROM product_db.brands WHERE deleted = 0;