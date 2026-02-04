<template>
  <div class="person-page">
    <!-- 头部区域 -->
    <section class="heading">
      <h3>个人中心</h3>
      <p> <router-link to="/">首页</router-link> / <span>个人中心</span> </p>
    </section>
    
    <!-- 个人身份与概览 -->
    <section class="profile-header">
      <div class="profile-avatar">
        <img :src="user.avatar || '/static/default-avatar.png'" alt="用户头像" class="avatar-img">
        <button class="avatar-upload-btn">
          <i class="fas fa-camera"></i>
        </button>
      </div>
      <div class="profile-info">
        <h2 class="profile-name">{{ user.username }}</h2>
        <p class="profile-greeting">{{ greetingMessage }}</p>
      </div>
      <div class="stats-grid">
        <div class="stat-card">
          <div class="stat-icon"><i class="fas fa-heart"></i></div>
          <div class="stat-info">
            <span class="stat-number">{{ stats.collectionCount }}</span>
            <span class="stat-label">我的收藏</span>
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-icon"><i class="fas fa-book"></i></div>
          <div class="stat-info">
            <span class="stat-number">{{ stats.learningProgress }}</span>
            <span class="stat-label">学习进度</span>
          </div>
        </div>

        <div class="stat-card">
          <div class="stat-icon"><i class="fas fa-shopping-bag"></i></div>
          <div class="stat-info">
            <span class="stat-number">{{ stats.pendingOrders }}</span>
            <span class="stat-label">待发货</span>
          </div>
        </div>
      </div>
    </section>
    
    <!-- 核心功能导航 -->
    <section class="function-grid">
      <div class="function-card" @click="goToCollect">
        <div class="function-icon">
          <i class="fas fa-box-open"></i>
        </div>
        <div class="function-info">
          <h3>我的藏品馆</h3>
          <p>查看收藏的作品和商品</p>
        </div>
      </div>
      
      <div class="function-card" @click="goToKnowledgeGraph">
        <div class="function-icon">
          <i class="fas fa-graduation-cap"></i>
        </div>
        <div class="function-info">
          <h3>我的工坊</h3>
          <p>继续学习和查看学习进度</p>
        </div>
      </div>
      
      <div class="function-card" @click="goToCart">
        <div class="function-icon">
          <i class="fas fa-shopping-cart"></i>
        </div>
        <div class="function-info">
          <h3>我的绣市</h3>
          <p>订单管理和购物车</p>
        </div>
      </div>
      
      <div class="function-card" @click="navigate('creation')">
        <div class="function-icon">
          <i class="fas fa-palette"></i>
        </div>
        <div class="function-info">
          <h3>我的创作</h3>
          <p>设计作品和评论笔记</p>
        </div>
      </div>
      
      <div class="function-card" @click="showSettingsDialog = true">
        <div class="function-icon">
          <i class="fas fa-cog"></i>
        </div>
        <div class="function-info">
          <h3>账户设置</h3>
          <p>修改密码和个人信息</p>
        </div>
      </div>
    </section>
    
    <!-- 动态与提醒 -->
    <section class="notifications-section">
      <div class="notification-card">
        <h3>系统消息</h3>
        <div class="notification-list">
          <div class="notification-item" v-for="(item, index) in notifications" :key="index">
            <div class="notification-icon"><i class="fas fa-bell"></i></div>
            <div class="notification-content">
              <p>{{ item.message }}</p>
              <span class="notification-time">{{ item.time }}</span>
            </div>
          </div>
        </div>
      </div>
      
      <div class="recommendations-card">
        <h3>专属推荐</h3>
        <div class="recommendation-list">
          <div class="recommendation-item" v-for="(item, index) in recommendations" :key="index">
            <img :src="item.image" alt="推荐作品" class="recommendation-image">
            <div class="recommendation-info">
              <p>{{ item.title }}</p>
              <button class="view-btn">查看</button>
            </div>
          </div>
        </div>
      </div>
    </section>
  </div>
  
  <!-- 账户设置弹窗 -->
  <div v-if="showSettingsDialog" class="settings-dialog-overlay" @click="showSettingsDialog = false">
    <div class="settings-dialog" @click.stop>
      <div class="dialog-header">
        <h3>账户设置</h3>
        <button @click="showSettingsDialog = false" class="close-btn">
          <i class="fas fa-times"></i>
        </button>
      </div>
      <div class="dialog-content">
        <div class="user-info-section" v-if="!isEditingProfile">
          <h4>个人信息</h4>
          <div class="info-item">
            <label>用户名:</label>
            <span>{{ user.username }}</span>
          </div>
          <div class="info-item">
            <label>邮箱:</label>
            <span>{{ user.email || '未设置' }}</span>
          </div>
          <div class="info-item">
            <label>注册时间:</label>
            <span>{{ formatDate(user.createdAt) || '未知' }}</span>
          </div>
        </div>
        
        <!-- 编辑资料表单 -->
        <div class="edit-profile-section" v-if="isEditingProfile">
          <div class="edit-header">
            <h4>编辑资料</h4>
            <p class="edit-subtitle">完善您的个人信息</p>
          </div>
          
          <div class="form-group">
            <label for="edit-username" class="form-label">
              <i class="fas fa-user"></i>
              用户名
            </label>
            <div class="input-wrapper">
              <input 
                type="text" 
                id="edit-username"
                v-model="editForm.username" 
                class="form-input"
                :class="{ 'error': formErrors.username }"
                placeholder="请输入新用户名"
                maxlength="8"
                @input="handleUsernameInput"
              >
              <span class="input-count">{{ editForm.username.length }}/8</span>
            </div>
            <span class="form-hint" :class="{ 'error-text': formErrors.username }">
              {{ formErrors.username || '用户名将显示在您的个人资料中' }}
            </span>
          </div>
          
          <div class="form-group">
            <label for="edit-email" class="form-label">
              <i class="fas fa-envelope"></i>
              邮箱地址
            </label>
            <div class="input-wrapper">
              <input 
                type="email" 
                id="edit-email"
                v-model="editForm.email" 
                class="form-input"
                :class="{ 'error': formErrors.email }"
                placeholder="请输入邮箱地址"
                @input="handleEmailInput"
              >
              <i class="fas fa-at input-icon"></i>
            </div>
            <span class="form-hint" :class="{ 'error-text': formErrors.email }">
              {{ formErrors.email || '用于接收重要通知和找回密码' }}
            </span>
          </div>
          
          <div class="form-actions">
            <button @click="saveProfile" class="save-btn" :disabled="!editForm.username.trim()">
              <i class="fas fa-check"></i>
              保存修改
            </button>
            <button @click="cancelEdit" class="cancel-btn">
              <i class="fas fa-arrow-left"></i>
              返回
            </button>
          </div>
        </div>
        
        <div class="action-buttons" v-if="!isEditingProfile">
          <button @click="changePassword" class="action-btn primary">
            <i class="fas fa-key"></i> 修改密码
          </button>
          <button @click="startEditProfile" class="action-btn secondary">
            <i class="fas fa-user-edit"></i> 编辑资料
          </button>
          <button @click="logout" class="action-btn danger">
            <i class="fas fa-sign-out-alt"></i> 退出登录
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, inject } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

