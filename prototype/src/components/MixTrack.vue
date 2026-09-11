<template>
  <view class="mix-track app-card">
    <view class="track-info">
      <view class="track-icon" :style="{ background: color }">
        <Icon :name="iconName" :size="22" color="#fff" />
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
        </view>
      </view>
      <view class="track-actions">
        <view class="action-btn" :class="{ muted: isMuted }" @click="$emit('mute')">
          <Icon :name="isMuted ? 'mute' : 'volume'" :size="17" :color="isMuted ? 'var(--app-danger)' : 'var(--app-primary)'" />
        </view>
        <view class="action-btn danger" @click="$emit('remove')">
          <Icon name="close" :size="15" color="var(--app-text-3)" />
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import Icon from './Icon.vue'

defineProps<{
  name: string
  iconName: string
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
  padding: 22rpx 24rpx;
  margin-bottom: 14rpx;
}

.track-info {
  display: flex;
  align-items: center;
  gap: 18rpx;
  margin-bottom: 18rpx;
}

/* iOS 磁贴图标 */
.track-icon {
  width: 56rpx;
  height: 56rpx;
  border-radius: 18rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  box-shadow: inset 0 -2rpx 0 rgba(0,0,0,.08), inset 0 2rpx 0 rgba(255,255,255,.25), 0 4rpx 10rpx rgba(0,0,0,.10);
}

.track-meta {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.track-name {
  font-size: 28rpx;
  color: var(--app-text, $uni-text-color);
  font-weight: 600;
  letter-spacing: -0.3rpx;
}

.track-volume-label {
  font-size: 24rpx;
  color: var(--app-primary, $app-primary);
  font-weight: 700;
}

.track-controls {
  display: flex;
  align-items: center;
  gap: 20rpx;
}

.volume-slider {
  flex: 1;
  padding: 10rpx 0;
}

/* iOS 滑块轨道 */
.slider-track {
  height: 8rpx;
  background: var(--app-input-bg, $uni-bg-color-grey);
  border-radius: 4rpx;
  position: relative;
  overflow: hidden;
}

.slider-fill {
  height: 100%;
  background: linear-gradient(90deg, var(--app-primary, $app-primary), var(--app-accent, $app-primary-light));
  border-radius: 4rpx;
  transition: width 0.15s;
}

.track-actions {
  display: flex;
  gap: 8rpx;
}

.action-btn {
  width: 52rpx;
  height: 52rpx;
  border-radius: 16rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--app-subtle, $uni-bg-color-grey);
  transition: all 0.16s;

  &:active {
    transform: scale(0.88);
  }

  &.muted {
    background: color-mix(in srgb, var(--app-danger, #C4706B) 14%, transparent);
  }
}
</style>