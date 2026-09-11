<template>
  <view class="page-container">
    <view class="page-bg"></view>

    <view class="header">
      <view class="header-top">
        <view>
          <text class="page-title">播放历史</text>
          <text class="page-subtitle">回顾你的声音足迹</text>
        </view>
        <view class="clear-btn" @click="clearHistory" v-if="totalCount > 0">
          <text class="clear-text">清空历史</text>
        </view>
      </view>
    </view>

    <view v-if="historyGroups.length > 0">
      <view class="section" v-for="group in historyGroups" :key="group.date">
        <text class="section-title">{{ group.date }}</text>
        <view class="history-card app-card">
          <view
            class="history-item"
            v-for="(item, idx) in group.items"
            :key="item.id"
          >
            <view class="time-col">
              <text class="time-text">{{ item.time }}</text>
            </view>
            <view class="history-info">
              <text class="history-scene-name">{{ item.sceneName }}</text>
              <view class="history-meta">
                <text class="history-duration">{{ item.duration }} 分钟</text>
                <view class="meta-dot" />
                <view class="sound-icons-row">
                  <view
                    class="sound-mini-icon"
                    v-for="s in item.sounds"
                    :key="s.id"
                    :style="{ background: s.colorSoft }"
                  >
                    <Icon :name="s.iconName" :size="12" :color="s.color" />
                  </view>
                </view>
              </view>
            </view>
            <view class="replay-btn" @click="replay(item)">
              <Icon name="play" :size="18" color="var(--app-primary)" />
            </view>
            <view v-if="idx < group.items.length - 1" class="item-divider" />
          </view>
        </view>
      </view>

      <view class="footer-count">
        <text class="footer-text">共 {{ totalCount }} 条记录</text>
      </view>
    </view>

    <view class="empty-state app-card" v-else>
      <Icon name="clock" :size="56" color="var(--app-primary-soft)" />
      <text class="empty-text">还没有播放记录</text>
      <text class="empty-hint">开始你的第一次声音旅程吧</text>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import Icon from '@/components/Icon.vue'

interface HistorySound {
  id: string
  iconName: string
  color: string
  colorSoft: string
}

interface HistoryItem {
  id: string
  time: string
  sceneName: string
  duration: number
  sounds: HistorySound[]
}

interface HistoryGroup {
  date: string
  items: HistoryItem[]
}

const historyGroups = ref<HistoryGroup[]>([
  {
    date: '今天',
    items: [
      {
        id: 'h1',
        time: '22:30',
        sceneName: '深夜雨声',
        duration: 45,
        sounds: [
          { id: 's5', iconName: 'rain', color: '#7E93A8', colorSoft: 'rgba(126, 147, 168, 0.15)' },
          { id: 's6', iconName: 'wave-ocean', color: '#5F8296', colorSoft: 'rgba(95, 130, 150, 0.15)' },
          { id: 's7', iconName: 'white-noise', color: '#8296A8', colorSoft: 'rgba(130, 150, 168, 0.15)' },
        ],
      },
      {
        id: 'h2',
        time: '14:00',
        sceneName: '白噪音 + 雨声',
        duration: 30,
        sounds: [
          { id: 's1', iconName: 'white-noise', color: '#8296A8', colorSoft: 'rgba(130, 150, 168, 0.15)' },
          { id: 's5', iconName: 'rain', color: '#7E93A8', colorSoft: 'rgba(126, 147, 168, 0.15)' },
        ],
      },
    ],
  },
  {
    date: '昨天',
    items: [
      {
        id: 'h3',
        time: '23:00',
        sceneName: '海浪入眠',
        duration: 60,
        sounds: [
          { id: 's6', iconName: 'wave-ocean', color: '#5F8296', colorSoft: 'rgba(95, 130, 150, 0.15)' },
          { id: 's5', iconName: 'rain', color: '#7E93A8', colorSoft: 'rgba(126, 147, 168, 0.15)' },
        ],
      },
      {
        id: 'h4',
        time: '15:30',
        sceneName: '森林晨曦',
        duration: 25,
        sounds: [
          { id: 's7', iconName: 'forest', color: '#7E9A74', colorSoft: 'rgba(126, 154, 116, 0.15)' },
          { id: 's8', iconName: 'bird', color: '#8FAF8F', colorSoft: 'rgba(143, 175, 143, 0.15)' },
          { id: 's9', iconName: 'stream', color: '#7F9AA6', colorSoft: 'rgba(127, 154, 166, 0.15)' },
        ],
      },
      {
        id: 'h5',
        time: '09:00',
        sceneName: '咖啡厅时光',
        duration: 40,
        sounds: [
          { id: 's10', iconName: 'coffee', color: '#A89068', colorSoft: 'rgba(168, 144, 104, 0.15)' },
          { id: 's1', iconName: 'white-noise', color: '#8296A8', colorSoft: 'rgba(130, 150, 168, 0.15)' },
        ],
      },
    ],
  },
  {
    date: '8月15日',
    items: [
      {
        id: 'h6',
        time: '21:00',
        sceneName: '篝火夜话',
        duration: 50,
        sounds: [
          { id: 's9', iconName: 'fire', color: '#B97A48', colorSoft: 'rgba(185, 122, 72, 0.15)' },
          { id: 's7', iconName: 'forest', color: '#7E9A74', colorSoft: 'rgba(126, 154, 116, 0.15)' },
          { id: 's5', iconName: 'rain', color: '#7E93A8', colorSoft: 'rgba(126, 147, 168, 0.15)' },
        ],
      },
    ],
  },
])

