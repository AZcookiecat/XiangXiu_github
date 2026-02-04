<template>
  <div class="cart-container">
    <section class="heading">
      <h3>购物车</h3>
      <p> <router-link to="/">首页</router-link> / <router-link to="/shop">商城</router-link> / <span>购物车</span> </p>
    </section>

    <div v-if="cartItems.length > 0" class="cart-content">
      <div class="cart-items">
        <div class="cart-header">
          <div class="header-item">
            <input type="checkbox" v-model="selectAll" @change="toggleSelectAll" class="select-all-checkbox">
            <span>全选</span>
          </div>
          <div class="header-item">商品名称</div>
          <div class="header-item">单价</div>
          <div class="header-item">数量</div>
          <div class="header-item">小计</div>
          <div class="header-item">操作</div>
        </div>
        
        <div v-for="item in cartItems" :key="item.id" class="cart-item">
          <div class="cart-item-row">
            <div class="cart-item-cell select-cell">
              <input type="checkbox" v-model="item.selected" @change="updateTotal" class="item-checkbox">
            </div>
            <div class="cart-item-cell product-info-cell">
              <img :src="item.image_url" :alt="item.name" loading="lazy" class="cart-item-image">
              <div class="product-details">
                <span class="cart-item-name">{{ item.name }}</span>
              </div>
            </div>
            <div class="cart-item-cell price-cell">￥{{ item.price }}</div>
            <div class="cart-item-cell quantity-cell">
              <div class="quantity-controls">
                <button @click="decreaseQuantity(item)" :disabled="item.quantity <= 1" class="quantity-btn minus-btn">-</button>
                <input type="number" v-model="item.quantity" min="1" @change="updateTotal" class="quantity-input">
                <button @click="increaseQuantity(item)" class="quantity-btn plus-btn">+</button>
              </div>
            </div>
            <div class="cart-item-cell subtotal-cell" v-if="item.selected">
              <span class="subtotal-price">￥{{ item.price * item.quantity }}</span>
            </div>
            <div class="cart-item-cell subtotal-cell" v-else>￥0</div>
            <div class="cart-item-cell action-cell">
              <button @click="removeFromCart(item.id)" class="remove-btn" title="删除商品">
                <i class="fas fa-times"></i>
              </button>
            </div>
          </div>
          

        </div>
      </div>
      
      <div class="cart-summary">
        <div class="summary-top">
          <div class="continue-shopping">
            <a href="/shop" class="continue-shopping-link">继续购物</a>
            <span class="selected-info">| 共{{ cartItems.length }}件, 已选择了{{ selectedCount }}件</span>
          </div>
          <div class="total-amount">
            <span>合计:</span>
            <span class="total-price">￥{{ totalAmount }}</span>
          </div>
        </div>
        
        <div class="summary-actions">
          <button @click="checkout" class="checkout-btn" :disabled="selectedCount === 0">
            去结算
          </button>
        </div>
      </div>
    </div>
    
    <div v-else class="empty-cart">
      <div class="empty-cart-icon">
        <i class="fas fa-shopping-cart"></i>
      </div>
      <p>购物车还是空的，快去挑选心仪的商品吧！</p>
      <router-link to="/shop" class="go-shop-btn">
        <i class="fas fa-store"></i> 去商城
      </router-link>
    
      <!-- 推荐商品 -->
      <div class="recommended-products" v-if="recommendedProducts.length > 0">
        <h4>为您推荐</h4>
        <div class="product-grid">
          <div v-for="product in recommendedProducts" :key="product.id" class="recommended-product">
            <img :src="product.image_url" :alt="product.name" loading="lazy" class="product-image">
            <div class="product-info">
              <h5>{{ product.name }}</h5>
              <p class="product-price">￥{{ product.price }}</p>
              <button @click="addRecommendedToCart(product)" class="add-to-cart-btn">
                <i class="fas fa-plus"></i> 加入购物车
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch, inject } from 'vue'
import { useRouter } from 'vue-router'

const flash = inject('flash')

const router = useRouter()
// 修改store的获取方式
const store = inject('store')

// 状态管理
const cartItems = ref([])
const selectAll = ref(false)
const recommendedProducts = ref([])

