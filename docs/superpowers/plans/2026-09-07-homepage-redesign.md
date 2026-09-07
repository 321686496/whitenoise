# 声栖 · 首页重设计 实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 按「即刻助眠流」重构首页（排版/布局/内容），将共享播放状态、场景数据与页面结构落地。

**Architecture:** 新增 `data/scenes.ts`（11 个场景，分类制）与 `composables/usePlayer.ts`（模块级 reactive 播放状态，首页/场景网格/PlayBar 共用）；重写 `index.vue` 为 7 层结构（品牌头 → 大播放卡 → 金刚区 → 今日精选 → 分类场景网格 → 最近使用 → 声音库入口）；PlayBar 收纳混音面板；场景页支持分类直达。

**Tech Stack:** uni-app (Vue 3 + `<script setup lang="ts">` + SCSS)、主题引擎 CSS 变量（`var(--app-*)`）、自定义 `Icon.vue`（禁 emoji）。

## Global Constraints

- 所有 UI 使用 `var(--app-*)` 变量与 `.app-card` 容器，保持 6 配色 × 3 UI 风格即时切换；禁止新增自定义颜色常量
- 图标一律使用 `@/components/Icon.vue`（现有 36 个图标），禁止 emoji
- 文案中文、贴合「声栖」品牌（助眠调性），情感化短文案
- 项目无单元测试框架；每个任务验证 = `npm run type-check`（vue-tsc 无错）+ 任务描述中的手动检查项
- 工作目录：`prototype/`；命令均在 `prototype/` 下执行
- 分区表头用 iOS 式小号灰色次级标签（24rpx、`--app-text-2`），页面进入动效沿用 `iosPageIn`
- 混音音量滑块保持原型现状（视觉反馈，`MixTrack.vue` 不做触摸数学）

---

### Task 1: 场景数据 `src/data/scenes.ts`

**Files:**
- Create: `prototype/src/data/scenes.ts`

**Interfaces:**
- Consumes: `src/data/sounds.ts` 的 `sounds`（30 个声音，含 `id/name/iconName/color`）
- Produces:
  - `type SceneCategory = 'sleep' | 'focus' | 'relax' | 'nature'`
  - `interface Scene { id: string; name: string; category: SceneCategory; desc: string; iconName: string; gradient: string; soundIds: string[]; isPreset: boolean }`
  - `sceneCategories: { key: string; label: string }[]`
  - `soundNames(ids: string[]): string`
  - `findScene(id: string): Scene | undefined`
  - `homeScenes: Scene[]`

- [ ] **Step 1: 创建场景数据文件**

