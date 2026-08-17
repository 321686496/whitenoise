<template>
  <view class="sound-card" :class="{ active: isActive }" @click="$emit('tap')">
    <view class="sound-icon" :style="{ background: color }">
      <text class="sound-emoji">{{ emoji }}</text>
    </view>
    <text class="sound-name">{{ name }}</text>
    <text class="sound-type">{{ type }}</text>
  </view>
</template>

<script setup lang="ts">
defineProps<{
  name: string
  type: string
  emoji: string
  color: string
  isActive: boolean
}>()

defineEmits<{
  tap: []
}>()
</script>

<style lang="scss" scoped>
.sound-card {
  width: 156rpx;
  padding: 24rpx 16rpx;
  background: $app-card-bg;
  border-radius: $app-radius-sm;
  box-shadow: $app-shadow;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12rpx;
  transition: all 0.2s;
  border: 2rpx solid transparent;

  &.active {
    border-color: $app-primary;
    background: rgba($app-primary, 0.06);
  }

  &:active {
    transform: scale(0.95);
  }
}

.sound-icon {
  width: 72rpx;
  height: 72rpx;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.sound-emoji {
  font-size: 36rpx;
}

.sound-name {
  font-size: 24rpx;
  color: $uni-text-color;
  font-weight: 500;
  text-align: center;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  max-width: 100%;
}

.sound-type {
  font-size: 20rpx;
  color: $uni-text-color-grey;
}
</style>