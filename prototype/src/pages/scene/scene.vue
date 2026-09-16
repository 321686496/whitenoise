<template>
  <view class="page-container">
    <view class="page-bg"></view>

    <!-- 自定义悬浮 TabBar -->
    <TabBar current="scene" />

    <!-- ① 品牌头部 + 问候（含偏好胶囊） -->
    <view class="header">
      <view class="header-top">
        <view class="brand">
          <view class="brand-logo-wrap">
            <image class="brand-logo" src="/static/logo-v10-1.jpg" mode="aspectFit" />
          </view>
          <view class="brand-text">
            <text class="app-title">声栖</text>
            <view class="greeting-row">
              <text class="greeting-text">今晚想听什么？</text>
              <view class="pref-chip" v-for="p in prefLabels" :key="p">
                <Icon name="flame" :size="12" color="var(--app-primary)" />
                <text class="pref-chip-text">{{ p }}</text>
              </view>
            </view>
          </view>
        </view>
        <view class="header-actions">
          <view class="header-btn app-card" @click="createScene">
            <Icon name="mixer" :size="22" color="var(--app-primary)" />
          </view>
          <view class="header-btn app-card" @click="goTheme">
            <Icon name="palette" :size="22" color="var(--app-primary)" />
          </view>
        </view>
      </view>
    </view>

    <!-- ② 卡片 A：为你推荐 + 最近播放 -->
    <view class="group-card app-card">
      <view class="card-head">
        <Icon name="flame" :size="16" color="var(--app-primary)" />
        <text class="card-title">为你推荐</text>
      </view>
      <scroll-view scroll-x class="rec-scroll" :show-scrollbar="false">
        <view class="rec-row">
          <view class="rec-card" v-for="s in recommended" :key="s.id" @click="openDetail(s)">
            <view class="rec-cover" :style="coverOf(s)">
              <Icon :name="s.iconName" :size="40" color="var(--app-on-cover-soft)" />
              <view class="rec-reason">
                <Icon name="flame" :size="12" color="var(--app-primary)" />
                <text class="rec-reason-text">常听偏好</text>
              </view>
            </view>
            <text class="rec-name">{{ s.name }}</text>
            <text class="rec-desc">{{ s.desc }}</text>
          </view>
        </view>
      </scroll-view>

      <view class="recent-block" v-if="recentItems.length > 0">
        <view class="divider"></view>
        <view class="card-head">
          <Icon name="clock" :size="16" color="var(--app-primary)" />
          <text class="card-title">最近播放</text>
        </view>
        <scroll-view scroll-x class="recent-scroll" :show-scrollbar="false">
          <view class="recent-row">
            <view class="recent-card" v-for="r in recentItems" :key="r.sceneId" @click="openDetail(r)">
              <view class="recent-cover" :style="coverOfSceneId(r.sceneId)">
                <Icon :name="r.iconName" :size="34" color="var(--app-on-cover-soft)" />
              </view>
              <text class="recent-name">{{ r.name }}</text>
              <text class="recent-time">{{ recentTimeLabel(r.ts) }}</text>
            </view>
          </view>
        </scroll-view>
      </view>
    </view>

    <!-- ③ 卡片 B：分类分段 + 精选场景 -->
    <view class="group-card app-card">
      <view class="tag-filter">
        <view
          class="tag-item"
          :class="{ active: activeTag === tag.key }"
          v-for="tag in sceneCategories"
          :key="tag.key"
          @click="activeTag = tag.key"
        >
          <Icon :name="tag.icon" :size="14" :color="activeTag === tag.key ? 'var(--app-primary)' : 'var(--app-text-2)'" />
          <text>{{ tag.label }}</text>
        </view>
      </view>
      <view class="section-head">
        <view class="card-head">
          <Icon name="mountain" :size="16" color="var(--app-primary)" />
          <text class="card-title">精选场景</text>
        </view>
        <view class="more-btn" @click="goAllScenes">
          <text class="more-text">查看全部</text>
          <Icon name="chevron-right" :size="14" color="var(--app-text-2)" />
        </view>
      </view>
      <view class="featured-grid">
        <SceneCard
          v-for="scene in featuredScenes"
          :key="scene.id"
          :name="scene.name"
          :sound-count="scene.soundIds.length"
          :sound-icons="presetSoundIcons(scene)"
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

    <!-- ④ 卡片 C：我的场景 -->
    <view class="group-card app-card">
      <view class="section-head">
        <view class="card-head">
          <Icon name="mixer" :size="16" color="var(--app-primary)" />
          <text class="card-title">我的场景</text>
        </view>
        <view class="new-btn app-card" @click="createScene">
          <Icon name="mixer" :size="16" color="var(--app-primary)" />
          <text class="new-btn-text">新建</text>
        </view>
      </view>
      <SceneCard
        v-for="scene in myScenes"
        :key="scene.id"
        :name="scene.name"
        :sound-count="scene.soundCount"
        :sound-icons="scene.soundIcons"
        :bg-color="scene.bgColor"
        :is-preset="false"
        @tap="editScene(scene)"
        @share="shareScene(scene)"
        @play="playMyScene(scene)"
      />
      <view class="empty-scene" v-if="myScenes.length === 0">
        <view class="empty-icon">
          <Icon name="mountain" :size="52" color="var(--app-primary)" />
        </view>
        <text class="empty-text">还没有自定义场景</text>
        <text class="empty-hint">点击右上角「新建」即可创建，或在首页混音后保存</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import SceneCard from '@/components/SceneCard.vue'
