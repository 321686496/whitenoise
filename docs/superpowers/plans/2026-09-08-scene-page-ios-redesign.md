# 场景页 iOS 化重排实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将场景页 Tab（`scene.vue`）重排为 iOS 设计哲学结构：品牌头部 + 问候（消除顶部留白）与三张分组卡片（为你推荐/场景精选/我的场景），数据层与交互全部不变。

**Architecture:** 单一文件重构。模板重排为「品牌头部 + 3 张 `.group-card app-card` 分组卡片」，脚本仅新增 `goTheme` 一个导航函数，其余函数/数据/事件全部保留；样式复用首页 `index.vue` 头部样式与全局 `.app-card`/`.divider`，删除不再使用的本地样式。

**Tech Stack:** uni-app Vue3 `<script setup lang="ts">`、SCSS、vue-tsc 类型检查（无测试框架，验证 = `npm run type-check`）。

## Global Constraints

- 颜色一律使用 CSS 变量（`var(--app-*)`），不新增自定义色值
- 图标一律使用 `@/components/Icon.vue`，iconName 需与已定义图标一致（本任务用到：flame/clock/mountain/mixer/palette/chevron-right 均已定义）
- `.page-container` 顶部保留安全区 padding；页面动效 `iosPageIn` + `prefers-reduced-motion` + `backwards`
- 可点击项加入 iOS 触觉式按压缩放（`:active` 缩放）
- 双列网格显式 `box-sizing: border-box`；间距 `gap: 16rpx` + `width: calc(50% - 8rpx)`
- 双列网格间距模式不变；CSS 变量与 SCSS 回退模式（`var(--app-x, $fallback)`）不变
- git 纪律：工作区存在大量无关未提交改动，**只 `git add` 本任务涉及的具体文件**，禁止 `git add -A` / `git add .`

---

### Task 1: 场景页整页重排（scene.vue 品牌头部 + 三张分组卡片）

**Files:**
- Modify: `prototype/src/pages/scene/scene.vue`（整文件重写）

**Interfaces:**
- Consumes: 现有 `prefLabels`、`recommended`、`recentItems`、`featuredScenes`、`tags`、`myScenes` 与全部事件函数（`openDetail`/`playScene`/`goAllScenes`/`createScene`/`editScene`/`shareScene`/`playMyScene`）；`@/components/Icon.vue`、`SceneCard.vue`、`TabBar.vue`；`usePlayer` 的 `player`/`getRecent`/`recentTimeLabel`；`@/data/scenes` 的 `SIMULATED_PREFS`/`getRecommended`/`getCategoryScenes`
- Produces: 供 H5 手测与最终审查消费；无新导出

- [ ] **Step 1: 整文件重写模板 + 脚本 + 样式**

将 `prototype/src/pages/scene/scene.vue` 完整替换为以下内容（模板结构：① 品牌头部 + 问候；② 卡片 A「为你推荐 + 最近播放」；③ 卡片 B「分类分段 + 精选网格」；④ 卡片 C「我的场景」。脚本在现有基础上仅新增 `goTheme`，`onShow` 刷新逻辑原样保留）：