// 用户信息
const user = ref({
  username: '湘绣爱好者',
  avatar: '/static/default-avatar.png'
})

// 统计数据
const stats = ref({
  collectionCount: 0,
  learningProgress: 0,
  pendingOrders: 2
})

// 问候消息
const greetingMessage = computed(() => {
  const hour = new Date().getHours()
  if (hour < 6) return '夜深了，注意休息'
  if (hour < 12) return '早上好，开始新的一天'
  if (hour < 18) return '下午好，继续加油'
  return '晚上好，放松一下'
})

// 通知消息
const notifications = ref([
  { message: '您的订单已发货', time: '今天 10:30' },
  { message: '新的课程已上线', time: '昨天 15:45' },
  { message: '活动报名成功', time: '3天前' }
])

// 弹窗状态
const showSettingsDialog = ref(false)

// 推荐内容
const recommendations = ref([
  { title: '湘绣技法入门', image: '/static/recommendation1.jpg' },
  { title: '传统纹样赏析', image: '/static/recommendation2.jpg' }
])

// 导航函数
const navigate = (path) => {
  router.push(`/user-center/${path}`)
}

// 跳转到收藏页面
const goToCollect = () => {
  router.push('/collect')
}

// 跳转到购物车页面
const goToCart = () => {
  router.push('/cart')
}

