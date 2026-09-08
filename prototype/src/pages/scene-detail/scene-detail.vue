<template>
  <view class="page-container">
    <view class="page-bg"></view>

    <view class="cover-section" :style="{ background: coverGradient }">
      <view class="cover-icon-wrap">
        <Icon :name="scene.iconName" :size="120" color="#fff" />
      </view>
      <text class="cover-name">{{ scene.name }}</text>
      <text class="cover-desc">{{ scene.desc }}</text>
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
            <text class="recipe-percent">{{ item.percent }}%</text>
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
      <view class="play-btn" @click="playScene">
        <Icon name="play" :size="22" color="#fff" />
        <text class="play-btn-text">播放此场景</text>
      </view>

      <view class="action-row">
        <view class="action-btn app-card" @click="editScene">
          <Icon name="edit" :size="20" color="var(--app-primary)" />
          <text class="action-text">编辑配方</text>
        </view>
        <view class="action-btn app-card" @click="toggleFavorite">
          <Icon name="save" :size="20" color="var(--app-primary)" />
          <text class="action-text">{{ isFavorited ? '已收藏' : '收藏' }}</text>
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
          <view class="share-icon-wrap">
            <Icon :name="scene.iconName" :size="28" color="#fff" />
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
  </view>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import Icon from '@/components/Icon.vue'
import { findScene, homeScenes, buildRecipe, buildPresets } from '@/data/scenes'
import { applyScene } from '@/composables/usePlayer'

const sceneId = ref('')
const activePreset = ref('标准')
// 收藏状态：按 sceneId 内存级记忆
const favMap = ref<Record<string, boolean>>({})

const scene = computed(() => findScene(sceneId.value) ?? homeScenes[0])
const recipe = computed(() => buildRecipe(scene.value))
const presets = computed(() => buildPresets(scene.value))
const isFavorited = computed(() => !!favMap.value[scene.value.id])

onLoad((options) => {
  sceneId.value = options?.sceneId ?? ''
})

const coverGradient = computed(() => scene.value.gradient)

const applyPreset = (preset: { name: string }) => {
  activePreset.value = preset.name
  uni.showToast({ title: `已切换「${preset.name}」方案`, icon: 'none' })
}

const playScene = () => {
  applyScene(scene.value)
  uni.showToast({ title: '已开始播放', icon: 'success' })
  setTimeout(() => uni.switchTab({ url: '/pages/index/index' }), 800)
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
</script>

<style lang="scss" scoped>
.cover-section {
  margin: -24rpx -26rpx 0;
  padding: 80rpx 40rpx 56rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  position: relative;
}

.cover-icon-wrap {
  width: 240rpx;
  height: 240rpx;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.18);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 32rpx;
  box-shadow: 0 12rpx 40rpx rgba(0, 0, 0, 0.15);
  backdrop-filter: blur(10rpx);
  -webkit-backdrop-filter: blur(10rpx);
}

.cover-name {
  font-size: 44rpx;
  font-weight: 700;
  color: #fff;
  letter-spacing: 3rpx;
  margin-bottom: 12rpx;
  text-shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.15);
}

.cover-desc {
  font-size: 26rpx;
  color: rgba(255, 255, 255, 0.85);
  text-align: center;
  line-height: 1.6;
  padding: 0 20rpx;
}

.section {
  margin-top: 36rpx;
}

.story-card {
  padding: 28rpx 32rpx;
}

.story-text {
  font-size: 28rpx;
  color: var(--app-text, $uni-text-color);
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
  color: var(--app-text, $uni-text-color);
  font-weight: 500;
  flex: 1;
}

.recipe-percent {
  font-size: 24rpx;
  color: var(--app-text-2, $uni-text-color-grey);
  font-weight: 600;
}

.recipe-bar-bg {
  height: 12rpx;
  background: var(--app-subtle, $uni-bg-color-grey);
  border-radius: 6rpx;
  overflow: hidden;
}

.recipe-bar-fill {
  height: 100%;
  border-radius: 6rpx;
  transition: width 0.4s cubic-bezier(.4, 0, .2, 1);
}

.preset-list {
  display: flex;
  flex-direction: column;
  gap: 16rpx;
}

.preset-card {
  padding: 24rpx 28rpx;
  transition: all 0.16s cubic-bezier(.4, 0, .2, 1);

  &:active {
    transform: scale(0.99);
  }

  &.active {
    border-color: var(--app-primary, $app-primary);
    box-shadow: 0 0 0 1rpx var(--app-primary, $app-primary), var(--app-card-shadow);
  }
}

.preset-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 14rpx;
}

.preset-badge {
  padding: 8rpx 24rpx;
  border-radius: 20rpx;
  display: inline-flex;
  align-items: center;
}

.preset-badge-text {
  font-size: 24rpx;
  font-weight: 600;
  color: #fff;
}

.check-wrap {
  width: 36rpx;
  height: 36rpx;
  border-radius: 50%;
  background: var(--app-primary-soft, rgba($app-primary, 0.12));
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
  color: var(--app-text-2, $uni-text-color-grey);
}

.ratio-sep {
  color: var(--app-divider, $uni-border-color);
  margin: 0 4rpx;
}

.play-btn {
  width: 100%;
  background: var(--app-primary, $app-primary);
  border-radius: 26rpx;
  padding: 26rpx 0;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12rpx;
  box-shadow: 0 10rpx 26rpx color-mix(in srgb, var(--app-primary, $app-primary) 30%, transparent);
  transition: all 0.18s cubic-bezier(.4, 0, .2, 1);
  margin-bottom: 20rpx;

  &:active {
    opacity: 0.82;
    transform: scale(0.97);
  }
}

.play-btn-text {
  font-size: 30rpx;
  font-weight: 600;
  color: #fff;
  letter-spacing: 1rpx;
}

.action-row {
  display: flex;
  gap: 20rpx;
}

.action-btn {
  flex: 1;
  padding: 22rpx 0;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10rpx;
  transition: all 0.16s cubic-bezier(.4, 0, .2, 1);

  &:active {
    transform: scale(0.9);
  }
}

.action-text {
  font-size: 26rpx;
  color: var(--app-primary, $app-primary);
  font-weight: 600;
}

.share-card {
  padding: 28rpx 28rpx 20rpx;
  background: linear-gradient(135deg, var(--app-card-bg) 0%, var(--app-subtle, $uni-bg-color-grey) 100%);
}

.share-card-header {
  display: flex;
  align-items: center;
  gap: 18rpx;
  margin-bottom: 20rpx;
}

.share-icon-wrap {
  width: 72rpx;
  height: 72rpx;
  border-radius: 22rpx;
  background: linear-gradient(135deg, #8296A8, #5F7A92);
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
  color: var(--app-text, $uni-text-color);
}

.share-card-stat {
  font-size: 22rpx;
  color: var(--app-text-2, $uni-text-color-grey);
}

.share-card-quote {
  font-size: 26rpx;
  color: var(--app-text, $uni-text-color);
  font-style: italic;
  line-height: 1.6;
  margin-bottom: 20rpx;
  display: block;
}

.share-card-footer {
  padding-top: 16rpx;
  border-top: 1rpx solid var(--app-divider, $uni-border-color);
}

.share-card-brand {
  font-size: 22rpx;
  color: var(--app-text-2, $uni-text-color-grey);
  letter-spacing: 0.5rpx;
}
</style>