```vue
<template>
  <view class="page-container">
    <view class="page-bg"></view>

    <!-- 自定义悬浮 TabBar -->
    <TabBar current="scene" />

    <!-- ① 品牌头部 + 问候（含偏好胶囊） -->
    <view class="header">
      <view class="header-top">
        <view class="brand">
          <view class="brand-logo-wrap">
            <image class="brand-logo" src="/static/logo-v10-1.jpg" mode="aspectFit" />
          </view>
          <view class="brand-text">
            <text class="app-title">声栖</text>
            <view class="greeting-row">
              <text class="greeting-text">今晚想听什么？</text>
              <view class="pref-chip" v-for="p in prefLabels" :key="p">
                <Icon name="flame" :size="12" color="var(--app-primary)" />
                <text class="pref-chip-text">{{ p }}</text>
              </view>
            </view>
          </view>
        </view>
        <view class="header-actions">
          <view class="header-btn app-card" @click="createScene">
            <Icon name="mixer" :size="22" color="var(--app-primary)" />
          </view>
          <view class="header-btn app-card" @click="goTheme">
            <Icon name="palette" :size="22" color="var(--app-primary)" />
          </view>
        </view>
      </view>
    </view>

    <!-- ② 卡片 A：为你推荐 + 最近播放 -->
    <view class="group-card app-card">
      <view class="card-head">
        <Icon name="flame" :size="16" color="var(--app-primary)" />
        <text class="card-title">为你推荐</text>
      </view>
      <scroll-view scroll-x class="rec-scroll" :show-scrollbar="false">
        <view class="rec-row">
          <view class="rec-card" v-for="s in recommended" :key="s.id" @click="openDetail(s)">
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

      <view class="recent-block" v-if="recentItems.length > 0">
        <view class="divider"></view>
        <view class="card-head">
          <Icon name="clock" :size="16" color="var(--app-primary)" />
          <text class="card-title">最近播放</text>
        </view>
        <scroll-view scroll-x class="recent-scroll" :show-scrollbar="false">
          <view class="recent-row">
            <view class="recent-card" v-for="r in recentItems" :key="r.sceneId" @click="openDetail(r)">
              <view class="recent-cover" :style="{ background: r.gradient }">
                <Icon :name="r.iconName" :size="34" color="rgba(255,255,255,.95)" />
              </view>
              <text class="recent-name">{{ r.name }}</text>
              <text class="recent-time">{{ recentTimeLabel(r.ts) }}</text>
            </view>
          </view>
        </scroll-view>
      </view>
    </view>

    <!-- ③ 卡片 B：分类分段 + 精选场景 -->
    <view class="group-card app-card">
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
      <view class="section-head">
        <view class="card-head">
          <Icon name="mountain" :size="16" color="var(--app-primary)" />
          <text class="card-title">精选场景</text>
        </view>
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

    <!-- ④ 卡片 C：我的场景 -->
    <view class="group-card app-card">
      <view class="section-head">
        <view class="card-head">
          <Icon name="mixer" :size="16" color="var(--app-primary)" />
          <text class="card-title">我的场景</text>
        </view>
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
      <view class="empty-scene" v-if="myScenes.length === 0">
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

const recommended = ref(getRecommended(SIMULATED_PREFS, getRecent()))
const recentItems = ref(getRecent())

const featuredScenes = computed(() =>
  getCategoryScenes(activeTag.value as Scene['category'] | 'all', 3),
)

// 首页金刚区快捷入口直达分类 + 重读最近播放
onShow(() => {
  recentItems.value = getRecent()
  recommended.value = getRecommended(SIMULATED_PREFS, recentItems.value)
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

const goTheme = () => uni.navigateTo({ url: '/pages/theme/theme' })

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
/* ① 品牌头部（与首页 index.vue 同款） */
.header {
  padding: 16rpx 4rpx 20rpx;
}

.header-top {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.brand {
  display: flex;
  align-items: center;
  gap: 20rpx;
}

.brand-logo-wrap {
  width: 84rpx;
  height: 84rpx;
  border-radius: 24rpx;
  overflow: hidden;
  box-shadow: 0 8rpx 22rpx color-mix(in srgb, var(--app-primary, $app-primary) 22%, transparent);
}

.brand-logo {
  width: 100%;
  height: 100%;
}

.brand-text {
  display: flex;
  flex-direction: column;
  gap: 6rpx;
}

.app-title {
  font-size: 46rpx;
  font-weight: 800;
  color: var(--app-text, $uni-text-color);
  letter-spacing: 4rpx;
  line-height: 1.1;
}

.greeting-row {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 8rpx;
}

.greeting-text {
  font-size: 22rpx;
  color: var(--app-text-2, $uni-text-color-grey);
  letter-spacing: 1rpx;
}

.pref-chip {
  display: inline-flex;
  align-items: center;
  gap: 4rpx;
  padding: 4rpx 14rpx;
  border-radius: 18rpx;
  background: var(--app-primary-soft, rgba($app-primary, 0.1));
}

.pref-chip-text {
  font-size: 20rpx;
  color: var(--app-primary, $app-primary);
  font-weight: 600;
}

.header-actions {
  display: flex;
  gap: 16rpx;
}

.header-btn {
  width: 68rpx;
  height: 68rpx;
  border-radius: 22rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: transform 0.16s cubic-bezier(.4, 0, .2, 1);

  &:active {
    transform: scale(0.9);
  }
}

/* ② 分组卡片 */
.group-card {
  padding: 24rpx;
  margin-bottom: 24rpx;
}

.card-head {
  display: flex;
  align-items: center;
  gap: 10rpx;
  margin-bottom: 18rpx;
}

.card-title {
  font-size: 25rpx;
  font-weight: 600;
  letter-spacing: 0.3rpx;
  color: var(--app-text-2, $uni-text-color-grey);
}

.divider {
  height: 1rpx;
  background: var(--app-divider, rgba($app-primary, 0.08));
  margin: 6rpx 0 20rpx;
}

.recent-block {
  margin-top: 2rpx;
}

/* ③ 为你推荐横滑（卡片 A 内） */
.rec-scroll,
.recent-scroll {
  white-space: nowrap;
}

.rec-row,
.recent-row {
  display: inline-flex;
  gap: 20rpx;
  padding: 4rpx 4rpx 8rpx;
}

.rec-card {
  width: 240rpx;
  flex-shrink: 0;
  transition: transform .16s;

  &:active {
    transform: scale(.96);
  }
}

.rec-cover {
  height: 140rpx;
  border-radius: 16rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  margin-bottom: 12rpx;
}

.rec-reason {
  position: absolute;
  left: 10rpx;
  bottom: 10rpx;
  display: flex;
  align-items: center;
  gap: 4rpx;
  padding: 4rpx 12rpx;
  border-radius: 18rpx;
  background: rgba(255, 255, 255, .9);
}

.rec-reason-text {
  font-size: 20rpx;
  color: var(--app-primary, $app-primary);
  font-weight: 600;
}

.rec-name {
  font-size: 27rpx;
  font-weight: 600;
  color: var(--app-text, $uni-text-color);
  display: block;
}

.rec-desc {
  font-size: 22rpx;
  color: var(--app-text-2, $uni-text-color-grey);
  display: block;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

/* ④ 最近播放横滑（卡片 A 内） */
.recent-card {
  width: 180rpx;
  flex-shrink: 0;
  transition: transform .16s;

  &:active {
    transform: scale(.96);
  }
}

.recent-cover {
  height: 110rpx;
  border-radius: 16rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 10rpx;
}

.recent-name {
  font-size: 25rpx;
  font-weight: 600;
  color: var(--app-text, $uni-text-color);
  display: block;
}

.recent-time {
  font-size: 21rpx;
  color: var(--app-text-2, $uni-text-color-grey);
}

/* ⑤ 分类分段（卡片 B 内） */
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

/* ⑥ 精选场景（卡片 B 内） */
.section-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 18rpx;
  padding-left: 2rpx;
}

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

.more-btn {
  display: flex;
  align-items: center;
  gap: 2rpx;
  padding: 8rpx 12rpx;
  transition: transform .16s;

  &:active {
    transform: scale(.9);
  }
}

.more-text {
  font-size: 23rpx;
  color: var(--app-text-2, $uni-text-color-grey);
}

/* ⑦ 我的场景（卡片 C 内） */
.new-btn {
  display: flex;
  align-items: center;
  gap: 8rpx;
  padding: 10rpx 24rpx;
  border-radius: 30rpx;
  transition: all 0.16s cubic-bezier(.4, 0, .2, 1);

  &:active {
    transform: scale(0.9);
  }
}

.new-btn-text {
  font-size: 23rpx;
  color: var(--app-primary, $app-primary);
  font-weight: 600;
}

.empty-scene {
  padding: 48rpx 24rpx;
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
```

