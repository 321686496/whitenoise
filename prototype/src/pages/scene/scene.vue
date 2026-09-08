<template>
  <view class="page-container">
    <view class="page-bg"></view>

    <!-- 自定义悬浮 TabBar -->
    <TabBar current="scene" />

    <view class="header">
      <text class="page-title">场景</text>
      <text class="page-subtitle">管理你的专属声音场景</text>
    </view>

    <!-- ① 偏好胶囊 -->
    <view class="pref-bar">
      <Icon name="flame" :size="16" color="var(--app-primary)" />
      <text class="pref-label">你的偏好：</text>
      <text class="pref-tag" v-for="p in prefLabels" :key="p">{{ p }}</text>
    </view>

    <!-- ② 为你推荐 -->
    <view class="section" v-if="recommended.length > 0">
      <text class="section-title">为你推荐</text>
      <scroll-view scroll-x class="rec-scroll" :show-scrollbar="false">
        <view class="rec-row">
          <view
            class="rec-card app-card"
            v-for="s in recommended"
            :key="s.id"
            @click="openDetail(s)"
          >
            <view class="rec-cover" :style="{ background: s.gradient }">
              <Icon :name="s.iconName" :size="40" color="rgba(255,255,255,.95)" />
              <view class="rec-reason">
                <Icon name="flame" :size="12" color="var(--app-primary)" />
                <text class="rec-reason-text">常听偏好</text>
              </view>
            </view>
            <text class="rec-name">{{ s.name }}</text>
            <text class="rec-desc">{{ s.desc }}</text>
          </view>
        </view>
      </scroll-view>
    </view>

    <!-- ③ 最近播放 -->
    <view class="section" v-if="recentItems.length > 0">
      <text class="section-title">最近播放</text>
      <scroll-view scroll-x class="recent-scroll" :show-scrollbar="false">
        <view class="recent-row">
          <view
            class="recent-card app-card"
            v-for="r in recentItems"
            :key="r.sceneId"
            @click="openDetail(r)"
          >
            <view class="recent-cover" :style="{ background: r.gradient }">
              <Icon :name="r.iconName" :size="34" color="rgba(255,255,255,.95)" />
            </view>
            <text class="recent-name">{{ r.name }}</text>
            <text class="recent-time">{{ recentTimeLabel(r.ts) }}</text>
          </view>
        </view>
      </scroll-view>
    </view>

    <!-- ④ 分类 Tab -->
    <view class="tag-filter">
      <view
        class="tag-item"
        :class="{ active: activeTag === tag.id }"
        v-for="tag in tags"
        :key="tag.id"
        @click="activeTag = tag.id"
      >
        <Icon :name="tag.icon" :size="14" :color="activeTag === tag.id ? 'var(--app-primary)' : 'var(--app-text-2)'" />
        <text>{{ tag.label }}</text>
      </view>
    </view>

    <!-- ⑤ 精选场景 -->
    <view class="section">
      <view class="section-head">
        <text class="section-title">精选场景</text>
        <view class="more-btn" @click="goAllScenes">
          <text class="more-text">查看全部</text>
          <Icon name="chevron-right" :size="14" color="var(--app-text-2)" />
        </view>
      </view>
      <view class="featured-grid">
        <SceneCard
          v-for="scene in featuredScenes"
          :key="scene.id"
          :name="scene.name"
          :sound-count="scene.soundIds.length"
          :sound-icons="presetSoundIcons(scene)"
          :bg-color="scene.gradient"
          :is-preset="scene.isPreset"
          layout="grid"
          :active="player.currentScene?.id === scene.id"
          @tap="openDetail(scene)"
          @play="playScene(scene)"
        />
      </view>
    </view>

    <!-- ⑥ 我的场景 -->
    <view class="section">
      <view class="section-head">
        <text class="section-title">我的场景</text>
        <view class="new-btn app-card" @click="createScene">
          <Icon name="mixer" :size="16" color="var(--app-primary)" />
          <text class="new-btn-text">新建</text>
        </view>
      </view>
      <SceneCard
        v-for="scene in myScenes"
        :key="scene.id"
        :name="scene.name"
        :sound-count="scene.soundCount"
        :sound-icons="scene.soundIcons"
        :bg-color="scene.bgColor"
        :is-preset="false"
        @tap="editScene(scene)"
        @share="shareScene(scene)"
        @play="playMyScene(scene)"
      />

      <view class="empty-scene app-card" v-if="myScenes.length === 0">
        <view class="empty-icon">
          <Icon name="mountain" :size="52" color="var(--app-primary)" />
        </view>
        <text class="empty-text">还没有自定义场景</text>
        <text class="empty-hint">点击右上角「新建」即可创建，或在首页混音后保存</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import SceneCard from '@/components/SceneCard.vue'