// 计算属性
const isLoggedIn = computed(() => store.isAuthenticated())
const selectedCount = computed(() => {
  return cartItems.value.filter(item => item.selected).length
})
const totalAmount = computed(() => {
  return cartItems.value
    .filter(item => item.selected)
    .reduce((total, item) => total + (item.price * item.quantity), 0)
})

// 方法
const updateCartItems = () => {
  // 正确调用store中的方法
  const items = store.getCartItems()
  // 为每个商品添加selected属性（如果不存在）
  cartItems.value = items.map(item => ({
    ...item,
    selected: item.selected !== undefined ? item.selected : true
  }))
}

const toggleSelectAll = () => {
  cartItems.value.forEach(item => {
    item.selected = selectAll.value
  })
  updateTotal()
}

const updateTotal = () => {
  // 确保购物车数据更新到store
  store.saveCart()
  
  // 检查是否所有商品都被选中
  const allSelected = cartItems.value.every(item => item.selected)
  const hasItems = cartItems.value.length > 0
  selectAll.value = allSelected && hasItems
}

const decreaseQuantity = (item) => {
  if (item.quantity > 1) {
    item.quantity--
    updateTotal()
  }
}

const increaseQuantity = (item) => {
  item.quantity++
  updateTotal()
}

const removeFromCart = (itemId) => {
  store.removeFromCart(itemId)
  updateCartItems()
  flash && flash('商品已从购物车移除!')
}

const clearSelectedItems = () => {
  const selectedIds = cartItems.value
    .filter(item => item.selected)
    .map(item => item.id)
  
  selectedIds.forEach(id => store.removeFromCart(id))
  updateCartItems()
  flash && flash('已清空选中的商品!')
}

const checkout = () => {
  if (selectedCount.value === 0) {
    flash && flash('请选择要结算的商品!')
    return
  }
  
  // 检查是否登录
  if (!isLoggedIn.value) {
    router.push({ name: 'login', query: { redirect: '/cart' } })
    return
  }
  
  // 模拟结算功能
  flash && flash('即将前往结算页面!')
  // 在实际应用中，这里会跳转到结算页面
  // router.push('/checkout')
}

// 添加推荐商品到购物车
const addRecommendedToCart = (product) => {
  store.addToCart(product)
  updateCartItems()
  flash && flash('商品已添加到购物车!')
}

// 加载模拟推荐数据
const loadRecommendedProducts = () => {
  recommendedProducts.value = [
    {
      id: 101,
      name: '绣艺精品 - 山水图',
      price: 299.99,
      image_url: '/static/pictures/product1.jpg' || 'https://picsum.photos/seed/product101/300/300',
      description: '精美的传统刺绣工艺品，展现中国山水画的趣味'
    },
    {
      id: 102,
      name: '绣艺小物 - 手帕礼盒',
      price: 89.99,
      image_url: '/static/pictures/product2.jpg' || 'https://picsum.photos/seed/product102/300/300',
      description: '精致的刺绣手帕，适合送礼或自用'
    },
    {
      id: 103,
      name: '绣艺摆件 - 花开富贵',
      price: 199.99,
      image_url: '/static/pictures/product3.jpg' || 'https://picsum.photos/seed/product103/300/300',
      description: '刺绣装饰摆件，增添家居艺术氛围'
    }
  ]
}

// 初始化购物车数据
onMounted(() => {
  updateCartItems()
  loadRecommendedProducts()
  
  // 检查是否所有商品都被选中
  const hasItems = cartItems.value.length > 0
  const allSelected = hasItems && cartItems.value.every(item => item.selected)
  selectAll.value = allSelected
})

// 监听购物车数据变化
watch(cartItems, () => {
  updateTotal()
}, { deep: true })
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

/* 购物车容器样式 - 符合project项目设计 */
.cart-container {
  max-width: 1200px;
  margin: 0 auto;
  margin-top: 100px; /* 为固定的导航栏留出空间 */
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

.heading::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, rgba(255,255,255,0.05) 0%, rgba(255,255,255,0) 100%);
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

