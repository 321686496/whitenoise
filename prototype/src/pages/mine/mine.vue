<template>
  <view class="page-container">
    <view class="page-bg"></view>

    <!-- 自定义悬浮 TabBar -->
    <TabBar current="mine" />

    <!-- ① 品牌头部（与首页 / 场景页统一） -->
    <view class="header">
      <view class="header-top">
        <view class="brand">
          <view class="brand-logo-wrap">
            <image class="brand-logo" src="/static/logo-v10-1.jpg" mode="aspectFit" />
          </view>
          <view class="brand-text">
            <text class="app-title">声栖</text>
            <text class="app-slogan">我的私享声音空间</text>
          </view>
        </view>
        <view class="header-btn app-card" @click="goTheme">
          <Icon name="palette" :size="22" color="var(--app-primary)" />
        </view>
      </view>
    </view>

    <!-- ② 用户 Hero 渐变带 -->
    <view class="profile-hero">
      <view class="hero-blob blob-a"></view>
      <view class="hero-blob blob-b"></view>
      <view class="hero-avatar">
        <Icon name="bird" :size="52" color="var(--app-primary)" />
      </view>
      <view class="hero-id">
        <view class="hero-id-top">
          <text class="hero-name">声栖用户</text>
          <view class="member-chip">
            <Icon name="moon" :size="12" color="var(--app-primary)" />
            <text class="member-text">睡眠陪伴中</text>
          </view>
        </view>
        <text class="hero-tag">已陪伴你 12 天 · 第 2 周</text>
      </view>
      <view class="hero-edit app-card" @click="goSettings">
        <Icon name="edit" :size="20" color="var(--app-text-3)" />
      </view>
    </view>

    <!-- ③ 核心数据（重叠 Hero 下层，营造层次） -->
    <view class="stats-card app-card">
      <view class="stat-item" @click="goStats">
        <text class="stat-value">128</text>
        <text class="stat-label">累计播放(分)</text>
      </view>
      <view class="stat-sep"></view>
      <view class="stat-item" @click="goCheckin">
        <text class="stat-value">12</text>
        <text class="stat-label">连续天数</text>
      </view>
      <view class="stat-sep"></view>
      <view class="stat-item" @click="goFavorites">
        <text class="stat-value">5</text>
        <text class="stat-label">场景数</text>
      </view>
      <view class="stat-sep"></view>
      <view class="stat-item" @click="goAchievement">
        <text class="stat-value">3</text>
        <text class="stat-label">成就</text>
      </view>
    </view>

    <!-- ④ 常用功能（2×2 大卡） -->
    <view class="group-head">常用功能</view>
    <view class="quick-grid">
      <view class="quick-item app-card" v-for="q in quickActions" :key="q.id" @click="goQuick(q)">
        <view class="q-icon">
          <Icon :name="q.icon" :size="30" color="var(--app-primary)" />
        </view>
        <text class="q-name">{{ q.name }}</text>
        <view class="q-badge" :class="{ primary: q.primary }">
          <text>{{ q.badge }}</text>
        </view>
      </view>
    </view>

    <!-- ⑤ 偏好与设置 -->
    <view class="group-head">偏好与设置</view>
    <view class="menu-card app-card">
      <view class="menu-item" @click="goStats">
        <view class="menu-icon">
          <Icon name="wave" :size="22" color="var(--app-primary)" />
        </view>
        <text class="menu-label">使用数据</text>
        <view class="menu-badge">本周5天</view>
        <Icon name="chevron-right" :size="20" color="var(--app-text-3)" />
      </view>
      <view class="divider" />
      <view class="menu-item" @click="goInvite">
        <view class="menu-icon">
          <Icon name="gift" :size="22" color="var(--app-primary)" />
        </view>
        <text class="menu-label">邀请好友</text>
        <view class="menu-badge primary">2 人已加入</view>
        <Icon name="chevron-right" :size="20" color="var(--app-text-3)" />
      </view>
      <view class="divider" />
      <view class="menu-item" @click="goTheme">
        <view class="menu-icon">
          <Icon name="palette" :size="22" color="var(--app-primary)" />
        </view>
        <text class="menu-label">主题与风格</text>
        <view class="menu-value">
          <text class="current-theme">{{ currentThemeLabel }}</text>
        </view>
        <Icon name="chevron-right" :size="20" color="var(--app-text-3)" />
      </view>
      <view class="divider" />
      <view class="menu-item" @click="goSettings">
        <view class="menu-icon">
          <Icon name="settings" :size="22" color="var(--app-primary)" />
        </view>
        <text class="menu-label">设置</text>
        <Icon name="chevron-right" :size="20" color="var(--app-text-3)" />
      </view>
    </view>

    <!-- ⑥ 最近成就 -->
    <view class="group-head">最近成就</view>
    <view class="achi-grid">
      <view class="achi-chip app-card" v-for="ach in recentAchievements" :key="ach.id" @click="goAchievement">
        <view class="achi-icon">
          <Icon :name="ach.iconName" :size="20" color="var(--app-primary)" />
        </view>
        <text class="achi-name">{{ ach.name }}</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import Icon from '@/components/Icon.vue'
