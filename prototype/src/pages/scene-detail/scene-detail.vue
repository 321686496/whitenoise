<template>
  <!-- v2：自定义导航（pages.json 已改 custom），NavBar 自带安全区 -->
  <view class="page-container scene-detail-page">
    <view class="page-bg"></view>

    <NavBar title="场景详情" />

    <!-- 封面 Hero：场景渐变资产作底，浮层文字全部走 on-cover token -->
    <view class="cover-section" :style="{ background: coverGradient }">
      <view class="cover-icon-wrap">
        <Icon :name="scene.iconName" :size="120" color="var(--app-on-cover)" />
      </view>
      <text class="cover-name">{{ scene.name }}</text>
      <text class="cover-desc">{{ scene.desc }}</text>

      <view class="hero-body">
        <view class="hero-wave" :class="{ paused: !isThisPlaying }" aria-hidden="true">
          <view
            v-for="i in 5"
            :key="i"
            class="hero-wave-bar"
            :style="{ animationDelay: (i * 0.12) + 's' }"
          />
        </view>
        <view
          class="hero-play"
          :aria-label="isCurrent && player.isPlaying ? '暂停' : '播放此场景'"
          @click="onHeroPlay"
        >
          <Icon :name="isCurrent && player.isPlaying ? 'pause' : 'play'" :size="64" color="var(--app-on-primary)" />
        </view>
      </view>

      <view class="hero-chips">
        <view
          class="hero-chip"
          :class="{ on: player.timerMinutes > 0 }"
          aria-label="睡眠定时"
          @click="player.showTimerPanel = true"
        >
          <Icon name="timer" :size="20" />
          <text class="num">{{ player.timerMinutes > 0 ? player.timerMinutes + '分' : '定时' }}</text>
        </view>
        <view class="hero-chip" aria-label="混音面板" @click="player.showMixPanel = true">
          <Icon name="shuffle" :size="20" /><text>混音</text>
        </view>
      </view>
    </view>

    <view class="section">
      <text class="section-title">场景故事</text>
      <view class="story-card app-card">
        <text class="story-text">"{{ scene.desc }}"</text>
      </view>
    </view>

    <view class="section">
      <text class="section-title">声音配方</text>
      <view class="recipe-card app-card">
        <view
          class="recipe-item"
          v-for="item in recipe"
          :key="item.name"
        >
          <view class="recipe-info">
            <Icon :name="item.icon" :size="20" color="var(--app-primary)" />
            <text class="recipe-name">{{ item.name }}</text>
            <text class="recipe-percent num">{{ item.percent }}%</text>
          </view>
          <view class="recipe-bar-bg">
            <view
              class="recipe-bar-fill"
              :style="{ width: item.percent + '%', background: item.color }"
            />
          </view>
        </view>
      </view>
    </view>

    <view class="section">
      <text class="section-title">预设方案</text>
      <view class="preset-list">
        <view
          class="preset-card app-card"
          v-for="preset in presets"
          :key="preset.name"
          :class="{ active: activePreset === preset.name }"
          @click="applyPreset(preset)"
        >
          <view class="preset-header">
            <view class="preset-badge" :style="{ background: preset.badgeColor }">
              <text class="preset-badge-text">{{ preset.name }}</text>
            </view>
            <view class="check-wrap" v-if="activePreset === preset.name">
              <Icon name="check" :size="16" color="var(--app-primary)" />
            </view>
          </view>
          <view class="preset-recipe">
            <text
              class="preset-ratio"
              v-for="(r, idx) in preset.ratios"
              :key="r.name"
            >{{ r.name }} {{ r.value }}%<text v-if="idx < preset.ratios.length - 1" class="ratio-sep"> · </text></text>
          </view>
        </view>
      </view>
    </view>

    <view class="section">
      <view class="action-row">
        <view class="action-btn app-card" @click="editScene">
          <Icon name="edit" :size="20" color="var(--app-primary)" />
          <text class="action-text">编辑配方</text>
        </view>
        <view class="action-btn app-card" @click="toggleFavorite">
          <Icon
            name="heart"
            :size="20"
            :color="isFavorited ? 'var(--app-primary)' : 'var(--app-text-3)'"
          />
          <text class="action-text" :class="{ on: isFavorited }">{{ isFavorited ? '已收藏' : '收藏' }}</text>
        </view>
        <view class="action-btn app-card" @click="shareScene">
          <Icon name="share" :size="20" color="var(--app-primary)" />
          <text class="action-text">分享</text>
        </view>
      </view>
    </view>

    <view class="section">
      <text class="section-title">分享预览</text>
      <view class="share-card app-card">
        <view class="share-card-header">
          <view class="share-icon-wrap" :style="{ background: coverGradient }">
            <Icon :name="scene.iconName" :size="28" color="var(--app-on-cover)" />
          </view>
          <view class="share-card-info">
            <text class="share-card-name">{{ scene.name }}</text>
            <text class="share-card-stat">累计播放 1,284 次 · 收藏 326 次</text>
          </view>
        </view>
        <text class="share-card-quote">"每晚听着雨声入眠，是我给自己最温柔的仪式"</text>
        <view class="share-card-footer">
          <text class="share-card-brand">— 声栖 · 用声音构建你的宁静空间</text>
        </view>
      </view>
    </view>

    <!-- 定时底部 Sheet（与混音 Sheet 各用 player.showTimerPanel / showMixPanel，互斥独立）
         作为页面根级兄弟节点渲染：不嵌在任何 backdrop-filter / overflow 祖先内 -->
    <view class="sd-sheet-mask" v-if="player.showTimerPanel" @click="closeTimer">
      <view class="sd-sheet" @click.stop>
        <view class="sd-sheet-handle" aria-hidden="true" />
        <view class="sd-sheet-head">
          <text class="sd-sheet-title">睡眠定时</text>
          <view class="sd-sheet-close" aria-label="关闭" @click="closeTimer">
            <Icon name="close" :size="18" color="var(--app-text-3)" />
          </view>
        </view>
        <view class="sd-timer-grid">
          <view
            class="sd-timer-pill num"
            :class="{ active: player.timerMinutes === m }"
            v-for="m in timerOptions"
            :key="m"
            @click="onSetTimer(m)"
          >{{ m }}分钟</view>
        </view>
        <text class="sd-timer-hint">再次点选同一时长即可取消定时</text>
      </view>
    </view>

    <!-- 混音底部 Sheet（结构镜像 NowPlayingCard 自持面板） -->
    <view class="sd-sheet-mask" v-if="player.showMixPanel" @click="closeMix">
      <view class="sd-sheet" @click.stop>
        <view class="sd-sheet-handle" aria-hidden="true" />
        <view class="sd-sheet-head">
          <text class="sd-sheet-title">当前混音</text>
          <view class="sd-sheet-count num" v-if="player.tracks.length > 0">{{ player.tracks.length }}/6 路</view>
          <view class="sd-sheet-close" aria-label="关闭" @click="closeMix">
            <Icon name="close" :size="18" color="var(--app-text-3)" />
          </view>
        </view>
        <scroll-view class="sd-sheet-list" scroll-y v-if="player.tracks.length > 0">
          <MixTrack
            v-for="track in player.tracks"
            :key="track.id"
            :name="track.name"
            :icon-name="track.iconName"
            :color="track.color"
            :volume="track.volume"
            :is-muted="track.muted"
            @volume-change="(v: number) => setTrackVolume(track.id, v)"
            @mute="toggleTrackMute(track.id)"
            @remove="removeTrack(track.id)"
          />
        </scroll-view>
        <view class="sd-sheet-empty" v-else>
          <text>暂无音轨，点上方播放键开始混音</text>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { onLoad, onHide } from '@dcloudio/uni-app'
