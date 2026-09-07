<template>
  <view class="page-container">
    <view class="page-bg"></view>

    <!-- 自定义悬浮 TabBar -->
    <TabBar current="index" />

    <!-- ① 品牌头部 -->
    <view class="header">
      <view class="header-top">
        <view class="brand">
          <view class="brand-logo-wrap">
            <image class="brand-logo" src="/static/logo-v10-1.jpg" mode="aspectFit" />
          </view>
          <view class="brand-text">
            <text class="app-title">声栖</text>
            <text class="app-slogan">{{ greetingText }}</text>
          </view>
        </view>
        <view class="header-actions">
          <view class="header-btn app-card" @click="goTheme">
            <Icon name="palette" :size="22" color="var(--app-primary)" />
          </view>
          <view class="header-btn app-card" @click="goAchievement">
            <Icon name="trophy" :size="22" color="var(--app-primary)" />
          </view>
        </view>
      </view>
    </view>

    <!-- ② 大播放卡（首屏黄金位） -->
    <view class="hero app-card" :style="{ background: heroBg }" @click="onHeroTap">
      <template v-if="player.tracks.length > 0">
        <view class="hero-top">
          <text class="hero-scene">{{ player.currentScene?.name || '即兴混音' }}</text>
          <view class="hero-count">
            <text>{{ player.tracks.length }}/6 路</text>
          </view>
        </view>
        <view class="hero-main">
          <view class="hero-bars" :class="{ playing: player.isPlaying }">
            <view class="hero-bar" v-for="i in 5" :key="i"></view>
          </view>
          <view class="hero-play" @click.stop="onMainPlay">
            <Icon :name="player.isPlaying ? 'pause' : 'play'" :size="36" color="var(--app-primary)" />
          </view>
        </view>
        <view class="hero-actions">
          <view class="hero-action" @click.stop="player.showTimerPanel = true">
            <Icon name="timer" :size="26" color="rgba(255,255,255,.92)" />
            <text class="hero-action-text">定时</text>
          </view>
          <view class="hero-action" @click.stop="showSaveDialog = true">
            <Icon name="save" :size="26" color="rgba(255,255,255,.92)" />
            <text class="hero-action-text">保存场景</text>
          </view>
        </view>
      </template>
      <template v-else>
        <view class="hero-empty">
          <view class="hero-empty-icon">
            <Icon name="moon" :size="46" color="rgba(255,255,255,.95)" />
          </view>
          <text class="hero-empty-title">开始你的助眠之旅</text>
          <text class="hero-empty-sub">点选下方场景，即刻开播</text>
        </view>
      </template>
    </view>

    <!-- ③ 金刚区 2×2 -->
    <view class="quick-grid">
      <view
        class="quick-item app-card"
        v-for="q in quickActions"
        :key="q.id"
        @click="onQuick(q)"
      >
        <view class="quick-icon" :style="{ background: q.bg }">
          <Icon :name="q.icon" :size="28" color="#fff" />
        </view>
        <view class="quick-meta">
          <text class="quick-name">{{ q.name }}</text>
          <text class="quick-desc">{{ q.desc }}</text>
        </view>
      </view>
    </view>

    <!-- ④ 今日精选 -->
    <view class="section">
      <view class="section-header">
        <text class="section-title">今日精选</text>
        <text class="section-more" @click="randomPlay">换一批</text>
      </view>
      <scroll-view scroll-x class="pick-scroll" :show-scrollbar="false">
        <view class="pick-list">
          <view
            class="pick-card"
            v-for="scene in todayPicks"
            :key="scene.id"
            :style="{ background: scene.gradient }"
            @click="playScene(scene)"
          >
            <view class="pick-tag"><text>今日精选</text></view>
            <text class="pick-title">{{ scene.name }}</text>
            <text class="pick-desc">{{ scene.desc }}</text>
            <view class="pick-bottom">
              <text class="pick-combo">{{ soundNames(scene.soundIds) }}</text>
              <view class="pick-play">
                <Icon name="play" :size="18" color="var(--app-on-primary)" />
              </view>
            </view>
          </view>
        </view>
      </scroll-view>
    </view>

    <!-- ⑤ 场景推荐 -->
    <view class="section">
      <view class="section-header">
        <text class="section-title">场景推荐</text>
      </view>
      <view class="category-tabs">
        <view
          v-for="cat in sceneCategories"
          :key="cat.key"
          class="cat-tab"
          :class="{ active: activeCategory === cat.key }"
          @click="activeCategory = cat.key"
        >
          <text>{{ cat.label }}</text>
        </view>
      </view>

      <view class="scene-grid" v-if="filteredScenes.length > 0">
        <SceneCard
          v-for="scene in filteredScenes"
          :key="scene.id"
          :name="scene.name"
          :sound-count="scene.soundIds.length"
          :sound-icons="[scene.iconName]"
          :bg-color="scene.gradient"
          :is-preset="scene.isPreset"
          :sound-label="soundNames(scene.soundIds)"
          :active="player.currentScene?.id === scene.id"
          layout="grid"
          @tap="playScene(scene)"
          @play="playScene(scene)"
        />
      </view>
      <view class="scene-empty app-card" v-else>
        <text>暂无此类场景</text>
      </view>
    </view>

    <!-- ⑥ 最近使用 -->
    <view class="section" v-if="recentItems.length > 0">
      <view class="section-header">
        <text class="section-title">最近使用</text>
        <text class="section-more" @click="goHistory">查看全部</text>
      </view>
      <scroll-view scroll-x class="recent-scroll" :show-scrollbar="false">
        <view class="recent-list">
          <view class="recent-item app-card" v-for="item in recentItems" :key="item.sceneId" @click="playRecent(item)">
            <view class="recent-icon" :style="{ background: item.gradient }">
              <Icon :name="item.iconName" :size="20" color="#fff" />
            </view>
            <text class="recent-name">{{ item.name }}</text>
            <text class="recent-time">{{ recentTimeLabel(item.ts) }}</text>
          </view>
        </view>
      </scroll-view>
    </view>

    <!-- ⑦ 声音库入口 -->
    <view class="section">
      <view class="library-entry app-card" @click="goLibrary">
        <view class="library-icon">
          <Icon name="mixer" :size="26" color="var(--app-primary)" />
        </view>
        <view class="library-meta">
          <text class="library-name">声音库</text>
          <text class="library-desc">{{ soundCountLabel }}种白噪音，自由混音</text>
        </view>
        <Icon name="chevron-right" :size="22" color="var(--app-text-3)" />
      </view>
    </view>

    <!-- 底部播放栏 -->
    <PlayBar @save-tap="showSaveDialog = true" />

    <!-- 保存场景弹窗 -->
    <view class="modal-overlay" v-if="showSaveDialog" @click="showSaveDialog = false">
      <view class="modal-content app-card" @click.stop>
        <text class="modal-title">保存为场景</text>
        <input
          class="modal-input"
          v-model="saveName"
          placeholder="输入场景名称"
          maxlength="20"
        />
        <view class="modal-actions">
          <view class="btn-outline" @click="showSaveDialog = false">取消</view>
          <view class="btn-primary" @click="saveScene">保存</view>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import SceneCard from '@/components/SceneCard.vue'
