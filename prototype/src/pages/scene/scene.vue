<template>
  <view class="page-container">
    <view class="header">
      <text class="page-title">场景管理</text>
      <text class="page-subtitle">管理你的专属声音场景</text>
    </view>

    <!-- 预设场景 -->
    <view class="section">
      <text class="section-title">官方预设</text>
      <SceneCard
        v-for="scene in presetScenes"
        :key="scene.id"
        :name="scene.name"
        :sound-count="scene.soundCount"
        :sound-icons="scene.soundIcons"
        :bg-color="scene.bgColor"
        :is-preset="true"
        @play="applyScene(scene)"
      />
    </view>

    <!-- 我的场景 -->
    <view class="section">
      <text class="section-title">我的场景</text>
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
        @play="applyScene(scene)"
      />

      <view class="empty-scene" v-if="myScenes.length === 0">
        <text class="empty-icon">📋</text>
        <text class="empty-text">还没有自定义场景</text>
        <text class="empty-hint">在首页混音后点击保存即可创建</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import SceneCard from '@/components/SceneCard.vue'

interface Scene {
  id: string
  name: string
  soundCount: number
  soundIcons: string[]
  bgColor: string
}

const presetScenes = ref<Scene[]>([
  { id: 'p1', name: '深度睡眠', soundCount: 3, soundIcons: ['🌧️', '🌀', '🌲'], bgColor: '#A8B5C0' },
  { id: 'p2', name: '专注白噪', soundCount: 2, soundIcons: ['📡', '🌸'], bgColor: '#D4B5B0' },
  { id: 'p3', name: '自然放松', soundCount: 4, soundIcons: ['🌊', '🌲', '💧', '🔥'], bgColor: '#B0BFA8' },
  { id: 'p4', name: '城市午后', soundCount: 3, soundIcons: ['☕', '🌀', '🌧️'], bgColor: '#D4C9B8' },
])

const myScenes = ref<Scene[]>([
  { id: 'm1', name: '雨天阅读', soundCount: 3, soundIcons: ['🌧️', '🔥', '☕'], bgColor: '#B8B0C4' },
  { id: 'm2', name: '冥想时刻', soundCount: 2, soundIcons: ['💧', '🌲'], bgColor: '#7B8FA1' },
])

const applyScene = (scene: Scene) => {
  uni.showToast({ title: `已应用「${scene.name}」`, icon: 'success' })
  setTimeout(() => {
    uni.switchTab({ url: '/pages/index/index' })
  }, 800)
}

const editScene = (scene: Scene) => {
  uni.showToast({ title: `编辑「${scene.name}」`, icon: 'none' })
}

const shareScene = (scene: Scene) => {
  uni.showToast({ title: `已生成分享卡片`, icon: 'success' })
}
</script>

<style lang="scss" scoped>
.header {
  padding: 40rpx 32rpx 20rpx;
}

.page-title {
  font-size: 44rpx;
  font-weight: 700;
  color: $uni-text-color;
  display: block;
}

.page-subtitle {
  font-size: 26rpx;
  color: $uni-text-color-grey;
  margin-top: 8rpx;
  display: block;
}

.section {
  padding: 0 32rpx;
  margin-bottom: 32rpx;
}

.section-title {
  font-size: 32rpx;
  font-weight: 600;
  color: $uni-text-color;
  margin-bottom: 20rpx;
  display: block;
}

.empty-scene {
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
</style>