```ts
/**
 * 声栖 · 首页场景数据
 *
 * 供首页（场景推荐网格 / 今日精选 / 金刚区）与场景页共用。
 * iconName 需与 components/Icon.vue 中已定义的图标名保持一致。
 */

import { sounds } from './sounds'

export type SceneCategory = 'sleep' | 'focus' | 'relax' | 'nature'

export interface Scene {
  id: string
  name: string
  category: SceneCategory
  desc: string
  iconName: string
  gradient: string
  soundIds: string[]
  isPreset: boolean
}

export const sceneCategories: { key: string; label: string }[] = [
  { key: 'all', label: '全部' },
  { key: 'sleep', label: '助眠' },
  { key: 'focus', label: '专注' },
  { key: 'relax', label: '放松' },
  { key: 'nature', label: '自然' },
]

/** 由 soundIds 拼出如「雨声 + 白噪音」的组合文案 */
export function soundNames(ids: string[]): string {
  return ids.map((id) => sounds.find((s) => s.id === id)?.name ?? id).join(' + ')
}

export function findScene(id: string): Scene | undefined {
  return homeScenes.find((s) => s.id === id)
}

export const homeScenes: Scene[] = [
  // 助眠
  { id: 'deep-sleep', name: '深度睡眠', category: 'sleep', desc: '雨声铺底、白噪衬静，一夜沉入深眠', iconName: 'moon', gradient: 'linear-gradient(135deg, #7E93A8, #4E7182)', soundIds: ['rain', 'white-noise', 'forest'], isPreset: true },
  { id: 'rainy-night', name: '夜雨入眠', category: 'sleep', desc: '细雨夹着篝火，温暖安全地睡去', iconName: 'rain', gradient: 'linear-gradient(135deg, #5F7A92, #B97A48)', soundIds: ['drizzle', 'thunder', 'campfire'], isPreset: true },
  { id: 'ocean-sleep', name: '海浪催眠', category: 'sleep', desc: '潮起潮落，像摇篮一样晃进梦里', iconName: 'wave-ocean', gradient: 'linear-gradient(135deg, #5F8296, #4E7182)', soundIds: ['ocean-wave', 'white-noise'], isPreset: true },
  // 专注
  { id: 'focus-white-noise', name: '专注白噪', category: 'focus', desc: '纯净声墙，一键进入心流', iconName: 'white-noise', gradient: 'linear-gradient(135deg, #8296A8, #C49A92)', soundIds: ['white-noise', 'pink-noise'], isPreset: true },
  { id: 'coffee-time', name: '咖啡时光', category: 'focus', desc: '杯碟轻响，适合写字的角落', iconName: 'coffee', gradient: 'linear-gradient(135deg, #A89068, #9A886B)', soundIds: ['cafe', 'typewriter'], isPreset: true },
  { id: 'long-train', name: '长途列车', category: 'focus', desc: '车轮规律作响，思绪随轨道延伸', iconName: 'train', gradient: 'linear-gradient(135deg, #8E82A6, #746889)', soundIds: ['train', 'white-noise'], isPreset: true },
  // 放松
  { id: 'nature-relax', name: '自然放松', category: 'relax', desc: '把大海和森林搬进房间', iconName: 'forest', gradient: 'linear-gradient(135deg, #5F8296, #7E9A74)', soundIds: ['ocean-wave', 'forest', 'stream', 'birdsong'], isPreset: true },
  { id: 'forest-meditation', name: '森林冥想', category: 'relax', desc: '空谷幽林，让呼吸慢下来', iconName: 'mountain', gradient: 'linear-gradient(135deg, #7E9A74, #5F7A86)', soundIds: ['forest', 'stream', 'cricket'], isPreset: true },
  { id: 'campfire-night', name: '篝火夜晚', category: 'relax', desc: '火光噼啪，虫鸣作伴的冬夜', iconName: 'fire', gradient: 'linear-gradient(135deg, #B97A48, #9C5F34)', soundIds: ['campfire', 'cricket'], isPreset: true },
  // 自然
  { id: 'forest-stream', name: '林间溪流', category: 'nature', desc: '泉水淌过青石，清亮又安定', iconName: 'stream', gradient: 'linear-gradient(135deg, #7F9AA6, #66818D)', soundIds: ['stream', 'forest'], isPreset: true },
  { id: 'morning-forest', name: '山野清晨', category: 'nature', desc: '鸟鸣与风拂过林梢的清晨', iconName: 'bird', gradient: 'linear-gradient(135deg, #7E9A74, #547E54)', soundIds: ['forest', 'birdsong'], isPreset: true },
]
```

- [ ] **Step 2: 类型检查**

Run: `npm run type-check`（在 `prototype/` 下）
Expected: 无 `scenes.ts` 相关错误（vue-tsc 仅报既有类型问题则同样视为通过）

- [ ] **Step 3: 提交**

```bash
git add src/data/scenes.ts
git commit -m "feat: add homepage scene data"
```

---

### Task 2: 共享播放状态 `src/composables/usePlayer.ts`

**Files:**
- Create: `prototype/src/composables/usePlayer.ts`

**Interfaces:**
- Consumes: `src/data/scenes.ts` 的 `Scene`、`src/data/sounds.ts` 的 `sounds`
- Produces:
  - `interface Track { id; name; iconName; color; volume; muted }`
  - `export const player: reactive`（字段：`currentScene: Scene | null`、`tracks: Track[]`、`isPlaying: boolean`、`timerMinutes: number`、`fadeMinutes: number`、`showTimerPanel: boolean`、`showMixPanel: boolean`、`pendingSceneCategory: string`）
  - `applyScene(scene: Scene): void`
  - `togglePlay(): boolean`（无音轨返回 false）
  - `setTrackVolume(id: string, volume: number): void`
  - `toggleTrackMute(id: string): void`
  - `removeTrack(id: string): void`
  - `setTimer(minutes: number): void`
  - `getRecent(): RecentItem[]`、`interface RecentItem { sceneId; name; iconName; gradient; ts }`
  - `recentTimeLabel(ts: number): string`

- [ ] **Step 1: 创建共享状态文件**

