<template>
  <div class="viewer-page">
    <section class="heading">
      <h3>3D模型预览</h3>
      <p>
        <router-link to="/">首页</router-link> /
        <router-link to="/models">3D模型</router-link> /
        <span>{{ model?.name || '预览' }}</span>
      </p>
    </section>

    <div class="viewer-container">
      <div class="viewer-header">
        <h2 class="model-name">{{ model?.name || '加载中...' }}</h2>
        <router-link to="/models" class="btn back-btn">
          <i class="fas fa-arrow-left"></i>
          <span>返回列表</span>
        </router-link>
      </div>

      <div class="viewer-layout">
        <div ref="canvasContainer" class="canvas-container">
          <div v-if="loading" class="loading-overlay">
            <div class="loading-spinner"></div>
            <p>加载3D模型中...</p>
          </div>
          <div v-if="error" class="error-overlay">
            <i class="fas fa-exclamation-triangle"></i>
            <p>{{ error }}</p>
          </div>
        </div>

        <div class="model-sidebar">
          <div class="info-card">
            <h3><i class="fas fa-info-circle"></i> 模型信息</h3>
            <div class="info-item">
              <span class="label">名称：</span>
              <span class="value">{{ model?.name || '-' }}</span>
            </div>
            <div class="info-item">
              <span class="label">分类：</span>
              <span class="value">{{ model?.category || '未分类' }}</span>
            </div>
            <div class="info-item">
              <span class="label">描述：</span>
              <span class="value description">{{ model?.description || '暂无描述' }}</span>
            </div>
            <div class="info-item">
              <span class="label">格式：</span>
              <span class="value format">{{ getFileFormat() }}</span>
            </div>
            <div class="info-item">
              <span class="label">大小：</span>
              <span class="value">{{ formatSize(model?.file_size) }}</span>
            </div>
            <div class="info-item">
              <span class="label">创建时间：</span>
              <span class="value">{{ formatDate(model?.created_at) }}</span>
            </div>
          </div>

          <div class="info-card">
            <h3><i class="fas fa-tags"></i> 标签</h3>
            <div class="tags">
              <span v-for="tag in model?.tags" :key="tag.id" class="tag">{{ tag.name }}</span>
              <span v-if="!model?.tags?.length" class="no-tags">暂无标签</span>
            </div>
          </div>

          <div class="info-card">
            <h3><i class="fas fa-cog"></i> 模型方向调整</h3>
            <div class="orientation-controls">
              <button @click="rotateModel('x', 90)" class="orient-btn">绕X轴+90°</button>
              <button @click="rotateModel('x', -90)" class="orient-btn">绕X轴-90°</button>
              <button @click="rotateModel('y', 90)" class="orient-btn">绕Y轴+90°</button>
              <button @click="rotateModel('y', -90)" class="orient-btn">绕Y轴-90°</button>
              <button @click="rotateModel('z', 90)" class="orient-btn">绕Z轴+90°</button>
              <button @click="rotateModel('z', -90)" class="orient-btn">绕Z轴-90°</button>
              <button @click="resetOrientation" class="orient-btn reset">重置方向</button>
              <button @click="autoOrient" class="orient-btn auto">自动底部朝下</button>
            </div>
          </div>

          <div class="info-card">
            <h3><i class="fas fa-mouse"></i> 操作说明</h3>
            <ul class="controls-help">
              <li><i class="fas fa-hand-rock"></i> 左键拖拽：旋转视角</li>
              <li><i class="fas fa-arrows-alt"></i> Shift+左键拖拽：平移视角</li>
              <li><i class="fas fa-arrows-alt-h"></i> 鼠标中键拖拽：平移视角</li>
              <li><i class="fas fa-search-plus"></i> 滚轮：缩放</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount, markRaw } from 'vue'
import { useRoute } from 'vue-router'
import axios from 'axios'
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader.js'
import { OBJLoader } from 'three/examples/jsm/loaders/OBJLoader.js'
import { FBXLoader } from 'three/examples/jsm/loaders/FBXLoader.js'
import { STLLoader } from 'three/examples/jsm/loaders/STLLoader.js'
import { PLYLoader } from 'three/examples/jsm/loaders/PLYLoader.js'
import { ColladaLoader } from 'three/examples/jsm/loaders/ColladaLoader.js'

const route = useRoute()
const canvasContainer = ref(null)

const model = ref(null)
const loading = ref(true)
const error = ref('')

