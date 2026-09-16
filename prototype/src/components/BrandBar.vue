<template>
  <view class="brand-bar">
    <image class="brand-logo" src="/static/logo-v10-1.jpg" mode="aspectFill" />
    <view class="brand-text">
      <text class="brand-name">声栖</text>
      <text class="brand-greet">{{ greeting }}</text>
    </view>
    <view class="brand-actions">
      <view class="brand-btn" aria-label="主题" @click="go('/pages/theme/theme')"><Icon name="palette" :size="20" /></view>
      <view class="brand-btn" aria-label="成就" @click="go('/pages/achievement/achievement')"><Icon name="award" :size="20" /></view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import Icon from '@/components/Icon.vue'
const greeting = computed(() => {
  const h = new Date().getHours()
  if (h < 5) return '夜深了，愿你好眠'
  if (h < 11) return '早上好'
  if (h < 13) return '中午好'
  if (h < 18) return '下午好'
  return '晚上好'
})
function go(url: string) {
  uni.navigateTo({ url })
}
</script>

<style lang="scss" scoped>
.brand-bar { display: flex; align-items: center; gap: 20rpx; margin-bottom: 32rpx; }
.brand-logo { width: 88rpx; height: 88rpx; border-radius: 28rpx; flex: none; }
.brand-text { flex: 1; display: flex; flex-direction: column; gap: 4rpx; }
.brand-name { font-size: 40rpx; font-weight: 700; letter-spacing: -0.4rpx; color: var(--app-text); }
.brand-greet { font-size: 24rpx; color: var(--app-text-2); }
.brand-actions { display: flex; gap: 8rpx; }
.brand-btn {
  width: 88rpx; height: 88rpx; border-radius: 999rpx;
  background: var(--app-surface); border: 1rpx solid var(--app-line);
  box-shadow: var(--app-shadow-1), var(--app-inset);
  display: flex; align-items: center; justify-content: center; color: var(--app-text-2);
  transition: transform var(--dur-fast) var(--ease-std);
  &:active { transform: scale(.96); }
}
</style>
