<template>
  <view class="page-container">
    <view class="page-bg"></view>

    <!-- 自定义悬浮 TabBar -->
    <TabBar current="discover" />

    <!-- ① 品牌头部（与首页 / 场景页统一） -->
    <view class="header">
      <view class="header-top">
        <view class="brand">
          <view class="brand-logo-wrap">
            <image class="brand-logo" src="/static/logo-v10-1.jpg" mode="aspectFit" />
          </view>
          <view class="brand-text">
            <text class="app-title">声栖</text>
            <text class="app-slogan">今天想探索什么？</text>
          </view>
        </view>
        <view class="header-actions">
          <view class="header-btn app-card" @click="goTheme">
            <Icon name="palette" :size="22" color="var(--app-primary)" />
          </view>
          <view class="header-btn app-card" @click="goLibrary">
            <Icon name="wave" :size="22" color="var(--app-primary)" />
          </view>
        </view>
      </view>
    </view>

    <!-- ② 卡片 A：今日推荐 -->
    <view class="group-card app-card">
      <view class="card-head">
        <Icon name="flame" :size="16" color="var(--app-primary)" />
        <text class="card-title">今日推荐</text>
      </view>
      <view class="hero-row" @click="goDetail(hero)">
        <view class="hero-cover" :style="{ background: hero.gradient }">
          <Icon :name="hero.iconName" :size="72" color="rgba(255,255,255,.95)" />
          <view class="hero-plays-badge">
            <Icon name="play" :size="12" color="var(--app-primary)" />
            <text class="hero-plays-text">{{ hero.playCount }}</text>
          </view>
        </view>
        <view class="hero-info">
          <view class="hero-main">
            <text class="hero-name">{{ hero.name }}</text>
            <text class="hero-desc">{{ hero.desc }}</text>
            <view class="hero-chips">
              <view class="chip" v-for="(s, i) in heroSoundNames" :key="i">
                <Icon name="play" :size="14" color="var(--app-primary)" />
                <text class="chip-text">{{ s }}</text>
              </view>
            </view>
          </view>
          <view class="hero-btn" @click.stop="playScene(hero)">
            <text>立即体验</text>
            <Icon name="chevron-right" :size="16" color="#fff" />
          </view>
        </view>
      </view>
    </view>

    <!-- ③ 卡片 B：场景推荐 -->
    <view class="group-card app-card">
      <view class="tag-filter">
        <view
          class="tag-item"
          :class="{ active: activeTag === tag.id }"
          v-for="tag in tags"
          :key="tag.id"
          @click="activeTag = tag.id"
        >
          <Icon :name="tag.icon" :size="14" :color="activeTag === tag.id ? 'var(--app-primary)' : 'var(--app-text-2)'" />
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
          v-for="scene in filteredFeatured"
          :key="scene.id"
          :name="scene.name"
          :sound-count="scene.soundIds.length"
          :sound-icons="[scene.iconName]"
          :bg-color="scene.gradient"
          :is-preset="true"
          :sound-label="soundNames(scene.soundIds)"
          :active="player.currentScene?.id === scene.id"
          layout="grid"
          @tap="goDetail(scene)"
          @play="playScene(scene)"
        />
      </view>
      <view class="scene-empty" v-if="filteredFeatured.length === 0">
        <text>暂无此类场景</text>
      </view>
    </view>

    <!-- ④ 卡片 C：声音精选 -->
    <view class="group-card app-card">
      <view class="card-head">
        <Icon name="white-noise" :size="16" color="var(--app-primary)" />
        <text class="card-title">声音精选</text>
      </view>
      <scroll-view scroll-x class="featured-scroll" :show-scrollbar="false">
        <view class="featured-list">
          <view
            class="featured-item"
            v-for="sound in featuredSounds"
            :key="sound.id"
            @click="addSound(sound)"
          >
            <view class="featured-icon" :style="{ background: sound.color }">
              <Icon :name="sound.iconName" :size="34" color="#fff" />
            </view>
            <text class="featured-name">{{ sound.name }}</text>
            <text class="featured-heat">热度 {{ sound.hot }}</text>
          </view>
        </view>
      </scroll-view>
    </view>

    <!-- ⑤ 卡片 D：场景故事 -->
    <view class="group-card app-card">
      <view class="card-head">
        <Icon name="moon" :size="16" color="var(--app-primary)" />
        <text class="card-title">场景故事</text>
      </view>
      <view class="story-item" v-for="story in stories" :key="story.id" @click="goDetailOf(story)">
        <view class="story-icon" :style="{ background: story.gradient }">
          <Icon :name="story.iconName" :size="28" color="#fff" />
        </view>
        <view class="story-body">
          <text class="story-title">{{ story.title }}</text>
          <text class="story-text">{{ story.text }}</text>
          <view class="story-scene-row">
            <Icon name="wave" :size="14" color="var(--app-primary)" />
            <text class="story-scene">{{ story.scene }}</text>
          </view>
        </view>
        <Icon name="chevron-right" :size="18" color="var(--app-text-3)" />
      </view>
    </view>

    <!-- 底部播放栏 -->
    <PlayBar @save-tap="onSaveTap" />
  </view>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import Icon from '@/components/Icon.vue'
