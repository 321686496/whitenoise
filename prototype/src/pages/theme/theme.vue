<template>
  <view class="page-container">
    <view class="page-bg"></view>

    <view class="header">
      <text class="page-title">主题与风格</text>
      <text class="page-subtitle">自由组合配色 × UI 风格，即时预览全局效果</text>
    </view>

    <!-- 主预览卡片（实时呈现当前主题） -->
    <view class="preview-hero app-card">
      <view class="preview-brand">
        <view class="preview-logo">
          <image src="/static/logo-v10-1.jpg" mode="aspectFit" />
        </view>
        <view class="preview-info">
          <text class="preview-name">{{ currentSchemeLabel }}</text>
          <text class="preview-mode">{{ currentModeLabel }} · 实时预览</text>
        </view>
      </view>
      <view class="preview-wall">
        <view class="preview-card" v-for="p in previewItems" :key="p.icon">
          <Icon :name="p.icon" :size="26" color="var(--app-primary)" />
          <view class="preview-bar" :style="{ width: p.width + '%' }"></view>
        </view>
      </view>
    </view>

    <!-- 配色方案 -->
    <view class="section">
      <text class="section-title">配色方案</text>
      <view class="scheme-grid">
        <view
          v-for="s in schemes"
          :key="s.key"
          class="scheme-item"
          :class="{ active: activeScheme === s.key }"
          @click="selectScheme(s.key)"
        >
          <view class="scheme-swatch">
            <view
              class="swatch-dot"
              v-for="(c, i) in s.swatch"
              :key="i"
              :style="{ background: c, zIndex: 3 - i }"
            ></view>
          </view>
          <text class="scheme-name">{{ s.label }}</text>
          <text class="scheme-desc">{{ s.desc }}</text>
          <view class="scheme-check" v-if="activeScheme === s.key">
            <Icon name="check" :size="14" color="#fff" />
          </view>
        </view>
      </view>
    </view>

    <!-- UI 风格 -->
    <view class="section">
      <text class="section-title">UI 风格</text>
      <view class="mode-list app-card">
        <view
          v-for="m in modes"
          :key="m.key"
          class="mode-item"
          :class="{ active: activeMode === m.key }"
          @click="selectMode(m.key)"
        >
          <view class="mode-demo" :class="m.key">
            <view class="demo-card"></view>
            <view class="demo-btn"></view>
            <view class="demo-bar"></view>
          </view>
          <view class="mode-info">
            <text class="mode-name">{{ m.label }}</text>
            <text class="mode-desc">{{ m.desc }}</text>
          </view>
          <view class="mode-radio">
            <view class="radio-dot" v-if="activeMode === m.key"></view>
          </view>
        </view>
      </view>
    </view>

    <!-- 说明 -->
    <view class="tip app-card">
      <Icon name="check" :size="22" color="var(--app-primary)" />
      <text class="tip-text">切换即时生效并全局记忆，返回首页即可查看应用效果。</text>
    </view>
  </view>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import Icon from '@/components/Icon.vue'
import { setTheme, themeState } from '@/theme/index'
import { SCHEME_KEYS, schemeMeta, UIMODE_META, UI_MODES } from '@/theme/index'
import type { SchemeKey, UiMode } from '@/theme/index'

const activeScheme = ref<SchemeKey>(themeState.scheme)
const activeMode = ref<UiMode>(themeState.ui)

const schemes = SCHEME_KEYS.map(k => ({ key: k, ...schemeMeta(k) }))
const modes = UI_MODES.map(key => ({ key, ...UIMODE_META[key] }))

const currentSchemeLabel = computed(() => schemeMeta(activeScheme.value).label)
const currentModeLabel = computed(() => UIMODE_META[activeMode.value].label)

const previewItems = [
  { icon: 'white-noise', width: 58 },
  { icon: 'rain', width: 76 },
  { icon: 'forest', width: 44 },
  { icon: 'coffee', width: 62 },
]

const selectScheme = (k: SchemeKey) => {
  activeScheme.value = k
  setTheme(k, activeMode.value)
}

const selectMode = (k: UiMode) => {
  activeMode.value = k
  setTheme(activeScheme.value, k)
}
</script>

<style lang="scss" scoped>
.header {
  padding: 16rpx 4rpx 8rpx;
}

.page-title {
  font-size: 46rpx;
}

.page-subtitle {
  font-size: 24rpx;
  color: var(--app-text-2, $uni-text-color-grey);
  margin-top: 10rpx;
  display: block;
}

/* 主预览 */
.preview-hero {
  padding: 28rpx;
  margin-top: 24rpx;
}

.preview-brand {
  display: flex;
  align-items: center;
  gap: 20rpx;
  margin-bottom: 24rpx;
}

.preview-logo {
  width: 76rpx;
  height: 76rpx;
  border-radius: 22rpx;
  overflow: hidden;
  background: var(--app-subtle, $uni-bg-color-grey);
}

