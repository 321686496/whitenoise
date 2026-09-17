# 声栖原型 v2 全量落地 · 实施设计

> 日期：2026-09-16
> 状态：已全量落地（主题引擎 v2 / 全局样式 / 6 新组件 / 17 页迁移完成）；2026-09-16 收尾轮补齐 discover·onboarding·history 硬编码清理，并修复 pnpm-workspace.yaml 配置使 install/type-check/dev:h5 可用
> 设计规范来源：`docs/design-system/MASTER.md`（v2.0，单一事实来源）
> 视觉对照基准：`html/design-preview.html`（17 界面 + 4 浮层高保真稿）

---

## 1. 背景与目标

2026-09-15 的一轮设计工作产出了 Design System v2（`docs/design-system/MASTER.md` + `html/design-preview.html`），但 `prototype/src` 代码仍为 v1：

- 主题引擎只有「配色 × UI 风格」二维，**无明暗模式**；
- morandi 主色为 `#5C8A72`，**与品牌约定 `#3D6B5E` 不一致**；
- 缺失 `--app-overlay` 等 18 个语义 token，弹窗遮罩实际失效；
- 全库 60+ 处硬编码颜色 / 阴影 / 渐变。

**目标**：把 v2 设计全量落地到 `prototype/src`（uni-app 工程），使实际运行的界面与 v2 规范及品牌调性（莫兰迪绿 `#3D6B5E`、iOS/Apple HIG、助眠低刺激）完全一致。

**不在本轮范围**：`snapp/`（Flutter）侧复刻（下一轮按同一 token 表 1:1 迁移）；新增功能；品牌资产（logo、static 资源）变更；路由表增删。

## 2. 设计依据与硬约束

- 全部 token、组件规格、IA 结构以 `docs/design-system/MASTER.md` 为准，本文件不重复其色值表，仅定义落地方式。
- 视觉细节以 `html/design-preview.html` 为对照权威。
- 沿用 AGENTS.md 既有铁律：禁 emoji（一律 `Icon.vue` SVG）、禁新增自定义颜色、`.page-bg` 必须 `z-index: -1`、新拟态浮雕取向（§4.2）、叠图浮层取向（§4.3）、uni-app 改动后必须通过 `pnpm type-check`。

## 3. 架构变更

### 3.1 主题引擎（`prototype/src/theme/index.ts` 重写）

- 新增 `ThemeMode = 'auto' | 'light' | 'dark'` 维度；`auto` 跟随系统，H5 通过 `window.matchMedia('(prefers-color-scheme: dark)')` 监听并即时切换（其它端读取系统主题一次，不做实时监听）。
- `buildTokens(scheme, ui, mode)` 按三层架构产出：
  1. **L0**：12 组 `--p-*` 基础色板（6 配色 × 明暗，色值逐套照搬 MASTER.md §3.1）；
  2. **L1**：语义 `--app-*`，补齐 v1 缺失的 `--app-overlay / --app-surface / --app-surface-2 / --app-sunken / --app-line / --app-line-strong / --app-success / --app-warning / --app-danger-soft / --app-rank-1..3 / --app-hl` 等；
  3. **L2**：由 `ui` 覆写容器/描边/模糊/阴影（`--app-shadow-1..4`、`--app-inset`、`--app-blur`），规格照 MASTER.md §4。
- 注入动效 token `--dur-fast/base/slow/page` 与 `--ease-std/out/in`（§8）。
- 持久化 key 仍为 `shengqi-theme`，值从 `{scheme, ui}` 扩为 `{scheme, ui, mode}`；读取旧数据缺 `mode` 时按 `'auto'` 兼容。
- `schemeMeta` 扩展为携带 v2 明暗双 swatch（供 theme 页展示，替换 theme.vue 内写死的 hex）；`schemePrimary` 等供原生组件绑定的导出保留。
- 主题设置页新增「外观」分段：跟随系统 / 浅色 / 深色（写入 `mode`）。
- `themeState` 增加 `mode` 响应式字段；`setTheme` / `initTheme` 签名相应扩展（向后兼容旧调用点，编译期通过即可）。

### 3.2 基础样式（`prototype/src/App.vue` / `uni.scss`）

- 阴影收敛为 `--app-shadow-1..4`；弹窗/遮罩统一 `--app-overlay`（修复 v1 遮罩失效）。
- 全局 `prefers-reduced-motion: reduce` 覆盖（MASTER.md §8 的全局规则）；`:focus-visible` 焦点态（2px `--app-primary` 描边）。
- `.page-bg` 渐变改用 `--p-bg-grad`，保持 `z-index: -1` 铁律不变。
- 字排按 MASTER.md §5：正文基准 15px、数字/计时 `font-variant-numeric: tabular-nums`、禁 800+ 中文字重。
- 公共类（`.btn-primary / .btn-outline / .app-card / .page-title / .section-title / .divider`）保留名称与用途，内部值迁移 v2 token，避免全库类名断裂。

### 3.3 公共组件（`prototype/src/components/`）

