<template>
  <div v-if="$route.name === 'chatBot'" class="chat-bot-page">
    <section class="heading">
      <h3>AI助手</h3>
      <p> <router-link to="/">首页</router-link> / <span>AI助手</span> </p>
    </section>
    
    <div class="chat-container-wrapper">
      <div class="chat-container">
      <!-- 消息列表 -->
      <div class="messages-container" ref="messagesContainer">
        <div v-for="(message, index) in messages" :key="index" :class="message.type">
          <div class="message-content">
            {{ message.content }}
          </div>
        </div>
        
        <div v-if="isTyping" class="typing-indicator">
          <span class="typing-dots">
            <span></span>
            <span></span>
            <span></span>
          </span>
        </div>
      </div>
      
      <!-- 输入区域 -->
      <div class="input-area">
        <input 
          type="text" 
          v-model="userInput" 
          placeholder="请输入您的问题..."
          class="user-input"
          @keyup.enter="sendMessage"
        >
        <button @click="sendMessage" class="send-btn">
          <i class="fas fa-paper-plane"></i>
        </button>
      </div>
      </div>
    </div>
  </div>
  
  <div v-else class="chat-bot-float">
    <div class="chat-bot-trigger" @click="goToChatBot">
      <i class="fas fa-comments"></i>
    </div>
  </div>
</template>

<script setup>
import { ref, nextTick, onMounted } from 'vue'

// 控制聊天窗口开关
const isChatOpen = ref(true)

// 跳转到ChatBot页面
const goToChatBot = () => {
  window.location.href = '/chatBot'
}
// 用户输入内容
const userInput = ref('')
// 消息列表
const messages = ref([
  {
    type: 'bot-message',
    content: '您好！我是湘绣AI助手，很高兴为您提供帮助。\n您可以向我询问关于湘绣的历史、技法、作品等相关信息。'
  }
])
// 是否正在输入
const isTyping = ref(false)
// 消息容器引用
const messagesContainer = ref(null)
// Coze SDK实例
let cozeWebSDK = null

// Bot ID - 使用提供的bot_id
const botId = '7486101891035447346'
// PAT令牌 - 实际使用时需要从安全的地方获取
const patToken = 'pat_5G1AogU0NX2yx0dRSHe5yjj233ykcllkbtx5ofqWRwOouoOEycgONJj4FIuHrkK3'

// 动态加载Coze SDK
const loadCozeSDK = () => {
  return new Promise((resolve, reject) => {
    // 检查SDK是否已经加载
    if (window.CozeWebSDK) {
      resolve(window.CozeWebSDK)
      return
    }
    
    // 创建script标签
    const script = document.createElement('script')
    script.src = 'https://lf-cdn.coze.cn/obj/unpkg/flow-platform/chat-app-sdk/1.1.0-beta.0/libs/cn/index.js'
    script.async = true
    
    // 加载成功回调
    script.onload = () => {
      console.log('Coze SDK 加载成功')
      resolve(window.CozeWebSDK)
    }
    
    // 加载失败回调
    script.onerror = (error) => {
      console.error('Coze SDK 加载失败:', error)
      reject(new Error('Coze SDK 加载失败'))
    }
    
    // 添加到document
    document.head.appendChild(script)
  })
}

// 初始化Coze SDK
const initCozeSDK = async () => {
  try {
    // 加载SDK
    const CozeWebSDK = await loadCozeSDK()
    
    if (CozeWebSDK) {
      // 初始化WebChatClient
      cozeWebSDK = new CozeWebSDK.WebChatClient({
        config: {
          // Agent ID
          botId: botId,
          isIframe: false,
        },
        auth: {
          // Authentication methods, the default type is 'unauth', which means no authentication is required
          type: 'token',
          // When the type is set to 'token', it is necessary to configure a PAT (Personal Access Token) or OAuth access token for authentication.
          token: patToken,
          // When the access token expires, use a new token and set it as needed.
          onRefreshToken: () => patToken,
        },
        chatBot: {
          title: '湘绣AI助手',
          uploadable: true,
          width: 390
        },
        footer: {
          isShow: false,
        }
      })
      
      console.log('Coze SDK 初始化成功')
    }
  } catch (error) {
    console.error('Coze SDK 初始化失败:', error)
  }
}

