<template>
  <view class="page-container">
    <view class="page-bg"></view>

    <!-- 顶部导航：收起播放器 -->
    <view class="np-nav">
      <view class="np-nav-btn" aria-label="收起播放器" @click="goBack">
        <Icon name="chevron-down" :size="26" color="var(--app-text)" />
      </view>
      <text class="np-nav-title">正在播放</text>
      <view class="np-nav-placeholder" />
    </view>

    <!-- 空态 -->
    <view class="np-empty app-card" v-if="!player.currentScene">
      <view class="np-empty-ic"><Icon name="moon" :size="40" color="var(--app-primary)" /></view>
      <text class="np-empty-t">还没有在播放的场景</text>
      <text class="np-empty-d">选一个场景或声音，享受此刻的安静</text>
      <view class="btn-primary" @click="goLibrary">去场景库</view>
    </view>

    <!-- 播放态 -->
    <template v-else>
      <scroll-view class="np-scroll" scroll-y>
        <!-- 大封面 -->
        <view class="np-cover-wrap">
          <view class="np-cover" :style="coverStyle" :class="{ playing: player.isPlaying }">
            <image v-if="scene?.image" class="np-cover-img" :src="scene.image" mode="aspectFill" />
            <Icon v-else :name="scene?.iconName || 'wave'" :size="110" color="var(--app-on-primary)" />
          </view>
        </view>

        <!-- 标题区 -->
        <view class="np-meta">
          <text class="np-name">{{ scene?.name }}</text>
          <text class="np-sub">{{ trackCountLabel }} 路音轨 · {{ soundNames }}</text>
          <view class="np-chips">
            <view class="np-chip" v-for="t in player.tracks" :key="t.id" :style="{ '--chip-color': t.color }">
              <Icon :name="t.iconName" :size="14" color="var(--chip-color)" />
              <text class="np-chip-t">{{ t.name }}</text>
            </view>
          </view>
        </view>

        <!-- 进度条 -->
        <view class="np-progress">
          <view
            class="np-prog-groove"
            ref="progRef"
            @touchstart="onTouchStart"
            @touchmove="onTouchMove"
            @touchend="onTouchEnd"
            @touchcancel="onTouchEnd"
            @click="onTap"
          >
            <view class="np-prog-fill" :style="{ width: progressPct + '%' }" />
            <view class="np-prog-knob" :style="{ left: progressPct + '%' }" />
          </view>
          <view class="np-time num">
            <text>{{ fmt(curSec) }}</text>
            <text>{{ fmt(totalSec) }}</text>
          </view>
        </view>

        <!-- 主控排 -->
        <view class="np-controls">
          <view class="np-ctl" :class="{ on: isFav }" aria-label="收藏" @click="toggleFav">
            <Icon name="heart" :size="26" :color="isFav ? 'var(--app-primary)' : 'var(--app-text-2)'" />
          </view>
          <view class="np-ctl" :class="{ on: player.timerMinutes > 0 }" aria-label="睡眠定时" @click="player.showTimerPanel = !player.showTimerPanel">
            <Icon name="timer" :size="26" :color="player.timerMinutes > 0 ? 'var(--app-primary)' : 'var(--app-text-2)'" />
          </view>
          <view class="np-main" aria-label="播放/暂停" @click="onToggle">
            <Icon :name="player.isPlaying ? 'pause' : 'play'" :size="44" color="var(--app-on-primary)" />
          </view>
          <view class="np-ctl" :class="{ on: isLocked }" aria-label="锁定" @click="toggleLock">
            <Icon name="lock" :size="26" :color="isLocked ? 'var(--app-primary)' : 'var(--app-text-2)'" />
          </view>
          <view class="np-ctl" aria-label="保存" @click="onSave">
            <Icon name="save" :size="26" color="var(--app-text-2)" />
          </view>
        </view>

        <!-- 睡眠定时面板 -->
        <view class="np-timer app-card" v-if="player.showTimerPanel">
          <view class="np-timer-head">
            <text class="np-timer-title">睡眠定时</text>
            <text class="np-timer-close" @click="player.showTimerPanel = false">
              <Icon name="close" :size="18" color="var(--app-text-3)" />
            </text>
          </view>
          <view class="np-timer-opts">
            <view
              class="np-timer-opt"
              :class="{ active: player.timerMinutes === o.minutes }"
              v-for="o in timerOptions"
              :key="o.minutes"
              @click="setTimer(o.minutes)"
            >
              <text>{{ o.label }}</text>
            </view>
          </view>
        </view>

        <!-- 当前混音 -->
        <view class="np-mix-head">
          <text class="section-title">当前混音</text>
          <text class="np-mix-count num" v-if="player.tracks.length > 0">{{ player.tracks.length }}/6 路</text>
        </view>
        <view class="np-mix" v-if="player.tracks.length > 0">
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
        </view>
        <view class="np-mix-empty app-card" v-else>
          <text>暂无音轨，去选择场景后调整混音</text>
        </view>
        <view class="np-add" @click="goLibrary">
          <Icon name="mixer" :size="18" color="var(--app-primary)" /><text>添加声音</text>
        </view>
      </scroll-view>
    </template>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, watch, onBeforeUnmount } from 'vue'
