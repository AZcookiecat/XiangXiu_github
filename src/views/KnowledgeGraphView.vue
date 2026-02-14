<template>
  <div class="knowledge-graph-container">
    <!-- 页面头部 -->
    <div class="heading">
      <h3>湘绣知识图谱</h3>
      <p><router-link to="/">首页</router-link> <span>/</span> 知识图谱</p>
    </div>

    <!-- 主要内容区域 -->
    <div class="graph-content">
      <!-- 控制区域 -->
      <div class="control-panel">
        <div class="search-section">
          <input 
            type="text" 
            v-model="searchTerm"
            placeholder="搜索湘绣知识..."
            class="search-input"
            @input="handleSearch"
          >
          <button class="search-btn" @click="handleSearch">
            <i class="fas fa-search"></i> 搜索
          </button>
        </div>
        
        <div class="graph-controls">
          <button class="control-btn" @click="zoomIn">
            <i class="fas fa-search-plus"></i> 放大
          </button>
          <button class="control-btn" @click="zoomOut">
            <i class="fas fa-search-minus"></i> 缩小
          </button>
          <button class="control-btn" @click="resetView">
            <i class="fas fa-redo"></i> 重置视图
          </button>

        </div>
      </div>

      <!-- 知识图谱展示区域 -->
      <div class="graph-display" ref="graphContainer">
        <!-- 加载状态 -->
        <div v-if="loading" class="loading-overlay">
          <div class="loading-spinner"></div>
          <p>加载知识图谱中...</p>
        </div>
        
        <!-- 错误提示 -->
        <div v-if="error" class="error-message">
          <p>{{ error }}</p>
          <button class="retry-btn" @click="fetchKnowledgeGraph">重试</button>
        </div>



        <!-- 知识图谱可视化 - 使用 ECharts -->
        <div ref="graphChart" class="graph-chart"></div>
      </div>

      <!-- 详情展示区域 -->
      <transition name="node-details">
        <div v-if="selectedNode" class="node-details">
          <div class="details-header">
            <h4>{{ selectedNode.name }}</h4>
            <button class="close-btn" @click="clearSelection">
              <i class="fas fa-times"></i>
            </button>
          </div>
          <div class="details-content">
            <div class="detail-item">
              <strong>类别:</strong> {{ selectedNode.category }}
            </div>
            <div class="detail-item">
              <strong>描述:</strong> {{ selectedNode.description }}
            </div>
            <div v-if="selectedNode.related" class="detail-item">
              <strong>相关概念:</strong>
              <div class="related-concepts">
                <span 
                  v-for="related in selectedNode.related" 
                  :key="related"
                  class="related-tag"
                  @click="highlightRelated(related)"
                >
                  {{ related }}
                </span>
              </div>
            </div>
            <div v-if="selectedNode.imageUrl" class="detail-item">
              <img :src="selectedNode.imageUrl" :alt="selectedNode.name" class="node-image" loading="lazy">
            </div>
            <div class="detail-actions">
              <button @click="learnNode(selectedNode)" class="learn-btn">
                <i class="fas fa-check"></i> 标记学习
              </button>
              <button class="resource-btn" @click="unlearnNode(selectedNode)">
            <i class="fas fa-undo"></i> 取消标记
              </button>
            </div>
          </div>
        </div>
      </transition>

      <!-- 信息卡片区域 -->
      <div class="info-cards">
        <div class="info-card">
          <div class="card-icon">
            <i class="fas fa-book"></i>
          </div>
          <div class="card-content">
            <h4>湘绣历史</h4>
            <p>湘绣是中国四大名绣之一，源于湖南长沙，有着悠久的历史和独特的艺术风格。</p>
          </div>
        </div>
        <div class="info-card">
          <div class="card-icon">
            <i class="fas fa-paint-brush"></i>
          </div>
          <div class="card-content">
            <h4>独特技法</h4>
            <p>湘绣以针法精湛著称，尤其擅长运用掺针、齐针等多种针法表现物体的质感和层次。</p>
          </div>
        </div>
        <div class="info-card">
          <div class="card-icon">
            <i class="fas fa-award"></i>
          </div>
          <div class="card-content">
            <h4>文化传承</h4>
            <p>湘绣已被列入国家级非物质文化遗产名录，是湖湘文化的重要组成部分。</p>
          </div>
        </div>
      </div>
    </div>

    <!-- 学习进度区域 -->
      <div class="progress-container">
        <h4>学习进度</h4>
        <div class="progress-bar">
          <div class="progress" :style="{ width: progress + '%' }"></div>
        </div>
        <p>{{ progress }}% 完成</p>
        <div class="progress-stats">
          <div class="stat-item">
            <span class="stat-label">已学习节点</span>
            <span class="stat-value">{{ learnedNodes.length }}</span>
          </div>
          <div class="stat-item">
            <span class="stat-label">总节点数</span>
            <span class="stat-value">{{ knowledgeGraphData.nodes.length }}</span>
          </div>
          <div class="stat-item">
            <span class="stat-label">学习时长</span>
            <span class="stat-value">{{ totalStudyTime }}分钟</span>
          </div>
        </div>
        <button @click="scrollToTop" class="continue-btn">
          <i class="fas fa-arrow-up"></i> 继续学习
        </button>
      </div>

    <!-- 知识图谱简介 -->
    <div class="graph-intro">
      <h3>关于湘绣知识图谱</h3>
      <p>本知识图谱整合了湘绣的历史渊源、工艺技法、代表作品、材料工具和文化内涵等多维度信息，以可视化方式呈现湘绣文化的知识体系。通过探索知识图谱，您可以深入了解湘绣这一国家级非物质文化遗产的丰富内涵。</p>
    </div>

    <!-- 添加节点模态框 -->
    <transition name="modal">
      <div v-if="showAddNodeModal" class="modal-overlay" @click="closeAddNodeModal">
        <div class="modal-content" @click.stop>
          <div class="modal-header">
            <h4>{{ addNodeSuccess ? '添加成功' : '添加知识节点' }}</h4>
            <button class="close-btn" @click="closeAddNodeModal">
              <i class="fas fa-times"></i>
            </button>
          </div>
          <div class="modal-body">
            <div v-if="addNodeSuccess" class="success-message">
              <div class="success-icon">
                <i class="fas fa-check-circle"></i>
              </div>
              <p>节点添加成功！图谱已自动更新。</p>
            </div>
            <form v-else @submit.prevent="submitAddNode">
              <div class="form-group">
                <label for="node-name">名称（可选）</label>
                <input 
                  type="text" 
                  id="node-name" 
                  v-model="newNode.name"
                  class="form-input"
                  placeholder="节点名称"
                >
              </div>
              <div class="form-group">
                <label for="node-category">类别 <span class="required">*</span></label>
                <input 
                  type="text" 
                  id="node-category" 
                  v-model="newNode.category"
                  class="form-input"
                  placeholder="节点类别"
                  required
                >
              </div>
              <div class="form-group">
                <label for="node-content">内容 <span class="required">*</span></label>
                <textarea 
                  id="node-content" 
                  v-model="newNode.content"
                  class="form-textarea"
                  placeholder="节点内容"
                  rows="4"
                  required
                ></textarea>
              </div>
              <div class="form-actions">
                <button type="button" class="btn btn-secondary" @click="closeAddNodeModal">
                  取消
                </button>
                <button type="submit" class="btn btn-primary">
                  添加节点
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </transition>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, nextTick } from 'vue'
import axios from 'axios'