import NavBar from '@/components/NavBar.vue'
import Icon from '@/components/Icon.vue'
import MixTrack from '@/components/MixTrack.vue'
import { findScene, homeScenes, buildRecipe, buildPresets } from '@/data/scenes'
import {
  player,
  applyScene,
  togglePlay,
  setTimer,
  setTrackVolume,
  toggleTrackMute,
  removeTrack,
} from '@/composables/usePlayer'

const sceneId = ref('')
const activePreset = ref('标准')
// 收藏状态：按 sceneId 内存级记忆
const favMap = ref<Record<string, boolean>>({})

const scene = computed(() => findScene(sceneId.value) ?? homeScenes[0])
const recipe = computed(() => buildRecipe(scene.value))
const presets = computed(() => buildPresets(scene.value))
const isFavorited = computed(() => !!favMap.value[scene.value.id])

/** 本场景是否即当前播放场景 */
const isCurrent = computed(() => player.currentScene?.id === scene.value.id)
const isThisPlaying = computed(() => isCurrent.value && player.isPlaying)

const timerOptions = [15, 30, 45, 60]

onLoad((options) => {
  sceneId.value = options?.sceneId ?? ''
})

// 页面隐藏时收起面板，避免 player 面板标志残留导致其他页面弹窗无端弹出（同 index.vue onHide 约定）
onHide(() => {
  player.showTimerPanel = false
  player.showMixPanel = false
})

