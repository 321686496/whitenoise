<template>
  <view class="page-container">
    <view class="page-bg"></view>

    <view class="header">
      <text class="page-title">使用数据</text>
      <text class="page-subtitle">你的声音旅程</text>
    </view>

    <view class="overview-card app-card">
      <view class="overview-item">
        <text class="overview-num">{{ weekUsageDays }}</text>
        <text class="overview-label">使用天数</text>
      </view>
      <view class="overview-sep" />
      <view class="overview-item">
        <text class="overview-num">{{ weekTotalHours }}</text>
        <text class="overview-label">累计时长</text>
      </view>
      <view class="overview-sep" />
      <view class="overview-item">
        <text class="overview-num accent">{{ weekFavScene }}</text>
        <text class="overview-label">最爱场景</text>
      </view>
    </view>

    <view class="section">
      <text class="section-title">本周使用趋势</text>
      <view class="chart-card app-card">
        <view class="chart-row">
          <view
            v-for="bar in chartBars"
            :key="bar.label"
            class="chart-col"
          >
            <view class="bar-wrap">
              <view
                class="bar"
                :class="{ empty: bar.minutes === 0 }"
                :style="{ height: bar.heightPercent + '%' }"
              />
            </view>
            <text class="bar-label">{{ bar.label }}</text>
            <text class="bar-value" v-if="bar.minutes > 0">{{ bar.minutes }}m</text>
          </view>
        </view>
      </view>
    </view>

    <view class="section">
      <text class="section-title">最爱场景 Top 3</text>
      <view class="top-list">
        <view
          v-for="(scene, index) in topScenes"
          :key="scene.name"
          class="top-item app-card"
        >
          <view class="rank-badge" :class="{ gold: index === 0, silver: index === 1, bronze: index === 2 }">
            <text class="rank-num">{{ index + 1 }}</text>
          </view>
          <view class="top-info">
            <view class="top-name-row">
              <text class="top-name">{{ scene.name }}</text>
              <text class="top-duration">{{ scene.duration }}</text>
            </view>
            <view class="percent-track">
              <view class="percent-fill" :style="{ width: scene.percent + '%' }" />
            </view>
            <text class="percent-text">{{ scene.percent }}%</text>
          </view>
        </view>
      </view>
    </view>

    <view class="section">
      <text class="section-title">累计成就</text>
      <view class="achieve-grid">
        <view class="achieve-item app-card">
          <view class="achieve-icon">
            <Icon name="clock" :size="22" color="var(--app-primary)" />
          </view>
          <text class="achieve-num">128</text>
          <text class="achieve-label">累计使用分钟</text>
        </view>
        <view class="achieve-item app-card">
          <view class="achieve-icon">
            <Icon name="mountain" :size="22" color="var(--app-primary)" />
          </view>
          <text class="achieve-num">5</text>
          <text class="achieve-label">探索场景</text>
        </view>
        <view class="achieve-item app-card">
          <view class="achieve-icon">
            <Icon name="mixer" :size="22" color="var(--app-primary)" />
          </view>
          <text class="achieve-num">3</text>
          <text class="achieve-label">自定义场景</text>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import Icon from '@/components/Icon.vue'

interface ChartBar {
  label: string
  minutes: number
  heightPercent: number
}

interface TopScene {
  name: string
  duration: string
  percent: number
}

const weekUsageDays = ref(5)
const weekTotalHours = ref('3h 28m')
const weekFavScene = ref('雨声')

const weeklyMinutes = ref([45, 30, 50, 20, 25, 0, 0])

const maxMinutes = computed(() => Math.max(...weeklyMinutes.value, 1))

const chartBars = computed<ChartBar[]>(() => {
  const labels = ['一', '二', '三', '四', '五', '六', '日']
  return labels.map((label, i) => ({
    label,
    minutes: weeklyMinutes.value[i],
    heightPercent: Math.max((weeklyMinutes.value[i] / maxMinutes.value) * 100, 4),
  }))
})

const topScenes = ref<TopScene[]>([
  { name: '雨声', duration: '1h 23m', percent: 40 },
  { name: '白噪音', duration: '1h 02m', percent: 30 },
  { name: '森林', duration: '31m', percent: 15 },
])
</script>