import TabBar from '@/components/TabBar.vue'
import PlayBar from '@/components/PlayBar.vue'
import SceneCard from '@/components/SceneCard.vue'
import { player, applyScene } from '@/composables/usePlayer'
import { soundNames, findScene } from '@/data/scenes'
import type { Scene } from '@/data/scenes'
import { featuredScenes, featuredSounds, sounds as allSounds } from '@/data/sounds'

// 今日推荐：取精选场景首位
const hero = featuredScenes[0]

// 声音组合 chips：由 soundIds 映射为声音名
const heroSoundNames = computed(() =>
  (hero.soundIds || []).map((id) => allSounds.find((s) => s.id === id)?.name || id)
)

// 场景推荐：分类标签 + 按分类过滤（本地 8 个精选场景的归类映射）
const activeTag = ref('all')
const tags = [
  { id: 'all', label: '全部', icon: 'wave' },
  { id: 'sleep', label: '助眠', icon: 'moon' },
  { id: 'focus', label: '专注', icon: 'flame' },
  { id: 'relax', label: '放松', icon: 'forest' },
  { id: 'nature', label: '自然', icon: 'mountain' },
]

const CATEGORY_MAP: Record<string, string> = {
  'deep-sleep': 'sleep',
  'focus-white-noise': 'focus',
  'nature-relax': 'nature',
  'urban-afternoon': 'focus',
  'rainy-night': 'sleep',
  'forest-meditation': 'relax',
  'seaside-sunset': 'relax',
  'coffee-time': 'focus',
}

const filteredFeatured = computed(() => {
  const rest = featuredScenes.filter((s) => s.id !== hero.id)
  if (activeTag.value === 'all') return rest
  return rest.filter((s) => CATEGORY_MAP[s.id] === activeTag.value)
})

// 精选场景 → 播放器所需 Scene（补全 category / isPreset，均视为预设）
const toScene = (f: (typeof featuredScenes)[number]): Scene => ({
  id: f.id,
  name: f.name,
  category: (CATEGORY_MAP[f.id] ?? 'relax') as Scene['category'],
  desc: f.desc,
  iconName: f.iconName,
  gradient: f.gradient,
  image: findScene(f.id)?.image ?? '',
  soundIds: f.soundIds,
  isPreset: true,
})

// 场景故事（纯文案 + 关联场景跳转）
const stories = [
  {
    id: 'st1',
    title: '雨夜书桌',
    text: '城市夜晚，雨滴敲打窗棂，世界安静下来，只有翻书声与雨声相伴',
    scene: '雨夜入眠',
    sceneId: 'rainy-night',
    iconName: 'rain',
    gradient: 'linear-gradient(135deg,#5F7A92,#B97A48)',
  },
  {
    id: 'st2',
    title: '海边初醒',
    text: '清晨的海风裹着潮声，把梦一点点吹散，你在晨光里慢慢清醒',
    scene: '海边日落',
    sceneId: 'seaside-sunset',
    iconName: 'wave-ocean',
    gradient: 'linear-gradient(135deg,#4E7182,#8E9E96)',
  },
  {
    id: 'st3',
    title: '林中漫步',
    text: '踩过松软的落叶，溪水在不远处低语，整个世界只剩下自然的呼吸',
    scene: '自然放松',
    sceneId: 'nature-relax',
    iconName: 'forest',
    gradient: 'linear-gradient(135deg,#5F8296,#7E9A74)',
  },
]

