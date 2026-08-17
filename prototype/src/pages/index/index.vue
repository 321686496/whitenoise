<template>
  <view class="page-container">
    <!-- 顶部区域 -->
    <view class="header">
      <view class="header-top">
        <text class="app-title">白噪音</text>
        <view class="header-actions">
          <view class="header-btn" @click="goTheme">
            <text>🎨</text>
          </view>
          <view class="header-btn" @click="goAchievement">
            <text>🏆</text>
          </view>
        </view>
      </view>
      <text class="header-subtitle">自由混音，找到属于你的声音</text>
    </view>

    <!-- 声音分类 -->
    <view class="section">
      <text class="section-title">声音库</text>
      <view class="category-tabs">
        <view
          v-for="cat in categories"
          :key="cat.key"
          class="cat-tab"
          :class="{ active: activeCategory === cat.key }"
          @click="activeCategory = cat.key"
        >
          <text>{{ cat.label }}</text>
        </view>
      </view>

      <!-- 声音卡片网格 -->
      <scroll-view scroll-x class="sound-scroll" :show-scrollbar="false">
        <view class="sound-grid">
          <SoundCard
            v-for="sound in filteredSounds"
            :key="sound.id"
            :name="sound.name"
            :type="sound.type"
            :emoji="sound.emoji"
            :color="sound.color"
            :is-active="activeTracks.some(t => t.id === sound.id)"
            @tap="addSound(sound)"
          />
        </view>
      </scroll-view>
    </view>

    <!-- 当前混音 -->
    <view class="section">
      <view class="section-header">
        <text class="section-title">混音面板</text>
        <text class="section-count" v-if="activeTracks.length > 0">
          {{ activeTracks.length }}/{{ maxTracks }} 路
        </text>
      </view>

      <view class="mix-panel" v-if="activeTracks.length > 0">
        <MixTrack
          v-for="track in activeTracks"
          :key="track.id"
          :name="track.name"
          :emoji="track.emoji"
          :color="track.color"
          :volume="track.volume"
          :is-muted="track.muted"
          @mute="toggleMute(track.id)"
          @remove="removeSound(track.id)"
        />
      </view>

      <view class="empty-mix" v-else>
        <text class="empty-icon">🎵</text>
        <text class="empty-text">点击上方声音开始混音</text>
        <text class="empty-hint">最多可混合 {{ maxTracks }} 路声音</text>
      </view>
    </view>

    <!-- 底部播放栏 -->
    <PlayBar
      :is-playing="isPlaying"
      :current-scene="currentScene"
      :timer-remaining="timerDisplay"
      @play-tap="togglePlay"
      @timer-tap="showTimer = true"
      @save-tap="showSaveDialog = true"
      @scene-tap="goScene"
    />

    <!-- 定时器弹窗 -->
    <view class="modal-overlay" v-if="showTimer" @click="showTimer = false">
      <view class="modal-content" @click.stop>
        <text class="modal-title">定时停止</text>
        <view class="timer-options">
          <view
            v-for="t in timerPresets"
            :key="t.value"
            class="timer-option"
            :class="{ active: selectedTimer === t.value }"
            @click="setTimer(t.value)"
          >
            <text class="timer-value">{{ t.label }}</text>
          </view>
        </view>
        <view class="modal-actions">
          <view class="btn-outline" @click="showTimer = false; timerRemaining = 0">取消</view>
        </view>
      </view>
    </view>

    <!-- 保存场景弹窗 -->
    <view class="modal-overlay" v-if="showSaveDialog" @click="showSaveDialog = false">
      <view class="modal-content" @click.stop>
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
import SoundCard from '@/components/SoundCard.vue'
import MixTrack from '@/components/MixTrack.vue'
import PlayBar from '@/components/PlayBar.vue'

// 声音类别
const categories = [
  { key: 'all', label: '全部' },
  { key: 'synthetic', label: '合成系' },
  { key: 'nature', label: '自然' },
  { key: 'urban', label: '城市' },
]
const activeCategory = ref('all')

// 声音数据
interface Sound {
  id: string
  name: string
  type: string
  category: string
  emoji: string
  color: string
}

