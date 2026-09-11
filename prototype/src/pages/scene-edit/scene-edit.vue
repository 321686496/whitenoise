<template>
  <view class="page-container">
    <view class="page-bg"></view>

    <!-- 场景名称 -->
    <view class="section">
      <text class="section-title">场景名称</text>
      <view class="name-card app-card">
        <Icon name="edit" :size="20" color="var(--app-primary)" />
        <input
          class="name-input"
          v-model="name"
          placeholder="给场景取个名字，如「雨天阅读」"
          maxlength="20"
        />
      </view>
    </view>

    <!-- 当前配方概览 -->
    <view class="section">
      <view class="section-header">
        <text class="section-title">当前配方</text>
        <text class="section-count" v-if="tracks.length">{{ tracks.length }} 路 / {{ maxTracks }} 路</text>
      </view>
      <view class="recipe-chip-row" v-if="tracks.length">
        <view class="chip" v-for="t in tracks" :key="t.id" :style="{ background: t.color }">
          <Icon :name="t.iconName" :size="18" color="#fff" />
          <text class="chip-name">{{ t.name }}</text>
          <text class="chip-vol">{{ t.volume }}%</text>
        </view>
      </view>
      <view class="recipe-total app-card" v-if="tracks.length">
        <text class="total-label">总占比</text>
        <text class="total-value">{{ totalPercent }}%</text>
        <text class="total-hint">下方滑动可调整各路音量</text>
      </view>
      <view class="empty-recipe app-card" v-else>
        <Icon name="wave" :size="40" color="var(--app-primary-soft)" />
        <text class="empty-recipe-text">还没有添加声音，去下方挑选吧</text>
      </view>
    </view>

    <!-- 声音库选择 -->
    <view class="section">
      <text class="section-title">声音库</text>
      <view class="cat-tabs">
        <view
          v-for="cat in cats"
          :key="cat.key"
          class="cat-tab app-card"
          :class="{ active: activeCat === cat.key }"
          @click="activeCat = cat.key"
        >{{ cat.label }}</view>
      </view>
      <scroll-view scroll-x class="sound-scroll" :show-scrollbar="false">
        <view class="sound-grid">
          <SoundCard
            v-for="s in filteredSounds"
            :key="s.id"
            :name="s.name"
            :type="s.type"
            :icon-name="s.iconName"
            :color="s.color"
            :is-active="tracks.some(t => t.id === s.id)"
            @tap="toggleSound(s)"
          />
        </view>
      </scroll-view>
    </view>

    <!-- 调节音量比例 -->
    <view class="section">
      <text class="section-title">调节音量比例</text>
      <view v-if="tracks.length">
        <view class="mix-track-item" v-for="t in tracks" :key="t.id">
          <MixTrack
            :name="t.name"
            :icon-name="t.iconName"
            :color="t.color"
            :volume="t.volume"
            :is-muted="t.muted"
            @mute="toggleMute(t.id)"
            @remove="removeTrack(t.id)"
          />
        </view>
        <text class="adjust-hint">* 原型演示：滑块仅做视觉示意，拖动不改变真实比例</text>
      </view>
      <view class="empty-mix app-card" v-else>
        <text class="empty-mix-text">暂无音量轨道</text>
      </view>
    </view>

    <!-- 底部操作 -->
    <view class="footer-bar">
      <view class="btn-outline footer-btn" @click="cancel">取消</view>
      <view class="btn-primary footer-btn" @click="save">保存</view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import Icon from '@/components/Icon.vue'
import SoundCard from '@/components/SoundCard.vue'
import MixTrack from '@/components/MixTrack.vue'
import { sounds, soundCategories } from '@/data/sounds'

const name = ref('')
const isEdit = ref(false)
const maxTracks = 6

// 声音分类 tab（复用全局分类）
const cats = soundCategories
const activeCat = ref('all')

const filteredSounds = computed(() => {
  if (activeCat.value === 'all') return sounds
  return sounds.filter(s => s.category === activeCat.value)
})

// 配方轨（当前已选声音）
interface Track {
  id: string
  name: string
  iconName: string
  color: string
  volume: number
  muted: boolean
}

const tracks = ref<Track[]>([])

const totalPercent = computed(() => tracks.value.reduce((sum, t) => sum + t.volume, 0))

// 读取参数：new=新建，其他 id=编辑（原型仅演示标题/预填，不取真实数据）
onLoad((query) => {
  const id = query?.sceneId
  if (id && id !== 'new') {
    isEdit.value = true
    name.value = '雨天阅读'
    tracks.value = [
      { id: 'rain', name: '雨声', iconName: 'rain', color: '#7E93A8', volume: 60, muted: false },
      { id: 'campfire', name: '篝火', iconName: 'fire', color: '#B97A48', volume: 25, muted: false },
      { id: 'cafe', name: '咖啡厅', iconName: 'coffee', color: '#A89068', volume: 15, muted: false },
    ]
  } else {
    isEdit.value = false
    name.value = ''
  }
  uni.setNavigationBarTitle({ title: isEdit.value ? '编辑场景' : '新建场景' })
})

