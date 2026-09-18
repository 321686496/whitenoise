# 声栖 · 首页 Banners 分发位设计

日期：2026-09-18
状态：已获用户分节确认（位置 → 内容构成 → 呈现形式 → 点击行为 → 实现结构）

## 背景与目标

首页当前结构为 `品牌头 → 主控卡 → 场景流`，无横幅栏。首页重设计（2026-09-07）曾刻意移除运营轮播 Banner 以「效率优先、避免运营腔文案」。

现用户希望在首页新增一个 **Banners 分发位**，承载「运营内容 + 用户个性化内容」，作为信息流分发口：横滑/轮播卡片，点击进入运营活动、精选场景、个性化内容或状态页。

**分发位定位（已确认）**：信息流分发位，而非轻量状态提示。

## 目标架构：首页层级（新增 ⑧ 后）

```
⑧ 品牌头（BrandBar）
⑦ Banners 分发位（新增：本设计）★
② 主控卡（NowPlayingCard）
③+⑤ 场景流（一键播 chip + 分类 Segmented + 场景网格）
```

> Banners 栏插在品牌头之下、主控卡之上，作为首屏内容入口优先展示，不抢占播放卡黄金位（主控卡仍在可视首屏内）。

## 内容类型与来源（4 类，均数据驱动）

| 类型 type | 来源 | 点击行为 | 文案示例 |
|---|---|---|---|
| `campaign` 运营活动 | `data/banners.ts` 静态运营配置 | `navigate` → 签到/活动落地页 | 「连续签到领好礼」 |
| `featured` 今日精选 | 场景数据选 2 张（时段/心情匹配） | `play` → `applyScene` 直接开播 | 「雨夜入眠 · 一夜好眠」 |
| `personal` 个性化推荐 | `getRecent()` + 偏好标签 | `navigate` → 场景详情/声音库 | 「你常听的专注白噪，新增了下雨版」 |
| `status` 状态反馈 | `getRecent()` 派生 | `navigate` → 成就/统计页 | 「今天已助眠 2 次」 |

### 真实性约束
- 现有成就/签到/统计页**无真实数据层**（持久化仅有 `shengqi-recent` / `shengqi-theme` / `shengqi-reminder`）。
- **状态反馈卡只从 `getRecent()` 派生**（今日播放次数、上次场景），不新增空/脑补计数器。
- `status` 卡仅当近期（近 7 天）有播放记录时显示，否则整张隐藏，避免空卡。

## 数据结构（`data/banners.ts`）

```ts
type BannerType = 'campaign' | 'featured' | 'personal' | 'status'

interface BannerAction =
  | { kind: 'play'; sceneId: string }            // 应用并播放场景
  | { kind: 'navigate'; url: string }            // 跳转落地页

interface Banner {
  id: string
  type: BannerType
  title: string          // 主文案
  subtitle?: string      // 副文案
  icon: string           // Icon.vue 已定义图标名，禁 emoji
  gradient: string       // 背景渐变（主题变量 / 场景渐变）
  action: BannerAction
}
```

## 个性化组装层 `buildBanners(ctx)`

- **固定顺序**：`campaign → featured → personal → status`。
- `featured`：结合时段（早/午/晚）与最近偏好场景选取 2 张，回退到默认精选。
- `personal`：优先「偏好分类且近期未听」的场景，其次最近使用回退。
- `status`：仅近期有播放才产出该张。
- 输入 ctx 来自：时段、`getRecent()`、偏好标签（`sleep/nature` 模拟，与 `getRecommended` 一致）。
- 返回 `Banner[]` 供轮播渲染，确定性、可单测。

## 呈现形式与交互

- 全宽横滑卡片，**自动轮播**（圆点指示器 + 定时切换）。
- 兼容 `prefers-reduced-motion`：减少动效用户关闭自动切换，仅保留手动滑动。
- 卡片高约 200rpx、圆角 32rpx，视觉沿用 `.app-card` / `var(--app-*)`，随主题与 UI 风格切换。
- 点击行为见上表：`play` 复用 `applyScene()`；`navigate` 走 `uni.navigateTo`。

## 状态 / 数据流

- 横幅数据只读，不写播放状态；播放类动作统一复用 `applyScene()` / 现有播放流程。
- `banners` 用 `ref` 承载，`buildBanners()` 在 `onShow` 时刷新（与场景网格一致，防 tab 缓存不更新）。

## 组件与变更文件

1. 新增 `data/banners.ts` —— `Banner` 类型、四类配置、`buildBanners()` 个性化组装。
2. 新增 `components/BannerCarousel.vue` —— 轮播容器：接收 `Banner[]`，按 `type` 渲染背景与文案，处理自动轮播/指示器/点击动作。
3. `pages/index/index.vue` —— 在 `BrandBar` 之后、`NowPlayingCard` 之前插入 `<BannerCarousel :banners="banners" />`，并新增 `onShow` 刷新。

## 空态与兜底

- 无近期播放：`status` 卡隐藏，轮播剩余卡正常。
- `featured` 找不到匹配场景：回退默认精选场景。
- 单卡场景（如只有 1 张）：隐藏自动轮播/指示器，正常展示单卡。

## 验证方式

- `pnpm type-check` 通过。
- H5 渲染检查 6 配色 × 3 UI 风格下轮播正常（复用 `var(--app-*)`）。
- 交互逐类验证：`play` 开播、`navigate` 跳转、`status` 无数据显示隐藏、reduced-motion 关闭自动切换。