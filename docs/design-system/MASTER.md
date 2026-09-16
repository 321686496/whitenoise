# 声栖 · Design System MASTER

> 版本 v2.0（2026-09-15） · 全界面 redesign 的单一事实来源
> 适用范围：`prototype/`（uni-app）与 `snapp/`（Flutter）两个工程
> 上一版基线：`prototype/src/theme/index.ts` + `uni.scss`（v1 主题引擎）

---

## 0. 这次改了什么（TL;DR）

| 项 | v1 现状 | v2 方案 |
|---|---|---|
| 明暗 | 只有「深海」一套是暗色，其余 5 套全是浅色 | **6 套配色 × 明暗双模式 = 12 个完整色板**，默认跟随系统 |
| 主色 | 莫兰迪主色 `#5C8A72`，与品牌约定 `#3D6B5E` 不一致 | 全量回归品牌深森林绿 `#3D6B5E`（浅色模式） |
| 变量缺失 | `--app-overlay` 从未定义，弹窗遮罩实际失效 | 补齐 overlay / scrim / inset / rank / success / warning 等 18 个语义 token |
| 硬编码 | 全库 60+ 处 `rgba(0,0,0,.x)` / `#fff` / 写死渐变 | **零硬编码**，阴影、遮罩、金银铜、声音色全部 token 化 |
| 首页 | 7 个区块纵向堆叠，首屏看不到播放键 | **播放优先三层**：品牌行 → 主控卡 → 场景流 |
| 触控 | 多处 22px 图标按钮（低于 44pt） | 最小触控 44px，主操作 56–88px |
| 动效 | 仅页面级 reduced-motion 降级 | 全局 `--dur-*` / `--ease-*` token，reduced-motion 一键降级 |
| 一致性 | 部分页原生导航栏、部分 custom；分类定义两套 | 统一自定义导航栏，分类数据源单一 |

---

## 1. 设计原则

1. **暗色优先，明暗对等。** 助眠 App 的第一使用场景是深夜。暗色不是浅色的反转，而是独立调过的一套色板：背景近黑带色相（非纯黑）、卡片靠明度差而非阴影分层、主色提高明度保证 4.5:1 对比。
2. **一次点击出声（Play-First）。** 首页首屏必须直接可见播放键，任何场景从冷启动到出声不超过 1 次点击。
3. **零硬编码。** 业务代码里禁止出现 `Color(0xFF…)` / `Colors.xxx` / `#hex` / `rgba()`。所有颜色来自语义 token。
4. **触控优先。** 最小 44×44；相邻触控目标间距 ≥ 8px；主播放键 88px。
5. **低刺激动效。** 时长 160–320ms，缓动 `cubic-bezier(.32,.72,0,1)`；装饰性动效（波形呼吸、光晕）周期 ≥ 1.6s 且必须尊重 `prefers-reduced-motion`。
6. **单一数据源。** 分类、声音色板、成就数据各只有一处定义，页面只读不重写。

---

## 2. Token 架构（三层）

```
L0 基础色板  --p-*     由 scheme × mode 决定（6 × 2 = 12 组）
      ↓
L1 语义 token --app-*   与风格无关的稳定语义（primary / text / danger …）
      ↓
L2 组件 token --app-surface / --app-line / --app-shadow-*   由 ui 风格（3 种）覆写
```

落地方式（uni-app）：`theme/index.ts` 的 `buildTokens(scheme, ui, mode)` 一次算出全部变量注入 `html` 根节点。
落地方式（Flutter）：`AppTheme.of(context)` 读同一套枚举组合，输出 `ThemeData` + `ThemeExtension`。

---

## 3. 色彩

### 3.1 基础色板 L0（`--p-*`，12 组）

每套配色必须提供以下 20 个基础位：

