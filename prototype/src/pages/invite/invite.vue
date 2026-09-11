<template>
  <view class="page-container">
    <view class="page-bg"></view>

    <view class="header">
      <text class="page-title">邀请好友</text>
      <text class="page-subtitle">邀请好友一起使用，解锁更多主题与场景</text>
    </view>

    <!-- 邀请码卡 -->
    <view class="invite-hero app-card">
      <view class="invite-hero-icon">
        <Icon name="gift" :size="32" color="var(--app-primary)" />
      </view>
      <text class="invite-hero-title">分享邀请码给好友</text>
      <view class="invite-code-row">
        <view class="invite-code">WN2024</view>
        <view class="copy-btn app-card" @click="copyCode">
          <Icon name="copy" :size="18" color="var(--app-primary)" />
          <text class="copy-text">复制</text>
        </view>
      </view>
      <view class="btn-primary invite-btn" @click="shareInvite">
        <Icon name="share" :size="20" color="#fff" />
        <text class="invite-btn-text">分享邀请</text>
      </view>
    </view>

    <!-- 裂变进度 -->
    <view class="section">
      <text class="section-title">邀请进度</text>
      <view class="progress-card app-card">
        <view class="progress-bar-wrap">
          <view class="progress-count-now">{{ inviteCount }}</view>
          <view class="progress-track app-card">
            <view class="progress-fill" :style="{ width: progressPercent + '%' }"></view>
          </view>
          <text class="progress-total">/ 10</text>
        </view>
        <view class="progress-rewards">
          <view
            class="reward-item"
            v-for="r in rewards"
            :key="r.count"
            :class="{ unlocked: inviteCount >= r.count }"
          >
            <view class="reward-dot">
              <Icon v-if="inviteCount >= r.count" name="check" :size="12" color="#fff" />
            </view>
            <text class="reward-label">{{ r.label }}</text>
            <text class="reward-count">邀请 {{ r.count }} 人</text>
          </view>
        </view>
      </view>
    </view>

    <!-- 已解锁权益 -->
    <view class="section">
      <text class="section-title">邀请权益</text>
      <view class="benefit-list">
        <view class="benefit-item app-card" :class="{ locked: !benefit.unlocked }" v-for="benefit in benefits" :key="benefit.id">
          <view class="benefit-icon" :class="{ locked: !benefit.unlocked }">
            <Icon :name="benefit.unlocked ? 'check' : 'lock'" :size="24" :color="benefit.unlocked ? 'var(--app-primary)' : 'var(--app-text-3)'" />
          </view>
          <view class="benefit-info">
            <text class="benefit-name">{{ benefit.name }}</text>
            <text class="benefit-cond">{{ benefit.condition }}</text>
          </view>
          <text class="benefit-state" :class="{ locked: !benefit.unlocked }">
            {{ benefit.unlocked ? '已解锁' : '未解锁' }}
          </text>
        </view>
      </view>
    </view>

    <!-- 邀请历史 -->
    <view class="section">
      <text class="section-title">邀请记录</text>
      <view class="history-list">
        <view class="history-item app-card" v-for="h in inviteHistory" :key="h.id">
          <view class="history-avatar">
            <Icon name="user" :size="22" color="var(--app-primary)" />
          </view>
          <view class="history-info">
            <text class="history-name">{{ h.name }}</text>
            <text class="history-date">{{ h.date }}</text>
          </view>
          <view class="history-status">
            <Icon name="check" :size="14" color="var(--app-primary)" />
            <text>已加入</text>
          </view>
        </view>
      </view>

      <view class="empty-history" v-if="inviteHistory.length === 0">
        <Icon name="user" :size="40" color="var(--app-text-3)" />
        <text class="empty-text">暂无邀请记录</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import Icon from '@/components/Icon.vue'

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
  { id: 'h1', name: '小明', date: '2026-08-17' },
  { id: 'h2', name: '小红', date: '2026-08-15' },
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
  padding: 16rpx 4rpx 8rpx;
}

.page-subtitle {
  font-size: 24rpx;
  color: var(--app-text-2, $uni-text-color-grey);
  margin-top: 10rpx;
  display: block;
}

/* 邀请码主卡 */
.invite-hero {
  margin-top: 24rpx;
  padding: 36rpx 28rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 18rpx;
  position: relative;
  overflow: hidden;
}

.invite-hero-icon {
  width: 88rpx;
  height: 88rpx;
  border-radius: 28rpx;
  background: var(--app-primary-soft, rgba($app-primary, 0.12));
  display: flex;
  align-items: center;
  justify-content: center;
}