// 跳转到知识图谱页面
const goToKnowledgeGraph = () => {
  router.push('/knowledge-graph')
}

// 加载用户资料
const loadUserProfile = () => {
  const savedProfile = localStorage.getItem('userProfile')
  if (savedProfile) {
    try {
      const profile = JSON.parse(savedProfile)
      user.value.username = profile.username || '湘绣爱好者'
      user.value.email = profile.email || ''
      user.value.createdAt = profile.createdAt || new Date().toISOString()
      console.log('用户资料加载成功:', profile)
    } catch (error) {
      console.error('加载用户资料失败:', error)
    }
  }
}

// 格式化日期
const formatDate = (dateString) => {
  if (!dateString) return '未知'
  const date = new Date(dateString)
  return date.toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
  })
}

// 修改密码
const changePassword = () => {
  flash('密码修改功能开发中...')
  showSettingsDialog.value = false
}

// 编辑资料状态
const isEditingProfile = ref(false)
const editForm = ref({
  username: '',
  email: ''
})

// 表单验证状态
const formErrors = ref({
  username: '',
  email: ''
})

// 开始编辑资料
const startEditProfile = () => {
  // 初始化表单数据
  editForm.value.username = user.value.username
  editForm.value.email = user.value.email || ''
  // 清空之前的错误信息
  formErrors.value.username = ''
  formErrors.value.email = ''
  isEditingProfile.value = true
}

// 保存资料
const saveProfile = () => {
  // 验证表单
  const isUsernameValid = validateUsername(editForm.value.username)
  const isEmailValid = validateEmail(editForm.value.email)
  
  if (!isUsernameValid || !isEmailValid) {
    return
  }
  
  // 更新用户信息
  user.value.username = editForm.value.username.trim()
  user.value.email = editForm.value.email.trim()
  
  // 保存到localStorage
  const userData = {
    username: user.value.username,
    email: user.value.email,
    updatedAt: new Date().toISOString()
  }
  localStorage.setItem('userProfile', JSON.stringify(userData))
  
  flash('资料更新成功！')
  isEditingProfile.value = false
}

// 验证用户名
const validateUsername = (username) => {
  if (!username.trim()) {
    formErrors.value.username = '用户名不能为空'
    return false
  }
  if (username.length < 2) {
    formErrors.value.username = '用户名至少需要2个字符'
    return false
  }
  if (username.length > 8) {
    formErrors.value.username = '用户名不能超过8个字符'
    return false
  }
  formErrors.value.username = ''
  return true
}

// 验证邮箱
const validateEmail = (email) => {
  if (email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    formErrors.value.email = '请输入有效的邮箱地址'
    return false
  }
  formErrors.value.email = ''
  return true
}

// 实时验证
const handleUsernameInput = () => {
  validateUsername(editForm.value.username)
}

const handleEmailInput = () => {
  validateEmail(editForm.value.email)
}

// 取消编辑
const cancelEdit = () => {
  isEditingProfile.value = false
  editForm.value.username = ''
  editForm.value.email = ''
  formErrors.value.username = ''
  formErrors.value.email = ''
}