| 变量 | 含义 |
|---|---|
| `--p-bg` | 页面底色 |
| `--p-bg-grad` | 顶部氛围渐变起点 |
| `--p-surface` | 卡片/浮层实底色 |
| `--p-surface-2` | 次级容器（分段控件底、chip 底、凹陷底） |
| `--p-sunken` | 输入框 / 进度槽 |
| `--p-t1 / t2 / t3` | 一级 / 二级 / 三级文本 |
| `--p-line` | 发丝级描边 |
| `--p-line-strong` | 强描边（选中态、输入框聚焦） |
| `--p-primary` | 品牌主色 |
| `--p-primary-strong` | 主色按下 / 渐变终点 |
| `--p-on-primary` | 主色上的文字与图标 |
| `--p-accent` | 辅助强调（进度条渐变终点、图表第二色） |
| `--p-overlay` | 弹窗遮罩（**v1 缺失**） |
| `--p-scrim` | 阴影用的 RGB 三元组，如 `24,32,28` |
| `--p-neu-a / neu-b` | 新拟态暗 / 亮阴影 |
| `--p-glass / glass-line` | 玻璃拟态底 / 高光描边 |
| `--p-hl` | 暗色下卡片内顶部高光（inset） |

#### 莫兰迪 morandi（默认 · 品牌森绿）

| | 浅色 | 深色 |
|---|---|---|
| bg | `#F4F2EC` | `#101513` |
| bg-grad | `#EAE6DC` | `#18211D` |
| surface | `#FFFFFF` | `#1A221F` |
| surface-2 | `#EDEAE1` | `#222B27` |
| sunken | `#E9E5DA` | `#0C1210` |
| t1 | `#26302B` | `#E8EDEA` |
| t2 | `#66756D` | `#A3B2AA` |
| t3 | `#9AA69F` | `#6E7D76` |
| line | `#E5E0D5` | `#26312C` |
| primary | `#3D6B5E` | `#7FBFAA` |
| primary-strong | `#2F544A` | `#5EA88F` |
| on-primary | `#FFFFFF` | `#0C1512` |
| accent | `#8FB8A0` | `#6FA892` |
| overlay | `rgba(24,32,28,.42)` | `rgba(0,0,0,.62)` |
| scrim | `24,32,28` | `0,0,0` |
| neu-a / neu-b | `rgba(90,110,100,.18)` / `rgba(255,255,255,.9)` | `rgba(0,0,0,.45)` / `rgba(255,255,255,.055)` |
| glass / line | `rgba(255,255,255,.64)` / `rgba(255,255,255,.85)` | `rgba(255,255,255,.07)` / `rgba(255,255,255,.13)` |
| hl | — | `rgba(255,255,255,.055)` |

> 浅色 primary 对比度：`#3D6B5E` on `#FFFFFF` = **5.6:1** ✅
> 深色 primary 对比度：`#7FBFAA` on `#1A221F` = **7.4:1** ✅

#### 深海 ocean

| | 浅色 | 深色 |
|---|---|---|
| bg / grad | `#EFF4F5` / `#E2EDEF` | `#0B1A21` / `#122831` |
| surface / 2 / sunken | `#FFFFFF` / `#E6EFF1` / `#DFEAEC` | `#13242C` / `#1B2F38` / `#091820` |
| t1 / t2 / t3 | `#0F2833` / `#5A7480` / `#93A8B0` | `#E4F1F3` / `#9DB6BF` / `#6A858F` |
| line | `#DCE7EA` | `#22333C` |
| primary / strong | `#2F7F86` / `#1F5F65` | `#6FC9CE` / `#4FA9AF` |
| on-primary | `#FFFFFF` | `#04171C` |
| accent | `#7FC4C4` | `#4FA3A8` |
| scrim | `15,40,51` | `0,0,0` |

#### 森林 forest

| | 浅色 | 深色 |
|---|---|---|
| bg / grad | `#F1F4EA` / `#E4EBD9` | `#12170F` / `#1A2216` |
| surface / 2 / sunken | `#FFFFFF` / `#E9EFDF` / `#E2E9D6` | `#1A2016` / `#232B1D` / `#0F140D` |
| t1 / t2 / t3 | `#25301F` / `#5F7053` / `#96A48A` | `#EAF0E3` / `#A6B598` / `#728068` |
| line | `#E0E7D4` | `#27301F` |
| primary / strong | `#3F6B34` / `#2C4E24` | `#8FC46F` / `#6EA64F` |
| on-primary | `#FFFFFF` | `#0E1509` |
| accent | `#8FB071` | `#6EA34F` |
| scrim | `37,48,31` | `0,0,0` |

#### 日落 sunset