// 响应式数据
const searchTerm = ref('')
const selectedNode = ref(null)
const graphChart = ref(null)
const loading = ref(true)
const error = ref(null)
let chart = null // ECharts 实例

// 学习进度
const progress = ref(0)
const learnedNodes = ref([])
const totalStudyTime = ref(0)

// 知识图谱数据
const knowledgeGraphData = ref({
  nodes: [],
  links: []
})

// 节点详细信息
const nodeDetails = ref({})

// 添加节点的模态框状态
const showAddNodeModal = ref(false)
const newNode = ref({
  category: '',
  content: '',
  name: ''
})
const addNodeSuccess = ref(false)

// 从localStorage加载学习记录
const loadLearningProgress = () => {
  const saved = localStorage.getItem('knowledgeGraphProgress')
  if (saved) {
    const data = JSON.parse(saved)
    learnedNodes.value = data.learnedNodes || []
    totalStudyTime.value = data.totalStudyTime || 0
    updateProgress()
  }
}

// 保存学习记录到localStorage
const saveLearningProgress = () => {
  const data = {
    learnedNodes: learnedNodes.value,
    totalStudyTime: totalStudyTime.value,
    timestamp: new Date().toISOString()
  }
  localStorage.setItem('knowledgeGraphProgress', JSON.stringify(data))
}