import Icon from '@/components/Icon.vue'
import TabBar from '@/components/TabBar.vue'
import { player, applyScene, getRecent, recentTimeLabel } from '@/composables/usePlayer'
import { SIMULATED_PREFS, getRecommended, getCategoryScenes } from '@/data/scenes'
import type { Scene } from '@/data/scenes'
import { sounds } from '@/data/sounds'

interface MyScene {
  id: string
  name: string
  soundCount: number
  soundIcons: string[]
  bgColor: string
}

const activeTag = ref('all')
const tags = [
  { id: 'all', label: '全部', icon: 'wave' },
  { id: 'sleep', label: '助眠', icon: 'moon' },
  { id: 'focus', label: '专注', icon: 'flame' },
  { id: 'relax', label: '放松', icon: 'forest' },
  { id: 'nature', label: '自然', icon: 'mountain' },
]

const prefLabels = computed(() => {
  const map: Record<string, string> = { sleep: '助眠', focus: '专注', relax: '放松', nature: '自然' }
  return SIMULATED_PREFS.map((c) => map[c] ?? c)
})

const recommended = computed(() => getRecommended(SIMULATED_PREFS, getRecent()))
const recentItems = ref(getRecent())

const featuredScenes = computed(() =>
  getCategoryScenes(activeTag.value as Scene['category'] | 'all', 3),
)

// 首页金刚区快捷入口直达分类 + 重读最近播放
onShow(() => {
  recentItems.value = getRecent()
  if (player.pendingSceneCategory && player.pendingSceneCategory !== 'all') {
    activeTag.value = player.pendingSceneCategory
    player.pendingSceneCategory = 'all'
  }
})

const presetSoundIcons = (scene: Scene) =>
  scene.soundIds.map((id) => sounds.find((s) => s.id === id)?.iconName ?? 'wave')

// 支持 Scene（id）与 RecentItem（sceneId）两种来源
const openDetail = (scene: { id?: string; sceneId?: string }) => {
  uni.navigateTo({ url: `/pages/scene-detail/scene-detail?sceneId=${scene.id ?? scene.sceneId}` })
}

const playScene = (scene: Scene) => {
  applyScene(scene)
  uni.showToast({ title: '已开始播放', icon: 'success' })
  setTimeout(() => uni.switchTab({ url: '/pages/index/index' }), 800)
}

const goAllScenes = () => uni.navigateTo({ url: '/pages/scene-all/scene-all' })

const myScenes = ref<MyScene[]>([
  { id: 'm1', name: '雨天阅读', soundCount: 3, soundIcons: ['rain', 'fire', 'coffee'], bgColor: 'linear-gradient(135deg,#8E82A6,#6E6290)' },
  { id: 'm2', name: '冥想时刻', soundCount: 2, soundIcons: ['stream', 'forest'], bgColor: 'linear-gradient(135deg,#7F9AA6,#5F7A86)' },
])

const createScene = () => {
  uni.navigateTo({ url: '/pages/scene-edit/scene-edit?sceneId=new' })
}

const editScene = (scene: { id: string; name: string }) => {
  uni.navigateTo({ url: `/pages/scene-edit/scene-edit?sceneId=${scene.id}` })
}

const shareScene = (scene: { name: string }) => {
  uni.showToast({ title: '已生成分享卡片', icon: 'success' })
}

