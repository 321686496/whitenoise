<template>
  <view
    class="scene-card app-card"
    :class="[`scene-card--${layout}`, { 'scene-card--active': active }]"
    @click="$emit('tap')"
  >
    <view class="scene-cover" :style="coverStyle">
      <!-- 横排布局：封面内叠声音图标 -->
      <view class="scene-sounds" v-if="layout === 'row'">
        <view class="sound-chip" v-for="(s, i) in soundIcons" :key="i">
          <Icon :name="s" :size="20" color="rgba(255,255,255,.95)" />
        </view>
      </view>
      <!-- 网格布局：封面主图标 -->
      <view class="cover-icon" v-else>
        <Icon :name="soundIcons[0] || 'wave'" :size="44" color="rgba(255,255,255,.95)" />
      </view>
      <!-- 网格布局：播放按钮悬浮封面右上 -->
      <view class="scene-cover-actions" v-if="layout === 'grid'" @click.stop>
        <view class="scene-action-btn play" :class="{ playing: active }" @click="$emit('play')">
          <Icon :name="active ? 'pause' : 'play'" :size="20" color="var(--app-on-primary)" />
        </view>
      </view>
    </view>

    <view class="scene-body">
      <view class="scene-header">
        <text class="scene-name">{{ name }}</text>
        <view class="scene-tag" v-if="isPreset">
          <text>预设</text>
        </view>
      </view>
      <text class="scene-desc">{{ soundLabel || `${soundCount} 种声音组合` }}</text>
    </view>

    <view class="scene-actions" v-if="layout === 'row'" @click.stop>
      <view class="scene-action-btn" v-if="!isPreset" @click="$emit('share')">
        <Icon name="share" :size="20" color="var(--app-text-3)" />
      </view>
      <view class="scene-action-btn play" :class="{ playing: active }" @click="$emit('play')">
        <Icon :name="active ? 'pause' : 'play'" :size="20" color="var(--app-on-primary)" />
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import Icon from './Icon.vue'

const props = withDefaults(defineProps<{
  name: string
  soundCount: number
  soundIcons: string[]
  bgColor: string
  cover?: string
  isPreset: boolean
  layout?: 'row' | 'grid'
  active?: boolean
  soundLabel?: string
}>(), {
  layout: 'row',
  active: false,
  soundLabel: '',
  cover: '',
})

const coverStyle = computed(() => ({
  background: props.bgColor,
  backgroundImage: props.cover ? `url(${props.cover})` : undefined,
  backgroundSize: 'cover',
  backgroundPosition: 'center',
}))

defineEmits<{
  tap: []
  share: []
  play: []
}>()
</script>

<style lang="scss" scoped>
.scene-card {
  border-radius: 26rpx;
  overflow: hidden;
  margin-bottom: 20rpx;
  transition: all 0.2s;

  &:active {
    transform: scale(0.985);
  }

  &--active {
    border-color: color-mix(in srgb, var(--app-primary, $app-primary) 70%, transparent);
    box-shadow: 0 10rpx 24rpx color-mix(in srgb, var(--app-primary, $app-primary) 16%, transparent);
  }

  /* 横排（场景页） */
  &--row {
    display: flex;
  }
}

.scene-cover {
  position: relative;
  flex-shrink: 0;
  box-shadow: inset -1rpx 0 0 rgba(255, 255, 255, .08);
  display: flex;
  align-items: center;
  justify-content: center;
}

.scene-card--row .scene-cover {
  width: 150rpx;
  min-height: 150rpx;
}

/* 网格：封面置顶全宽 */
.scene-card--grid {
  display: flex;
  flex-direction: column;

  .scene-cover {
    width: 100%;
    height: 150rpx;
    box-shadow: inset 0 -1rpx 0 rgba(0, 0, 0, .06);
  }

  .scene-body {
    padding: 20rpx;
    gap: 6rpx;
  }

  .scene-name {
    font-size: 27rpx;
  }

  .scene-desc {
    font-size: 22rpx;
  }
}

.scene-sounds {
  display: flex;
  gap: 10rpx;
}

.sound-chip {
  width: 44rpx;
  height: 44rpx;
  border-radius: 14rpx;
  background: rgba(255, 255, 255, .22);
  backdrop-filter: blur(6rpx);
  box-shadow: inset 0 -1rpx 0 rgba(0, 0, 0, .06);
  display: flex;
  align-items: center;
  justify-content: center;
}

.cover-icon {
  width: 88rpx;
  height: 88rpx;
  border-radius: 26rpx;
  background: rgba(255, 255, 255, .18);
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: inset 0 1rpx 0 rgba(255, 255, 255, .35);
}

/* 网格下播放按钮悬浮封面右上 */
.scene-cover-actions {
  position: absolute;
  top: 14rpx;
  right: 14rpx;
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
  font-size: 30rpx;
  color: var(--app-text, $uni-text-color);
  font-weight: 600;
  letter-spacing: -0.4rpx;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.scene-tag {
  font-size: 20rpx;
  padding: 4rpx 14rpx;
  border-radius: 20rpx;
  background: var(--app-primary-soft, rgba($app-morandi-green, 0.2));
  color: var(--app-primary, $app-primary);
  flex-shrink: 0;
}

.scene-desc {
  font-size: 24rpx;
  color: var(--app-text-2, $uni-text-color-grey);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.scene-actions {
  display: flex;
  flex-direction: column;
  gap: 14rpx;
  padding: 24rpx 24rpx 24rpx 0;
  justify-content: center;
}

.scene-action-btn {
  width: 58rpx;
  height: 58rpx;
  border-radius: 18rpx;
  background: var(--app-subtle, $uni-bg-color-grey);
  display: flex;
  align-items: center;
  justify-content: center;
  transition: transform 0.16s;

  &:active {
    transform: scale(0.88);
  }

  &.play {
    background: linear-gradient(135deg, var(--app-primary, $app-primary), var(--app-primary-dark, $app-primary-dark));
    box-shadow: 0 8rpx 18rpx color-mix(in srgb, var(--app-primary, $app-primary) 32%, transparent);
  }

  &.playing {
    box-shadow: inset 0 3rpx 8rpx rgba(0, 0, 0, .18);
  }
}
</style>