const sounds = ref<Sound[]>([
  { id: 's1', name: '白噪音', type: '合成', category: 'synthetic', emoji: '📡', color: '#A8B5C0' },
  { id: 's2', name: '粉红噪音', type: '合成', category: 'synthetic', emoji: '🌸', color: '#D4B5B0' },
  { id: 's3', name: '褐噪音', type: '合成', category: 'synthetic', emoji: '🌰', color: '#D4C9B8' },
  { id: 's4', name: '棕噪音', type: '合成', category: 'synthetic', emoji: '🍂', color: '#C4A882' },
  { id: 's5', name: '雨声', type: '自然', category: 'nature', emoji: '🌧️', color: '#A8B5C0' },
  { id: 's6', name: '海浪', type: '自然', category: 'nature', emoji: '🌊', color: '#7B8FA1' },
  { id: 's7', name: '森林', type: '自然', category: 'nature', emoji: '🌲', color: '#B0BFA8' },
  { id: 's8', name: '溪流', type: '自然', category: 'nature', emoji: '💧', color: '#A8B5C0' },
  { id: 's9', name: '篝火', type: '自然', category: 'nature', emoji: '🔥', color: '#C4A882' },
  { id: 's10', name: '咖啡厅', type: '城市', category: 'urban', emoji: '☕', color: '#D4C9B8' },
  { id: 's11', name: '列车', type: '城市', category: 'urban', emoji: '🚂', color: '#B8B0C4' },
  { id: 's12', name: '风扇', type: '城市', category: 'urban', emoji: '🌀', color: '#A8B5C0' },
])

const filteredSounds = computed(() => {
  if (activeCategory.value === 'all') return sounds.value
  return sounds.value.filter(s => s.category === activeCategory.value)
})

// 混音音轨
interface Track {
  id: string
  name: string
  emoji: string
  color: string
  volume: number
  muted: boolean
}

const activeTracks = ref<Track[]>([])
const maxTracks = ref(6)

const addSound = (sound: Sound) => {
  const exists = activeTracks.value.find(t => t.id === sound.id)
  if (exists) return

  if (activeTracks.value.length >= maxTracks.value) {
    uni.showToast({ title: `已达混音上限(${maxTracks.value}路)`, icon: 'none' })
    return
  }

  activeTracks.value.push({
    id: sound.id,
    name: sound.name,
    emoji: sound.emoji,
    color: sound.color,
    volume: 50,
    muted: false,
  })

  if (!isPlaying.value) {
    isPlaying.value = true
  }
}

const removeSound = (id: string) => {
  activeTracks.value = activeTracks.value.filter(t => t.id !== id)
  if (activeTracks.value.length === 0) {
    isPlaying.value = false
  }
}

const toggleMute = (id: string) => {
  const track = activeTracks.value.find(t => t.id === id)
  if (track) track.muted = !track.muted
}

// 播放状态
const isPlaying = ref(false)
const currentScene = ref('')

const togglePlay = () => {
  if (activeTracks.value.length === 0) {
    uni.showToast({ title: '请先添加声音', icon: 'none' })
    return
  }
  isPlaying.value = !isPlaying.value
}

// 定时器
const showTimer = ref(false)
const timerRemaining = ref(0)
const selectedTimer = ref(0)
const timerPresets = [
  { label: '5 分钟', value: 5 },
  { label: '10 分钟', value: 10 },
  { label: '15 分钟', value: 15 },
  { label: '30 分钟', value: 30 },
  { label: '45 分钟', value: 45 },
  { label: '60 分钟', value: 60 },
  { label: '90 分钟', value: 90 },
  { label: '自定义', value: -1 },
]

const timerDisplay = computed(() => {
  if (timerRemaining.value <= 0) return ''
  const m = Math.floor(timerRemaining.value / 60)
  const s = timerRemaining.value % 60
  return `剩余 ${m}:${String(s).padStart(2, '0')}`
})

const setTimer = (value: number) => {
  if (value === -1) {
    // 自定义 - 原型暂用 20 分钟
    value = 20
  }
  selectedTimer.value = value
  timerRemaining.value = value * 60
  showTimer.value = false
}

// 保存场景
const showSaveDialog = ref(false)
const saveName = ref('')