const coverGradient = computed(() => scene.value.gradient)

const applyPreset = (preset: { name: string }) => {
  activePreset.value = preset.name
  uni.showToast({ title: `已切换「${preset.name}」方案`, icon: 'none' })
}

const onHeroPlay = () => {
  if (!isCurrent.value) {
    applyScene(scene.value)
    uni.showToast({ title: '已开始播放', icon: 'success' })
    return
  }
  if (!togglePlay()) {
    uni.showToast({ title: '暂无音轨，去编辑配方添加声音', icon: 'none' })
  }
}

const editScene = () => {
  uni.navigateTo({ url: `/pages/scene-edit/scene-edit?sceneId=${scene.value.id}` })
}

const toggleFavorite = () => {
  favMap.value[scene.value.id] = !favMap.value[scene.value.id]
  uni.showToast({ title: isFavorited.value ? '已收藏' : '已取消收藏', icon: 'none' })
}

const shareScene = () => {
  uni.showToast({ title: '已生成分享卡片', icon: 'success' })
}

const closeTimer = () => { player.showTimerPanel = false }
const closeMix = () => { player.showMixPanel = false }

const onSetTimer = (minutes: number) => {
  const willCancel = player.timerMinutes === minutes
  setTimer(minutes)
  uni.showToast({ title: willCancel ? '已取消定时' : `定时 ${minutes} 分钟`, icon: 'none' })
}
</script>

<style lang="scss" scoped>
/* NavBar 自带 env(safe-area-inset-top)，容器顶距收窄 */
.scene-detail-page {
  padding-top: calc(env(safe-area-inset-top, 0rpx) + 12rpx);
}

/* ---------- 封面 Hero（渐变数据资产作底，浮层全走 on-cover token） ---------- */
.cover-section {
  margin: 0 -40rpx;
  padding: 48rpx 56rpx 56rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  border-radius: 0 0 48rpx 48rpx;
}

/* 图上浮层取向：on-cover 白经 color-mix 半透明 + 毛玻璃（MASTER §7） */
.cover-icon-wrap {
  width: 240rpx;
  height: 240rpx;
  border-radius: 999rpx;
  background: color-mix(in srgb, var(--app-on-cover) 18%, transparent);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 32rpx;
  backdrop-filter: blur(10rpx);
  -webkit-backdrop-filter: blur(10rpx);
  box-shadow: inset 0 1rpx 0 color-mix(in srgb, var(--app-on-cover) 35%, transparent);
}

.cover-name {
  font-size: 44rpx;
  font-weight: 700;
  color: var(--app-on-cover);
  letter-spacing: 3rpx;
  margin-bottom: 12rpx;
}

.cover-desc {
  font-size: 26rpx;
  color: var(--app-on-cover-soft);
  text-align: center;
  line-height: 1.6;
  padding: 0 20rpx;
}

.hero-body {
  width: 100%;
  display: flex;
  align-items: center;
  gap: 32rpx;
  margin-top: 48rpx;
}

.hero-wave {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 10rpx;
  height: 88rpx;
}

.hero-wave-bar {
  width: 8rpx;
  border-radius: 999rpx;
  background: var(--app-on-cover);
  height: 30%;
  animation: heroBreath 1.6s ease-in-out infinite;
}

.hero-wave-bar:nth-child(2) { height: 55%; }
.hero-wave-bar:nth-child(3) { height: 85%; }
.hero-wave-bar:nth-child(4) { height: 55%; }
.hero-wave-bar:nth-child(5) { height: 30%; }

.hero-wave.paused .hero-wave-bar {
  animation-play-state: paused;
  opacity: 0.4;
}

@keyframes heroBreath {
  0%, 100% { transform: scaleY(0.6); }
  50% { transform: scaleY(1); }
}

@media (prefers-reduced-motion: reduce) {
  .hero-wave-bar { animation: none; }
}

/* 播放键 176rpx，primary 渐变 + shadow-3（对齐 NowPlayingCard 主控） */
.hero-play {
  width: 176rpx;
  height: 176rpx;
  border-radius: 999rpx;
  flex: none;
  background: linear-gradient(135deg, var(--app-primary), var(--app-primary-strong));
  box-shadow: var(--app-shadow-3);
  display: flex;
  align-items: center;
  justify-content: center;
  transition: transform var(--dur-fast) var(--ease-std);

  &:active {
    transform: scale(0.96);
  }
}

