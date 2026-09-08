# 场景页个性化实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 场景页改为「偏好 + 推荐 + 最近播放 + 分类精选 + 我的场景」结构，新增查看全部列表页，并把场景详情页从硬编码改造为真实数据驱动。

**Architecture:** 三个页面共享 `@/data/scenes.ts`（homeScenes/sounds）与 `@/composables/usePlayer.ts`（applyScene/getRecent）。数据层函数（推荐/配方/预设模拟）集中在 scenes.ts，页面只消费。场景页与列表页卡片交互一致：tap 进详情页、play 走共享播放状态。

**Tech Stack:** uni-app Vue3 `<script setup lang="ts">`、SCSS、vue-tsc 类型检查（无测试框架，验证 = `npm run type-check`）。

## Global Constraints

- 颜色一律使用 CSS 变量（`var(--app-*)`），不新增自定义色值
- 图标一律使用 `@/components/Icon.vue`，iconName 需与 Icon.vue 已定义图标一致
- 分区表头采用 iOS 式小号灰色次级标签（12px 灰），非大号加粗标题
- `.page-container` 顶部保留安全区 padding（刘海适配）
- 页面进入动效使用 `iosPageIn`，兼容 `prefers-reduced-motion`，`backwards` 填充
- 分组列表分隔线内缩（对齐图标后文字起点）
- 可点击项加入 iOS 触觉式按压缩放过渡（`:active` 缩放）
- **双列网格元素必须显式 `box-sizing: border-box`**（uni-app H5 对 view 无全局 border-box，缺失会两列塌成单列）
- 双列网格间距模式：`gap: 16rpx` + 单卡 `width: calc(50% - 8rpx)`
- git 纪律：工作区存在大量无关未提交改动，**只 `git add` 本任务涉及的具体文件**，禁止 `git add -A` / `git add .`；提交前先 `git status` 核对

---

### Task 1: 数据层扩展（scenes.ts）

**Files:**
- Modify: `prototype/src/data/scenes.ts`（文件末尾追加）

**Interfaces:**
- Consumes: 已有 `Scene`、`SceneCategory`、`homeScenes`、`sounds`
- Produces（后续任务消费）:
  - `SIMULATED_PREFS: SceneCategory[]`
  - `getRecommended(prefs, recent, limit?) => Scene[]`
  - `getCategoryScenes(category, limit) => Scene[]`
  - `buildRecipe(scene) => RecipeItem[]`
  - `buildPresets(scene) => PresetOption[]`

- [ ] **Step 1: 在 scenes.ts 末尾追加数据层代码**

```ts
/* ------------------------- 场景页个性化数据层 ------------------------- */

export interface RecipeItem {
  name: string
  icon: string
  percent: number
  color: string
}

export interface PresetOption {
  name: string
  badgeColor: string
  ratios: { name: string; value: number }[]
}

/** 模拟偏好标签（原型阶段写死：助眠 + 自然） */
export const SIMULATED_PREFS: SceneCategory[] = ['sleep', 'nature']

/** 按偏好推荐：优先 prefs 分类且 recent 未听过的，取 limit 个；不足按序补齐 */
export function getRecommended(
  prefs: SceneCategory[],
  recent: { sceneId: string }[],
  limit = 4,
): Scene[] {
  const heard = new Set(recent.map((r) => r.sceneId))
  const preferred = homeScenes.filter((s) => prefs.includes(s.category) && !heard.has(s.id))
  if (preferred.length >= limit) return preferred.slice(0, limit)
  const rest = homeScenes.filter((s) => !preferred.includes(s))
  return [...preferred, ...rest].slice(0, limit)
}

/** 分类精选：'all' 取前 limit，否则按分类过滤后取前 limit */
export function getCategoryScenes(category: SceneCategory | 'all', limit: number): Scene[] {
  const list = category === 'all' ? homeScenes : homeScenes.filter((s) => s.category === category)
  return list.slice(0, limit)
}

/** 生成配方比例（原型模拟）：首音 40%，其余均分，末位补齐保证总和 100 */
export function buildRecipe(scene: Scene): RecipeItem[] {
  const first = 40
  const n = scene.soundIds.length
  return scene.soundIds.map((id, i) => {
    const s = sounds.find((x) => x.id === id)
    let percent: number
    if (i === 0) percent = first
    else if (i === n - 1) percent = 100 - first - Math.round((100 - first) / Math.max(n - 1, 1)) * (n - 2)
    else percent = Math.round((100 - first) / Math.max(n - 1, 1))
    return {
      name: s?.name ?? id,
      icon: s?.iconName ?? 'wave',
      color: s?.color ?? '#8296A8',
      percent,
    }
  })
}

/** 生成三档预设（原型模拟）：轻度首音 25% / 标准 40% / 深度 60%，末位补齐 */
export function buildPresets(scene: Scene): PresetOption[] {
  const names = scene.soundIds.map((id) => sounds.find((s) => s.id === id)?.name ?? id)
  const spread = (first: number): { name: string; value: number }[] => {
    const n = names.length
    const out: { name: string; value: number }[] = []
    let used = 0
    names.forEach((name, i) => {
      if (i === 0) {
        out.push({ name, value: first })
        used = first
      } else if (i === n - 1) {
        out.push({ name, value: 100 - used })
      } else {
        const v = Math.round((100 - first) / Math.max(n - 1, 1))
        out.push({ name, value: v })
        used += v
      }
    })
    return out
  }
  return [
    { name: '轻度', badgeColor: 'linear-gradient(135deg, #B0BFA8, #8FAF8F)', ratios: spread(25) },
    { name: '标准', badgeColor: 'linear-gradient(135deg, #8296A8, #5F7A92)', ratios: spread(40) },
    { name: '深度', badgeColor: 'linear-gradient(135deg, #6E6290, #8E82A6)', ratios: spread(60) },
  ]
}
```

