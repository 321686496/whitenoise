<template>
  <view class="mix-track">
    <view class="track-info">
      <view class="track-icon" :style="{ background: color }">
        <text class="track-emoji">{{ emoji }}</text>
      </view>
      <view class="track-meta">
        <text class="track-name">{{ name }}</text>
        <text class="track-volume-label">{{ volume }}%</text>
      </view>
    </view>
    <view class="track-controls">
      <view class="volume-slider" @touchmove="onSlide" @touchstart="onSlide" @click="onSlide">
        <view class="slider-track">
          <view class="slider-fill" :style="{ width: volume + '%' }"></view>
          <view class="slider-thumb" :style="{ left: volume + '%' }"></view>
        </view>
      </view>
      <view class="track-actions">
        <view class="action-btn mute-btn" :class="{ muted: isMuted }" @click="$emit('mute')">
          <text>{{ isMuted ? '🔇' : '🔊' }}</text>
        </view>
        <view class="action-btn remove-btn" @click="$emit('remove')">
          <text>✕</text>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
defineProps<{
  name: string
  emoji: string
  color: string
  volume: number
  isMuted: boolean
}>()

defineEmits<{
  volumeChange: [value: number]
  mute: []
  remove: []
}>()

const onSlide = (e: any) => {
  // 简化交互 - 原型中只做视觉反馈
}
</script>

<style lang="scss" scoped>
.mix-track {
  background: $app-card-bg;
  border-radius: $app-radius-sm;
  padding: 20rpx 24rpx;
  margin-bottom: 12rpx;
  box-shadow: $app-shadow;
}

.track-info {
  display: flex;
  align-items: center;
  gap: 16rpx;
  margin-bottom: 16rpx;
}

.track-icon {
  width: 56rpx;
  height: 56rpx;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.track-emoji {
  font-size: 28rpx;
}

.track-meta {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.track-name {
  font-size: 28rpx;
  color: $uni-text-color;
  font-weight: 500;
}

.track-volume-label {
  font-size: 24rpx;
  color: $app-primary;
  font-weight: 600;
}

.track-controls {
  display: flex;
  align-items: center;
  gap: 20rpx;
}

.volume-slider {
  flex: 1;
  padding: 12rpx 0;
}

.slider-track {
  height: 8rpx;
  background: $uni-bg-color-grey;
  border-radius: 4rpx;
  position: relative;
}

.slider-fill {
  height: 100%;
  background: $app-primary;
  border-radius: 4rpx;
  transition: width 0.15s;
}

.slider-thumb {
  width: 28rpx;
  height: 28rpx;
  background: $app-primary;
  border-radius: 50%;
  position: absolute;
  top: 50%;
  transform: translate(-50%, -50%);
  box-shadow: 0 2rpx 8rpx rgba($app-primary, 0.4);
}

.track-actions {
  display: flex;
  gap: 8rpx;
}

.action-btn {
  width: 52rpx;
  height: 52rpx;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 22rpx;
  background: $uni-bg-color-grey;
  transition: all 0.2s;

  &:active {
    transform: scale(0.9);
  }
}

.mute-btn.muted {
  background: rgba($uni-color-error, 0.12);
}

.remove-btn {
  background: rgba($uni-color-error, 0.08);
  color: $uni-color-error;
}
</style>