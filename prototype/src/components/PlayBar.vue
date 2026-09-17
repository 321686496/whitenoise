<template>
  <view class="play-bar">
    <view class="play-bar-inner app-card">
      <view class="play-info" @click="goPlayer">
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
  </view>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import Icon from './Icon.vue'
import { player, togglePlay, setTimer } from '@/composables/usePlayer'

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

/* 点击悬浮主控左侧信息区 → 展开完整播放器详情页（听歌软件式收起/展开） */
const goPlayer = () => {
  uni.navigateTo({ url: '/pages/player/player' })
}
</script>

<style lang="scss" scoped>
.play-bar {
  position: fixed;
  bottom: var(--app-tab-height);
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
  /* v2：悬浮主控胶囊（.app-card 已给 44rpx 全圆角），此处仅提升至 shadow-3 */
  box-shadow: var(--app-shadow-3), var(--app-inset);
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
  background: var(--app-sunken);
  flex-shrink: 0;
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
    background: var(--app-text-3);
    border-radius: 3rpx;

    &:nth-child(1) { height: 10rpx; }
    &:nth-child(2) { height: 20rpx; }
    &:nth-child(3) { height: 14rpx; }
    &:nth-child(4) { height: 17rpx; }
  }

  &.playing .bar {
    background: var(--app-primary);
    animation: wave 1.2s var(--ease-std) infinite;

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

/* v2 字排：主文案 Title-3（16px=32rpx） */
.play-scene {
  font-size: 32rpx;
  color: var(--app-text);
  font-weight: 600;
  letter-spacing: -0.3rpx;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.timer-badge {
  font-size: 22rpx;
  color: var(--app-primary);
  font-weight: 700;
  background: var(--app-primary-soft);
  padding: 4rpx 14rpx;
  border-radius: 999rpx;
  letter-spacing: 0.5rpx;
  flex-shrink: 0;
}

.play-actions {
  display: flex;
  align-items: center;
  gap: 4rpx;
}

.play-btn {
  width: 88rpx;
  height: 88rpx;
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

.main-btn {
  width: 88rpx;
  height: 88rpx;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--app-primary), var(--app-primary-strong));
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: var(--app-shadow-2);
  transition: transform var(--dur-fast) var(--ease-std);

  &:active {
    transform: scale(0.96);
  }
}

.play-btn.active {
  background: var(--app-primary-soft);
}

/* 面板（定时 / 混音）共用浮层样式 */
.timer-panel,
.mix-panel {
  position: absolute;
  bottom: calc(100% + 16rpx);
  left: 0;
  right: 0;
  padding: 24rpx;
  animation: panelIn var(--dur-base) var(--ease-std) both;
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
  color: var(--app-text);
  flex: 1;
}

.mix-panel-count {
  padding: 6rpx 20rpx;
  border-radius: 999rpx;
  background: var(--app-primary-soft);
  font-size: 21rpx;
  font-weight: 600;
  color: var(--app-primary);
}

.timer-close {
  width: 88rpx;
  height: 88rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 999rpx;
  transition: transform var(--dur-fast) var(--ease-std), background var(--dur-fast) var(--ease-std);

  &:active {
    transform: scale(0.96);
    background: var(--app-press);
  }
}

.timer-options {
  display: flex;
  gap: 12rpx;
  margin-bottom: 20rpx;
}

.timer-option {
  flex: 1;
  height: 88rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 999rpx;
  background: var(--app-surface-2);
  transition: transform var(--dur-fast) var(--ease-std), background var(--dur-fast) var(--ease-std);

  &.active {
    background: var(--app-primary);
    box-shadow: var(--app-shadow-1);
  }

  &:active {
    transform: scale(0.96);
  }
}

.timer-option-label {
  font-size: 24rpx;
  font-weight: 600;
  color: var(--app-text);

  .timer-option.active & {
    color: var(--app-on-primary);
  }
}

.timer-fade {
  display: flex;
  align-items: center;
  gap: 16rpx;
}

.timer-fade-label {
  font-size: 24rpx;
  color: var(--app-text-2);
  flex-shrink: 0;
}

.timer-fade-options {
  display: flex;
  gap: 10rpx;
  flex: 1;
}

.timer-fade-opt {
  flex: 1;
  height: 64rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 999rpx;
  background: var(--app-surface-2);
  font-size: 20rpx;
  color: var(--app-text-2);
  font-weight: 500;
  transition: transform var(--dur-fast) var(--ease-std), background var(--dur-fast) var(--ease-std);

  &.active {
    background: var(--app-primary-soft);
    color: var(--app-primary);
    font-weight: 600;
  }

  &:active {
    transform: scale(0.96);
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
  color: var(--app-text-2);
}
</style>