import TabBar from '@/components/TabBar.vue'
import { themeState, schemeMeta, UIMODE_META } from '@/theme/index'

const recentAchievements = ref([
  { id: 'a1', name: '初次入眠', iconName: 'moon' },
  { id: 'a2', name: '连续七天', iconName: 'flame' },
  { id: 'a3', name: '声音调音师', iconName: 'mixer' },
])

const quickActions = [
  { id: 'checkin', name: '每日签到', icon: 'flame', badge: '连续5天', primary: true },
  { id: 'favorites', name: '我的收藏', icon: 'save', badge: '9 个', primary: false },
  { id: 'history', name: '播放历史', icon: 'clock', badge: '今天2次', primary: false },
  { id: 'achievement', name: '成就墙', icon: 'trophy', badge: '3/8', primary: false },
]

const goQuick = (q: { id: string }) => {
  const map: Record<string, () => void> = {
    checkin: goCheckin,
    favorites: goFavorites,
    history: goHistory,
    achievement: goAchievement,
  }
  map[q.id]?.()
}

const currentThemeLabel = computed(
  () => `${schemeMeta(themeState.scheme).label} · ${UIMODE_META[themeState.ui].label}`
)

const goAchievement = () => uni.navigateTo({ url: '/pages/achievement/achievement' })
const goInvite = () => uni.navigateTo({ url: '/pages/invite/invite' })
const goTheme = () => uni.navigateTo({ url: '/pages/theme/theme' })
const goSettings = () => uni.navigateTo({ url: '/pages/settings/settings' })
const goCheckin = () => uni.navigateTo({ url: '/pages/checkin/checkin' })
const goStats = () => uni.navigateTo({ url: '/pages/stats/stats' })
const goFavorites = () => uni.navigateTo({ url: '/pages/favorites/favorites' })
const goHistory = () => uni.navigateTo({ url: '/pages/history/history' })
</script>

<style lang="scss" scoped>
.page-container {
  padding-bottom: calc(56rpx + env(safe-area-inset-bottom));
}

/* ① 品牌头部 */
.header {
  padding: 16rpx 4rpx 24rpx;
}

.header-top {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.brand {
  display: flex;
  align-items: center;
  gap: 20rpx;
}

.brand-logo-wrap {
  width: 84rpx;
  height: 84rpx;
  border-radius: 24rpx;
  overflow: hidden;
  box-shadow: 0 8rpx 22rpx color-mix(in srgb, var(--app-primary) 22%, transparent);
}

.brand-logo {
  width: 100%;
  height: 100%;
}

.brand-text {
  display: flex;
  flex-direction: column;
  gap: 6rpx;
}

.app-title {
  font-size: 46rpx;
  font-weight: 800;
  color: var(--app-text);
  letter-spacing: 4rpx;
  line-height: 1.1;
}

.app-slogan {
  font-size: 22rpx;
  color: var(--app-text-2);
  letter-spacing: 1rpx;
}

.header-btn {
  width: 68rpx;
  height: 68rpx;
  border-radius: 22rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: transform var(--dur-fast) var(--ease-std);

  &:active {
    transform: scale(0.9);
  }
}

/* ② 用户 Hero 渐变带 */
.profile-hero {
  position: relative;
  overflow: hidden;
  display: flex;
  align-items: center;
  gap: 26rpx;
  padding: 44rpx 30rpx 96rpx;
  border-radius: 36rpx;
  background: linear-gradient(
    150deg,
    color-mix(in srgb, var(--app-primary) 30%, var(--app-surface)) 0%,
    color-mix(in srgb, var(--app-primary) 16%, var(--app-bg)) 55%,
    var(--app-surface) 100%
  );
}

.hero-blob {
  position: absolute;
  border-radius: 50%;
  pointer-events: none;

  &.blob-a {
    width: 260rpx;
    height: 260rpx;
    right: -80rpx;
    top: -90rpx;
    background: color-mix(in srgb, var(--app-primary) 14%, transparent);
  }

  &.blob-b {
    width: 160rpx;
    height: 160rpx;
    bottom: -70rpx;
    right: 90rpx;
    background: color-mix(in srgb, var(--app-primary) 8%, transparent);
  }
}

.hero-avatar {
  position: relative;
  width: 132rpx;
  height: 132rpx;
  border-radius: 44rpx;
  background: var(--app-surface);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  box-shadow: 0 14rpx 30rpx color-mix(in srgb, var(--app-primary) 22%, transparent),
    inset 0 -2rpx 0 var(--app-press), inset 0 2rpx 0 var(--p-neu-b);
}

.hero-id {
  position: relative;
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 10rpx;
}

.hero-id-top {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 14rpx;
}

.hero-name {
  font-size: 46rpx;
  font-weight: 800;
  color: var(--app-text);
  letter-spacing: -0.5rpx;
  line-height: 1.1;
}

.member-chip {
  display: inline-flex;
  align-items: center;
  gap: 6rpx;
  padding: 6rpx 16rpx;
  border-radius: 18rpx;
  background: var(--app-surface);
}

.member-text {
  font-size: 20rpx;
  color: var(--app-primary);
  font-weight: 600;
}

.hero-tag {
  font-size: 24rpx;
  color: var(--app-text-2);
  letter-spacing: 0.5rpx;
}

.hero-edit {
  position: relative;
  width: 66rpx;
  height: 66rpx;
  border-radius: 22rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  transition: transform var(--dur-fast) var(--ease-std);

  &:active {
    transform: scale(0.9);
  }
}

/* ③ 核心数据（重叠 Hero） */
.stats-card {
  position: relative;
  margin: -52rpx 14rpx 0;
  padding: 28rpx 12rpx;
  display: flex;
  align-items: center;
  box-shadow: 0 20rpx 48rpx color-mix(in srgb, var(--app-primary) 14%, transparent);
}

.stat-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8rpx;
  padding: 8rpx 0;
  transition: transform var(--dur-fast) var(--ease-std);

  &:active {
    transform: scale(0.95);
  }
}