// 从后端API获取知识图谱数据
const fetchKnowledgeGraph = async () => {
  loading.value = true
  error.value = null
  
  try {
    // 获取图谱数据
    const response = await axios.get('http://localhost:5000/api/knowledge/graph')
    const data = response.data
    
    console.log('API response data:', {
      nodesCount: data.nodes?.length || 0,
      linksCount: data.links?.length || 0,
      hasNodeDetails: !!data.nodeDetails
    })
    
    // 过滤出有关系的节点
    const nodeIdsWithRelations = new Set()
    data.links?.forEach(link => {
      nodeIdsWithRelations.add(link.source)
      nodeIdsWithRelations.add(link.target)
    })
    
    // 只保留有关系的节点
    const filteredNodes = data.nodes?.filter(node => nodeIdsWithRelations.has(node.id)) || []
    
    console.log('Filtered nodes:', filteredNodes.length)
    
    // 更新图谱数据
    knowledgeGraphData.value = {
      nodes: filteredNodes,
      links: data.links || []
    }
    
    // 更新节点详情
    nodeDetails.value = data.nodeDetails || {}
    
    console.log('Knowledge graph data loaded successfully')
    
    // 数据加载成功后更新学习进度
    updateProgress()
    
    // 绘制知识图谱
    await nextTick()
    drawGraph()
  } catch (err) {
    console.error('Error fetching knowledge graph:', err)
    error.value = '加载知识图谱失败，请稍后重试'
  } finally {
    loading.value = false
  }
}



// 初始化 ECharts
const initChart = () => {
  if (!graphChart.value) return
  
  // 动态加载 ECharts
  if (typeof window.echarts === 'undefined') {
    // 加载 ECharts 脚本
    const script = document.createElement('script')
    script.src = 'https://cdn.jsdelivr.net/npm/echarts@5.4.3/dist/echarts.min.js'
    script.onload = () => {
      createChart()
    }
    document.head.appendChild(script)
  } else {
    createChart()
  }
}

// 创建 ECharts 实例
const createChart = () => {
  if (!graphChart.value) return
  
  // 销毁已存在的实例
  if (chart) {
    chart.dispose()
  }
  
  // 创建新实例
  chart = window.echarts.init(graphChart.value)
  
  // 监听窗口大小变化
  window.addEventListener('resize', handleResize)
}

// 绘制知识图谱
const drawGraph = () => {
  if (!chart) return
  if (loading.value || error.value) return

  const nodes = knowledgeGraphData.value.nodes
  const links = knowledgeGraphData.value.links

  // 准备 ECharts 数据
  const echartsNodes = nodes.map(node => ({
    id: node.id,
    name: node.name,
    symbolSize: node.size || 30,
    value: node.size || 30,
    category: node.category,
    itemStyle: {
      color: node.color || '#244d4d',
      opacity: 0.8
    }
  }))

  const echartsLinks = links.map(link => ({
    source: link.source,
    target: link.target,
    lineStyle: {
      color: '#ddd',
      width: 2,
      opacity: 0.7
    }
  }))

  // 准备类别数据
  const categories = Array.from(new Set(nodes.map(node => node.category))).map(category => ({
    name: category
  }))

  // 图表配置
  const option = {
    title: {
      text: '湘绣知识图谱',
      subtext: '基于关系网络的知识可视化',
      top: 'top',
      left: 'center'
    },
    tooltip: {
      trigger: 'item',
      formatter: function(params) {
        if (params.dataType === 'node') {
          const nodeDetail = nodeDetails.value[params.data.id]
          if (nodeDetail) {
            return `
              <div style="font-weight:bold;margin-bottom:5px;">${params.data.name}</div>
              <div>类别: ${nodeDetail.category}</div>
              <div>描述: ${nodeDetail.description}</div>
            `
          } else {
            return `
              <div style="font-weight:bold;margin-bottom:5px;">${params.data.name}</div>
              <div>类别: ${params.data.category}</div>
            `
          }
        }
        return ''
      }
    },

    animationDurationUpdate: 1500,
    animationEasingUpdate: 'quinticInOut',
    series: [
      {
        type: 'graph',
        layout: 'force', // 力导向布局
        data: echartsNodes,
        links: echartsLinks,
        categories: categories,
        roam: true, // 开启缩放和平移
        label: {
          show: true,
          position: 'inside',
          formatter: '{b}',
          fontSize: 12,
          color: '#000',
          overflow: 'break',
          rich: {
            name: {
              fontSize: 12,
              fontWeight: 'bold'
            }
          }
        },
        force: {
          repulsion: 700, // 排斥力
          gravity: 0.2, // 引力
          edgeLength: [5, 10], // 边长度范围
          layoutAnimation: true
        },
        lineStyle: {
          color: 'source',
          curveness: 0.3
        },
        emphasis: {
          focus: 'adjacency',
          lineStyle: {
            width: 4
          }
        }
      }
    ]
  }

  // 设置配置
  chart.setOption(option)
}

