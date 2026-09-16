<template>
  <!-- v2：自定义导航（pages.json 改 custom），NavBar 补返回入口；提醒设置两段合并为单一数据源（MASTER §10.3-1/2） -->
  <view class="page-container settings-page">
    <view class="page-bg"></view>

    <NavBar title="设置" />

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
          <switch :checked="autoResume" @change="onAutoResumeChange" :color="switchColor" />
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

    <!-- 提醒设置（§10.3-1：两段合一，单一数据源 shengqi-reminder） -->
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
              <text class="setting-desc">{{ reminderOn ? '在设定时间提醒你开始放松' : '已关闭' }}</text>
            </view>
          </view>
          <switch :checked="reminderOn" @change="onReminderChange" :color="switchColor" />
        </view>
        <template v-if="reminderOn">
          <view class="divider" />
          <view class="setting-item" @click="openTimePicker">
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
        </template>
      </view>
    </view>

    <!-- 关于 -->
    <view class="section">
      <text class="section-title">关于</text>
      <view class="settings-card app-card">
        <view class="setting-item" @click="goTheme">
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
            <Icon name="chevron-right" :size="20" color="var(--app-text-3)" />
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

    <!-- 底部 Sheet：提醒时间选择（§10.3-2 补齐 showTimePicker 死代码） -->
    <view class="st-sheet-mask" v-if="showTimePicker" @click="closeTimePicker">
      <view class="st-sheet" @click.stop>
        <view class="st-sheet-handle" aria-hidden="true" />
        <view class="st-sheet-head">
          <text class="st-sheet-title">提醒时间</text>
          <view class="st-sheet-close" aria-label="关闭" @click="closeTimePicker">
            <Icon name="close" :size="20" color="var(--app-text-2)" />
          </view>
        </view>
        <picker mode="time" :value="pendingTime" @change="onPendingTimeChange">
          <view class="st-time-row">
            <text class="st-time-value">{{ pendingTime }}</text>
            <text class="st-time-hint">点击修改时间</text>
          </view>
        </picker>
        <view class="btn-primary st-sheet-confirm" @click="confirmTime">确认</view>
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
import NavBar from '@/components/NavBar.vue'
import { themeState, schemeMeta, schemePrimary, resolveMode, UIMODE_META } from '@/theme/index'

/** 提醒设置单一数据源（与 shengqi-theme / shengqi-recent 同命名规约） */
const REMINDER_KEY = 'shengqi-reminder'

interface ReminderPrefs {
  on: boolean
  time: string
}

function loadReminderPrefs(): ReminderPrefs {
  try {
    const saved = uni.getStorageSync(REMINDER_KEY) as Partial<ReminderPrefs> | ''
    if (saved && typeof saved === 'object') {
      return {
        on: saved.on === true,
        time: typeof saved.time === 'string' && /^\d{2}:\d{2}$/.test(saved.time) ? saved.time : '22:30',
      }
    }
  } catch { /* 读取失败回退默认 */ }
  return { on: false, time: '22:30' }
}

const savedReminder = loadReminderPrefs()
const autoResume = ref(true)
const fadeDuration = ref(1)
const maxTracks = ref(6)
const reminderOn = ref(savedReminder.on)
const reminderTime = ref(savedReminder.time)

const persistReminder = () => {
  try {
    uni.setStorageSync(REMINDER_KEY, { on: reminderOn.value, time: reminderTime.value })
  } catch { /* 存储失败静默 */ }
}

type SwitchChangeEvent = { detail: { value: boolean } }

const onAutoResumeChange = (e: SwitchChangeEvent) => {
  autoResume.value = e.detail.value
}

const onReminderChange = (e: SwitchChangeEvent) => {
  reminderOn.value = e.detail.value
  persistReminder()
}

/* 时间选择 Sheet */
const showTimePicker = ref(false)
const pendingTime = ref(reminderTime.value)

const openTimePicker = () => {
  pendingTime.value = reminderTime.value
  showTimePicker.value = true
}

const closeTimePicker = () => {
  showTimePicker.value = false
}

type TimePickerChangeEvent = { detail: { value: string } }

const onPendingTimeChange = (e: TimePickerChangeEvent) => {
  pendingTime.value = e.detail.value
}

const confirmTime = () => {
  reminderTime.value = pendingTime.value
  persistReminder()
  showTimePicker.value = false
}

const showFadePicker = ref(false)
const showTrackPicker = ref(false)

// 原生 switch 颜色随主题响应式更新（配色 × 当前明暗）
const switchColor = computed(() => schemePrimary(themeState.scheme, resolveMode(themeState.mode)))

const currentThemeLabel = computed(
  () => `${schemeMeta(themeState.scheme).label} · ${UIMODE_META[themeState.ui].label}`
)

const goTheme = () => uni.navigateTo({ url: '/pages/theme/theme' })

const clearCache = () => {
  uni.showToast({ title: '缓存已清除', icon: 'success' })
}
</script>

<style lang="scss" scoped>
/* NavBar 自带 env(safe-area-inset-top)，去掉容器重复的安全区顶距 */
.settings-page {
  padding-top: calc(env(safe-area-inset-top, 0rpx) + 12rpx);
}

.section {
  margin-top: 36rpx;
}