.stat-value {
  font-size: 48rpx;
  font-weight: 800;
  color: var(--app-primary);
  letter-spacing: -1rpx;
  line-height: 1;
}

.stat-label {
  font-size: 21rpx;
  color: var(--app-text-2);
}

.stat-sep {
  width: 1rpx;
  height: 58rpx;
  background: var(--app-line);
}

/* 分组标题 */
.group-head {
  font-size: 24rpx;
  font-weight: 600;
  letter-spacing: 0.3rpx;
  color: var(--app-text-2);
  margin: 40rpx 4rpx 16rpx;
  padding-left: 4rpx;
}

/* ④ 常用功能 2×2 */
.quick-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 16rpx;
}

.quick-item {
  width: calc(50% - 8rpx);
  box-sizing: border-box;
  padding: 32rpx 20rpx 28rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 14rpx;
  transition: transform var(--dur-fast) var(--ease-std);

  &:active {
    transform: scale(0.97);
  }
}

.q-icon {
  width: 92rpx;
  height: 92rpx;
  border-radius: 30rpx;
  background: var(--app-primary-soft);
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: inset 0 -2rpx 0 var(--app-press), inset 0 2rpx 0 var(--p-neu-b);
}

.q-name {
  font-size: 29rpx;
  font-weight: 600;
  color: var(--app-text);
}

.q-badge {
  padding: 6rpx 20rpx;
  border-radius: 20rpx;
  background: var(--app-surface-2);

  text {
    font-size: 20rpx;
    color: var(--app-text-2);
  }

  &.primary {
    background: var(--app-primary-soft);

    text {
      color: var(--app-primary);
      font-weight: 600;
    }
  }
}

/* ⑤ 偏好与设置 */
.menu-card {
  overflow: hidden;
}

.menu-card .divider {
  margin-left: 106rpx;
}

.menu-item {
  padding: 30rpx 26rpx;
  display: flex;
  align-items: center;
  gap: 22rpx;
  transition: transform var(--dur-fast) var(--ease-std);

  &:active {
    background: var(--app-press);
    transform: scale(0.99);
  }
}

.menu-icon {
  width: 60rpx;
  height: 60rpx;
  border-radius: 20rpx;
  background: var(--app-primary-soft);
  display: flex;
  align-items: center;
  justify-content: center;
}

.menu-label {
  font-size: 29rpx;
  color: var(--app-text);
  font-weight: 500;
  flex: 1;
}

.menu-badge {
  font-size: 21rpx;
  padding: 4rpx 16rpx;
  border-radius: 20rpx;
  background: var(--app-surface-2);
  color: var(--app-text-2);

  &.primary {
    background: var(--app-primary-soft);
    color: var(--app-primary);
    font-weight: 600;
  }
}

.menu-value {
  font-size: 22rpx;
  color: var(--app-text-2);
}

.current-theme {
  font-weight: 500;
  color: var(--app-primary);
}

/* ⑥ 最近成就 */
.achi-grid {
  display: flex;
  gap: 16rpx;
}

.achi-chip {
  flex: 1;
  padding: 26rpx 10rpx 24rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 14rpx;
  transition: transform var(--dur-fast) var(--ease-std);

  &:active {
    transform: scale(0.96);
  }
}

.achi-icon {
  width: 68rpx;
  height: 68rpx;
  border-radius: 22rpx;
  background: var(--app-primary-soft);
  display: flex;
  align-items: center;
  justify-content: center;
}

.achi-name {
  font-size: 23rpx;
  color: var(--app-text);
  font-weight: 500;
  text-align: center;
}
</style>