- [ ] **Step 2: 类型检查**

Run（在 `prototype/` 下）: `npm run type-check`
Expected: 零错误

- [ ] **Step 3: 提交**

```bash
git add prototype/src/data/scenes.ts
git commit -m "feat: scene personalization data layer (recommend/recipe/presets)"
```

---

### Task 2: 场景页个性化改造（scene.vue）

**Files:**
- Modify: `prototype/src/pages/scene/scene.vue`（整页重排）

**Interfaces:**
- Consumes: Task 1 的 `SIMULATED_PREFS`、`getRecommended`、`getCategoryScenes`；`usePlayer` 的 `applyScene`、`getRecent`、`recentTimeLabel`；`SceneCard`（props: name/soundCount/soundIcons/bgColor/isPreset/layout/active；events: tap/play/share）
- Produces: 页面结构与交互约定（列表页 Task 4 复用同样的 tap→详情 / play→播放 规则）

- [ ] **Step 1: 重写模板为六区块结构**

区块顺序：偏好胶囊 → 为你推荐（横滑）→ 最近播放（横滑，空则隐藏）→ 分类 Tab → 精选场景（grid 双列 + 查看全部）→ 我的场景（保留）。

关键模板（新增区块 + 精选区改造）：

```vue
<!-- ① 偏好胶囊 -->
<view class="pref-bar">
  <Icon name="sparkle" :size="16" color="var(--app-primary)" />
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
            <Icon name="sparkle" :size="12" color="var(--app-primary)" />
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
```

精选区（替换现有"官方预设"块）——grid 双列 + 查看全部：

```vue
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
```

- [ ] **Step 2: 重写 script 逻辑**

```ts
import { ref, computed } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import SceneCard from '@/components/SceneCard.vue'
import Icon from '@/components/Icon.vue'
import TabBar from '@/components/TabBar.vue'
import { player, applyScene, getRecent, recentTimeLabel } from '@/composables/usePlayer'
import { homeScenes, SIMULATED_PREFS, getRecommended, getCategoryScenes } from '@/data/scenes'
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

// 首页金刚区快捷入口直达分类
onShow(() => {
  recentItems.value = getRecent()
  if (player.pendingSceneCategory && player.pendingSceneCategory !== 'all') {
    activeTag.value = player.pendingSceneCategory
    player.pendingSceneCategory = 'all'
  }
})

const presetSoundIcons = (scene: Scene) =>
  scene.soundIds.map((id) => sounds.find((s) => s.id === id)?.iconName ?? 'wave')

const openDetail = (scene: { id: string }) => {
  uni.navigateTo({ url: `/pages/scene-detail/scene-detail?sceneId=${scene.id}` })
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
}
```

注意：删除原本地 `applyScene` 函数（改为 `playScene` 组合共享 `applyScene`）；我的场景 SceneCard 保留 `@tap="editScene(scene)"`、`@share="shareScene(scene)"`、`@play="playScene(scene)"`（`Scene` 结构与 `MyScene` 均有 id，`playScene` 入参需放宽为 `{ id: string; name: string } & Partial<Scene>`——实际 `playScene` 需要完整 Scene（soundIds），我的场景播放需构造：`myScenes` 播放时调用 `playScene({ ...scene } as unknown as Scene)` 或仅 toast 提示。**决定：我的场景 @play 保持 toast + 返回首页（不写共享状态）**，见 Step 3 说明。

- [ ] **Step 3: 补充样式并处理我的场景播放**

新增样式（SCSS，沿用现有变量与按压动效）：