import PlayBar from '@/components/PlayBar.vue'
import TabBar from '@/components/TabBar.vue'
import Icon from '@/components/Icon.vue'
import { player, applyScene, togglePlay, getRecent, recentTimeLabel } from '@/composables/usePlayer'
import { homeScenes, sceneCategories, findScene, soundNames } from '@/data/scenes'
import { sounds } from '@/data/sounds'

const greetingText = computed(() => {
  const h = new Date().getHours()
  if (h >= 6 && h < 10) return '早安，新的一天开始了'
  if (h >= 10 && h < 14) return '午安，享受片刻宁静'
  if (h >= 14 && h < 18) return '下午好，放松一下吧'
  if (h >= 18 && h < 22) return '晚上好，让声音陪伴你'
  return '夜深了，安心入眠吧'
})

/* ② 大播放卡 */
const heroBg = computed(() => {
  return player.currentScene?.gradient || 'linear-gradient(135deg, var(--app-primary), var(--app-primary-dark))'
})

const onHeroTap = () => {
  if (player.tracks.length === 0) {
    uni.showToast({ title: '请先选择场景', icon: 'none' })
  } else {
    player.showMixPanel = true
  }
}

const onMainPlay = () => {
  if (!togglePlay()) {
    uni.showToast({ title: '请先选择场景', icon: 'none' })
  }
}

/* ③ 金刚区 */
const quickActions = [
  { id: 'sleep', name: '开始助眠', desc: '一键深度睡眠', icon: 'moon', bg: 'linear-gradient(135deg, #7E93A8, #4E7182)' },
  { id: 'focus', name: '专注时刻', desc: '纯净白噪音', icon: 'flame', bg: 'linear-gradient(135deg, #8296A8, #C49A92)' },
  { id: 'nature', name: '自然放松', desc: '林间溪流', icon: 'forest', bg: 'linear-gradient(135deg, #5F8296, #7E9A74)' },
  { id: 'checkin', name: '每日签到', desc: '连续打卡领好礼', icon: 'gift', bg: 'linear-gradient(135deg, #B98A4E, #CFA878)' },
]

