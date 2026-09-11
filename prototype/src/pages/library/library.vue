<template>
  <view class="page-container">
    <view class="page-bg"></view>

    <!-- 顶部标题 -->
    <view class="header">
      <text class="page-title">声音库</text>
      <text class="page-subtitle">内置 30+ 精选白噪音</text>
    </view>

    <!-- 搜索栏 -->
    <view class="search-bar">
      <view class="search-icon">
        <view class="search-circle"></view>
        <view class="search-handle"></view>
      </view>
      <input
        class="search-input"
        v-model="keyword"
        placeholder="搜索声音或场景"
        :placeholder-style="'color: var(--app-text-3); font-size: 26rpx;'"
        confirm-type="search"
      />
      <view class="search-clear" v-if="keyword" @click="keyword = ''">
        <Icon name="close" :size="20" color="var(--app-text-2)" />
      </view>
    </view>

    <!-- 分类分段控制器 -->
    <view class="category-tabs">
      <view
        v-for="cat in soundCategories"
        :key="cat.key"
        class="cat-tab app-card"
        :class="{ active: activeCat === cat.key }"
        @click="activeCat = cat.key"
      >
        <text>{{ cat.label }}</text>
      </view>
    </view>

    <!-- 声音列表 -->
    <view class="sound-list" v-if="filteredSounds.length > 0">
      <view
        class="sound-item app-card"
        v-for="sound in filteredSounds"
        :key="sound.id"
        @click="openDetail(sound)"
      >
        <view class="sound-icon" :style="{ background: sound.color }">
          <Icon :name="sound.iconName" :size="34" color="#fff" />
        </view>
        <view class="sound-info">
          <view class="sound-name-row">
            <text class="sound-name">{{ sound.name }}</text>
            <text class="sound-type">{{ sound.type }}</text>
          </view>
          <text class="sound-desc">{{ sound.desc }}</text>
          <text class="sound-meta">{{ sound.duration }} · {{ sound.sampleRate }} · {{ sound.quality }}</text>
        </view>
        <view class="play-btn" @click.stop="playSound(sound)">
          <Icon name="play" :size="24" color="#fff" />
        </view>
      </view>

      <view class="sound-count">
        <text>共 {{ filteredSounds.length }} 个声音</text>
      </view>
    </view>

    <!-- 空状态 -->
    <view class="empty-state" v-else>
      <view class="empty-icon-wrap">
        <Icon name="wave" :size="64" color="var(--app-text-3)" />
      </view>
      <text class="empty-text">未找到相关声音</text>
      <text class="empty-hint">换个关键词试试吧</text>
    </view>

    <!-- 声音详情弹窗（底部滑入） -->
    <view class="sheet-overlay" v-if="selected" @click="closeDetail">
      <view class="sheet app-card" @click.stop>
        <view class="sheet-handle"></view>

        <view class="sheet-hero" :style="{ background: selected.gradient }">
          <view class="sheet-icon">
            <Icon :name="selected.iconName" :size="64" color="#fff" />
          </view>
          <text class="sheet-name">{{ selected.name }}</text>
          <text class="sheet-type">{{ selected.type }}</text>
          <text class="sheet-desc">{{ selected.desc }}</text>
        </view>

        <view class="meta-table">
          <view class="meta-row" v-for="row in metaRows" :key="row.label">
            <text class="meta-label">{{ row.label }}</text>
            <text class="meta-value">{{ row.value }}</text>
          </view>
        </view>

        <view class="tags-section">
          <text class="tags-title">适用场景</text>
          <view class="tag-list">
            <view class="tag-chip" v-for="tag in selected.scenes" :key="tag">
              <text>{{ tag }}</text>
            </view>
          </view>
        </view>

        <view class="sheet-actions">
          <view class="btn-primary sheet-play" @click="playSound(selected)">
            <Icon name="play" :size="20" color="var(--app-on-primary)" />
            <text>播放</text>
          </view>
          <view class="btn-outline sheet-mix" @click="mixSound(selected)">
            <Icon name="mixer" :size="20" color="var(--app-primary)" />
            <text>加入混音</text>
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import Icon from '@/components/Icon.vue'
import { sounds as soundListData, soundCategories } from '@/data/sounds'
import type { Sound } from '@/data/sounds'

const keyword = ref('')
const activeCat = ref('all')

// 数据源为普通数组，包一层 ref 以支持响应式过滤（sounds.value）
const sounds = ref(soundListData)

const filteredSounds = computed(() => {
  return sounds.value.filter(s => {
    const matchCat = activeCat.value === 'all' || s.category === activeCat.value
    const kw = keyword.value.trim().toLowerCase()
    const matchKw = !kw || s.name.toLowerCase().includes(kw) || s.desc.toLowerCase().includes(kw) || s.type.toLowerCase().includes(kw)
    return matchCat && matchKw
  })
})