// 我的场景播放：仅演示提示，不写共享播放状态
const playMyScene = (scene: { name: string }) => {
  uni.showToast({ title: `已应用「${scene.name}」`, icon: 'success' })
  setTimeout(() => uni.switchTab({ url: '/pages/index/index' }), 800)
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

/* ① 偏好胶囊 */
.pref-bar {
  display: flex;
  align-items: center;
  gap: 8rpx;
  padding: 14rpx 24rpx;
  border-radius: 30rpx;
  background: var(--app-primary-soft, rgba($app-primary, 0.1));
  margin-bottom: 8rpx;
}
.pref-label { font-size: 24rpx; color: var(--app-text-2, $uni-text-color-grey); }
.pref-tag { font-size: 24rpx; color: var(--app-primary, $app-primary); font-weight: 600; }

/* ② 为你推荐 */
.rec-scroll, .recent-scroll { white-space: nowrap; }
.rec-row, .recent-row { display: inline-flex; gap: 20rpx; padding: 4rpx 4rpx 8rpx; }
.rec-card { width: 260rpx; padding: 16rpx; flex-shrink: 0; transition: transform .16s; &:active { transform: scale(.96); } }
.rec-cover { height: 150rpx; border-radius: 18rpx; display: flex; align-items: center; justify-content: center; position: relative; margin-bottom: 12rpx; }
.rec-reason { position: absolute; left: 10rpx; bottom: 10rpx; display: flex; align-items: center; gap: 4rpx; padding: 4rpx 12rpx; border-radius: 18rpx; background: rgba(255,255,255,.9); }
.rec-reason-text { font-size: 20rpx; color: var(--app-primary, $app-primary); font-weight: 600; }
.rec-name { font-size: 27rpx; font-weight: 600; color: var(--app-text, $uni-text-color); display: block; }
.rec-desc { font-size: 22rpx; color: var(--app-text-2, $uni-text-color-grey); display: block; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }

/* ③ 最近播放 */
.recent-card { width: 190rpx; flex-shrink: 0; padding: 16rpx; transition: transform .16s; &:active { transform: scale(.96); } }
.recent-cover { height: 120rpx; border-radius: 18rpx; display: flex; align-items: center; justify-content: center; margin-bottom: 10rpx; }
.recent-name { font-size: 25rpx; font-weight: 600; color: var(--app-text, $uni-text-color); display: block; }
.recent-time { font-size: 21rpx; color: var(--app-text-2, $uni-text-color-grey); }

/* ④ 分类 Tab */
.tag-filter {
  display: flex;
  gap: 12rpx;
  padding: 8rpx 0;
  margin-bottom: 8rpx;
  overflow-x: auto;
}

.tag-item {
  display: flex;
  align-items: center;
  gap: 8rpx;
  padding: 12rpx 24rpx;
  border-radius: 28rpx;
  font-size: 24rpx;
  font-weight: 500;
  color: var(--app-text-2, $uni-text-color-grey);
  background: var(--app-subtle, $uni-bg-color-grey);
  transition: all 0.16s cubic-bezier(.4, 0, .2, 1);
  flex-shrink: 0;

  &.active {
    background: var(--app-primary-soft, rgba($app-primary, 0.1));
    color: var(--app-primary, $app-primary);
    font-weight: 600;
  }

  &:active {
    transform: scale(0.94);
  }
}

/* ⑤ 精选场景 */
.featured-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 16rpx;
  .scene-card {
    width: calc(50% - 8rpx);
    margin-bottom: 0;
    box-sizing: border-box;
  }
}

.more-btn { display: flex; align-items: center; gap: 2rpx; padding: 8rpx 12rpx; transition: transform .16s; &:active { transform: scale(.9); } }
.more-text { font-size: 23rpx; color: var(--app-text-2, $uni-text-color-grey); }

.section {
  margin-top: 32rpx;
}

.section-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 18rpx;
  padding-left: 4rpx;
}

.section-head .section-title {
  margin-bottom: 0;
}

.new-btn {
  display: flex;
  align-items: center;
  gap: 8rpx;
  padding: 10rpx 24rpx;
  border-radius: 30rpx;
  transition: all 0.16s cubic-bezier(.4,0,.2,1);

  &:active {
    transform: scale(0.9);
  }
}

.new-btn-text {
  font-size: 23rpx;
  color: var(--app-primary, $app-primary);
  font-weight: 600;
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

.empty-scene {
  padding: 60rpx 32rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12rpx;
}

.empty-icon {
  width: 104rpx;
  height: 104rpx;
  border-radius: 32rpx;
  background: var(--app-primary-soft, rgba($app-primary, 0.1));
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 6rpx;
}

.empty-text {
  font-size: 28rpx;
  color: var(--app-text, $uni-text-color);
  font-weight: 600;
}

.empty-hint {
  font-size: 23rpx;
  color: var(--app-text-2, $uni-text-color-grey);
}
</style>
