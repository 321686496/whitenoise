# 场景页个性化设计（场景页/详情页/全部列表）规格

> 日期：2026-09-08
> 关联：2026-09-07-homepage-redesign-design.md（首页重设计，本方案复用其数据源与共享播放状态）

## 背景与目标

当前场景页（`pages/scene/scene.vue`）为「分类 Tab + 全部官方场景平铺 + 我的场景」，信息密度高但缺乏个性化与浏览深度。本次优化：

1. 场景页 Tab 页只展示**一部分场景信息与用户信息**（偏好、推荐、最近播放、我的场景）
2. 依据**用户偏好**给出推荐信息（原型阶段模拟偏好，不做真实推荐算法）
3. 所有场景的完整信息通过**场景详情页**查看（`pages/scene-detail/scene-detail.vue` 从硬编码改造为真实数据驱动）

原型定位：**先做设计展示，不做重功能**。偏好、推荐理由、配方比例、预设方案均为模拟/派生数据；最近播放使用现有真实本地存储（`shengqi-recent`）。

## 架构

三个页面共享同一数据源（`@/data/scenes.ts` 的 `homeScenes`、`@/data/sounds.ts` 的 `sounds`）与共享播放状态（`@/composables/usePlayer.ts`）：

- 场景页（Tab 页）：个性化区块 + 分类精选 + 我的场景，承担入口职责
- 场景详情页（普通页）：按 `sceneId` 展示单个场景完整信息，承担"查看"职责
- 查看全部列表页（普通页，新增 `pages/scene-all`）：10 个官方场景平铺网格，承担"浏览全部"职责

## 全局约束

以下约束对三个页面一律生效：

- 颜色一律使用 CSS 变量（`var(--app-*)`），不新增自定义色值
- 图标一律使用 `@/components/Icon.vue`，iconName 需与 Icon.vue 已定义图标一致
- 分区表头采用 iOS 式小号灰色次级标签（12px 灰），非大号加粗标题
- `.page-container` 顶部保留安全区 padding（刘海适配）
- 页面进入动效使用 `iosPageIn`，兼容 `prefers-reduced-motion`，`backwards` 填充
- 分组列表分隔线内缩（对齐图标后文字起点）
- 可点击项加入 iOS 触觉式按压缩放过渡（`transform: scale(0.9x)` + `:active`）
- **双列网格元素必须显式 `box-sizing: border-box`**（uni-app H5 对 view 无全局 border-box，缺失会导致两列塌成单列——首页已踩坑修复）
- 双列网格间距模式：`gap: 16rpx` + 单卡 `width: calc(50% - 8rpx)`

---

## 1. 场景页（scene.vue）改造

### 1.1 页面结构（自上而下）

```
① 偏好胶囊     [你的偏好：助眠 · 自然]          ← 模拟标签
② 为你推荐    横滑卡 ×4（推荐理由角标）         ← getRecommended()
③ 最近播放    横滑 ×5（真实 getRecent()）       ← 现有真实数据
④ 分类 Tab    全部 / 助眠 / 专注 / 放松 / 自然   ← 保留
⑤ 精选场景    当前分类前 3 个网格 + 「查看全部」入口
⑥ 我的场景    保留（新建 / 编辑 / 分享）
```

### 1.2 区块明细

| 区块 | 内容 | 数据源 | 空态 |
|---|---|---|---|
| ① 偏好胶囊 | 一行胶囊标签，文案「你的偏好：助眠 · 自然」，左侧偏好图标 | 模拟（常量 `SIMULATED_PREFS = ['sleep', 'nature']`） | 恒有值 |
| ② 为你推荐 | 横滑卡片：渐变封面 + 名称 + 推荐理由小角标（如「常听自然」） | `getRecommended(prefs, recent)` | 恒有值（不足 4 个时补齐） |
| ③ 最近播放 | 横滑卡片：渐变封面 + 名称 + 时间标签（`recentTimeLabel`） | `getRecent()` | 无记录时隐藏整个区块 |
| ④ 分类 Tab | 现有 5 个 Tab 保留 | `sceneCategories` | — |
| ⑤ 精选场景 | 当前分类 `getCategoryScenes(category, 3)`，双列网格；标题右侧「查看全部」入口 | `homeScenes` | 分类恒有 ≥2 个 |
| ⑥ 我的场景 | 现有 m1/m2 模拟数据与「新建」按钮，行为不变 | 本地模拟 | — |

### 1.3 交互规则

| 卡片 | 点击（tap） | 播放按钮（play） |
|---|---|---|
| 官方预设卡 | `navigateTo /pages/scene-detail/scene-detail?sceneId=` | `applyScene(scene)` + toast + `switchTab` 首页 |
| 为你推荐卡 | 同上进详情页 | 同上直接播放 |
| 最近播放项 | 进详情页（`sceneId` 有效时） | — |
| 我的场景卡 | 保留进编辑（scene-edit） | 保留播放 |