/* 购物车内容区域 */
.cart-content {
  display: flex;
  flex-direction: column;
  gap: 3rem;
  padding: 4rem 9%;
  background-color: #fff;
  box-shadow: var(--box-shadow);
  margin-top: 30px;
  border-radius: 8px;
  animation: fadeIn 0.5s ease-in-out;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.cart-items {
  flex: 1;
}

/* 购物车头部 */
.cart-header {
  display: grid;
  grid-template-columns: 1fr 3fr 1.3fr 1.3fr 1.1fr 0.8fr;
  gap: 1rem;
  padding: 1.5rem;
  background-color: var(--primary-light);
  color: #fff;
  font-weight: bold;
  font-size: 1.6rem;
  border-radius: 0.8rem 0.8rem 0 0;
}

.header-item {
  display: flex;
  align-items: center;
  gap: 0.8rem;
}

/* 购物车商品行 */
.cart-item {
  background-color: #fff;
  border: 1px solid #eee;
  border-radius: 0.8rem;
  margin-bottom: 1.5rem;
  overflow: hidden;
  transition: all 0.3s ease;
}

.cart-item:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  transform: translateY(-2px);
}

.cart-item-row {
  display: grid;
  grid-template-columns: 1fr 2fr 1fr 1fr 1fr 1fr;
  gap: 1rem;
  padding: 1.5rem;
  align-items: center;
}

/* 单元格样式 */
.cart-item-cell {
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.6rem;
  height: 80px;
}

.select-cell {
  justify-content: flex-start;
}

.product-info-cell {
  justify-content: flex-start;
  gap: 1.5rem;
  align-items: center;
}

.cart-item-image {
  width: 80px;
  height: 80px;
  object-fit: cover;
  border-radius: 0.5rem;
  border: 2px solid #f0f0f0;
  transition: all 0.3s ease;
}

.cart-item-image:hover {
  transform: scale(1.05);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.product-details {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.cart-item-name {
  font-size: 1.6rem;
  font-weight: 500;
  color: var(--text-color);
  max-width: 200px;
  line-height: 1.4;
  display: flex;
  align-items: center;
  height: 100%;
}

.cart-item-desc {
  font-size: 1.4rem;
  color: var(--text-secondary);
}

.price-cell {
  color: var(--primary-color);
  font-weight: bold;
  font-size: 1.7rem;
}

/* 数量控制 */
.quantity-controls {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.quantity-btn {
  width: 3.5rem;
  height: 3.5rem;
  background-color: var(--primary-light);
  border: 1px solid var(--primary-color);
  color: var(--primary-color);
  font-size: 1.8rem;
  font-weight: bold;
  border-radius: 0.5rem;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.quantity-btn:hover:not(:disabled) {
  background-color: var(--primary-color);
  color: #fff;
  transform: scale(1.1);
  box-shadow: 0 2px 8px rgba(36, 77, 77, 0.3);
}

.quantity-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  background-color: #f1f1f1;
  border-color: #ddd;
  color: #999;
}

.quantity-input {
  width: 7rem;
  height: 3.5rem;
  text-align: center;
  border: 1px solid var(--primary-light);
  border-radius: 0.5rem;
  font-size: 1.6rem;
  padding: 0 0.5rem;
  transition: all 0.3s ease;
}

.quantity-input:focus {
  border-color: var(--primary-color);
  box-shadow: 0 0 0 0.2rem rgba(36, 77, 77, 0.1);
  outline: none;
}

/* 小计样式 */
.subtotal-cell {
  color: var(--primary-color);
  font-weight: bold;
  font-size: 1.7rem;
}

.subtotal-price {
  display: block;
}

/* 删除按钮样式 */
.action-cell {
  justify-content: center;
}

.remove-btn {
  background-color: #dc3545;
  color: #fff;
  border: none;
  width: 3.5rem;
  height: 3.5rem;
  border-radius: 50%;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.6rem;
}

.remove-btn:hover {
  background-color: #c82333;
  transform: scale(1.1);
  box-shadow: 0 4px 12px rgba(220, 53, 69, 0.4);
}

/* 可选服务项 */
.cart-item-services {
  padding: 1.5rem;
  background-color: #f9f9f9;
  border-top: 1px solid #eee;
  display: flex;
  gap: 2rem;
  flex-wrap: wrap;
}

.service-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 1.4rem;
  color: var(--text-secondary);
}

.service-item i {
  color: var(--success-color);
  font-size: 1.6rem;
}

/* 购物车摘要 */
.cart-summary {
  background-color: #fff;
  border: 1px solid var(--primary-light);
  padding: 3rem;
  border-radius: 0.8rem;
  text-align: right;
  box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.05);
  position: relative;
  overflow: hidden;
}

.cart-summary::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 4px;
  background: linear-gradient(90deg, var(--primary-color), var(--primary-light));
}

