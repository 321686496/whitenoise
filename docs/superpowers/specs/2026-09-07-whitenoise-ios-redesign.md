# 声栖 App 原型重设计文档（iOS 设计哲学 × 新拟态/玻璃融合）

日期：2026-09-07

状态：已确认（视觉风格、架构导航、页面明细、组件清单、实施计划）

## 1. 背景与目标

现有原型位于 `prototype/`（uni-app Vue3 + Vite，一套代码跑 H5 / HarmonyOS / 小程序等），UI 采用「6 套配色 × 3 种风格（flat/glass/neu）」可切换体系。本次重新设计的核心目标：

- **设计哲学全面 iOS 化**：Large Title、inset 分组列表、Tab Bar、底部 Sheet、标准导航栏、深浅色跟随系统、SF 字体同构排版。

- **视觉风格收敛**：由「flat/glass/neu 三选一」收敛为唯一确定的方向 —— **新拟态 × Liquid Glass 融合质感**（方案 A，已确认）。

- **统一品牌色**：外观设置只保留主色调切换（青绿＝品牌默认 / 靛蓝 / 紫），深浅色自动跟随系统。

- **入口与导航重塑**：导航层级压缩到最多 2 层，任意操作 2 步内可达；轻量操作全部改走底部 Sheet。

> 说明：早期文档（`2026-08-17-whitenoise-app-design.md`）中描述的是 Flutter 时代的长期形态；本文档针对当前 uni-app 原型，是原型本次改版的设计基准。

## 2. 设计哲学（iOS 设计语言映射）

| iOS 原语                       | 本项目应用                                                           |
| ---------------------------- | --------------------------------------------------------------- |
| Large Title 大标题              | 四个 Tab 根页顶部大标题，滚动收拢                                             |
| 标准导航栏                        | 二级页：返回 chevron + 居中标题（`navigationStyle: custom` 自绘玻璃导航条）        |
| Inset Grouped List           | 「我的」及全部设置/列表二级页的圆角分组列表                                          |
| Tab Bar                      | 底部玻璃 Tab Bar（首页/场景/发现/我的）                                       |
| Card Sheet                   | 定时关闭、声音库、播放设置等轻量操作用底部卡片（grabber 把手、下滑关闭）                        |
| System Material              | glass 材质 `backdrop-blur` + 边缘高光；不支持端回退纯色玻璃                      |
| Now Playing                  | 悬浮 Mini Player 胶囊条，点击上滑展开全屏播放面板                                 |
| Alert / Action Sheet / Toast | 确认、长按菜单、轻反馈                                                     |
| 深浅色跟随系统                      | `uni.onThemeChange` + `matchMedia(prefers-color-scheme)`，应用内可覆盖 |
| SF Pro 同构排版                  | 系统字体栈，中文 PingFang/默认，字阶 34/41 B → 13/18 R                       |

## 3. 视觉规范（Design Tokens）

统一由 CSS 变量运行时注入（沿用 `theme/index.ts` 的注入机制，见 §7）。

### 3.1 颜色

| 令牌                          | 浅色                                   | 深色                            |
| --------------------------- | ------------------------------------ | ----------------------------- |
| `bg-base / bg-mid / bg-end` | `#DFE7EF / #D3DFE2 / #D8E4DC`        | `#22262E / #1D2629 / #232822` |
| 背景氛围                        | 渐变 + 低透明氛围光斑（blob）                   | 渐变 + 微光光斑                     |
| `text`                      | `#1C2632`                            | `#EEF2F4`                     |
| `text-2`                    | `#5B6B77`                            | `#9AA6B0`                     |
| `text-3`                    | `#8E98A5`                            | `#5C6872`                     |
| `accent`（品牌青绿）              | `#00A88E`                            | `#00C8B2`                     |
| 可选主色                        | 靛蓝 `#5E7CE6`｜紫 `#9B7BD8`（浅）/ 提亮变体（深） | 同左                            |
| `ios-blue`（链接/选中）           | `#007AFF`                            | `#0A84FF`                     |
| `danger`                    | 沿用现有 `#C4706B` 系                     | 沿用的提亮变体                       |

### 3.2 材质与投影