import Icon from '@/components/Icon.vue'
import MixTrack from '@/components/MixTrack.vue'
import { player, togglePlay, setTimer, setTrackVolume, toggleTrackMute, removeTrack } from '@/composables/usePlayer'
import { findScene } from '@/data/scenes'
import type { Scene } from '@/data/scenes'

const scene = computed<Scene | null>(() => findScene(player.currentScene?.id ?? '') ?? player.currentScene ?? null)

const coverStyle = computed(() => ({ background: scene.value?.gradient || 'var(--app-surface-2)' }))
const soundNames = computed(() => player.tracks.map((t) => t.name).join(' + '))
const trackCountLabel = computed(() => (player.tracks.length || 0).toString())

/* ------------- 播放控制 ------------- */
const isFav = ref(false)
const isLocked = ref(false)
const totalSec = 200 // 原型无真实音频，取固定演示时长

const curSec = ref(0)
const dragPct = ref<number | null>(null)
let tick: ReturnType<typeof setInterval> | null = null

const progressPct = computed(() => {
  if (dragPct.value !== null) return dragPct.value
  return totalSec > 0 ? (curSec.value / totalSec) * 100 : 0
})

const progRef = ref<null | any>(null)
function seekFromEvent(e: any) {
  const touch = (e.touches && e.touches[0]) || (e.changedTouches && e.changedTouches[0])
  const el = progRef.value as HTMLElement | undefined
  if (!touch || !el || !el.getBoundingClientRect) return
  const rect = el.getBoundingClientRect()
  const width = rect.width || 1
  let ratio = (touch.clientX - rect.left) / width
  ratio = Math.min(1, Math.max(0, ratio))
  dragPct.value = Math.round(ratio * 1000) / 1000
}
function onTouchStart(e: any) { e.stopPropagation(); seekFromEvent(e) }
function onTouchMove(e: any) { e.stopPropagation(); seekFromEvent(e) }
function onTouchEnd() {
  if (dragPct.value !== null) {
    curSec.value = Math.round((dragPct.value / 100) * totalSec)
    dragPct.value = null
  }
}
function onTap(e: any) { seekFromEvent(e) }

function startTick() {
  clearInterval(tick ?? undefined)
  tick = setInterval(() => {
    if (!player.isPlaying) return
    curSec.value += 1
    if (curSec.value >= totalSec) curSec.value = 0 // 循环
  }, 1000)
}
watch(() => player.isPlaying, (p) => { if (p) startTick() }, { immediate: true })
onBeforeUnmount(() => { if (tick) clearInterval(tick) })

