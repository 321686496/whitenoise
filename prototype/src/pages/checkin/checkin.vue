<template>
  <!-- v2：自定义导航（pages.json 已改 custom）；成功态走 --app-success、提醒走 --app-warning（MASTER §3.2） -->
  <view class="page-container checkin-page">
    <view class="page-bg"></view>

    <NavBar title="每日签到" />

    <text class="page-subtitle">坚持使用，解锁专属奖励</text>

    <view class="streak-card app-card">
      <view class="streak-top">
        <text class="streak-label">已连续签到</text>
        <view class="streak-num-row">
          <text class="streak-num num">{{ streakDays }}</text>
          <text class="streak-unit">天</text>
        </view>
      </view>
      <view class="divider" />
      <view class="streak-bottom">
        <Icon name="gift" :size="16" color="var(--app-warning)" />
        <text class="streak-hint">再坚持 <text class="accent num">{{ remainDays }}</text> 天解锁奖励</text>
      </view>
    </view>

    <view class="section">
      <text class="section-title">本周签到</text>
      <view class="calendar-row">
        <view
          v-for="day in weekDays"
          :key="day.label"
          class="day-cell"
          :class="{ checked: day.checked, today: day.isToday, future: day.isFuture }"
        >
          <text class="day-label">{{ day.label }}</text>
          <view class="day-circle" :class="{ checked: day.checked, today: day.isToday }">
            <Icon v-if="day.checked" name="check" :size="18" color="var(--app-on-primary)" />
            <text v-else class="day-num num">{{ day.date }}</text>
          </view>
        </view>
      </view>
    </view>

    <view class="checkin-section">
      <view class="checkin-btn" :class="{ done: checkedInToday }" @click="handleCheckin">
        <Icon
          :name="checkedInToday ? 'check' : 'trophy'"
          :size="32"
          :color="checkedInToday ? 'var(--app-on-primary)' : 'var(--app-primary)'"
        />
        <text class="checkin-btn-text">{{ checkedInToday ? '已签到' : '签到' }}</text>
      </view>
      <view v-if="showSuccess" class="success-tip">
        <Icon name="check" :size="14" color="var(--app-success)" />
        <text class="success-text">签到成功！</text>
      </view>
    </view>

    <view class="section">
      <text class="section-title">签到奖励</text>
      <view class="reward-list">
        <view
          v-for="reward in rewards"
          :key="reward.id"
          class="reward-card app-card"
          :class="{ unlocked: reward.unlocked }"
        >
          <view class="reward-icon-wrap" :class="{ unlocked: reward.unlocked }">
            <Icon v-if="reward.unlocked" :name="reward.iconName" :size="22" color="var(--app-primary)" />
            <Icon v-else name="lock" :size="18" color="var(--app-text-3)" />
          </view>
          <view class="reward-info">
            <text class="reward-name">{{ reward.name }}</text>
            <text class="reward-desc">{{ reward.desc }}</text>
          </view>
          <view class="reward-status">
            <Icon
              :name="reward.unlocked ? 'check' : 'lock'"
              :size="14"
              :color="reward.unlocked ? 'var(--app-success)' : 'var(--app-text-3)'"
            />
            <text class="reward-status-text" :class="{ locked: !reward.unlocked }">
              {{ reward.unlocked ? '已解锁' : '未解锁' }}
            </text>
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import Icon from '@/components/Icon.vue'
import NavBar from '@/components/NavBar.vue'

interface Reward {
  id: string
  name: string
  desc: string
  iconName: string
  unlocked: boolean
}

const streakDays = ref(5)
const nextRewardDays = 7
const remainDays = computed(() => nextRewardDays - streakDays.value)
const checkedInToday = ref(false)
const showSuccess = ref(false)

const weekDays = computed(() => {
  const labels = ['一', '二', '三', '四', '五', '六', '日']
  const todayIndex = 5
  return labels.map((label, i) => ({
    label: `周${label}`,
    date: 14 + i,
    checked: i < 5,
    isToday: i === todayIndex,
    isFuture: i > todayIndex,
  }))
})

const rewards = ref<Reward[]>([
  { id: 'r1', name: '连续 3 天', desc: '专属场景「清晨森林」', iconName: 'forest', unlocked: true },
  { id: 'r2', name: '连续 7 天', desc: '专属场景「星空夜晚」', iconName: 'moon', unlocked: false },
  { id: 'r3', name: '连续 14 天', desc: '专属场景「山间溪流」', iconName: 'stream', unlocked: false },
  { id: 'r4', name: '连续 30 天', desc: '专属场景「深夜壁炉」', iconName: 'flame', unlocked: false },
])

const handleCheckin = () => {
  if (checkedInToday.value) return
  checkedInToday.value = true
  showSuccess.value = true
  setTimeout(() => {
    showSuccess.value = false
  }, 2000)
}
</script>

