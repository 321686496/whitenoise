<template>
  <!-- v2：NavBar + 配色×风格×明暗 三维（外观分段新增，色点全部来自 schemeMeta，MASTER §10.3） -->
  <view class="page-container theme-page">
    <view class="page-bg"></view>

    <NavBar title="主题与风格" />

    <!-- 主预览卡片（实时呈现当前主题） -->
    <view class="preview-hero app-card">
      <view class="preview-brand">
        <view class="preview-logo">
          <image src="/static/logo-v13.svg" mode="aspectFit" />
        </view>
        <view class="preview-info">
          <text class="preview-name">{{ currentSchemeLabel }}</text>
          <text class="preview-mode">{{ currentUiLabel }} · {{ currentModeLabel }} · 实时预览</text>
        </view>
      </view>
      <view class="preview-wall">
        <view class="preview-card" v-for="p in previewItems" :key="p.icon">
          <Icon :name="p.icon" :size="26" color="var(--app-primary)" />
          <view class="preview-bar" :style="{ width: p.width + '%' }"></view>
        </view>
      </view>
    </view>

    <!-- 外观（明暗） -->
    <view class="section">
      <text class="section-title">外观</text>
      <view class="appearance-card app-card">
        <Segmented :options="modeOptions" :model-value="appearance" @update:model-value="selectAppearance" />
      </view>
    </view>

    <!-- 配色方案 -->
    <view class="section">
      <text class="section-title">配色方案</text>
      <view class="scheme-grid">
        <view
          v-for="s in schemes"
          :key="s.key"
          class="scheme-item app-card"
          :class="{ active: activeScheme === s.key }"
          @click="selectScheme(s.key)"
        >
          <view class="scheme-swatches">
            <view class="swatch-row">
              <view
                class="swatch-dot"
                v-for="(c, i) in s.swatchLight"
                :key="'l' + i"
                :style="{ background: c, zIndex: 4 - i }"
              ></view>
            </view>
            <view class="swatch-row">
              <view
                class="swatch-dot"
                v-for="(c, i) in s.swatchDark"
                :key="'d' + i"
                :style="{ background: c, zIndex: 4 - i }"
              ></view>
            </view>
          </view>
          <text class="scheme-name">{{ s.label }}</text>
          <text class="scheme-desc">{{ s.desc }}</text>
          <view class="scheme-check" v-if="activeScheme === s.key">
            <Icon name="check" :size="14" color="var(--app-on-primary)" />
          </view>
        </view>
      </view>
    </view>

    <!-- UI 风格 -->
    <view class="section">
      <text class="section-title">UI 风格</text>
      <view class="mode-list app-card">
        <view
          v-for="m in uiModes"
          :key="m.key"
          class="mode-item"
          :class="{ active: activeUi === m.key }"
          @click="selectUiMode(m.key)"
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
            <view class="radio-dot" v-if="activeUi === m.key"></view>
          </view>
        </view>
      </view>
    </view>

    <!-- 说明 -->
    <view class="tip app-card">
      <Icon name="check" :size="22" color="var(--app-primary)" />
      <text class="tip-text">配色 × UI 风格 × 外观自由组合，切换即时生效并全局记忆；「跟随系统」随系统明暗自动变化。</text>
    </view>
  </view>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import Icon from '@/components/Icon.vue'
import NavBar from '@/components/NavBar.vue'
import Segmented from '@/components/Segmented.vue'
import {
  setTheme, themeState,
  SCHEME_KEYS, schemeMeta,
  UI_MODES, UIMODE_META,
  THEME_MODES, THEMEMODE_META,
} from '@/theme/index'
import type { SchemeKey, UiMode, ThemeMode } from '@/theme/index'

const activeScheme = ref<SchemeKey>(themeState.scheme)
const activeUi = ref<UiMode>(themeState.ui)
const appearance = ref<string>(themeState.mode)

/* 配色数据来自主题引擎（明/暗两组色点），不再写死任何 hex */
const schemes = SCHEME_KEYS.map(k => ({ key: k, ...schemeMeta(k) }))
const uiModes = UI_MODES.map(key => ({ key, ...UIMODE_META[key] }))
const modeOptions = THEME_MODES.map(key => ({ key, label: THEMEMODE_META[key].label }))

const currentSchemeLabel = computed(() => schemeMeta(activeScheme.value).label)
const currentUiLabel = computed(() => UIMODE_META[activeUi.value].label)
const currentModeLabel = computed(() => THEMEMODE_META[appearance.value as ThemeMode].label)

const previewItems = [
  { icon: 'white-noise', width: 58 },
  { icon: 'rain', width: 76 },
  { icon: 'forest', width: 44 },
  { icon: 'coffee', width: 62 },
]