```scss
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

.rec-scroll, .recent-scroll { white-space: nowrap; }
.rec-row, .recent-row { display: inline-flex; gap: 20rpx; padding: 4rpx 4rpx 8rpx; }
.rec-card { width: 260rpx; padding: 16rpx; flex-shrink: 0; transition: transform .16s; &:active { transform: scale(.96); } }
.rec-cover { height: 150rpx; border-radius: 18rpx; display: flex; align-items: center; justify-content: center; position: relative; margin-bottom: 12rpx; }
.rec-reason { position: absolute; left: 10rpx; bottom: 10rpx; display: flex; align-items: center; gap: 4rpx; padding: 4rpx 12rpx; border-radius: 18rpx; background: rgba(255,255,255,.9); }
.rec-reason-text { font-size: 20rpx; color: var(--app-primary, $app-primary); font-weight: 600; }
.rec-name { font-size: 27rpx; font-weight: 600; color: var(--app-text, $uni-text-color); display: block; }
.rec-desc { font-size: 22rpx; color: var(--app-text-2, $uni-text-color-grey); display: block; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }

.recent-card { width: 190rpx; flex-shrink: 0; padding: 16rpx; transition: transform .16s; &:active { transform: scale(.96); } }
.recent-cover { height: 120rpx; border-radius: 18rpx; display: flex; align-items: center; justify-content: center; margin-bottom: 10rpx; }
.recent-name { font-size: 25rpx; font-weight: 600; color: var(--app-text, $uni-text-color); display: block; }
.recent-time { font-size: 21rpx; color: var(--app-text-2, $uni-text-color-grey); }

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
```

我的场景播放：`@play="playMyScene(scene)"`，`playMyScene` 仅 toast + switchTab 首页（原型演示，不写共享状态）：

```ts
const playMyScene = (scene: { name: string }) => {
  uni.showToast({ title: `已应用「${scene.name}」`, icon: 'success' })
  setTimeout(() => uni.switchTab({ url: '/pages/index/index' }), 800)
}
```

- [ ] **Step 4: 类型检查**

Run（在 `prototype/` 下）: `npm run type-check`
Expected: 零错误

- [ ] **Step 5: 提交**

```bash
git add prototype/src/pages/scene/scene.vue
git commit -m "feat: personalize scene page (prefs/recommend/recent/featured grid)"
```

---

### Task 3: 场景详情页真实数据驱动（scene-detail.vue）

**Files:**
- Modify: `prototype/src/pages/scene-detail/scene-detail.vue`

**Interfaces:**
- Consumes: Task 1 的 `buildRecipe`、`buildPresets`；`scenes.ts` 的 `findScene`、`homeScenes`、`soundNames`；`usePlayer` 的 `applyScene`
- Produces: 供 Task 2/4 的 `navigateTo /pages/scene-detail/scene-detail?sceneId=` 消费

- [ ] **Step 1: 重写 script 为数据驱动**

```ts
import { ref, computed } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import Icon from '@/components/Icon.vue'
import { findScene, homeScenes, buildRecipe, buildPresets } from '@/data/scenes'
import { applyScene } from '@/composables/usePlayer'

const sceneId = ref('')
const activePreset = ref('标准')
// 收藏状态：按 sceneId 内存级记忆
const favMap = ref<Record<string, boolean>>({})

const scene = computed(() => findScene(sceneId.value) ?? homeScenes[0])
const recipe = computed(() => buildRecipe(scene.value))
const presets = computed(() => buildPresets(scene.value))
const isFavorited = computed(() => !!favMap.value[scene.value.id])

onLoad((options) => {
  sceneId.value = options?.sceneId ?? ''
})

const coverGradient = computed(() => scene.value.gradient)

const applyPreset = (preset: { name: string }) => {
  activePreset.value = preset.name
  uni.showToast({ title: `已切换「${preset.name}」方案`, icon: 'none' })
}

const playScene = () => {
  applyScene(scene.value)
  uni.showToast({ title: '已开始播放', icon: 'success' })
  setTimeout(() => uni.switchTab({ url: '/pages/index/index' }), 800)
}

const editScene = () => {
  uni.navigateTo({ url: `/pages/scene-edit/scene-edit?sceneId=${scene.value.id}` })
}

const toggleFavorite = () => {
  favMap.value[scene.value.id] = !favMap.value[scene.value.id]
  uni.showToast({ title: isFavorited.value ? '已收藏' : '已取消收藏', icon: 'none' })
}

const shareScene = () => {
  uni.showToast({ title: '已生成分享卡片', icon: 'success' })
}
```

- [ ] **Step 2: 重写模板绑定**

