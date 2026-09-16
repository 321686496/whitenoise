<template>
  <!-- v2：自定义导航（pages.json 已改 custom），NavBar 自带安全区；概览全部 computed 驱动（MASTER §10.3-4） -->
  <view class="page-container achievement-page">
    <view class="page-bg"></view>

    <NavBar title="成就墙" />

    <text class="page-subtitle">记录你的每一次专注与放松</text>

    <!-- 达成概览（§10.3-4：数字与百分比一律来自 computed，禁止字面量） -->
    <view class="overview app-card">
      <view class="overview-item">
        <text class="overview-num num">{{ unlockedCount }}</text>
        <text class="overview-label">已解锁</text>
      </view>
      <view class="overview-sep"></view>
      <view class="overview-item">
        <text class="overview-num num">{{ totalAchievements }}</text>
        <text class="overview-label">全部成就</text>
      </view>
      <view class="overview-sep"></view>
      <view class="overview-item">
        <text class="overview-num accent num">{{ progressPercent }}%</text>
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
        <text class="progress-count num">{{ unlockedCount }} / {{ totalAchievements }}</text>
      </view>
      <view class="progress-track">
        <view class="progress-fill" :style="{ width: progressPercent + '%' }"></view>
      </view>
      <view class="achievement-list">
        <view
          v-for="ach in allAchievements"
          :key="ach.id"
          class="achievement-card app-card"
          :class="{ locked: !ach.unlocked }"
        >
          <view class="ach-icon-wrap">
            <Icon v-if="ach.unlocked" :name="ach.iconName" :size="24" color="var(--app-primary)" />
            <Icon v-else name="lock" :size="20" color="var(--app-text-3)" />
          </view>
          <view class="ach-info">
            <text class="ach-name">{{ ach.name }}</text>
            <text class="ach-desc">{{ ach.desc }}</text>
          </view>
          <view class="ach-status" :class="{ locked: !ach.unlocked }">
            <Icon :name="ach.unlocked ? 'check' : 'lock'" :size="14" :color="ach.unlocked ? 'var(--app-success)' : 'var(--app-text-3)'" />
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
import NavBar from '@/components/NavBar.vue'

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

/* §10.3-4：单一 computed 数据源驱动概览与进度，杜绝「3 / 38%」与进度条不一致 */
const unlockedCount = computed(() => allAchievements.value.filter(a => a.unlocked).length)
const totalAchievements = computed(() => allAchievements.value.length)
const progressPercent = computed(() =>
  totalAchievements.value === 0 ? 0 : Math.round((unlockedCount.value / totalAchievements.value) * 100)
)
</script>

<style lang="scss" scoped>
/* NavBar 自带 env(safe-area-inset-top)，去掉容器重复的安全区顶距 */
.achievement-page {
  padding-top: calc(env(safe-area-inset-top, 0rpx) + 12rpx);
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
  color: var(--app-primary);

  /* v1 误用 --app-danger 表达完成度 → v2 完成度语义为成功色 */
  &.accent {
    color: var(--app-success);
  }
}

.overview-label {
  font-size: 21rpx;
  color: var(--app-text-2);
}

.overview-sep {
  width: 1rpx;
  height: 56rpx;
  background: var(--app-line);
}

.section {
  margin-top: 36rpx;
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
    border-color: var(--app-primary);
    background: linear-gradient(180deg, var(--app-primary-soft), var(--app-surface));
  }

  &.locked {
    opacity: 0.55;
  }
}

.ach-icon-wrap {
  width: 76rpx;
  height: 76rpx;
  border-radius: 24rpx;
  background: var(--app-surface-2);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.ach-name {
  font-size: 24rpx;
  color: var(--app-text);
  font-weight: 600;
  text-align: center;
}

.ach-desc {
  font-size: 20rpx;
  color: var(--app-text-2);
  text-align: center;
}

.ach-date {
  font-size: 20rpx;
  color: var(--app-primary);
}

/* 进度（MASTER §9：Progress 6px 高、圆角 full，槽走 --app-sunken） */
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
  color: var(--app-primary);
  font-weight: 600;
}

.progress-track {
  height: 12rpx;
  border-radius: 999rpx;
  background: var(--app-sunken);
  overflow: hidden;
  position: relative;
}

.progress-fill {
  height: 100%;
  background: var(--app-success);
  border-radius: 999rpx;
  transition: width var(--dur-slow) var(--ease-std);
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
  color: var(--app-success);
  font-weight: 500;
}

.ach-status.locked .ach-status-text {
  color: var(--app-text-3);
}
</style>