| | 浅色 | 深色 |
|---|---|---|
| bg / grad | `#FBF3EA` / `#F5E7D6` | `#1A1310` / `#261A14` |
| surface / 2 / sunken | `#FFFFFF` / `#F7ECE0` / `#F2E5D6` | `#241A16` / `#2E221C` / `#150F0C` |
| t1 / t2 / t3 | `#3A2A20` / `#7A6455` / `#AC9683` | `#F3E7DD` / `#BFA795` / `#8A7466` |
| line | `#F0E2D2` | `#33251E` |
| primary / strong | `#B4603C` / `#8E482B` | `#E08B5E` / `#BF6B42` |
| on-primary | `#FFFFFF` | `#1A0F09` |
| accent | `#E3A377` | `#C47A50` |
| scrim | `58,42,32` | `0,0,0` |

#### 薰衣草 lavender

| | 浅色 | 深色 |
|---|---|---|
| bg / grad | `#F5F3FA` / `#EAE5F4` | `#14121C` / `#1E1A28` |
| surface / 2 / sunken | `#FFFFFF` / `#EEEAF6` / `#E7E2F1` | `#1D1A26` / `#262231` / `#100E17` |
| t1 / t2 / t3 | `#2E2A3D` / `#6C6486` / `#9E96B8` | `#EDEAF5` / `#A79FC0` / `#746C8C` |
| line | `#E6E1F0` | `#2B2637` |
| primary / strong | `#6B5A9E` / `#524478` | `#A896E0` / `#8B76C6` |
| on-primary | `#FFFFFF` | `#120F1A` |
| accent | `#B3A5CE` | `#8E7EC0` |
| scrim | `46,42,61` | `0,0,0` |

#### 极简黑白 mono

| | 浅色 | 深色 |
|---|---|---|
| bg / grad | `#F7F7F7` / `#EDEDED` | `#0E0E0E` / `#171717` |
| surface / 2 / sunken | `#FFFFFF` / `#F0F0F0` / `#E9E9E9` | `#171717` / `#202020` / `#0A0A0A` |
| t1 / t2 / t3 | `#171717` / `#616161` / `#9A9A9A` | `#F2F2F2` / `#A8A8A8` / `#747474` |
| line | `#E8E8E8` | `#262626` |
| primary / strong | `#2E2E2E` / `#141414` | `#E4E4E4` / `#C4C4C4` |
| on-primary | `#FFFFFF` | `#111111` |
| accent | `#757575` | `#9A9A9A` |
| scrim | `23,23,23` | `0,0,0` |

### 3.2 语义色（跨配色共享，随明暗切换）

| Token | 浅色 | 深色 | 用途 |
|---|---|---|---|
| `--app-success` | `#4A8F6B` | `#6FC295` | 签到成功、成就解锁 |
| `--app-warning` | `#B98A3E` | `#E0AA5E` | 提醒、进度将满 |
| `--app-danger` | `#B4544C` | `#E0837B` | 清空历史、删除、取消收藏 |
| `--app-danger-soft` | `color-mix(danger 12%, surface)` | 同 | 危险操作底色 |
| `--app-rank-1` | `linear-gradient(135deg,#F0C27F,#E8A849)` | 同 | Top1 金银铜 |
| `--app-rank-2` | `linear-gradient(135deg,#C0C7CF,#9EA8B3)` | 同 | |
| `--app-rank-3` | `linear-gradient(135deg,#D4A373,#BC8A5F)` | 同 | |

> v1 问题：`history.vue` 硬编码 `#C48B8B`、`achievement.vue` 用 `--app-danger` 表达完成度（语义错）。v2 全部收敛到上表。

### 3.3 声音色板（数据资产，非主题色）

`sounds.ts` 里 40+ 组 `color` / `gradient` 保留为**内容资产**（声音的品牌识别色），但派生值必须用 `color-mix` 生成，不再手写 rgba：

```scss
.sound-icon { background: color-mix(in srgb, var(--sound-color) 16%, var(--app-surface)); }
.sound-icon .ic { color: var(--sound-color); }
```

深色模式下统一对声音色做 `+8% lightness` 提亮，避免暗底上发灰：
```scss
[data-mode="dark"] .sound-icon { background: color-mix(in srgb, var(--sound-color) 22%, var(--app-surface)); }
```

---

## 4. UI 风格（L2 组件 token，3 种）

### flat 扁平化