import Icon from '@/components/Icon.vue'
import TabBar from '@/components/TabBar.vue'
import { player, applyScene, getRecent, recentTimeLabel } from '@/composables/usePlayer'
import { SIMULATED_PREFS, getRecommended, getCategoryScenes, findScene, sceneCategories } from '@/data/scenes'
import type { Scene } from '@/data/scenes'
import { sounds } from '@/data/sounds'

interface MyScene {
  id: string
  name: string
  soundCount: number
  soundIcons: string[]
  bgColor: string
}

/* 分类单一来源：data/scenes.ts 的 sceneCategories（v2 收敛，页内不再重复定义） */
const activeTag = ref<string>('all')

const prefLabels = computed(() => {
  const map: Record<string, string> = { sleep: '助眠', focus: '专注', relax: '放松', nature: '自然' }
  return SIMULATED_PREFS.map((c) => map[c] ?? c)
})

const recommended = ref(getRecommended(SIMULATED_PREFS, getRecent()))
const recentItems = ref(getRecent())

const featuredScenes = computed(() =>
  getCategoryScenes(activeTag.value as Scene['category'] | 'all', 3),
)

// 首页金刚区快捷入口直达分类 + 重读最近播放
onShow(() => {
  recentItems.value = getRecent()
  recommended.value = getRecommended(SIMULATED_PREFS, recentItems.value)
  if (player.pendingSceneCategory && player.pendingSceneCategory !== 'all') {
    activeTag.value = player.pendingSceneCategory
    player.pendingSceneCategory = 'all'
  }
})

const presetSoundIcons = (scene: Scene) =>
  scene.soundIds.map((id) => sounds.find((s) => s.id === id)?.iconName ?? 'wave')

// 封面样式：优先素材图，回退渐变占位
const coverStyle = (bg: string, img?: string) => ({
  background: bg,
  backgroundImage: img ? `url(${img})` : undefined,
  backgroundSize: 'cover',
  backgroundPosition: 'center',
})

const coverOf = (s: Scene) => coverStyle(s.gradient, s.image)

// 最近播放项只有 sceneId，回查场景取素材；取不到则退回记录的渐变
const coverOfSceneId = (sceneId: string) => {
  const s = findScene(sceneId)
  const r = recentItems.value.find((x) => x.sceneId === sceneId)
  return coverStyle(s?.gradient ?? r?.gradient ?? 'var(--app-surface-2)', s?.image)
}

// 支持 Scene（id）与 RecentItem（sceneId）两种来源
const openDetail = (scene: { id?: string; sceneId?: string }) => {
  uni.navigateTo({ url: `/pages/scene-detail/scene-detail?sceneId=${scene.id ?? scene.sceneId}` })
}

