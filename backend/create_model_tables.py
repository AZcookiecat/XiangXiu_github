from app import app, db
from sqlalchemy import text

# 创建表的SQL语句
create_tables_sql = """
-- 创建3D模型表
CREATE TABLE IF NOT EXISTS model3d (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    file_path VARCHAR(255) NOT NULL,
    file_size INT,
    category VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 创建模型标签表
CREATE TABLE IF NOT EXISTS model_tag (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 创建模型和标签的关联表
CREATE TABLE IF NOT EXISTS model_tags (
    model_id INT NOT NULL,
    tag_id INT NOT NULL,
    PRIMARY KEY (model_id, tag_id),
    FOREIGN KEY (model_id) REFERENCES model3d(id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES model_tag(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
"""

with app.app_context():
    # 执行SQL创建表
    sql_statements = [stmt.strip() for stmt in create_tables_sql.split(';') if stmt.strip()]
    for sql in sql_statements:
        try:
            db.session.execute(text(sql))
            print(f"执行成功: {sql[:50]}...")
        except Exception as e:
            print(f"执行失败: {e}")
    
    db.session.commit()
    print("表创建完成！")
