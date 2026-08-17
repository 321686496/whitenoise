<template>
  <view class="play-bar" :class="{ playing: isPlaying }">
    <view class="play-bar-inner">
      <view class="play-info" @click="$emit('sceneTap')">
        <view class="play-wave">
          <view class="wave-bar" v-for="i in 4" :key="i" :class="{ active: isPlaying }"></view>
        </view>
        <view class="play-meta">
          <text class="play-scene">{{ currentScene || '未选择场景' }}</text>
          <text class="play-timer" v-if="timerRemaining">{{ timerRemaining }}</text>
        </view>
      </view>
      <view class="play-actions">
        <view class="play-btn timer-btn" @click="$emit('timerTap')">
          <text>⏱</text>
        </view>
        <view class="play-btn main-btn" :class="{ active: isPlaying }" @click="$emit('playTap')">
          <text>{{ isPlaying ? '⏸' : '▶️' }}</text>
        </view>
        <view class="play-btn save-btn" @click="$emit('saveTap')">
          <text>💾</text>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
defineProps<{
  isPlaying: boolean
  currentScene: string
  timerRemaining: string
}>()

defineEmits<{
  playTap: []
  timerTap: []
  saveTap: []
  sceneTap: []
}>()
</script>

<style lang="scss" scoped>
.play-bar {
  position: fixed;
  bottom: $app-tab-height;
  left: 0;
  right: 0;
  z-index: 100;
  padding: 0 24rpx 16rpx;
  padding-bottom: calc(16rpx + constant(safe-area-inset-bottom));
  padding-bottom: calc(16rpx + env(safe-area-inset-bottom));
}

.play-bar-inner {
  height: $app-playbar-height;
  background: $app-card-bg;
  border-radius: $app-radius;
  box-shadow: 0 -4rpx 24rpx rgba(92, 111, 128, 0.1);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 32rpx;
}

.play-info {
  display: flex;
  align-items: center;
  gap: 20rpx;
  flex: 1;
}

.play-wave {
  display: flex;
  align-items: flex-end;
  gap: 4rpx;
  height: 40rpx;
}

.wave-bar {
  width: 6rpx;
  background: $uni-border-color;
  border-radius: 3rpx;
  transition: all 0.3s;

  &:nth-child(1) { height: 16rpx; }
  &:nth-child(2) { height: 28rpx; }
  &:nth-child(3) { height: 20rpx; }
  &:nth-child(4) { height: 24rpx; }

  &.active {
    background: $app-primary;
    animation: wave 1.2s ease-in-out infinite;

    &:nth-child(1) { animation-delay: 0s; }
    &:nth-child(2) { animation-delay: 0.2s; }
    &:nth-child(3) { animation-delay: 0.4s; }
    &:nth-child(4) { animation-delay: 0.6s; }
  }
}

@keyframes wave {
  0%, 100% { transform: scaleY(0.5); }
  50% { transform: scaleY(1.5); }
}

.play-meta {
  display: flex;
  flex-direction: column;
  gap: 4rpx;
}

.play-scene {
  font-size: 26rpx;
  color: $uni-text-color;
  font-weight: 500;
}

.play-timer {
  font-size: 22rpx;
  color: $app-primary;
  font-weight: 600;
}

.play-actions {
  display: flex;
  align-items: center;
  gap: 16rpx;
}

.play-btn {
  width: 64rpx;
  height: 64rpx;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28rpx;
  background: $uni-bg-color-grey;
  transition: all 0.2s;

  &:active {
    transform: scale(0.9);
  }
}

.main-btn {
  width: 80rpx;
  height: 80rpx;
  background: $app-primary;
  font-size: 32rpx;

  &.active {
    background: $app-primary;
    box-shadow: 0 4rpx 16rpx rgba($app-primary, 0.4);
  }

  &:active {
    background: $app-primary-dark;
  }
}
</style>