<template>
  <!-- v2：自定义导航（pages.json 已改 custom）；NavBar back=true 补回「无返回入口」缺陷（MASTER §10.3-3） -->
  <view class="page-container library-page">
    <view class="page-bg"></view>

    <NavBar title="声音库" />

    <!-- 搜索栏（iOS 风格） -->
    <view class="search-bar">
      <view class="search-icon" aria-hidden="true">
        <view class="search-circle"></view>
        <view class="search-handle"></view>
      </view>
      <input
        class="search-input"
        v-model="keyword"
        placeholder="搜索声音或场景"
        :placeholder-style="'color: var(--app-text-3); font-size: 26rpx;'"
        confirm-type="search"
      />
      <view class="search-clear" v-if="keyword" aria-label="清空搜索" @click="keyword = ''">
        <Icon name="close" :size="20" color="var(--app-text-2)" />
      </view>
    </view>

    <!-- 分类分段控制器 -->
    <view class="category-row">
      <Segmented :options="catOptions" v-model="activeCat" />
    </view>

    <!-- 声音网格（v2：复用 SoundCard，色底经 --sound-color + color-mix 派生） -->
    <view class="sound-grid" v-if="filteredSounds.length > 0">
      <SoundCard
        v-for="sound in filteredSounds"
        :key="sound.id"
        :name="sound.name"
        :type="sound.type"
        :icon-name="sound.iconName"
        :color="sound.color"
        :is-active="selected?.id === sound.id"
        @tap="openDetail(sound)"
      />
      <view class="sound-count">
        <text>共 {{ filteredSounds.length }} 个声音 · 点按查看详情</text>
      </view>
    </view>

    <!-- 空状态 -->
    <EmptyState
      v-else
      icon="wave"
      title="未找到相关声音"
      desc="换个关键词试试吧"
    />

    <!-- 声音详情弹窗（底部滑入，根级兄弟节点：不嵌于 backdrop-filter / overflow 祖先） -->
    <view class="sheet-overlay" v-if="selected" @click="closeDetail">
      <view class="sheet" @click.stop>
        <view class="sheet-handle" aria-hidden="true" />
        <view class="sheet-head">
          <text class="sheet-title">声音详情</text>
          <view class="sheet-close" aria-label="关闭" @click="closeDetail">
            <Icon name="close" :size="18" color="var(--app-text-3)" />
          </view>
        </view>

        <!-- Hero：声音渐变数据资产作底，浮层文字走 on-cover token -->
        <view class="sheet-hero" :style="{ background: selected.gradient }">
          <view class="sheet-icon">
            <Icon :name="selected.iconName" :size="64" color="var(--app-on-cover)" />
          </view>
          <text class="sheet-name">{{ selected.name }}</text>
          <text class="sheet-type">{{ selected.type }}</text>
          <text class="sheet-desc">{{ selected.desc }}</text>
        </view>

        <view class="meta-table">
          <view class="meta-row" v-for="row in metaRows" :key="row.label">
            <text class="meta-label">{{ row.label }}</text>
            <text class="meta-value">{{ row.value }}</text>
          </view>
        </view>

        <view class="tags-section">
          <text class="tags-title">适用场景</text>
          <view class="tag-list">
            <view class="tag-chip" v-for="tag in selected.scenes" :key="tag">
              <text>{{ tag }}</text>
            </view>
          </view>
        </view>

        <view class="sheet-actions">
          <view class="btn-primary sheet-play" @click="playSound(selected)">
            <Icon name="play" :size="20" color="var(--app-on-primary)" />
            <text>播放</text>
          </view>
          <view class="btn-outline sheet-mix" @click="mixSound(selected)">
            <Icon name="mixer" :size="20" color="var(--app-primary)" />
            <text>加入混音</text>
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import NavBar from '@/components/NavBar.vue'
import Icon from '@/components/Icon.vue'
import Segmented from '@/components/Segmented.vue'
import SoundCard from '@/components/SoundCard.vue'
import EmptyState from '@/components/EmptyState.vue'
import { sounds as soundListData, soundCategories } from '@/data/sounds'
import type { Sound } from '@/data/sounds'

const keyword = ref('')
const activeCat = ref('all')

