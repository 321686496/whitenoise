<template>
  <view class="empty">
    <view class="empty-ic"><Icon :name="icon" :size="34" /></view>
    <text class="empty-title">{{ title }}</text>
    <text v-if="desc" class="empty-desc">{{ desc }}</text>
    <view v-if="actionText" class="empty-btn" @click="$emit('action')">{{ actionText }}</view>
  </view>
</template>

<script setup lang="ts">
import Icon from '@/components/Icon.vue'
withDefaults(defineProps<{ icon?: string; title: string; desc?: string; actionText?: string }>(), { icon: 'moon' })
defineEmits<{ (e: 'action'): void }>()
</script>

<style lang="scss" scoped>
.empty { display: flex; flex-direction: column; align-items: center; padding: 96rpx 48rpx; }
.empty-ic {
  width: 144rpx; height: 144rpx; border-radius: 999rpx;
  background: var(--app-surface-2); color: var(--app-text-3);
  display: flex; align-items: center; justify-content: center; margin-bottom: 32rpx;
  box-shadow: var(--app-inset);
}
.empty-title { font-size: 32rpx; font-weight: 600; color: var(--app-text); }
.empty-desc { font-size: 26rpx; color: var(--app-text-2); margin-top: 12rpx; text-align: center; line-height: 1.5; }
.empty-btn {
  margin-top: 40rpx; padding: 20rpx 56rpx; border-radius: 999rpx;
  background: var(--app-primary); color: var(--app-on-primary);
  font-size: 28rpx; font-weight: 600; box-shadow: var(--app-shadow-2);
  transition: transform var(--dur-fast) var(--ease-std);
  &:active { transform: scale(.96); }
}
</style>