let scene, camera, renderer, controls, currentModel
let originalRotation = null

const API_BASE_URL = 'http://localhost:5000'

const loadModel = async () => {
  try {
    const response = await axios.get(`${API_BASE_URL}/api/models/${route.params.id}`)
    model.value = response.data
  } catch (err) {
    console.error('加载模型信息失败:', err)
    error.value = '加载模型信息失败'
    loading.value = false
  }
}

const getFileFormat = () => {
  if (!model.value?.file_path) return '-'
  const ext = model.value.file_path.split('.').pop().toUpperCase()
  return ext
}

const formatSize = (bytes) => {
  if (!bytes) return '-'
  const sizes = ['B', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(1024))
  return (bytes / Math.pow(1024, i)).toFixed(2) + ' ' + sizes[i]
}

const formatDate = (date) => {
  if (!date) return '-'
  return new Date(date).toLocaleString('zh-CN')
}

const initThreeJS = () => {
  const container = canvasContainer.value

  scene = new THREE.Scene()
  scene.background = new THREE.Color(0xf5f5f5)

  camera = new THREE.PerspectiveCamera(
    75,
    container.clientWidth / container.clientHeight,
    0.1,
    1000
  )
  camera.position.set(0, 2, 5)

  renderer = new THREE.WebGLRenderer({ antialias: true })
  renderer.setSize(container.clientWidth, container.clientHeight)
  renderer.shadowMap.enabled = true
  container.appendChild(renderer.domElement)

  const ambientLight = new THREE.AmbientLight(0xffffff, 0.6)
  scene.add(ambientLight)

  const directionalLight = new THREE.DirectionalLight(0xffffff, 0.8)
  directionalLight.position.set(10, 10, 5)
  directionalLight.castShadow = true
  scene.add(directionalLight)

  controls = new OrbitControls(camera, renderer.domElement)
  controls.enableDamping = true
  controls.dampingFactor = 0.05
  controls.mouseButtons = {
    LEFT: THREE.MOUSE.ROTATE,
    MIDDLE: THREE.MOUSE.PAN,
    RIGHT: null
  }
  controls.enablePan = true

  const gridHelper = new THREE.GridHelper(10, 10, 0x244d4d, 0xcccccc)
  scene.add(gridHelper)

  loadModelFile()
  animate()

  window.addEventListener('resize', handleResize)
}

const loadModelFile = async () => {
  try {
    const response = await axios.get(`${API_BASE_URL}/api/model-file/${model.value.id}`, {
      responseType: 'blob'
    })
    const blob = new Blob([response.data])
    const url = URL.createObjectURL(blob)

    const fileExt = model.value.file_path.split('.').pop().toLowerCase()

    switch(fileExt) {
      case 'glb':
      case 'gltf':
        await loadGLTF(url)
        break
      case 'obj':
        await loadOBJ(url)
        break
      case 'fbx':
        await loadFBX(url)
        break
      case 'stl':
        await loadSTL(url)
        break
      case 'ply':
        await loadPLY(url)
        break
      case 'dae':
        await loadDAE(url)
        break
      default:
        throw new Error(`不支持的文件格式: ${fileExt}`)
    }

    URL.revokeObjectURL(url)
  } catch (err) {
    console.error('加载模型失败:', err)
    error.value = '模型加载失败: ' + (err.message || '请检查文件是否有效')
    loading.value = false
  }
}

const loadGLTF = (url) => {
  return new Promise((resolve, reject) => {
    const loader = new GLTFLoader()
    loader.load(url, (gltf) => {
      processModel(gltf.scene)
      resolve()
    }, undefined, reject)
  })
}

const loadOBJ = (url) => {
  return new Promise((resolve, reject) => {
    const loader = new OBJLoader()
    loader.load(url, (obj) => {
      processModel(obj)
      resolve()
    }, undefined, reject)
  })
}

const loadFBX = (url) => {
  return new Promise((resolve, reject) => {
    const loader = new FBXLoader()
    loader.load(url, (fbx) => {
      processModel(fbx)
      resolve()
    }, undefined, reject)
  })
}

const loadSTL = (url) => {
  return new Promise((resolve, reject) => {
    const loader = new STLLoader()
    loader.load(url, (geometry) => {
      const material = new THREE.MeshPhongMaterial({ color: 0x888888 })
      const mesh = new THREE.Mesh(geometry, material)
      processModel(mesh)
      resolve()
    }, undefined, reject)
  })
}