.preview-logo image {
  width: 100%;
  height: 100%;
}

.preview-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4rpx;
}

.preview-name {
  font-size: 32rpx;
  font-weight: 700;
  color: var(--app-text, $uni-text-color);
}

.preview-mode {
  font-size: 23rpx;
  color: var(--app-primary, $app-primary);
  font-weight: 600;
}

.preview-wall {
  display: flex;
  gap: 14rpx;
}

.preview-card {
  flex: 1;
  min-height: 130rpx;
  border-radius: 20rpx;
  background: linear-gradient(180deg, var(--app-bg-grad, $uni-bg-color-grey), var(--app-subtle, $uni-bg-color-grey));
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 12rpx;
  padding: 16rpx;
}

.preview-bar {
  height: 8rpx;
  border-radius: 4rpx;
  background: var(--app-primary, $app-primary);
  opacity: 0.5;
}

/* 配色网格 */
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

.scheme-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 16rpx;
}

.scheme-item {
  width: calc(33.33% - 12rpx);
  background: var(--app-card-bg, #fff);
  border: 2rpx solid var(--app-card-border, $uni-border-color);
  border-radius: 24rpx;
  padding: 20rpx 16rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10rpx;
  position: relative;
  transition: all 0.2s;

  &.active {
    border-color: var(--app-primary, $app-primary);
    background: var(--app-primary-soft, rgba($app-primary, 0.06));
  }
}

.scheme-swatch {
  display: flex;
  height: 40rpx;
}

.swatch-dot {
  width: 36rpx;
  height: 36rpx;
  border-radius: 50%;
  border: 2rpx solid var(--app-card-bg, #fff);
  margin-left: -10rpx;

  &:first-child {
    margin-left: 0;
  }
}

.scheme-name {
  font-size: 27rpx;
  color: var(--app-text, $uni-text-color);
  font-weight: 600;
}

.scheme-desc {
  font-size: 20rpx;
  color: var(--app-text-2, $uni-text-color-grey);
  text-align: center;
}

.scheme-check {
  position: absolute;
  top: 14rpx;
  right: 14rpx;
  width: 30rpx;
  height: 30rpx;
  border-radius: 50%;
  background: var(--app-primary, $app-primary);
  display: flex;
  align-items: center;
  justify-content: center;
}

/* UI 风格列表 */
.mode-list {
  overflow: hidden;
}

.mode-item {
  display: flex;
  align-items: center;
  gap: 20rpx;
  padding: 24rpx;
  transition: background 0.2s;

  &:active {
    background: var(--app-press, $uni-bg-color-hover);
  }
}

.mode-demo {
  width: 110rpx;
  height: 78rpx;
  border-radius: 16rpx;
  padding: 14rpx;
  display: flex;
  flex-direction: column;
  gap: 8rpx;
  flex-shrink: 0;

  &.flat {
    background: linear-gradient(135deg, var(--app-primary, $app-primary), var(--app-accent, $app-primary-light));
  }

  &.glass {
    background: linear-gradient(135deg, var(--app-accent, $app-primary-light), var(--app-primary-soft, rgba($app-primary, 0.3)));
    backdrop-filter: blur(4rpx);
  }

  &.neu {
    background: var(--app-bg, $app-bg);
    box-shadow: inset 2rpx 2rpx 6rpx rgba(0,0,0,.06);
  }
}

.demo-card {
  height: 24rpx;
  width: 78rpx;
  border-radius: 4rpx;
  background: var(--app-on-primary, #fff);
  opacity: 0.9;
}

.demo-bar {
  height: 10rpx;
  width: 60rpx;
  border-radius: 6rpx;
  background: var(--app-on-primary, #fff);
  opacity: 0.6;
}

.demo-btn {
  height: 16rpx;
  width: 46rpx;
  border-radius: 8rpx;
  background: var(--app-on-primary, #fff);
  opacity: 0.8;
}

.mode-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4rpx;
}

.mode-name {
  font-size: 29rpx;
  color: var(--app-text, $uni-text-color);
  font-weight: 600;
}

.mode-desc {
  font-size: 22rpx;
  color: var(--app-text-2, $uni-text-color-grey);
}

.mode-radio {
  width: 40rpx;
  height: 40rpx;
  border-radius: 50%;
  border: 3rpx solid var(--app-card-border, $uni-border-color);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.mode-item.active .mode-radio {
  border-color: var(--app-primary, $app-primary);
}

.radio-dot {
  width: 22rpx;
  height: 22rpx;
  border-radius: 50%;
  background: var(--app-primary, $app-primary);
}

.tip {
  margin-top: 32rpx;
  padding: 24rpx;
  display: flex;
  align-items: flex-start;
  gap: 16rpx;
}

.tip-text {
  flex: 1;
  font-size: 24rpx;
  color: var(--app-text-2, $uni-text-color-grey);
  line-height: 1.6;
}
</style>