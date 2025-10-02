-- 创建数据库并设置正确的字符集
CREATE DATABASE IF NOT EXISTS monolith_db DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE monolith_db;

-- 查看字符集设置
SHOW VARIABLES LIKE 'character_set_database';
SHOW VARIABLES LIKE 'collation_database';

-- 如果字符集不正确，重新设置
ALTER DATABASE monolith_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 验证设置
SELECT 'Current database character set:' as info, @@character_set_database as charset;
SELECT 'Current database collation:' as info, @@collation_database as collation;