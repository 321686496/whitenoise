<template>
  <view class="sound-card app-card" :class="{ active: isActive }" @click="$emit('tap')">
    <view class="sound-icon" :style="{ '--sound-color': color }">
      <Icon :name="iconName" :size="30" color="var(--sound-color)" />
    </view>
    <view class="sound-name-wrap">
      <text class="sound-name">{{ name }}</text>
      <!-- 选中角标 -->
      <view class="sound-check" v-if="isActive">
        <Icon name="check" :size="14" color="var(--app-on-primary)" />
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
  transition: transform var(--dur-fast) var(--ease-std), background var(--dur-fast) var(--ease-std), border-color var(--dur-fast) var(--ease-std);
  border: 1rpx solid var(--app-line);
  position: relative;
  border-radius: 26rpx;
  transform: translateZ(0);

  &.active {
    border-color: color-mix(in srgb, var(--app-primary) 70%, transparent);
    background: var(--app-primary-soft);
    box-shadow: var(--app-shadow-2), var(--app-inset);
  }

  &:active {
    transform: scale(0.96);
  }
}

/* v2：圆形色底，声音资产色经 --sound-color 注入，color-mix 与表面色融合 */
.sound-icon {
  width: 112rpx;
  height: 112rpx;
  border-radius: 999rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  background: color-mix(in srgb, var(--sound-color) 16%, var(--app-surface));
  color: var(--sound-color);
  box-shadow: var(--app-shadow-1), var(--app-inset);
}

.sound-name-wrap {
  display: flex;
  align-items: center;
  gap: 6rpx;
  max-width: 100%;
}

.sound-name {
  font-size: 25rpx;
  color: var(--app-text);
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
  background: var(--app-primary);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.sound-type {
  font-size: 21rpx;
  color: var(--app-text-3);
}
</style>

<style lang="scss">
/* 深色模式提亮色底，避免暗底发灰（非 scoped：`--sound-color` 由内联样式注入在同一元素上） */
:root[data-mode='dark'] .sound-card .sound-icon {
  background: color-mix(in srgb, var(--sound-color) 22%, var(--app-surface));
}
</style>
