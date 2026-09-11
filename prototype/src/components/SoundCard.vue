<template>
  <view class="sound-card app-card" :class="{ active: isActive }" @click="$emit('tap')">
    <view class="sound-icon" :style="{ background: color }">
      <Icon :name="iconName" :size="30" color="#fff" />
    </view>
    <view class="sound-name-wrap">
      <text class="sound-name">{{ name }}</text>
      <!-- 选中角标 -->
      <view class="sound-check" v-if="isActive">
        <Icon name="check" :size="14" color="#fff" />
      </view>
    </view>
    <text class="sound-type">{{ type }}</text>
  </view>
</template>

<script setup lang="ts">
import Icon from './Icon.vue'

defineProps<{
  name: string
  type: string
  iconName: string
  color: string
  isActive: boolean
}>()

defineEmits<{
  tap: []
}>()
</script>

<style lang="scss" scoped>
.sound-card {
  width: 164rpx;
  padding: 26rpx 18rpx 22rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 14rpx;
  transition: transform 0.16s cubic-bezier(.4,0,.2,1), background 0.2s;
  border: 1rpx solid var(--app-card-border, $uni-border-color);
  position: relative;
  border-radius: 26rpx;
  transform: translateZ(0);

  &.active {
    border-color: color-mix(in srgb, var(--app-primary, $app-primary) 70%, transparent);
    background: var(--app-primary-soft, rgba($app-primary, 0.08));
    box-shadow: 0 10rpx 24rpx color-mix(in srgb, var(--app-primary, $app-primary) 16%, transparent);
  }

  &:active {
    transform: scale(0.94);
  }
}

/* iOS 拟物方形图标磁贴 */
.sound-icon {
  width: 80rpx;
  height: 80rpx;
  border-radius: 22rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: inset 0 -2rpx 0 rgba(0,0,0,.08), inset 0 2rpx 0 rgba(255,255,255,.25), 0 6rpx 14rpx rgba(0,0,0,.10);
}

.sound-name-wrap {
  display: flex;
  align-items: center;
  gap: 6rpx;
  max-width: 100%;
}

.sound-name {
  font-size: 25rpx;
  color: var(--app-text, $uni-text-color);
  font-weight: 600;
  letter-spacing: -0.3rpx;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  max-width: 100%;
}

.sound-check {
  width: 26rpx;
  height: 26rpx;
  border-radius: 50%;
  background: var(--app-primary, $app-primary);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.sound-type {
  font-size: 21rpx;
  color: var(--app-text-3, $uni-text-color-grey);
}
</style>