- 封面区：`:style="{ background: coverGradient }"`；图标 `:name="scene.iconName"`；名称 `{{ scene.name }}`；描述 `{{ scene.desc }}`
- 场景故事：`"{{ scene.desc }}"`
- 声音配方：`v-for="item in recipe"`（保留现有 `recipe-item` / `recipe-bar-fill` 结构，宽度绑定 `item.percent + '%'`，背景色 `item.color`）
- 预设方案：`v-for="preset in presets"`（保留现有 `preset-card` 结构；`activePreset` 与 `preset.name` 比较）
- 播放：`@click="playScene"`（播放后 switchTab 首页）
- 编辑配方：`@click="editScene"`；收藏：`@click="toggleFavorite"`，文案 `{{ isFavorited ? '已收藏' : '收藏' }}`；分享不变
- 分享预览：`scene.iconName` / `scene.name`，统计文案保留模拟

- [ ] **Step 3: 删除硬编码数据**

删除原 `const scene = {...}` 硬编码对象（深夜雨声数据、presets 数组）。

- [ ] **Step 4: 类型检查**

Run（在 `prototype/` 下）: `npm run type-check`
Expected: 零错误

- [ ] **Step 5: 提交**

```bash
git add prototype/src/pages/scene-detail/scene-detail.vue
git commit -m "feat: drive scene detail page from real scene data"
```

---

### Task 4: 查看全部列表页（scene-all.vue + pages.json）

**Files:**
- Create: `prototype/src/pages/scene-all/scene-all.vue`
- Modify: `prototype/src/pages.json`（scene-edit 之后追加注册）

**Interfaces:**
- Consumes: `homeScenes`、`sceneCategories`、`SceneCard`（grid）、`usePlayer` 的 `applyScene`
- Produces: `navigateTo /pages/scene-all/scene-all`（Task 2 已引用）

- [ ] **Step 1: 创建页面模板与逻辑**

```vue
<template>
  <view class="page-container">
    <view class="page-bg"></view>
    <view class="header">
      <text class="page-title">全部场景</text>
      <text class="page-subtitle">浏览全部官方预设场景</text>
    </view>

    <view class="tag-filter">
      <view
        class="tag-item"
        :class="{ active: activeTag === tag.key }"
        v-for="tag in sceneCategories"
        :key="tag.key"
        @click="activeTag = tag.key"
      >
        <text>{{ tag.label }}</text>
      </view>
    </view>

    <view class="scene-grid">
      <SceneCard
        v-for="scene in filteredScenes"
        :key="scene.id"
        :name="scene.name"
        :sound-count="scene.soundIds.length"
        :sound-icons="soundIconsOf(scene)"
        :bg-color="scene.gradient"
        :is-preset="scene.isPreset"
        layout="grid"
        :active="player.currentScene?.id === scene.id"
        @tap="openDetail(scene)"
        @play="playScene(scene)"
      />
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import SceneCard from '@/components/SceneCard.vue'
import Icon from '@/components/Icon.vue'
import { sceneCategories, homeScenes } from '@/data/scenes'
import type { Scene } from '@/data/scenes'
import { sounds } from '@/data/sounds'
import { player, applyScene } from '@/composables/usePlayer'

const activeTag = ref('all')

const filteredScenes = computed(() => {
  if (activeTag.value === 'all') return homeScenes
  return homeScenes.filter((s) => s.category === activeTag.value)
})

const soundIconsOf = (scene: Scene) =>
  scene.soundIds.map((id) => sounds.find((s) => s.id === id)?.iconName ?? 'wave')

const openDetail = (scene: { id: string }) => {
  uni.navigateTo({ url: `/pages/scene-detail/scene-detail?sceneId=${scene.id}` })
}

const playScene = (scene: Scene) => {
  applyScene(scene)
  uni.showToast({ title: '已开始播放', icon: 'success' })
  setTimeout(() => uni.switchTab({ url: '/pages/index/index' }), 800)
}
</script>
```

样式要点：`.header/.page-title/.page-subtitle` 同场景页；`.tag-filter/.tag-item` 同场景页；`.scene-grid` 双列（gap 16rpx + `width: calc(50% - 8rpx)` + `box-sizing: border-box`）。`Icon` 若未在模板使用则删除 import。

- [ ] **Step 2: 注册页面（pages.json）**

在 scene-edit 对象之后追加：

```json
{
  "path": "pages/scene-all/scene-all",
  "style": {
    "navigationBarTitleText": "全部场景",
    "navigationBarBackgroundColor": "#F5F2ED",
    "navigationBarTextStyle": "black"
  }
}
```

- [ ] **Step 3: 类型检查**

Run（在 `prototype/` 下）: `npm run type-check`
Expected: 零错误

- [ ] **Step 4: 提交**

```bash
git add prototype/src/pages/scene-all/scene-all.vue prototype/src/pages.json
git commit -m "feat: add all-scenes list page"
```

---

### Task 5: 最终审查与修复

- 派发代码审查子代理：规格符合性（六区块、交互矩阵、详情页数据映射、列表页）+ 代码质量（box-sizing、空态、import 清理、命名冲突）
- 对 Critical/Important 发现派发修复子代理
- 最终 `npm run type-check` 零错误后收尾