// 处理节点点击
const handleNodeClick = (node) => {
  selectedNode.value = { ...node, ...nodeDetails.value[node.id] }
}

// 学习节点
const learnNode = (node) => {
  if (!learnedNodes.value.includes(node.id)) {
    learnedNodes.value.push(node.id)
    totalStudyTime.value += 5 // 假设每个节点学习5分钟
    updateProgress()
    saveLearningProgress() // 保存学习记录
    console.log(`已学习节点: ${node.name}`)
  }
}

// 取消学习节点
const unlearnNode = (node) => {
  const index = learnedNodes.value.indexOf(node.id)
  if (index > -1) {
    learnedNodes.value.splice(index, 1)
    totalStudyTime.value -= 5
    updateProgress()
    saveLearningProgress() // 保存学习记录
    console.log(`已取消学习节点: ${node.name}`)
  }
}

// 更新学习进度
const updateProgress = () => {
  const totalNodes = knowledgeGraphData.value.nodes.length
  if (totalNodes > 0) {
    progress.value = Math.round((learnedNodes.value.length / totalNodes) * 100)
  }
}

// 滚动到顶部
const scrollToTop = () => {
  window.scrollTo({
    top: 0,
    behavior: 'smooth'
  })
}

// 清除选中状态
const clearSelection = () => {
  selectedNode.value = null
}

// 高亮相关节点
const highlightRelated = (relatedName) => {
  const relatedNode = knowledgeGraphData.value.nodes.find(n => n.name === relatedName)
  if (relatedNode) {
    handleNodeClick(relatedNode)
  }
}

// 搜索功能
const handleSearch = () => {
  if (!searchTerm.value.trim()) return
  
  const searchLower = searchTerm.value.toLowerCase().trim()
  const foundNode = knowledgeGraphData.value.nodes.find(n => 
    n.name.toLowerCase().includes(searchLower) || 
    (nodeDetails.value[n.id] && nodeDetails.value[n.id].description.toLowerCase().includes(searchLower))
  )
  
  if (foundNode) {
    handleNodeClick(foundNode)
    // 高亮显示找到的节点
    if (chart) {
      chart.dispatchAction({
        type: 'showTip',
        seriesIndex: 0,
        dataIndex: knowledgeGraphData.value.nodes.indexOf(foundNode)
      })
    }
  }
}



// 缩放控制
const zoomIn = () => {
  if (chart) {
    chart.dispatchAction({
      type: 'dataZoom',
      start: 0,
      end: 80
    })
  }
}

const zoomOut = () => {
  if (chart) {
    chart.dispatchAction({
      type: 'dataZoom',
      start: 0,
      end: 100
    })
  }
}

const resetView = () => {
  if (chart) {
    chart.dispatchAction({
      type: 'restore'
    })
    drawGraph()
  }
}

// 处理窗口大小变化
const handleResize = () => {
  if (chart) {
    chart.resize()
  }
}

