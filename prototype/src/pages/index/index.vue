<template>
  <view class="page-container">
    <view class="page-bg"></view>

    <!-- 自定义悬浮 TabBar（首页不渲染 PlayBar：与主控卡互斥） -->
    <TabBar current="index" />

    <!-- ① 品牌行 -->
    <BrandBar />

    <!-- ⑧ Banners 分发位 -->
    <BannerCarousel :banners="banners" @action="onBannerAction" />

    <!-- ② 主控卡（黄金位） -->
    <NowPlayingCard />

    <!-- ③ 场景流 -->
    <view class="flow">
      <!-- 一键播快捷 chip -->
      <view class="chip-row">
        <view
          class="quick-chip"
          v-for="chip in quickChips"
          :key="chip.scene.id"
          @click="quickPlay(chip.scene)"
        >
          <Icon :name="chip.icon" :size="18" color="var(--app-primary)" />
          <text class="quick-chip-label">{{ chip.scene.name }}</text>
        </view>
      </view>

      <!-- 分类 + 网格 -->
      <view class="flow-head">
        <text class="section-title">场景</text>
        <text class="flow-more" @click="goSceneFlow">更多</text>
      </view>
      <Segmented :options="catOptions" v-model="activeCat" />

      <view class="scene-grid" v-if="gridScenes.length > 0">
        <SceneCard
          v-for="scene in gridScenes"
          :key="scene.id"
          :name="scene.name"
          :sound-count="scene.soundIds.length"
          :sound-icons="[scene.iconName]"
          :bg-color="scene.gradient"
          :cover="scene.image"
          :is-preset="scene.isPreset"
          :active="player.currentScene?.id === scene.id"
          layout="grid"
          @tap="openDetail(scene)"
          @play="playScene(scene)"
        />
      </view>
      <view class="scene-empty app-card" v-else>
        <text>暂无此类场景</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { onShow, onHide } from '@dcloudio/uni-app'
import BannerCarousel from '@/components/BannerCarousel.vue'
import BrandBar from '@/components/BrandBar.vue'
import NowPlayingCard from '@/components/NowPlayingCard.vue'
import Segmented from '@/components/Segmented.vue'
import SceneCard from '@/components/SceneCard.vue'
import TabBar from '@/components/TabBar.vue'
import Icon from '@/components/Icon.vue'
import { player, applyScene, togglePlay, getRecent } from '@/composables/usePlayer'
import { sceneCategories, getCategoryScenes, findScene } from '@/data/scenes'
import { buildBanners } from '@/data/banners'
import type { Banner, BannerAction } from '@/data/banners'
import type { Scene, SceneCategory } from '@/data/scenes'

/* ③ 场景流 —— 一键播 chip：优先按场景 id 解析，缺失时回退对应分类首条 */
interface QuickChip {
  scene: Scene
  icon: string
}

const quickChipDefs: { id: string; fallback: SceneCategory; icon: string }[] = [
  { id: 'deep-sleep', fallback: 'sleep', icon: 'moon' },
  { id: 'focus-white-noise', fallback: 'focus', icon: 'white-noise' },
  { id: 'forest-stream', fallback: 'nature', icon: 'stream' },
]

const quickChips: QuickChip[] = quickChipDefs
  .map((d) => {
    const scene = findScene(d.id) ?? getCategoryScenes(d.fallback, 1)[0]
    return scene ? { scene, icon: d.icon } : null
  })
  .filter((c): c is QuickChip => c !== null)

const quickPlay = (scene: Scene) => {
  applyScene(scene)
}

/* 分类胶囊：数据源 sceneCategories 单一来源（Task 7 前无 icon 字段，仅用 label） */
const catOptions = computed(() => sceneCategories.map((c) => ({ key: c.key, label: c.label })))
const activeCat = ref('all')

/* 网格数据用 ref 承载（tab 缓存页不重跑 setup，v1 约定）：onShow + 分类切换时刷新 */
const gridScenes = ref<Scene[]>(getCategoryScenes('all', 20))

function refreshGrid() {
  gridScenes.value = getCategoryScenes(activeCat.value as SceneCategory | 'all', 20)
}

watch(activeCat, refreshGrid)
onShow(refreshGrid)
/* 状态防泄漏：离开首页（含 tab 切换 / navigateTo）时收起主控卡混音 Sheet，
   避免 player.showMixPanel 残留导致 PlayBar 页面（发现页等）面板无端弹出 */
onHide(() => { player.showMixPanel = false })

/* 卡片交互：tap 进详情，play 按钮播放/暂停当前 */
const openDetail = (scene: Scene) => {
  uni.navigateTo({ url: `/pages/scene-detail/scene-detail?sceneId=${scene.id}` })
}

const playScene = (scene: Scene) => {
  if (player.currentScene?.id === scene.id) {
    togglePlay()
  } else {
    applyScene(scene)
  }
}

/* 「更多」：带当前分类跳场景页（保留 v1 pendingSceneCategory 交接流程） */
const goSceneFlow = () => {
  player.pendingSceneCategory = activeCat.value
  uni.switchTab({ url: '/pages/scene/scene' })
}

/* ⑧ Banners 分发位：运营 + 时段精选 + 个性化 + 最近状态 */
const preference: SceneCategory[] = ['sleep', 'nature'] // 与 getRecommended 偏好一致
const banners = ref<Banner[]>([])

function refreshBanners() {
  const hour = new Date().getHours()
  banners.value = buildBanners({
    hour,
    recent: getRecent().map((r) => ({ sceneId: r.sceneId, name: r.name })),
    preference,
  })
}
onShow(refreshBanners)

function onBannerAction(a: BannerAction) {
  if (a.kind === 'play') {
    const s = findScene(a.sceneId)
    if (s) applyScene(s)
  } else {
    uni.navigateTo({ url: a.url })
  }
}
</script>

<style lang="scss" scoped>
/* ③ 场景流 */
.flow {
  margin-top: 40rpx;
}

.chip-row {
  display: flex;
  gap: 16rpx;
  margin-bottom: 36rpx;
}

.quick-chip {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10rpx;
  min-height: 88rpx;
  padding: 0 28rpx;
  border-radius: 999rpx;
  background: var(--app-surface);
  border: 1rpx solid var(--app-line);
  box-shadow: var(--app-shadow-1), var(--app-inset);
  transition: transform var(--dur-fast) var(--ease-std);

  &:active {
    transform: scale(0.96);
  }
}

.quick-chip-label {
  font-size: 26rpx;
  font-weight: 600;
  color: var(--app-text);
  letter-spacing: -0.2rpx;
}

.flow-head {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  margin-bottom: 16rpx;
  padding: 0 8rpx;

  .section-title {
    margin-bottom: 0;
  }
}

.flow-more {
  font-size: 24rpx;
  font-weight: 500;
  color: var(--app-primary);
}

.scene-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 24rpx;
  margin-top: 28rpx;
  box-sizing: border-box;

  :deep(.scene-card) {
    margin-bottom: 0;
    box-sizing: border-box;
  }
}

.scene-empty {
  margin-top: 28rpx;
  padding: 60rpx 32rpx;
  text-align: center;
  font-size: 25rpx;
  color: var(--app-text-2);
}
</style>
