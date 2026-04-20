<template>
  <div class="models-container">
    <section class="heading">
      <h3>3D模型展示</h3>
      <p>
        <router-link to="/">首页</router-link> /
        <span>3D模型</span>
      </p>
    </section>

    <section class="models-content">
      <div class="page-header">
        <h2 class="guofeng-title">湘绣3D模型库</h2>
        <p class="section-subtitle">沉浸式体验湘绣艺术的三维魅力</p>
        <div class="title-decoration">
          <span class="decoration-line"></span>
          <span class="decoration-dot">◆</span>
          <span class="decoration-line"></span>
        </div>
      </div>

      <div class="filters">
        <div class="search-container">
          <input
            v-model="searchQuery"
            @input="handleSearch"
            type="text"
            placeholder="搜索模型..."
            class="search-input"
          />
          <span class="search-icon"><i class="fas fa-search"></i></span>
        </div>
        <select v-model="selectedCategory" @change="handleFilter" class="category-select">
          <option value="">所有分类</option>
          <option v-for="cat in categories" :key="cat" :value="cat">{{ cat }}</option>
        </select>
      </div>

      <div v-if="loading" class="loading">
        <div class="loading-spinner"></div>
        <p>加载中...</p>
      </div>

      <div v-else-if="models.length === 0" class="empty">
        <div class="empty-icon">
          <i class="fas fa-cube"></i>
        </div>
        <h3>暂无3D模型</h3>
        <p>暂无3D模型数据，请联系管理员添加</p>
      </div>

      <div v-else class="models-grid">
        <div v-for="model in models" :key="model.id" class="model-card">
          <div class="model-preview" :class="'format-' + getFileType(model.file_path).toLowerCase()">
            <div class="preview-overlay">
              <span class="file-type">{{ getFileType(model.file_path) }}</span>
            </div>
            <div class="placeholder">
              <span class="format-icon">{{ getFormatIcon(getFileType(model.file_path)) }}</span>
              <span class="model-icon"><i class="fas fa-cube"></i></span>
            </div>
          </div>
          <div class="model-info">
            <h3 class="model-title">{{ model.name }}</h3>
            <p class="category">{{ model.category || '未分类' }}</p>
            <p class="description">{{ model.description || '暂无描述' }}</p>
            <div class="tags">
              <span v-for="tag in model.tags" :key="tag.id" class="tag">{{ tag.name }}</span>
            </div>
            <div class="actions">
              <router-link :to="`/models/${model.id}`" class="btn guofeng-btn view-btn">
                <span>查看</span>
                <i class="fas fa-eye"></i>
              </router-link>
            </div>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'

const models = ref([])
const categories = ref([])
const searchQuery = ref('')
const selectedCategory = ref('')
const loading = ref(false)

const API_BASE_URL = 'http://localhost:5000'

const loadModels = async () => {
  loading.value = true
  try {
    const params = {}
    if (searchQuery.value) params.search = searchQuery.value
    if (selectedCategory.value) params.category = selectedCategory.value

    const response = await axios.get(`${API_BASE_URL}/api/models`, { params })
    models.value = response.data
  } catch (err) {
    console.error('加载模型失败:', err)
    models.value = []
  } finally {
    loading.value = false
  }
}

const loadCategories = async () => {
  try {
    const response = await axios.get(`${API_BASE_URL}/api/model-categories`)
    categories.value = response.data
  } catch (err) {
    console.error('加载分类失败:', err)
    categories.value = []
  }
}

const handleSearch = () => {
  loadModels()
}

const handleFilter = () => {
  loadModels()
}

const getFileType = (filePath) => {
  if (!filePath) return 'Unknown'
  const extension = filePath.split('.').pop().toUpperCase()
  return extension
}

const getFormatIcon = (format) => {
  const icons = {
    'GLB': '📦',
    'GLTF': '📦',
    'OBJ': '🎯',
    'FBX': '🎬',
    'STL': '🧊',
    'PLY': '📐',
    'DAE': '🎭',
    '3DS': '🎨',
    'DRC': '🔧',
    'USDZ': '💎',
    'USD': '💎'
  }
  return icons[format] || '📄'
}

onMounted(() => {
  loadModels()
  loadCategories()
})
</script>

<style scoped>
.models-container {
  max-width: 1200px;
  margin: 0 auto;
  margin-top: 100px;
}

.heading {
  background: var(--primary-color);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 2rem 9%;
  margin-bottom: 3rem;
}

.heading h3 {
  font-size: 2.8rem;
  text-transform: uppercase;
  color: #fff;
  font-weight: 600;
  letter-spacing: 1px;
  margin-bottom: 0;
}

.heading p {
  color: #fff;
  font-size: 1.8rem;
  margin: 0;
}

.heading p a {
  color: #fff;
  text-decoration: none;
}

.heading p a:hover {
  color: var(--warning-color);
}

.models-content {
  padding: 4rem 9%;
  background-color: #f9f9f9;
  min-height: 600px;
}

.page-header {
  text-align: center;
  margin-bottom: 4rem;
}

.guofeng-title {
  font-size: 3.2rem;
  color: var(--primary-color);
  font-weight: 700;
  font-family: 'Noto Serif SC', serif;
  margin-bottom: 1rem;
  letter-spacing: 0.15em;
}

.section-subtitle {
  font-size: 1.8rem;
  color: #666;
  margin-bottom: 1rem;
}

.title-decoration {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  margin-top: 1rem;
}