| 令牌           | 浅色                                                                         | 深色                                                                |
| ------------ | -------------------------------------------------------------------------- | ----------------------------------------------------------------- |
| `glass-card` | `rgba(255,255,255,.42)` + `backdrop-blur(20px)`                            | `rgba(42,50,58,.46)` + `backdrop-blur(20px)`                      |
| glass 边框     | `rgba(255,255,255,.75)`                                                    | `rgba(255,255,255,.16)`                                           |
| glass 投影     | `0 4px 14px rgba(60,80,90,.18)`                                            | `0 4px 14px rgba(0,0,0,.42)`                                      |
| 边缘高光         | `inset 0 1px 1px rgba(255,255,255,.9)`                                     | `inset 0 1px 1px rgba(255,255,255,.22)`                           |
| 新拟态凸起        | `6px 6px 14px rgba(163,177,188,.55), -6px -6px 14px rgba(255,255,255,.85)` | `6px 6px 14px rgba(8,10,13,.6), -6px -6px 14px rgba(60,68,78,.4)` |
| 新拟态凹陷        | `inset 5px 5px 12px … , inset -5px -5px 12px …`                            | 同类深色变体                                                            |

降级策略：不支持 `backdrop-filter` 的环境（部分 H5 / Android WebView）将 glass 背景提高不透明度（如 `.55→.75`）作为纯色玻璃回退，保证观感一致。

### 3.3 圆角 / 间距 / 字体

- 圆角：`s 8 / m 12 / l 16 / xl 22 / full 999`

- 间距：4 基准；页面水平留白 24；区块间距 32

- 字体：系统栈（`-apple-system, "PingFang SC", "Helvetica Neue", sans-serif`），不引入外部字体

- 字阶：Large Title 34/41 B（根页大标题）、Title2 22/28 SB、Headline 17/22 SB、Body 17/22、Footnote 13/18；数字用 `font-variant-numeric: tabular-nums`

## 4. 页面架构与导航

### 4.1 导航范式（四级模式）

1. **Tab 根页 = Large Title**：首页/场景/发现/我的，无传统导航条，沉浸背景，滚动联动收拢。
2. **二级页 = 标准导航栏**：返回 chevron + 居中标题 + inset 分组列表正文（可选搜索栏）。
3. **轻量操作 = 底部 Sheet**：grabber 把手、圆角毛玻璃、下滑关闭；不打断上下文。
4. **沉浸页**：场景详情、引导页 —— 全屏沉浸 + 悬浮控件 + 底部 Liquid Glass 控制面板。

导航层级最多 2 层；页面流转：

```
Tab 根页 ──→ Sheet（声音库/定时/播放设置）
   │
   ├─→ Push 场景详情（沉浸）
   └─→ Push 设置/收藏/历史/数据/成就/邀请/签到（标准导航栏）
```

### 4.2 页面清单

| 页面（现有）                                                       | 新形态                                                    | 导航方式          |
| ------------------------------------------------------------ | ------------------------------------------------------ | ------------- |
| index（首页）                                                    | Large Title「声栖」，快捷场景横滑卡 → 今日推荐 → Mini Player → Tab Bar | Tab 根页        |
| scene（场景）                                                    | 分段控件分类 + 双列场景卡片网格                                      | Tab 根页        |
| discover（发现）                                                 | 横滑 Banner → 编辑精选 → inset 列表内容流                         | Tab 根页        |
| mine（我的）                                                     | 用户卡 + 签到入口 + inset 分组列表                                | Tab 根页        |
| theme（主题设置）                                                  | 改造为「外观」：浅/深/跟随系统 + 主色调三选                               | 二级页（入口：我的→设置） |
| settings                                                     | iOS inset 分组列表设置页                                      | 二级页           |
| favorites / history / stats / achievement / invite / checkin | 标准二级页（导航栏 + inset 列表）                                  | 二级页           |
| library（声音库）                                                 | 由首页「＋」/快捷卡触发，底部 Sheet 弹出，含搜索 + 分类筛选                    | Sheet         |
| scene-detail                                                 | 全屏沉浸 + 悬浮返回 + 底部控制面板（进度/播放/音量/定时）                      | 沉浸 Push       |
| onboarding                                                   | 全屏沉浸引导：圆标 + 指示点 + 开始按钮                                 | 沉浸            |

## 5. 关键页面明细

- **首页**：Large Title「声栖」→ 快捷场景（横滑玻璃卡）→ 今日推荐（图文卡）→ 悬浮 Mini Player → Tab Bar。Mini Player 点击上滑展开全屏播放面板；原「选择风格/配色」入口移除。

- **场景**：分段控件（助眠/专注/氛围/更多）→ 2 列场景卡（图 + 悬浮播放钮 + 时长）；双击卡片直接播放并唤起 Mini Player。

- **发现**：Banner 横滑 → 编辑精选三卡 → 内容列表；点赞/收藏仅按压反馈不跳页。

- **我的**：用户卡（头像/昵称/签到）→ inset 分组列表：我的收藏 / 播放历史 / 使用数据 / 成就墙 / 邀请好友 / 设置（含外观）。