const fmt = (s: number) => {
  const m = Math.floor(s / 60)
  const ss = Math.floor(s % 60)
  return `${m}:${ss.toString().padStart(2, '0')}`
}

/* ------------- 交互动作 ------------- */
const onToggle = () => { if (!togglePlay()) uni.showToast({ title: '请先选择场景', icon: 'none' }) }
const toggleFav = () => { isFav.value = !isFav.value }
const toggleLock = () => {
  isLocked.value = !isLocked.value
  uni.showToast({ title: isLocked.value ? '已锁定播放' : '已解锁', icon: 'none' })
}
const onSave = () => uni.showToast({ title: '已保存到收藏', icon: 'none' })

const goBack = () => uni.navigateBack()
const goLibrary = () => uni.navigateTo({ url: '/pages/library/library' })

const timerOptions = [
  { label: '15分钟', minutes: 15 },
  { label: '30分钟', minutes: 30 },
  { label: '45分钟', minutes: 45 },
  { label: '60分钟', minutes: 60 },
  { label: '90分钟', minutes: 90 },
]
</script>

<style lang="scss" scoped>
.np-nav {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8rpx 8rpx 24rpx;
}

.np-nav-btn {
  width: 88rpx;
  height: 88rpx;
  border-radius: 999rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-left: -20rpx;
  transition: transform var(--dur-fast) var(--ease-std), background var(--dur-fast) var(--ease-std);
  &:active { transform: scale(0.96); background: var(--app-press); }
}

.np-nav-title {
  font-size: 24rpx;
  font-weight: 600;
  letter-spacing: 0.3rpx;
  color: var(--app-text-2);
}

.np-nav-placeholder { width: 88rpx; height: 88rpx; }

.np-empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16rpx;
  padding: 88rpx 40rpx;
  text-align: center;
}
.np-empty-ic {
  width: 144rpx; height: 144rpx; border-radius: 999rpx;
  background: var(--app-primary-soft); color: var(--app-primary);
  display: flex; align-items: center; justify-content: center; margin-bottom: 12rpx;
}
.np-empty-t { font-size: 30rpx; font-weight: 700; color: var(--app-text); }
.np-empty-d { font-size: 25rpx; color: var(--app-text-2); margin-bottom: 24rpx; }
.np-empty .btn-primary { margin-top: 12rpx; }

.np-scroll {
  height: calc(100vh - 200rpx);
}

/* 封面 */
.np-cover-wrap { display: flex; justify-content: center; padding: 24rpx 0 40rpx; }
.np-cover {
  width: 520rpx; height: 520rpx; border-radius: 48rpx;
  box-shadow: var(--app-shadow-3), var(--app-inset);
  display: flex; align-items: center; justify-content: center;
  overflow: hidden; position: relative;
  transition: transform var(--dur-slow) var(--ease-std);
}
.np-cover.playing { animation: coverBreath 3.2s var(--ease-std) infinite alternate; }
.np-cover-img { width: 100%; height: 100%; }
@keyframes coverBreath {
  from { transform: scale(1); }
  to { transform: scale(1.035); }
}
@media (prefers-reduced-motion: reduce) { .np-cover.playing { animation: none; } }

/* 标题区 */
.np-meta { display: flex; flex-direction: column; gap: 14rpx; }
.np-name {
  font-size: 42rpx; font-weight: 700; color: var(--app-text);
  letter-spacing: -0.5rpx; line-height: 1.2; text-align: center;
}
.np-sub { font-size: 25rpx; color: var(--app-text-2); text-align: center; }
.np-chips {
  display: flex; flex-wrap: wrap; justify-content: center; gap: 12rpx; margin-top: 8rpx;
}
.np-chip {
  display: flex; align-items: center; gap: 8rpx;
  padding: 8rpx 20rpx; border-radius: 999rpx; font-size: 22rpx;
  background: color-mix(in srgb, var(--chip-color) 14%, var(--app-surface));
  border: 1rpx solid var(--app-line);
  color: var(--app-text);
}
.np-chip-t { color: var(--app-text-2); }