// 退出登录
const logout = () => {
  const store = inject('store')
  if (store && store.logout) {
    store.logout()
    flash('已成功退出登录')
    router.push('/')
  }
  showSettingsDialog.value = false
}

// 生命周期钩子
onMounted(() => {
  // 加载用户资料
  loadUserProfile()
  
  // 同步收藏数量
  syncCollectionCount()
  
  // 同步知识图谱学习进度
  syncKnowledgeGraphProgress()
  
  // 监听localStorage变化，实时更新数据
  window.addEventListener('storage', (e) => {
    if (e.key === 'userCollections') {
      console.log('检测到收藏数据变化，重新同步...')
      syncCollectionCount()
    } else if (e.key === 'knowledgeGraphProgress') {
      console.log('检测到学习进度变化，重新同步...')
      syncKnowledgeGraphProgress()
    } else if (e.key === 'userProfile') {
      console.log('检测到用户资料变化，重新加载...')
      loadUserProfile()
    }
  })
  
  // 可以在这里加载其他用户数据
  console.log('个人中心页面加载完成')
})

// 同步收藏数量
const syncCollectionCount = () => {
  // 从localStorage获取收藏数据
  const savedCollections = localStorage.getItem('userCollections')
  if (savedCollections) {
    try {
      const collections = JSON.parse(savedCollections)
      stats.value.collectionCount = collections.length
      console.log('从localStorage获取收藏数量:', collections.length)
    } catch (error) {
      console.error('解析收藏数据失败:', error)
      stats.value.collectionCount = 0
    }
  } else {
    // 如果没有localStorage数据，尝试从store获取
    try {
      const store = inject('store')
      if (store && store.getCollectItems) {
        const collections = store.getCollectItems()
        stats.value.collectionCount = collections.length
        console.log('从store获取收藏数量:', collections.length)
      } else {
        console.log('store中没有getCollectItems方法')
        stats.value.collectionCount = 0
      }
    } catch (error) {
      console.error('获取收藏数据失败:', error)
      stats.value.collectionCount = 0
    }
  }
  
  // 添加调试信息
  console.log('当前收藏数量:', stats.value.collectionCount)
}

// 同步知识图谱学习进度
const syncKnowledgeGraphProgress = () => {
  const savedProgress = localStorage.getItem('knowledgeGraphProgress')
  if (savedProgress) {
    try {
      const progressData = JSON.parse(savedProgress)
      const learnedNodes = progressData.learnedNodes || []
      const totalNodes = 50 // 假设总共有50个节点，可以根据实际情况调整
      
      if (totalNodes > 0) {
        stats.value.learningProgress = Math.round((learnedNodes.length / totalNodes) * 100)
      }
      console.log('从localStorage获取学习进度:', stats.value.learningProgress)
    } catch (error) {
      console.error('解析学习进度数据失败:', error)
      stats.value.learningProgress = 0
    }
  } else {
    stats.value.learningProgress = 0
    console.log('没有找到学习进度数据')
  }
}
</script>

<style scoped>
/* 页面样式 */
.person-page {
  max-width: 1200px;
  margin: 0 auto;
  margin-top: 100px;
  padding-bottom: 50px;
}

/* 页面标题样式 */
.heading {
  background: var(--primary-color);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 2rem 9%;
  margin-bottom: 0;
  position: relative;
  overflow: hidden;
}

.heading h3 {
  font-size: 2.8rem;
  text-transform: uppercase;
  color: #fff;
  font-weight: 600;
  letter-spacing: 1px;
  margin-bottom: 0;
  position: relative;
  z-index: 1;
}

.heading p {
  color: #fff;
  font-size: 1.8rem;
  margin: 0;
  position: relative;
  z-index: 1;
}

.heading p a {
  color: #fff;
  text-decoration: none;
  transition: color 0.3s ease;
}

.heading p a:hover {
  color: var(--warning-color);
  text-decoration: underline;
}

.heading p span {
  color: var(--warning-color);
}