const onQuick = (q: { id: string }) => {
  if (q.id === 'sleep') {
    const scene = findScene('deep-sleep')
    if (scene) applyScene(scene)
  } else if (q.id === 'focus') {
    const scene = findScene('focus-white-noise')
    if (scene) applyScene(scene)
  } else if (q.id === 'nature') {
    player.pendingSceneCategory = 'nature'
    uni.switchTab({ url: '/pages/scene/scene' })
  } else if (q.id === 'checkin') {
    uni.navigateTo({ url: '/pages/checkin/checkin' })
  }
}

/* ④ 今日精选 */
const todayPicks = computed(() => {
  return ['rainy-night', 'focus-white-noise']
    .map((id) => findScene(id))
    .filter((s): s is NonNullable<typeof s> => !!s)
})

const randomPlay = () => {
  const scene = homeScenes[Math.floor(Math.random() * homeScenes.length)]
  applyScene(scene)
  uni.showToast({ title: `已为你播放「${scene.name}」`, icon: 'none' })
}

/* ⑤ 场景推荐 */
const activeCategory = ref('all')
const filteredScenes = computed(() => {
  if (activeCategory.value === 'all') return homeScenes
  return homeScenes.filter((s) => s.category === activeCategory.value)
})

const playScene = (scene: { id: string }) => {
  if (player.currentScene?.id === scene.id) {
    togglePlay()
  } else {
    const target = homeScenes.find((s) => s.id === scene.id)
    if (target) applyScene(target)
  }
}

/* ⑥ 最近使用 */
const recentItems = ref(getRecent())

onShow(() => {
  recentItems.value = getRecent()
})

const playRecent = (item: { sceneId: string }) => {
  const scene = findScene(item.sceneId)
  if (scene) applyScene(scene)
}

/* ⑦ 声音库 */
const soundCountLabel = computed(() => sounds.length)

/* 保存场景 */
const showSaveDialog = ref(false)
const saveName = ref('')

const saveScene = () => {
  if (!saveName.value.trim()) {
    uni.showToast({ title: '请输入场景名称', icon: 'none' })
    return
  }
  showSaveDialog.value = false
  saveName.value = ''
  uni.showToast({ title: '场景已保存', icon: 'success' })
}

/* 导航 */
const goTheme = () => {
  uni.navigateTo({ url: '/pages/theme/theme' })
}
const goAchievement = () => {
  uni.navigateTo({ url: '/pages/achievement/achievement' })
}
const goHistory = () => uni.navigateTo({ url: '/pages/history/history' })
const goLibrary = () => uni.navigateTo({ url: '/pages/library/library' })
</script>

<style lang="scss" scoped>
.header {
  padding: 16rpx 4rpx 2rpx;
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
  gap: 4rpx;
}