/* 进度条 */
.np-progress { padding: 40rpx 8rpx 8rpx; }
.np-prog-groove {
  position: relative; height: 8rpx; border-radius: 999rpx;
  background: var(--app-sunken); cursor: pointer;
}
.np-prog-fill {
  position: absolute; left: 0; top: 0; height: 100%; border-radius: 999rpx;
  background: linear-gradient(90deg, var(--app-primary), var(--app-primary-strong));
}
.np-prog-knob {
  position: absolute; top: 50%; width: 32rpx; height: 32rpx; border-radius: 999rpx;
  background: var(--app-surface); box-shadow: var(--app-shadow-1), var(--app-inset);
  transform: translate(-50%, -50%);
}
.np-time {
  display: flex; justify-content: space-between; margin-top: 16rpx;
  font-size: 23rpx; color: var(--app-text-3);
}

/* 主控排 */
.np-controls {
  display: flex; align-items: center; justify-content: space-around; padding: 16rpx 8rpx 8rpx;
}
.np-ctl {
  width: 96rpx; height: 96rpx; border-radius: 999rpx;
  display: flex; align-items: center; justify-content: center;
  transition: transform var(--dur-fast) var(--ease-std), background var(--dur-fast) var(--ease-std);
  &:active { transform: scale(0.94); background: var(--app-press); }
  &.on { background: var(--app-primary-soft); }
}
.np-main {
  width: 176rpx; height: 176rpx; border-radius: 999rpx;
  background: linear-gradient(135deg, var(--app-primary), var(--app-primary-strong));
  color: var(--app-on-primary); box-shadow: var(--app-shadow-3);
  display: flex; align-items: center; justify-content: center;
  transition: transform var(--dur-fast) var(--ease-std);
  &:active { transform: scale(0.95); }
}

/* 定时面板 */
.np-timer { margin: 20rpx 8rpx 8rpx; padding: 28rpx 28rpx; }
.np-timer-head { display: flex; align-items: center; justify-content: space-between; margin-bottom: 20rpx; }
.np-timer-title { font-size: 28rpx; font-weight: 700; color: var(--app-text); letter-spacing: -0.3rpx; }
.np-timer-close { width: 64rpx; height: 64rpx; display: flex; align-items: center; justify-content: center; border-radius: 999rpx; margin-right: -8rpx; }
.np-timer-opts { display: flex; flex-wrap: wrap; gap: 14rpx; }
.np-timer-opt {
  min-height: 72rpx; padding: 0 26rpx; border-radius: 999rpx;
  display: flex; align-items: center; justify-content: center; font-size: 24rpx;
  background: var(--app-surface-2); border: 1rpx solid var(--app-line); color: var(--app-text-2);
  transition: transform var(--dur-fast) var(--ease-std);
  &:active { transform: scale(0.96); }
  &.active { background: var(--app-primary); color: var(--app-on-primary); border-color: transparent; font-weight: 600; }
}

/* 混音 */
.np-mix-head {
  display: flex; align-items: center; justify-content: space-between;
  padding: 40rpx 8rpx 16rpx;
  .section-title { margin-bottom: 0; }
}
.np-mix-count {
  padding: 6rpx 20rpx; border-radius: 999rpx; font-size: 21rpx; font-weight: 600;
  background: var(--app-primary-soft); color: var(--app-primary);
}
.np-mix-empty {
  padding: 56rpx 32rpx; text-align: center; font-size: 25rpx; color: var(--app-text-2);
}
.np-add {
  margin-top: 20rpx; min-height: 88rpx; border-radius: 999rpx;
  display: flex; align-items: center; justify-content: center; gap: 12rpx;
  background: var(--app-surface-2); border: 1rpx solid var(--app-line);
  color: var(--app-primary); font-size: 27rpx; font-weight: 600;
  transition: transform var(--dur-fast) var(--ease-std);
  &:active { transform: scale(0.98); }
}
</style>