// 导航
const goDetail = (scene: { id: string }) =>
  uni.navigateTo({ url: `/pages/scene-detail/scene-detail?sceneId=${scene.id}` })
const goDetailOf = (story: { sceneId?: string; title: string }) => {
  if (story.sceneId) goDetail({ id: story.sceneId })
  else uni.showToast({ title: story.title, icon: 'none' })
}
const goLibrary = () => uni.navigateTo({ url: '/pages/library/library' })
const goTheme = () => uni.navigateTo({ url: '/pages/theme/theme' })
const goAllScenes = () => uni.navigateTo({ url: '/pages/scene-all/scene-all' })

// 播放：接入共享播放状态，直接在本页切换
const playScene = (scene: { id: string }) => {
  const target = featuredScenes.find((s) => s.id === scene.id)
  if (!target) return
  applyScene(toScene(target))
  uni.showToast({ title: `已开始播放「${target.name}」`, icon: 'none' })
}

const addSound = (sound: { name: string }) =>
  uni.showToast({ title: `${sound.name} 已加入混音`, icon: 'success' })

const onSaveTap = () =>
  uni.showToast({ title: '可在首页保存为场景', icon: 'none' })
</script>

<style lang="scss" scoped>
.page-container {
  padding-bottom: calc(220rpx + env(safe-area-inset-bottom));
}

/* ① 品牌头部（与首页 / 场景页统一） */
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
  box-shadow: 0 8rpx 22rpx color-mix(in srgb, var(--app-primary, $app-primary) 22%, transparent);
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
  color: var(--app-text, $uni-text-color);
  letter-spacing: 4rpx;
  line-height: 1.1;
}

.app-slogan {
  font-size: 22rpx;
  color: var(--app-text-2, $uni-text-color-grey);
  letter-spacing: 1rpx;
}

.header-actions {
  display: flex;
  gap: 16rpx;
}

.header-btn {
  width: 68rpx;
  height: 68rpx;
  border-radius: 22rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: transform 0.16s cubic-bezier(.4, 0, .2, 1);

  &:active {
    transform: scale(0.9);
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
  color: var(--app-text-2, $uni-text-color-grey);
}

/* ③ 今日推荐（浅色横排卡片） */
.hero-row {
  display: flex;
  gap: 20rpx;
  align-items: center;
  transition: all 0.16s cubic-bezier(.4, 0, .2, 1);

  &:active {
    transform: scale(0.99);
  }
}

.hero-cover {
  width: 196rpx;
  height: 196rpx;
  border-radius: 26rpx;
  flex-shrink: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  box-shadow: inset 0 -2rpx 0 rgba(0, 0, 0, 0.08), inset 0 2rpx 0 rgba(255, 255, 255, 0.25);
}

.hero-plays-badge {
  position: absolute;
  left: 12rpx;
  bottom: 12rpx;
  display: flex;
  align-items: center;
  gap: 6rpx;
  padding: 6rpx 16rpx;
  border-radius: 20rpx;
  background: rgba(255, 255, 255, 0.92);
}

.hero-plays-text {
  font-size: 20rpx;
  color: var(--app-primary, $app-primary);
  font-weight: 700;
}

.hero-info {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  align-self: stretch;
  padding: 4rpx 0;
}

.hero-main {
  display: flex;
  flex-direction: column;
  gap: 10rpx;
}

.hero-name {
  font-size: 34rpx;
  font-weight: 700;
  color: var(--app-text, $uni-text-color);
  letter-spacing: -0.3rpx;
}

.hero-desc {
  font-size: 22rpx;
  color: var(--app-text-2, $uni-text-color-grey);
  line-height: 1.5;
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 2;
  overflow: hidden;
}

.hero-chips {
  display: flex;
  flex-wrap: wrap;
  gap: 8rpx;
}

.chip {
  display: inline-flex;
  align-items: center;
  gap: 4rpx;
  padding: 6rpx 14rpx;
  border-radius: 16rpx;
  background: var(--app-primary-soft, rgba($app-primary, 0.1));
}

.chip-text {
  font-size: 20rpx;
  color: var(--app-primary, $app-primary);
  font-weight: 600;
}

.hero-btn {
  align-self: flex-start;
  display: inline-flex;
  align-items: center;
  gap: 4rpx;
  padding: 14rpx 26rpx;
  border-radius: 30rpx;
  background: linear-gradient(135deg, var(--app-primary, $app-primary), var(--app-primary-dark, $app-primary-dark));
  color: #fff;
  font-size: 24rpx;
  font-weight: 700;
  margin-top: 12rpx;
  box-shadow: 0 8rpx 20rpx color-mix(in srgb, var(--app-primary, $app-primary) 30%, transparent);
  transition: all 0.16s cubic-bezier(.4, 0, .2, 1);

  &:active {
    transform: scale(0.94);
  }

  text {
    color: #fff;
  }
}

/* ③ 场景推荐 */
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

.section-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 18rpx;
  padding-left: 2rpx;
}

