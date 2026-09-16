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
   声栖 · 全局 iOS 设计语言（Apple HIG）v2
   跟随主题引擎 var(--app-*) / --p-* token，
   保留 6 配色 × 3 UI 风格 × 明暗切换
   ============================================================ */
page {
  background-color: var(--app-bg);
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'PingFang SC', 'HarmonyOS Sans SC', 'Noto Sans SC', 'Microsoft YaHei', sans-serif;
  color: var(--app-text);
  font-size: 30rpx; /* 基准 15px */
  line-height: 1.55;
  -webkit-font-smoothing: antialiased;
}

/* 数字/计时专用（tabular-nums 防跳动） */
.num {
  font-variant-numeric: tabular-nums;
}

/* 顶部柔和渐变氛围（iOS 淡彩磨砂感） */
.page-bg {
  position: fixed;
  left: 0;
  top: 0;
  right: 0;
  height: 440rpx;
  background: linear-gradient(180deg, var(--app-bg-grad) 0%, var(--app-bg) 70%, transparent 100%);
  pointer-events: none;
  z-index: -1; /* 铁律：不得改 */
}

/* 页面容器：左右留白遵循内容安全边距 */
.page-container {
  position: relative;
  z-index: 1;
  min-height: 100vh;
  padding: calc(env(safe-area-inset-top, 0rpx) + 24rpx) 40rpx calc(var(--app-tab-height, 56px) + var(--app-playbar-height, 64px) + 56rpx);
  box-sizing: border-box;
  background: transparent;
  animation: iosPageIn var(--dur-page, 380ms) var(--ease-std, cubic-bezier(.32, .72, 0, 1)) backwards;
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

/* 动效 token 未注入时的静态兜底 */
:root {
  --dur-fast: 160ms;
  --dur-base: 220ms;
  --dur-slow: 320ms;
  --dur-page: 380ms;
  --ease-std: cubic-bezier(.32, .72, 0, 1);
  --ease-out: cubic-bezier(.2, 0, 0, 1);
  --ease-in: cubic-bezier(.4, 0, 1, 1);
}

/* 全局 reduced-motion：尊重系统「减弱动态效果」偏好 */
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: .01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: .01ms !important;
    scroll-behavior: auto !important;
  }
}

/* 键盘焦点可见态（无障碍） */
:focus-visible {
  outline: 2px solid var(--app-primary);
  outline-offset: 2px;
}

/* ---------- 按钮 Primary（iOS 填充按钮） ---------- */
.btn-primary {
  background: var(--app-primary);
  color: var(--app-on-primary);
  border-radius: 999rpx;
  padding: 22rpx 44rpx;
  font-size: 29rpx;
  font-weight: 600;
  display: flex;
  align-items: center;
  justify-content: center;
  border: none;
  box-shadow: var(--app-shadow-2);
  transition: transform var(--dur-fast) var(--ease-std), opacity var(--dur-fast) var(--ease-std);

  &:active {
    transform: scale(.96);
  }
}

/* ---------- 按钮 Outline（iOS 边框按钮） ---------- */
.btn-outline {
  background: transparent;
  color: var(--app-primary);
  border: 1rpx solid color-mix(in srgb, var(--app-primary) 55%, transparent);
  border-radius: 999rpx;
  padding: 20rpx 44rpx;
  font-size: 29rpx;
  font-weight: 600;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background var(--dur-fast) var(--ease-std);

  &:active {
    background: var(--app-primary-soft);
    transform: scale(.96);
  }
}

/* ---------- 卡片容器（iOS 卡片：圆角 + 发丝级描边 + 柔和投影） ---------- */
.app-card {
  background: var(--app-surface);
  border: 1rpx solid var(--app-line);
  border-radius: 44rpx; /* MASTER.md 卡片 lg 22px */
  box-shadow: var(--app-shadow-2), var(--app-inset);
  backdrop-filter: blur(var(--app-blur));
  -webkit-backdrop-filter: blur(var(--app-blur));
}

/* ---------- 页面大标题（iOS Large Title） ---------- */
.page-title {
  font-size: 48rpx;
  font-weight: 700;
  letter-spacing: -0.4rpx;
  line-height: 1.22;
  color: var(--app-text);
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
  background: var(--app-line);
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