```css
--app-surface: var(--p-surface);
--app-line: var(--p-line);
--app-blur: 0px;
--app-shadow-1: 0 1px 2px rgba(var(--p-scrim), .06);
--app-shadow-2: 0 4px 12px rgba(var(--p-scrim), .07), 0 1px 3px rgba(var(--p-scrim), .05);
--app-shadow-3: 0 12px 28px rgba(var(--p-scrim), .10), 0 2px 6px rgba(var(--p-scrim), .06);
--app-shadow-4: 0 20px 48px rgba(var(--p-scrim), .18);
--app-inset: none;
```

### glass 玻璃拟态

```css
--app-surface: var(--p-glass);
--app-line: var(--p-glass-line);
--app-blur: 20px;
--app-shadow-2: 0 8px 26px rgba(var(--p-scrim), .10);
--app-inset: inset 0 1px 0 var(--p-hl);
```
卡片必须显式写 `backdrop-filter: blur(var(--app-blur))`；**叠在照片/封面上的浮层一律走 glass 取向**（见 §7）。

### neu 新拟态

```css
--app-surface: var(--p-bg);          /* 表面色 == 画布色，这是浮雕成立的前提 */
--app-line: transparent;
--app-blur: 0px;
--app-shadow-2: 7px 7px 16px var(--p-neu-a), -7px -7px 18px var(--p-neu-b);
--app-inset: none;
```

**浮雕取向铁律**（沿用 AGENTS.md 4.2，v2 补充暗色规则）：
- 光源固定左上前方；凸起 = 左上亮 + 右下暗；凹陷（按下/选中）= 方向反转。
- 组件表面色必须与所在画布一致，禁止描边。
- **暗色下** neu 的亮阴影极弱（`rgba(255,255,255,.055)`），需把暗阴影加深到 `.45` 才能看出浮雕，已体现在 `--p-neu-*` 里。

---

## 5. 字排

- **中文**：`-apple-system, "PingFang SC", "HarmonyOS Sans SC", "Noto Sans SC", sans-serif`
- **数字/时间**：加 `font-variant-numeric: tabular-nums`，避免计时器跳动。
- 禁用 800 及以上的中文字重（笔画糊）。

| 级别 | px | 行高 | 字重 | 字距 | 用途 |
|---|---|---|---|---|---|
| Display | 30 | 1.18 | 700 | −0.02em | 引导页 / 空状态主标题 |
| Title-1 | 24 | 1.22 | 700 | −0.02em | 页面大标题 |
| Title-2 | 19 | 1.30 | 600 | −0.01em | 卡片标题、场景名 |
| Title-3 | 16 | 1.38 | 600 | 0 | 列表项主文案 |
| Body | 15 | 1.55 | 400 | 0 | 正文 |
| Body-SM | 13 | 1.50 | 400 | 0 | 描述、辅助说明 |
| Caption | 12 | 1.40 | 500 | 0.01em | 角标、chip、图表标签 |
| Caption-2 | 11 | 1.35 | 600 | 0.02em | 仅用于极小徽标（**不承载正文**） |

> 基准 15px（不是 16）——移动端单手场景，15/1.55 的可读性与信息密度最优；正文最小 13px。

---

## 6. 间距 / 圆角 / 阴影

**间距（4pt 网格）**：`2 4 8 12 16 20 24 32 40 48`
- 页面水平安全边距 **20px**
- 卡片内边距 **16px**
- 卡片之间 **12px**
- 分区之间 **28px**

**圆角**：`xs 8 · sm 12 · md 16 · lg 22 · xl 28 · full 999`
- 卡片 lg 22；图标容器 md 16；按钮 / chip / 分段 full；底部 sheet xl 28（仅顶部两角）

**暗色下的层级替代**：暗色阴影几乎不可见，改用
1. `surface` 明度台阶（bg → surface → surface-2）
2. `1px solid var(--p-line)`
3. `inset 0 1px 0 var(--p-hl)` 顶部内高光

---

## 7. 浮层叠在图片上的取向（速查）

| UI 风格 | 叠在照片/封面上的浮层 |
|---|---|
| flat | **不透明实底** + 发丝描边 + 柔和投影，不用毛玻璃 |
| glass | **半透明 + 20px 模糊** + 白色高光描边 |
| neu | **禁止浮雕双阴影**，降级为实底或毛玻璃浮层 |

---

## 8. 动效