const saveScene = () => {
  if (!saveName.value.trim()) {
    uni.showToast({ title: '请输入场景名称', icon: 'none' })
    return
  }
  currentScene.value = saveName.value
  showSaveDialog.value = false
  saveName.value = ''
  uni.showToast({ title: '场景已保存', icon: 'success' })
}

// 导航
const goScene = () => {
  uni.switchTab({ url: '/pages/scene/scene' })
}
const goTheme = () => {
  uni.navigateTo({ url: '/pages/theme/theme' })
}
const goAchievement = () => {
  uni.navigateTo({ url: '/pages/achievement/achievement' })
}
</script>

<style lang="scss" scoped>
.header {
  padding: 40rpx 32rpx 20rpx;
}

.header-top {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 8rpx;
}

.app-title {
  font-size: 44rpx;
  font-weight: 700;
  color: $uni-text-color;
}

.header-actions {
  display: flex;
  gap: 16rpx;
}

.header-btn {
  width: 64rpx;
  height: 64rpx;
  border-radius: 50%;
  background: $app-card-bg;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28rpx;
  box-shadow: $app-shadow;
}

.header-subtitle {
  font-size: 26rpx;
  color: $uni-text-color-grey;
}

.section {
  padding: 0 32rpx;
  margin-bottom: 32rpx;
}

.section-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 20rpx;
}

.section-title {
  font-size: 32rpx;
  font-weight: 600;
  color: $uni-text-color;
  margin-bottom: 20rpx;
  display: block;
}

.section-header .section-title {
  margin-bottom: 0;
}

.section-count {
  font-size: 24rpx;
  color: $app-primary;
  font-weight: 500;
}

.category-tabs {
  display: flex;
  gap: 16rpx;
  margin-bottom: 24rpx;
}

.cat-tab {
  padding: 12rpx 28rpx;
  border-radius: 24rpx;
  background: $app-card-bg;
  font-size: 26rpx;
  color: $uni-text-color-grey;
  box-shadow: $app-shadow;
  transition: all 0.2s;

  &.active {
    background: $app-primary;
    color: #fff;
  }
}

.sound-scroll {
  white-space: nowrap;
  width: 100%;
}

.sound-grid {
  display: inline-flex;
  gap: 16rpx;
  padding-bottom: 8rpx;
}

.mix-panel {
  background: transparent;
}

.empty-mix {
  background: $app-card-bg;
  border-radius: $app-radius;
  padding: 60rpx 32rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12rpx;
  box-shadow: $app-shadow;
}

.empty-icon {
  font-size: 56rpx;
}

.empty-text {
  font-size: 28rpx;
  color: $uni-text-color;
  font-weight: 500;
}

.empty-hint {
  font-size: 24rpx;
  color: $uni-text-color-grey;
}

/* 弹窗 */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: $uni-bg-color-mask;
  z-index: 200;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 64rpx;
}

.modal-content {
  width: 100%;
  background: $app-card-bg;
  border-radius: $app-radius;
  padding: 40rpx;
  max-width: 600rpx;
}

.modal-title {
  font-size: 32rpx;
  font-weight: 600;
  color: $uni-text-color;
  display: block;
  margin-bottom: 32rpx;
  text-align: center;
}

.timer-options {
  display: flex;
  flex-wrap: wrap;
  gap: 16rpx;
  margin-bottom: 32rpx;
}

.timer-option {
  width: calc(25% - 12rpx);
  padding: 20rpx 0;
  border-radius: $app-radius-sm;
  background: $uni-bg-color-grey;
  text-align: center;
  font-size: 26rpx;
  color: $uni-text-color;
  transition: all 0.2s;

  &.active {
    background: $app-primary;
    color: #fff;
  }
}

.timer-value {
  font-weight: 500;
}

.modal-input {
  height: 88rpx;
  background: $uni-bg-color-grey;
  border-radius: $app-radius-sm;
  padding: 0 24rpx;
  font-size: 28rpx;
  margin-bottom: 32rpx;
  width: 100%;
  box-sizing: border-box;
}

.modal-actions {
  display: flex;
  justify-content: center;
  gap: 24rpx;
}
</style>