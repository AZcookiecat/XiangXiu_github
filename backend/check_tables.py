from app import app, db
from sqlalchemy import text

with app.app_context():
    result = db.session.execute(text('SHOW TABLES'))
    tables = [r[0] for r in result]
    print("数据库中的表:")
    for table in tables:
        print(f"  - {table}")