.hero-chips {
  display: flex;
  gap: 20rpx;
  margin-top: 36rpx;
}

.hero-chip {
  min-height: 88rpx;
  padding: 0 40rpx;
  border-radius: 999rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10rpx;
  font-size: 25rpx;
  font-weight: 600;
  color: var(--app-on-cover);
  background: color-mix(in srgb, var(--app-on-cover) 16%, transparent);
  border: 1rpx solid color-mix(in srgb, var(--app-on-cover) 30%, transparent);
  backdrop-filter: blur(6rpx);
  -webkit-backdrop-filter: blur(6rpx);
  transition: transform var(--dur-fast) var(--ease-std), background var(--dur-fast) var(--ease-std);

  &:active {
    transform: scale(0.96);
  }

  &.on {
    background: color-mix(in srgb, var(--app-on-cover) 92%, transparent);
    color: var(--app-primary-strong);
  }
}

/* ---------- 通用分区 ---------- */
.section {
  margin-top: 36rpx;
}

.story-card {
  padding: 28rpx 32rpx;
}

.story-text {
  font-size: 28rpx;
  color: var(--app-text);
  font-style: italic;
  line-height: 1.7;
  letter-spacing: 0.5rpx;
}

.recipe-card {
  padding: 24rpx 28rpx;
  display: flex;
  flex-direction: column;
  gap: 24rpx;
}

.recipe-item {
  display: flex;
  flex-direction: column;
  gap: 10rpx;
}

.recipe-info {
  display: flex;
  align-items: center;
  gap: 10rpx;
}

.recipe-name {
  font-size: 26rpx;
  color: var(--app-text);
  font-weight: 500;
  flex: 1;
}

.recipe-percent {
  font-size: 24rpx;
  color: var(--app-text-2);
  font-weight: 600;
}

.recipe-bar-bg {
  height: 12rpx;
  background: var(--app-sunken);
  border-radius: 999rpx;
  overflow: hidden;
}

.recipe-bar-fill {
  height: 100%;
  border-radius: 999rpx;
  transition: width var(--dur-base) var(--ease-std);
}

.preset-list {
  display: flex;
  flex-direction: column;
  gap: 16rpx;
}

.preset-card {
  padding: 24rpx 28rpx;
  transition: transform var(--dur-fast) var(--ease-std), border-color var(--dur-fast) var(--ease-std), box-shadow var(--dur-fast) var(--ease-std);

  &:active {
    transform: scale(0.98);
  }

  &.active {
    border-color: color-mix(in srgb, var(--app-primary) 70%, transparent);
    box-shadow: var(--app-shadow-2), var(--app-inset), 0 0 0 2rpx color-mix(in srgb, var(--app-primary) 24%, transparent);
  }
}

.preset-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 14rpx;
}

/* 预设徽章：数据资产渐变作底，文字走 on-cover */
.preset-badge {
  padding: 8rpx 24rpx;
  border-radius: 999rpx;
  display: inline-flex;
  align-items: center;
}

.preset-badge-text {
  font-size: 24rpx;
  font-weight: 600;
  color: var(--app-on-cover);
}

.check-wrap {
  width: 36rpx;
  height: 36rpx;
  border-radius: 999rpx;
  background: var(--app-primary-soft);
  display: flex;
  align-items: center;
  justify-content: center;
}

.preset-recipe {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
}

.preset-ratio {
  font-size: 24rpx;
  color: var(--app-text-2);
}

.ratio-sep {
  color: var(--app-text-3);
  margin: 0 4rpx;
}

/* ---------- 操作行 ---------- */
.action-row {
  display: flex;
  gap: 20rpx;
}

.action-btn {
  flex: 1;
  min-height: 88rpx;
  padding: 22rpx 0;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10rpx;
  transition: transform var(--dur-fast) var(--ease-std);

  &:active {
    transform: scale(0.96);
  }
}

.action-text {
  font-size: 26rpx;
  color: var(--app-primary);
  font-weight: 600;

  &.on {
    color: var(--app-primary);
  }
}

/* ---------- 分享预览 ---------- */
.share-card {
  padding: 28rpx 28rpx 20rpx;
  background: linear-gradient(135deg, var(--app-surface) 0%, var(--app-surface-2) 100%);
}

.share-card-header {
  display: flex;
  align-items: center;
  gap: 18rpx;
  margin-bottom: 20rpx;
}