- **外观设置**：外观（浅色/深色/跟随系统，默认跟随）+ 主色调（青绿/靛蓝/紫）+ 默认定时开关。

- **场景详情**：大图满屏 + 暗色遮罩 + 悬浮返回；底部 Liquid Glass 控制面板（进度条、播放/暂停、音量、定时）。

- **声音库 Sheet**：grabber 把手、搜索栏、分类筛选 chips、每行带播放预览。

## 6. 组件清单

| 新组件                         | iOS 语义                       | 用途                                       |
| --------------------------- | ---------------------------- | ---------------------------------------- |
| NeGlass                     | Material / Vibrancy          | 玻璃容器：`backdrop-blur` + 边缘高光 + 新拟态双影（含回退） |
| NeChip                      | Filter Chip                  | 分类/快捷场景筛选，选中态 accent 填充                  |
| NeSlider                    | Slider                       | 音量/进度/混音配比                               |
| NeSwitch                    | Switch                       | 定时、循环、设置开关                               |
| NeSegmented                 | Segmented Control            | 场景分类、发现内容切换                              |
| NeSheet                     | Card Sheet                   | 声音库/定时/播放设置：grabber + 上滑入场 + 下滑关闭 + 遮罩   |
| NavBar / LargeTitle         | Navigation Bar + Large Title | 大标题滚动收拢、二级页返回栏                           |
| MiniPlayer / PlayerPanel    | Now Playing                  | 悬浮胶囊常驻条 → 上滑播放面板                         |
| ActionSheet / Alert / Toast | Action Sheet / Alert / Toast | 长按菜单、确认（封装 `uni.showModal/showToast`）    |
| EmptyState / ListRow        | Empty State / Table Row      | 空态；inset 分组列表行（chevron）                  |

## 7. 主题引擎与技术实施

### 7.1 改造 `src/theme/index.ts`

- 保留 CSS 变量运行时注入与 `uni.getSystemInfoSync` rpx 换算机制。

- 状态维度重构：`appearance: 'light' | 'dark' | 'system'` × `accent: 'teal' | 'indigo' | 'lavender'`（替代原 `scheme × ui` 矩阵）。

- 令牌生成改为深浅两套主题树，accent 只影响 `--app-accent` 与选中态高亮。

- 跟随系统：原生端 `uni.onThemeChange`；H5 端 `matchMedia('(prefers-color-scheme: dark)')` 监听；应用内设置覆盖；持久化沿用 `uni.setStorageSync` 模式。

- 保留 `--app-tab-height` / `--app-playbar-height` 等布局令牌。

### 7.2 其他技术要点

- 抽取 `components/` 组件库（§6 清单），全部由 CSS 变量驱动。

- 保留现有播放/混音/定时/数据逻辑，只替换视觉壳并新增 Mini Player 与播放面板交互；状态继续用轻量 reactive，不引入 pinia。

- `backdrop-filter` 兼容回退（High-alpha 纯色玻璃）。

- 动效：按压 `scale(.97)`、页面右滑转场、Sheet 上滑入场、大标题滚动收拢、深浅色过渡。

- Logo：沿用现有 `static/logo-v10-1.jpg`（PlayBar / 首页 / 外观页引用不变），本次不改 logo，可在后续单独立项。

- 安全：无新增外部服务/密钥；字体仅系统栈。

## 8. 错误处理与空态

- 播放失败：Toast + 重试。

- 发现/推荐请求失败：EmptyState + 重试按钮。

- 数据为空：引导性空态（插图 + 主操作按钮）。

- Mini Player 无播放内容时隐藏。

## 9. 分阶段实施计划

| 阶段           | 内容                                                                                            |
| ------------ | --------------------------------------------------------------------------------------------- |
| P0 视觉基座      | theme 引擎重构 + uni.scss 令牌 + 核心组件库（NeGlass/NeChip/NeSlider/NeSwitch/NeSegmented/NeSheet/NavBar） |
| P1 四大 Tab 根页 | index / scene / discover / mine 全面换新                                                          |
| P2 二级页批量     | 外观设置、设置、收藏、历史、数据、成就、邀请、签到、声音库 Sheet                                                           |
| P3 沉浸页与打磨    | 场景详情、引导页、Mini Player + 播放面板、动效、空态与错误态                                                         |

## 10. 验证策略

- 开发验证：`npm run dev:h5` 浏览器预览；DevTools 模拟深色模式验证深浅跟随。

- 编译器类型校验通过（vue-tsc / 构建无报错）后再交付。

- 逐页手测清单：大标题滚动收拢、Sheet 出入场、播放面板展开、深浅切换、accent 三色切换。