- 播放统一行为：`applyScene(scene)` 写入共享状态 → toast「已开始播放」→ `switchTab` 至首页，首页大播放卡即时呈现
- 「查看全部」入口：置于精选网格区标题右侧（与首页「随机播放」同款式），点击 `navigateTo /pages/scene-all/scene-all`
- 官方预设卡与推荐卡均可进详情页；卡片内播放按钮 `@click.stop` 阻断冒泡，避免误进详情

---

## 2. 场景详情页改造（scene-detail.vue）

### 2.1 数据驱动

- `onLoad(options)` 读取 `options.sceneId` → `findScene(sceneId)`；查不到时兜底 `homeScenes[0]`
- 所有展示数据由 Scene 对象 + `sounds` 派生，移除组件内写死的"深夜雨声"数据

### 2.2 区块映射

| 区块 | 现状（硬编码） | 改造后 |
|---|---|---|
| 封面区 | 雨声图标/名称 | `scene.gradient` 背景 + `scene.iconName` 图标 + `scene.name` + `scene.desc` |
| 场景故事 | 写死文案 | `scene.desc`（引用文案） |
| 声音配方 | 写死 3 声音 + 比例条 | `scene.soundIds` → `sounds` 查名称/图标/颜色；比例由 `buildRecipe(scene)` 生成（首个声音 40%，其余均分） |
| 预设方案 | 写死 轻度/标准/深度 | `buildPresets(scene)` 三档：标准 = 配方本身；轻度 = 首音权重 −15；深度 = 首音权重 +15（其余均摊） |
| 播放 | 写死 toast | `applyScene(scene)` + toast「已开始播放」+ `switchTab` 首页 |
| 编辑/收藏/分享 | 原型模拟 | 保留；收藏状态按 `sceneId` 内存级记忆 |
| 分享预览 | 写死文案 | 名称/图标取真实场景，文案模拟 |

### 2.3 设计决策

- 详情页**不设**「相关推荐」区：浏览闭环由场景页推荐区块承担，保持详情页聚焦
- 预设比例是视觉演示数据（原型），不参与真实混音
- 收藏、分享保持 toast 级模拟，不新增存储

---

## 3. 查看全部列表页（新增 scene-all.vue）

- 注册于 `pages.json` 为非 Tab 页，标题「全部场景」
- 顶部复用分类 Tab（全部/助眠/专注/放松/自然）快速筛选
- 10 个官方场景**双列网格**平铺（复用 `SceneCard` grid 模式，注意 `box-sizing: border-box`）
- 点击卡 → 详情页；播放按钮 → 直接播放（交互规则同场景页官方预设卡）
- 数据：`homeScenes` 按 `activeTag` 过滤（`'all'` → 全部）
- 空态：分类恒有 ≥2 个场景，理论不空；仍提供兜底空态文案

---

## 4. 数据层（scenes.ts 内新增）

| 函数 | 签名 | 行为 |
|---|---|---|
| `getRecommended` | `(prefs: SceneCategory[], recent: RecentItem[]) => Scene[]` | 按 `prefs` 匹配 `homeScenes.category`，优先 recent 中未出现者，取 4；不足时按顺序补齐 |
| `getCategoryScenes` | `(category: SceneCategory \| 'all', limit: number) => Scene[]` | `'all'` → 全部取前 `limit`；否则过滤后取前 `limit` |
| `buildRecipe` | `(scene: Scene) => RecipeItem[]` | `{ name, icon, percent, color }[]`，首音 40% 其余均分 |
| `buildPresets` | `(scene: Scene) => Preset[]` | 三档：标准/轻度/深度，比例由 `buildRecipe` 偏移 |

- 模拟偏好常量 `SIMULATED_PREFS: SceneCategory[] = ['sleep', 'nature']`（导出供场景页使用）
- `getRecommended` 依赖 `usePlayer` 的 `RecentItem` 类型——为避免循环依赖，签名接收 `recent: { sceneId: string }[]` 结构的最小类型

---

## 5. 验证

- `npm run type-check`（vue-tsc --noEmit）零错误
- H5 手测路径：
  1. 场景页：偏好胶囊 → 为你推荐横滑 → 最近播放横滑 → Tab 切换 → 精选 3 个 → 查看全部
  2. 卡片点击进详情、播放按钮直接播
  3. 详情页：任意场景 id 直达（含无效 id 兜底）、配方/预设随场景变化
  4. 列表页：Tab 筛选 + 双列网格正常（无单列塌陷）