| Token | 值 | 用途 |
|---|---|---|
| `--dur-fast` | 160ms | 按压反馈 |
| `--dur-base` | 220ms | 常规状态切换 |
| `--dur-slow` | 320ms | 页面进入、Sheet 弹起 |
| `--dur-page` | 380ms | 导航转场 |
| `--ease-std` | `cubic-bezier(.32,.72,0,1)` | 默认（iOS 风格收尾减速） |
| `--ease-out` | `cubic-bezier(.2,0,0,1)` | 进入 |
| `--ease-in` | `cubic-bezier(.4,0,1,1)` | 退出（比进入快） |

- 按压统一 `transform: scale(.96)`，160ms。
- 波形呼吸 1.6s `ease-in-out` infinite，5 根条错峰 0.12s。
- 列表进入：stagger 40ms，仅位移 12px + 淡入，不做缩放。
- **全局 reduced-motion 覆盖**：
```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: .01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: .01ms !important;
    scroll-behavior: auto !important;
  }
}
```

---

## 9. 组件清单

| 组件 | 规格 | v2 变更 |
|---|---|---|
| BrandBar | 44px logo + 品牌名 + 问候语；右侧最多 2 个 44px 图标钮 | 新增问候语时段化 |
| NowPlayingCard | 首页黄金位；88px 播放键 + 5 根波形 + 3 个次级操作 | **新增**，替代 v1 大播放卡 |
| PlayRing | 88px 圆形，主键用 `--app-primary` 渐变 + `--app-shadow-3` | 触控面积从 48 → 88 |
| MiniPlayer | 64px 高；首页不显示（与主控卡互斥），其余页常驻 | 新增互斥规则 |
| TabBar | 悬浮胶囊，104rpx 高，4 项；选中态 = 底色药丸 + 主色图标 + 2px 指示点 | 新增指示点 |
| SceneCard | grid(2 列) / list 两种；封面 4:3，标题 2 行截断 | 统一封面比例 |
| SoundCard | 56px 圆形色底 + 名称 + 类型 chip | 色底走 `color-mix` |
| MixTrack | 44px 滑块 + 静音 / 删除 | 滑块触控区扩到 44px |
| Segmented | 胶囊容器 + 等分药丸，选中走 `--app-surface` + `--app-shadow-1` | 统一 |
| Sheet | 底部滑入，圆角 xl，`--dur-slow` | 新增拖拽把手 |
| Dialog | 居中，`--app-overlay` 遮罩 | **修复遮罩失效** |
| EmptyState | 72px 图标容器 + 主文案 + 副文案 + 可选行动按钮 | 新增 |
| Skeleton | 1.6s shimmer，占位与真实内容同尺寸 | 新增 |
| Progress / BarChart | 6px / 12px 高，圆角 full | 统一 |
| Switch | 51×31，on 色 = `--app-primary` | 删掉 settings 里的自绘 switch |
| Chip / Badge | 高度 28（chip）/ 20（badge） | 统一 |

---

## 10. 信息架构重构

### 10.1 首页（index）— 播放优先三层

```
① 品牌行      logo + 声栖 + 时段问候语            [主题] [成就]
② 主控卡      ← 黄金位，约占首屏 42%
              场景名 + 「3/6 路」胶囊
              波形条 ──────────   ⟨ 88px 播放 ⟩
              [定时 30分] [混音] [收藏]
              空态：月亮图标 + 「选一个场景，开始你的助眠之旅」+ 去场景库
③ 场景流      快捷 chip：深度睡眠 / 专注白噪 / 林间溪流（一键播）
              分类胶囊：全部 助眠 专注 放松 自然
              2 列场景卡网格
```

**移除与去向**

| v1 区块 | v2 处理 |
|---|---|
| 金刚区 2×2（4 个大卡） | 降级为 ③ 顶部的 3 个**一键播 chip** |
| 今日精选（横滑大卡） | 移入「发现」页 |
| 最近使用（横滑） | 移入「播放历史」页 |
| 声音库入口（通栏卡） | 移入 TabBar「场景」页顶部与「我的」 |
| 首页 MiniPlayer | 与主控卡互斥，首页不渲染 |

### 10.2 导航一致性

