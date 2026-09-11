<template>
  <view class="page-container">
    <view class="page-bg"></view>

    <view class="header">
      <text class="page-title">设置</text>
      <text class="page-subtitle">播放偏好 · 提醒 · 关于</text>
    </view>

    <!-- 播放设置 -->
    <view class="section">
      <text class="section-title">播放设置</text>
      <view class="settings-card app-card">
        <view class="setting-item">
          <view class="setting-info">
            <view class="setting-icon">
              <Icon name="play" :size="20" color="var(--app-primary)" />
            </view>
            <view class="setting-text">
              <text class="setting-label">启动时自动恢复播放</text>
              <text class="setting-desc">打开 App 时自动恢复上次的声音组合</text>
            </view>
          </view>
          <switch :checked="autoResume" @change="autoResume = !autoResume" :color="switchColor" />
        </view>
        <view class="divider" />
        <view class="setting-item" @click="showFadePicker = true">
          <view class="setting-info">
            <view class="setting-icon">
              <Icon name="wave" :size="20" color="var(--app-primary)" />
            </view>
            <view class="setting-text">
              <text class="setting-label">淡入淡出时长</text>
              <text class="setting-desc">播放/停止时的过渡时间</text>
            </view>
          </view>
          <view class="setting-value">
            <text>{{ fadeDuration }}s</text>
            <Icon name="chevron-right" :size="20" color="var(--app-text-3)" />
          </view>
        </view>
        <view class="divider" />
        <view class="setting-item" @click="showTrackPicker = true">
          <view class="setting-info">
            <view class="setting-icon">
              <Icon name="mixer" :size="20" color="var(--app-primary)" />
            </view>
            <view class="setting-text">
              <text class="setting-label">混音轨数上限</text>
              <text class="setting-desc">同时播放的声音数量上限</text>
            </view>
          </view>
          <view class="setting-value">
            <text>{{ maxTracks }} 路</text>
            <Icon name="chevron-right" :size="20" color="var(--app-text-3)" />
          </view>
        </view>
      </view>
    </view>

    <!-- 提醒设置 -->
    <view class="section">
      <text class="section-title">提醒设置</text>
      <view class="settings-card app-card">
        <view class="setting-item">
          <view class="setting-info">
            <view class="setting-icon">
              <Icon name="moon" :size="20" color="var(--app-primary)" />
            </view>
            <view class="setting-text">
              <text class="setting-label">每日助眠提醒</text>
              <text class="setting-desc">在设定时间提醒你开始放松</text>
            </view>
          </view>
          <switch :checked="sleepReminder" @change="sleepReminder = !sleepReminder" :color="switchColor" />
        </view>
        <view class="divider" v-if="sleepReminder" />
        <view class="setting-item" v-if="sleepReminder" @click="showTimePicker = true">
          <view class="setting-info">
            <view class="setting-icon">
              <Icon name="timer" :size="20" color="var(--app-primary)" />
            </view>
            <view class="setting-text">
              <text class="setting-label">提醒时间</text>
            </view>
          </view>
          <view class="setting-value">
            <text>{{ reminderTime }}</text>
            <Icon name="chevron-right" :size="20" color="var(--app-text-3)" />
          </view>
        </view>
      </view>
    </view>

    <!-- 提醒设置 -->
    <view class="section">
      <text class="section-title">提醒设置</text>
      <view class="settings-card app-card">
        <view class="setting-item" @click="toggleReminder">
          <view class="setting-left">
            <view class="setting-icon" style="background: rgba(126, 147, 168, 0.15);">
              <Icon name="moon" :size="18" color="#7E93A8" />
            </view>
            <view class="setting-text">
              <text class="setting-name">使用提醒</text>
              <text class="setting-desc">{{ reminderEnabled ? '每晚 22:00 提醒' : '已关闭' }}</text>
            </view>
          </view>
          <view class="switch" :class="{ on: reminderEnabled }">
            <view class="switch-thumb"></view>
          </view>
        </view>
        <view class="divider" />
        <view class="setting-item" @click="changeReminderTime">
          <view class="setting-left">
            <view class="setting-icon" style="background: rgba(126, 154, 116, 0.15);">
              <Icon name="clock" :size="18" color="#7E9A74" />
            </view>
            <view class="setting-text">
              <text class="setting-name">提醒时间</text>
              <text class="setting-desc">{{ reminderTime }}</text>
            </view>
          </view>
          <Icon name="chevron-right" :size="16" color="var(--app-text-3, $uni-text-color-grey)" />
        </view>
      </view>
    </view>

    <!-- 关于 -->
    <view class="section">
      <text class="section-title">关于</text>
      <view class="settings-card app-card">
        <view class="setting-item">
          <view class="setting-info">
            <view class="setting-icon">
              <Icon name="palette" :size="20" color="var(--app-primary)" />
            </view>
            <view class="setting-text">
              <text class="setting-label">当前主题</text>
            </view>
          </view>
          <view class="setting-value">
            <text class="current-theme">{{ currentThemeLabel }}</text>
          </view>
        </view>
        <view class="divider" />
        <view class="setting-item">
          <view class="setting-info">
            <view class="setting-icon">
              <Icon name="mountain" :size="20" color="var(--app-primary)" />
            </view>
            <view class="setting-text">
              <text class="setting-label">版本</text>
            </view>
          </view>
          <text class="setting-value-text">v1.0.0</text>
        </view>
        <view class="divider" />
        <view class="setting-item" @click="clearCache">
          <view class="setting-info">
            <view class="setting-icon">
              <Icon name="close" :size="20" color="var(--app-primary)" />
            </view>
            <view class="setting-text">
              <text class="setting-label">清除缓存</text>
            </view>
          </view>
          <view class="setting-value">
            <text>12.3 MB</text>
            <Icon name="chevron-right" :size="20" color="var(--app-text-3)" />
          </view>
        </view>
      </view>
    </view>

    <!-- 弹窗：淡入淡出 -->
    <view class="modal-overlay" v-if="showFadePicker" @click="showFadePicker = false">
      <view class="modal-content app-card" @click.stop>
        <text class="modal-title">淡入淡出时长</text>
        <view class="picker-options">
          <view
            v-for="v in [0.5, 1, 1.5, 2]"
            :key="v"
            class="picker-option"
            :class="{ active: fadeDuration === v }"
            @click="fadeDuration = v; showFadePicker = false"
          >
            <text>{{ v }}s</text>
          </view>
        </view>
      </view>
    </view>

    <!-- 弹窗：音轨上限 -->
    <view class="modal-overlay" v-if="showTrackPicker" @click="showTrackPicker = false">
      <view class="modal-content app-card" @click.stop>
        <text class="modal-title">混音轨数上限</text>
        <view class="picker-options">
          <view
            v-for="v in [4, 6, 8]"
            :key="v"
            class="picker-option"
            :class="{ active: maxTracks === v }"
            @click="maxTracks = v; showTrackPicker = false"
          >
            <text>{{ v }} 路</text>
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import Icon from '@/components/Icon.vue'
import { themeState, schemeMeta, schemePrimary, UIMODE_META } from '@/theme/index'

