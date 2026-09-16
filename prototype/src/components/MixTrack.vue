<template>
  <view class="mix-track app-card">
    <view class="track-info">
      <view class="track-icon" :style="{ '--sound-color': color }">
        <Icon :name="iconName" :size="22" color="var(--sound-color)" />
      </view>
      <view class="track-meta">
        <text class="track-name">{{ name }}</text>
        <text class="track-volume-label">{{ volume }}%</text>
      </view>
    </view>
    <view class="track-controls">
      <view class="volume-slider" @touchmove="onSlide" @touchstart="onSlide" @click="onSlide">
        <view class="slider-groove">
          <view class="slider-fill" :style="{ width: volume + '%' }">
            <view class="slider-knob"></view>
          </view>
        </view>
      </view>
      <view class="track-actions">
        <view class="action-btn" :class="{ muted: isMuted }" @click="$emit('mute')">
          <Icon :name="isMuted ? 'mute' : 'volume'" :size="17" :color="isMuted ? 'var(--app-danger)' : 'var(--app-text-3)'" />
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

const onSlide = (_e: unknown) => {
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
  margin-bottom: 8rpx;
}

/* v2：色底图标与 SoundCard 同源（color-mix 资产色 × 表面色） */
.track-icon {
  width: 64rpx;
  height: 64rpx;
  border-radius: 999rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  background: color-mix(in srgb, var(--sound-color) 16%, var(--app-surface));
  color: var(--sound-color);
}

.track-meta {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: space-between;
  min-width: 0;
}

.track-name {
  font-size: 28rpx;
  color: var(--app-text);
  font-weight: 600;
  letter-spacing: -0.3rpx;
}

.track-volume-label {
  font-size: 24rpx;
  color: var(--app-primary);
  font-weight: 700;
}

.track-controls {
  display: flex;
  align-items: center;
  gap: 8rpx;
}

/* 滑轨整行触控高 88rpx（44px），6rpx 细槽垂直居中 */
.volume-slider {
  flex: 1;
  height: 88rpx;
  display: flex;
  align-items: center;
}

.slider-groove {
  height: 6rpx;
  width: 100%;
  background: var(--app-sunken);
  border-radius: 999rpx;
  position: relative;
}

.slider-fill {
  height: 100%;
  background: var(--app-primary);
  border-radius: 999rpx;
  position: relative;
  transition: width var(--dur-fast) var(--ease-std);
}

.slider-knob {
  position: absolute;
  right: -14rpx;
  top: 50%;
  transform: translateY(-50%);
  width: 28rpx;
  height: 28rpx;
  border-radius: 999rpx;
  background: var(--app-surface);
  box-shadow: var(--app-shadow-1), var(--app-inset);
}

.track-actions {
  display: flex;
  gap: 4rpx;
}

.action-btn {
  width: 88rpx;
  height: 88rpx;
  border-radius: 999rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: transform var(--dur-fast) var(--ease-std), background var(--dur-fast) var(--ease-std);

  &:active {
    transform: scale(0.96);
    background: var(--app-press);
  }

  &.muted {
    background: var(--app-danger-soft);
  }
}
</style>
