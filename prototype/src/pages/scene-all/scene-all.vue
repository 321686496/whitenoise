<template>
  <view class="page-container">
    <view class="page-bg"></view>
    <view class="header">
      <text class="page-title">全部场景</text>
      <text class="page-subtitle">浏览全部官方预设场景</text>
    </view>

    <view class="tag-filter">
      <view
        class="tag-item"
        :class="{ active: activeTag === tag.key }"
        v-for="tag in sceneCategories"
        :key="tag.key"
        @click="activeTag = tag.key"
      >
        <text>{{ tag.label }}</text>
      </view>
    </view>

    <view class="scene-grid">
      <SceneCard
        v-for="scene in filteredScenes"
        :key="scene.id"
        :name="scene.name"
        :sound-count="scene.soundIds.length"
        :sound-icons="soundIconsOf(scene)"
        :bg-color="scene.gradient"
        :is-preset="scene.isPreset"
        layout="grid"
        :active="player.currentScene?.id === scene.id"
        @tap="openDetail(scene)"
        @play="playScene(scene)"
      />
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import SceneCard from '@/components/SceneCard.vue'
import { sceneCategories, homeScenes } from '@/data/scenes'
import type { Scene } from '@/data/scenes'
import { sounds } from '@/data/sounds'
import { player, applyScene } from '@/composables/usePlayer'

const activeTag = ref('all')

const filteredScenes = computed(() => {
  if (activeTag.value === 'all') return homeScenes
  return homeScenes.filter((s) => s.category === activeTag.value)
})

const soundIconsOf = (scene: Scene) =>
  scene.soundIds.map((id) => sounds.find((s) => s.id === id)?.iconName ?? 'wave')

const openDetail = (scene: { id: string }) => {
  uni.navigateTo({ url: `/pages/scene-detail/scene-detail?sceneId=${scene.id}` })
}

const playScene = (scene: Scene) => {
  applyScene(scene)
  uni.showToast({ title: '已开始播放', icon: 'success' })
  setTimeout(() => uni.switchTab({ url: '/pages/index/index' }), 800)
}
</script>

<style lang="scss" scoped>
.header {
  padding: 16rpx 4rpx 8rpx;
}

.page-title {
  font-size: 46rpx;
}

.page-subtitle {
  font-size: 24rpx;
  color: var(--app-text-2, $uni-text-color-grey);
  margin-top: 10rpx;
  display: block;
}

/* 分类 Tab */
.tag-filter {
  display: flex;
  gap: 12rpx;
  padding: 8rpx 0;
  margin-bottom: 8rpx;
  overflow-x: auto;
}

.tag-item {
  display: flex;
  align-items: center;
  gap: 8rpx;
  padding: 12rpx 24rpx;
  border-radius: 28rpx;
  font-size: 24rpx;
  font-weight: 500;
  color: var(--app-text-2, $uni-text-color-grey);
  background: var(--app-subtle, $uni-bg-color-grey);
  transition: all 0.16s cubic-bezier(.4, 0, .2, 1);
  flex-shrink: 0;

  &.active {
    background: var(--app-primary-soft, rgba($app-primary, 0.1));
    color: var(--app-primary, $app-primary);
    font-weight: 600;
  }

  &:active {
    transform: scale(0.94);
  }
}

/* 全部场景双列网格 */
.scene-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 16rpx;
  .scene-card {
    width: calc(50% - 8rpx);
    margin-bottom: 0;
    box-sizing: border-box;
  }
}
</style>