/* 分享缩略图标底改用当前场景渐变数据资产（原 v1 写死 #8296A8→#5F7A92） */
.share-icon-wrap {
  width: 72rpx;
  height: 72rpx;
  border-radius: 22rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.share-card-info {
  display: flex;
  flex-direction: column;
  gap: 6rpx;
}

.share-card-name {
  font-size: 28rpx;
  font-weight: 600;
  color: var(--app-text);
}

.share-card-stat {
  font-size: 22rpx;
  color: var(--app-text-2);
}

.share-card-quote {
  font-size: 26rpx;
  color: var(--app-text);
  font-style: italic;
  line-height: 1.6;
  margin-bottom: 20rpx;
  display: block;
}

.share-card-footer {
  padding-top: 16rpx;
  border-top: 1rpx solid var(--app-line);
}

.share-card-brand {
  font-size: 22rpx;
  color: var(--app-text-2);
  letter-spacing: 0.5rpx;
}

/* ---------- 底部 Sheet（定时 / 混音共用，v2 §8/§9：顶角 xl=56rpx / shadow-4 / dur-slow） ---------- */
.sd-sheet-mask {
  position: fixed;
  left: 0;
  top: 0;
  right: 0;
  bottom: 0;
  z-index: 300;
  background: var(--app-overlay);
  display: flex;
  align-items: flex-end;
  animation: sdMaskIn var(--dur-slow) var(--ease-std) both;
}

.sd-sheet {
  width: 100%;
  box-sizing: border-box;
  max-height: 82vh;
  display: flex;
  flex-direction: column;
  padding: 16rpx 32rpx calc(32rpx + env(safe-area-inset-bottom));
  background: var(--app-surface);
  border-top: 1rpx solid var(--app-line);
  border-radius: 56rpx 56rpx 0 0;
  box-shadow: var(--app-shadow-4), var(--app-inset);
  backdrop-filter: blur(var(--app-blur));
  -webkit-backdrop-filter: blur(var(--app-blur));
  animation: sdSheetUp var(--dur-slow) var(--ease-std) both;
}

.sd-sheet-handle {
  width: 72rpx;
  height: 8rpx;
  border-radius: 999rpx;
  background: var(--app-sunken);
  margin: 0 auto 20rpx;
  flex: none;
}

.sd-sheet-head {
  display: flex;
  align-items: center;
  gap: 14rpx;
  flex: none;
}

.sd-sheet-title {
  font-size: 30rpx;
  font-weight: 700;
  color: var(--app-text);
  letter-spacing: -0.3rpx;
  flex: 1;
}

.sd-sheet-count {
  padding: 6rpx 20rpx;
  border-radius: 999rpx;
  font-size: 21rpx;
  font-weight: 600;
  background: var(--app-primary-soft);
  color: var(--app-primary);
}

.sd-sheet-close {
  width: 88rpx;
  height: 88rpx;
  flex: none;
  margin-right: -18rpx;
  border-radius: 999rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: transform var(--dur-fast) var(--ease-std), background var(--dur-fast) var(--ease-std);

  &:active {
    transform: scale(0.96);
    background: var(--app-press);
  }
}

.sd-sheet-list {
  flex: 1;
  min-height: 0;
}

.sd-sheet-empty {
  padding: 48rpx 0;
  text-align: center;
  font-size: 25rpx;
  color: var(--app-text-2);
}

/* 定时时长胶囊 */
.sd-timer-grid {
  display: flex;
  gap: 16rpx;
  margin-top: 24rpx;
}

.sd-timer-pill {
  flex: 1;
  min-height: 88rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 999rpx;
  background: var(--app-surface-2);
  border: 1rpx solid var(--app-line);
  font-size: 25rpx;
  font-weight: 600;
  color: var(--app-text);
  transition: transform var(--dur-fast) var(--ease-std), background var(--dur-fast) var(--ease-std);

  &:active {
    transform: scale(0.96);
  }

  &.active {
    background: var(--app-primary);
    border-color: transparent;
    color: var(--app-on-primary);
    box-shadow: var(--app-shadow-1);
  }
}

.sd-timer-hint {
  margin-top: 20rpx;
  font-size: 22rpx;
  color: var(--app-text-3);
  text-align: center;
}

@keyframes sdMaskIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes sdSheetUp {
  from { transform: translateY(100%); }
  to { transform: translateY(0); }
}

@media (prefers-reduced-motion: reduce) {
  .sd-sheet-mask,
  .sd-sheet {
    animation: none;
  }
}
</style>
