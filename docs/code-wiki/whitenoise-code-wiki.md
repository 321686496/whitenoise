# 声栖（Whitenoise）代码 Wiki

> 文档版本：v1.0
> 生成日期：2026-09-07
> 适用范围：当前仓库快照（`prototype/` 下的 uni-app 原型代码）

***

## 目录

1. [项目概览](#1-项目概览)
2. [技术栈](#2-技术栈)
3. [项目整体架构](#3-项目整体架构)
4. [模块职责说明](#4-模块职责说明)
5. [关键类与函数说明](#5-关键类与函数说明)
6. [依赖关系](#6-依赖关系)
7. [项目运行方式](#7-项目运行方式)
8. [与设计文档的差异与演进](#8-与设计文档的差异与演进)
9. [常见问题与注意事项](#9-常见问题与注意事项)

***

## 1. 项目概览

**声栖** 是一款以「多声音混合调音」为核心、「多主题视觉切换」为差异的白噪音助眠 App。产品定位为"混音自由 + 审美自由 + 分享裂变"三合一，目标覆盖 iOS / HarmonyOS / Android 三端（详见 PRD v2.0）。

**当前仓库状态**：可运行的实现位于 [`prototype/`](file:///d:/app/projects/whitenoise/prototype)，是一个基于 **uni-app（Vue 3 + Vite + TypeScript）** 的**高保真交互原型**，用于验证产品功能与视觉设计（iOS 设计语言）。PRD / 设计文档中描述的目标技术栈为 Flutter 一套代码多端，与当前原型实现不同（详见 [第 8 节](#8-与设计文档的差异与演进)）。

### 1.1 仓库顶层结构

| 路径                                                                                                                                                                   | 说明                                                      |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------- |
| [`docs/superpowers/specs/`](file:///d:/app/projects/whitenoise/docs/superpowers/specs)                                                                               | 产品需求文档（PRD v2.0）与设计文档                                   |
| [`prototype/`](file:///d:/app/projects/whitenoise/prototype)                                                                                                         | 可运行的 uni-app 原型项目（**核心代码**）                             |
| [`.agent/`](file:///d:/app/projects/whitenoise/.agent)、[`.agents/`](file:///d:/app/projects/whitenoise/.agents)、[`.trae/`](file:///d:/app/projects/whitenoise/.trae) | AI 编程助手技能（skills）、项目规则（rules）与修复规格（specs）配置目录，**非业务代码** |

> 注：`.trae/specs/fix-decode-bounds-compile-error/` 中的内容对应另一个 Flutter 项目（lumira\_app\_flutter），与本仓库原型代码无关。

### 1.2 原型功能范围（已实现）

- 首页：声音分类浏览、混音面板（最多 6 路、独立音量/静音/移除）、定时器、保存场景、随机推荐

- 场景页：官方预设 / 我的场景，应用 / 编辑 / 分享场景

- 声音库：30+ 声音数据，搜索 + 分类筛选 + 详情底部弹窗

- 发现页：今日推荐 Banner、推荐场景、声音精选、场景故事

- 我的页：用户卡片、统计条、8 项功能入口、最近成就

- 功能子页：主题设置、成就墙、签到、使用数据、收藏、播放历史、邀请好友、设置、引导页、场景详情

- **主题系统**：6 套配色 × 3 种 UI 风格，运行时 CSS 变量注入，即时切换并持久化

***

## 2. 技术栈

| 分类    | 技术              | 版本                     | 说明                                                                                        |
| ----- | --------------- | ---------------------- | ----------------------------------------------------------------------------------------- |
| 跨端框架  | uni-app（DCloud） | 3.0.0-5020420260813003 | 一套代码编译到 H5 / 微信小程序 / HarmonyOS / App 等多端                                                  |
| UI 框架 | Vue             | ^3.4.21                | Composition API + `<script setup>`                                                        |
| 构建工具  | Vite            | 5.2.8                  | 配合 `@dcloudio/vite-plugin-uni`                                                            |
| 语言    | TypeScript      | ^4.9.4                 | 全量 TS 类型标注                                                                                |
| 样式    | Sass            | ^1.102.0               | 全局 SCSS 变量（`uni.scss`）+ scoped 样式                                                         |
| 包管理   | pnpm            | 11.16.0                | 见 [pnpm-workspace.yaml](file:///d:/app/projects/whitenoise/prototype/pnpm-workspace.yaml) |
| 国际化   | vue-i18n        | ^9.1.9                 | 已安装，原型中暂未实际使用                                                                             |

***

## 3. 项目整体架构

### 3.1 分层架构

原型采用**页面（Page）→ 组件（Component）→ 数据层（Data）/ 主题层（Theme）** 的三层结构，与 iOS 设计语言全局样式配合。

```
┌────────────────────────────────────────────────────────────┐
│ 页面层 pages/  （15 个页面，含 4 个 Tab）                     │
│   index · scene · discover · mine（tabBar）                 │
│   library · theme · achievement · invite · settings ·      │
│   checkin · stats · favorites · history · onboarding ·     │
│   scene-detail                                             │
├────────────────────────────────────────────────────────────┤
│ 组件层 components/（5 个通用组件）                           │
│   Icon（SVG 图标）· SoundCard · MixTrack · SceneCard · PlayBar│
├────────────────────────────────────────────────────────────┤
│ 数据层 data/sounds.ts   声音数据源（30 声音/场景/推荐）       │
│ 主题层 theme/index.ts   配色 × UI 风格 → 运行时 CSS 变量      │
├────────────────────────────────────────────────────────────┤
│ 全局基建：App.vue 全局样式 · uni.scss · pages.json · main.ts │
└────────────────────────────────────────────────────────────┘
```

**关键设计：CSS 变量驱动的主题系统。** 全站样式不写死颜色，而是消费 `var(--app-*)` 变量（如 `--app-primary`、`--app-card-bg`）；主题引擎 `setTheme()` 将配色与风格计算出的变量注入 `<html>` 根节点，实现**全局即时换肤、无需重新编译**。

### 3.2 目录结构（`prototype/src`）

```
src/
├── main.ts                  # 应用入口（createSSRApp）
├── App.vue                  # 根组件：生命周期 + 全局 iOS 设计语言样式
├── pages.json               # 路由注册（15 页面）+ tabBar（4 Tab）
├── manifest.json            # 应用清单（名称/权限/平台配置）
├── uni.scss                 # 全局 SCSS 变量（莫兰迪森林绿）
├── env.d.ts                 # Vite/类型声明
├── shime-uni.d.ts           # uni-app 类型补充
├── theme/
│   └── index.ts             # ★ 主题引擎（6 配色 × 3 风格）
├── data/
│   └── sounds.ts            # ★ 声音数据源（30 声音 + 场景 + 精选）
├── components/
│   ├── Icon.vue             # SVG 图标库（30+ 图标）
│   ├── SoundCard.vue        # 声音卡片
│   ├── MixTrack.vue         # 混音音轨（音量/静音/删除）
│   ├── SceneCard.vue        # 场景卡片
│   └── PlayBar.vue          # 底部播放栏（含定时器面板）
├── static/                  # 静态资源（logo、tab 图标、启动图）
└── pages/
    ├── index/index.vue      # 首页：声音库 + 混音 + 播放
    ├── scene/scene.vue      # 场景管理（Tab）
    ├── discover/discover.vue# 发现（Tab）
    ├── mine/mine.vue        # 我的（Tab）
    ├── library/library.vue  # 声音库（搜索/筛选/详情）
    ├── theme/theme.vue      # 主题与风格
    ├── achievement/achievement.vue # 成就墙
    ├── checkin/checkin.vue  # 每日签到
    ├── stats/stats.vue      # 使用数据
    ├── favorites/favorites.vue # 我的收藏
    ├── history/history.vue  # 播放历史
    ├── invite/invite.vue    # 邀请好友
    ├── settings/settings.vue# 设置
    ├── onboarding/onboarding.vue # 引导页
    └── scene-detail/scene-detail.vue # 场景详情
```

### 3.3 数据流

1. **静态数据**：`data/sounds.ts` 集中管理声音/场景/推荐数据，被 `library`、`discover` 页面直接导入复用。
2. **页面状态**：绝大多数页面（收藏、历史、签到、成就、设置、统计等）使用**页面内硬编码 ref** 模拟数据，仅做 UI 演示，**不持久化**。
3. **持久化触点（当前唯一）**：主题引擎 `initTheme()` / `setTheme()` 通过 `uni.getStorageSync/setStorageSync('shengqi-theme')` 保存与恢复主题配置（见 [theme/index.ts](file:///d:/app/projects/whitenoise/prototype/src/theme/index.ts#L232-L255)）。
4. **导航**：Tab 间用 `uni.switchTab`，子页面用 `uni.navigateTo`（路由表见 [第 6.3 节](#63-页面路由与导航关系)）。

***

## 4. 模块职责说明

### 4.1 入口与全局配置

#### `src/main.ts` — 应用入口

- 调用 `createSSRApp(App)` 创建应用实例，供 uni-app 各端（H5 SSR/小程序/App）启动调用。

- 仅作启动装配，无其他逻辑。

#### `src/App.vue` — 根组件与全局样式

- **生命周期**：[onLaunch 中调用](file:///d:/app/projects/whitenoise/prototype/src/App.vue#L5-L8) [`initTheme()`](file:///d:/app/projects/whitenoise/prototype/src/App.vue#L5-L8) 完成主题初始化。

- **全局 iOS 设计语言**：定义了全站复用的样式类：

  - `.page-bg`：顶部柔和渐变氛围层

  - `.page-container`：页面容器（安全区 + 左右留白 + 页面进入动效）

  - `.btn-primary` / `.btn-outline`：iOS 填充/描边按钮

  - `.app-card`：iOS 卡片（圆角 + 发丝描边 + 模糊投影）

  - `.page-title` / `.page-subtitle` / `.section-title`、`.divider`、`.safe-bottom`

- **tabBar 主题跟随**：通过选择器强制 H5 tabBar 背景色/文字颜色跟随 CSS 变量。

#### `src/pages.json` — 路由与 tabBar

- 注册 15 个页面，绝大多数使用 `navigationStyle: custom`（自定义导航）。

- `tabBar` 4 个 Tab：首页、场景、发现、我的（图标位于 `static/tab-*.jpg/svg`）。

#### `src/manifest.json` — 应用清单

- 应用名「声栖」、版本 1.0.0（versionCode 100）、`vueVersion: "3"`。

- 平台配置：app-plus（Android 权限）、mp-weixin 等各端 `usingComponents`。

- `uniStatistics.enable: false`（关闭统计）。

#### `src/uni.scss` — 全局 SCSS 变量

- uni-app 官方变量（`$uni-color-*`, `$uni-text-color-*`, `$uni-bg-color-*`, `$uni-font-size-*` 等）与 App 专属莫兰迪变量（`$app-primary: #3D6B5E` 等）。

- **注意**：页面样式主要消费运行时 CSS 变量 `var(--app-*)`，SCSS 变量仅作为兜底默认值（如 `var(--app-primary, $app-primary)`）。

#### `tsconfig.json` / `vite.config.ts` / `env.d.ts`

- `tsconfig.json`：路径别名 `@/* → ./src/*`，类型包含 `@dcloudio/types`。

- `vite.config.ts`：仅注册 `uni()` 插件。

- `env.d.ts`：`.vue` 模块类型声明 + Vite 客户端类型。

### 4.2 主题引擎 [theme/index.ts](file:///d:/app/projects/whitenoise/prototype/src/theme/index.ts)（核心模块）

| 成员                                          | 说明                                                                                         |
| ------------------------------------------- | ------------------------------------------------------------------------------------------ |
| `SchemeKey`                                 | 配色键：`morandi`（莫兰迪）/ `ocean`（深海）/ `forest`（森林）/ `sunset`（日落）/ `lavender`（薰衣草）/ `mono`（极简黑白） |
| `UiMode`                                    | UI 风格键：`flat`（扁平化）/ `glass`（玻璃拟态）/ `neu`（新拟态）                                              |
| `SchemeTokens`                              | 每套配色的基础色板（primary/accent/bg/text/glass/neu 等 20 个 token）                                   |
| `SCHEME_KEYS` / `UI_MODES`                  | 配色与风格的导出数组                                                                                 |
| `schemeMeta(k)`                             | 获取配色元信息（名称/描述/色板样本）                                                                        |
| `schemePrimary(k)` / `schemePrimaryDark(k)` | 获取主色 HEX，供原生组件（如 switch）绑定                                                                 |
| `UIMODE_META`                               | 风格元信息（扁平化/玻璃拟态/新拟态的描述）                                                                     |
| `buildTokens(scheme, ui)`                   | **核心计算函数**：由配色 + 风格计算最终 CSS 变量表（约 20 个 `--app-*` 变量），rpx 换算为 px 并区分卡片/输入框/阴影/模糊等容器行为       |
| `applyTheme(scheme, ui)`                    | 将变量注入 `document.documentElement`，同时写入 `data-scheme` / `data-ui` 属性                         |
| `themeState`                                | `reactive` 响应式对象（scheme/ui），供组件读取当前主题                                                      |
| `initTheme()`                               | 启动时读取本地存储恢复主题（默认莫兰迪 + 扁平化）并应用                                                              |
| `setTheme(scheme, ui)`                      | 更新状态 → 应用 → 持久化到 `uni.setStorageSync('shengqi-theme')`                                     |

**风格差异实现要点**（`buildTokens` 内）：

- `flat`：白底卡片 + 描边 + 轻阴影。

- `glass`：半透明卡片（`glassCard`）+ 白描边 + `backdrop-filter: blur(22px)`。

- `neu`：同背景色卡片 + 双阴影（`neuA` 暗影 + `neuB` 亮影），无边框。

### 4.3 数据层 [data/sounds.ts](file:///d:/app/projects/whitenoise/prototype/src/data/sounds.ts)

| 成员                  | 说明                                                                                                           |
| ------------------- | ------------------------------------------------------------------------------------------------------------ |
| `Sound`             | 声音实体：id/name/type/category/iconName/color/gradient/duration/sampleRate/quality/source/desc/scenes/loopLength |
| `FeaturedScene`     | 推荐场景：id/name/desc/iconName/gradient/tags/soundIds（声音组合）/ratio（各声比重）/playCount/duration                       |
| `FeaturedSound`     | 精选声音：`Sound` + `hot` 热度值                                                                                     |
| `sounds`            | **30 个内置声音**，覆盖 4 类：合成白噪音（8）、自然音（12）、城市音（6）、环境音（4）                                                           |
| `soundCategories`   | 5 个分类 key：all / synthetic / nature / urban / ambient                                                         |
| `featuredScenes`    | 8 个推荐场景（深度睡眠、专注白噪、自然放松、城市午后、雨夜入眠、森林冥想、海边日落、咖啡时光）                                                             |
| `featuredSounds`    | 8 个精选声音（按热度 98\~85）                                                                                          |
| `findSound(id)`（内部） | 按 id 查声音，未找到时抛错                                                                                              |

> `iconName` 必须与 [Icon.vue](file:///d:/app/projects/whitenoise/prototype/src/components/Icon.vue) 中已定义的图标名保持一致。

### 4.4 组件层（`src/components/`）

#### [Icon.vue](file:///d:/app/projects/whitenoise/prototype/src/components/Icon.vue) — SVG 图标库

- Props：`name`（图标名）/ `size`（默认 24）/ `color`（默认 currentColor）。

- 内置 30+ 线性图标：`wave`、`white-noise`、`pink-noise`、`brown-noise`、`red-noise`、`rain`、`wave-ocean`、`forest`、`stream`、`fire`、`coffee`、`train`、`fan`、`play`、`pause`、`timer`、`save`、`palette`、`trophy`、`settings`、`share`、`user`、`edit`、`mute`、`volume`、`close`、`chevron-right`、`gift`、`moon`、`flame`、`mixer`、`clock`、`copy`、`lock`、`check`、`mountain`、`bird`。

- 未知名称回退为空心圆点。

#### [SoundCard.vue](file:///d:/app/projects/whitenoise/prototype/src/components/SoundCard.vue) — 声音卡片

- Props：`name` / `type` / `iconName` / `color` / `isActive`。

- Emits：`tap`。

- 激活态：主色描边 + 柔和底色 + 右上角对勾角标。

#### [MixTrack.vue](file:///d:/app/projects/whitenoise/prototype/src/components/MixTrack.vue) — 混音音轨行

- Props：`name` / `iconName` / `color` / `volume` / `isMuted`。

- Emits：`volumeChange` / `mute` / `remove`。

- UI：磁贴图标 + 音轨名 + 音量百分比 + 音量滑杆（视觉） + 静音/删除按钮。

- 注：原型中 `onSlide` 仅做占位，无真实音量逻辑。

#### [SceneCard.vue](file:///d:/app/projects/whitenoise/prototype/src/components/SceneCard.vue) — 场景卡片

- Props：`name` / `soundCount` / `soundIcons` / `bgColor` / `isPreset`。

- Emits：`tap` / `share` / `play`。

- 预设场景显示「预设」徽标；非预设显示分享按钮。

#### [PlayBar.vue](file:///d:/app/projects/whitenoise/prototype/src/components/PlayBar.vue) — 底部播放栏

- Props：`isPlaying` / `currentScene` / `timerRemaining`。

- Emits：`playTap` / `timerTap` / `saveTap` / `sceneTap`。

- 内部自管理状态：`isLocked`（锁定播放）、`showTimerPanel`、`timerMinutes`、`fadeMinutes`（渐弱时长 1/2/3/5 分钟）。

- 内置**睡眠定时面板**：预设 15/30/45/60/90 分钟，`timerDisplay` 计算显示格式（`h` 时 / `m` 分）。

- 播放中动画：四根声浪柱 CSS 循环动画。

### 4.5 页面层（`src/pages/`）

#### Tab 页

| 页面 | 文件                                                                                                    | 职责与要点                                                                                                                                                                                                                                        |
| -- | ----------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 首页 | [index/index.vue](file:///d:/app/projects/whitenoise/prototype/src/pages/index/index.vue)             | 核心页。问候语（按时间段 computed）、最近使用横向列表、声音库（分类 Tab：全部/合成/自然/城市 + SoundCard 网格）、**混音面板**（添加/移除/静音音轨，上限 `maxTracks=6`，空态插画）、为你推荐（随机按钮）、PlayBar 播放栏、定时器弹窗（5-90 分钟预设 + 自定义=20 分钟）、保存场景弹窗（名称 ≤20 字符）。导航到 theme / achievement / history / library / scene。 |
| 场景 | [scene/scene.vue](file:///d:/app/projects/whitenoise/prototype/src/pages/scene/scene.vue)             | 标签筛选（助眠/专注/放松/自然）+ 官方预设 4 套（不可删）+ 我的场景 2 套（应用/编辑/分享）。`applyScene` 应用后 `switchTab` 回首页。                                                                                                                                                       |
| 发现 | [discover/discover.vue](file:///d:/app/projects/whitenoise/prototype/src/pages/discover/discover.vue) | 今日推荐 Banner（取 `featuredScenes[0]`，computed 映射声音名）、推荐场景两列网格、声音精选横向滚动、场景故事卡片。唯一大量使用 `@/data/sounds.ts` 的页面。`goDetail` 跳 `scene-detail?sceneId=`。                                                                                               |
| 我的 | [mine/mine.vue](file:///d:/app/projects/whitenoise/prototype/src/pages/mine/mine.vue)                 | 用户卡片、四格统计（累计播放/连续天数/场景数/成就，硬编码）、8 项功能菜单（签到/数据/收藏/历史/成就/邀请/主题/设置）、最近成就 chips。`currentThemeLabel` 经 computed 读取 `themeState` 显示当前主题名。                                                                                                          |

#### 子页面（功能页）

| 页面    | 文件                                                                                                                    | 职责与要点                                                                                                                                           |
| ----- | --------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| 声音库   | [library/library.vue](file:///d:/app/projects/whitenoise/prototype/src/pages/library/library.vue)                     | 搜索（名称/描述/类型） + `soundCategories` 分类筛选 + 列表；点击弹出**底部详情弹窗**（时长/采样率/音质/循环片段/来源 + 适用场景标签 + 播放/加入混音按钮）。数据来自 `data/sounds.ts`。                        |
| 主题与风格 | [theme/theme.vue](file:///d:/app/projects/whitenoise/prototype/src/pages/theme/theme.vue)                             | 预览卡 + 配色网格（`SCHEME_KEYS` 映射）+ UI 风格列表（`UI_MODES` 映射）；`selectScheme`/`selectMode` 调 `setTheme()` 即时生效并持久化。                                       |
| 成就墙   | [achievement/achievement.vue](file:///d:/app/projects/whitenoise/prototype/src/pages/achievement/achievement.vue)     | 达成概览（解锁 3/全部 8/38%）、最近获得卡片、全部成就列表（未解锁置灰带锁）。静态数据。                                                                                                |
| 每日签到  | [checkin/checkin.vue](file:///d:/app/projects/whitenoise/prototype/src/pages/checkin/checkin.vue)                     | 连续签到主卡（5 天）、本周日历行、圆形签到按钮（动画）、奖励列表。`handleCheckin` 翻转本地状态。                                                                                       |
| 使用数据  | [stats/stats.vue](file:///d:/app/projects/whitenoise/prototype/src/pages/stats/stats.vue)                             | 概览、7 天柱状图（computed 换算百分比柱高）、最爱场景 Top3（金银铜）、成就三格。                                                                                                |
| 我的收藏  | [favorites/favorites.vue](file:///d:/app/projects/whitenoise/prototype/src/pages/favorites/favorites.vue)             | 收藏场景/收藏声音分类切换；`removeScene` 本地 splice 删除。                                                                                                       |
| 播放历史  | [history/history.vue](file:///d:/app/projects/whitenoise/prototype/src/pages/history/history.vue)                     | 按今天/昨天/日期分组的记录卡片；`clearHistory` 用 `uni.showModal` 确认后清空（内存级）。                                                                                   |
| 邀请好友  | [invite/invite.vue](file:///d:/app/projects/whitenoise/prototype/src/pages/invite/invite.vue)                         | 邀请码 WN2024（复制/分享仅 toast）、2/10 进度条、三档权益、邀请记录。                                                                                                    |
| 设置    | [settings/settings.vue](file:///d:/app/projects/whitenoise/prototype/src/pages/settings/settings.vue)                 | 播放设置（自动恢复/淡入淡出时长/轨数上限 4/6/8）、提醒设置（助眠提醒 + 时间选择 ActionSheet 21:00-23:00）、关于（主题/版本/清缓存）。switch 颜色随主题响应式。                                           |
| 引导页   | [onboarding/onboarding.vue](file:///d:/app/projects/whitenoise/prototype/src/pages/onboarding/onboarding.vue)         | 3 屏 swiper（欢迎/自由混音/安心入眠）+ 跳过/下一步 + 开始体验（`switchTab` 首页）。未写入"已看过"标记，每次启动都会进入。                                                                    |
| 场景详情  | [scene-detail/scene-detail.vue](file:///d:/app/projects/whitenoise/prototype/src/pages/scene-detail/scene-detail.vue) | 场景封面、故事卡、声音配方进度条（雨声 60%/雷声 25%/白噪音 15%）、三个预设方案（轻度/标准/深度）、播放 + 收藏/分享。**注意**：`scene` 为页面内硬编码对象，未读取路由 `sceneId` 参数（discover 以 `?sceneId=` 跳入但未消费）。 |

***

## 5. 关键类与函数说明

> 原型为 Vue `<script setup>` 组件式写法，无传统意义上的"类"，以下是关键类型（TypeScript interface）与函数（composable/computed/handler）清单。

### 5.1 主题引擎关键函数（[theme/index.ts](file:///d:/app/projects/whitenoise/prototype/src/theme/index.ts)）

| 函数                                                   | 签名                                                          | 行为说明                                                                          |
| ---------------------------------------------------- | ----------------------------------------------------------- | ----------------------------------------------------------------------------- |
| `buildTokens`                                        | `(scheme: SchemeKey, ui: UiMode) => Record<string, string>` | 计算约 20 个 `--app-*` CSS 变量；内部按 ui 分支生成卡片/输入框/阴影/模糊 token；`rpx()` 将 rpx 换算为 px  |
| `applyTheme`                                         | `(scheme, ui) => void`                                      | 批量 `el.style.setProperty` 注入变量；设置 `data-scheme`、`data-ui`；H5 无 document 时静默返回 |
| `initTheme`                                          | `() => void`                                                | 从 `uni.getStorageSync('shengqi-theme')` 恢复（校验合法性），默认 `morandi + flat`         |
| `setTheme`                                           | `(scheme, ui) => void`                                      | 更新 `themeState` → `applyTheme` → `uni.setStorageSync` 持久化                     |
| `schemeMeta` / `schemePrimary` / `schemePrimaryDark` | `(k) => ...`                                                | 供页面读取 meta 与主色（如 settings 的 switch 颜色）                                        |

### 5.2 数据层（[data/sounds.ts](file:///d:/app/projects/whitenoise/prototype/src/data/sounds.ts)）

| 导出                                          | 类型/值                  | 说明                                                   |
| ------------------------------------------- | --------------------- | ---------------------------------------------------- |
| `interface Sound`                           | 14 字段实体               | 声音唯一标识 `id` 与 `iconName` 的稳定规程见第 4.3 节               |
| `interface FeaturedScene` / `FeaturedSound` | 组合类型                  | 推荐场景含 `soundIds + ratio`（多声配比），精选声音追加 `hot`          |
| `sounds`                                    | `Sound[30]`           | 分类：synthetic(8) / nature(12) / urban(6) / ambient(4) |
| `soundCategories`                           | `{key,label,icon}[5]` | all + 4 类筛选                                          |
| `featuredScenes`                            | `FeaturedScene[8]`    | 含配比与播放量                                              |
| `featuredSounds`                            | `FeaturedSound[8]`    | 热度排序 98→85                                           |
| `findSound`（未导出）                            | `(id) => Sound`       | 内部查找，抛错保护                                            |

### 5.3 首页核心逻辑函数（[index.vue](file:///d:/app/projects/whitenoise/prototype/src/pages/index/index.vue)）

| 函数                                                  | 行为                                                                                  |
| --------------------------------------------------- | ----------------------------------------------------------------------------------- |
| `greetingText`（computed）                            | 按时段返回问候语（早/午/下午/晚上/深夜）                                                              |
| `filteredSounds`（computed）                          | 按 `activeCategory` 过滤本地声音数组                                                         |
| `addSound(sound)`                                   | 去重；达上限 6 路时 toast 提示；加入音轨并自动置为播放中                                                   |
| `removeSound(id)`                                   | 移除音轨；音轨归零时停止播放态                                                                     |
| `toggleMute(id)`                                    | 切换音轨静音状态                                                                            |
| `togglePlay()`                                      | 无音轨时提示"请先添加声音"；否则切换播放态（原型无真实音频）                                                     |
| `setTimer(value)`                                   | 选择定时时长，`-1`（自定义）回退为 20 分钟；更新 `timerRemaining`；`timerDisplay`（computed）格式化 `剩余 m:ss` |
| `saveScene()`                                       | 校验名称非空 → 设置 `currentScene` → toast 保存成功                                             |
| `goScene/goTheme/goAchievement/goHistory/goLibrary` | 导航函数（`switchTab` / `navigateTo`）                                                    |

### 5.4 组件事件契约

| 组件        | Props                                           | Emits                                |
| --------- | ----------------------------------------------- | ------------------------------------ |
| Icon      | name, size=24, color='currentColor'             | —                                    |
| SoundCard | name, type, iconName, color, isActive           | tap                                  |
| MixTrack  | name, iconName, color, volume, isMuted          | volumeChange(value), mute, remove    |
| SceneCard | name, soundCount, soundIcons, bgColor, isPreset | tap, share, play                     |
| PlayBar   | isPlaying, currentScene, timerRemaining         | playTap, timerTap, saveTap, sceneTap |

***

## 6. 依赖关系

### 6.1 第三方依赖（来自 [package.json](file:///d:/app/projects/whitenoise/prototype/package.json)）

**dependencies（运行时）：**

| 包                                                                                                                                                                                 | 版本                     | 用途                                          |
| --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------- | ------------------------------------------- |
| `@dcloudio/uni-app`                                                                                                                                                               | 3.0.0-5020420260813003 | uni-app 核心运行时框架                             |
| `@dcloudio/uni-components`                                                                                                                                                        | 3.0.0-5020420260813003 | 内置基础组件库（view/text/scroll-view…）             |
| `@dcloudio/uni-h5`                                                                                                                                                                | 3.0.0-5020420260813003 | H5（浏览器）平台编译支持                               |
| `@dcloudio/uni-app-plus`                                                                                                                                                          | 3.0.0-5020420260813003 | App 端（5+ Runtime）编译支持                       |
| `@dcloudio/uni-app-harmony`                                                                                                                                                       | 3.0.0-5020420260813003 | HarmonyOS 端编译支持                             |
| `@dcloudio/uni-mp-weixin` / `uni-mp-alipay` / `uni-mp-baidu` / `uni-mp-toutiao` / `uni-mp-qq` / `uni-mp-lark` / `uni-mp-jd` / `uni-mp-kuaishou` / `uni-mp-xhs` / `uni-mp-harmony` | 3.0.0-5020420260813003 | 各小程序平台编译支持（微信/支付宝/百度/抖音/QQ/飞书/京东/快手/小红书/鸿蒙） |
| `@dcloudio/uni-quickapp-webview`                                                                                                                                                  | 3.0.0-5020420260813003 | 快应用（webview）平台编译支持                          |
| `vue`                                                                                                                                                                             | ^3.4.21                | Vue 3 核心框架                                  |
| `vue-i18n`                                                                                                                                                                        | ^9.1.9                 | 国际化插件（已安装，原型中未实际使用）                         |

**devDependencies（开发与构建期）：**

| 包                                             | 版本                     | 用途                                                                                                       |
| --------------------------------------------- | ---------------------- | -------------------------------------------------------------------------------------------------------- |
| `@dcloudio/vite-plugin-uni`                   | 3.0.0-5020420260813003 | ★ 构建核心：Vite 插件，统一各端编译入口（见 [vite.config.ts](file:///d:/app/projects/whitenoise/prototype/vite.config.ts)） |
| `@dcloudio/uni-cli-shared`                    | 3.0.0-5020420260813003 | uni 命令行工具共享库                                                                                             |
| `@dcloudio/uni-automator` / `uni-stacktracey` | 3.0.0-5020420260813003 | 自动化测试 / 错误堆栈还原工具                                                                                         |
| `@dcloudio/types`                             | ^3.4.8                 | uni-app 全局 API（`uni.*`）的 TypeScript 类型声明                                                                 |
| `typescript` + `vue-tsc`                      | ^4.9.4 / ^1.0.24       | 类型检查（`pnpm type-check` = `vue-tsc --noEmit`）                                                             |
| `vite`                                        | 5.2.8                  | 构建/开发服务器                                                                                                 |
| `sass`                                        | ^1.102.0               | SCSS 编译（`uni.scss` 与各页面 scoped 样式）                                                                       |
| `@vue/runtime-core` / `@vue/tsconfig`         | ^3.4.21 / ^0.1.3       | Vue 类型与 TS 配置支持                                                                                          |

> 包管理器约束：`packageManager: pnpm@11.16.0`；`pnpm.onlyBuiltDependencies` 允许构建脚本的包仅 `esbuild` / `core-js` / `core-js-pure`。

### 6.2 依赖关系图

```
┌────────────────────────────────────────────────────────────┐
│ 业务代码 src/                                              │
│  页面 → 组件 → data/sounds.ts · theme/index.ts            │
│  ├─ 依赖 vue（Composition API）                            │
│  ├─ 依赖 @dcloudio/uni-app 运行时                          │
│  └─ 调用全局 uni.* API（navigateTo/switchTab/storage…）    │
└──────────────────────────┬─────────────────────────────────┘
                           │
┌──────────────────────────▼─────────────────────────────────┐
│ 构建层（dev:*/build:* 脚本）                               │
│  ├─ vite 5.2.8 + @dcloudio/vite-plugin-uni                 │
│  ├─ sass（stylus 样式编译）                                │
│  ├─ typescript + vue-tsc（类型检查，可选 type-check）      │
│  └─ 按目标平台分包（uni-h5 / uni-mp-weixin / uni-app-plus…）│
└──────────────────────────┬─────────────────────────────────┘
                           │
┌──────────────────────────▼─────────────────────────────────┐
│ 产物层                                                     │
│  ├─ H5        → dist/build/h5（浏览器直接访问）            │
│  ├─ 微信小程序 → dist/build/mp-weixin（导入微信开发者工具） │
│  ├─ 其他小程序 → dist/build/mp-*                          │
│  └─ App        → 经 HBuilderX / 云打包生成 apk / ipa       │
└────────────────────────────────────────────────────────────┘
```

模块间引用关系（自顶向下）：

```
pages/*.vue ──props/events──> components/*.vue
pages/index · pages/library · pages/discover ──import──> data/sounds.ts
pages/theme · pages/mine · pages/settings · App.vue ──import──> theme/index.ts
全局 ──uni.scss 变量 + App.vue 全局样式（--app-* 由主题引擎注入）
```

### 6.3 页面路由与导航关系（[pages.json](file:///d:/app/projects/whitenoise/prototype/src/pages.json)）

```
tabBar（4 个主页面，switchTab 切换，常驻底部）
├── pages/index/index        首页（混音 + 播放）
├── pages/scene/scene        场景管理
├── pages/discover/discover  发现
└── pages/mine/mine          我的

navigateTo（栈式跳转，返回按钮返回）
├── index ───────→ theme · achievement · history · library · scene
├── mine ────────→ checkin · stats · favorites · history · achievement · invite · theme · settings
├── discover ────→ scene-detail（?sceneId=，注意页面暂未消费该参数）
└── onboarding ──(switchTab)─→ index（引导页，原型中每次启动都会出现，无"已看过"标记）
```

> 所有非 tabBar 页面均需在 `pages.json` 的 `pages` 数组中注册（当前 15 个页面）；tabBar 图标位于 `src/static/tabbar/`。

***

## 7. 项目运行方式

### 7.1 环境要求

| 工具      | 版本      | 说明                                                            |
| ------- | ------- | ------------------------------------------------------------- |
| Node.js | ≥ 18    | Vite 5 的运行要求                                                  |
| pnpm    | 11.16.0 | 由 package.json `packageManager` 锁定，可用 `corepack enable` 后自动匹配 |

### 7.2 安装依赖

```bash
cd prototype
pnpm install
```

### 7.3 开发运行（推荐先用 H5 验证）

```bash
pnpm dev:h5          # H5 开发模式，默认 http://localhost:5173
pnpm dev:mp-weixin   # 微信小程序模式，产物在 dist/dev/mp-weixin，用微信开发者工具导入
pnpm dev:mp-harmony  # HarmonyOS 模式
pnpm dev:mp-alipay   # 支付宝小程序模式（其余端见 package.json scripts）
```

### 7.4 生产构建

```bash
pnpm build:h5          # H5 产物 → dist/build/h5
pnpm build:mp-weixin   # 微信小程序产物 → dist/build/mp-weixin
pnpm build:custom      # 自定义平台（-p 后跟平台名）
```

### 7.5 类型检查

```bash
pnpm type-check        # vue-tsc --noEmit
```

### 7.6 运行后验证清单

1. `pnpm dev:h5` 启动无编译错误，浏览器打开首页。
2. 首页混音面板可添加音轨（上限 6 路）、静音、移除、设置定时器。
3. 「设置 → 主题」切换配色与 UI 风格，全站即时换肤；刷新页面后主题保持不变（唯一持久化点）。
4. Scene / Discover / Mine 各 Tab 可正常切换，子页面可进入返回。
5. `pnpm type-check` 通过。

> 注意：原型无真实音频与后端接口，所有数据为内存级 mock（主题设置除外，持久化于 `uni` storage 的 `shengqi-theme` 键）。

***

## 8. 与设计文档的差异与演进

### 8.1 当前差异

| 维度   | PRD v2.0 / 设计文档                           | 当前原型（prototype/）                             |
| ---- | ----------------------------------------- | -------------------------------------------- |
| 技术栈  | Flutter（一套代码三端：iOS / HarmonyOS / Android） | uni-app（Vue 3 + Vite + TS），当前可在 H5 / 各小程序端运行 |
| 音频能力 | 完整混音引擎、淡入淡出、真实播放                          | 仅视觉演示，无真实音频                                  |
| 数据   | 需后端/云端同步                                  | 全部 mock，仅主题持久化                               |
| 分享裂变 | 邀请码 + 分享链路                                | 仅 UI 与 toast 占位                              |

### 8.2 演进建议

- **若定稿为 Flutter 多端 App**：按设计文档方案迁移；`data/sounds.ts` 的声音/场景数据结构（`Sound`、`FeaturedScene` 含 `soundIds + ratio`）与 `theme/index.ts` 的 token 体系可直接平移为 Dart 数据模型与主题类。

- **若延续 uni-app**：可逐项补齐

  1. 真实音频：`uni.createInnerAudioContext()`（小程序/App）或 Web Audio（H5）实现播放、混音音量与淡入淡出；
  2. 数据层：接入后端 API 替换 `data/sounds.ts` mock，收藏/历史/签到/成就等页面补持久化；
  3. 功能缺口：`scene-detail` 消费路由 `sceneId`、引导页增加"已看过"标记与本地存储、真实音量滑块联动音频、邀请链接真实生成。

***

## 9. 常见问题与注意事项

1. **换肤失效**：不要硬编码颜色，应使用 `var(--app-*)` 变量（如 `--app-primary`、`--app-card-bg`）或 `uni.scss` 中的 `$app-*`/`$uni-*` 变量；否则切换配色/UI 风格后该元素不会跟随。
2. **页面状态不持久**：除主题外所有数据均为内存级 mock（收藏/历史/签到/成就等），刷新或重进即重置，属原型预期行为。
3. **scene-detail 参数未消费**：`discover` 以 `?sceneId=` 跳入但该页面使用硬编码场景对象，接入真实数据时需改用 `onLoad` 的 `options.sceneId`。
4. **引导页每次都出现**：`onboarding` 未写"已看过"标记，不符合"仅首次展示"的常规预期，后续需补 `uni.setStorageSync` 判断。
5. **混音上限**：`maxTracks = 6`，超出时仅 toast 提示，没有更优雅的交互引导。
6. **无真实音频**：播放/定时器/音量/淡入淡出均为视觉演示，勿误以为存在后台音频。
7. **新增页面必须注册**：在 `pages.json` 的 `pages` 数组登记；若新增 Tab，还需要在 `tabBar` 中配置文本与 `static/tabbar/` 下的图标路径。
8. **运行端命令对应**：不同目标端使用对应 `dev:mp-*` / `build:mp-*` 命令；类型提示依赖 `@dcloudio/types`，勿移除。
9. **pnpm 锁定**：使用 `pnpm@11.16.0`（packageManager 字段锁定）安装依赖，避免 lockfile 漂移；若需下载构建脚本，注意 `pnpm.onlyBuiltDependencies` 仅放行 esbuild / core-js / core-js-pure。

***

> 本文档基于当前仓库快照自动生成，若代码结构发生变化请同步更新。核心入口：[main.ts](file:///d:/app/projects/whitenoise/prototype/src/main.ts) · [App.vue](file:///d:/app/projects/whitenoise/prototype/src/App.vue) · [theme/index.ts](file:///d:/app/projects/whitenoise/prototype/src/theme/index.ts) · [data/sounds.ts](file:///d:/app/projects/whitenoise/prototype/src/data/sounds.ts)