.app-title {
  font-size: 46rpx;
  font-weight: 800;
  color: var(--app-text, $uni-text-color);
  letter-spacing: 4rpx;
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

/* ② 大播放卡 */
.hero {
  margin-top: 20rpx;
  border-radius: 32rpx;
  padding: 30rpx;
  min-height: 290rpx;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  border: none;
  box-shadow: 0 16rpx 36rpx rgba(30, 40, 36, .18);
  overflow: hidden;
}

.hero-top {
  display: flex;
  align-items: center;
  gap: 14rpx;
}

.hero-scene {
  font-size: 32rpx;
  font-weight: 800;
  color: #fff;
  letter-spacing: 0.5rpx;
}

.hero-count {
  padding: 4rpx 16rpx;
  border-radius: 22rpx;
  background: rgba(255, 255, 255, .22);

  text {
    font-size: 19rpx;
    color: #fff;
    font-weight: 600;
  }
}

.hero-main {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin: 30rpx 0 22rpx;
}

.hero-bars {
  display: flex;
  align-items: flex-end;
  gap: 10rpx;
  height: 64rpx;
  flex: 1;

  .hero-bar {
    width: 8rpx;
    border-radius: 4rpx;
    background: rgba(255, 255, 255, .55);

    &:nth-child(1) { height: 26rpx; }
    &:nth-child(2) { height: 52rpx; }
    &:nth-child(3) { height: 38rpx; }
    &:nth-child(4) { height: 60rpx; }
    &:nth-child(5) { height: 32rpx; }
  }

  &.playing .hero-bar {
    background: #fff;
    animation: heroWave 1.1s ease-in-out infinite;

    &:nth-child(1) { animation-delay: 0s; }
    &:nth-child(2) { animation-delay: 0.15s; }
    &:nth-child(3) { animation-delay: 0.3s; }
    &:nth-child(4) { animation-delay: 0.45s; }
    &:nth-child(5) { animation-delay: 0.6s; }
  }
}

@keyframes heroWave {
  0%, 100% { transform: scaleY(0.55); }
  50% { transform: scaleY(1.15); }
}

.hero-play {
  width: 96rpx;
  height: 96rpx;
  border-radius: 50%;
  background: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  margin-left: 30rpx;
  box-shadow: 0 12rpx 26rpx rgba(0, 0, 0, .18);
  transition: transform 0.16s cubic-bezier(.4, 0, .2, 1);

  &:active {
    transform: scale(0.92);
  }
}

.hero-actions {
  display: flex;
  gap: 20rpx;
}

.hero-action {
  display: flex;
  align-items: center;
  gap: 8rpx;
  padding: 12rpx 24rpx;
  border-radius: 28rpx;
  background: rgba(255, 255, 255, .16);
  transition: all 0.16s;

  &:active {
    transform: scale(0.94);
  }
}

.hero-action-text {
  font-size: 22rpx;
  color: #fff;
  font-weight: 600;
}

.hero-empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 12rpx;
  min-height: 230rpx;
}

.hero-empty-icon {
  width: 108rpx;
  height: 108rpx;
  border-radius: 34rpx;
  background: rgba(255, 255, 255, .18);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 8rpx;
  box-shadow: inset 0 1rpx 0 rgba(255, 255, 255, .35);
}

.hero-empty-title {
  font-size: 32rpx;
  font-weight: 700;
  color: #fff;
  letter-spacing: 1rpx;
}

.hero-empty-sub {
  font-size: 23rpx;
  color: rgba(255, 255, 255, .82);
  letter-spacing: 0.5rpx;
}

/* ③ 金刚区 */
.quick-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 16rpx;
  margin-top: 24rpx;
}

.quick-item {
  width: calc(50% - 8rpx);
  padding: 22rpx;
  display: flex;
  align-items: center;
  gap: 18rpx;
  transition: transform 0.16s cubic-bezier(.4, 0, .2, 1);

  &:active {
    transform: scale(0.97);
  }
}

.quick-icon {
  width: 72rpx;
  height: 72rpx;
  border-radius: 22rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  box-shadow: inset 0 -2rpx 0 rgba(0, 0, 0, .08), inset 0 2rpx 0 rgba(255, 255, 255, .25), 0 6rpx 14rpx rgba(0, 0, 0, .10);
}

.quick-meta {
  display: flex;
  flex-direction: column;
  gap: 4rpx;
  min-width: 0;
}

.quick-name {
  font-size: 27rpx;
  font-weight: 700;
  color: var(--app-text, $uni-text-color);
}

