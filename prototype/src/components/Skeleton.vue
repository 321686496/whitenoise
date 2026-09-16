<template>
  <view class="sk-wrap">
    <view v-for="i in count" :key="i" class="sk-row" :class="'sk-row--' + type">
      <view class="sk sk-media" />
      <view class="sk-lines">
        <view class="sk sk-line" style="width: 62%" />
        <view class="sk sk-line" style="width: 38%" />
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
withDefaults(defineProps<{ type?: 'card' | 'list' | 'grid'; count?: number }>(), { type: 'list', count: 3 })
</script>

<style lang="scss" scoped>
.sk { background: var(--app-surface-2); border-radius: 16rpx; overflow: hidden; position: relative; }
.sk::after {
  content: ''; position: absolute; inset: 0;
  background: linear-gradient(90deg, transparent, color-mix(in srgb, var(--app-text) 6%, transparent), transparent);
  animation: skShimmer 1.6s ease-in-out infinite;
}
@keyframes skShimmer { 0% { transform: translateX(-100%); } 100% { transform: translateX(100%); } }
.sk-wrap { display: flex; flex-direction: column; gap: 24rpx; }
.sk-row { display: flex; gap: 24rpx; align-items: center; }
.sk-row--grid, .sk-row--card { display: block; }
.sk-media { width: 112rpx; height: 112rpx; flex: none; }
.sk-lines { flex: 1; display: flex; flex-direction: column; gap: 16rpx; }
.sk-line { height: 28rpx; }
@media (prefers-reduced-motion: reduce) { .sk::after { animation: none; } }
</style>
