<template>
  <div class="product-container">
    <section class="heading">
      <h3>产品详情</h3>
      <p> <router-link to="/">首页</router-link> / <router-link to="/shop">商城</router-link> / <span>{{ product?.name || '产品' }}</span> </p>
    </section>

    <div v-if="product" class="product-detail">
      <!-- 图片展示部分 -->
      <div class="image-section">
        <!-- 主图 -->
        <div class="main-image">
          <img :src="product.image_url" :alt="product.name" loading="lazy">
        </div>
        <!-- 缩略图 -->
        <div class="thumbnail-images">
          <div v-for="(img, index) in productImages" :key="index" class="thumbnail">
            <img :src="img" :alt="product.name + index" loading="lazy">
          </div>
        </div>
      </div>
      
      <!-- 商品信息部分 -->
      <div class="product-info">
        <h1 class="product-name">{{ product.name }}</h1>
        
        <div class="price-section">
          <span class="price">￥{{ product.price }}</span>
        </div>
        
        <!-- 评分星星 -->
        <div class="rating">
          <div class="stars">
            <i class="fas fa-star"></i>
            <i class="fas fa-star"></i>
            <i class="fas fa-star"></i>
            <i class="fas fa-star"></i>
            <i class="far fa-star"></i>
          </div>
          <span class="rating-text">4.6 (50)</span>
        </div>
        <!-- 评分星星结束 -->
        
        <div class="description">
          <p>{{ product.description || '这是一个精美的湘绣作品，采用传统工艺精心制作，展现了湘绣的精湛技艺和独特魅力。' }}</p>
        </div>
        
        <div class="action-section">
          <!-- 数量控制 -->
          <div class="quantity">
            <button @click="decreaseQuantity" :disabled="quantity <= 1">-</button>
            <span>{{ quantity }}</span>
            <button @click="increaseQuantity" :disabled="quantity >= product.stock">+</button>
          </div>
          
          <!-- 按钮组 -->
          <div class="buttons">
            <button @click="addToCart(product)" class="buy-now">加入购物车</button>
          </div>
        </div>
        
        <!-- 配送信息 -->
        <div class="delivery-info">
          <p>3-5天免费配送 | 无理由退换货 | 365天质保</p>
        </div>
        
        <!-- 操作按钮 -->
        <div class="action-buttons">
          <button @click="addToCollection(product)" class="favorite-btn">
            <i class="far fa-heart"></i> 加入收藏夹
          </button>
          <div class="share-buttons">
            <button class="share-btn"><i class="fas fa-share-alt"></i></button>
            <button class="share-btn"><i class="fab fa-weixin"></i></button>
            <button class="share-btn"><i class="fab fa-weibo"></i></button>
            <button class="share-btn"><i class="fab fa-qq"></i></button>
          </div>
        </div>
      </div>
    </div>
    
    <div v-else class="loading">加载中...</div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, inject } from 'vue'
import { useRouter, useRoute } from 'vue-router'

const flash = inject('flash')
const store = inject('store')
const router = useRouter()
const route = useRoute()

// 状态管理
const product = ref(null)
const quantity = ref(1)
const productImages = ref([])

// 计算属性
const isLoggedIn = computed(() => store?.isAuthenticated?.() || false)

// 方法
const decreaseQuantity = () => {
  if (quantity.value > 1) {
    quantity.value--
  }
}

const increaseQuantity = () => {
  if (product.value && quantity.value < product.value.stock) {
    quantity.value++
  }
}

const addToCart = (selectedProduct) => {
  if (isLoggedIn.value && store?.addToCart) {
    store.addToCart(selectedProduct, quantity.value)
    flash?.('添加到购物车成功!')
  } else {
    router.push({ name: 'login', query: { redirect: `/product/${route.params.id}` } })
  }
}

const addToCollection = (selectedProduct) => {
  if (isLoggedIn.value && store?.addToCollect) {
    store.addToCollect(selectedProduct)
    flash?.('添加收藏成功!')
  } else {
    router.push({ name: 'login', query: { redirect: `/product/${route.params.id}` } })
  }
}