```ts
/**
 * 声栖 · 共享播放状态
 *
 * 模块级 reactive 单例，首页大播放卡 / 场景网格 / 底部 PlayBar 读写同一状态。
 */

import { reactive } from 'vue'
import type { Scene } from '@/data/scenes'
import { sounds } from '@/data/sounds'

export interface Track {
  id: string
  name: string
  iconName: string
  color: string
  volume: number
  muted: boolean
}

interface PlayerState {
  currentScene: Scene | null
  tracks: Track[]
  isPlaying: boolean
  timerMinutes: number
  fadeMinutes: number
  showTimerPanel: boolean
  showMixPanel: boolean
  pendingSceneCategory: string
}

export const player = reactive<PlayerState>({
  currentScene: null,
  tracks: [],
  isPlaying: false,
  timerMinutes: 0,
  fadeMinutes: 2,
  showTimerPanel: false,
  showMixPanel: false,
  pendingSceneCategory: 'all',
})

function findSound(id: string) {
  const s = sounds.find((item) => item.id === id)
  if (!s) throw new Error(`usePlayer: 未找到声音 ${id}`)
  return s
}

/** 应用场景：按 soundIds 重建音轨并开始播放 */
export function applyScene(scene: Scene) {
  player.currentScene = scene
  player.tracks = scene.soundIds.map((id) => {
    const s = findSound(id)
    return { id: s.id, name: s.name, iconName: s.iconName, color: s.color, volume: 50, muted: false }
  })
  player.isPlaying = true
  pushRecent(scene)
}

/** 播放/暂停；无音轨时返回 false，由调用方 toast 提示 */
export function togglePlay(): boolean {
  if (player.tracks.length === 0) return false
  player.isPlaying = !player.isPlaying
  return true
}

export function setTrackVolume(id: string, volume: number) {
  const t = player.tracks.find((x) => x.id === id)
  if (t) t.volume = volume
}

export function toggleTrackMute(id: string) {
  const t = player.tracks.find((x) => x.id === id)
  if (t) t.muted = !t.muted
}

export function removeTrack(id: string) {
  player.tracks = player.tracks.filter((t) => t.id !== id)
  if (player.tracks.length === 0) player.isPlaying = false
}

/** 定时：重复点击同一时长则取消 */
export function setTimer(minutes: number) {
  player.timerMinutes = player.timerMinutes === minutes ? 0 : minutes
}

/* ------------------------- 最近使用（本地存储） ------------------------- */

const RECENT_KEY = 'shengqi-recent'
const RECENT_MAX = 10

export interface RecentItem {
  sceneId: string
  name: string
  iconName: string
  gradient: string
  ts: number
}

export function getRecent(): RecentItem[] {
  try {
    const raw = uni.getStorageSync(RECENT_KEY) as unknown
    return Array.isArray(raw) ? (raw as RecentItem[]) : []
  } catch {
    return []
  }
}

function pushRecent(scene: Scene) {
  const list = getRecent().filter((i) => i.sceneId !== scene.id)
  list.unshift({ sceneId: scene.id, name: scene.name, iconName: scene.iconName, gradient: scene.gradient, ts: Date.now() })
  try {
    uni.setStorageSync(RECENT_KEY, list.slice(0, RECENT_MAX))
  } catch {}
}

/** 时间标签：刚刚 / n分钟前 / n小时前 / 昨晚 / n天前 */
export function recentTimeLabel(ts: number): string {
  const diff = Date.now() - ts
  const m = Math.floor(diff / 60000)
  if (m < 1) return '刚刚'
  if (m < 60) return `${m}分钟前`
  const h = Math.floor(m / 60)
  if (h < 8) return `${h}小时前`
  if (h < 24) return '昨晚'
  const d = Math.floor(h / 24)
  return `${d}天前`
}
```

- [ ] **Step 2: 类型检查**

Run: `npm run type-check`
Expected: 无 `usePlayer.ts` 相关错误

- [ ] **Step 3: 提交**

```bash
git add src/composables/usePlayer.ts
git commit -m "feat: add shared player composable"
```

---

### Task 3: `SceneCard.vue` 支持两列网格布局

**Files:**
- Modify: `prototype/src/components/SceneCard.vue`（整体重写为双布局）