// 分类单一来源：data/sounds.ts 的 soundCategories，经 Segmented 统一渲染
const catOptions = soundCategories.map((c) => ({ key: c.key, label: c.label }))

// 数据源为普通数组，包一层 ref 以支持响应式过滤（sounds.value）
const sounds = ref(soundListData)

const filteredSounds = computed(() => {
  return sounds.value.filter(s => {
    const matchCat = activeCat.value === 'all' || s.category === activeCat.value
    const kw = keyword.value.trim().toLowerCase()
    const matchKw = !kw || s.name.toLowerCase().includes(kw) || s.desc.toLowerCase().includes(kw) || s.type.toLowerCase().includes(kw)
    return matchCat && matchKw
  })
})

// 声音详情弹窗
const selected = ref<Sound | null>(null)

const metaRows = computed(() => {
  if (!selected.value) return []
  const s = selected.value
  return [
    { label: '时长', value: s.duration },
    { label: '采样率', value: s.sampleRate },
    { label: '音质', value: s.quality },
    { label: '循环片段', value: s.loopLength },
    { label: '来源', value: s.source },
  ]
})

const openDetail = (sound: Sound) => {
  selected.value = sound
}

const closeDetail = () => {
  selected.value = null
}

const playSound = (sound: Sound | null) => {
  if (!sound) return
  uni.showToast({ title: `正在播放 ${sound.name}`, icon: 'none' })
}

const mixSound = (sound: Sound | null) => {
  if (!sound) return
  closeDetail()
  uni.showToast({ title: `${sound.name} 已加入混音`, icon: 'success' })
}
</script>

<style lang="scss" scoped>
/* NavBar 自带 env(safe-area-inset-top)，去掉容器重复的安全区顶距 */
.library-page {
  padding-top: calc(env(safe-area-inset-top, 0rpx) + 12rpx);
  padding-bottom: calc(80rpx + env(safe-area-inset-bottom));
}

/* ---------- 搜索栏（v2：sunken 底 + 发丝描边，触控 ≥88rpx） ---------- */
.search-bar {
  display: flex;
  align-items: center;
  gap: 16rpx;
  min-height: 88rpx;
  padding: 0 24rpx;
  margin-top: 12rpx;
  border-radius: 24rpx;
  background: var(--app-sunken);
  border: 1rpx solid var(--app-line);
  box-sizing: border-box;
  transition: border-color var(--dur-fast) var(--ease-std);

  &:focus-within {
    border-color: var(--app-line-strong);
  }
}

.search-icon {
  position: relative;
  width: 30rpx;
  height: 30rpx;
  flex-shrink: 0;
}

.search-circle {
  position: absolute;
  left: 0;
  top: 0;
  width: 20rpx;
  height: 20rpx;
  border: 3rpx solid var(--app-text-3);
  border-radius: 50%;
  box-sizing: border-box;
}

.search-handle {
  position: absolute;
  right: 1rpx;
  bottom: 3rpx;
  width: 3rpx;
  height: 12rpx;
  border-radius: 2rpx;
  background: var(--app-text-3);
  transform: rotate(-45deg);
}

.search-input {
  flex: 1;
  height: 100%;
  font-size: 26rpx;
  color: var(--app-text);
  background: transparent;
}

/* 视觉 56rpx，::after 外扩热区至 ≥88rpx 触控达标（同 SceneCard 模式） */
.search-clear {
  position: relative;
  width: 56rpx;
  height: 56rpx;
  border-radius: 999rpx;
  background: var(--app-surface-2);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  transition: transform var(--dur-fast) var(--ease-std);

  &::after {
    content: '';
    position: absolute;
    inset: -16rpx;
  }

  &:active {
    transform: scale(0.96);
  }
}

/* ---------- 分类分段控制器 ---------- */
.category-row {
  margin: 24rpx 0 26rpx;
}

/* ---------- 声音网格（SoundCard 自适应多列，box-sizing 兜底） ---------- */
.sound-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, 164rpx);
  justify-content: space-between;
  gap: 20rpx 16rpx;
  box-sizing: border-box;

  :deep(.sound-card) {
    box-sizing: border-box;
  }
}

.sound-count {
  grid-column: 1 / -1;
  text-align: center;
  font-size: 22rpx;
  color: var(--app-text-3);
  padding: 28rpx 0 8rpx;
}