// 声音详情弹窗
const selected = ref<Sound | null>(null)

const metaRows = computed(() => {
  if (!selected.value) return []
  const s = selected.value
  return [
    { label: '时长', value: s.duration },
    { label: '采样率', value: s.sampleRate },
    { label: '音质', value: s.quality },
    { label: '循环片段', value: s.loopLength },
    { label: '来源', value: s.source },
  ]
})

const openDetail = (sound: Sound) => {
  selected.value = sound
}

const closeDetail = () => {
  selected.value = null
}

const playSound = (sound: Sound | null) => {
  if (!sound) return
  uni.showToast({ title: `正在播放 ${sound.name}`, icon: 'none' })
}

const mixSound = (sound: Sound | null) => {
  if (!sound) return
  closeDetail()
  uni.showToast({ title: `${sound.name} 已加入混音`, icon: 'success' })
}
</script>

<style lang="scss" scoped>
.page-container {
  padding-bottom: calc(220rpx + env(safe-area-inset-bottom));
}

.header {
  padding: 16rpx 4rpx 8rpx;
}

.page-title {
  font-size: 46rpx;
  font-weight: 700;
  letter-spacing: -1rpx;
  color: var(--app-text, $uni-text-color);
}

.page-subtitle {
  font-size: 24rpx;
  color: var(--app-text-2, $uni-text-color-grey);
  margin-top: 10rpx;
  display: block;
}

/* ---------- 搜索栏（iOS 风格） ---------- */
.search-bar {
  display: flex;
  align-items: center;
  gap: 16rpx;
  height: 80rpx;
  padding: 0 24rpx;
  margin-top: 12rpx;
  border-radius: 20rpx;
  background: var(--app-subtle, $uni-bg-color-grey);
  border: 1rpx solid var(--app-input-border, transparent);
}

.search-icon {
  position: relative;
  width: 30rpx;
  height: 30rpx;
  flex-shrink: 0;
}

.search-circle {
  position: absolute;
  left: 0;
  top: 0;
  width: 20rpx;
  height: 20rpx;
  border: 3rpx solid var(--app-text-2, $uni-text-color-grey);
  border-radius: 50%;
  box-sizing: border-box;
}

.search-handle {
  position: absolute;
  right: 1rpx;
  bottom: 3rpx;
  width: 3rpx;
  height: 12rpx;
  border-radius: 2rpx;
  background: var(--app-text-2, $uni-text-color-grey);
  transform: rotate(-45deg);
}

.search-input {
  flex: 1;
  height: 100%;
  font-size: 26rpx;
  color: var(--app-text, $uni-text-color);
}

.search-clear {
  width: 40rpx;
  height: 40rpx;
  border-radius: 50%;
  background: var(--app-card-bg, #fff);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

/* ---------- 分类分段控制器 ---------- */
.category-tabs {
  display: flex;
  gap: 8rpx;
  margin: 24rpx 0 26rpx;
  padding: 8rpx;
  background: var(--app-subtle, $uni-bg-color-grey);
  border-radius: 30rpx;
}

.cat-tab {
  flex: 1;
  height: 64rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 24rpx;
  font-size: 23rpx;
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

  &:active {
    transform: scale(0.96);
  }
}

/* ---------- 声音列表 ---------- */
.sound-list {
  display: flex;
  flex-direction: column;
  gap: 16rpx;
}

.sound-item {
  display: flex;
  align-items: center;
  gap: 20rpx;
  padding: 20rpx 24rpx;
  transition: all 0.16s cubic-bezier(.4, 0, .2, 1);

  &:active {
    transform: scale(0.99);
  }
}

.sound-icon {
  width: 76rpx;
  height: 76rpx;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  box-shadow: inset 0 -2rpx 0 rgba(0, 0, 0, 0.08), inset 0 2rpx 0 rgba(255, 255, 255, 0.25), 0 6rpx 14rpx rgba(0, 0, 0, 0.1);
}

.sound-info {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 6rpx;
}

.sound-name-row {
  display: flex;
  align-items: center;
  gap: 10rpx;
}

.sound-name {
  font-size: 28rpx;
  font-weight: 600;
  color: var(--app-text, $uni-text-color);
  letter-spacing: -0.3rpx;
}

.sound-type {
  font-size: 20rpx;
  padding: 2rpx 14rpx;
  border-radius: 12rpx;
  background: var(--app-primary-soft, rgba($app-primary, 0.1));
  color: var(--app-primary, $app-primary);
  font-weight: 500;
  flex-shrink: 0;
}

.sound-desc {
  font-size: 22rpx;
  color: var(--app-text-2, $uni-text-color-grey);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.sound-meta {
  font-size: 20rpx;
  color: var(--app-text-3, $uni-text-color-grey);
}

.play-btn {
  width: 64rpx;
  height: 64rpx;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--app-primary, $app-primary), var(--app-primary-dark, $app-primary-dark));
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  box-shadow: 0 8rpx 18rpx color-mix(in srgb, var(--app-primary, $app-primary) 30%, transparent);
  transition: all 0.16s cubic-bezier(.4, 0, .2, 1);

  &:active {
    transform: scale(0.88);
  }
}

.sound-count {
  text-align: center;
  font-size: 22rpx;
  color: var(--app-text-3, $uni-text-color-grey);
  padding: 28rpx 0 8rpx;
}

/* ---------- 空状态 ---------- */
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 14rpx;
  padding: 110rpx 32rpx;
}

