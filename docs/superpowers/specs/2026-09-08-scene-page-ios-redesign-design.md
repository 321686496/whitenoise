# 场景页 iOS 化重设计（品牌头部 + 分组卡片）规格

> 日期：2026-09-08
> 关联：2026-09-08-scene-page-personalization-design.md（个性化方案已实现，本方案只重排场景页 Tab 的视觉结构，数据层/交互/详情页/列表页不变）

## 背景与问题

场景页 Tab 当前为「小字标题 + 6 个悬浮区块」结构，用户反馈三个问题：

1. **顶部没有标题栏**：页面只有一行小号「场景」标题，与首页的品牌头部（logo + 声栖 + 问候 + 操作按钮）不一致
2. **内容上方大片留白**：头部视觉锚点过弱，顶部米色渐变带显得空旷
3. **区块组织模糊**：偏好胶囊 / 为你推荐 / 最近播放 / 分类 Tab / 精选场景 / 我的场景六个悬浮区块视觉权重均等、间距松散，缺乏清晰分组

## 目标

按 iOS 设计哲学（Apple HIG）重排场景页 Tab 结构：**品牌头部 + 问候** 消除顶部留白，**分组卡片式**（iOS 设置/健康 App 风格）使区块边界清晰、层级分明。

## 全局约束（沿用）

- 颜色一律使用 CSS 变量（`var(--app-*)`），不新增自定义色值
- 图标一律使用 `@/components/Icon.vue`，iconName 需与已定义图标一致
- `.page-container` 顶部保留安全区 padding；页面动效 `iosPageIn` + `prefers-reduced-motion` + `backwards`
- 可点击项加入 iOS 触觉式按压缩放（`:active` 缩放）
- 双列网格显式 `box-sizing: border-box`；间距 `gap: 16rpx` + `width: calc(50% - 8rpx)`
- 双列网格间距模式不变；CSS 变量与 SCSS 回退模式不变
- git 纪律：只提交本任务涉及文件，禁止 `git add -A` / `git add .`

---

## 1. 页面结构（自上而下）

```
① 品牌头部 + 问候（替代原小标题 + 偏好胶囊）
   左：logo + 「声栖」 + 问候行（含偏好标签内嵌胶囊）
   右：新建场景（mixer） / 主题（palette） 两个圆形按钮
② 卡片 A「继续聆听」
   卡片头「为你推荐」 + 横滑推荐卡 ×4（保留「常听偏好」角标）
   —— 发丝分隔线 ——
   「最近播放」横滑卡（无记录时整块隐藏）
③ 卡片 B「场景精选」
   卡片顶部：分类分段控件（全部/助眠/专注/放松/自然，图标+文字胶囊）
   卡片内：「精选场景 + 查看全部」表头 + 双列网格 ×3
④ 卡片 C「我的场景」
   「我的场景 + 新建」表头 + 场景行列表 + 空态（不变）
```

## 2. 区块明细

### 2.1 品牌头部（替换原 header + 偏好胶囊）

- 结构与首页 `index.vue` header 一致：`header-top` 左品牌右按钮
- 品牌区：`logo-v10-1.jpg`（56rpx 圆角）+ 「声栖」（26rpx 粗体）+ 问候行
- 问候行：文案「今晚想听什么？」（24rpx 次级色），末尾内嵌偏好胶囊（`SIMULATED_PREFS` 经 `prefLabels` 映射的「助眠」「自然」标签，胶囊用 `--app-primary-soft` 背景 + `--app-primary` 文字 + 前缀小图标 `flame`）
- 右侧操作按钮：**新建场景**（`mixer` → `createScene`，复用现有函数）、**主题**（`palette` → `navigateTo /pages/theme/theme`），样式复用首页 `header-btn app-card`（88rpx 圆形）
- 原独立 `.pref-bar` 区块删除，数据与逻辑（`prefLabels` computed）保留并入头部

### 2.2 卡片 A「继续聆听」

- 容器：`.group-card app-card`（圆角 28rpx + 发丝描边 + 柔和投影，内边距 24rpx）
- 卡片头：「为你推荐」—— iOS 分组表头样式（图标 `flame` + 24rpx 灰色小字），复用现有 `.section-title` 基础
- 内容：现有 `rec-scroll` / `rec-card` 横滑结构原样保留（数据 `recommended`、角标「常听偏好」、点击 `openDetail`、`:active` 按压不变）
- 分隔线：`.divider` 发丝线（内缩，对齐卡片内边距）
- 子表头：「最近播放」+ 横滑 `recent-card`（数据 `recentItems`、时间标签 `recentTimeLabel` 不变）；`recentItems.length === 0` 时分隔线与整个子块隐藏

### 2.3 卡片 B「场景精选」

- 容器：`.group-card app-card`
- 顶部：分类分段控件——现有 `tag-filter` / `tag-item` 原样内嵌（保留图标+文字胶囊、`active` 态、`:active` 按压、`pendingSceneCategory` 直达逻辑）
- 表头行：「精选场景」+ 右侧「查看全部」入口（`goAllScenes`，保留 `more-btn` 样式）
- 内容：现有 `featured-grid` 双列网格 ×3（`getCategoryScenes(activeTag, 3)`、`SceneCard` grid、`box-sizing: border-box` 不变）

### 2.4 卡片 C「我的场景」

- 容器：`.group-card app-card`
- 表头行：「我的场景」+ 右侧「新建」按钮（`new-btn app-card`，`mixer` 图标 + 文字，`createScene` 不变）
- 内容：现有 `SceneCard` 行列表（`editScene` / `shareScene` / `playMyScene` 不变）+ 空态（`empty-scene` 保留）

## 3. 交互与数据（全部不变）

- 推荐/最近/精选数据源与算法不变（`getRecommended` / `getRecent` / `getCategoryScenes` / `SIMULATED_PREFS`）
- 播放链路不变：`applyScene(scene)` + toast + `switchTab` 首页
- 点击进详情（`openDetail`）、查看全部（`goAllScenes`）、新建/编辑/分享/我的场景播放行为不变
- `onShow` 刷新（`recentItems` / `recommended` / `pendingSceneCategory`）不变

## 4. 验证

- `npm run type-check`（vue-tsc --noEmit）零错误
- H5 手测：
  1. 顶部：品牌头部 + 问候行 + 偏好胶囊显示正常，无大片留白
  2. 三张分组卡片边界清晰，卡片间留白均匀
  3. 卡片 A：推荐横滑 + 最近播放横滑；清空最近记录后该子块隐藏
  4. 卡片 B：分类分段切换联动网格；查看全部进列表页
  5. 卡片 C：新建/编辑/分享/播放行为不变
  6. 主题切换后卡片颜色随 `--app-*` 变量变化