/* ---------- 声音详情弹窗（底部滑入，v2 §8/§9：顶角 xl=56rpx / shadow-4 / dur-slow） ---------- */
.sheet-overlay {
  position: fixed;
  left: 0;
  top: 0;
  right: 0;
  bottom: 0;
  background: var(--app-overlay);
  z-index: 300;
  display: flex;
  align-items: flex-end;
  animation: maskIn var(--dur-slow) var(--ease-std) both;
}

.sheet {
  width: 100%;
  box-sizing: border-box;
  max-height: 88vh;
  overflow-y: auto;
  padding: 16rpx 32rpx calc(36rpx + env(safe-area-inset-bottom));
  background: var(--app-surface);
  border-top: 1rpx solid var(--app-line);
  border-radius: 56rpx 56rpx 0 0;
  box-shadow: var(--app-shadow-4), var(--app-inset);
  backdrop-filter: blur(var(--app-blur));
  -webkit-backdrop-filter: blur(var(--app-blur));
  animation: sheetUp var(--dur-slow) var(--ease-std) both;
}

.sheet-handle {
  width: 72rpx;
  height: 8rpx;
  border-radius: 999rpx;
  background: var(--app-sunken);
  margin: 0 auto 20rpx;
}

.sheet-head {
  display: flex;
  align-items: center;
}

.sheet-title {
  flex: 1;
  font-size: 30rpx;
  font-weight: 700;
  color: var(--app-text);
  letter-spacing: -0.3rpx;
}

.sheet-close {
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

/* 图上浮层取向：on-cover 白经 color-mix 半透明 + 毛玻璃 */
.sheet-hero {
  margin-top: 8rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10rpx;
  padding: 40rpx 24rpx;
  border-radius: 32rpx;
}

.sheet-icon {
  width: 120rpx;
  height: 120rpx;
  border-radius: 32rpx;
  background: color-mix(in srgb, var(--app-on-cover) 18%, transparent);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 6rpx;
  backdrop-filter: blur(8rpx);
  -webkit-backdrop-filter: blur(8rpx);
  box-shadow: inset 0 1rpx 0 color-mix(in srgb, var(--app-on-cover) 35%, transparent);
}

.sheet-name {
  font-size: 36rpx;
  font-weight: 700;
  color: var(--app-on-cover);
  letter-spacing: 1rpx;
}

.sheet-type {
  font-size: 22rpx;
  color: var(--app-on-cover-soft);
}

.sheet-desc {
  font-size: 24rpx;
  color: var(--app-on-cover-soft);
  line-height: 1.6;
  text-align: center;
}

/* 元数据表格 */
.meta-table {
  margin-top: 24rpx;
}

.meta-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  min-height: 72rpx;
  padding: 8rpx;
  border-bottom: 1rpx solid var(--app-line);
}

.meta-row:last-child {
  border-bottom: none;
}

.meta-label {
  font-size: 24rpx;
  color: var(--app-text-2);
}

.meta-value {
  font-size: 24rpx;
  color: var(--app-text);
  font-weight: 500;
  text-align: right;
  margin-left: 24rpx;
}

/* 适用场景 */
.tags-section {
  margin-top: 24rpx;
}

.tags-title {
  font-size: 24rpx;
  font-weight: 600;
  color: var(--app-text-2);
  display: block;
}

.tag-list {
  display: flex;
  flex-wrap: wrap;
  gap: 12rpx;
  margin-top: 14rpx;
}

.tag-chip {
  padding: 8rpx 22rpx;
  border-radius: 999rpx;
  background: var(--app-primary-soft);
  color: var(--app-primary);
  font-size: 23rpx;
  font-weight: 500;
}

/* 操作按钮 */
.sheet-actions {
  display: flex;
  gap: 20rpx;
  margin-top: 32rpx;
}

.sheet-play,
.sheet-mix {
  flex: 1;
  gap: 10rpx;
}

@keyframes maskIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes sheetUp {
  from { transform: translateY(100%); }
  to { transform: translateY(0); }
}

@media (prefers-reduced-motion: reduce) {
  .sheet-overlay,
  .sheet {
    animation: none;
  }
}
</style>
