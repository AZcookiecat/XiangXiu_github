-- 湘云绣阁 - 关键词回复表
-- 用于AI助手的关键词匹配功能
-- 创建时间: 2026-04-19

-- 选择数据库（根据你的实际情况修改数据库名）
-- USE xiangxiu_culture;

-- 删除已存在的表（如果需要重新创建）
-- DROP TABLE IF EXISTS keyword_reply;

-- 创建关键词回复表
CREATE TABLE IF NOT EXISTS keyword_reply (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    keyword VARCHAR(200) NOT NULL COMMENT '关键词，多个关键词用逗号分隔',
    reply_content TEXT NOT NULL COMMENT '回复内容',
    category VARCHAR(100) DEFAULT NULL COMMENT '分类标签，如:常见问题、技术咨询等',
    priority INT DEFAULT 0 COMMENT '优先级，数字越大优先级越高',
    is_active TINYINT(1) DEFAULT 1 COMMENT '是否启用: 1-启用, 0-禁用',
    match_type VARCHAR(20) DEFAULT 'contains' COMMENT '匹配类型: exact-精确匹配, contains-包含匹配, fuzzy-模糊匹配',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_keyword (keyword),
    INDEX idx_category (category),
    INDEX idx_priority (priority),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='关键词回复表 - 用于AI助手的关键词匹配';

-- 插入示例数据
INSERT INTO keyword_reply (keyword, reply_content, category, priority, match_type, is_active) VALUES
('你好,您好,hi,hello', '您好！我是湘云绣阁的AI助手，很高兴为您服务。请问有什么可以帮您的吗？', '问候语', 100, 'exact', 1),
('湘绣,什么是湘绣', '湘绣是中国四大名绣之一，起源于湖南省长沙、沙坪一带，有着2000多年的历史。湘绣以狮虎题材见长，针法丰富，色彩鲜明，形神兼备，被誉为"绣花能生香，绣鸟能听声，绣虎能奔跑，绣人能传神"。', '湘绣介绍', 90, 'contains', 1),
('创始人,品牌故事,历史', '湘云绣阁成立于2024年，致力于传承和推广湘绣文化。我们汇聚了众多湘绣非遗传承人，将传统技艺与现代设计相结合，让更多人了解和喜爱这项国家级非物质文化遗产。', '品牌介绍', 80, 'contains', 1),
('联系方式,电话,邮箱,联系', '您可以通过以下方式联系我们：\n电话：400-888-9999\n邮箱：contact@xiangyunxiuge.com\n地址：湖南省长沙市湘绣文化产业园', '联系方式', 85, 'contains', 1),
('营业时间,开放时间,几点开门', '我们的展厅营业时间为：\n周一至周五：9:00 - 18:00\n周六至周日：10:00 - 20:00\n节假日照常开放', '营业信息', 70, 'contains', 1),
('门票,收费,多少钱,价格', '湘云绣阁展厅免费对外开放！\n部分特殊展览和工作坊可能需要预约或收费，详情请咨询现场工作人员。', '价格信息', 75, 'contains', 1),
('谢谢,感谢', '不客气！很高兴能帮到您。如有其他问题，随时欢迎咨询。祝您生活愉快！', '结束语', 100, 'exact', 1);

-- 查看插入的数据
-- SELECT * FROM keyword_reply;