.quick-desc {
  font-size: 21rpx;
  color: var(--app-text-2, $uni-text-color-grey);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

/* 通用分区 */
.section {
  margin-top: 32rpx;
}

.section-header {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  margin-bottom: 18rpx;
  padding: 0 4rpx;
}

.section-title {
  font-size: 24rpx;
  font-weight: 600;
  letter-spacing: 0.3rpx;
  color: var(--app-text-2, $uni-text-color-grey);
}

.section-more {
  font-size: 22rpx;
  color: var(--app-primary, $app-primary);
  font-weight: 500;
}

/* ④ 今日精选 */
.pick-scroll {
  white-space: nowrap;
  width: 100%;
}

.pick-list {
  display: inline-flex;
  gap: 16rpx;
  padding-bottom: 8rpx;
}

.pick-card {
  width: 480rpx;
  height: 210rpx;
  border-radius: 28rpx;
  padding: 26rpx 28rpx;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  flex-shrink: 0;
  overflow: hidden;
  transition: transform 0.16s cubic-bezier(.4, 0, .2, 1);

  &:active {
    transform: scale(0.98);
  }
}

.pick-tag {
  align-self: flex-start;
  padding: 4rpx 16rpx;
  border-radius: 22rpx;
  background: rgba(255, 255, 255, .24);

  text {
    font-size: 19rpx;
    color: #fff;
    font-weight: 600;
    letter-spacing: 1rpx;
  }
}

.pick-title {
  font-size: 34rpx;
  font-weight: 800;
  color: #fff;
  letter-spacing: 0.5rpx;
}

.pick-desc {
  font-size: 22rpx;
  color: rgba(255, 255, 255, .84);
}

.pick-bottom {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.pick-combo {
  font-size: 20rpx;
  color: rgba(255, 255, 255, .72);
}

.pick-play {
  width: 52rpx;
  height: 52rpx;
  border-radius: 50%;
  background: rgba(255, 255, 255, .94);
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4rpx 10rpx rgba(0, 0, 0, .08);
}

/* ⑤ 场景推荐 */
.category-tabs {
  display: flex;
  gap: 8rpx;
  margin-bottom: 26rpx;
  padding: 8rpx;
  background: var(--app-subtle, $uni-bg-color-grey);
  border-radius: 30rpx;
}

.cat-tab {
  flex: 1;
  height: 66rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 24rpx;
  font-size: 26rpx;
  color: var(--app-text-2, $uni-text-color-grey);
  font-weight: 500;
  transition: all 0.2s cubic-bezier(.4, 0, .2, 1);
  background: transparent;

  &.active {
    background: var(--app-card-bg, #fff);
    color: var(--app-primary, $app-primary);
    font-weight: 600;
    box-shadow: 0 4rpx 12rpx color-mix(in srgb, var(--app-primary, $app-primary) 14%, transparent);
  }
}

.scene-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 16rpx;

  .scene-card {
    width: calc(50% - 8rpx);
    margin-bottom: 0;
  }
}

.scene-empty {
  padding: 60rpx 32rpx;
  text-align: center;
  font-size: 25rpx;
  color: var(--app-text-2, $uni-text-color-grey);
}

/* ⑥ 最近使用 */
.recent-scroll {
  white-space: nowrap;
  width: 100%;
}

.recent-list {
  display: inline-flex;
  gap: 16rpx;
  padding-bottom: 8rpx;
}

.recent-item {
  width: 180rpx;
  padding: 22rpx 14rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10rpx;
  transition: transform 0.16s cubic-bezier(.4, 0, .2, 1);

  &:active {
    transform: scale(0.97);
  }
}

.recent-icon {
  width: 72rpx;
  height: 72rpx;
  border-radius: 22rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: inset 0 -2rpx 0 rgba(0, 0, 0, .08), inset 0 2rpx 0 rgba(255, 255, 255, .25);
}

.recent-name {
  font-size: 23rpx;
  font-weight: 500;
  color: var(--app-text, $uni-text-color);
  max-width: 100%;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.recent-time {
  font-size: 19rpx;
  color: var(--app-text-2, $uni-text-color-grey);
}

/* ⑦ 声音库入口 */
.library-entry {
  padding: 24rpx;
  display: flex;
  align-items: center;
  gap: 20rpx;
  transition: transform 0.16s cubic-bezier(.4, 0, .2, 1);

  &:active {
    transform: scale(0.98);
  }
}

.library-icon {
  width: 76rpx;
  height: 76rpx;
  border-radius: 24rpx;
  background: var(--app-primary-soft, rgba($app-primary, 0.12));
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.library-meta {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4rpx;
}

.library-name {
  font-size: 28rpx;
  font-weight: 700;
  color: var(--app-text, $uni-text-color);
}

.library-desc {
  font-size: 21rpx;
  color: var(--app-text-2, $uni-text-color-grey);
}

/* 保存弹窗 */
.modal-overlay {
  position: fixed;
  inset: 0;
  background: var(--app-overlay, rgba(0, 0, 0, 0.38));
  z-index: 200;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 64rpx;
}

.modal-content {
  width: 100%;
  padding: 36rpx;
  max-width: 620rpx;
}

.modal-title {
  font-size: 32rpx;
  font-weight: 700;
  color: var(--app-text, $uni-text-color);
  display: block;
  margin-bottom: 32rpx;
  text-align: center;
}

.modal-input {
  height: 92rpx;
  background: var(--app-input-bg, $uni-bg-color-grey);
  border: 1rpx solid var(--app-input-border, transparent);
  border-radius: 20rpx;
  padding: 0 24rpx;
  font-size: 28rpx;
  margin-bottom: 32rpx;
  width: 100%;
  box-sizing: border-box;
  color: var(--app-text, $uni-text-color);
}

.modal-actions {
  display: flex;
  justify-content: center;
  gap: 24rpx;
}
</style>