- **全部页面统一使用自定义导航栏**（v1 里 scene-all / scene-detail / scene-edit / theme / achievement / checkin 用原生导航栏，与 custom 页混用）。
- 分类数据源统一为 `data/scenes.ts` 的 `sceneCategories`（v1 里 scene.vue 自己定义了一份 5 项，与 scene-all 不一致）。
- 二级页一律：返回 44px + 标题 + 右侧最多 1 个操作。

### 10.3 待修的功能缺陷（design 顺带发现）

1. `settings.vue` 存在**两段重复的「提醒设置」**（一段原生 switch + 一段自绘 switch，状态不同源）→ 合并为一段。
2. `settings.vue` 的 `showTimePicker` 已声明但无对应弹窗 → 死代码，补齐时间选择。
3. `library.vue` 无返回入口（custom 导航栏又没画返回键）→ 补返回。
4. `achievement.vue` 概览「3 / 38%」与 `progressPercent`（4/8=50%）不一致 → 全部改为 computed 驱动。
5. `pages.json` 里 `#F5F2ED` 写死 12 处，主题切换后导航栏不变色 → 改为运行时 `setNavigationBarColor` 跟随主题。

---

## 11. 硬编码清理清单（按优先级）

| P | 位置 | 现状 | 处理 |
|---|---|---|---|
| P0 | `history.vue` | `#C48B8B` / `rgba(196,139,139,.1)` | → `--app-danger` / `--app-danger-soft` |
| P0 | 全库 | `--app-overlay` 未定义 | 主题引擎补 `--app-overlay` |
| P0 | `settings.vue` | 行内 `#7E93A8` / `#7E9A74` | → icon 容器走 `--app-primary-soft` |
| P1 | `stats.vue` | 金银铜 6 个 hex | → `--app-rank-1/2/3` |
| P1 | `favorites.vue` / `history.vue` | 声音 color/colorSoft 12 组 hex+rgba | → 单一 sound palette map，`color-mix` 派生 |
| P1 | `discover.vue` / `onboarding.vue` | 6 组写死渐变 | → 复用主题色 token |
| P1 | `pages.json` | `#F5F2ED` / tabBar 色 12 处 | → 运行时 setNavigationBarColor |
| P2 | 全库 | `#fff` 约 12 处 | → `--app-on-primary` / `--app-surface` |
| P2 | 全库 | `rgba(0,0,0,.08/.1/.15/.38)` 内阴影与遮罩 | → `--app-shadow-*` / `--app-overlay` |
| P2 | `theme.vue` | swatch 24 个 hex 写死在组件里 | → 移到 `theme/index.ts` 的 `schemeMeta` |

---

## 12. 无障碍校验

- [x] 正文对比度 ≥ 4.5:1（12 套色板已逐套核算 primary/text 组合）
- [x] 三级文本 `--p-t3` 仅用于非关键辅助信息，对比度 ≥ 3:1
- [x] 触控目标 ≥ 44×44，相邻间距 ≥ 8px
- [x] 所有图标按钮带 `aria-label` / `accessibilityLabel`
- [x] 焦点态可见（`:focus-visible` 2px `--app-primary` 描边，2px offset）
- [x] 不依赖颜色单独传达状态（选中态同时有形状/图标变化）
- [x] `prefers-reduced-motion` 全局降级
- [x] 动态字体（iOS Dynamic Type / Android fontScale）下布局不破（用 min-height 而非固定 height）

---

## 13. 落地顺序建议

1. **主题引擎**（`theme/index.ts`）：加 `mode` 维度 → 12 套基础色板 → 补齐缺失 token
2. **基础样式**（`App.vue` / `uni.scss`）：token 化阴影/遮罩/reduced-motion/焦点态
3. **公共组件**：Icon 补齐 → TabBar / MiniPlayer / NowPlayingCard / Segmented / EmptyState / Skeleton
4. **首页**（IA 重构）→ 播放链路（scene / scene-detail / scene-edit / library）
5. **我的链路**（mine / settings / theme / achievement / checkin / stats / favorites / history / invite）
6. **发现 / 引导页**
7. **Flutter 侧**：按同一 token 表 1:1 复刻（先 theme + 组件，再页面）

---

## 附：本次交付物

- `docs/design-system/MASTER.md`（本文件）
- `html/design-preview.html` — 17 个界面 + 4 个浮层的高保真可交互视觉稿，支持 6 配色 × 3 风格 × 明暗三态实时切换