- [ ] **Step 2: 类型检查**

Run（在 `prototype/` 下）: `npm run type-check`
Expected: 零错误（exit 0）

- [ ] **Step 3: 自审**

- 模板不再引用已删除的 `.pref-bar`；`prefLabels` 仍被头部胶囊使用，无死引用
- 旧样式 `.section`/`.page-title`/`.page-subtitle`/`.pref-bar`/`.section-title` 本地覆盖已移除，`card-title` 取代其职责
- 双列网格 `.featured-grid .scene-card` 保留 `box-sizing: border-box` + `gap: 16rpx` + `width: calc(50% - 8rpx)`
- 所有可点击项（header-btn/tag-item/rec-card/recent-card/more-btn/new-btn/SceneCard 内部）保留 `:active` 按压
- 卡片 A 的最近播放子块 `v-if="recentItems.length > 0"`，为空时连分隔线一起隐藏

- [ ] **Step 4: 提交**

```bash
git add prototype/src/pages/scene/scene.vue
git commit -m "feat: ios-ify scene tab with brand header and grouped cards"
```

（仅此一个文件；提交前 `git status --short` 核对暂存区只有 scene.vue）

---

### Task 2: 最终审查与视觉验证

**Files:**
- 审查对象：`prototype/src/pages/scene/scene.vue`（Task 1 的提交）

**Interfaces:**
- Consumes: Task 1 完成后的 `scene.vue`；H5 dev 服务（`npm run dev:h5`，端口 5173）

- [ ] **Step 1: 代码审查（task reviewer）**

按 subagent-driven-development 流程：以 Task 1 的 BASE..HEAD 生成 review package，派发 task reviewer 核对规格合规与代码质量。Global Constraints 逐条对照（CSS 变量、Icon.vue、`:active`、box-sizing、gap/width、git 纪律）。

- [ ] **Step 2: H5 视觉验证**

浏览器打开 `http://localhost:5173/#/pages/scene/scene`，对照规格 §4 手测清单：
1. 顶部品牌头部 + 问候行 + 偏好胶囊，无大片留白
2. 三张分组卡片边界清晰、间距均匀
3. 卡片 A：推荐横滑 + 最近播放横滑；无最近记录时子块隐藏
4. 卡片 B：分段切换联动精选网格；查看全部进列表页
5. 卡片 C：新建/编辑/分享/播放行为不变
6. 主题切换后卡片颜色随 `--app-*` 变化

- [ ] **Step 3: 收尾**

修复审查发现的 Critical/Important 项（如有），记录 Minor 项到进度账本；全部通过后向用户汇报。

---
