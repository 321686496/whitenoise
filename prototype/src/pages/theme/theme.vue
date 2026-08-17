<template>
  <view class="page-container">
    <view class="header">
      <text class="page-title">主题设置</text>
      <text class="page-subtitle">选择你喜欢的视觉风格与配色</text>
    </view>

    <!-- 风格选择 -->
    <view class="section">
      <text class="section-title">UI 风格</text>
      <view class="style-grid">
        <view
          v-for="style in styles"
          :key="style.key"
          class="style-card"
          :class="{ active: activeStyle === style.key }"
          @click="activeStyle = style.key"
        >
          <view class="style-preview" :class="style.key">
            <view class="preview-bar"></view>
            <view class="preview-card"></view>
            <view class="preview-btn"></view>
          </view>
          <text class="style-name">{{ style.label }}</text>
          <text class="style-desc">{{ style.desc }}</text>
        </view>
      </view>
    </view>

    <!-- 配色选择 -->
    <view class="section">
      <text class="section-title">配色方案</text>
      <view class="color-grid">
        <view
          v-for="color in colors"
          :key="color.key"
          class="color-card"
          :class="{ active: activeColor === color.key }"
          @click="activeColor = color.key"
        >
          <view class="color-preview">
            <view
              class="color-dot"
              v-for="c in color.palette"
              :key="c"
              :style="{ background: c }"
            ></view>
          </view>
          <text class="color-name">{{ color.label }}</text>
        </view>
      </view>
    </view>

    <!-- 预览按钮 -->
    <view class="preview-section">
      <view class="btn-primary preview-btn" @click="applyTheme">
        <text>应用主题</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const activeStyle = ref('flat')
const activeColor = ref('morandi')

const styles = [
  { key: 'flat', label: '扁平化', desc: '简洁克制' },
  { key: 'glass', label: '玻璃拟态', desc: '通透轻盈' },
  { key: 'neu', label: '新拟态', desc: '柔和立体' },
]

const colors = [
  { key: 'morandi', label: '莫兰迪', palette: ['#7B8FA1', '#D4B5B0', '#B0BFA8', '#D4C9B8'] },
  { key: 'ocean', label: '深海', palette: ['#2C3E50', '#3498DB', '#1ABC9C', '#ECF0F1'] },
  { key: 'forest', label: '森林', palette: ['#4A6741', '#7C9D6E', '#A8C3A6', '#F5F0EB'] },
  { key: 'sunset', label: '日落', palette: ['#C48B8B', '#D4A574', '#E8C4A2', '#F5F0EB'] },
  { key: 'lavender', label: '薰衣草', palette: ['#9B8EC4', '#B8B0C4', '#D4C9D8', '#F5F0EB'] },
  { key: 'mono', label: '极简黑白', palette: ['#333333', '#666666', '#999999', '#F5F5F5'] },
]

const applyTheme = () => {
  uni.showToast({ title: '主题已应用', icon: 'success' })
  setTimeout(() => {
    uni.navigateBack()
  }, 800)
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

.style-grid {
  display: flex;
  gap: 20rpx;
}

.style-card {
  flex: 1;
  background: $app-card-bg;
  border-radius: $app-radius;
  padding: 24rpx;
  box-shadow: $app-shadow;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12rpx;
  border: 3rpx solid transparent;
  transition: all 0.2s;

  &.active {
    border-color: $app-primary;
    background: rgba($app-primary, 0.04);
  }
}

.style-preview {
  width: 100%;
  height: 120rpx;
  border-radius: $app-radius-sm;
  padding: 16rpx;
  display: flex;
  flex-direction: column;
  gap: 8rpx;

  &.flat {
    background: $app-card-bg;
  }

  &.glass {
    background: rgba(255, 255, 255, 0.5);
    backdrop-filter: blur(10rpx);
  }

  &.neu {
    background: $app-bg;
    box-shadow: 4rpx 4rpx 8rpx rgba(92, 111, 128, 0.1),
                -4rpx -4rpx 8rpx rgba(255, 255, 255, 0.7);
  }
}

.preview-bar {
  height: 12rpx;
  background: $app-primary;
  border-radius: 6rpx;
  width: 60%;
}

.preview-card {
  flex: 1;
  background: rgba($app-primary, 0.1);
  border-radius: 4rpx;
}

.preview-btn {
  height: 16rpx;
  background: $app-primary;
  border-radius: 8rpx;
  width: 40%;
}

.style-name {
  font-size: 26rpx;
  color: $uni-text-color;
  font-weight: 600;
}

.style-desc {
  font-size: 22rpx;
  color: $uni-text-color-grey;
}

.color-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 16rpx;
}

.color-card {
  width: calc(33.33% - 12rpx);
  background: $app-card-bg;
  border-radius: $app-radius-sm;
  padding: 20rpx;
  box-shadow: $app-shadow;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12rpx;
  border: 3rpx solid transparent;
  transition: all 0.2s;

  &.active {
    border-color: $app-primary;
  }
}

.color-preview {
  display: flex;
  gap: 8rpx;
}

.color-dot {
  width: 32rpx;
  height: 32rpx;
  border-radius: 50%;
}

.color-name {
  font-size: 24rpx;
  color: $uni-text-color;
  font-weight: 500;
}

.preview-section {
  padding: 32rpx;
  display: flex;
  justify-content: center;
}

.preview-btn {
  width: 100%;
  max-width: 400rpx;
  padding: 24rpx;
  font-size: 30rpx;
}
</style>