// 获取产品详情
onMounted(() => {
  const productId = parseInt(route.params.id)
  
  // 在实际应用中，这里会调用API获取产品详情
  // 由于没有后端，我们使用模拟数据
  const mockProducts = [
    { id: 1, name: '北极熊', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2d5688c538a9b5d1b564.jpg' },
    { id: 2, name: '月夜虎影', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2d5688c538a9b5d1b563.jpg' },
    { id: 3, name: '金鱼', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2d5688c538a9b5d1b562.jpg' },
    { id: 4, name: '虎头', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2d5688c538a9b5d1b565.jpg' },
    { id: 5, name: '雄狮', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2d5688c538a9b5d1b560.jpg' },
    { id: 6, name: '亲昵', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2d5688c538a9b5d1b561.jpg' },
    { id: 7, name: '白虎头', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2d5f88c538a9b5d1b569.jpg' },
    { id: 8, name: '饮水虎', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2d5f88c538a9b5d1b56a.jpg' },
    { id: 9, name: '沙皮狗', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2d5f88c538a9b5d1b56b.jpg' },
    { id: 10, name: '纸画绣 几维鸟', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2d5f88c538a9b5d1b56e.jpg' },
    { id: 11, name: '雪归', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2d5f88c538a9b5d1b56c.jpg' },
    { id: 12, name: '望月', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2d5f88c538a9b5d1b56d.jpg' },
    { id: 13, name: '布什总统全家福', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2d6e88c538a9b5d1b570.jpg' },
    { id: 14, name: '邓小平绣像', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2d6f88c538a9b5d1b571.jpg' },
    { id: 15, name: '童趣', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2d6f88c538a9b5d1b572.jpg' },
    { id: 16, name: '亚特兰大市长肖像', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2d6f88c538a9b5d1b573.jpg' },
    { id: 17, name: '李仪徽研磨掺针绣连环画绣', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2d6f88c538a9b5d1b574.jpg' },
    { id: 18, name: '毛泽东在陕北', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2d7888c538a9b5d1b576.jpg' },
    { id: 19, name: '菡萏潇湘', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2d7888c538a9b5d1b578.jpg' },
    { id: 20, name: '荷香熠熠', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2d7a88c538a9b5d1b57b.jpg' },
    { id: 21, name: '秾芳图', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2d7988c538a9b5d1b57a.jpg' },
    { id: 22, name: '马蹄莲', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2d7988c538a9b5d1b579.jpg' },
    { id: 23, name: '黄底锦缎麒麟花卉帐檐', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2d8488c538a9b5d1b594.jpg' },
    { id: 24, name: '套针绣 牡丹', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2d8388c538a9b5d1b593.jpg' },
    { id: 25, name: '掺针绣 牡丹', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2d8488c538a9b5d1b595.jpg' },
    { id: 26, name: '明净清幽幽', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67ff693088c538a9b5d35ee6.jpg' },
    { id: 27, name: '馨香月影清', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2d8888c538a9b5d1b59d.jpg' },
    { id: 28, name: '百花争妍', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2d8788c538a9b5d1b599.jpg' },
    { id: 29, name: '冬雪北国', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2d9888c538a9b5d1b5a2.jpg' },
    { id: 30, name: '枫红爱晚', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2d9988c538a9b5d1b5a3.jpg' },
    { id: 31, name: '幽谷清亭图', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2d9b88c538a9b5d1b5a5.jpg' },
    { id: 32, name: '唐寅山水', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2d9d88c538a9b5d1b5a7.jpg' },
    { id: 33, name: '李云青的山水图', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2db388c538a9b5d1b5b4.jpg' },
    { id: 34, name: '湘西风情', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2db888c538a9b5d1b5bf.jpg' },
    { id: 35, name: '油画白桦林', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2d9988c538a9b5d1b5a4.jpg' },
    { id: 36, name: '山水条屏', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2d9d88c538a9b5d1b5a6.jpg' },
    { id: 37, name: '墨色山水四页屏', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2db988c538a9b5d1b5c0.jpg' },
    { id: 38, name: '韶山全景', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2db988c538a9b5d1b5c1.jpg' },
    { id: 39, name: '瑶族挑花围裙 哪吒闹海', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2db788c538a9b5d1b5b7.jpg' },
    { id: 40, name: '华主席鼓励我们绣韶山', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2db988c538a9b5d1b5c2.jpg' },
    { id: 41, name: '桃源刺绣红呢地 "诸葛亮七擒孟获"堂彩', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2dd188c538a9b5d1b5d5.jpg' },
    { id: 42, name: '壁画 羞女情', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2dd788c538a9b5d1b5de.jpg' },
    { id: 43, name: '香港精品展签名', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2dd588c538a9b5d1b5d8.jpg' },
    { id: 44, name: '人物故事绣片', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2dd688c538a9b5d1b5dd.jpg' },
    { id: 45, name: '婴戏图6页屏风', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67fe2dd188c538a9b5d1b5d6.jpg' },
    { id: 46, name: '壁挂 太阳和人', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67ff6afb88c538a9b5d365f2.jpg' },
    { id: 47, name: '毛主席去安源', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67ff6b1388c538a9b5d36649.jpg' },
    { id: 48, name: '韩熙载夜宴图', price: 10, stock: 10, image_url: 'https://pic1.imgdb.cn/item/67ff6b3388c538a9b5d366bb.jpg' }
  ]
  
  const foundProduct = mockProducts.find(p => p.id === productId)
  if (foundProduct) {
    product.value = foundProduct
    // 设置产品图片（使用相同图片作为示例）
    productImages.value = Array(5).fill(foundProduct.image_url)
  } else {
    flash?.('产品不存在!', 'error')
    router.push('/shop')
  }
})
</script>

<style scoped>
/* 产品容器样式 - 符合project项目设计 */
.product-container {
  max-width: 1200px;
  margin: 0 auto;
  margin-top: 100px; /* 为固定的导航栏留出空间 */
}

/* 页面标题样式 */
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

.heading p span {
  color: var(--warning-color);
}

/* 产品详情部分样式 */
.product-detail {
  display: flex;
  gap: 5rem;
  padding: 5rem 9%;
  background-color: #fff;
  flex-wrap: wrap;
}

/* 图片展示部分 */
.image-section {
  flex: 1;
  min-width: 300px;
  max-width: 500px;
}

/* 主图 */
.main-image {
  margin-bottom: 2rem;
}

.main-image img {
  width: 100%;
  height: auto;
  border-radius: 0.5rem;
  box-shadow: 0 0.5rem 1.5rem rgba(0, 0, 0, 0.1);
}

/* 缩略图 */
.thumbnail-images {
  display: flex;
  gap: 1rem;
  overflow-x: auto;
  padding-bottom: 1rem;
}

.thumbnail {
  flex: 0 0 auto;
  width: 80px;
  border: 2px solid transparent;
  border-radius: 0.5rem;
  cursor: pointer;
  transition: all 0.3s ease;
}

.thumbnail:hover {
  border-color: var(--primary-color);
}

.thumbnail img {
  width: 100%;
  height: auto;
  border-radius: 0.3rem;
}

/* 产品信息样式 */
.product-info {
  flex: 1;
  min-width: 300px;
  max-width: 500px;
}

/* 商品名称 */
.product-name {
  font-size: 2.5rem;
  color: var(--secondary-color);
  margin-bottom: 1.5rem;
  line-height: 1.2;
}

/* 价格样式 */
.price-section {
  margin-bottom: 1.5rem;
}

.price-section .price {
  font-size: 2.8rem;
  color: #e74c3c;
  font-weight: bold;
}

/* 评分样式 */
.rating {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 2rem;
}

.rating .stars {
  color: #f39c12;
  font-size: 1.6rem;
  display: flex;
  gap: 0.3rem;
}

.rating .rating-text {
  color: var(--secondary-color);
  font-size: 1.4rem;
}

/* 描述样式 */
.description {
  font-size: 1.6rem;
  color: var(--secondary-color);
  line-height: 1.6;
  margin-bottom: 2.5rem;
}

/* 操作区域 */
.action-section {
  display: flex;
  align-items: center;
  gap: 2rem;
  margin-bottom: 2.5rem;
  flex-wrap: wrap;
}

/* 数量控制样式 */
.quantity {
  display: flex;
  align-items: center;
  background-color: #f9f9f9;
  border-radius: 0.5rem;
  overflow: hidden;
}

.quantity button {
  width: 40px;
  height: 40px;
  background-color: #f9f9f9;
  border: none;
  cursor: pointer;
  font-size: 1.8rem;
  color: var(--secondary-color);
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.quantity button:hover:not(:disabled) {
  background-color: #e0e0e0;
}

.quantity button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.quantity span {
  width: 60px;
  height: 40px;
  text-align: center;
  line-height: 40px;
  font-size: 1.6rem;
  color: var(--secondary-color);
  background-color: #fff;
  border-left: 1px solid #e0e0e0;
  border-right: 1px solid #e0e0e0;
}

/* 立即购买按钮 */
.buttons {
  flex: 1;
  min-width: 200px;
}

.buy-now {
  width: 100%;
  background-color: var(--primary-color);
  color: white;
  border: none;
  padding: 1.2rem;
  font-size: 1.6rem;
  cursor: pointer;
  border-radius: 0.5rem;
  transition: all 0.3s ease;
  font-weight: 600;
}

.buy-now:hover {
  background-color: var(--primary-light);
  transform: translateY(-2px);
  box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.1);
}

/* 配送信息 */
.delivery-info {
  margin-bottom: 2.5rem;
  padding: 1.5rem;
  background-color: #f9f9f9;
  border-radius: 0.5rem;
  font-size: 1.4rem;
  color: var(--secondary-color);
  line-height: 1.5;
}

/* 操作按钮 */
.action-buttons {
  display: flex;
  align-items: center;
  gap: 2rem;
  flex-wrap: wrap;
}

/* 收藏按钮 */
.favorite-btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  background-color: #fff;
  color: var(--secondary-color);
  border: 1px solid #e0e0e0;
  padding: 0.8rem 1.5rem;
  font-size: 1.4rem;
  cursor: pointer;
  border-radius: 0.5rem;
  transition: all 0.3s ease;
}

.favorite-btn:hover {
  border-color: var(--primary-color);
  color: var(--primary-color);
}

/* 分享按钮组 */
.share-buttons {
  display: flex;
  gap: 1rem;
}

.share-btn {
  width: 40px;
  height: 40px;
  background-color: #f9f9f9;
  border: 1px solid #e0e0e0;
  border-radius: 50%;
  cursor: pointer;
  font-size: 1.6rem;
  color: var(--secondary-color);
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s ease;
}

.share-btn:hover {
  background-color: var(--primary-color);
  color: #fff;
  border-color: var(--primary-color);
  transform: translateY(-2px);
}

/* 加载状态样式 */
.loading {
  text-align: center;
  font-size: 2rem;
  color: var(--secondary-color);
  padding: 6rem 2rem;
  background-color: #fff;
  border-radius: 0.5rem;
  margin: 2rem 9%;
  box-shadow: 0 0.5rem 1.5rem rgba(0, 0, 0, 0.05);
}

/* 响应式设计 - 大屏幕 */
@media (max-width: 1200px) {
  .product-detail {
    padding: 4rem 5%;
    gap: 4rem;
  }
  
  .heading {
    padding: 2rem 5%;
  }
}

/* 响应式设计 - 平板 */
@media (max-width: 991px) {
  .product-detail {
    flex-direction: column;
    align-items: center;
    gap: 3rem;
  }
  
  .image-section,
  .product-info {
    max-width: 100%;
  }
  
  .action-section {
    justify-content: center;
  }
  
  .buttons {
    min-width: 250px;
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
  
  .product-detail {
    padding: 2rem;
  }
  
  .product-name {
    font-size: 2.2rem;
  }
  
  .price-section .price {
    font-size: 2.5rem;
  }
  
  .description {
    font-size: 1.4rem;
  }
  
  .action-section {
    flex-direction: column;
    align-items: stretch;
    gap: 1.5rem;
  }
  
  .quantity {
    align-self: flex-start;
  }
  
  .buttons {
    width: 100%;
  }
  
  .action-buttons {
    justify-content: center;
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
  
  .product-detail {
    padding: 1.5rem;
  }
  
  .product-name {
    font-size: 2rem;
  }
  
  .price-section .price {
    font-size: 2.2rem;
  }
  
  .thumbnail {
    width: 60px;
  }
  
  .quantity button {
    width: 35px;
    height: 35px;
    font-size: 1.6rem;
  }
  
  .quantity span {
    width: 50px;
    height: 35px;
    line-height: 35px;
    font-size: 1.4rem;
  }
  
  .buy-now {
    font-size: 1.4rem;
    padding: 1rem;
  }
  
  .delivery-info {
    font-size: 1.2rem;
    padding: 1.2rem;
  }
  
  .favorite-btn {
    font-size: 1.2rem;
    padding: 0.6rem 1.2rem;
  }
  
  .share-btn {
    width: 35px;
    height: 35px;
    font-size: 1.4rem;
  }
  
  .loading {
    font-size: 1.8rem;
    padding: 4rem 1.5rem;
    margin: 1rem;
  }
}
</style>