const toggleSound = (s: any) => {
  const idx = tracks.value.findIndex(t => t.id === s.id)
  if (idx >= 0) {
    tracks.value.splice(idx, 1)
    return
  }
  if (tracks.value.length >= maxTracks) {
    uni.showToast({ title: `已达混音上限(${maxTracks}路)`, icon: 'none' })
    return
  }
  tracks.value.push({ id: s.id, name: s.name, iconName: s.iconName, color: s.color, volume: 50, muted: false })
}

const toggleMute = (id: string) => {
  const t = tracks.value.find(x => x.id === id)
  if (t) t.muted = !t.muted
}

const removeTrack = (id: string) => {
  tracks.value = tracks.value.filter(x => x.id !== id)
}

const cancel = () => uni.navigateBack()

const save = () => {
  if (!name.value.trim()) {
    uni.showToast({ title: '请输入场景名称', icon: 'none' })
    return
  }
  uni.showToast({ title: isEdit.value ? '场景已更新' : '场景已创建', icon: 'success' })
  setTimeout(() => uni.navigateBack(), 800)
}
</script>

<style lang="scss" scoped>
.page-container {
  padding-bottom: calc(160rpx + env(safe-area-inset-bottom));
}

.section {
  margin-top: 30rpx;
}

.section-header {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  margin-bottom: 18rpx;
  padding-left: 4rpx;
}

.section-title {
  font-size: 24rpx;
  font-weight: 600;
  letter-spacing: 0.3rpx;
  color: var(--app-text-2, $uni-text-color-grey);
  display: block;
  margin-bottom: 18rpx;
  padding-left: 4rpx;
}

.section-count {
  font-size: 21rpx;
  color: var(--app-primary, $app-primary);
  font-weight: 600;
}

/* 名称输入 */
.name-card {
  padding: 0 26rpx;
  height: 96rpx;
  display: flex;
  align-items: center;
  gap: 18rpx;
}

.name-input {
  flex: 1;
  font-size: 28rpx;
  color: var(--app-text, $uni-text-color);
}

/* 配方概览 */
.recipe-chip-row {
  display: flex;
  flex-wrap: wrap;
  gap: 14rpx;
  margin-bottom: 18rpx;
}

.chip {
  display: flex;
  align-items: center;
  gap: 8rpx;
  padding: 10rpx 20rpx;
  border-radius: 26rpx;
}

.chip-name {
  font-size: 23rpx;
  color: #fff;
  font-weight: 600;
}

.chip-vol {
  font-size: 20rpx;
  color: rgba(255, 255, 255, 0.82);
}

.recipe-total {
  padding: 22rpx 26rpx;
  display: flex;
  align-items: baseline;
  gap: 14rpx;
}

.total-label {
  font-size: 23rpx;
  color: var(--app-text-2, $uni-text-color-grey);
}

.total-value {
  font-size: 32rpx;
  font-weight: 800;
  color: var(--app-primary, $app-primary);
}

.total-hint {
  margin-left: auto;
  font-size: 21rpx;
  color: var(--app-text-3, $uni-text-color-grey);
}

.empty-recipe {
  padding: 44rpx 32rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 14rpx;
}

.empty-recipe-text {
  font-size: 25rpx;
  color: var(--app-text-2, $uni-text-color-grey);
}

/* 分类 tab */
.cat-tabs {
  display: flex;
  gap: 8rpx;
  margin-bottom: 26rpx;
  padding: 8rpx;
  background: var(--app-subtle, $uni-bg-color-grey);
  border-radius: 30rpx;
  overflow-x: auto;
}

.cat-tab {
  flex-shrink: 0;
  min-width: 96rpx;
  height: 60rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 22rpx;
  font-size: 24rpx;
  color: var(--app-text-2, $uni-text-color-grey);
  font-weight: 500;
  background: transparent;

  &.active {
    background: var(--app-card-bg, #fff);
    color: var(--app-primary, $app-primary);
    font-weight: 600;
    box-shadow: 0 4rpx 12rpx color-mix(in srgb, var(--app-primary, $app-primary) 14%, transparent);
  }
}

/* 声音选择网格 */
.sound-scroll {
  white-space: nowrap;
  width: 100%;
}

.sound-grid {
  display: inline-flex;
  gap: 16rpx;
  padding-bottom: 8rpx;
}

/* 音量轨道 */
.mix-track-item {
  margin-bottom: 14rpx;
}

.adjust-hint {
  display: block;
  margin: 16rpx 4rpx 0;
  font-size: 20rpx;
  color: var(--app-text-3, $uni-text-color-grey);
}

.empty-mix {
  padding: 40rpx 32rpx;
  display: flex;
  justify-content: center;
}

.empty-mix-text {
  font-size: 24rpx;
  color: var(--app-text-3, $uni-text-color-grey);
}

/* 底部固定操作 */
.footer-bar {
  position: fixed;
  left: 0;
  right: 0;
  bottom: 0;
  padding: 20rpx 26rpx calc(20rpx + env(safe-area-inset-bottom));
  background: var(--app-bg);
  display: flex;
  gap: 20rpx;
  z-index: 50;
  box-shadow: 0 -6rpx 24rpx color-mix(in srgb, var(--app-text) 6%, transparent);
}

.footer-btn {
  flex: 1;
}
</style>