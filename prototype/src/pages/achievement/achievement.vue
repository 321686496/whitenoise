<template>
  <view class="page-container">
    <view class="page-bg"></view>

    <view class="header">
      <text class="page-title">成就墙</text>
      <text class="page-subtitle">记录你的每一次专注与放松</text>
    </view>

    <!-- 达成概览 -->
    <view class="overview app-card">
      <view class="overview-item">
        <text class="overview-num">3</text>
        <text class="overview-label">已解锁</text>
      </view>
      <view class="overview-sep"></view>
      <view class="overview-item">
        <text class="overview-num">8</text>
        <text class="overview-label">全部成就</text>
      </view>
      <view class="overview-sep"></view>
      <view class="overview-item">
        <text class="overview-num accent">38%</text>
        <text class="overview-label">完成度</text>
      </view>
    </view>

    <!-- 最近获得 -->
    <view class="section" v-if="recentAchievements.length > 0">
      <text class="section-title">最近获得</text>
      <view class="recent-grid">
        <view
          v-for="ach in recentAchievements"
          :key="ach.id"
          class="achievement-card app-card recent"
        >
          <view class="ach-icon-wrap">
            <Icon :name="ach.iconName" :size="32" color="var(--app-primary)" />
          </view>
          <text class="ach-name">{{ ach.name }}</text>
          <text class="ach-desc">{{ ach.desc }}</text>
          <text class="ach-date">{{ ach.date }}</text>
        </view>
      </view>
    </view>

    <!-- 进度条 -->
    <view class="section">
      <view class="progress-row">
        <text class="section-title">全部成就</text>
        <text class="progress-count">3 / 8</text>
      </view>
      <view class="progress-track app-card">
        <view class="progress-fill" :style="{ width: progressPercent + '%' }"></view>
      </view>
      <view class="achievement-list">
        <view
          v-for="ach in allAchievements"
          :key="ach.id"
          class="achievement-card app-card"
          :class="{ locked: !ach.unlocked }"
        >
          <view class="ach-icon-wrap" :class="{ locked: !ach.unlocked }">
            <Icon v-if="ach.unlocked" :name="ach.iconName" :size="24" color="var(--app-primary)" />
            <Icon v-else name="lock" :size="20" color="var(--app-text-3)" />
          </view>
          <view class="ach-info">
            <text class="ach-name">{{ ach.name }}</text>
            <text class="ach-desc">{{ ach.desc }}</text>
          </view>
          <view class="ach-status" :class="{ locked: !ach.unlocked }">
            <Icon :name="ach.unlocked ? 'check' : 'lock'" :size="14" :color="ach.unlocked ? 'var(--app-primary)' : 'var(--app-text-3)'" />
            <text class="ach-status-text">{{ ach.unlocked ? '已解锁' : '未解锁' }}</text>
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import Icon from '@/components/Icon.vue'

interface Achievement {
  id: string
  name: string
  desc: string
  iconName: string
  unlocked: boolean
  date?: string
}

const recentAchievements = ref<Achievement[]>([
  { id: 'a1', name: '初次入眠', desc: '首次使用定时器完成播放', iconName: 'moon', unlocked: true, date: '2026-08-15' },
  { id: 'a2', name: '连续七天', desc: '连续 7 天使用白噪音', iconName: 'flame', unlocked: true, date: '2026-08-17' },
  { id: 'a3', name: '声音调音师', desc: '创建 5 个自定义场景', iconName: 'mixer', unlocked: true, date: '2026-08-16' },
])

const allAchievements = ref<Achievement[]>([
  { id: 'a1', name: '初次入眠', desc: '首次使用定时器完成播放', iconName: 'moon', unlocked: true },
  { id: 'a2', name: '连续七天', desc: '连续 7 天使用白噪音', iconName: 'flame', unlocked: true },
  { id: 'a3', name: '声音调音师', desc: '创建 5 个自定义场景', iconName: 'mixer', unlocked: true },
  { id: 'a4', name: '分享达人', desc: '成功邀请 3 位好友', iconName: 'share', unlocked: false },
  { id: 'a5', name: '百日坚持', desc: '累计使用 100 天', iconName: 'check', unlocked: false },
  { id: 'a6', name: '午夜电台', desc: '在 22:00-02:00 期间使用', iconName: 'clock', unlocked: true },
  { id: 'a7', name: '混音大师', desc: '同时加载 6 路音轨', iconName: 'mixer', unlocked: false },
  { id: 'a8', name: '审美家', desc: '切换过所有主题风格', iconName: 'palette', unlocked: false },
])