| 组件 | 动作 | 要点 |
|---|---|---|
| NavBar.vue | **新增** | 统一二级页自定义导航：44px 返回 + 标题 + 右侧至多 1 个操作 |
| BrandBar.vue | **新增** | 首页品牌行：logo + 「声栖」 + 时段问候语，右侧至多 2 个 44px 图标钮（主题/成就） |
| NowPlayingCard.vue | **新增** | 首页主控卡（黄金位）：场景名 + 路数胶囊 + 波形 + 88px 播放键 + 定时/混音/收藏；空态为月亮图标 + 引导文案 |
| EmptyState.vue | **新增** | 72px 图标容器 + 主/副文案 + 可选行动按钮 |
| Skeleton.vue | **新增** | 1.6s shimmer，占位与真实内容同尺寸 |
| Segmented.vue | **新增** | 胶囊容器 + 等分药丸，选中 `--app-surface` + `--app-shadow-1` |
| TabBar.vue | 更新 | 悬浮胶囊；选中态 = 底色药丸 + 主色图标 + 2px 指示点 |
| PlayBar.vue | 更新 | 降级为 MiniPlayer 角色（64px）；首页不渲染（与 NowPlayingCard 互斥） |
| SceneCard.vue | 更新 | 封面统一 4:3，标题 2 行截断，grid/list 双形态 |
| SoundCard.vue | 更新 | 56px 色底改 `color-mix(in srgb, var(--sound-color) 16%, var(--app-surface))`，深色模式 22% 提亮 |
| MixTrack.vue | 更新 | 滑块触控区扩到 44px，静音/删除保留 |
| Icon.vue | 按需补充 | 新组件所需图标名（如 moon、timer 等）先确认/新增，全部 SVG |

组件内落实：新拟态浮雕铁律（表面色=画布色、无描边、方向铁律）与「叠图浮层取向」（flat 实底 / glass 毛玻璃 / neu 降级）。

### 3.4 页面层（17 页全量迁移）

- **index 首页 IA 重构**（MASTER.md §10.1）：① BrandBar → ② NowPlayingCard 主控卡 → ③ 场景流（3 个一键播快捷 chip + 分类胶囊 + 2 列场景网格）。金刚区 2×2 降级为 chip；今日精选移入 discover；最近使用移入 history；首页移除 MiniPlayer。
- **导航统一**：12 个原生导航页（theme/achievement/invite/settings/checkin/stats/favorites/history/scene-detail/scene-edit/scene-all/library）全部改 `navigationStyle: custom` 并接入 NavBar；`pages.json` 清理全部写死色值（`#F5F2ED` 等）；tabBar 保持 `custom: true`。
- **scene**：分类数据源改读 `data/scenes.ts` 单一来源（删除页内重复定义）。
- 其余页面（discover / mine / settings / theme / achievement / checkin / stats / favorites / history / invite / onboarding / scene-all / scene-detail / scene-edit / library）全部迁移 v2 token 与组件。
- **顺带修复 MASTER.md §10.3 的 5 个功能缺陷**：
  1. settings 两段重复「提醒设置」合并为一段；
  2. settings 死代码 `showTimePicker` 补齐时间选择弹窗（照 MASTER.md §10.3）；
  3. library 补返回入口；
  4. achievement 概览数字与 `progressPercent` 不一致，全部改 computed 驱动；
  5. pages.json 硬编码导航色清理（由「全部 custom」方案覆盖）。

### 3.5 数据层（接口不变）

- `data/scenes.ts`：`sceneCategories` 作为唯一分类来源；`getRecommended / getCategoryScenes / buildRecipe / buildPresets / findScene` 签名不变。
- `data/sounds.ts`：40+ 声音 `color/gradient` 保留为内容资产，样式侧一律 `color-mix` 派生，不手写 rgba。
- `composables/usePlayer.ts`：状态机不改；NowPlayingCard 与快捷 chip 直接走 `applyScene / togglePlay`（无音轨 toast 提示逻辑保留）。

## 4. 兼容性与风险

| 风险 | 对策 |
|---|---|
| 旧持久化数据无 `mode` 字段 | 读取时缺省为 `'auto'`，不丢弃旧 `{scheme, ui}` |
| `color-mix()` 兼容性 | 原型目标为现代 H5 浏览器（v1 已在用 `color-mix`），维持现状不降级 |
| 全部页面改 custom 导航后返回行为 | NavBar 统一 `uni.navigateBack`，无上级时回首页 |
| PlayBar 与主控卡互斥 | 以路由判断：仅首页不渲染 PlayBar，其余页常驻 |
| 17 页一次改动面大 | 实施计划按「主题引擎 → 基础样式 → 组件 → 首页 → 播放链路 → 我的链路 → 发现/引导」分批提交，每批 `pnpm type-check` 通过 |

## 5. 验收标准

1. `pnpm type-check` 通过（每批改动后及最终）。
2. `pnpm dev:h5` 目视验收：17 页逐页过一遍；至少抽查 morandi ×（浅色/深色）×（flat/glass/neu）组合的首页、场景页、主题页。
3. 明暗切换即时生效且持久化；跟随系统模式在系统切换时响应。
4. 全库无新增自定义颜色（`#hex` / `rgba(0,0,0,…)` 硬编码清零，MASTER.md §11 清单逐项核对）。
5. 品牌：首页头部 logo + 「声栖」品牌名；主色浅色模式为 `#3D6B5E`；无 emoji 图标。
6. 触控目标 ≥ 44×44；弹窗遮罩可见（overlay 修复验证）。

## 6. 交付物清单

- `prototype/src/theme/index.ts`（重写）
- `prototype/src/App.vue`、`prototype/src/uni.scss`（样式迁移）
- `prototype/src/pages.json`（导航统一 + 色值清理）
- 新增组件 6 个：NavBar / BrandBar / NowPlayingCard / EmptyState / Skeleton / Segmented
- 更新组件 6 个：Icon / TabBar / PlayBar / SceneCard / SoundCard / MixTrack
- 17 个页面 vue 全量迁移
- `docs/design-system/MASTER.md` 若有落地偏差，回写勘误；AGENTS.md 文档索引同步