// 切换聊天窗口显示状态
const toggleChat = () => {
  isChatOpen.value = !isChatOpen.value
  if (isChatOpen.value) {
    nextTick(() => scrollToBottom())
  }
}

// 发送消息
const sendMessage = () => {
  if (userInput.value.trim() && !isTyping.value) {
    const userMessage = userInput.value.trim()
    
    // 添加用户消息
    messages.value.push({
      type: 'user-message',
      content: userMessage
    })
    
    // 清空输入框
    userInput.value = ''
    
    // 滚动到底部
    scrollToBottom()
    
    // 获取AI回复
    getAIResponse(userMessage)
  }
}

// 使用Coze SDK获取AI回复
const getAIResponse = async (question) => {
  // 设置正在输入状态
  isTyping.value = true
  
  // 滚动到底部
  nextTick(() => scrollToBottom())
  
  try {
    if (!cozeWebSDK) {
      throw new Error('Coze SDK 未初始化')
    }
    
    console.log('通过Coze SDK发送消息:', question)
    
    // 使用SDK发送消息
    const response = await cozeWebSDK.chat({ query: question, stream: false })
    
    console.log('Coze SDK响应数据:', response)
    
    // 处理SDK返回的回复
    let botResponse = '抱歉，我无法获取回复。请稍后再试。'
    
    // 根据SDK响应结构提取回复内容
    if (response.code === 0 && response.data) {
      if (response.data.messages && response.data.messages.length > 0) {
        const lastMessage = response.data.messages[response.data.messages.length - 1]
        if (lastMessage.content) {
          botResponse = lastMessage.content
        }
      } else if (response.data.answer) {
        // 兼容可能的其他响应格式
        botResponse = response.data.answer
      }
    } else {
      botResponse = `获取回复失败: ${response.msg || '未知错误'}`
    }
    
    // 关闭正在输入状态
    isTyping.value = false
    
    // 添加AI回复
    messages.value.push({
      type: 'bot-message',
      content: botResponse
    })
    
  } catch (error) {
    console.error('获取AI回复失败:', error)
    
    // 错误情况下也关闭输入状态并显示友好提示
    isTyping.value = false
    
    messages.value.push({
      type: 'bot-message',
      content: '抱歉，我暂时无法为您提供回答。可能是网络问题或服务暂时不可用，请稍后再试。'
    })
  } finally {
    // 滚动到底部
    nextTick(() => scrollToBottom())
  }
}

// 发送预设问题
const sendQuestion = (question) => {
  userInput.value = question
  sendMessage()
}

// 滚动到底部
const scrollToBottom = () => {
  if (messagesContainer.value) {
    messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight
  }
}

// 生命周期钩子
onMounted(async () => {
  console.log('聊天机器人组件已加载')
  // 初始化Coze SDK
  await initCozeSDK()
  // 滚动到底部
  nextTick(() => scrollToBottom())
})
</script>

<style scoped>
/* 页面样式 */
.chat-bot-page {
  max-width: 1200px;
  margin: 0 auto;
  margin-top: 100px;
  padding-bottom: 50px;
  min-height: calc(100vh - 200px);
}

/* 浮窗样式 */
.chat-bot-float {
  position: fixed;
  bottom: 30px;
  right: 30px;
  z-index: 9999;
}

.chat-bot-trigger {
  width: 60px;
  height: 60px;
  background-color: var(--primary-color);
  color: #fff;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 2.4rem;
  cursor: pointer;
  box-shadow: 0 4px 12px rgba(36, 77, 77, 0.3);
  transition: all 0.3s ease;
}

