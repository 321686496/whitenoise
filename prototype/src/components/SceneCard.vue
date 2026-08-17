<template>
  <view class="scene-card" @click="$emit('tap')">
    <view class="scene-cover" :style="{ background: bgColor }">
      <view class="scene-sounds">
        <text class="scene-sound-icon" v-for="(s, i) in soundIcons" :key="i">{{ s }}</text>
      </view>
    </view>
    <view class="scene-body">
      <view class="scene-header">
        <text class="scene-name">{{ name }}</text>
        <view class="scene-tag" v-if="isPreset">
          <text>预设</text>
        </view>
      </view>
      <text class="scene-desc">{{ soundCount }} 种声音组合</text>
    </view>
    <view class="scene-actions" @click.stop>
      <view class="scene-action-btn" v-if="!isPreset" @click="$emit('share')">
        <text>📤</text>
      </view>
      <view class="scene-action-btn" @click="$emit('play')">
        <text>▶️</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
defineProps<{
  name: string
  soundCount: number
  soundIcons: string[]
  bgColor: string
  isPreset: boolean
}>()

defineEmits<{
  tap: []
  share: []
  play: []
}>()
</script>

<style lang="scss" scoped>
.scene-card {
  background: $app-card-bg;
  border-radius: $app-radius;
  box-shadow: $app-shadow;
  overflow: hidden;
  margin-bottom: 20rpx;
  display: flex;
  transition: all 0.2s;

  &:active {
    transform: scale(0.98);
  }
}

.scene-cover {
  width: 140rpx;
  min-height: 140rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.scene-sounds {
  display: flex;
  gap: 8rpx;
}

.scene-sound-icon {
  font-size: 36rpx;
}

.scene-body {
  flex: 1;
  padding: 24rpx;
  display: flex;
  flex-direction: column;
  justify-content: center;
  gap: 8rpx;
}

.scene-header {
  display: flex;
  align-items: center;
  gap: 12rpx;
}

.scene-name {
  font-size: 28rpx;
  color: $uni-text-color;
  font-weight: 600;
}

.scene-tag {
  font-size: 20rpx;
  padding: 4rpx 12rpx;
  border-radius: 20rpx;
  background: rgba($app-morandi-blue, 0.2);
  color: $app-primary;
}

.scene-desc {
  font-size: 24rpx;
  color: $uni-text-color-grey;
}

.scene-actions {
  display: flex;
  flex-direction: column;
  gap: 12rpx;
  padding: 24rpx 24rpx 24rpx 0;
  justify-content: center;
}

.scene-action-btn {
  width: 56rpx;
  height: 56rpx;
  border-radius: 50%;
  background: $uni-bg-color-grey;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24rpx;

  &:active {
    transform: scale(0.9);
  }
}
</style>