const loadPLY = (url) => {
  return new Promise((resolve, reject) => {
    const loader = new PLYLoader()
    loader.load(url, (geometry) => {
      const material = new THREE.MeshPhongMaterial({ color: 0x888888 })
      const mesh = new THREE.Mesh(geometry, material)
      processModel(mesh)
      resolve()
    }, undefined, reject)
  })
}

const loadDAE = (url) => {
  return new Promise((resolve, reject) => {
    const loader = new ColladaLoader()
    loader.load(url, (collada) => {
      processModel(collada.scene)
      resolve()
    }, undefined, reject)
  })
}

const processModel = (modelObj) => {
  currentModel = markRaw(modelObj)

  const box = new THREE.Box3().setFromObject(modelObj)
  const center = box.getCenter(new THREE.Vector3())
  const size = box.getSize(new THREE.Vector3())

  const maxDim = Math.max(size.x, size.y, size.z)
  if (maxDim > 0) {
    const scale = 3 / maxDim
    modelObj.scale.setScalar(scale)
    modelObj.position.sub(center.multiplyScalar(scale))
    modelObj.position.y += size.y * scale / 2
  }

  originalRotation = {
    x: modelObj.rotation.x,
    y: modelObj.rotation.y,
    z: modelObj.rotation.z
  }

  scene.add(modelObj)
  loading.value = false
}

const rotateModel = (axis, degrees) => {
  if (!currentModel) return

  const radians = degrees * (Math.PI / 180)

  switch(axis) {
    case 'x':
      currentModel.rotation.x += radians
      break
    case 'y':
      currentModel.rotation.y += radians
      break
    case 'z':
      currentModel.rotation.z += radians
      break
  }
}

const resetOrientation = () => {
  if (!currentModel || !originalRotation) return

  currentModel.rotation.x = originalRotation.x
  currentModel.rotation.y = originalRotation.y
  currentModel.rotation.z = originalRotation.z
}

const autoOrient = () => {
  if (!currentModel) return

  const box = new THREE.Box3().setFromObject(currentModel)
  const size = box.getSize(new THREE.Vector3())

  const minDim = Math.min(size.x, size.y, size.z)

  if (size.y !== minDim) {
    if (size.x === minDim) {
      currentModel.rotation.z += Math.PI / 2
    } else if (size.z === minDim) {
      currentModel.rotation.x += Math.PI / 2
    }
  }

  const newBox = new THREE.Box3().setFromObject(currentModel)
  const newSize = newBox.getSize(new THREE.Vector3())

  currentModel.position.y = newSize.y / 2
}

const animate = () => {
  requestAnimationFrame(animate)
  if (controls) {
    controls.update()
  }
  if (renderer && scene && camera) {
    renderer.render(scene, camera)
  }
}

const handleResize = () => {
  if (!camera || !renderer || !canvasContainer.value) return
  const container = canvasContainer.value
  camera.aspect = container.clientWidth / container.clientHeight
  camera.updateProjectionMatrix()
  renderer.setSize(container.clientWidth, container.clientHeight)
}

onMounted(async () => {
  await loadModel()
  if (model.value) {
    initThreeJS()
  }
})

onBeforeUnmount(() => {
  if (renderer) {
    renderer.dispose()
    window.removeEventListener('resize', handleResize)
  }
})
</script>

<style scoped>
.viewer-page {
  max-width: 1400px;
  margin: 0 auto;
  margin-top: 100px;
}