.chat-bot-trigger:hover {
  background-color: var(--primary-light);
  transform: scale(1.1);
  box-shadow: 0 6px 16px rgba(36, 77, 77, 0.4);
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

/* 聊天容器包装器 */
.chat-container-wrapper {
  padding: 4rem 9%;
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



/* 聊天容器 */
.chat-container {
  background-color: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.08);
  overflow: hidden;
  max-width: 800px;
  margin: 0 auto;
  display: flex;
  flex-direction: column;
  height: 600px;
}

/* 消息列表 */
.messages-container {
  flex: 1;
  padding: 20px;
  overflow-y: auto;
  background-color: #f9f9f9;
  display: flex;
  flex-direction: column;
  gap: 15px;
}

/* 消息样式 */
.user-message, .bot-message {
  display: flex;
  max-width: 80%;
}

.user-message {
  align-self: flex-end;
}

.bot-message {
  align-self: flex-start;
}

.message-content {
  padding: 12px 16px;
  border-radius: 18px;
  font-size: 1.6rem;
  line-height: 1.5;
  white-space: pre-wrap;
}

.user-message .message-content {
  background-color: var(--primary-color);
  color: #fff;
  border-bottom-right-radius: 6px;
}

.bot-message .message-content {
  background-color: #fff;
  color: #333;
  border-bottom-left-radius: 6px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

/* 输入区域 */
.input-area {
  display: flex;
  padding: 20px;
  gap: 10px;
  border-top: 1px solid #eee;
  background-color: #fff;
}

.user-input {
  flex: 1;
  padding: 12px 16px;
  border: 1px solid var(--primary-light);
  border-radius: 25px;
  font-size: 1.6rem;
  outline: none;
  transition: all 0.3s ease;
}

.user-input:focus {
  border-color: var(--primary-color);
  box-shadow: 0 0 0 2px rgba(36, 77, 77, 0.1);
}

.send-btn {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  background-color: var(--primary-color);
  color: #fff;
  border: none;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s ease;
  font-size: 1.8rem;
}

.send-btn:hover {
  background-color: var(--primary-light);
  transform: scale(1.05);
}

/* 正在输入指示器 */
.typing-indicator {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 16px;
  background-color: #fff;
  border-radius: 18px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.typing-dots span {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background-color: #999;
  animation: typing 1.4s infinite ease-in-out;
}

.typing-dots span:nth-child(1) {
  animation-delay: -0.32s;
}

.typing-dots span:nth-child(2) {
  animation-delay: -0.16s;
}

@keyframes typing {
  0%, 80%, 100% {
    transform: scale(0.8);
    opacity: 0.5;
  }
  40% {
    transform: scale(1);
    opacity: 1;
  }
}

/* 响应式设计 */
@media (max-width: 768px) {
  .chat-container-wrapper {
    padding: 2rem 5%;
  }
  
  .chat-container {
    height: 500px;
  }
  
  .messages-container {
    padding: 15px;
  }
  
  .input-area {
    padding: 15px;
  }
  
  .message-content {
    font-size: 1.4rem;
    padding: 10px 14px;
  }
}
/* 滚动条样式 */
.messages-container::-webkit-scrollbar {
  width: 6px;
}

.messages-container::-webkit-scrollbar-track {
  background: #f1f1f1;
}

.messages-container::-webkit-scrollbar-thumb {
  background: var(--primary-light);
  border-radius: 3px;
}

.messages-container::-webkit-scrollbar-thumb:hover {
  background: var(--primary-color);
}

/* 响应式设计 - 大屏幕 */
@media (max-width: 1200px) {
  .chat-container-wrapper {
    padding: 3rem 5%;
  }
  
  .heading {
    padding: 2rem 5%;
  }
}

/* 响应式设计 - 平板 */
@media (max-width: 991px) {
  .chat-container {
    height: 450px;
  }
}

/* 响应式设计 - 小手机 */
@media (max-width: 450px) {
  .chat-container {
    height: 400px;
  }
  
  .chat-bot-float {
    bottom: 20px;
    right: 20px;
  }
  
  .chat-bot-trigger {
    width: 50px;
    height: 50px;
    font-size: 2rem;
  }
}
</style>