const unlockedCount = computed(() => allAchievements.value.filter(a => a.unlocked).length)
const progressPercent = computed(() => Math.round((unlockedCount.value / allAchievements.value.length) * 100))
</script>

<style lang="scss" scoped>
.header {
  padding: 16rpx 4rpx 8rpx;
}

.page-subtitle {
  font-size: 24rpx;
  color: var(--app-text-2, $uni-text-color-grey);
  margin-top: 10rpx;
  display: block;
}

/* 达成概览 */
.overview {
  margin-top: 24rpx;
  padding: 28rpx 12rpx;
  display: flex;
  align-items: center;
}

.overview-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6rpx;
}

.overview-num {
  font-size: 38rpx;
  font-weight: 800;
  color: var(--app-primary, $app-primary);

  &.accent {
    color: var(--app-danger, $uni-color-error);
  }
}

.overview-label {
  font-size: 21rpx;
  color: var(--app-text-2, $uni-text-color-grey);
}

.overview-sep {
  width: 1rpx;
  height: 56rpx;
  background: var(--app-divider, $uni-border-color);
}

.section {
  margin-top: 36rpx;
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

.recent-grid {
  display: flex;
  gap: 16rpx;
  overflow-x: auto;
}

.achievement-card {
  padding: 24rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8rpx;
  min-width: 176rpx;

  &.recent {
    border-color: var(--app-primary, $app-primary);
    background: linear-gradient(180deg, var(--app-primary-soft, rgba($app-primary, 0.12)), var(--app-card-bg));
  }

  &.locked {
    opacity: 0.55;
  }
}

.ach-icon-wrap {
  width: 76rpx;
  height: 76rpx;
  border-radius: 24rpx;
  background: var(--app-subtle, $uni-bg-color-grey);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;

  &.locked {
    background: var(--app-subtle, $uni-bg-color-grey);
  }
}

.ach-name {
  font-size: 24rpx;
  color: var(--app-text, $uni-text-color);
  font-weight: 600;
  text-align: center;
}

.ach-desc {
  font-size: 20rpx;
  color: var(--app-text-2, $uni-text-color-grey);
  text-align: center;
}

.ach-date {
  font-size: 20rpx;
  color: var(--app-primary, $app-primary);
}

/* 进度 */
.progress-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 14rpx;

  .section-title {
    margin-bottom: 0;
  }
}

.progress-count {
  font-size: 23rpx;
  color: var(--app-primary, $app-primary);
  font-weight: 600;
}

.progress-track {
  height: 14rpx;
  border-radius: 7rpx;
  padding: 0;
  overflow: hidden;
  position: relative;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, var(--app-primary, $app-primary), var(--app-accent, $app-morandi-sage));
  border-radius: 7rpx;
  transition: width 0.5s;
}

.achievement-list {
  margin-top: 20rpx;
  display: flex;
  flex-direction: column;
  gap: 12rpx;
}

.achievement-list .achievement-card {
  flex-direction: row;
  min-width: unset;
  align-items: center;
  gap: 20rpx;
  padding: 22rpx 24rpx;
}

.achievement-list .ach-icon-wrap {
  width: 64rpx;
  height: 64rpx;
  border-radius: 20rpx;
}

.ach-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4rpx;
}

.ach-info .ach-name {
  text-align: left;
  font-size: 27rpx;
}

.ach-info .ach-desc {
  text-align: left;
}

.ach-status {
  display: flex;
  align-items: center;
  gap: 6rpx;

  &.locked {
    opacity: 0.7;
  }
}

.ach-status-text {
  font-size: 22rpx;
  color: var(--app-primary, $app-primary);
  font-weight: 500;

  &.locked {
    color: var(--app-text-3, $uni-text-color-disable);
  }
}
</style>