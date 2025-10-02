-- 使用正确的字符集重新创建表结构
USE monolith_db;

-- 删除已存在的表（如果存在）
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS brands;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS users;

-- 用户表
CREATE TABLE users (
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

-- 商品分类表
CREATE TABLE categories (
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

-- 品牌表
CREATE TABLE brands (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL COMMENT '品牌名称',
    logo VARCHAR(255) COMMENT '品牌Logo',
    description TEXT COMMENT '品牌描述',
    status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT DEFAULT 0 COMMENT '逻辑删除：0-未删除，1-已删除'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='品牌表';

-- 商品表
CREATE TABLE products (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL COMMENT '商品名称',
    description TEXT COMMENT '商品描述',
    price DECIMAL(10,2) NOT NULL COMMENT '商品价格',
    stock INT DEFAULT 0 COMMENT '库存数量',
    category_id BIGINT COMMENT '分类ID',
    brand_id BIGINT COMMENT '品牌ID',
    image_url VARCHAR(255) COMMENT '主图URL',
    status TINYINT DEFAULT 1 COMMENT '状态：0-下架，1-上架',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT DEFAULT 0 COMMENT '逻辑删除：0-未删除，1-已删除'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='商品表';

-- 订单表
CREATE TABLE orders (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_no VARCHAR(50) NOT NULL UNIQUE COMMENT '订单号',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    total_amount DECIMAL(10,2) NOT NULL COMMENT '订单总金额',
    shipping_fee DECIMAL(10,2) DEFAULT 0.00 COMMENT '运费',
    payment_method TINYINT COMMENT '支付方式',
    payment_status TINYINT DEFAULT 0 COMMENT '支付状态：0-未支付，1-已支付，2-已退款',
    order_status TINYINT DEFAULT 0 COMMENT '订单状态：0-待支付，1-已支付，2-已发货，3-已完成，4-已取消',
    receiver_name VARCHAR(50) NOT NULL COMMENT '收货人姓名',
    receiver_phone VARCHAR(20) NOT NULL COMMENT '收货人电话',
    receiver_address VARCHAR(255) NOT NULL COMMENT '收货地址',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT DEFAULT 0 COMMENT '逻辑删除：0-未删除，1-已删除'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单表';

-- 订单明细表
CREATE TABLE order_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL COMMENT '订单ID',
    product_id BIGINT NOT NULL COMMENT '商品ID',
    product_name VARCHAR(100) NOT NULL COMMENT '商品名称',
    product_price DECIMAL(10,2) NOT NULL COMMENT '商品价格',
    quantity INT NOT NULL COMMENT '购买数量',
    subtotal DECIMAL(10,2) NOT NULL COMMENT '小计金额',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT DEFAULT 0 COMMENT '逻辑删除：0-未删除，1-已删除'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单明细表';

-- 创建索引
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_status ON products(status);
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_order_no ON orders(order_no);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);

-- 插入测试数据
INSERT INTO users (username, password, email, real_name, status) VALUES
('admin', '$2a$10$7JB720yubVSZv0IiSrwLGOjQ9N8RBKrZ3Ixd.WStfQqKUi.KriOQ6', 'admin@example.com', '管理员', 1),
('user1', '$2a$10$7JB720yubVSZv0IiSrwLGOjQ9N8RBKrZ3Ixd.WStfQqKUi.KriOQ6', 'user1@example.com', '测试用户1', 1),
('user2', '$2a$10$7JB720yubVSZv0IiSrwLGOjQ9N8RBKrZ3Ixd.WStfQqKUi.KriOQ6', 'user2@example.com', '测试用户2', 1);

INSERT INTO categories (name, parent_id, level, sort_order) VALUES
('电子产品', 0, 1, 1),
('手机数码', 0, 1, 2),
('服装鞋包', 0, 1, 3),
('食品生鲜', 0, 1, 4);

INSERT INTO brands (name, logo, description, status) VALUES
('Apple', 'https://example.com/apple-logo.png', 'Apple Inc.', 1),
('Samsung', 'https://example.com/samsung-logo.png', 'Samsung Electronics', 1),
('Huawei', 'https://example.com/huawei-logo.png', 'Huawei Technologies', 1);

INSERT INTO products (name, description, price, stock, category_id, brand_id, status) VALUES
('iPhone 14 Pro', '苹果iPhone 14 Pro 256GB 深空黑色', 7999.00, 100, 2, 1, 1),
('Samsung Galaxy S23', '三星Galaxy S23 256GB 幻影黑', 6999.00, 80, 2, 2, 1),
('华为Mate 50 Pro', '华为Mate 50 Pro 256GB 昆仑青', 6499.00, 120, 2, 3, 1),
('iPhone 14', '苹果iPhone 14 128MB 蓝色', 5999.00, 150, 2, 1, 1),
('MacBook Pro', '苹果MacBook Pro 14英寸 M2芯片', 14999.00, 50, 1, 1, 1);

INSERT INTO orders (order_no, user_id, total_amount, shipping_fee, payment_method, payment_status, order_status, receiver_name, receiver_phone, receiver_address) VALUES
('ORD202401270001', 1, 7999.00, 10.00, 1, 1, 2, '张三', '13800138001', '北京市朝阳区XX路XX号'),
('ORD202401270002', 2, 6999.00, 10.00, 1, 0, 0, '李四', '13800138002', '上海市浦东新区XX路XX号'),
('ORD202401270003', 3, 5999.00, 10.00, 1, 1, 3, '王五', '13800138003', '广州市天河区XX路XX号');

INSERT INTO order_items (order_id, product_id, product_name, product_price, quantity, subtotal) VALUES
(1, 1, 'iPhone 14 Pro', 7999.00, 1, 7999.00),
(2, 2, 'Samsung Galaxy S23', 6999.00, 1, 6999.00),
(3, 4, 'iPhone 14', 5999.00, 1, 5999.00);

-- 验证数据
SELECT '用户数量:' as info, COUNT(*) as count FROM users WHERE deleted = 0;
SELECT '商品数量:' as info, COUNT(*) as count FROM products WHERE deleted = 0;
SELECT '订单数量:' as info, COUNT(*) as count FROM orders WHERE deleted = 0;