.settings-card {
  overflow: hidden;
}

.settings-card .divider {
  margin-left: 102rpx;
}

.setting-item {
  min-height: 88rpx;
  padding: 24rpx;
  display: flex;
  align-items: center;
  justify-content: space-between;
  transition: transform var(--dur-fast) var(--ease-std), background var(--dur-fast) var(--ease-std);

  &:active {
    background: var(--app-press);
    transform: scale(0.96);
  }
}

.setting-info {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 18rpx;
  min-width: 0;
}

.setting-icon {
  width: 60rpx;
  height: 60rpx;
  border-radius: 18rpx;
  background: var(--app-primary-soft);
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
  min-width: 0;
}

.setting-label {
  font-size: 28rpx;
  color: var(--app-text);
  font-weight: 500;
}

.setting-desc {
  font-size: 22rpx;
  color: var(--app-text-2);
}

.setting-value {
  display: flex;
  align-items: center;
  gap: 8rpx;
  font-size: 26rpx;
  color: var(--app-text-2);
  flex-shrink: 0;
}

.setting-value-text {
  font-size: 26rpx;
  color: var(--app-text-2);
  flex-shrink: 0;
}

.current-theme {
  font-size: 23rpx;
  color: var(--app-primary);
  font-weight: 600;
}

/* ---------- 底部 Sheet：时间选择（v2 §8/§9：顶角 56rpx / shadow-4 / dur-slow，样式对齐 scene-detail） ---------- */
.st-sheet-mask {
  position: fixed;
  left: 0;
  top: 0;
  right: 0;
  bottom: 0;
  z-index: 300;
  background: var(--app-overlay);
  display: flex;
  align-items: flex-end;
  animation: stMaskIn var(--dur-slow) var(--ease-std) both;
}

.st-sheet {
  width: 100%;
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
  padding: 16rpx 32rpx calc(32rpx + env(safe-area-inset-bottom));
  background: var(--app-surface);
  border-top: 1rpx solid var(--app-line);
  border-radius: 56rpx 56rpx 0 0;
  box-shadow: var(--app-shadow-4), var(--app-inset);
  backdrop-filter: blur(var(--app-blur));
  -webkit-backdrop-filter: blur(var(--app-blur));
  animation: stSheetUp var(--dur-slow) var(--ease-std) both;
}

.st-sheet-handle {
  width: 72rpx;
  height: 8rpx;
  border-radius: 999rpx;
  background: var(--app-sunken);
  margin: 0 auto 20rpx;
  flex: none;
}

.st-sheet-head {
  display: flex;
  align-items: center;
  gap: 14rpx;
  flex: none;
}

.st-sheet-title {
  font-size: 30rpx;
  font-weight: 700;
  color: var(--app-text);
  letter-spacing: -0.3rpx;
  flex: 1;
}

.st-sheet-close {
  width: 88rpx;
  height: 88rpx;
  flex: none;
  margin-right: -18rpx;
  border-radius: 999rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: transform var(--dur-fast) var(--ease-std), background var(--dur-fast) var(--ease-std);

  &:active {
    transform: scale(0.96);
    background: var(--app-press);
  }
}

.st-time-row {
  min-height: 112rpx;
  margin-top: 24rpx;
  padding: 0 28rpx;
  box-sizing: border-box;
  border-radius: 28rpx;
  background: var(--app-sunken);
  border: 1rpx solid var(--app-line);
  display: flex;
  align-items: center;
  justify-content: space-between;
  transition: transform var(--dur-fast) var(--ease-std);

  &:active {
    transform: scale(0.96);
  }
}

.st-time-value {
  font-size: 44rpx;
  font-weight: 700;
  color: var(--app-text);
  letter-spacing: 1rpx;
}

.st-time-hint {
  font-size: 23rpx;
  color: var(--app-text-3);
}

.st-sheet-confirm {
  margin-top: 28rpx;
  width: 100%;
  min-height: 88rpx;
  box-sizing: border-box;
}

@keyframes stMaskIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes stSheetUp {
  from { transform: translateY(100%); }
  to { transform: translateY(0); }
}

@media (prefers-reduced-motion: reduce) {
  .st-sheet-mask,
  .st-sheet {
    animation: none;
  }
}

/* ---------- 中央弹窗（淡入淡出 / 音轨上限） ---------- */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: var(--app-overlay);
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
  color: var(--app-text);
  display: block;
  margin-bottom: 32rpx;
  text-align: center;
}

.picker-options {
  display: flex;
  gap: 16rpx;
  justify-content: center;
  flex-wrap: wrap;
}

.picker-option {
  min-height: 88rpx;
  padding: 20rpx 36rpx;
  box-sizing: border-box;
  border-radius: $app-radius-sm;
  background: var(--app-sunken);
  border: 1rpx solid var(--app-line);
  font-size: 28rpx;
  color: var(--app-text);
  display: flex;
  align-items: center;
  justify-content: center;
  transition: transform var(--dur-fast) var(--ease-std), background var(--dur-fast) var(--ease-std);

  &:active {
    transform: scale(0.96);
  }

  &.active {
    background: var(--app-primary);
    border-color: transparent;
    color: var(--app-on-primary);
    font-weight: 600;
  }
}
</style>