// 打开添加节点模态框
const openAddNodeModal = () => {
  showAddNodeModal.value = true
  addNodeSuccess.value = false
}

// 关闭添加节点模态框
const closeAddNodeModal = () => {
  showAddNodeModal.value = false
  // 重置表单
  newNode.value = {
    category: '',
    content: '',
    name: ''
  }
}

// 提交添加节点
const submitAddNode = async () => {
  if (!newNode.value.category || !newNode.value.content) {
    alert('请填写类别和内容')
    return
  }
  
  try {
    // 构建节点数据
    const nodeData = {
      category: newNode.value.category,
      content: newNode.value.name ? `${newNode.value.name}：${newNode.value.content}` : newNode.value.content
    }
    
    // 调用API添加节点
    await axios.post('http://localhost:5000/api/knowledge/nodes', nodeData)
    
    // 重新获取图谱数据
    await fetchKnowledgeGraph()
    
    // 显示成功提示
    addNodeSuccess.value = true
    
    // 3秒后关闭模态框
    setTimeout(() => {
      closeAddNodeModal()
    }, 3000)
  } catch (error) {
    console.error('添加节点失败:', error)
    alert('添加节点失败，请重试')
  }
}

// 组件挂载时执行
onMounted(async () => {
  // 加载学习记录
  loadLearningProgress()
  
  // 从后端API获取知识图谱数据
  await fetchKnowledgeGraph()
  
  // 数据加载完成后再初始化 ECharts
  initChart()
})

// 组件卸载时清理
onUnmounted(() => {
  if (chart) {
    chart.dispose()
  }
  window.removeEventListener('resize', handleResize)
})
</script>

<style scoped>
/* CSS变量定义 */
:root {
  --primary-color: #244d4d;
  --primary-light: #3a6e6e;
  --secondary-color: #333;
  --danger-color: #e74c3c;
  --danger-light: #c0392b;
  --warning-color: #f39c12;
  --success-color: #2ecc71;
  --background-color: #f9f9f9;
  --white: #fff;
  --border-color: #e0e0e0;
  --text-color: #333;
  --text-secondary: #666;
  --box-shadow: 0 2px 10px rgba(0, 0, 0, 0.08);
  --transition: all 0.3s ease;
}

/* 知识图谱容器样式 */
.knowledge-graph-container {
  max-width: 1200px;
  margin: 0 auto;
  margin-top: 100px; /* 为固定的导航栏留出空间 */
  min-height: 100vh;
  background-color: var(--background-color);
}

/* 页面头部样式 */
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

/* 主要内容区域 */
.graph-content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 3rem 2rem;
}

/* 控制区域 */
.control-panel {
  background-color: #fff;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: var(--box-shadow);
  margin-bottom: 2rem;
}

.search-section {
  display: flex;
  gap: 1rem;
  margin-bottom: 1.5rem;
}

.search-input {
  flex: 1;
  padding: 1rem 1.5rem;
  border: 1px solid var(--border-color);
  border-radius: 4px;
  font-size: 1.6rem;
  transition: border-color 0.3s ease;
}

.search-input:focus {
  outline: none;
  border-color: var(--primary-color);
}

