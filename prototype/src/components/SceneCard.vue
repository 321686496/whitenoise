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
          <Icon :name="s" :size="20" color="var(--app-on-cover)" />
        </view>
      </view>
      <!-- 网格布局：封面主图标 -->
      <view class="cover-icon" v-else>
        <Icon :name="soundIcons[0] || 'wave'" :size="44" color="var(--app-on-cover)" />
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
  overflow: hidden;
  margin-bottom: 20rpx;
  transition: transform var(--dur-fast) var(--ease-std), border-color var(--dur-fast) var(--ease-std), box-shadow var(--dur-fast) var(--ease-std);

  &:active {
    transform: scale(0.96);
  }

  &--active {
    border-color: color-mix(in srgb, var(--app-primary) 70%, transparent);
    box-shadow: var(--app-shadow-2), var(--app-inset), 0 0 0 2rpx color-mix(in srgb, var(--app-primary) 24%, transparent);
  }

  /* 横排（场景页） */
  &--row {
    display: flex;
  }
}

.scene-cover {
  position: relative;
  flex-shrink: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}

/* list（row）形态：封面 160×120（4:3），贴左缘由卡片裁圆角 */
.scene-card--row .scene-cover {
  width: 160rpx;
  min-height: 120rpx;
  align-self: stretch;
  box-shadow: inset -1rpx 0 0 var(--app-line);
}

/* 网格形态：封面全宽 4:3、圆角 32rpx，内嵌于卡片留白中 */
.scene-card--grid {
  display: flex;
  flex-direction: column;
  padding: 12rpx;

  .scene-cover {
    width: 100%;
    aspect-ratio: 4 / 3;
    border-radius: 32rpx;
  }

  .scene-body {
    padding: 16rpx 12rpx 12rpx;
    gap: 6rpx;
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
  background: color-mix(in srgb, var(--app-on-cover) 22%, transparent);
  backdrop-filter: blur(6rpx);
  -webkit-backdrop-filter: blur(6rpx);
  box-shadow: inset 0 -1rpx 0 var(--app-press);
  display: flex;
  align-items: center;
  justify-content: center;
}

.cover-icon {
  width: 88rpx;
  height: 88rpx;
  border-radius: 26rpx;
  background: color-mix(in srgb, var(--app-on-cover) 18%, transparent);
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: inset 0 1rpx 0 color-mix(in srgb, var(--app-on-cover) 35%, transparent);
}

/* 网格下播放按钮悬浮封面右上 */
.scene-cover-actions {
  position: absolute;
  top: 12rpx;
  right: 12rpx;
}

.scene-body {
  flex: 1;
  padding: 24rpx;
  display: flex;
  flex-direction: column;
  justify-content: center;
  gap: 8rpx;
  min-width: 0;
}

.scene-header {
  display: flex;
  align-items: flex-start;
  gap: 12rpx;
}

/* v2 标题规格：30rpx/600/1.3，两行截断 */
.scene-name {
  font-size: 30rpx;
  color: var(--app-text);
  font-weight: 600;
  line-height: 1.3;
  letter-spacing: -0.4rpx;
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 2;
  overflow: hidden;
  flex: 1;
  min-width: 0;
}

.scene-tag {
  font-size: 20rpx;
  padding: 4rpx 14rpx;
  border-radius: 999rpx;
  background: var(--app-primary-soft);
  color: var(--app-primary);
  flex-shrink: 0;
}

.scene-desc {
  font-size: 24rpx;
  color: var(--app-text-2);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.scene-actions {
  display: flex;
  flex-direction: column;
  gap: 20rpx;
  padding: 0 16rpx 0 0;
  justify-content: center;
}

/* 视觉 64rpx，::after 外扩热区至 88rpx 触控达标 */
.scene-action-btn {
  position: relative;
  width: 64rpx;
  height: 64rpx;
  border-radius: 999rpx;
  background: var(--app-surface-2);
  display: flex;
  align-items: center;
  justify-content: center;
  transition: transform var(--dur-fast) var(--ease-std);

  &::after {
    content: '';
    position: absolute;
    inset: -12rpx;
  }

  &:active {
    transform: scale(0.96);
  }

  &.play {
    background: linear-gradient(135deg, var(--app-primary), var(--app-primary-strong));
    box-shadow: var(--app-shadow-2);
  }

  &.playing {
    box-shadow: inset 0 3rpx 8rpx color-mix(in srgb, var(--app-text) 22%, transparent);
  }
}
</style>
