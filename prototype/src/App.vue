<script setup lang="ts">
import { onLaunch, onShow, onHide } from '@dcloudio/uni-app'
import { initTheme } from '@/theme/index'

onLaunch(() => {
  initTheme()
  console.log('声栖 App Launch')
})

onShow(() => {
  console.log('声栖 App Show')
})

onHide(() => {
  console.log('声栖 App Hide')
})
</script>

<style lang="scss">
@import '@/uni.scss';

/* ============================================================
   声栖 · 全局 iOS 设计语言（Apple HIG）
   跟随主题引擎 var(--app-*) 变量，保留 6 配色 × 3 UI 风格切换
   ============================================================ */
page {
  background-color: var(--app-bg);
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'SF Pro Display', 'PingFang SC', 'Helvetica Neue', 'Segoe UI', Roboto, sans-serif;
  color: var(--app-text);
  font-size: $uni-font-size-base;
  -webkit-font-smoothing: antialiased;
}

/* 顶部柔和渐变氛围（iOS 淡彩磨砂感） */
.page-bg {
  position: fixed;
  left: 0;
  top: 0;
  right: 0;
  height: 440rpx;
  background: linear-gradient(180deg, var(--app-bg-grad) 0%, var(--app-bg) 70%, rgba(255,255,255,0) 100%);
  pointer-events: none;
  z-index: -1;
}

/* 页面容器：左右留白遵循内容安全边距 */
.page-container {
  position: relative;
  z-index: 1;
  min-height: 100vh;
  padding: calc(env(safe-area-inset-top, 0rpx) + 24rpx) 26rpx calc(var(--app-tab-height, 100rpx) + var(--app-playbar-height, 140rpx) + 28rpx);
  box-sizing: border-box;
  background: transparent;
  animation: iosPageIn 0.32s cubic-bezier(.4, 0, .2, 1) backwards;
}

/* iOS 页面进入动效：轻微上浮 + 淡入 */
@keyframes iosPageIn {
  from {
    opacity: 0;
    transform: translateY(18rpx);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@media (prefers-reduced-motion: reduce) {
  .page-container {
    animation: none;
  }
}

/* ---------- 按钮 Primary（iOS 填充按钮） ---------- */
.btn-primary {
  background: var(--app-primary);
  color: var(--app-on-primary);
  border-radius: 26rpx;
  padding: 22rpx 44rpx;
  font-size: 29rpx;
  font-weight: 600;
  letter-spacing: 1rpx;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 10rpx 26rpx color-mix(in srgb, var(--app-primary) 30%, transparent);
  transition: all 0.18s cubic-bezier(.4,0,.2,1);

  &:active {
    opacity: 0.82;
    transform: scale(0.97);
  }
}

/* ---------- 按钮 Outline（iOS 边框按钮） ---------- */
.btn-outline {
  background: transparent;
  color: var(--app-primary);
  border: 1rpx solid color-mix(in srgb, var(--app-primary) 60%, transparent);
  border-radius: 26rpx;
  padding: 20rpx 44rpx;
  font-size: 29rpx;
  font-weight: 600;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.18s;

  &:active {
    background: var(--app-primary-soft);
  }
}

/* ---------- 卡片容器（iOS 卡片：圆角 + 发丝级描边 + 柔和投影） ---------- */
.app-card {
  background: var(--app-card-bg);
  border: 1rpx solid var(--app-card-border);
  border-radius: 28rpx;
  box-shadow: var(--app-card-shadow);
  backdrop-filter: blur(var(--app-card-blur));
  -webkit-backdrop-filter: blur(var(--app-card-blur));
}

/* ---------- 页面大标题（iOS Large Title） ---------- */
.page-title {
  font-size: 52rpx;
  font-weight: 700;
  letter-spacing: -1.5rpx;
  color: var(--app-text);
  line-height: 1.15;
  display: block;
}

/* ---------- 小节标题（iOS Grouped Header：小号次级标签色，左对齐内缩） ---------- */
.section-title {
  font-size: 24rpx;
  font-weight: 600;
  letter-spacing: 0.3rpx;
  color: var(--app-text-2);
  margin-bottom: 16rpx;
  padding-left: 8rpx;
  display: block;
}

.page-subtitle {
  font-size: 26rpx;
  font-weight: 400;
  letter-spacing: 0rpx;
  color: var(--app-text-2);
  margin-top: 10rpx;
  display: block;
}

/* ---------- 分隔线（发丝级，inset 风格） ---------- */
.divider {
  height: 1rpx;
  background: var(--app-divider);
}

/* 底部安全区 */
.safe-bottom {
  padding-bottom: constant(safe-area-inset-bottom);
  padding-bottom: env(safe-area-inset-bottom);
}

/* ============================================================
   tabBar 采用自定义悬浮 TabBar（components/TabBar.vue），
   原生 tabBar 已通过 pages.json 开启 custom:true，
   这里再强制隐藏原生的 uni-tabbar 元素，避免 H5 上残留渲染。
   ============================================================ */
uni-tabbar,
uni-tabbar .uni-tabbar,
uni-tabbar .uni-tabbar__bd {
  display: none !important;
}
</style>