.empty-icon-wrap {
  width: 132rpx;
  height: 132rpx;
  border-radius: 40rpx;
  background: var(--app-subtle, $uni-bg-color-grey);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 6rpx;
}

.empty-text {
  font-size: 28rpx;
  color: var(--app-text, $uni-text-color);
  font-weight: 600;
}

.empty-hint {
  font-size: 23rpx;
  color: var(--app-text-2, $uni-text-color-grey);
}

/* ---------- 声音详情弹窗（底部滑入） ---------- */
.sheet-overlay {
  position: fixed;
  left: 0;
  top: 0;
  right: 0;
  bottom: 0;
  background: var(--app-overlay, rgba(0, 0, 0, 0.38));
  z-index: 300;
  display: flex;
  align-items: flex-end;
}

.sheet {
  width: 100%;
  border-radius: 32rpx 32rpx 0 0;
  padding: 16rpx 28rpx calc(36rpx + env(safe-area-inset-bottom));
  animation: sheetUp 0.28s cubic-bezier(.4, 0, .2, 1);
  max-height: 88vh;
  overflow-y: auto;
}

@keyframes sheetUp {
  from {
    transform: translateY(60%);
    opacity: 0.6;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}

.sheet-handle {
  width: 72rpx;
  height: 8rpx;
  border-radius: 4rpx;
  background: var(--app-divider, $uni-border-color);
  margin: 0 auto 20rpx;
}

.sheet-hero {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10rpx;
  padding: 30rpx 24rpx;
  border-radius: 24rpx;
}

.sheet-icon {
  width: 120rpx;
  height: 120rpx;
  border-radius: 32rpx;
  background: rgba(255, 255, 255, 0.18);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 6rpx;
  backdrop-filter: blur(8rpx);
  -webkit-backdrop-filter: blur(8rpx);
  box-shadow: inset 0 -2rpx 0 rgba(0, 0, 0, 0.08), inset 0 2rpx 0 rgba(255, 255, 255, 0.25);
}

.sheet-name {
  font-size: 36rpx;
  font-weight: 700;
  color: #fff;
  letter-spacing: 1rpx;
  text-shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.15);
}

.sheet-type {
  font-size: 22rpx;
  color: rgba(255, 255, 255, 0.8);
}

.sheet-desc {
  font-size: 24rpx;
  color: rgba(255, 255, 255, 0.9);
  line-height: 1.6;
  text-align: center;
}

/* 元数据表格 */
.meta-table {
  margin-top: 24rpx;
}

.meta-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16rpx 8rpx;
  border-bottom: 1rpx solid var(--app-divider, $uni-border-color);
}

.meta-row:last-child {
  border-bottom: none;
}

.meta-label {
  font-size: 24rpx;
  color: var(--app-text-2, $uni-text-color-grey);
}

.meta-value {
  font-size: 24rpx;
  color: var(--app-text, $uni-text-color);
  font-weight: 500;
  text-align: right;
  margin-left: 24rpx;
}

/* 适用场景 */
.tags-section {
  margin-top: 24rpx;
}

.tags-title {
  font-size: 24rpx;
  font-weight: 600;
  color: var(--app-text-2, $uni-text-color-grey);
  display: block;
}

.tag-list {
  display: flex;
  flex-wrap: wrap;
  gap: 12rpx;
  margin-top: 14rpx;
}

.tag-chip {
  padding: 8rpx 22rpx;
  border-radius: 24rpx;
  background: var(--app-primary-soft, rgba($app-primary, 0.1));
  color: var(--app-primary, $app-primary);
  font-size: 23rpx;
  font-weight: 500;
}

/* 操作按钮 */
.sheet-actions {
  display: flex;
  gap: 20rpx;
  margin-top: 32rpx;
}

.sheet-play {
  flex: 1;
  gap: 10rpx;
}

.sheet-mix {
  flex: 1;
  gap: 10rpx;
}
</style>