.section-head .card-head {
  margin-bottom: 0;
}

.more-btn {
  display: flex;
  align-items: center;
  gap: 2rpx;
  padding: 8rpx 12rpx;
  transition: transform .16s;

  &:active {
    transform: scale(.9);
  }
}

.more-text {
  font-size: 23rpx;
  color: var(--app-text-2, $uni-text-color-grey);
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

.scene-empty {
  padding: 60rpx 32rpx;
  text-align: center;
  font-size: 25rpx;
  color: var(--app-text-2, $uni-text-color-grey);
}

/* ④ 声音精选（横向滚动） */
.featured-scroll {
  white-space: nowrap;
  width: 100%;
}

.featured-list {
  display: inline-flex;
  gap: 16rpx;
  padding-bottom: 8rpx;
}

.featured-item {
  width: 150rpx;
  padding: 22rpx 14rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12rpx;
  background: var(--app-subtle, $uni-bg-color-grey);
  border-radius: 26rpx;
  transition: all 0.16s cubic-bezier(.4, 0, .2, 1);

  &:active {
    transform: scale(0.94);
  }
}

.featured-icon {
  width: 96rpx;
  height: 96rpx;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: inset 0 -2rpx 0 rgba(0, 0, 0, 0.08), inset 0 2rpx 0 rgba(255, 255, 255, 0.25), 0 6rpx 14rpx rgba(0, 0, 0, 0.1);
}

.featured-name {
  font-size: 24rpx;
  font-weight: 600;
  color: var(--app-text, $uni-text-color);
  max-width: 100%;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.featured-heat {
  font-size: 20rpx;
  color: var(--app-text-2, $uni-text-color-grey);
}

/* ⑤ 场景故事 */
.story-item {
  display: flex;
  align-items: center;
  gap: 20rpx;
  padding: 20rpx 0;
  border-bottom: 1rpx solid var(--app-divider, rgba($app-primary, 0.08));
  transition: all 0.16s cubic-bezier(.4, 0, .2, 1);

  &:last-child {
    border-bottom: none;
    padding-bottom: 4rpx;
  }

  &:active {
    transform: scale(0.99);
  }
}

.story-icon {
  width: 88rpx;
  height: 88rpx;
  border-radius: 26rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.story-body {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 8rpx;
}

.story-title {
  font-size: 28rpx;
  font-weight: 700;
  color: var(--app-text, $uni-text-color);
}

.story-text {
  font-size: 23rpx;
  color: var(--app-text-2, $uni-text-color-grey);
  line-height: 1.6;
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 2;
  overflow: hidden;
}

.story-scene-row {
  display: flex;
  align-items: center;
  gap: 8rpx;
  margin-top: 2rpx;
}

.story-scene {
  font-size: 21rpx;
  color: var(--app-primary, $app-primary);
  font-weight: 500;
}
</style>