.heading {
  background: var(--primary-color);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 2rem 9%;
  margin-bottom: 0;
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

.viewer-container {
  display: flex;
  flex-direction: column;
  height: calc(100vh - 180px);
  background: #f9f9f9;
}

.viewer-header {
  background: #fff;
  padding: 1.5rem 3rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 2px solid var(--primary-color);
}

.model-name {
  color: var(--primary-color);
  font-size: 2.4rem;
  font-weight: 600;
  font-family: 'Noto Serif SC', serif;
}

.back-btn {
  display: inline-flex;
  align-items: center;
  gap: 0.8rem;
  padding: 1rem 2rem;
  background: var(--primary-color);
  color: #fff;
  text-decoration: none;
  border-radius: 25px;
  font-size: 1.6rem;
  transition: all 0.3s ease;
}

.back-btn:hover {
  background: var(--primary-light);
  transform: translateY(-2px);
}

.viewer-layout {
  flex: 1;
  display: flex;
  overflow: hidden;
}

.canvas-container {
  flex: 1;
  position: relative;
  background: linear-gradient(135deg, #f0f0f0, #e0e0e0);
}

.loading-overlay,
.error-overlay {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1.5rem;
  text-align: center;
}

.loading-spinner {
  width: 60px;
  height: 60px;
  border: 4px solid rgba(36, 77, 77, 0.1);
  border-top: 4px solid var(--primary-color);
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.loading-overlay p {
  color: var(--primary-color);
  font-size: 1.8rem;
  font-family: 'Noto Serif SC', serif;
}

.error-overlay {
  color: #e74c3c;
}

.error-overlay i {
  font-size: 5rem;
}

.error-overlay p {
  font-size: 1.6rem;
  max-width: 400px;
}

.model-sidebar {
  width: 350px;
  background: #fff;
  border-left: 2px solid var(--primary-color);
  padding: 2rem;
  overflow-y: auto;
}

.info-card {
  background: #f8f9fa;
  border-radius: 12px;
  padding: 2rem;
  margin-bottom: 2rem;
  border: 1px solid rgba(36, 77, 77, 0.1);
}

.info-card h3 {
  margin-bottom: 1.5rem;
  color: var(--primary-color);
  font-size: 1.8rem;
  font-family: 'Noto Serif SC', serif;
  display: flex;
  align-items: center;
  gap: 0.8rem;
}

.info-item {
  margin-bottom: 1rem;
  display: flex;
  flex-direction: column;
  gap: 0.3rem;
}

.label {
  color: #888;
  font-size: 1.4rem;
}

.value {
  color: #333;
  font-size: 1.5rem;
  font-weight: 500;
}

.value.description {
  line-height: 1.6;
}

.value.format {
  display: inline-block;
  background: var(--primary-color);
  color: #fff;
  padding: 0.3rem 1rem;
  border-radius: 15px;
  font-size: 1.3rem;
  width: fit-content;
}

.tags {
  display: flex;
  flex-wrap: wrap;
  gap: 0.8rem;
}

.tag {
  background: var(--primary-color);
  color: #fff;
  padding: 0.5rem 1.2rem;
  border-radius: 20px;
  font-size: 1.4rem;
}

.no-tags {
  color: #999;
  font-size: 1.4rem;
}

.orientation-controls {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 0.8rem;
}

.orient-btn {
  padding: 1rem;
  border: 2px solid var(--primary-color);
  border-radius: 8px;
  background: #fff;
  color: var(--primary-color);
  font-size: 1.4rem;
  cursor: pointer;
  transition: all 0.3s ease;
  font-family: 'Noto Serif SC', serif;
}

.orient-btn:hover {
  background: var(--primary-color);
  color: #fff;
}

.orient-btn.reset {
  background: #e74c3c;
  color: #fff;
  border-color: #e74c3c;
}

.orient-btn.reset:hover {
  background: #c0392b;
}

.orient-btn.auto {
  background: #27ae60;
  color: #fff;
  border-color: #27ae60;
  grid-column: span 2;
}

.orient-btn.auto:hover {
  background: #219a52;
}

.controls-help {
  list-style: none;
  padding: 0;
}

.controls-help li {
  padding: 1rem 0;
  color: #555;
  font-size: 1.5rem;
  border-bottom: 1px solid #eee;
  display: flex;
  align-items: center;
  gap: 1rem;
}

.controls-help li:last-child {
  border-bottom: none;
}

.controls-help li i {
  color: var(--primary-color);
  width: 24px;
}

@media (max-width: 991px) {
  .viewer-layout {
    flex-direction: column;
  }

  .model-sidebar {
    width: 100%;
    border-left: none;
    border-top: 2px solid var(--primary-color);
    max-height: 400px;
  }

  .viewer-container {
    height: auto;
    min-height: calc(100vh - 180px);
  }

  .canvas-container {
    min-height: 400px;
  }
}

@media (max-width: 768px) {
  .viewer-header {
    flex-direction: column;
    gap: 1rem;
    text-align: center;
  }

  .model-name {
    font-size: 2rem;
  }

  .model-sidebar {
    padding: 1.5rem;
  }

  .orientation-controls {
    grid-template-columns: 1fr;
  }

  .orient-btn.auto {
    grid-column: span 1;
  }
}
</style>
