<template>
  <view class="page-container">
    <view class="page-bg"></view>

    <view class="header">
      <text class="page-title">我的收藏</text>
      <text class="page-subtitle">你珍藏的声音</text>
    </view>

    <view class="category-tabs">
      <view
        v-for="tab in tabs"
        :key="tab.key"
        class="cat-tab app-card"
        :class="{ active: activeTab === tab.key }"
        @click="activeTab = tab.key"
      >
        <text>{{ tab.label }}</text>
      </view>
    </view>

    <view class="section" v-if="activeTab === 'scenes'">
      <view v-if="favScenes.length > 0">
        <view
          class="scene-item app-card"
          v-for="(scene, idx) in favScenes"
          :key="scene.id"
        >
          <view class="scene-cover" :style="{ background: scene.gradient }"></view>
          <view class="scene-info">
            <text class="scene-name">{{ scene.name }}</text>
            <view class="scene-meta">
              <text class="scene-meta-text">{{ scene.soundCount }} 个声音</text>
              <view class="meta-dot" />
              <text class="scene-meta-text">播放 {{ scene.playCount }} 次</text>
            </view>
          </view>
          <view class="scene-actions">
            <view class="action-btn" @click="playScene(scene)">
              <Icon name="play" :size="18" color="var(--app-primary)" />
            </view>
            <view class="action-btn" @click="removeScene(idx)">
              <Icon name="close" :size="18" color="var(--app-text-2)" />
            </view>
          </view>
        </view>
        <view class="footer-count">
          <text class="footer-text">共 {{ favScenes.length }} 个收藏</text>
        </view>
      </view>

      <view class="empty-state app-card" v-else>
        <Icon name="wave" :size="56" color="var(--app-primary-soft)" />
        <text class="empty-text">还没有收藏场景</text>
        <text class="empty-hint">在混音面板中保存你喜欢的声音组合</text>
      </view>
    </view>

    <view class="section" v-if="activeTab === 'sounds'">
      <view v-if="favSounds.length > 0">
        <view class="sound-grid">
          <view
            class="sound-item app-card"
            v-for="(sound, idx) in favSounds"
            :key="sound.id"
            @click="addSoundToMix(sound)"
          >
            <view class="sound-icon-wrap" :style="{ background: sound.colorSoft }">
              <Icon :name="sound.iconName" :size="26" color="var(--app-primary)" />
            </view>
            <text class="sound-name">{{ sound.name }}</text>
          </view>
        </view>
      </view>

      <view class="empty-state app-card" v-else>
        <Icon name="wave" :size="56" color="var(--app-primary-soft)" />
        <text class="empty-text">还没有收藏声音</text>
        <text class="empty-hint">在声音库中收藏你喜欢的声音</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import Icon from '@/components/Icon.vue'

const tabs = [
  { key: 'scenes', label: '收藏场景' },
  { key: 'sounds', label: '收藏声音' },
]
const activeTab = ref('scenes')

interface FavScene {
  id: string
  name: string
  gradient: string
  soundCount: number
  playCount: number
}

const favScenes = ref<FavScene[]>([
  { id: 'fs1', name: '深夜雨声', gradient: 'linear-gradient(135deg, #5B7B8F 0%, #3D5A6E 100%)', soundCount: 3, playCount: 12 },
  { id: 'fs2', name: '森林晨曦', gradient: 'linear-gradient(135deg, #7E9A74 0%, #5A7A52 100%)', soundCount: 4, playCount: 8 },
  { id: 'fs3', name: '咖啡厅时光', gradient: 'linear-gradient(135deg, #A89068 0%, #8A7452 100%)', soundCount: 2, playCount: 15 },
  { id: 'fs4', name: '海浪入眠', gradient: 'linear-gradient(135deg, #5F8296 0%, #3D6478 100%)', soundCount: 3, playCount: 20 },
])

interface FavSound {
  id: string
  name: string
  iconName: string
  color: string
  colorSoft: string
}