const playScene = (scene: Scene) => {
  applyScene(scene)
  uni.showToast({ title: '已开始播放', icon: 'success' })
  setTimeout(() => uni.switchTab({ url: '/pages/index/index' }), 800)
}

const goAllScenes = () => uni.navigateTo({ url: '/pages/scene-all/scene-all' })

const goTheme = () => uni.navigateTo({ url: '/pages/theme/theme' })

const myScenes = ref<MyScene[]>([
  { id: 'm1', name: '雨天阅读', soundCount: 3, soundIcons: ['rain', 'fire', 'coffee'], bgColor: 'linear-gradient(135deg,#8E82A6,#6E6290)' },
  { id: 'm2', name: '冥想时刻', soundCount: 2, soundIcons: ['stream', 'forest'], bgColor: 'linear-gradient(135deg,#7F9AA6,#5F7A86)' },
])

const createScene = () => {
  uni.navigateTo({ url: '/pages/scene-edit/scene-edit?sceneId=new' })
}

const editScene = (scene: { id: string; name: string }) => {
  uni.navigateTo({ url: `/pages/scene-edit/scene-edit?sceneId=${scene.id}` })
}

const shareScene = (scene: { name: string }) => {
  uni.showToast({ title: '已生成分享卡片', icon: 'success' })
}

// 我的场景播放：仅演示提示，不写共享播放状态
const playMyScene = (scene: { name: string }) => {
  uni.showToast({ title: `已应用「${scene.name}」`, icon: 'success' })
  setTimeout(() => uni.switchTab({ url: '/pages/index/index' }), 800)
}
</script>

<style lang="scss" scoped>
/* ① 品牌头部（与首页 index.vue 同款） */
.header {
  padding: 16rpx 4rpx 20rpx;
}