<style lang="scss" scoped>
/* NavBar 自带 env(safe-area-inset-top)，去掉容器重复的安全区顶距 */
.checkin-page {
  padding-top: calc(env(safe-area-inset-top, 0rpx) + 12rpx);
}

.streak-card {
  margin-top: 24rpx;
  padding: 32rpx 28rpx 24rpx;
}

.streak-top {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
}

.streak-label {
  font-size: 26rpx;
  color: var(--app-text-2);
  font-weight: 500;
}

.streak-num-row {
  display: flex;
  align-items: baseline;
  gap: 6rpx;
}

.streak-num {
  font-size: 72rpx;
  font-weight: 800;
  color: var(--app-primary);
  line-height: 1;
}

.streak-unit {
  font-size: 26rpx;
  color: var(--app-primary);
  font-weight: 600;
}

.streak-card .divider {
  margin: 20rpx 0 16rpx;
}

.streak-bottom {
  display: flex;
  align-items: center;
  gap: 8rpx;
}

/* 奖励提醒语义 → --app-warning */
.streak-hint {
  font-size: 24rpx;
  color: var(--app-text-2);

  .accent {
    color: var(--app-warning);
    font-weight: 700;
  }
}

.section {
  margin-top: 36rpx;
}

.calendar-row {
  display: flex;
  justify-content: space-between;
  gap: 8rpx;
}

.day-cell {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10rpx;
}

.day-label {
  font-size: 22rpx;
  color: var(--app-text-2);
  font-weight: 500;
}

/* 已签到 = 成功色实心 + 勾图标（不靠颜色单独表意）；今天 = 描边圈；未来 = 半透明 */
.day-circle {
  width: 68rpx;
  height: 68rpx;
  border-radius: 50%;
  background: var(--app-surface-2);
  box-sizing: border-box;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: transform var(--dur-fast) var(--ease-std), background var(--dur-fast) var(--ease-std);

  &.checked {
    background: var(--app-success);
  }

  &.today {
    border: 2rpx solid var(--app-primary);
    background: var(--app-primary-soft);
  }
}

.day-num {
  font-size: 24rpx;
  font-weight: 600;
  color: var(--app-text-2);

  .today & {
    color: var(--app-primary);
  }

  .future & {
    color: var(--app-text-3);
  }
}

.future .day-circle {
  opacity: 0.5;
}

.checkin-section {
  margin-top: 40rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16rpx;
}

.checkin-btn {
  width: 176rpx;
  height: 176rpx;
  border-radius: 50%;
  box-sizing: border-box;
  background: var(--app-primary-soft);
  border: 3rpx solid var(--app-primary);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 6rpx;
  transition: transform var(--dur-fast) var(--ease-std), background var(--dur-fast) var(--ease-std);

  &:active {
    transform: scale(0.96);
  }

  &.done {
    background: var(--app-success);
    border-color: var(--app-success);
  }
}

.checkin-btn-text {
  font-size: 24rpx;
  font-weight: 600;
  color: var(--app-primary);

  .done & {
    color: var(--app-on-primary);
  }
}

.success-tip {
  display: flex;
  align-items: center;
  gap: 6rpx;
  animation: fadeUp var(--dur-base) var(--ease-std);
}

.success-text {
  font-size: 24rpx;
  color: var(--app-success);
  font-weight: 600;
}

@keyframes fadeUp {
  from {
    opacity: 0;
    transform: translateY(10rpx);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.reward-list {
  display: flex;
  flex-direction: column;
  gap: 12rpx;
}

.reward-card {
  display: flex;
  align-items: center;
  gap: 20rpx;
  padding: 22rpx 24rpx;
  transition: transform var(--dur-fast) var(--ease-std);

  &:active {
    transform: scale(0.96);
  }

  &.unlocked {
    border-color: var(--app-primary);
    background: linear-gradient(180deg, var(--app-primary-soft), var(--app-surface));
  }
}

.reward-icon-wrap {
  width: 64rpx;
  height: 64rpx;
  border-radius: 20rpx;
  background: var(--app-surface-2);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;

  &.unlocked {
    background: var(--app-primary-soft);
  }
}

.reward-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4rpx;
}

.reward-name {
  font-size: 27rpx;
  color: var(--app-text);
  font-weight: 600;
}

.reward-desc {
  font-size: 22rpx;
  color: var(--app-text-2);
}

.reward-status {
  display: flex;
  align-items: center;
  gap: 6rpx;
  flex-shrink: 0;
}

.reward-status-text {
  font-size: 22rpx;
  color: var(--app-success);
  font-weight: 500;

  &.locked {
    color: var(--app-text-3);
  }
}
</style>