**Interfaces:**
- Consumes: 既有 props `name/soundCount/soundIcons/bgColor/isPreset` 与 emits `tap/play/share`
- Produces: 新增可选 props `layout?: 'row' | 'grid'`（默认 `'row'`）、`active?: boolean`（默认 false，播放中显示暂停/主色态）、`soundLabel?: string`（grid 下替代「N 种声音组合」文案）

- [ ] **Step 1: 重写组件**

```vue
<template>
  <view
    class="scene-card app-card"
    :class="[`scene-card--${layout}`, { 'scene-card--active': active }]"
    @click="$emit('tap')"
  >
    <view class="scene-cover" :style="{ background: bgColor }">
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
import Icon from './Icon.vue'

withDefaults(defineProps<{
  name: string
  soundCount: number
  soundIcons: string[]
  bgColor: string
  isPreset: boolean
  layout?: 'row' | 'grid'
  active?: boolean
  soundLabel?: string
}>(), {
  layout: 'row',
  active: false,
  soundLabel: '',
})

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
```

- [ ] **Step 2: 类型检查**

Run: `npm run type-check`
Expected: 无 `SceneCard.vue` 相关错误

- [ ] **Step 3: 提交**

```bash
git add src/components/SceneCard.vue
git commit -m "feat: add grid layout mode to SceneCard"
```

---

### Task 4: `PlayBar.vue` 接入共享状态并收纳混音面板

**Files:**
- Modify: `prototype/src/components/PlayBar.vue`（整体重写）

**Interfaces:**
- Consumes: `usePlayer.ts` 全部导出；`MixTrack.vue`（props `name/iconName/color/volume/isMuted`，emits `mute/remove`）
- Produces: 不再接收 props；仅 emit `saveTap: []`。首页改为 `<PlayBar @save-tap="showSaveDialog = true" />`

- [ ] **Step 1: 重写 PlayBar**