.invite-hero-title {
  font-size: 30rpx;
  font-weight: 700;
  color: var(--app-text, $uni-text-color);
}

.invite-code-row {
  display: flex;
  align-items: center;
  gap: 20rpx;
  margin-bottom: 12rpx;
}

.invite-code {
  font-size: 52rpx;
  font-weight: 800;
  color: var(--app-primary, $app-primary);
  letter-spacing: 10rpx;
}

.copy-btn {
  padding: 10rpx 24rpx;
  border-radius: 30rpx;
  display: flex;
  align-items: center;
  gap: 6rpx;
}

.copy-text {
  font-size: 24rpx;
  color: var(--app-primary, $app-primary);
  font-weight: 600;
}

.invite-btn {
  width: 100%;
  margin-top: 4rpx;
}

.invite-btn-text {
  margin-left: 10rpx;
  color: var(--app-on-primary, #fff);
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

/* 进度 */
.progress-card {
  padding: 30rpx 26rpx;
}

.progress-bar-wrap {
  display: flex;
  align-items: center;
  gap: 12rpx;
  margin-bottom: 28rpx;
}

.progress-count-now {
  font-size: 32rpx;
  font-weight: 800;
  color: var(--app-primary, $app-primary);
}

.progress-track {
  flex: 1;
  height: 12rpx;
  border-radius: 6rpx;
  padding: 0;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, var(--app-primary, $app-primary), var(--app-accent, $app-morandi-sage));
  border-radius: 6rpx;
  transition: width 0.5s;
}

.progress-total {
  font-size: 24rpx;
  color: var(--app-text-3, $uni-text-color-disable);
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
  opacity: 0.85;

  &.unlocked {
    opacity: 1;
  }
}

.reward-dot {
  width: 28rpx;
  height: 28rpx;
  border-radius: 50%;
  background: var(--app-divider, $uni-border-color);
  display: flex;
  align-items: center;
  justify-content: center;

  .reward-item.unlocked & {
    background: var(--app-primary, $app-primary);
  }
}

.reward-label {
  font-size: 20rpx;
  color: var(--app-text, $uni-text-color);
  font-weight: 500;
}

.reward-count {
  font-size: 18rpx;
  color: var(--app-text-2, $uni-text-color-grey);
}

/* 权益 */
.benefit-list {
  display: flex;
  flex-direction: column;
  gap: 12rpx;
}

.benefit-item {
  padding: 24rpx;
  display: flex;
  align-items: center;
  gap: 20rpx;

  &.locked {
    opacity: 0.55;
  }
}

.benefit-icon {
  width: 60rpx;
  height: 60rpx;
  border-radius: 20rpx;
  background: var(--app-primary-soft, rgba($app-primary, 0.12));
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;

  &.locked {
    background: var(--app-subtle, $uni-bg-color-grey);
  }
}

.benefit-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4rpx;
}

.benefit-name {
  font-size: 28rpx;
  color: var(--app-text, $uni-text-color);
  font-weight: 600;
}

.benefit-cond {
  font-size: 22rpx;
  color: var(--app-text-2, $uni-text-color-grey);
}

.benefit-state {
  font-size: 22rpx;
  color: var(--app-primary, $app-primary);
  font-weight: 600;
  flex-shrink: 0;

  &.locked {
    color: var(--app-text-3, $uni-text-color-disable);
  }
}

/* 历史 */
.history-list {
  display: flex;
  flex-direction: column;
  gap: 12rpx;
}

.history-item {
  padding: 22rpx 24rpx;
  display: flex;
  align-items: center;
  gap: 16rpx;
}

.history-avatar {
  width: 64rpx;
  height: 64rpx;
  border-radius: 50%;
  background: var(--app-primary-soft, rgba($app-primary, 0.12));
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.history-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4rpx;
}

.history-name {
  font-size: 26rpx;
  color: var(--app-text, $uni-text-color);
  font-weight: 600;
}

.history-date {
  font-size: 22rpx;
  color: var(--app-text-2, $uni-text-color-grey);
}

.history-status {
  display: flex;
  align-items: center;
  gap: 6rpx;
  font-size: 22rpx;
  color: var(--app-primary, $app-primary);
  font-weight: 500;
  flex-shrink: 0;
}

.empty-history {
  padding: 48rpx 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16rpx;
}

.empty-text {
  font-size: 26rpx;
  color: var(--app-text-2, $uni-text-color-grey);
}
</style>