<style lang="scss" scoped>
.header {
  padding: 16rpx 4rpx 8rpx;
}

.overview-card {
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
  font-size: 36rpx;
  font-weight: 800;
  color: var(--app-primary, $app-primary);
  line-height: 1.2;

  &.accent {
    font-size: 30rpx;
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

.chart-card {
  padding: 28rpx 20rpx 20rpx;
}

.chart-row {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  height: 260rpx;
  gap: 8rpx;
}

.chart-col {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  height: 100%;
}

.bar-wrap {
  flex: 1;
  width: 100%;
  display: flex;
  align-items: flex-end;
  justify-content: center;
}

.bar {
  width: 40rpx;
  border-radius: 10rpx 10rpx 4rpx 4rpx;
  background: linear-gradient(180deg, var(--app-primary, $app-primary), var(--app-primary-soft, rgba($app-primary, 0.35)));
  transition: height 0.4s cubic-bezier(.4, 0, .2, 1);
  min-height: 8rpx;

  &.empty {
    background: var(--app-subtle, $uni-bg-color-grey);
    min-height: 8rpx;
  }
}

.bar-label {
  font-size: 22rpx;
  color: var(--app-text-2, $uni-text-color-grey);
  margin-top: 10rpx;
  font-weight: 500;
}

.bar-value {
  font-size: 18rpx;
  color: var(--app-primary, $app-primary);
  font-weight: 600;
  margin-top: 4rpx;
}

.top-list {
  display: flex;
  flex-direction: column;
  gap: 12rpx;
}

.top-item {
  display: flex;
  align-items: center;
  gap: 20rpx;
  padding: 22rpx 24rpx;
  transition: all 0.16s cubic-bezier(.4, 0, .2, 1);

  &:active {
    transform: scale(0.99);
  }
}

.rank-badge {
  width: 52rpx;
  height: 52rpx;
  border-radius: 16rpx;
  background: var(--app-subtle, $uni-bg-color-grey);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;

  &.gold {
    background: linear-gradient(135deg, #f0c27f, #e8a849);
  }

  &.silver {
    background: linear-gradient(135deg, #c0c7cf, #9ea8b3);
  }

  &.bronze {
    background: linear-gradient(135deg, #d4a373, #bc8a5f);
  }
}

.rank-num {
  font-size: 24rpx;
  font-weight: 700;
  color: #fff;
}

.top-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 8rpx;
}

.top-name-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.top-name {
  font-size: 27rpx;
  color: var(--app-text, $uni-text-color);
  font-weight: 600;
}

.top-duration {
  font-size: 23rpx;
  color: var(--app-text-2, $uni-text-color-grey);
}

.percent-track {
  height: 12rpx;
  border-radius: 6rpx;
  background: var(--app-subtle, $uni-bg-color-grey);
  overflow: hidden;
}

.percent-fill {
  height: 100%;
  border-radius: 6rpx;
  background: linear-gradient(90deg, var(--app-primary, $app-primary), var(--app-primary-soft, rgba($app-primary, 0.5)));
  transition: width 0.5s cubic-bezier(.4, 0, .2, 1);
}

.percent-text {
  font-size: 21rpx;
  color: var(--app-primary, $app-primary);
  font-weight: 600;
}

.achieve-grid {
  display: flex;
  gap: 12rpx;
}

.achieve-item {
  flex: 1;
  padding: 24rpx 12rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8rpx;
  transition: all 0.16s cubic-bezier(.4, 0, .2, 1);

  &:active {
    transform: scale(0.99);
  }
}

.achieve-icon {
  width: 60rpx;
  height: 60rpx;
  border-radius: 18rpx;
  background: var(--app-primary-soft, rgba($app-primary, 0.12));
  display: flex;
  align-items: center;
  justify-content: center;
}

.achieve-num {
  font-size: 36rpx;
  font-weight: 800;
  color: var(--app-primary, $app-primary);
  line-height: 1.2;
}

.achieve-label {
  font-size: 20rpx;
  color: var(--app-text-2, $uni-text-color-grey);
  text-align: center;
}
</style>