```vue
<template>
  <view class="play-bar">
    <view class="play-bar-inner app-card">
      <view class="play-info" @click="player.showMixPanel = !player.showMixPanel">
        <view class="play-thumb">
          <view class="mini-logo">
            <image src="/static/logo-v10-1.jpg" mode="aspectFit" />
          </view>
        </view>
        <view class="play-meta">
          <view class="play-bars" :class="{ playing: player.isPlaying }">
            <view class="bar" v-for="i in 4" :key="i"></view>
          </view>
          <view class="play-scene-row">
            <text class="play-scene">{{ player.currentScene?.name || '未选择场景' }}</text>
            <text class="timer-badge" v-if="player.timerMinutes > 0">{{ timerDisplay }}</text>
          </view>
        </view>
      </view>
      <view class="play-actions">
        <view class="play-btn" :class="{ active: isLocked }" @click="toggleLock">
          <Icon name="lock" :size="20" :color="isLocked ? 'var(--app-primary)' : 'var(--app-text-3)'" />
        </view>
        <view class="play-btn" :class="{ active: player.showTimerPanel }" @click="player.showTimerPanel = !player.showTimerPanel">
          <Icon name="timer" :size="20" :color="player.timerMinutes > 0 ? 'var(--app-primary)' : 'var(--app-text-3)'" />
        </view>
        <view class="main-btn" :class="{ playing: player.isPlaying }" @click="onMainPlay">
          <Icon :name="player.isPlaying ? 'pause' : 'play'" :size="30" color="var(--app-on-primary)" />
        </view>
        <view class="play-btn" @click="$emit('saveTap')">
          <Icon name="save" :size="20" color="var(--app-text-3)" />
        </view>
      </view>
    </view>

    <!-- 睡眠定时面板 -->
    <view class="timer-panel app-card" v-if="player.showTimerPanel">
      <view class="timer-panel-header">
        <text class="timer-panel-title">睡眠定时</text>
        <view class="timer-close" @click="player.showTimerPanel = false">
          <Icon name="close" :size="16" color="var(--app-text-3)" />
        </view>
      </view>
      <view class="timer-options">
        <view
          class="timer-option"
          :class="{ active: player.timerMinutes === opt.minutes }"
          v-for="opt in timerOptions"
          :key="opt.minutes"
          @click="setTimer(opt.minutes)"
        >
          <text class="timer-option-label">{{ opt.label }}</text>
        </view>
      </view>
      <view class="timer-fade">
        <text class="timer-fade-label">渐弱时长</text>
        <view class="timer-fade-options">
          <view
            class="timer-fade-opt"
            :class="{ active: player.fadeMinutes === f }"
            v-for="f in [1, 2, 3, 5]"
            :key="f"
            @click="player.fadeMinutes = f"
          >
            <text>{{ f }}分钟</text>
          </view>
        </view>
      </view>
    </view>

    <!-- 混音面板（收纳原首页音轨调节） -->
    <view class="mix-panel app-card" v-if="player.showMixPanel">
      <view class="mix-panel-header">
        <text class="mix-panel-title">当前混音</text>
        <view class="mix-panel-count" v-if="player.tracks.length > 0">
          <text>{{ player.tracks.length }}/6 路</text>
        </view>
        <view class="timer-close" @click="player.showMixPanel = false">
          <Icon name="close" :size="16" color="var(--app-text-3)" />
        </view>
      </view>
      <view class="mix-list" v-if="player.tracks.length > 0">
        <MixTrack
          v-for="track in player.tracks"
          :key="track.id"
          :name="track.name"
          :icon-name="track.iconName"
          :color="track.color"
          :volume="track.volume"
          :is-muted="track.muted"
          @mute="toggleTrackMute(track.id)"
          @remove="removeTrack(track.id)"
        />
      </view>
      <view class="mix-empty" v-else>
        <text>暂无音轨，去首页选择一个场景吧</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import Icon from './Icon.vue'
import MixTrack from './MixTrack.vue'
import { player, togglePlay, setTimer, toggleTrackMute, removeTrack } from '@/composables/usePlayer'

defineEmits<{
  saveTap: []
}>()

const isLocked = ref(false)

const timerOptions = [
  { label: '15分钟', minutes: 15 },
  { label: '30分钟', minutes: 30 },
  { label: '45分钟', minutes: 45 },
  { label: '60分钟', minutes: 60 },
  { label: '90分钟', minutes: 90 },
]

const timerDisplay = computed(() => {
  if (player.timerMinutes <= 0) return ''
  return `${player.timerMinutes}分钟`
})

const toggleLock = () => {
  isLocked.value = !isLocked.value
  uni.showToast({ title: isLocked.value ? '已锁定播放' : '已解锁', icon: 'none' })
}

const onMainPlay = () => {
  if (!togglePlay()) {
    uni.showToast({ title: '请先选择场景', icon: 'none' })
  }
}
</script>

<style lang="scss" scoped>
.play-bar {
  position: fixed;
  bottom: var(--app-tab-height, 100rpx);
  left: 26rpx;
  right: 26rpx;
  z-index: 100;
  padding-bottom: calc(16rpx + constant(safe-area-inset-bottom));
  padding-bottom: calc(16rpx + env(safe-area-inset-bottom));
}

.play-bar-inner {
  height: 128rpx;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 20rpx;
}

.play-info {
  display: flex;
  align-items: center;
  gap: 20rpx;
  flex: 1;
}

.play-thumb {
  width: 72rpx;
  height: 72rpx;
  border-radius: 20rpx;
  overflow: hidden;
  background: var(--app-subtle, $uni-bg-color-grey);
  flex-shrink: 0;
  box-shadow: inset 0 -1rpx 0 rgba(0, 0, 0, .08);
}

.mini-logo {
  width: 100%;
  height: 100%;
}

.mini-logo image {
  width: 100%;
  height: 100%;
}

.play-meta {
  display: flex;
  flex-direction: column;
  gap: 8rpx;
  flex: 1;
  min-width: 0;
}

.play-bars {
  display: flex;
  align-items: flex-end;
  gap: 5rpx;
  height: 24rpx;

  .bar {
    width: 5rpx;
    background: var(--app-text-3, $uni-border-color);
    border-radius: 3rpx;

    &:nth-child(1) { height: 10rpx; }
    &:nth-child(2) { height: 20rpx; }
    &:nth-child(3) { height: 14rpx; }
    &:nth-child(4) { height: 17rpx; }
  }

  &.playing .bar {
    background: var(--app-primary, $app-primary);
    animation: wave 1.2s ease-in-out infinite;

    &:nth-child(1) { animation-delay: 0s; }
    &:nth-child(2) { animation-delay: 0.2s; }
    &:nth-child(3) { animation-delay: 0.4s; }
    &:nth-child(4) { animation-delay: 0.6s; }
  }
}

@keyframes wave {
  0%, 100% { transform: scaleY(0.5); }
  50% { transform: scaleY(1.5); }
}

.play-scene-row {
  display: flex;
  align-items: center;
  gap: 10rpx;
}

.play-scene {
  font-size: 26rpx;
  color: var(--app-text, $uni-text-color);
  font-weight: 600;
  letter-spacing: -0.3rpx;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.timer-badge {
  font-size: 18rpx;
  color: var(--app-primary, $app-primary);
  font-weight: 700;
  background: var(--app-primary-soft, rgba($app-primary, 0.1));
  padding: 2rpx 12rpx;
  border-radius: 12rpx;
  letter-spacing: 0.5rpx;
  flex-shrink: 0;
}

.play-actions {
  display: flex;
  align-items: center;
  gap: 18rpx;
}

.play-btn {
  width: 56rpx;
  height: 56rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.16s;

  &:active {
    transform: scale(0.85);
    opacity: 0.6;
  }
}

.main-btn {
  width: 88rpx;
  height: 88rpx;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--app-primary, $app-primary), var(--app-primary-dark, $app-primary-dark));
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 12rpx 26rpx color-mix(in srgb, var(--app-primary, $app-primary) 36%, transparent);
  transition: all 0.16s cubic-bezier(.4, 0, .2, 1);

  &:active {
    transform: scale(0.9);
  }
}

.play-btn.active {
  background: var(--app-primary-soft, rgba($app-primary, 0.1));
  border-radius: 16rpx;
}

/* 面板（定时 / 混音）共用浮层样式 */
.timer-panel,
.mix-panel {
  position: absolute;
  bottom: calc(100% + 16rpx);
  left: 0;
  right: 0;
  padding: 24rpx;
  animation: panelIn 0.2s cubic-bezier(.4, 0, .2, 1) both;
}

@keyframes panelIn {
  from {
    opacity: 0;
    transform: translateY(12rpx);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.timer-panel-header,
.mix-panel-header {
  display: flex;
  align-items: center;
  gap: 14rpx;
  margin-bottom: 20rpx;
}

.timer-panel-title,
.mix-panel-title {
  font-size: 28rpx;
  font-weight: 700;
  color: var(--app-text, $uni-text-color);
  flex: 1;
}

.mix-panel-count {
  padding: 6rpx 20rpx;
  border-radius: 26rpx;
  background: var(--app-primary-soft, rgba($app-primary, 0.12));
  font-size: 21rpx;
  font-weight: 600;
  color: var(--app-primary, $app-primary);
}

.timer-close {
  width: 44rpx;
  height: 44rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 14rpx;
  background: var(--app-subtle, $uni-bg-color-grey);
  transition: all 0.16s;

  &:active {
    transform: scale(0.9);
  }
}

.timer-options {
  display: flex;
  gap: 12rpx;
  margin-bottom: 20rpx;
}

.timer-option {
  flex: 1;
  height: 64rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 18rpx;
  background: var(--app-subtle, $uni-bg-color-grey);
  transition: all 0.16s cubic-bezier(.4, 0, .2, 1);

  &.active {
    background: var(--app-primary, $app-primary);
    box-shadow: 0 6rpx 16rpx color-mix(in srgb, var(--app-primary, $app-primary) 30%, transparent);
  }

  &:active {
    transform: scale(0.94);
  }
}

.timer-option-label {
  font-size: 22rpx;
  font-weight: 600;
  color: var(--app-text, $uni-text-color);

  .timer-option.active & {
    color: #fff;
  }
}

.timer-fade {
  display: flex;
  align-items: center;
  gap: 16rpx;
}

.timer-fade-label {
  font-size: 22rpx;
  color: var(--app-text-2, $uni-text-color-grey);
  flex-shrink: 0;
}

.timer-fade-options {
  display: flex;
  gap: 10rpx;
  flex: 1;
}

.timer-fade-opt {
  flex: 1;
  height: 48rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 14rpx;
  background: var(--app-subtle, $uni-bg-color-grey);
  font-size: 20rpx;
  color: var(--app-text-2, $uni-text-color-grey);
  font-weight: 500;
  transition: all 0.16s;

  &.active {
    background: var(--app-primary-soft, rgba($app-primary, 0.12));
    color: var(--app-primary, $app-primary);
    font-weight: 600;
  }

  &:active {
    transform: scale(0.94);
  }
}

.mix-list {
  max-height: 420rpx;
  overflow-y: auto;
}

.mix-empty {
  padding: 40rpx 0;
  text-align: center;
  font-size: 24rpx;
  color: var(--app-text-2, $uni-text-color-grey);
}
</style>
```