.search-btn {
  padding: 1rem 2rem;
  background-color: var(--primary-color);
  color: white;
  border: none;
  border-radius: 4px;
  font-size: 1.6rem;
  cursor: pointer;
  transition: background-color 0.3s ease;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.search-btn:hover {
  background-color: var(--primary-light);
}

.category-filter {
  margin-bottom: 1.5rem;
}

.category-filter label {
  font-size: 1.6rem;
  color: var(--text-color);
  margin-right: 1rem;
}

.category-filter select {
  padding: 0.8rem 1.2rem;
  border: 1px solid var(--border-color);
  border-radius: 4px;
  font-size: 1.6rem;
  background-color: #fff;
  cursor: pointer;
}

.graph-controls {
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
}

.control-btn {
  padding: 0.8rem 1.5rem;
  background-color: #f1f1f1;
  color: var(--text-color);
  border: 1px solid var(--border-color);
  border-radius: 4px;
  font-size: 1.5rem;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.control-btn:hover {
  background-color: var(--primary-light);
  color: white;
  border-color: var(--primary-color);
}

/* 知识图谱展示区域 */
.graph-display {
  position: relative;
  background-color: #fff;
  border-radius: 8px;
  box-shadow: var(--box-shadow);
  height: 600px;
  margin-bottom: 2rem;
  overflow: hidden;
}

.loading-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(255, 255, 255, 0.8);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  z-index: 10;
}

.loading-spinner {
  width: 50px;
  height: 50px;
  border: 5px solid #f3f3f3;
  border-top: 5px solid var(--primary-color);
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 1rem;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.error-message {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  text-align: center;
  color: var(--danger-color);
  z-index: 10;
}

.retry-btn {
  margin-top: 1rem;
  padding: 0.8rem 1.5rem;
  background-color: var(--primary-color);
  color: white;
  border: none;
  border-radius: 4px;
  font-size: 1.5rem;
  cursor: pointer;
  transition: background-color 0.3s ease;
}

.retry-btn:hover {
  background-color: var(--primary-light);
}

.graph-chart {
  width: 100%;
  height: 100%;
}

/* 图例样式 */
.graph-legend {
  position: absolute;
  top: 20px;
  right: 20px;
  background-color: rgba(255, 255, 255, 0.95);
  border: 1px solid var(--border-color);
  border-radius: 8px;
  padding: 1.5rem;
  z-index: 10;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.graph-legend h4 {
  margin-top: 0;
  margin-bottom: 1rem;
  font-size: 1.6rem;
  color: var(--primary-color);
}

/* 信息卡片区域样式 */
.info-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 2rem;
  margin: 2rem 0;
}

.info-card {
  background-color: #fff;
  border-radius: 8px;
  box-shadow: var(--box-shadow);
  padding: 2rem;
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.info-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.12);
}

.card-icon {
  width: 60px;
  height: 60px;
  background-color: var(--primary-light);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 1.5rem;
  color: white;
  font-size: 1.8rem;
}

.card-content h4 {
  font-size: 1.6rem;
  color: var(--primary-color);
  margin-bottom: 1rem;
}

.card-content p {
  font-size: 1.4rem;
  color: var(--text-secondary);
  line-height: 1.6;
}

/* 学习进度区域样式 */
.progress-container {
  background-color: #fff;
  border-radius: 8px;
  box-shadow: var(--box-shadow);
  padding: 2rem;
  margin: 2rem 0;
}

.progress-container h4 {
  font-size: 1.6rem;
  color: var(--primary-color);
  margin-bottom: 1.5rem;
}

.progress-bar {
  width: 100%;
  height: 12px;
  background-color: #f0f0f0;
  border-radius: 6px;
  overflow: hidden;
  margin-bottom: 1rem;
}

.progress {
  height: 100%;
  background-color: var(--primary-color);
  border-radius: 6px;
  transition: width 0.5s ease;
}

.progress-container p {
  font-size: 1.4rem;
  color: var(--text-secondary);
  margin-bottom: 1.5rem;
}

.progress-stats {
  display: flex;
  justify-content: space-around;
  margin-bottom: 2rem;
}

.stat-item {
  text-align: center;
}

.stat-label {
  display: block;
  font-size: 1.2rem;
  color: var(--text-secondary);
  margin-bottom: 0.5rem;
}

.stat-value {
  display: block;
  font-size: 1.8rem;
  font-weight: bold;
  color: var(--primary-color);
}

.continue-btn {
  width: 100%;
  padding: 1rem;
  background-color: var(--primary-color);
  color: white;
  border: none;
  border-radius: 4px;
  font-size: 1.4rem;
  cursor: pointer;
  transition: background-color 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
}

.continue-btn:hover {
  background-color: var(--primary-light);
}

/* 知识图谱简介样式 */
.graph-intro {
  background-color: #fff;
  border-radius: 8px;
  box-shadow: var(--box-shadow);
  padding: 2rem;
  margin: 2rem 0;
}

.graph-intro h3 {
  font-size: 1.8rem;
  color: var(--primary-color);
  margin-bottom: 1.5rem;
}

.graph-intro p {
  font-size: 1.4rem;
  color: var(--text-secondary);
  line-height: 1.6;
}
</style>