/* 个人信息头部 */
.profile-header {
  padding: 4rem 9%;
  background-color: #fff;
  margin-top: 30px;
  box-shadow: var(--box-shadow);
  border-radius: 8px;
  text-align: center;
}

.profile-avatar {
  position: relative;
  display: inline-block;
  margin-bottom: 2rem;
}

.avatar-img {
  width: 150px;
  height: 150px;
  border-radius: 50%;
  object-fit: cover;
  border: 4px solid var(--primary-light);
  box-shadow: 0 4px 12px rgba(36, 77, 77, 0.2);
}

.avatar-upload-btn {
  position: absolute;
  bottom: 5px;
  right: 5px;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background-color: var(--primary-color);
  color: #fff;
  border: none;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s ease;
  font-size: 1.6rem;
}

.avatar-upload-btn:hover {
  background-color: var(--primary-light);
  transform: scale(1.1);
}

.profile-name {
  font-size: 2.8rem;
  color: var(--primary-color);
  margin-bottom: 1rem;
  font-weight: 600;
}

.profile-greeting {
  font-size: 1.8rem;
  color: var(--text-secondary);
  margin-bottom: 3rem;
}

/* 统计数据网格 */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 2rem;
  max-width: 800px;
  margin: 0 auto;
}

.stat-card {
  display: flex;
  align-items: center;
  gap: 1.5rem;
  padding: 2rem;
  background-color: #f9f9f9;
  border-radius: 12px;
  transition: all 0.3s ease;
  border: 2px solid transparent;
}

.stat-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 25px rgba(36, 77, 77, 0.15);
  border-color: var(--primary-light);
}

.stat-icon {
  width: 60px;
  height: 60px;
  background-color: var(--primary-light);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 2.4rem;
  color: #fff;
  transition: all 0.3s ease;
}

.stat-card:hover .stat-icon {
  background-color: var(--primary-color);
  transform: scale(1.1);
}

.stat-number {
  font-size: 2.4rem;
  color: var(--primary-color);
  font-weight: 600;
  display: block;
}

.stat-label {
  font-size: 1.4rem;
  color: var(--text-secondary);
  display: block;
}

/* 功能网格 */
.function-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 2.5rem;
  padding: 4rem 9%;
  max-width: 1200px;
  margin: 0 auto;
}

.function-card {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
  padding: 2.5rem;
  background-color: #fff;
  border-radius: 12px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
  cursor: pointer;
  border: 2px solid transparent;
}

.function-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 12px 30px rgba(36, 77, 77, 0.15);
  border-color: var(--primary-light);
}

.function-icon {
  width: 70px;
  height: 70px;
  background-color: var(--primary-light);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 3rem;
  color: #fff;
  transition: all 0.3s ease;
}

.function-card:hover .function-icon {
  background-color: var(--primary-color);
  transform: scale(1.1);
}

.function-info h3 {
  font-size: 2.2rem;
  color: var(--primary-color);
  margin-bottom: 1rem;
  font-weight: 600;
}

.function-info p {
  font-size: 1.6rem;
  color: var(--text-secondary);
  line-height: 1.6;
}

/* 通知与推荐区域 */
.notifications-section {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
  gap: 2.5rem;
  padding: 0 9% 4rem;
  max-width: 1200px;
  margin: 0 auto;
}

.notification-card,
.recommendations-card {
  background-color: #fff;
  border-radius: 12px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.08);
  padding: 2.5rem;
}

.notification-card h3,
.recommendations-card h3 {
  font-size: 2rem;
  color: var(--primary-color);
  margin-bottom: 2rem;
  font-weight: 600;
}

