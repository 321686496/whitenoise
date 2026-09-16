<template>
  <!-- v2：自定义导航（pages.json 已改 custom），NavBar 自带安全区，容器顶距归零 -->
  <view class="page-container scene-all-page">
    <view class="page-bg"></view>

    <NavBar title="全部场景" />

    <view class="filter-head">
      <Segmented :options="catOptions" v-model="activeTag" />
    </view>

    <view class="scene-grid">
      <SceneCard
        v-for="scene in filteredScenes"
        :key="scene.id"
        :name="scene.name"
        :sound-count="scene.soundIds.length"
        :sound-icons="soundIconsOf(scene)"
        :bg-color="scene.gradient"
        :cover="scene.image"
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
import NavBar from '@/components/NavBar.vue'
import Segmented from '@/components/Segmented.vue'
import SceneCard from '@/components/SceneCard.vue'
import { sceneCategories, homeScenes } from '@/data/scenes'
import type { Scene, SceneCategory } from '@/data/scenes'
import { sounds } from '@/data/sounds'
import { player, applyScene } from '@/composables/usePlayer'

/* 分类单一来源：data/scenes.ts 的 sceneCategories（与首页场景流一致） */
const catOptions = computed(() => sceneCategories.map((c) => ({ key: c.key, label: c.label })))
const activeTag = ref('all')

const filteredScenes = computed(() => {
  if (activeTag.value === 'all') return homeScenes
  return homeScenes.filter((s) => s.category === (activeTag.value as SceneCategory))
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
/* NavBar 自带 env(safe-area-inset-top)，去掉容器重复的安全区顶距，仅留少量余白 */
.scene-all-page {
  padding-top: 12rpx;
}

.filter-head {
  margin-bottom: 24rpx;
}

/* v2 双列网格：grid + box-sizing 兜底，避免 H5 双列变单列 */
.scene-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 24rpx;
  box-sizing: border-box;

  :deep(.scene-card) {
    margin-bottom: 0;
    box-sizing: border-box;
  }
}
</style>
