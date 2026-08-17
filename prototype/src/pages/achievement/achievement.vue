<template>
  <view class="page-container">
    <view class="header">
      <text class="page-title">成就墙</text>
      <text class="page-subtitle">记录你的每一次专注与放松</text>
    </view>

    <!-- 最近获得 -->
    <view class="section" v-if="recentAchievements.length > 0">
      <text class="section-title">最近获得</text>
      <view class="recent-grid">
        <view
          v-for="ach in recentAchievements"
          :key="ach.id"
          class="achievement-card recent"
        >
          <view class="ach-icon-wrap">
            <text class="ach-icon">{{ ach.icon }}</text>
          </view>
          <text class="ach-name">{{ ach.name }}</text>
          <text class="ach-desc">{{ ach.desc }}</text>
          <text class="ach-date">{{ ach.date }}</text>
        </view>
      </view>
    </view>

    <!-- 全部成就 -->
    <view class="section">
      <text class="section-title">全部成就</text>
      <view class="achievement-list">
        <view
          v-for="ach in allAchievements"
          :key="ach.id"
          class="achievement-card"
          :class="{ locked: !ach.unlocked }"
        >
          <view class="ach-icon-wrap">
            <text class="ach-icon">{{ ach.unlocked ? ach.icon : '🔒' }}</text>
          </view>
          <view class="ach-info">
            <text class="ach-name">{{ ach.name }}</text>
            <text class="ach-desc">{{ ach.desc }}</text>
          </view>
          <view class="ach-status">
            <text class="ach-status-text" v-if="ach.unlocked">已解锁</text>
            <text class="ach-status-text locked" v-else>未解锁</text>
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'

interface Achievement {
  id: string
  name: string
  desc: string
  icon: string
  unlocked: boolean
  date?: string
}

const recentAchievements = ref<Achievement[]>([
  { id: 'a1', name: '初次入眠', desc: '首次使用定时器完成播放', icon: '🌙', unlocked: true, date: '2026-08-15' },
  { id: 'a2', name: '连续七天', desc: '连续 7 天使用白噪音', icon: '🔥', unlocked: true, date: '2026-08-17' },
  { id: 'a3', name: '声音调音师', desc: '创建 5 个自定义场景', icon: '🎛️', unlocked: true, date: '2026-08-16' },
])

const allAchievements = ref<Achievement[]>([
  { id: 'a1', name: '初次入眠', desc: '首次使用定时器完成播放', icon: '🌙', unlocked: true },
  { id: 'a2', name: '连续七天', desc: '连续 7 天使用白噪音', icon: '🔥', unlocked: true },
  { id: 'a3', name: '声音调音师', desc: '创建 5 个自定义场景', icon: '🎛️', unlocked: true },
  { id: 'a4', name: '分享达人', desc: '成功邀请 3 位好友', icon: '📤', unlocked: false },
  { id: 'a5', name: '百日坚持', desc: '累计使用 100 天', icon: '💯', unlocked: false },
  { id: 'a6', name: '午夜电台', desc: '在 22:00-02:00 期间使用', icon: '🕐', unlocked: true },
  { id: 'a7', name: '混音大师', desc: '同时加载 6 路音轨', icon: '🎚️', unlocked: false },
  { id: 'a8', name: '审美家', desc: '切换过所有主题风格', icon: '🎨', unlocked: false },
])
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

.recent-grid {
  display: flex;
  gap: 16rpx;
  overflow-x: auto;
}

.achievement-card {
  background: $app-card-bg;
  border-radius: $app-radius-sm;
  padding: 24rpx;
  box-shadow: $app-shadow;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8rpx;
  min-width: 180rpx;

  &.recent {
    border: 2rpx solid rgba($app-morandi-green, 0.4);
    background: rgba($app-morandi-green, 0.06);
  }

  &.locked {
    opacity: 0.5;
  }
}

.ach-icon-wrap {
  width: 80rpx;
  height: 80rpx;
  border-radius: 50%;
  background: $uni-bg-color-grey;
  display: flex;
  align-items: center;
  justify-content: center;
}

.ach-icon {
  font-size: 40rpx;
}

.ach-name {
  font-size: 24rpx;
  color: $uni-text-color;
  font-weight: 600;
  text-align: center;
}

.ach-desc {
  font-size: 20rpx;
  color: $uni-text-color-grey;
  text-align: center;
}

.ach-date {
  font-size: 20rpx;
  color: $app-primary;
}

.achievement-list {
  display: flex;
  flex-direction: column;
  gap: 12rpx;
}

.achievement-list .achievement-card {
  flex-direction: row;
  min-width: unset;
  align-items: center;
  gap: 20rpx;
}

.ach-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4rpx;
}

.ach-info .ach-name {
  text-align: left;
}

.ach-info .ach-desc {
  text-align: left;
}

.ach-status {
  flex-shrink: 0;
}

.ach-status-text {
  font-size: 22rpx;
  color: $app-morandi-green;
  font-weight: 500;

  &.locked {
    color: $uni-text-color-grey;
  }
}
</style>