.summary-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
  padding-bottom: 2rem;
  border-bottom: 1px solid #eee;
}

.continue-shopping {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.continue-shopping-link {
  color: var(--primary-color);
  font-size: 1.6rem;
  text-decoration: none;
  font-weight: 500;
  transition: all 0.3s ease;
}

.continue-shopping-link:hover {
  color: var(--primary-light);
  text-decoration: underline;
}

.selected-info {
  font-size: 1.4rem;
  color: var(--text-secondary);
}

.total-amount {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.total-amount span:first-child {
  font-size: 1.8rem;
  color: var(--text-color);
  font-weight: 500;
}

.total-price {
  font-size: 2.5rem;
  color: var(--primary-color);
  font-weight: bold;
}

.summary-actions {
  text-align: right;
}

.checkout-btn {
  background-color: var(--primary-color);
  color: #fff;
  border: none;
  padding: 1.2rem 3rem;
  font-size: 1.8rem;
  font-weight: 600;
  border-radius: 0.5rem;
  cursor: pointer;
  transition: all 0.3s ease;
  text-transform: uppercase;
  letter-spacing: 0.1rem;
  min-width: 200px;
}

.checkout-btn:hover:not(:disabled) {
  background-color: var(--primary-light);
  transform: translateY(-3px);
  box-shadow: 0 8px 20px rgba(36, 77, 77, 0.3);
}

.checkout-btn:disabled {
  background-color: #ccc;
  cursor: not-allowed;
  transform: none;
  box-shadow: none;
}

/* 复选框样式 */
.select-all-checkbox,
.item-checkbox {
  width: 2rem;
  height: 2rem;
  cursor: pointer;
  accent-color: var(--primary-color);
  transition: transform 0.2s ease;
}

.select-all-checkbox:hover,
.item-checkbox:hover {
  transform: scale(1.1);
}

/* 空购物车状态 */
.empty-cart {
  text-align: center;
  padding: 8rem 4rem;
  background-color: #fff;
  border-radius: 0.8rem;
  box-shadow: var(--box-shadow);
  margin-top: 30px;
}

.empty-cart .empty-cart-icon {
  font-size: 8rem;
  color: #e0e0e0;
  margin-bottom: 2rem;
  animation: float 3s ease-in-out infinite;
}

@keyframes float {
  0% {
    transform: translateY(0px);
  }
  50% {
    transform: translateY(-15px);
  }
  100% {
    transform: translateY(0px);
  }
}

.empty-cart p {
  font-size: 2rem;
  color: var(--secondary-color);
  margin-bottom: 3rem;
  line-height: 1.6;
}

.empty-cart .go-shop-btn {
  background-color: var(--primary-color);
  color: white;
  text-decoration: none;
  padding: 1.2rem 3rem;
  font-size: 1.8rem;
  border-radius: 0.5rem;
  transition: all 0.3s ease;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.1rem;
  display: inline-flex;
  align-items: center;
  gap: 0.8rem;
  min-width: 180px;
  justify-content: center;
}

.empty-cart .go-shop-btn:hover {
  background-color: var(--primary-light);
  transform: translateY(-3px);
  box-shadow: 0 8px 20px rgba(36, 77, 77, 0.3);
}

/* 推荐商品样式 */
.recommended-products {
  margin-top: 50px;
  padding-top: 30px;
  border-top: 1px solid var(--border-color);
}

.recommended-products h4 {
  font-size: 2rem;
  color: var(--primary-color);
  margin-bottom: 2rem;
  position: relative;
  display: inline-block;
}

.recommended-products h4::after {
  content: '';
  position: absolute;
  bottom: -8px;
  left: 0;
  width: 100%;
  height: 3px;
  background-color: var(--primary-light);
  border-radius: 3px;
}

.product-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 2rem;
}

.recommended-product {
  background-color: #fff;
  border-radius: 0.8rem;
  overflow: hidden;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
  transition: all 0.3s ease;
  border: 1px solid #f0f0f0;
}

.recommended-product:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
}

.recommended-product .product-image {
  width: 100%;
  height: 220px;
  object-fit: cover;
  transition: transform 0.5s ease;
}

