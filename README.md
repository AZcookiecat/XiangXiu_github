# 湘云绣阁 - 湘绣传统文化元宇宙平台

[![zread](https://img.shields.io/badge/Ask_Zread-_.svg?style=flat&color=00b0aa&labelColor=000000&logo=data%3Aimage%2Fsvg%2Bxml%3Bbase64%2CPHN2ZyB3aWR0aD0iMTYiIGhlaWdodD0iMTYiIHZpZXdCb3g9IjAgMCAxNiAxNiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTQuOTYxNTYgMS42MDAxSDIuMjQxNTZDMS44ODgxIDEuNjAwMSAxLjYwMTU2IDEuODg2NjQgMS42MDE1NiAyLjI0MDFWNC45NjAxQzEuNjAxNTYgNS4zMTM1NiAxLjg4ODEgNS42MDAxIDIuMjQxNTYgNS42MDAxSDQuOTYxNTZDNS4zMTUwMiA1LjYwMDEgNS42MDE1NiA1LjMxMzU2IDUuNjAxNTYgNC45NjAxVjIuMjQwMUM1LjYwMTU2IDEuODg2NjQgNS4zMTUwMiAxLjYwMDEgNC45NjE1NiAxLjYwMDFaIiBmaWxsPSIjZmZmIi8%2BCjxwYXRoIGQ9Ik00Ljk2MTU2IDEwLjM5OTlIMi4yNDE1NkMxLjg4ODEgMTAuMzk5OSAxLjYwMTU2IDEwLjY4NjQgMS42MDE1NiAxMS4wMzk5VjEzLjc1OTlDMS42MDE1NiAxNC4xMTM0IDEuODg4MSAxNC4zOTk5IDIuMjQxNTYgMTQuMzk5OUg0Ljk2MTU2QzUuMzE1MDIgMTQuMzk5OSA1LjYwMTU2IDE0LjExMzQgNS42MDE1NiAxMy43NTk5VjExLjAzOTlDNS42MDE1NiAxMC42ODY0IDUuMzE1MDIgMTAuMzk5OSA0Ljk2MTU2IDEwLjM5OTlaIiBmaWxsPSIjZmZmIi8%2BCjxwYXRoIGQ9Ik0xMy43NTg0IDEuNjAwMUgxMS4wMzg0QzEwLjY4NSAxLjYwMDEgMTAuMzk4NCAxLjg4NjY0IDEwLjM5ODQgMi4yNDAxVjQuOTYwMUMxMC4zOTg0IDUuMzEzNTYgMTAuNjg1IDUuNjAwMSAxMS4wMzg0IDUuNjAwMUgxMy43NTg0QzE0LjExMTkgNS42MDAxIDE0LjM5ODQgNS4zMTM1NiAxNC4zOTg0IDQuOTYwMVYyLjI0MDFDMTQuMzk4NCAxLjg4NjY0IDE0LjExMTkgMS42MDAxIDEzLjc1ODQgMS42MDAxWiIgZmlsbD0iI2ZmZiIvPgo8cGF0aCBkPSJNNCAxMkwxMiA0TDQgMTJaIiBmaWxsPSIjZmZmIi8%2BCjxwYXRoIGQ9Ik00IDEyTDEyIDQiIHN0cm9rZT0iI2ZmZiIgc3Ryb2tlLXdpZHRoPSIxLjUiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIvPgo8L3N2Zz4K&logoColor=ffffff)](https://zread.ai/AZcookiecat/XiangXiu_github)

## 项目简介

湘云绣阁是一个基于 **Vue 3 + Flask** 开发的湘绣传统文化元宇宙展示平台，旨在通过数字化手段展示和传承湘绣这一非物质文化遗产。平台融合了三维虚拟展厅、AI 智能助手、知识图谱等现代技术，让更多人了解和欣赏湘绣的魅力。

## 主要功能

### 前端展示
- 🎨 **作品展示**：展示精美的湘绣作品，包括图片、描述和创作背景
- 🏬 **虚拟商城**：提供湘绣相关产品的浏览和购买功能
- 🏛️ **虚拟场馆**：基于 Unity WebGL 的沉浸式3D展厅体验
- 🎭 **文化展览**：举办线上湘绣文化展览
- 🔍 **知识图谱**：构建湘绣知识图谱，可视化展示文化知识

### AI 智能助手
- 🤖 **AI 对话**：集成 Deepseek API，提供智能问答服务
- 🔑 **关键词回复**：支持自定义关键词自动回复
- 📚 **知识库检索**：基于知识库的精准内容检索（RAG）
- ⚡ **三级响应**：关键词 → 知识库 → AI 的优先级响应机制

### 后台管理
- 📊 **数据管理**：节点、关系、产品、用户的 CRUD 管理
- 🗝️ **关键词管理**：配置 AI 助手的关键词回复规则
- 📁 **3D 模型管理**：上传和管理虚拟展厅的 3D 模型文件
- 📥 **批量导入**：支持 Excel/CSV 批量导入知识库数据

## 技术栈

### 前端
- **框架**：Vue 3 + Composition API
- **构建工具**：Vite
- **路由**：Vue Router 4
- **HTTP 客户端**：Axios
- **UI 组件**：Element Plus
- **图标**：Font Awesome
- **样式**：CSS3 + SCSS

### 后端
- **框架**：Flask + Flask-SQLAlchemy + Flask-Migrate
- **数据库**：MySQL 5.7
- **ORM**：SQLAlchemy
- **AI 接口**：Deepseek API
- **部署**：Gunicorn + Nginx

### 其他
- **3D 展示**：Unity WebGL
- **知识图谱**：ECharts / D3.js
- **服务器**：Tencent Cloud (Ubuntu 22.04)

## 快速开始

### 环境要求

- Node.js >= 18.0.0
- Python >= 3.10
- MySQL >= 5.7

### 前端开发

```bash
# 进入前端目录
cd XiangXiu_github

# 安装依赖
npm install

# 开发模式运行
npm run dev

# 构建生产版本
npm run build
```

### 后端开发

```bash
# 进入后端目录
cd backend

# 创建虚拟环境
python -m venv venv

# 激活虚拟环境
# Windows:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate

# 安装依赖
pip install -r requirements.txt

# 配置数据库
# 修改 config.py 中的数据库连接信息

# 运行数据库迁移
flask db upgrade

# 启动开发服务器
python app.py
```

### AI 助手配置

1. **配置 Deepseek API Key**

   复制环境变量模板文件：
   ```bash
   cd backend
   cp .env.example .env
   ```

   编辑 `.env` 文件，填入你的 Deepseek API Key：
   ```bash
   DEEPSEEK_API_KEY=sk-your-api-key-here
   ```

   > ⚠️ **注意**: `.env` 文件包含敏感信息，**不要**将其提交到 Git！已添加到 `.gitignore`。

2. **执行 SQL 文件创建关键词回复表**
   ```bash
   mysql -u username -p database_name < backend/keyword_reply.sql
   ```

3. **访问后台配置关键词回复规则**
   - 登录后台管理 `/admin`
   - 进入"关键词回复"页面
   - 添加关键词和对应的回复内容

## 部署指南

### 生产环境部署（腾讯云）

1. **服务器配置**
   - 系统：Ubuntu 22.04 LTS
   - 配置：2核 4GB 内存（推荐）
   - 面板：Baota 面板（可选）

2. **环境安装**
```bash
# 安装 Python 3.10
sudo apt update
sudo apt install python3.10 python3.10-venv python3.10-dev

# 安装 MySQL
sudo apt install mysql-server

# 安装 Nginx
sudo apt install nginx
```

3. **后端部署**
```bash
# 上传代码到服务器
cd /www/wwwroot/XiangXiu_github/backend

# 创建虚拟环境
python3.10 -m venv venv
source venv/bin/activate

# 安装依赖
pip install -r requirements.txt

# 配置环境变量
export DEEPSEEK_API_KEY=sk-your-api-key-here
export DEEPSEEK_BASE_URL=https://api.deepseek.com

# 或创建 .env 文件
echo "DEEPSEEK_API_KEY=sk-your-api-key-here" > .env

# 配置 Gunicorn
pip install gunicorn

# 启动服务（使用 nohup 或 systemd）
gunicorn -w 4 -b 127.0.0.1:5000 app:app
```

**使用 Systemd 服务（推荐）**

创建服务文件 `/etc/systemd/system/xiangxiu.service`：
```ini
[Unit]
Description=湘云绣阁后端服务
After=network.target

[Service]
User=www
Group=www
WorkingDirectory=/www/wwwroot/XiangXiu_github/backend
Environment="DEEPSEEK_API_KEY=sk-your-api-key-here"
Environment="DEEPSEEK_BASE_URL=https://api.deepseek.com"
ExecStart=/www/wwwroot/XiangXiu_github/backend/venv/bin/gunicorn -w 4 -b 127.0.0.1:5000 app:app
Restart=always

[Install]
WantedBy=multi-user.target
```

启用并启动服务：
```bash
sudo systemctl enable xiangxiu
sudo systemctl start xiangxiu
```

4. **Nginx 配置**
```nginx
server {
    listen 80;
    server_name your-domain.com;
    
    location / {
        root /www/wwwroot/XiangXiu_github/dist;
        index index.html;
        try_files $uri $uri/ /index.html;
    }
    
    location /api/ {
        proxy_pass http://127.0.0.1:5000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    
    location /static/ {
        alias /www/wwwroot/XiangXiu_github/backend/static/;
    }
}
```

5. **前端部署**
```bash
# 本地构建
npm run build

# 上传 dist 目录到服务器
scp -r dist root@your-server:/www/wwwroot/XiangXiu_github/
```

## 项目结构

```
XiangXiu_github/
├── backend/                # Flask 后端
│   ├── app.py             # 应用入口
│   ├── config.py          # 配置文件
│   ├── keyword_reply.sql  # 关键词表初始化 SQL
│   ├── requirements.txt   # Python 依赖
│   ├── models/            # 数据库模型
│   ├── templates/         # HTML 模板
│   │   ├── admin/         # 后台管理页面
│   │   └── base.html      # 基础模板
│   └── static/            # 静态文件（3D模型等）
├── src/                   # Vue 前端源码
│   ├── components/        # 组件
│   │   ├── ChatBot.vue    # AI 助手组件
│   │   └── common/        # 公共组件
│   ├── views/             # 页面视图
│   ├── router/            # 路由配置
│   ├── assets/            # 静态资源
│   └── App.vue            # 根组件
├── public/                # 公共资源
├── dist/                  # 构建输出（前端）
├── index.html             # HTML 入口
└── package.json           # Node 依赖
```

## API 接口

### AI 对话
- `POST /api/chat` - AI 对话接口
  ```json
  {
    "message": "湘绣的历史"
  }
  ```

### 知识库管理
- `GET /api/nodes` - 获取知识节点
- `POST /api/nodes` - 创建节点
- `POST /api/knowledge/import-file` - 批量导入知识

### 3D 模型
- `GET /api/models` - 获取模型列表
- `POST /api/models` - 上传模型
- `DELETE /api/models/:id` - 删除模型

## 数据库结构

### 主要数据表
- `user` - 用户表
- `product` - 产品表
- `knowledge_node` - 知识节点表
- `knowledge_relationship` - 知识关系表
- `keyword_reply` - 关键词回复表（AI助手）
- `model3d` - 3D模型表

## 贡献指南

1. Fork 本仓库
2. 创建新的分支 (`git checkout -b feature/your-feature`)
3. 提交你的更改 (`git commit -m 'Add some feature'`)
4. 推送到分支 (`git push origin feature/your-feature`)
5. 打开 Pull Request

## 更新日志

### 2025-04
- 新增 AI 智能助手功能（Deepseek API + RAG）
- 新增关键词回复管理后台
- 统一后台管理 UI 样式
- 新增 3D 模型管理功能

### 2025-03
- 项目更名为"湘云绣阁"
- 新增 Unity WebGL 虚拟展厅
- 部署至腾讯云服务器

## 许可证

本项目采用 MIT 许可证 - 详情请查看 [LICENSE](LICENSE) 文件

## 联系我们

如有任何问题或建议，请随时联系我们。

---

© 2025 湘云绣阁 版权所有