.header-top {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.brand {
  display: flex;
  align-items: center;
  gap: 20rpx;
}

.brand-logo-wrap {
  width: 84rpx;
  height: 84rpx;
  border-radius: 24rpx;
  overflow: hidden;
  box-shadow: 0 8rpx 22rpx color-mix(in srgb, var(--app-primary) 22%, transparent);
}

.brand-logo {
  width: 100%;
  height: 100%;
}

.brand-text {
  display: flex;
  flex-direction: column;
  gap: 6rpx;
}

.app-title {
  font-size: 46rpx;
  font-weight: 800;
  color: var(--app-text);
  letter-spacing: 4rpx;
  line-height: 1.1;
}

.greeting-row {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 8rpx;
}

.greeting-text {
  font-size: 22rpx;
  color: var(--app-text-2);
  letter-spacing: 1rpx;
}

.pref-chip {
  display: inline-flex;
  align-items: center;
  gap: 4rpx;
  padding: 4rpx 14rpx;
  border-radius: 18rpx;
  background: var(--app-primary-soft);
}

.pref-chip-text {
  font-size: 20rpx;
  color: var(--app-primary);
  font-weight: 600;
}

.header-actions {
  display: flex;
  gap: 16rpx;
}

/* v2：触控 88rpx 达标，按压缩放统一 scale(.96) */
.header-btn {
  width: 88rpx;
  height: 88rpx;
  border-radius: 28rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: transform var(--dur-fast) var(--ease-std);

  &:active {
    transform: scale(0.96);
  }
}

/* ② 分组卡片 */
.group-card {
  padding: 24rpx;
  margin-bottom: 24rpx;
}

.card-head {
  display: flex;
  align-items: center;
  gap: 10rpx;
  margin-bottom: 18rpx;
}

.card-title {
  font-size: 25rpx;
  font-weight: 600;
  letter-spacing: 0.3rpx;
  color: var(--app-text-2);
}

.divider {
  height: 1rpx;
  background: var(--app-line);
  margin: 6rpx 0 20rpx;
}

.recent-block {
  margin-top: 2rpx;
}

/* ③ 为你推荐横滑（卡片 A 内） */
.rec-scroll,
.recent-scroll {
  white-space: nowrap;
}

.rec-row,
.recent-row {
  display: inline-flex;
  gap: 20rpx;
  padding: 4rpx 4rpx 8rpx;
}

.rec-card {
  width: 240rpx;
  flex-shrink: 0;
  transition: transform var(--dur-fast) var(--ease-std);

  &:active {
    transform: scale(.96);
  }
}

.rec-cover {
  height: 140rpx;
  border-radius: 16rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  margin-bottom: 12rpx;
}

/* 图上浮层徽章：on-cover 白经 color-mix 半透明 + 毛玻璃（glass 取向） */
.rec-reason {
  position: absolute;
  left: 10rpx;
  bottom: 10rpx;
  display: flex;
  align-items: center;
  gap: 4rpx;
  padding: 4rpx 12rpx;
  border-radius: 18rpx;
  background: color-mix(in srgb, var(--app-on-cover) 90%, transparent);
  backdrop-filter: blur(6rpx);
  -webkit-backdrop-filter: blur(6rpx);
}

.rec-reason-text {
  font-size: 20rpx;
  color: var(--app-primary);
  font-weight: 600;
}

.rec-name {
  font-size: 27rpx;
  font-weight: 600;
  color: var(--app-text);
  display: block;
}

.rec-desc {
  font-size: 22rpx;
  color: var(--app-text-2);
  display: block;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

/* ④ 最近播放横滑（卡片 A 内） */
.recent-card {
  width: 180rpx;
  flex-shrink: 0;
  transition: transform var(--dur-fast) var(--ease-std);

  &:active {
    transform: scale(.96);
  }
}

.recent-cover {
  height: 110rpx;
  border-radius: 16rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 10rpx;
}

.recent-name {
  font-size: 25rpx;
  font-weight: 600;
  color: var(--app-text);
  display: block;
}

.recent-time {
  font-size: 21rpx;
  color: var(--app-text-2);
}

/* ⑤ 分类分段（卡片 B 内） */
.tag-filter {
  display: flex;
  gap: 12rpx;
  padding: 8rpx 0;
  margin-bottom: 8rpx;
  overflow-x: auto;
}

/* v2 chip：surface 底 + 发丝描边 + 选中主色软底；触控高度 ≥88rpx */
.tag-item {
  display: flex;
  align-items: center;
  gap: 8rpx;
  min-height: 88rpx;
  padding: 0 28rpx;
  border-radius: 999rpx;
  font-size: 24rpx;
  font-weight: 500;
  color: var(--app-text-2);
  background: var(--app-surface);
  border: 1rpx solid var(--app-line);
  box-shadow: var(--app-shadow-1), var(--app-inset);
  transition: all var(--dur-fast) var(--ease-std);
  flex-shrink: 0;

  &.active {
    background: var(--app-primary-soft);
    border-color: color-mix(in srgb, var(--app-primary) 30%, transparent);
    color: var(--app-primary);
    font-weight: 600;
  }

  &:active {
    transform: scale(0.96);
  }
}

/* ⑥ 精选场景（卡片 B 内） */
.section-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 18rpx;
  padding-left: 2rpx;
}

.featured-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 16rpx;

  .scene-card {
    width: calc(50% - 8rpx);
    margin-bottom: 0;
    box-sizing: border-box;
  }
}

.more-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 88rpx;
  gap: 2rpx;
  padding: 8rpx 12rpx;
  transition: transform var(--dur-fast) var(--ease-std);

  &:active {
    transform: scale(.96);
  }
}

.more-text {
  font-size: 23rpx;
  color: var(--app-text-2);
}

/* ⑦ 我的场景（卡片 C 内） */
.new-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 88rpx;
  gap: 8rpx;
  padding: 10rpx 24rpx;
  border-radius: 30rpx;
  transition: all var(--dur-fast) var(--ease-std);

  &:active {
    transform: scale(0.96);
  }
}

.new-btn-text {
  font-size: 23rpx;
  color: var(--app-primary);
  font-weight: 600;
}

.empty-scene {
  padding: 48rpx 24rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12rpx;
}

.empty-icon {
  width: 104rpx;
  height: 104rpx;
  border-radius: 32rpx;
  background: var(--app-primary-soft);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 6rpx;
}

.empty-text {
  font-size: 28rpx;
  color: var(--app-text);
  font-weight: 600;
}

.empty-hint {
  font-size: 23rpx;
  color: var(--app-text-2);
}
</style>
