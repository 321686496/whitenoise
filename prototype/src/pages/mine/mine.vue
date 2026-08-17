<template>
  <view class="page-container">
    <view class="header">
      <view class="user-card">
        <view class="avatar">
          <text>🎵</text>
        </view>
        <view class="user-info">
          <text class="user-name">白噪音用户</text>
          <text class="user-desc">已陪伴你 12 天</text>
        </view>
        <view class="edit-btn">
          <text>✏️</text>
        </view>
      </view>
    </view>

    <!-- 使用统计 -->
    <view class="section">
      <view class="stats-row">
        <view class="stat-item">
          <text class="stat-value">128</text>
          <text class="stat-label">累计播放(分)</text>
        </view>
        <view class="stat-item">
          <text class="stat-value">12</text>
          <text class="stat-label">连续天数</text>
        </view>
        <view class="stat-item">
          <text class="stat-value">5</text>
          <text class="stat-label">场景数</text>
        </view>
        <view class="stat-item">
          <text class="stat-value">3</text>
          <text class="stat-label">成就</text>
        </view>
      </view>
    </view>

    <!-- 功能入口 -->
    <view class="section">
      <view class="menu-card">
        <view class="menu-item" @click="goAchievement">
          <view class="menu-icon">
            <text>🏆</text>
          </view>
          <text class="menu-label">成就墙</text>
          <view class="menu-badge">3/8</view>
          <text class="menu-arrow">›</text>
        </view>
        <view class="divider" />
        <view class="menu-item" @click="goInvite">
          <view class="menu-icon">
            <text>🎁</text>
          </view>
          <text class="menu-label">邀请好友</text>
          <view class="menu-badge primary">2 人已加入</view>
          <text class="menu-arrow">›</text>
        </view>
        <view class="divider" />
        <view class="menu-item" @click="goTheme">
          <view class="menu-icon">
            <text>🎨</text>
          </view>
          <text class="menu-label">主题设置</text>
          <text class="menu-value">莫兰迪 · 扁平化</text>
          <text class="menu-arrow">›</text>
        </view>
        <view class="divider" />
        <view class="menu-item" @click="goSettings">
          <view class="menu-icon">
            <text>⚙️</text>
          </view>
          <text class="menu-label">设置</text>
          <text class="menu-arrow">›</text>
        </view>
      </view>
    </view>

    <!-- 最近成就 -->
    <view class="section">
      <text class="section-title">最近成就</text>
      <view class="recent-achievements">
        <view class="achi-chip" v-for="ach in recentAchievements" :key="ach.id">
          <text class="achi-icon">{{ ach.icon }}</text>
          <text class="achi-name">{{ ach.name }}</text>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const recentAchievements = ref([
  { id: 'a1', name: '初次入眠', icon: '🌙' },
  { id: 'a2', name: '连续七天', icon: '🔥' },
  { id: 'a3', name: '声音调音师', icon: '🎛️' },
])

const goAchievement = () => uni.navigateTo({ url: '/pages/achievement/achievement' })
const goInvite = () => uni.navigateTo({ url: '/pages/invite/invite' })
const goTheme = () => uni.navigateTo({ url: '/pages/theme/theme' })
const goSettings = () => uni.navigateTo({ url: '/pages/settings/settings' })
</script>

<style lang="scss" scoped>
.header {
  padding: 40rpx 32rpx 20rpx;
}

.user-card {
  background: $app-card-bg;
  border-radius: $app-radius;
  padding: 32rpx;
  box-shadow: $app-shadow;
  display: flex;
  align-items: center;
  gap: 24rpx;
}

.avatar {
  width: 96rpx;
  height: 96rpx;
  border-radius: 50%;
  background: $uni-bg-color-grey;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 44rpx;
}

.user-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 6rpx;
}

.user-name {
  font-size: 32rpx;
  font-weight: 600;
  color: $uni-text-color;
}

.user-desc {
  font-size: 24rpx;
  color: $uni-text-color-grey;
}

.edit-btn {
  width: 64rpx;
  height: 64rpx;
  border-radius: 50%;
  background: $uni-bg-color-grey;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28rpx;
}

.section {
  padding: 0 32rpx;
  margin-bottom: 32rpx;
}

.stats-row {
  background: $app-card-bg;
  border-radius: $app-radius;
  padding: 28rpx 16rpx;
  box-shadow: $app-shadow;
  display: flex;
}

.stat-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6rpx;
}

.stat-value {
  font-size: 36rpx;
  font-weight: 700;
  color: $app-primary;
}

.stat-label {
  font-size: 22rpx;
  color: $uni-text-color-grey;
}

.menu-card {
  background: $app-card-bg;
  border-radius: $app-radius;
  box-shadow: $app-shadow;
  overflow: hidden;
}

.menu-item {
  padding: 28rpx 24rpx;
  display: flex;
  align-items: center;
  gap: 20rpx;

  &:active {
    background: $uni-bg-color-hover;
  }
}

.menu-icon {
  width: 56rpx;
  height: 56rpx;
  border-radius: 50%;
  background: $uni-bg-color-grey;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28rpx;
}

.menu-label {
  font-size: 28rpx;
  color: $uni-text-color;
  flex: 1;
}

.menu-badge {
  font-size: 22rpx;
  padding: 4rpx 14rpx;
  border-radius: 20rpx;
  background: $uni-bg-color-grey;
  color: $uni-text-color-grey;

  &.primary {
    background: rgba($app-primary, 0.12);
    color: $app-primary;
  }
}

.menu-value {
  font-size: 22rpx;
  color: $uni-text-color-grey;
}

.menu-arrow {
  font-size: 32rpx;
  color: $uni-text-color-grey;
}

.section-title {
  font-size: 28rpx;
  font-weight: 600;
  color: $uni-text-color-grey;
  margin-bottom: 16rpx;
  display: block;
  padding-left: 4rpx;
}

.recent-achievements {
  display: flex;
  gap: 16rpx;
  flex-wrap: wrap;
}

.achi-chip {
  background: $app-card-bg;
  border-radius: 24rpx;
  padding: 12rpx 24rpx;
  box-shadow: $app-shadow;
  display: flex;
  align-items: center;
  gap: 8rpx;
}

.achi-icon {
  font-size: 24rpx;
}

.achi-name {
  font-size: 24rpx;
  color: $uni-text-color;
}
</style>