const autoResume = ref(true)
const fadeDuration = ref(1)
const maxTracks = ref(6)
const sleepReminder = ref(false)
const reminderTime = ref('22:30')
const reminderEnabled = ref(true)

const toggleReminder = () => {
  reminderEnabled.value = !reminderEnabled.value
}

const changeReminderTime = () => {
  uni.showActionSheet({
    itemList: ['21:00', '21:30', '22:00', '22:30', '23:00'],
    success: (res) => {
      const times = ['21:00', '21:30', '22:00', '22:30', '23:00']
      reminderTime.value = times[res.tapIndex]
    }
  })
}

const showFadePicker = ref(false)
const showTrackPicker = ref(false)
const showTimePicker = ref(false)

// 原生 switch 颜色随主题响应式更新
const switchColor = computed(() => schemePrimary(themeState.scheme))

const currentThemeLabel = computed(
  () => `${schemeMeta(themeState.scheme).label} · ${UIMODE_META[themeState.ui].label}`
)

const clearCache = () => {
  uni.showToast({ title: '缓存已清除', icon: 'success' })
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

.section {
  margin-top: 36rpx;
}

.section-title {
  font-size: 24rpx;
  font-weight: 600;
  letter-spacing: 0.3rpx;
  color: var(--app-text-2, $uni-text-color-grey);
  margin-bottom: 16rpx;
  padding-left: 4rpx;
  display: block;
}

.settings-card {
  overflow: hidden;
}

.settings-card .divider {
  margin-left: 102rpx;
}

.setting-item {
  padding: 24rpx 24rpx;
  display: flex;
  align-items: center;
  justify-content: space-between;
  transition: transform 0.16s cubic-bezier(.4, 0, .2, 1);

  &:active {
    background: var(--app-press, $uni-bg-color-hover);
    transform: scale(0.99);
  }
}

.setting-info {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 18rpx;
}

.setting-icon {
  width: 60rpx;
  height: 60rpx;
  border-radius: 18rpx;
  background: var(--app-primary-soft, rgba($app-primary, 0.12));
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.setting-text {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4rpx;
}

.setting-label {
  font-size: 28rpx;
  color: var(--app-text, $uni-text-color);
  font-weight: 500;
}

.setting-desc {
  font-size: 22rpx;
  color: var(--app-text-2, $uni-text-color-grey);
}

.setting-value {
  display: flex;
  align-items: center;
  gap: 8rpx;
  font-size: 26rpx;
  color: var(--app-text-2, $uni-text-color-grey);
  flex-shrink: 0;
}

.setting-value-text {
  font-size: 26rpx;
  color: var(--app-text-2, $uni-text-color-grey);
}

.current-theme {
  font-size: 23rpx;
  color: var(--app-primary, $app-primary);
  font-weight: 600;
}

/* 弹窗 */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: var(--app-overlay, rgba(0, 0, 0, 0.38));
  z-index: 200;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 64rpx;
}

.modal-content {
  width: 100%;
  padding: 40rpx;
  max-width: 500rpx;
}

.modal-title {
  font-size: 32rpx;
  font-weight: 600;
  color: var(--app-text, $uni-text-color);
  display: block;
  margin-bottom: 32rpx;
  text-align: center;
}

.picker-options {
  display: flex;
  gap: 16rpx;
  justify-content: center;
}

.picker-option {
  padding: 20rpx 36rpx;
  border-radius: $app-radius-sm;
  background: var(--app-input-bg, $uni-bg-color-grey);
  border: 1rpx solid var(--app-input-border, transparent);
  font-size: 28rpx;
  color: var(--app-text, $uni-text-color);
  transition: all 0.2s;

  &.active {
    background: var(--app-primary, $app-primary);
    border-color: transparent;
    color: var(--app-on-primary, #fff);
    font-weight: 600;
  }
}
</style>