.notification-list,
.recommendation-list {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.notification-item {
  display: flex;
  align-items: flex-start;
  gap: 1.5rem;
  padding: 1.5rem;
  background-color: #f9f9f9;
  border-radius: 8px;
}

.notification-icon {
  width: 40px;
  height: 40px;
  background-color: var(--primary-light);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.8rem;
  color: #fff;
  flex-shrink: 0;
}

.notification-content p {
  font-size: 1.6rem;
  color: var(--text-color);
  margin-bottom: 0.5rem;
}

.notification-time {
  font-size: 1.4rem;
  color: var(--text-secondary);
}

.recommendation-item {
  display: flex;
  align-items: center;
  gap: 1.5rem;
  padding: 1.5rem;
  background-color: #f9f9f9;
  border-radius: 8px;
}

.recommendation-image {
  width: 80px;
  height: 80px;
  object-fit: cover;
  border-radius: 8px;
  flex-shrink: 0;
}

.recommendation-info p {
  font-size: 1.6rem;
  color: var(--text-color);
  margin-bottom: 1rem;
}

.view-btn {
  padding: 0.8rem 1.6rem;
  background-color: var(--primary-color);
  color: #fff;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-size: 1.4rem;
  transition: all 0.3s ease;
}

.view-btn:hover {
  background-color: var(--primary-light);
  transform: translateY(-2px);
}

/* 响应式设计 */
@media (max-width: 768px) {
  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .function-grid {
    grid-template-columns: 1fr;
  }
  
  .notifications-section {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 450px) {
  .stats-grid {
    grid-template-columns: 1fr;
  }
  
  .profile-header {
    padding: 2rem 5%;
  }
  
  .function-grid {
    padding: 2rem 5%;
  }
  
  .notifications-section {
    padding: 0 5% 2rem;
  }
}
/* 账户设置弹窗样式 */
.settings-dialog-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.settings-dialog {
  background-color: #fff;
  border-radius: 12px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
  width: 90%;
  max-width: 500px;
  max-height: 80vh;
  overflow-y: auto;
}

.dialog-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 2rem;
  border-bottom: 1px solid #eee;
}

.dialog-header h3 {
  font-size: 2rem;
  color: var(--primary-color);
  margin: 0;
}

.close-btn {
  background: none;
  border: none;
  font-size: 2rem;
  color: #999;
  cursor: pointer;
  transition: color 0.3s ease;
}

.close-btn:hover {
  color: var(--primary-color);
}

.dialog-content {
  padding: 2rem;
}

.user-info-section {
  margin-bottom: 2rem;
}

.user-info-section h4 {
  font-size: 1.6rem;
  color: var(--text-color);
  margin-bottom: 1.5rem;
  border-left: 4px solid var(--primary-color);
  padding-left: 1rem;
}

.info-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 0;
  border-bottom: 1px solid #f0f0f0;
}

.info-item:last-child {
  border-bottom: none;
}

.info-item label {
  font-weight: 600;
  color: var(--text-secondary);
  font-size: 1.4rem;
}

.info-item span {
  color: var(--text-color);
  font-size: 1.4rem;
}