- [ ] **Step 2: 类型检查**

Run: `npm run type-check`
Expected: 无 `PlayBar.vue` 相关错误

- [ ] **Step 3: 提交**

```bash
git add src/components/PlayBar.vue
git commit -m "feat: wire PlayBar to shared player and host mix panel"
```

---

### Task 5: 重写首页 `pages/index/index.vue`（核心）

**Files:**
- Modify: `prototype/src/pages/index/index.vue`（整体重写）

**Interfaces:**
- Consumes: `usePlayer.ts`（`player/applyScene/togglePlay/getRecent/recentTimeLabel`）、`data/scenes.ts`（`homeScenes/sceneCategories/findScene/soundNames`）、`SceneCard`（grid 模式）、`PlayBar`、`TabBar`、`Icon`
- Produces: 页面 7 层结构 + 保存场景弹窗；不再含 Banner 轮播/声音平铺/混音区块

- [ ] **Step 1: 重写 index.vue**

```vue
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
```

- [ ] **Step 2: 类型检查**

Run: `npm run type-check`
Expected: 无 `index.vue` 相关错误

- [ ] **Step 3: 启动 H5 开发服务器手动检查**

Run: `npm run dev:h5`（后台运行）
检查项：
- 首屏：大播放卡空态（moon + 「开始你的助眠之旅」）正常，无 Banner 轮播/声音平铺/旧混音区块
- 点击金刚区「开始助眠」→ 大播放卡切换为「深度睡眠」+ 波线动画 + 播放按钮为暂停态
- 场景网格分类切换过滤正确；点击卡片应用/暂停/切换
- 今日精选横滑 2 张可滑
- PlayBar 点击场景名/图标 → 弹出混音面板（音轨列表 + 静音/移除）；定时面板可用
- 保存场景弹窗可用；最近使用区块出现并记录本次播放
- 6 配色 × 3 UI 风格切换下新组件正常（用主题页验证至少 2 套）

