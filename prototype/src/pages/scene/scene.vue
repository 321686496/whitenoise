<template>
  <view class="page-container">
    <view class="page-bg"></view>

    <!-- 自定义悬浮 TabBar -->
    <TabBar current="scene" />

    <view class="header">
      <text class="page-title">场景</text>
      <text class="page-subtitle">管理你的专属声音场景</text>
    </view>

    <!-- 标签筛选 -->
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
      <view class="section-head">
        <text class="section-title">我的场景</text>
        <view class="new-btn app-card" @click="createScene">
          <Icon name="mixer" :size="16" color="var(--app-primary)" />
          <text class="new-btn-text">新建</text>
        </view>
      </view>
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
        @delete="confirmDelete(scene)"
      />

      <view class="empty-scene app-card" v-if="myScenes.length === 0">
        <view class="empty-icon">
          <Icon name="mountain" :size="52" color="var(--app-primary)" />
        </view>
        <text class="empty-text">还没有自定义场景</text>
        <text class="empty-hint">点击右上角「新建」即可创建，或在首页混音后保存</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import SceneCard from '@/components/SceneCard.vue'
import Icon from '@/components/Icon.vue'
import TabBar from '@/components/TabBar.vue'
import { player } from '@/composables/usePlayer'

interface Scene {
  id: string
  name: string
  soundCount: number
  soundIcons: string[]
  bgColor: string
}

const activeTag = ref('all')
const tags = [
  { id: 'all', label: '全部', icon: 'wave' },
  { id: 'sleep', label: '助眠', icon: 'moon' },
  { id: 'focus', label: '专注', icon: 'flame' },
  { id: 'relax', label: '放松', icon: 'forest' },
  { id: 'nature', label: '自然', icon: 'mountain' },
]

// 首页金刚区「自然放松」等快捷入口直达对应分类
onShow(() => {
  if (player.pendingSceneCategory && player.pendingSceneCategory !== 'all') {
    activeTag.value = player.pendingSceneCategory
    player.pendingSceneCategory = 'all'
  }
})

const presetScenes = ref<Scene[]>([
  { id: 'p1', name: '深度睡眠', soundCount: 3, soundIcons: ['rain', 'fan', 'forest'], bgColor: 'linear-gradient(135deg,#8296A8,#5F7A92)' },
  { id: 'p2', name: '专注白噪', soundCount: 2, soundIcons: ['white-noise', 'pink-noise'], bgColor: 'linear-gradient(135deg,#C49A92,#A97E7A)' },
  { id: 'p3', name: '自然放松', soundCount: 4, soundIcons: ['wave-ocean', 'forest', 'stream', 'fire'], bgColor: 'linear-gradient(135deg,#7E9A74,#5F7A52)' },
  { id: 'p4', name: '城市午后', soundCount: 3, soundIcons: ['coffee', 'fan', 'rain'], bgColor: 'linear-gradient(135deg,#B9A98A,#9A886B)' },
])

const myScenes = ref<Scene[]>([
  { id: 'm1', name: '雨天阅读', soundCount: 3, soundIcons: ['rain', 'fire', 'coffee'], bgColor: 'linear-gradient(135deg,#8E82A6,#6E6290)' },
  { id: 'm2', name: '冥想时刻', soundCount: 2, soundIcons: ['stream', 'forest'], bgColor: 'linear-gradient(135deg,#7F9AA6,#5F7A86)' },
])

const applyScene = (scene: Scene) => {
  uni.showToast({ title: `已应用「${scene.name}」`, icon: 'success' })
  setTimeout(() => {
    uni.switchTab({ url: '/pages/index/index' })
  }, 800)
}

// 新建场景：进入创建向导
const createScene = () => {
  uni.navigateTo({ url: '/pages/scene-edit/scene-edit?sceneId=new' })
}

// 编辑场景：进入编辑向导（原型：也可演示跳详情）
const editScene = (scene: Scene) => {
  uni.navigateTo({ url: `/pages/scene-edit/scene-edit?sceneId=${scene.id}` })
}

const shareScene = (scene: Scene) => {
  uni.showToast({ title: `已生成分享卡片`, icon: 'success' })
}

// 删除场景：二次确认（原型：仅从本地数组移除）
const confirmDelete = (scene: Scene) => {
  uni.showModal({
    title: '删除场景',
    content: `确定删除「${scene.name}」吗？删除后无法恢复`,
    confirmColor: '#C4706B',
    success: (res) => {
      if (res.confirm) {
        myScenes.value = myScenes.value.filter(s => s.id !== scene.id)
        uni.showToast({ title: '已删除', icon: 'success' })
      }
    },
  })
}
</script>

<style lang="scss" scoped>
.header {
  padding: 16rpx 4rpx 8rpx;
}

.page-title {
  font-size: 46rpx;
}

.page-subtitle {
  font-size: 24rpx;
  color: var(--app-text-2, $uni-text-color-grey);
  margin-top: 10rpx;
  display: block;
}

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

.section {
  margin-top: 32rpx;
}

.section-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 18rpx;
  padding-left: 4rpx;
}

.section-head .section-title {
  margin-bottom: 0;
}

.new-btn {
  display: flex;
  align-items: center;
  gap: 8rpx;
  padding: 10rpx 24rpx;
  border-radius: 30rpx;
  transition: all 0.16s cubic-bezier(.4,0,.2,1);

  &:active {
    transform: scale(0.9);
  }
}

.new-btn-text {
  font-size: 23rpx;
  color: var(--app-primary, $app-primary);
  font-weight: 600;
}

.section-title {
  font-size: 24rpx;
  font-weight: 600;
  letter-spacing: 0.3rpx;
  color: var(--app-text-2, $uni-text-color-grey);
  margin-bottom: 18rpx;
  padding-left: 4rpx;
  display: block;
}

.empty-scene {
  padding: 60rpx 32rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12rpx;
}

.empty-icon {
  width: 104rpx;
  height: 104rpx;
  border-radius: 32rpx;
  background: var(--app-primary-soft, rgba($app-primary, 0.1));
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
</style>