const selectScheme = (k: SchemeKey) => {
  activeScheme.value = k
  setTheme(k, activeUi.value, appearance.value as ThemeMode)
}

const selectUiMode = (k: UiMode) => {
  activeUi.value = k
  setTheme(activeScheme.value, k, appearance.value as ThemeMode)
}

const selectAppearance = (key: string) => {
  const mode = key as ThemeMode
  appearance.value = mode
  setTheme(activeScheme.value, activeUi.value, mode)
}
</script>

<style lang="scss" scoped>
/* NavBar 自带 env(safe-area-inset-top)，去掉容器重复的安全区顶距 */
.theme-page {
  padding-top: calc(env(safe-area-inset-top, 0rpx) + 12rpx);
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
  background: var(--app-surface-2);
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
  min-width: 0;
}

.preview-name {
  font-size: 32rpx;
  font-weight: 700;
  color: var(--app-text);
}

.preview-mode {
  font-size: 23rpx;
  color: var(--app-primary);
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
  background: linear-gradient(180deg, var(--app-bg-grad), var(--app-surface-2));
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
  background: var(--app-primary);
  opacity: 0.5;
}

/* 分组 */
.section {
  margin-top: 36rpx;
}

/* 外观分段 */
.appearance-card {
  padding: 8rpx;
  overflow: hidden;
}

/* 配色网格 */
.scheme-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 16rpx;
}

.scheme-item {
  width: calc(33.33% - 11rpx);
  box-sizing: border-box;
  min-height: 88rpx;
  border-radius: 28rpx;
  padding: 20rpx 16rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10rpx;
  position: relative;
  transition: transform var(--dur-fast) var(--ease-std), border-color var(--dur-fast) var(--ease-std), background var(--dur-fast) var(--ease-std);

  &:active {
    transform: scale(0.96);
  }

  &.active {
    border-color: var(--app-primary);
    background: var(--app-primary-soft);
  }
}

.scheme-swatches {
  display: flex;
  flex-direction: column;
  gap: 6rpx;
}

.swatch-row {
  display: flex;
  height: 28rpx;
}

.swatch-dot {
  width: 28rpx;
  height: 28rpx;
  border-radius: 50%;
  border: 2rpx solid var(--app-surface);
  margin-left: -8rpx;
  box-sizing: border-box;

  &:first-child {
    margin-left: 0;
  }
}

.scheme-name {
  font-size: 27rpx;
  color: var(--app-text);
  font-weight: 600;
}

.scheme-desc {
  font-size: 20rpx;
  color: var(--app-text-2);
  text-align: center;
}

.scheme-check {
  position: absolute;
  top: 14rpx;
  right: 14rpx;
  width: 30rpx;
  height: 30rpx;
  border-radius: 50%;
  background: var(--app-primary);
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
  min-height: 88rpx;
  padding: 24rpx;
  transition: background var(--dur-fast) var(--ease-std);

  &:active {
    background: var(--app-press);
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
    background: linear-gradient(135deg, var(--app-primary), var(--app-accent));
  }

  &.glass {
    background: linear-gradient(135deg, var(--app-accent), var(--app-primary-soft));
    backdrop-filter: blur(4rpx);
  }

  &.neu {
    background: var(--app-bg);
    box-shadow: inset 2rpx 2rpx 6rpx var(--p-neu-a);
  }
}

.demo-card {
  height: 24rpx;
  width: 78rpx;
  border-radius: 4rpx;
  background: var(--app-on-primary);
  opacity: 0.9;
}

.demo-bar {
  height: 10rpx;
  width: 60rpx;
  border-radius: 6rpx;
  background: var(--app-on-primary);
  opacity: 0.6;
}

.demo-btn {
  height: 16rpx;
  width: 46rpx;
  border-radius: 8rpx;
  background: var(--app-on-primary);
  opacity: 0.8;
}

.mode-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4rpx;
  min-width: 0;
}

.mode-name {
  font-size: 29rpx;
  color: var(--app-text);
  font-weight: 600;
}

.mode-desc {
  font-size: 22rpx;
  color: var(--app-text-2);
}

.mode-radio {
  width: 40rpx;
  height: 40rpx;
  border-radius: 50%;
  border: 3rpx solid var(--app-line-strong);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.mode-item.active .mode-radio {
  border-color: var(--app-primary);
}

.radio-dot {
  width: 22rpx;
  height: 22rpx;
  border-radius: 50%;
  background: var(--app-primary);
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
  color: var(--app-text-2);
  line-height: 1.6;
}
</style>
