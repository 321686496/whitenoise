<template>
  <view class="page-container">
    <view class="page-bg"></view>

    <view class="header">
      <text class="page-title">每日签到</text>
      <text class="page-subtitle">坚持使用，解锁专属奖励</text>
    </view>

    <view class="streak-card app-card">
      <view class="streak-top">
        <text class="streak-label">已连续签到</text>
        <view class="streak-num-row">
          <text class="streak-num">{{ streakDays }}</text>
          <text class="streak-unit">天</text>
        </view>
      </view>
      <view class="divider" />
      <view class="streak-bottom">
        <Icon name="gift" :size="16" color="var(--app-primary)" />
        <text class="streak-hint">再坚持 <text class="accent">{{ remainDays }}</text> 天解锁奖励</text>
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
            <Icon v-if="day.checked" name="check" :size="18" color="#fff" />
            <text v-else class="day-num">{{ day.date }}</text>
          </view>
        </view>
      </view>
    </view>

    <view class="checkin-section">
      <view
        class="checkin-btn"
        :class="{ done: checkedInToday }"
        @click="handleCheckin"
      >
        <Icon :name="checkedInToday ? 'check' : 'trophy'" :size="32" :color="checkedInToday ? '#fff' : 'var(--app-primary)'" />
        <text class="checkin-btn-text">{{ checkedInToday ? '已签到' : '签到' }}</text>
      </view>
      <view v-if="showSuccess" class="success-tip">
        <Icon name="check" :size="14" color="var(--app-primary)" />
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
              :color="reward.unlocked ? 'var(--app-primary)' : 'var(--app-text-3)'"
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
.header {
  padding: 16rpx 4rpx 8rpx;
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
  color: var(--app-text-2, $uni-text-color-grey);
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
  color: var(--app-primary, $app-primary);
  line-height: 1;
}

.streak-unit {
  font-size: 26rpx;
  color: var(--app-primary, $app-primary);
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

.streak-hint {
  font-size: 24rpx;
  color: var(--app-text-2, $uni-text-color-grey);

  .accent {
    color: var(--app-primary, $app-primary);
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
  color: var(--app-text-2, $uni-text-color-grey);
  font-weight: 500;
}

.day-circle {
  width: 68rpx;
  height: 68rpx;
  border-radius: 50%;
  background: var(--app-subtle, $uni-bg-color-grey);
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.16s cubic-bezier(.4, 0, .2, 1);

  &.checked {
    background: var(--app-primary, $app-primary);
  }

  &.today {
    border: 2rpx solid var(--app-primary, $app-primary);
    background: var(--app-primary-soft, rgba($app-primary, 0.12));
  }
}

.day-num {
  font-size: 24rpx;
  font-weight: 600;
  color: var(--app-text-2, $uni-text-color-grey);

  .today & {
    color: var(--app-primary, $app-primary);
  }

  .future & {
    color: var(--app-text-3, $uni-text-color-disable);
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
  width: 160rpx;
  height: 160rpx;
  border-radius: 50%;
  background: var(--app-primary-soft, rgba($app-primary, 0.12));
  border: 3rpx solid var(--app-primary, $app-primary);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 6rpx;
  transition: all 0.16s cubic-bezier(.4, 0, .2, 1);

  &:active {
    transform: scale(0.9);
  }

  &.done {
    background: var(--app-primary, $app-primary);
    border-color: var(--app-primary, $app-primary);
  }
}

.checkin-btn-text {
  font-size: 24rpx;
  font-weight: 600;
  color: var(--app-primary, $app-primary);

  .done & {
    color: #fff;
  }
}

.success-tip {
  display: flex;
  align-items: center;
  gap: 6rpx;
  animation: fadeUp 0.3s ease-out;
}

.success-text {
  font-size: 24rpx;
  color: var(--app-primary, $app-primary);
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
  transition: all 0.16s cubic-bezier(.4, 0, .2, 1);

  &:active {
    transform: scale(0.99);
  }

  &.unlocked {
    border-color: var(--app-primary, $app-primary);
    background: linear-gradient(180deg, var(--app-primary-soft, rgba($app-primary, 0.12)), var(--app-card-bg));
  }
}

.reward-icon-wrap {
  width: 64rpx;
  height: 64rpx;
  border-radius: 20rpx;
  background: var(--app-subtle, $uni-bg-color-grey);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;

  &.unlocked {
    background: var(--app-primary-soft, rgba($app-primary, 0.12));
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
  color: var(--app-text, $uni-text-color);
  font-weight: 600;
}

.reward-desc {
  font-size: 22rpx;
  color: var(--app-text-2, $uni-text-color-grey);
}

.reward-status {
  display: flex;
  align-items: center;
  gap: 6rpx;
  flex-shrink: 0;
}

.reward-status-text {
  font-size: 22rpx;
  color: var(--app-primary, $app-primary);
  font-weight: 500;

  &.locked {
    color: var(--app-text-3, $uni-text-color-disable);
  }
}
</style>