.decoration-line {
  width: 60px;
  height: 2px;
  background: linear-gradient(90deg, transparent, var(--primary-color), transparent);
}

.decoration-dot {
  color: var(--primary-color);
  font-size: 1.5rem;
}

.filters {
  display: flex;
  gap: 1rem;
  margin-bottom: 3rem;
  flex-wrap: wrap;
  max-width: 800px;
  margin-left: auto;
  margin-right: auto;
}

.search-container {
  flex: 1;
  position: relative;
  min-width: 250px;
}

.search-input {
  width: 100%;
  padding: 1rem 3rem 1rem 1.5rem;
  border: 2px solid var(--primary-color);
  border-radius: 25px;
  font-size: 1.6rem;
  transition: all 0.3s ease;
  background: #fff;
  font-family: 'Noto Serif SC', serif;
}

.search-input:focus {
  outline: none;
  box-shadow: 0 0 0 3px rgba(36, 77, 77, 0.1);
}

.search-icon {
  position: absolute;
  right: 1.5rem;
  top: 50%;
  transform: translateY(-50%);
  color: var(--primary-color);
  font-size: 1.6rem;
}

.category-select {
  padding: 1rem 1.5rem;
  border: 2px solid var(--primary-color);
  border-radius: 25px;
  font-size: 1.6rem;
  transition: all 0.3s ease;
  background: #fff;
  min-width: 180px;
  font-family: 'Noto Serif SC', serif;
  cursor: pointer;
}

.category-select:focus {
  outline: none;
  box-shadow: 0 0 0 3px rgba(36, 77, 77, 0.1);
}

.loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 6rem;
  color: var(--primary-color);
}

.loading-spinner {
  width: 50px;
  height: 50px;
  border: 4px solid rgba(36, 77, 77, 0.1);
  border-top: 4px solid var(--primary-color);
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 2rem;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.empty {
  text-align: center;
  padding: 6rem 2rem;
  background: #fff;
  border-radius: 15px;
  box-shadow: 0 5px 20px rgba(0, 0, 0, 0.1);
  margin: 2rem auto;
  max-width: 500px;
}

.empty-icon {
  font-size: 6rem;
  color: var(--primary-color);
  margin-bottom: 2rem;
  opacity: 0.5;
}

.empty h3 {
  font-size: 2.4rem;
  margin-bottom: 1rem;
  color: var(--primary-color);
  font-family: 'Noto Serif SC', serif;
}

.empty p {
  color: #666;
  font-size: 1.6rem;
}

.models-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 2.5rem;
}

.model-card {
  background: #fff;
  border-radius: 15px;
  overflow: hidden;
  box-shadow: 0 5px 20px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
  display: flex;
  flex-direction: column;
  height: 100%;
}

.model-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 15px 40px rgba(0, 0, 0, 0.15);
}

.model-preview {
  height: 200px;
  background: #244d4d;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  overflow: hidden;
}

.model-preview.format-glb,
.model-preview.format-gltf {
  background: #244d4d;
}

.model-preview.format-obj {
  background: #244d4d;
}

.model-preview.format-fbx {
  background: #244d4d;
}

.model-preview.format-stl {
  background: #244d4d;
}

.model-preview.format-ply {
  background: #244d4d;
}

.model-preview.format-dae {
  background: #244d4d;
}

.preview-overlay {
  position: absolute;
  top: 1rem;
  right: 1rem;
  background: rgba(0, 0, 0, 0.5);
  color: white;
  padding: 0.5rem 1rem;
  border-radius: 20px;
  font-size: 1.2rem;
  font-weight: 500;
}

.placeholder {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: white;
}

.format-icon {
  font-size: 4rem;
  margin-bottom: 0.5rem;
  filter: drop-shadow(0 2px 4px rgba(0,0,0,0.2));
}

.model-icon {
  font-size: 2.5rem;
  opacity: 0.8;
}

.model-info {
  padding: 2rem;
  flex: 1;
  display: flex;
  flex-direction: column;
}

.model-title {
  margin-bottom: 0.8rem;
  color: var(--primary-color);
  font-size: 2rem;
  font-weight: 600;
  font-family: 'Noto Serif SC', serif;
}

.category {
  color: var(--primary-color);
  font-size: 1.4rem;
  font-weight: 500;
  margin-bottom: 1rem;
  text-transform: capitalize;
  opacity: 0.8;
}

.description {
  color: #666;
  font-size: 1.5rem;
  margin-bottom: 1.5rem;
  line-height: 1.6;
  flex: 1;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.tags {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
  margin-bottom: 2rem;
}

.tag {
  background: rgba(36, 77, 77, 0.1);
  color: var(--primary-color);
  padding: 0.4rem 1rem;
  border-radius: 20px;
  font-size: 1.3rem;
  font-weight: 500;
}

.actions {
  display: flex;
  gap: 1rem;
  margin-top: auto;
}

.view-btn {
  flex: 1;
  text-align: center;
  justify-content: center;
  gap: 0.8rem;
  padding: 1rem 2rem;
  font-size: 1.6rem;
}

@media (max-width: 768px) {
  .models-content {
    padding: 3rem 5%;
  }

  .guofeng-title {
    font-size: 2.5rem;
  }

  .filters {
    flex-direction: column;
  }

  .search-container,
  .category-select {
    width: 100%;
  }

  .models-grid {
    grid-template-columns: 1fr;
  }
}
</style>
