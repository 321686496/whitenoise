<template>
  <view class="page-container">
    <view class="header">
      <text class="page-title">设置</text>
    </view>

    <!-- 播放设置 -->
    <view class="section">
      <text class="section-title">播放设置</text>
      <view class="settings-card">
        <view class="setting-item">
          <view class="setting-info">
            <text class="setting-label">启动时自动恢复播放</text>
            <text class="setting-desc">打开 App 时自动恢复上次的声音组合</text>
          </view>
          <switch :checked="autoResume" @change="autoResume = !autoResume" color="#7B8FA1" />
        </view>
        <view class="divider" />
        <view class="setting-item">
          <view class="setting-info">
            <text class="setting-label">淡入淡出时长</text>
            <text class="setting-desc">播放/停止时的过渡时间</text>
          </view>
          <view class="setting-value" @click="showFadePicker = true">
            <text>{{ fadeDuration }}s</text>
            <text class="arrow">›</text>
          </view>
        </view>
        <view class="divider" />
        <view class="setting-item">
          <view class="setting-info">
            <text class="setting-label">混音轨数上限</text>
            <text class="setting-desc">同时播放的声音数量上限</text>
          </view>
          <view class="setting-value" @click="showTrackPicker = true">
            <text>{{ maxTracks }} 路</text>
            <text class="arrow">›</text>
          </view>
        </view>
      </view>
    </view>

    <!-- 提醒设置 -->
    <view class="section">
      <text class="section-title">提醒设置</text>
      <view class="settings-card">
        <view class="setting-item">
          <view class="setting-info">
            <text class="setting-label">每日助眠提醒</text>
            <text class="setting-desc">在设定时间提醒你开始放松</text>
          </view>
          <switch :checked="sleepReminder" @change="sleepReminder = !sleepReminder" color="#7B8FA1" />
        </view>
        <view class="divider" v-if="sleepReminder" />
        <view class="setting-item" v-if="sleepReminder" @click="showTimePicker = true">
          <view class="setting-info">
            <text class="setting-label">提醒时间</text>
          </view>
          <view class="setting-value">
            <text>{{ reminderTime }}</text>
            <text class="arrow">›</text>
          </view>
        </view>
      </view>
    </view>

    <!-- 关于 -->
    <view class="section">
      <text class="section-title">关于</text>
      <view class="settings-card">
        <view class="setting-item">
          <view class="setting-info">
            <text class="setting-label">版本</text>
          </view>
          <text class="setting-value-text">v1.0.0</text>
        </view>
        <view class="divider" />
        <view class="setting-item" @click="clearCache">
          <view class="setting-info">
            <text class="setting-label">清除缓存</text>
          </view>
          <view class="setting-value">
            <text>12.3 MB</text>
            <text class="arrow">›</text>
          </view>
        </view>
      </view>
    </view>

    <!-- 弹窗：淡入淡出 -->
    <view class="modal-overlay" v-if="showFadePicker" @click="showFadePicker = false">
      <view class="modal-content" @click.stop>
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
      <view class="modal-content" @click.stop>
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
import { ref } from 'vue'

const autoResume = ref(true)
const fadeDuration = ref(1)
const maxTracks = ref(6)
const sleepReminder = ref(false)
const reminderTime = ref('22:30')

const showFadePicker = ref(false)
const showTrackPicker = ref(false)
const showTimePicker = ref(false)

const clearCache = () => {
  uni.showToast({ title: '缓存已清除', icon: 'success' })
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

.section {
  padding: 0 32rpx;
  margin-bottom: 32rpx;
}

.section-title {
  font-size: 28rpx;
  font-weight: 600;
  color: $uni-text-color-grey;
  margin-bottom: 16rpx;
  display: block;
  padding-left: 4rpx;
}

.settings-card {
  background: $app-card-bg;
  border-radius: $app-radius;
  box-shadow: $app-shadow;
  overflow: hidden;
}

.setting-item {
  padding: 28rpx 24rpx;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.setting-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4rpx;
}

.setting-label {
  font-size: 28rpx;
  color: $uni-text-color;
}

.setting-desc {
  font-size: 22rpx;
  color: $uni-text-color-grey;
}

.setting-value {
  display: flex;
  align-items: center;
  gap: 8rpx;
  font-size: 26rpx;
  color: $uni-text-color-grey;
}

.arrow {
  font-size: 32rpx;
  color: $uni-text-color-grey;
}

.setting-value-text {
  font-size: 26rpx;
  color: $uni-text-color-grey;
}

/* 弹窗 */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: $uni-bg-color-mask;
  z-index: 200;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 64rpx;
}

.modal-content {
  width: 100%;
  background: $app-card-bg;
  border-radius: $app-radius;
  padding: 40rpx;
  max-width: 500rpx;
}

.modal-title {
  font-size: 32rpx;
  font-weight: 600;
  color: $uni-text-color;
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
  background: $uni-bg-color-grey;
  font-size: 28rpx;
  color: $uni-text-color;
  transition: all 0.2s;

  &.active {
    background: $app-primary;
    color: #fff;
  }
}
</style>