const favSounds = ref<FavSound[]>([
  { id: 'fv1', name: '雨声', iconName: 'rain', color: '#7E93A8', colorSoft: 'rgba(126, 147, 168, 0.15)' },
  { id: 'fv2', name: '白噪音', iconName: 'white-noise', color: '#8296A8', colorSoft: 'rgba(130, 150, 168, 0.15)' },
  { id: 'fv3', name: '森林', iconName: 'forest', color: '#7E9A74', colorSoft: 'rgba(126, 154, 116, 0.15)' },
  { id: 'fv4', name: '篝火', iconName: 'fire', color: '#B97A48', colorSoft: 'rgba(185, 122, 72, 0.15)' },
  { id: 'fv5', name: '海浪', iconName: 'wave-ocean', color: '#5F8296', colorSoft: 'rgba(95, 130, 150, 0.15)' },
])

const playScene = (scene: FavScene) => {
  uni.showToast({ title: `播放「${scene.name}」`, icon: 'none' })
}

const removeScene = (idx: number) => {
  favScenes.value.splice(idx, 1)
  uni.showToast({ title: '已取消收藏', icon: 'none' })
}

const addSoundToMix = (sound: FavSound) => {
  uni.showToast({ title: `已添加「${sound.name}」到混音`, icon: 'none' })
}
</script>

<style lang="scss" scoped>
.header {
  padding: 16rpx 4rpx 8rpx;
}

.category-tabs {
  display: flex;
  gap: 8rpx;
  margin-top: 28rpx;
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

.section {
  margin-top: 32rpx;
}

.scene-item {
  padding: 24rpx;
  display: flex;
  align-items: center;
  gap: 20rpx;
  margin-bottom: 16rpx;
  transition: transform 0.16s cubic-bezier(.4, 0, .2, 1);

  &:active {
    transform: scale(0.99);
  }
}

.scene-cover {
  width: 88rpx;
  height: 88rpx;
  border-radius: 22rpx;
  flex-shrink: 0;
}

.scene-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 8rpx;
  min-width: 0;
}

.scene-name {
  font-size: 29rpx;
  font-weight: 600;
  color: var(--app-text, $uni-text-color);
}

.scene-meta {
  display: flex;
  align-items: center;
  gap: 8rpx;
}

.scene-meta-text {
  font-size: 22rpx;
  color: var(--app-text-2, $uni-text-color-grey);
}

.meta-dot {
  width: 6rpx;
  height: 6rpx;
  border-radius: 50%;
  background: var(--app-text-2, $uni-text-color-grey);
  opacity: 0.5;
}

.scene-actions {
  display: flex;
  align-items: center;
  gap: 12rpx;
  flex-shrink: 0;
}

.action-btn {
  width: 60rpx;
  height: 60rpx;
  border-radius: 20rpx;
  background: var(--app-primary-soft, rgba($app-primary, 0.12));
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.16s cubic-bezier(.4, 0, .2, 1);

  &:active {
    transform: scale(0.9);
  }
}

.footer-count {
  padding: 20rpx 0;
  text-align: center;
}

.footer-text {
  font-size: 23rpx;
  color: var(--app-text-2, $uni-text-color-grey);
}

.sound-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 20rpx;
}

.sound-item {
  width: calc(33.33% - 14rpx);
  padding: 28rpx 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16rpx;
  transition: transform 0.16s cubic-bezier(.4, 0, .2, 1);

  &:active {
    transform: scale(0.95);
  }
}

.sound-icon-wrap {
  width: 80rpx;
  height: 80rpx;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.sound-name {
  font-size: 24rpx;
  color: var(--app-text, $uni-text-color);
  font-weight: 500;
}

.empty-state {
  padding: 80rpx 40rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16rpx;
}

.empty-text {
  font-size: 29rpx;
  color: var(--app-text, $uni-text-color);
  font-weight: 500;
  margin-top: 8rpx;
}

.empty-hint {
  font-size: 23rpx;
  color: var(--app-text-2, $uni-text-color-grey);
}
</style>
