<script setup lang="ts">
import { onLaunch, onShow, onHide } from '@dcloudio/uni-app'

onLaunch(() => {
  console.log('白噪音 App Launch')
})

onShow(() => {
  console.log('白噪音 App Show')
})

onHide(() => {
  console.log('白噪音 App Hide')
})
</script>

<style lang="scss">
@import '@/uni.scss';

page {
  background-color: $app-bg;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  color: $uni-text-color;
  font-size: $uni-font-size-base;
}

/* 全局毛玻璃卡片 */
.glass-card {
  background: rgba(255, 255, 255, 0.72);
  backdrop-filter: blur(20rpx);
  border-radius: $app-radius;
  box-shadow: $app-shadow;
}

/* 全局扁平卡片 */
.flat-card {
  background: $app-card-bg;
  border-radius: $app-radius-sm;
  box-shadow: $app-shadow;
}

/* 新拟态卡片 */
.neu-card {
  background: $app-bg;
  border-radius: $app-radius;
  box-shadow: 8rpx 8rpx 16rpx rgba(92, 111, 128, 0.1),
              -8rpx -8rpx 16rpx rgba(255, 255, 255, 0.8);
}

/* 通用按钮 */
.btn-primary {
  background: $app-primary;
  color: #fff;
  border-radius: $app-radius-sm;
  padding: 16rpx 40rpx;
  font-size: 28rpx;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;

  &:active {
    background: $app-primary-dark;
    transform: scale(0.97);
  }
}

.btn-outline {
  background: transparent;
  color: $app-primary;
  border: 2rpx solid $app-primary;
  border-radius: $app-radius-sm;
  padding: 16rpx 40rpx;
  font-size: 28rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* 通用标签 */
.tag {
  font-size: 22rpx;
  padding: 6rpx 16rpx;
  border-radius: 20rpx;
  background: $app-bg;
  color: $uni-text-color-grey;
}

.tag-primary {
  background: rgba($app-primary, 0.12);
  color: $app-primary;
}

/* 分隔线 */
.divider {
  height: 1rpx;
  background: $uni-border-color;
  margin: 24rpx 0;
}

/* 页面容器 */
.page-container {
  min-height: 100vh;
  padding-bottom: calc($app-playbar-height + $app-tab-height + 40rpx);
}

/* 底部安全区 */
.safe-bottom {
  padding-bottom: constant(safe-area-inset-bottom);
  padding-bottom: env(safe-area-inset-bottom);
}
</style>