<template>
  <view class="nav-bar">
    <view class="nav-side">
      <view v-if="back" class="nav-btn" @click="goBack" aria-label="返回">
        <Icon name="chevron-left" :size="22" />
      </view>
    </view>
    <text class="nav-title">{{ title }}</text>
    <view class="nav-side nav-side--right"><slot name="action" /></view>
  </view>
</template>

<script setup lang="ts">
import Icon from '@/components/Icon.vue'
withDefaults(defineProps<{ title: string; back?: boolean }>(), { back: true })
function goBack() {
  const pages = getCurrentPages()
  if (pages.length > 1) uni.navigateBack()
  else uni.reLaunch({ url: '/pages/index/index' })
}
</script>

<style lang="scss" scoped>
.nav-bar {
  display: flex; align-items: center; height: 88rpx;
  padding: calc(env(safe-area-inset-top, 0rpx)) 0 0 0; margin-bottom: 8rpx;
}
.nav-side { width: 88rpx; display: flex; align-items: center; }
.nav-side--right { justify-content: flex-end; }
.nav-btn {
  width: 88rpx; height: 88rpx; margin-left: -16rpx;
  display: flex; align-items: center; justify-content: center;
  border-radius: 999rpx; color: var(--app-text);
  transition: transform var(--dur-fast) var(--ease-std);
  &:active { transform: scale(.96); background: var(--app-press); }
}
.nav-title {
  flex: 1; text-align: center; font-size: 34rpx; font-weight: 600;
  color: var(--app-text); letter-spacing: -0.2rpx;
}
</style>