.recommended-product:hover .product-image {
  transform: scale(1.05);
}

.recommended-product .product-info {
  padding: 1.5rem;
  text-align: left;
}

.recommended-product .product-info h5 {
  font-size: 1.6rem;
  color: var(--text-color);
  margin-bottom: 1rem;
  font-weight: 600;
  line-height: 1.4;
}

.recommended-product .product-info .product-price {
  font-size: 1.8rem;
  color: var(--primary-color);
  font-weight: bold;
  margin-bottom: 1.5rem;
}

.recommended-product .product-info .add-to-cart-btn {
  background-color: var(--primary-light);
  color: white;
  border: none;
  padding: 0.8rem 1.6rem;
  cursor: pointer;
  border-radius: 0.5rem;
  transition: all 0.3s ease;
  font-size: 1.5rem;
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  width: 100%;
  justify-content: center;
}

.recommended-product .product-info .add-to-cart-btn:hover {
  background-color: var(--primary-color);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(36, 77, 77, 0.3);
}

/* 响应式设计 - 大屏幕 */
@media (max-width: 1200px) {
  .cart-content {
    padding: 3rem 5%;
  }
  
  .heading {
    padding: 2rem 5%;
  }
  
  .cart-container {
    margin-left: 2%;
    margin-right: 2%;
  }
}

/* 响应式设计 - 平板 */
@media (max-width: 991px) {
  .cart-header {
    grid-template-columns: 1fr 2fr 1fr 1fr 1fr 1fr;
    gap: 0.5rem;
    padding: 1.2rem;
    font-size: 1.5rem;
  }
  
  .cart-item-row {
    grid-template-columns: 1fr 2fr 1fr 1fr 1fr 1fr;
    gap: 0.5rem;
    padding: 1.2rem;
  }
  
  .cart-item-name {
    max-width: 180px;
  }
  
  .product-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

/* 响应式设计 - 手机 */
@media (max-width: 768px) {
  .heading h3 {
    font-size: 2.4rem;
  }
  
  .heading p {
    font-size: 1.6rem;
  }
  
  .cart-content {
    padding: 2rem;
    gap: 2rem;
  }
  
  .cart-header {
    display: none;
  }
  
  .cart-item-row {
    grid-template-columns: 1fr;
    gap: 1rem;
    padding: 1.5rem;
  }
  
  .product-info-cell {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.8rem;
  }
  
  .cart-item-image {
    width: 60px;
    height: 60px;
  }
  
  .cart-item-name {
    max-width: 150px;
    white-space: normal;
  }
  
  .cart-summary {
    padding: 2rem;
  }
  
  .summary-top {
    flex-direction: column;
    gap: 1rem;
    align-items: flex-start;
  }
  
  .total-price {
    font-size: 2.2rem;
  }
  
  .checkout-btn {
    width: 100%;
  }
  
  .product-grid {
    grid-template-columns: 1fr;
  }
  
  .empty-cart-icon {
    font-size: 6rem !important;
  }
}

/* 响应式设计 - 小手机 */
@media (max-width: 450px) {
  .heading h3 {
    font-size: 2rem;
  }
  
  .heading p {
    font-size: 1.4rem;
  }
  
  .cart-content {
    padding: 1.5rem;
  }
  
  .cart-item-row {
    padding: 1rem;
  }
  
  .cart-item-image {
    width: 50px;
    height: 50px;
  }
  
  .cart-summary {
    padding: 1.5rem;
  }
  
  .total-price {
    font-size: 2rem;
  }
  
  .checkout-btn {
    padding: 0.8rem 1.5rem;
    font-size: 1.5rem;
  }
  
  .empty-cart {
    padding: 6rem 2rem;
  }
  
  .empty-cart p {
    font-size: 1.8rem;
  }
  
  .empty-cart-icon {
    font-size: 5rem !important;
  }
}

/* 滚动条样式优化 */
.cart-items::-webkit-scrollbar {
  height: 6px;
}

.cart-items::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 3px;
}

.cart-items::-webkit-scrollbar-thumb {
  background: var(--primary-light);
  border-radius: 3px;
}

.cart-items::-webkit-scrollbar-thumb:hover {
  background: var(--primary-color);
}



.cart-table::-webkit-scrollbar-thumb:hover {
    background: var(--primary-color);
  }
</style>