- [ ] **Step 4: 提交**

```bash
git add src/pages/index/index.vue
git commit -m "feat: redesign homepage with hero card, quick actions, scene grid"
```

---

### Task 6: 场景页支持「自然」分类直达

**Files:**
- Modify: `prototype/src/pages/scene/scene.vue`（script 段新增 onShow 处理）

**Interfaces:**
- Consumes: `usePlayer.ts` 的 `player.pendingSceneCategory`
- Produces: 无新导出；行为：首页金刚区「自然放松」切到场景页后自动定位「自然」Tab

- [ ] **Step 1: 新增 onShow 分类定位**

在 `scene.vue` 的 `<script setup lang="ts">` 中：

```ts
import { onShow } from '@dcloudio/uni-app'
import { player } from '@/composables/usePlayer'

onShow(() => {
  if (player.pendingSceneCategory && player.pendingSceneCategory !== 'all') {
    activeTag.value = player.pendingSceneCategory
    player.pendingSceneCategory = 'all'
  }
})
```

- [ ] **Step 2: 类型检查**

Run: `npm run type-check`
Expected: 无 `scene.vue` 相关错误

- [ ] **Step 3: 手动检查**

Run: `npm run dev:h5`
检查项：首页金刚区点「自然放松」→ 跳转场景页且「自然」标签高亮；再次进入场景页回到「全部」默认态。

- [ ] **Step 4: 提交**

```bash
git add src/pages/scene/scene.vue
git commit -m "feat: scene page honors pending category from home quick action"
```

---

## 自审记录（实施前核对）

- **规格覆盖**：①头部（Task5）、②大播放卡+空态（Task5）、③金刚区（Task5）、④今日精选（Task5）、⑤分类+两列网格（Task3+Task5）、⑥最近使用+空隐藏（Task2+Task5）、⑦声音库入口（Task5）、混音面板收纳（Task4）、共享状态（Task2）、场景数据（Task1）、场景页分类直达（Task6）—— 全部覆盖
- **无占位符**：所有步骤含完整代码与验证命令
- **类型一致性**：`Scene`/`Track`/`RecentItem` 字段在 Task1/2 定义，Task3-6 引用一致；`player` 字段名（`showMixPanel/showTimerPanel/pendingSceneCategory`）跨组件一致；`SceneCard` 新 props 名与 Task5 传参一致