.action-buttons {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.action-btn {
  padding: 1.2rem;
  border: none;
  border-radius: 8px;
  font-size: 1.5rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.8rem;
}

.action-btn.primary {
  background-color: var(--primary-color);
  color: #fff;
}

.action-btn.primary:hover {
  background-color: var(--primary-light);
  transform: translateY(-2px);
}

.action-btn.secondary {
  background-color: #f9f9f9;
  color: var(--primary-color);
  border: 2px solid var(--primary-color);
}

.action-btn.secondary:hover {
  background-color: var(--primary-color);
  color: #fff;
  transform: translateY(-2px);
}

.action-btn.danger {
  background-color: #f44336;
  color: #fff;
}

.action-btn.danger:hover {
  background-color: #d32f2f;
  transform: translateY(-2px);
}

/* 编辑资料表单样式 */
.edit-profile-section {
  animation: slideInUp 0.3s ease;
}

@keyframes slideInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.edit-header {
  text-align: center;
  margin-bottom: 2.5rem;
  padding-bottom: 1.5rem;
  border-bottom: 1px solid #f0f0f0;
}

.edit-header h4 {
  font-size: 2rem;
  color: var(--primary-color);
  margin-bottom: 0.5rem;
  font-weight: 600;
}

.edit-subtitle {
  font-size: 1.4rem;
  color: var(--text-secondary);
  margin: 0;
}

.form-group {
  margin-bottom: 2rem;
}

.form-label {
  display: flex;
  align-items: center;
  gap: 0.8rem;
  font-size: 1.5rem;
  font-weight: 600;
  color: var(--text-color);
  margin-bottom: 0.8rem;
  cursor: pointer;
}

.form-label i {
  color: var(--primary-color);
  font-size: 1.6rem;
}

.input-wrapper {
  position: relative;
  display: flex;
  align-items: center;
}

.form-input {
  width: 100%;
  padding: 1.2rem 4rem 1.2rem 1.5rem;
  border: 2px solid #e0e0e0;
  border-radius: 10px;
  font-size: 1.5rem;
  transition: all 0.3s ease;
  background-color: #fafafa;
}

.form-input:focus {
  outline: none;
  border-color: var(--primary-color);
  background-color: #fff;
  box-shadow: 0 0 0 3px rgba(36, 77, 77, 0.1);
}

.form-input:hover {
  border-color: var(--primary-light);
}

.input-count {
  position: absolute;
  right: 1rem;
  font-size: 1.2rem;
  color: var(--text-secondary);
  background-color: rgba(255, 255, 255, 0.8);
  padding: 0.2rem 0.5rem;
  border-radius: 4px;
}

.input-icon {
  position: absolute;
  right: 1rem;
  font-size: 1.4rem;
  color: var(--text-secondary);
  pointer-events: none;
}

.form-hint {
  display: block;
  font-size: 1.2rem;
  color: var(--text-secondary);
  margin-top: 0.5rem;
  padding-left: 0.5rem;
}

.form-actions {
  display: flex;
  gap: 1rem;
  margin-top: 2.5rem;
  padding-top: 2rem;
  border-top: 1px solid #f0f0f0;
}

.save-btn,
.cancel-btn {
  flex: 1;
  padding: 1.2rem 2rem;
  border: none;
  border-radius: 8px;
  font-size: 1.5rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.8rem;
}

.save-btn {
  background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-light) 100%);
  color: #fff;
  box-shadow: 0 4px 12px rgba(36, 77, 77, 0.2);
}

.save-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(36, 77, 77, 0.3);
}

.save-btn:disabled {
  background-color: #ccc;
  cursor: not-allowed;
  box-shadow: none;
}

.cancel-btn {
  background-color: #f5f5f5;
  color: var(--text-secondary);
  border: 1px solid #e0e0e0;
}

.cancel-btn:hover {
  background-color: #e8e8e8;
  transform: translateY(-1px);
}

/* 表单错误状态 */
.form-input.error {
  border-color: #f44336;
  background-color: #fff5f5;
}

.form-input.error:focus {
  box-shadow: 0 0 0 3px rgba(244, 67, 54, 0.1);
}

.form-hint.error-text {
  color: #f44336;
  font-weight: 500;
}

.form-label.error {
  color: #f44336;
}

.form-label.error i {
  color: #f44336;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .settings-dialog {
    width: 95%;
    margin: 2rem;
  }
  
  .dialog-content {
    padding: 1.5rem;
  }
  
  .edit-header h4 {
    font-size: 1.8rem;
  }
  
  .form-actions {
    flex-direction: column;
  }
  
  .save-btn,
  .cancel-btn {
    width: 100%;
  }
}

@media (max-width: 450px) {
  .action-buttons {
    gap: 0.8rem;
  }
  
  .action-btn {
    padding: 1rem;
    font-size: 1.4rem;
  }
  
  .form-input {
    padding: 1rem 3.5rem 1rem 1.2rem;
    font-size: 1.4rem;
  }
  
  .form-label {
    font-size: 1.4rem;
  }
}

</style>