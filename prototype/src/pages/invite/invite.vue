<template>
  <view class="page-container">
    <view class="header">
      <text class="page-title">邀请好友</text>
      <text class="page-subtitle">邀请好友一起使用，解锁更多主题与场景</text>
    </view>

    <!-- 裂变进度 -->
    <view class="section">
      <view class="progress-card">
        <text class="progress-title">邀请进度</text>
        <view class="progress-bar-wrap">
          <view class="progress-bar">
            <view class="progress-fill" :style="{ width: progressPercent + '%' }"></view>
          </view>
          <text class="progress-text">{{ inviteCount }}/10</text>
        </view>
        <view class="progress-rewards">
          <view class="reward-item" v-for="r in rewards" :key="r.count">
            <view class="reward-dot" :class="{ unlocked: inviteCount >= r.count }"></view>
            <text class="reward-label">{{ r.label }}</text>
            <text class="reward-count">邀请 {{ r.count }} 人</text>
          </view>
        </view>
      </view>
    </view>

    <!-- 邀请码 -->
    <view class="section">
      <view class="invite-card">
        <text class="invite-label">我的邀请码</text>
        <view class="invite-code-row">
          <text class="invite-code">WN2024</text>
          <view class="btn-outline copy-btn" @click="copyCode">
            <text>复制</text>
          </view>
        </view>
        <view class="invite-actions">
          <view class="btn-primary invite-btn" @click="shareInvite">
            <text>📤 分享邀请</text>
          </view>
        </view>
      </view>
    </view>

    <!-- 已解锁权益 -->
    <view class="section">
      <text class="section-title">已解锁权益</text>
      <view class="benefit-list">
        <view class="benefit-item" :class="{ locked: !benefit.unlocked }" v-for="benefit in benefits" :key="benefit.id">
          <text class="benefit-icon">{{ benefit.unlocked ? '✅' : '🔒' }}</text>
          <view class="benefit-info">
            <text class="benefit-name">{{ benefit.name }}</text>
            <text class="benefit-cond">{{ benefit.condition }}</text>
          </view>
        </view>
      </view>
    </view>

    <!-- 邀请历史 -->
    <view class="section">
      <text class="section-title">邀请记录</text>
      <view class="history-list">
        <view class="history-item" v-for="h in inviteHistory" :key="h.id">
          <view class="history-avatar">
            <text>{{ h.avatar }}</text>
          </view>
          <view class="history-info">
            <text class="history-name">{{ h.name }}</text>
            <text class="history-date">{{ h.date }}</text>
          </view>
          <text class="history-status">已加入</text>
        </view>
      </view>

      <view class="empty-history" v-if="inviteHistory.length === 0">
        <text class="empty-text">暂无邀请记录</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

const inviteCount = ref(2)
const progressPercent = computed(() => (inviteCount.value / 10) * 100)

const rewards = [
  { count: 1, label: '解锁 1 套配色' },
  { count: 3, label: '场景上限 +5' },
  { count: 10, label: '解锁全部主题' },
]

const benefits = ref([
  { id: 'b1', name: '薰衣草配色', condition: '邀请 1 人', unlocked: true },
  { id: 'b2', name: '场景上限 +5', condition: '邀请 3 人', unlocked: false },
  { id: 'b3', name: '全部主题风格', condition: '邀请 10 人', unlocked: false },
])

const inviteHistory = ref([
  { id: 'h1', name: '小明', avatar: '😊', date: '2026-08-17' },
  { id: 'h2', name: '小红', avatar: '🌸', date: '2026-08-15' },
])

const copyCode = () => {
  uni.showToast({ title: '邀请码已复制', icon: 'success' })
}

const shareInvite = () => {
  uni.showToast({ title: '已生成分享卡片', icon: 'success' })
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

.progress-card {
  background: $app-card-bg;
  border-radius: $app-radius;
  padding: 32rpx;
  box-shadow: $app-shadow;
}

.progress-title {
  font-size: 28rpx;
  font-weight: 600;
  color: $uni-text-color;
  display: block;
  margin-bottom: 20rpx;
}

.progress-bar-wrap {
  display: flex;
  align-items: center;
  gap: 16rpx;
  margin-bottom: 28rpx;
}

.progress-bar {
  flex: 1;
  height: 12rpx;
  background: $uni-bg-color-grey;
  border-radius: 6rpx;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: $app-primary;
  border-radius: 6rpx;
  transition: width 0.5s;
}

.progress-text {
  font-size: 24rpx;
  color: $app-primary;
  font-weight: 600;
}

.progress-rewards {
  display: flex;
  justify-content: space-between;
}

.reward-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6rpx;
}

.reward-dot {
  width: 20rpx;
  height: 20rpx;
  border-radius: 50%;
  background: $uni-border-color;

  &.unlocked {
    background: $app-morandi-green;
  }
}

.reward-label {
  font-size: 20rpx;
  color: $uni-text-color;
  font-weight: 500;
}

.reward-count {
  font-size: 18rpx;
  color: $uni-text-color-grey;
}

.invite-card {
  background: $app-card-bg;
  border-radius: $app-radius;
  padding: 32rpx;
  box-shadow: $app-shadow;
  text-align: center;
}

.invite-label {
  font-size: 26rpx;
  color: $uni-text-color-grey;
  display: block;
  margin-bottom: 16rpx;
}

.invite-code-row {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 20rpx;
  margin-bottom: 28rpx;
}

.invite-code {
  font-size: 48rpx;
  font-weight: 700;
  color: $app-primary;
  letter-spacing: 8rpx;
}

.copy-btn {
  padding: 8rpx 24rpx;
  font-size: 24rpx;
}

.invite-actions {
  display: flex;
  justify-content: center;
}

.invite-btn {
  padding: 20rpx 48rpx;
  font-size: 28rpx;
}

.benefit-list {
  display: flex;
  flex-direction: column;
  gap: 12rpx;
}

.benefit-item {
  background: $app-card-bg;
  border-radius: $app-radius-sm;
  padding: 24rpx;
  box-shadow: $app-shadow;
  display: flex;
  align-items: center;
  gap: 20rpx;

  &.locked {
    opacity: 0.5;
  }
}

.benefit-icon {
  font-size: 32rpx;
}

.benefit-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4rpx;
}

.benefit-name {
  font-size: 28rpx;
  color: $uni-text-color;
  font-weight: 500;
}

.benefit-cond {
  font-size: 22rpx;
  color: $uni-text-color-grey;
}

.history-list {
  display: flex;
  flex-direction: column;
  gap: 12rpx;
}

.history-item {
  background: $app-card-bg;
  border-radius: $app-radius-sm;
  padding: 20rpx 24rpx;
  box-shadow: $app-shadow;
  display: flex;
  align-items: center;
  gap: 16rpx;
}

.history-avatar {
  width: 64rpx;
  height: 64rpx;
  border-radius: 50%;
  background: $uni-bg-color-grey;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 32rpx;
}

.history-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4rpx;
}

.history-name {
  font-size: 26rpx;
  color: $uni-text-color;
  font-weight: 500;
}

.history-date {
  font-size: 22rpx;
  color: $uni-text-color-grey;
}

.history-status {
  font-size: 22rpx;
  color: $app-morandi-green;
  font-weight: 500;
}

.empty-history {
  padding: 40rpx;
  text-align: center;
}

.empty-text {
  font-size: 26rpx;
  color: $uni-text-color-grey;
}
</style>