const totalCount = computed(() => {
  return historyGroups.value.reduce((sum, g) => sum + g.items.length, 0)
})

const replay = (item: HistoryItem) => {
  uni.showToast({ title: `重新播放「${item.sceneName}」`, icon: 'none' })
}

const clearHistory = () => {
  uni.showModal({
    title: '清空历史',
    content: '确定要清空所有播放历史吗？此操作不可撤销。',
    success: (res) => {
      if (res.confirm) {
        historyGroups.value = []
        uni.showToast({ title: '历史已清空', icon: 'success' })
      }
    },
  })
}
</script>

<style lang="scss" scoped>
.header {
  padding: 16rpx 4rpx 8rpx;
}

.header-top {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
}

.clear-btn {
  padding: 12rpx 24rpx;
  border-radius: 20rpx;
  background: rgba(196, 139, 139, 0.1);
  margin-top: 8rpx;
  transition: all 0.16s cubic-bezier(.4, 0, .2, 1);

  &:active {
    transform: scale(0.9);
  }
}

.clear-text {
  font-size: 24rpx;
  color: #C48B8B;
  font-weight: 500;
}

.section {
  margin-top: 32rpx;
}

.history-card {
  overflow: hidden;
}

.history-item {
  padding: 24rpx 24rpx;
  display: flex;
  align-items: center;
  gap: 18rpx;
  position: relative;
  transition: transform 0.16s cubic-bezier(.4, 0, .2, 1);

  &:active {
    background: var(--app-press, $uni-bg-color-hover);
    transform: scale(0.99);
  }
}

.item-divider {
  position: absolute;
  bottom: 0;
  left: 102rpx;
  right: 24rpx;
  height: 1rpx;
  background: var(--app-divider, $uni-border-color);
}

.time-col {
  width: 78rpx;
  flex-shrink: 0;
}

.time-text {
  font-size: 28rpx;
  font-weight: 600;
  color: var(--app-primary, $app-primary);
}

.history-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 8rpx;
  min-width: 0;
}

.history-scene-name {
  font-size: 28rpx;
  font-weight: 500;
  color: var(--app-text, $uni-text-color);
}

.history-meta {
  display: flex;
  align-items: center;
  gap: 8rpx;
}

.history-duration {
  font-size: 22rpx;
  color: var(--app-text-2, $uni-text-color-grey);
  flex-shrink: 0;
}

.meta-dot {
  width: 6rpx;
  height: 6rpx;
  border-radius: 50%;
  background: var(--app-text-2, $uni-text-color-grey);
  opacity: 0.5;
  flex-shrink: 0;
}

.sound-icons-row {
  display: flex;
  align-items: center;
  gap: 6rpx;
}

.sound-mini-icon {
  width: 36rpx;
  height: 36rpx;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.replay-btn {
  width: 60rpx;
  height: 60rpx;
  border-radius: 20rpx;
  background: var(--app-primary-soft, rgba($app-primary, 0.12));
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  transition: all 0.16s cubic-bezier(.4, 0, .2, 1);

  &:active {
    transform: scale(0.9);
  }
}

.footer-count {
  padding: 32rpx 0 20rpx;
  text-align: center;
}

.footer-text {
  font-size: 23rpx;
  color: var(--app-text-2, $uni-text-color-grey);
}

.empty-state {
  margin-top: 80rpx;
  padding: 80rpx 40rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16rpx;
}

.empty-text {
  font-size: 29rpx;
  color: var(--app-text, $uni-text-color);
  font-weight: 500;
  margin-top: 8rpx;
}

.empty-hint {
  font-size: 23rpx;
  color: var(--app-text-2, $uni-text-color-grey);
}
</style>
