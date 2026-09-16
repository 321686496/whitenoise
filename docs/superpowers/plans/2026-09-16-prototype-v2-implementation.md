# 声栖原型 v2 全量落地 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把 Design System v2（`docs/design-system/MASTER.md` + `html/design-preview.html`）全量落地到 `prototype/src`，主题引擎/组件/17 页与品牌调性完全一致。

**Architecture:** 主题引擎重写为「配色 × UI 风格 × 明暗」三维三层 token（L0 `--p-*` → L1 `--app-*` → L2 风格覆写），运行时注入 html 根节点；旧变量名以别名过渡保证每批提交可用，全部页面迁移后统一移除。新组件承接首页播放优先 IA，数据层接口不变。

**Tech Stack:** uni-app + Vue3 `<script setup lang="ts">` + SCSS；验证 = `pnpm type-check`（vue-tsc）+ `pnpm dev:h5` 目视（原型无测试基建，spec 明确不新增测试框架）。

## Global Constraints（每个任务默认遵守）

1. **权威来源**：token 色值以 `html/design-preview.html` L0 色板（其 CSS 第 24–131 行）为准；规范语义以 `docs/design-system/MASTER.md` 为准。两者命名冲突时（preview `--app-sh-1..4` vs MASTER `--app-shadow-1..4`）**采用 MASTER.md 的 `--app-shadow-1..4`**，差异在 Task 12 回写 preview 勘误。
2. **品牌**：浅色主色 `#3D6B5E`（morandi light palette 已内置）；首页头部 logo + 「声栖」；**禁 emoji**，图标一律 `Icon.vue` SVG。
3. **禁新增自定义颜色**：所有颜色走 token；禁止 `#hex` / `rgba(0,0,0,…)` / `#fff` 直接写在页面/组件样式里（MASTER.md §11 清单清零）。
4. **rpx 换算**：preview 用 px，代码一律 **preview px × 2 = rpx**（如 preview 22px 圆角 → 44rpx）。
5. **铁律**：`.page-bg` 保持 `z-index: -1`；新拟态表面色=画布色、无描边、光源左上（凸=左上亮/右下暗，凹反转）；叠图浮层 flat=实底 / glass=毛玻璃 / neu=降级实底或毛玻璃（MASTER.md §7）。
6. **触控** ≥ 44×44px（88rpx）；按压反馈 `transform: scale(.96)` + `var(--dur-fast)`。
7. **编辑前先读目标文件完整上下文**（AGENTS.md §7.1）；每个任务结束必须 `cd prototype && pnpm type-check` 通过后 commit（conventional commit，中文描述）。
8. **变量重命名映射表**（页面/组件迁移时逐一替换；过渡期 Task 1 会同时输出旧名别名，Task 12 移除别名）：

| v1 旧变量 | v2 新变量 |
|---|---|
| `--app-card-bg` | `--app-surface` |
| `--app-card-border` | `--app-line` |
| `--app-card-shadow` | `--app-shadow-2` |
| `--app-card-blur` | `--app-blur` |
| `--app-primary-dark` | `--app-primary-strong` |
| `--app-divider` | `--app-line` |
| `--app-subtle` | `--app-surface-2` |
| `--app-input-bg` | `--app-sunken` |
| `--app-input-border` | `--app-line` |
| `--app-press` | 保留 token，值改为 `color-mix(in srgb, var(--app-text) 6%, transparent)` |

9. **布局高度变量**：`--app-tab-height: 56px`、`--app-playbar-height: 64px`（MiniPlayer 64px）。
10. **视觉对照**：迁移某页时打开 `html/design-preview.html`（浏览器或读源码），找到该页对应的界面 section，结构对齐其 DOM、样式对齐其 CSS；preview 未覆盖的细节遵循 MASTER.md。

---

### Task 1: 主题引擎 v2（theme/index.ts 全量重写）

**Files:**
- Modify: `prototype/src/theme/index.ts`（整文件替换）

**Interfaces:**
- Produces（后续所有任务依赖，签名精确）:
  - `type SchemeKey = 'morandi'|'ocean'|'forest'|'sunset'|'lavender'|'mono'`（不变）
  - `type UiMode = 'flat'|'glass'|'neu'`（不变）
  - `type ThemeMode = 'auto'|'light'|'dark'`（新增）
  - `type ResolvedMode = 'light'|'dark'`（新增）
  - `const SCHEME_KEYS: SchemeKey[]`、`const UI_MODES: UiMode[]`、`const THEME_MODES: ThemeMode[]`
  - `schemeMeta(k: SchemeKey): { label; desc; swatchLight: string[]; swatchDark: string[] }`
  - `schemePrimary(k: SchemeKey, resolved?: ResolvedMode): string`（旧调用点不传参=浅色，编译兼容）
  - `schemePrimaryDark(k: SchemeKey, resolved?: ResolvedMode): string`（@deprecated，等价 `schemePrimaryStrong`，Task 9 后由 Task 12 删）
  - `buildTokens(scheme: SchemeKey, ui: UiMode, resolved: ResolvedMode): Record<string,string>`
  - `resolveMode(mode: ThemeMode): ResolvedMode`
  - `applyTheme(scheme: SchemeKey, ui: UiMode, resolved: ResolvedMode): void`
  - `themeState: reactive<{ scheme: SchemeKey; ui: UiMode; mode: ThemeMode }>`
  - `initTheme(): void`（含 auto 模式系统监听）
  - `setTheme(scheme: SchemeKey, ui: UiMode, mode?: ThemeMode): void`

- [ ] **Step 1: 整文件替换 `theme/index.ts`**

```ts
/**
 * 声栖 · 全局主题引擎 v2
 *
 * 「配色 × UI 风格 × 明暗」三维组合生成运行时 CSS 变量，
 * 注入 html 根节点实现全局即时切换（无需重新编译）。
 *
 * Token 三层（docs/design-system/MASTER.md §2）：
 *   L0 基础色板 --p-*    scheme × mode（6 × 2 = 12 组）
 *   L1 语义     --app-*  与风格无关的稳定语义
 *   L2 组件覆写  surface / line / blur / shadow / inset 由 ui 决定
 *
 * L0 色板与 html/design-preview.html（第 24–131 行）逐值一致。
 */

export type SchemeKey = 'morandi' | 'ocean' | 'forest' | 'sunset' | 'lavender' | 'mono'
export type UiMode = 'flat' | 'glass' | 'neu'
export type ThemeMode = 'auto' | 'light' | 'dark'
export type ResolvedMode = 'light' | 'dark'

export interface SchemeMeta {
  label: string
  desc: string
  swatchLight: string[]
  swatchDark: string[]
}

/** L0 基础色板（20 位/组） */
interface Palette {
  bg: string; bgGrad: string; surface: string; surface2: string; sunken: string
  t1: string; t2: string; t3: string; line: string; lineStrong: string
  primary: string; primaryStrong: string; onPrimary: string; accent: string
  overlay: string; scrim: string
  neuA: string; neuB: string; glass: string; glassLine: string; hl: string
  danger: string; success: string; warning: string
}

const palettes: Record<SchemeKey, Record<ResolvedMode, Palette>> = {
  morandi: {
    light: { bg:'#F4F2EC', bgGrad:'#EAE6DC', surface:'#FFFFFF', surface2:'#EDEAE1', sunken:'#E9E5DA',
      t1:'#26302B', t2:'#66756D', t3:'#9AA69F', line:'#E5E0D5', lineStrong:'#D6D0C3',
      primary:'#3D6B5E', primaryStrong:'#2F544A', onPrimary:'#FFFFFF', accent:'#8FB8A0',
      overlay:'rgba(24,32,28,.42)', scrim:'24,32,28',
      neuA:'rgba(90,110,100,.18)', neuB:'rgba(255,255,255,.9)',
      glass:'rgba(255,255,255,.64)', glassLine:'rgba(255,255,255,.85)', hl:'transparent',
      danger:'#B4544C', success:'#4A8F6B', warning:'#B98A3E' },
    dark: { bg:'#101513', bgGrad:'#18211D', surface:'#1A221F', surface2:'#222B27', sunken:'#0C1210',
      t1:'#E8EDEA', t2:'#A3B2AA', t3:'#6E7D76', line:'#26312C', lineStrong:'#37443D',
      primary:'#7FBFAA', primaryStrong:'#5EA88F', onPrimary:'#0C1512', accent:'#6FA892',
      overlay:'rgba(0,0,0,.62)', scrim:'0,0,0',
      neuA:'rgba(0,0,0,.45)', neuB:'rgba(255,255,255,.055)',
      glass:'rgba(255,255,255,.07)', glassLine:'rgba(255,255,255,.13)', hl:'rgba(255,255,255,.055)',
      danger:'#E0837B', success:'#6FC295', warning:'#E0AA5E' },
  },
  ocean: {
    light: { bg:'#EFF4F5', bgGrad:'#E2EDEF', surface:'#FFFFFF', surface2:'#E6EFF1', sunken:'#DFEAEC',
      t1:'#0F2833', t2:'#5A7480', t3:'#93A8B0', line:'#DCE7EA', lineStrong:'#C6D8DD',
      primary:'#2F7F86', primaryStrong:'#1F5F65', onPrimary:'#FFFFFF', accent:'#7FC4C4',
      overlay:'rgba(15,40,51,.42)', scrim:'15,40,51',
      neuA:'rgba(60,110,120,.18)', neuB:'rgba(255,255,255,.92)',
      glass:'rgba(255,255,255,.66)', glassLine:'rgba(255,255,255,.88)', hl:'transparent',
      danger:'#B4544C', success:'#3E8C6E', warning:'#B98A3E' },
    dark: { bg:'#0B1A21', bgGrad:'#122831', surface:'#13242C', surface2:'#1B2F38', sunken:'#091820',
      t1:'#E4F1F3', t2:'#9DB6BF', t3:'#6A858F', line:'#22333C', lineStrong:'#33474F',
      primary:'#6FC9CE', primaryStrong:'#4FA9AF', onPrimary:'#04171C', accent:'#4FA3A8',
      overlay:'rgba(0,0,0,.62)', scrim:'0,0,0',
      neuA:'rgba(0,0,0,.48)', neuB:'rgba(120,190,200,.06)',
      glass:'rgba(255,255,255,.07)', glassLine:'rgba(255,255,255,.14)', hl:'rgba(255,255,255,.05)',
      danger:'#E0837B', success:'#6FC295', warning:'#E0AA5E' },
  },
  forest: {
    light: { bg:'#F1F4EA', bgGrad:'#E4EBD9', surface:'#FFFFFF', surface2:'#E9EFDF', sunken:'#E2E9D6',
      t1:'#25301F', t2:'#5F7053', t3:'#96A48A', line:'#E0E7D4', lineStrong:'#CBD6B9',
      primary:'#3F6B34', primaryStrong:'#2C4E24', onPrimary:'#FFFFFF', accent:'#8FB071',
      overlay:'rgba(37,48,31,.42)', scrim:'37,48,31',
      neuA:'rgba(70,95,55,.18)', neuB:'rgba(255,255,255,.92)',
      glass:'rgba(255,255,255,.66)', glassLine:'rgba(255,255,255,.88)', hl:'transparent',
      danger:'#B4544C', success:'#3F7A4E', warning:'#B98A3E' },
    dark: { bg:'#12170F', bgGrad:'#1A2216', surface:'#1A2016', surface2:'#232B1D', sunken:'#0F140D',
      t1:'#EAF0E3', t2:'#A6B598', t3:'#728068', line:'#27301F', lineStrong:'#38432D',
      primary:'#8FC46F', primaryStrong:'#6EA64F', onPrimary:'#0E1509', accent:'#6EA34F',
      overlay:'rgba(0,0,0,.62)', scrim:'0,0,0',
      neuA:'rgba(0,0,0,.48)', neuB:'rgba(180,230,150,.06)',
      glass:'rgba(255,255,255,.07)', glassLine:'rgba(255,255,255,.13)', hl:'rgba(255,255,255,.05)',
      danger:'#E0837B', success:'#8FD08A', warning:'#E0AA5E' },
  },
  sunset: {
    light: { bg:'#FBF3EA', bgGrad:'#F5E7D6', surface:'#FFFFFF', surface2:'#F7ECE0', sunken:'#F2E5D6',
      t1:'#3A2A20', t2:'#7A6455', t3:'#AC9683', line:'#F0E2D2', lineStrong:'#DFCAB2',
      primary:'#B4603C', primaryStrong:'#8E482B', onPrimary:'#FFFFFF', accent:'#E3A377',
      overlay:'rgba(58,42,32,.42)', scrim:'58,42,32',
      neuA:'rgba(130,90,60,.18)', neuB:'rgba(255,255,255,.92)',
      glass:'rgba(255,255,255,.66)', glassLine:'rgba(255,255,255,.88)', hl:'transparent',
      danger:'#A94F45', success:'#4A8F6B', warning:'#B98A3E' },
    dark: { bg:'#1A1310', bgGrad:'#261A14', surface:'#241A16', surface2:'#2E221C', sunken:'#150F0C',
      t1:'#F3E7DD', t2:'#BFA795', t3:'#8A7466', line:'#33251E', lineStrong:'#453229',
      primary:'#E08B5E', primaryStrong:'#BF6B42', onPrimary:'#1A0F09', accent:'#C47A50',
      overlay:'rgba(0,0,0,.62)', scrim:'0,0,0',
      neuA:'rgba(0,0,0,.5)', neuB:'rgba(255,200,160,.06)',
      glass:'rgba(255,255,255,.07)', glassLine:'rgba(255,255,255,.14)', hl:'rgba(255,255,255,.05)',
      danger:'#E0837B', success:'#6FC295', warning:'#E0AA5E' },
  },
  lavender: {
    light: { bg:'#F5F3FA', bgGrad:'#EAE5F4', surface:'#FFFFFF', surface2:'#EEEAF6', sunken:'#E7E2F1',
      t1:'#2E2A3D', t2:'#6C6486', t3:'#9E96B8', line:'#E6E1F0', lineStrong:'#D2CAE3',
      primary:'#6B5A9E', primaryStrong:'#524478', onPrimary:'#FFFFFF', accent:'#B3A5CE',
      overlay:'rgba(46,42,61,.42)', scrim:'46,42,61',
      neuA:'rgba(85,70,120,.18)', neuB:'rgba(255,255,255,.92)',
      glass:'rgba(255,255,255,.66)', glassLine:'rgba(255,255,255,.88)', hl:'transparent',
      danger:'#A94F45', success:'#4A8F6B', warning:'#B98A3E' },
    dark: { bg:'#14121C', bgGrad:'#1E1A28', surface:'#1D1A26', surface2:'#262231', sunken:'#100E17',
      t1:'#EDEAF5', t2:'#A79FC0', t3:'#746C8C', line:'#2B2637', lineStrong:'#3B3549',
      primary:'#A896E0', primaryStrong:'#8B76C6', onPrimary:'#120F1A', accent:'#8E7EC0',
      overlay:'rgba(0,0,0,.62)', scrim:'0,0,0',
      neuA:'rgba(0,0,0,.5)', neuB:'rgba(190,175,240,.06)',
      glass:'rgba(255,255,255,.07)', glassLine:'rgba(255,255,255,.14)', hl:'rgba(255,255,255,.05)',
      danger:'#E0837B', success:'#6FC295', warning:'#E0AA5E' },
  },
  mono: {
    light: { bg:'#F7F7F7', bgGrad:'#EDEDED', surface:'#FFFFFF', surface2:'#F0F0F0', sunken:'#E9E9E9',
      t1:'#171717', t2:'#616161', t3:'#9A9A9A', line:'#E8E8E8', lineStrong:'#D4D4D4',
      primary:'#2E2E2E', primaryStrong:'#141414', onPrimary:'#FFFFFF', accent:'#757575',
      overlay:'rgba(23,23,23,.42)', scrim:'23,23,23',
      neuA:'rgba(0,0,0,.14)', neuB:'rgba(255,255,255,.95)',
      glass:'rgba(255,255,255,.66)', glassLine:'rgba(255,255,255,.9)', hl:'transparent',
      danger:'#A83B32', success:'#3F7A4E', warning:'#8A6A24' },
    dark: { bg:'#0E0E0E', bgGrad:'#171717', surface:'#171717', surface2:'#202020', sunken:'#0A0A0A',
      t1:'#F2F2F2', t2:'#A8A8A8', t3:'#747474', line:'#262626', lineStrong:'#363636',
      primary:'#E4E4E4', primaryStrong:'#C4C4C4', onPrimary:'#111111', accent:'#9A9A9A',
      overlay:'rgba(0,0,0,.66)', scrim:'0,0,0',
      neuA:'rgba(0,0,0,.5)', neuB:'rgba(255,255,255,.055)',
      glass:'rgba(255,255,255,.07)', glassLine:'rgba(255,255,255,.14)', hl:'rgba(255,255,255,.05)',
      danger:'#E0837B', success:'#6FC295', warning:'#E0AA5E' },
  },
}

/* ---------------------------- L2 组件覆写（按 ui 风格） ---------------------------- */

const uiTokens: Record<UiMode, Record<string, string>> = {
  flat: {
    '--app-surface': 'var(--p-surface)',
    '--app-surface-2': 'var(--p-surface-2)',
    '--app-line': 'var(--p-line)',
    '--app-blur': '0px',
    '--app-shadow-1': '0 1px 2px rgba(var(--p-scrim), .06)',
    '--app-shadow-2': '0 4px 12px rgba(var(--p-scrim), .07), 0 1px 3px rgba(var(--p-scrim), .05)',
    '--app-shadow-3': '0 12px 28px rgba(var(--p-scrim), .10), 0 2px 6px rgba(var(--p-scrim), .06)',
    '--app-shadow-4': '0 20px 48px rgba(var(--p-scrim), .18)',
    '--app-inset': 'none',
  },
  glass: {
    '--app-surface': 'var(--p-glass)',
    '--app-surface-2': 'var(--p-glass)',
    '--app-line': 'var(--p-glass-line)',
    '--app-blur': '20px',
    '--app-shadow-1': '0 2px 8px rgba(var(--p-scrim), .06)',
    '--app-shadow-2': '0 8px 26px rgba(var(--p-scrim), .10)',
    '--app-shadow-3': '0 14px 38px rgba(var(--p-scrim), .14)',
    '--app-shadow-4': '0 24px 56px rgba(var(--p-scrim), .20)',
    '--app-inset': 'inset 0 1px 0 var(--p-hl)',
  },
  neu: {
    '--app-surface': 'var(--p-bg)',
    '--app-surface-2': 'var(--p-bg)',
    '--app-line': 'transparent',
    '--app-blur': '0px',
    '--app-shadow-1': '3px 3px 8px var(--p-neu-a), -3px -3px 8px var(--p-neu-b)',
    '--app-shadow-2': '7px 7px 16px var(--p-neu-a), -7px -7px 18px var(--p-neu-b)',
    '--app-shadow-3': '12px 12px 26px var(--p-neu-a), -10px -10px 24px var(--p-neu-b)',
    '--app-shadow-4': '18px 18px 38px var(--p-neu-a), -14px -14px 32px var(--p-neu-b)',
    '--app-inset': 'none',
  },
}

/* ---------------------------- 运行时变量组装 ---------------------------- */

export const SCHEME_KEYS: SchemeKey[] = ['morandi', 'ocean', 'forest', 'sunset', 'lavender', 'mono']
export const UI_MODES: UiMode[] = ['flat', 'glass', 'neu']
export const THEME_MODES: ThemeMode[] = ['auto', 'light', 'dark']

export const UIMODE_META: Record<UiMode, { label: string; desc: string }> = {
  flat: { label: '扁平化', desc: '清爽 / 低干扰' },
  glass: { label: '玻璃拟态', desc: '通透 / 高级感' },
  neu: { label: '新拟态', desc: '柔和 / 立体' },
}

export const THEMEMODE_META: Record<ThemeMode, { label: string }> = {
  auto: { label: '跟随系统' },
  light: { label: '浅色' },
  dark: { label: '深色' },
}

export const schemeMeta = (k: SchemeKey): SchemeMeta => {
  const p = palettes[k]
  return {
    label: META_LABEL[k],
    desc: META_DESC[k],
    swatchLight: [p.light.primary, p.light.accent, p.light.bg, p.light.danger],
    swatchDark: [p.dark.primary, p.dark.accent, p.dark.bg, p.dark.danger],
  }
}

const META_LABEL: Record<SchemeKey, string> = {
  morandi: '莫兰迪', ocean: '深海', forest: '森林', sunset: '日落', lavender: '薰衣草', mono: '极简黑白',
}
const META_DESC: Record<SchemeKey, string> = {
  morandi: '森系柔和的低饱和配色', ocean: '深邃冷静的靛蓝夜色', forest: '自然清新的苔绿色调',
  sunset: '温暖治愈的暮橙色调', lavender: '温柔静谧的淡紫配色', mono: '克制统一的黑白灰',
}

/** 当前配色/明暗下的主色 HEX（供原生组件如 switch color 绑定） */
export const schemePrimary = (k: SchemeKey, resolved: ResolvedMode = 'light') => palettes[k][resolved].primary
/** @deprecated 旧名，等价 primaryStrong；Task 12 移除 */
export const schemePrimaryDark = (k: SchemeKey, resolved: ResolvedMode = 'light') => palettes[k][resolved].primaryStrong

/** auto → 系统明暗；H5 用 matchMedia，其它端读 osTheme（失败回退浅色） */
export function resolveMode(mode: ThemeMode): ResolvedMode {
  if (mode !== 'auto') return mode
  try {
    // #ifdef H5
    if (typeof window !== 'undefined' && window.matchMedia) {
      return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light'
    }
    // #endif
    // @ts-ignore uni 运行环境
    const info = uni.getSystemInfoSync()
    return info.osTheme === 'dark' ? 'dark' : 'light'
  } catch {
    return 'light'
  }
}

/**
 * 由 配色 + UI 风格 + 明暗 计算最终 CSS 变量表。
 * 末尾输出 v1 旧变量名别名（迁移过渡期兼容），全部页面迁移后由 Task 12 移除。
 */
export function buildTokens(scheme: SchemeKey, ui: UiMode, resolved: ResolvedMode): Record<string, string> {
  const p = palettes[scheme][resolved]
  const tokens: Record<string, string> = {
    /* L0 基础色板 */
    '--p-bg': p.bg, '--p-bg-grad': p.bgGrad, '--p-surface': p.surface, '--p-surface-2': p.surface2,
    '--p-sunken': p.sunken, '--p-t1': p.t1, '--p-t2': p.t2, '--p-t3': p.t3,
    '--p-line': p.line, '--p-line-strong': p.lineStrong,
    '--p-primary': p.primary, '--p-primary-strong': p.primaryStrong, '--p-on-primary': p.onPrimary,
    '--p-accent': p.accent, '--p-overlay': p.overlay, '--p-scrim': p.scrim,
    '--p-neu-a': p.neuA, '--p-neu-b': p.neuB, '--p-glass': p.glass, '--p-glass-line': p.glassLine,
    '--p-hl': p.hl, '--p-danger': p.danger, '--p-success': p.success, '--p-warning': p.warning,
    /* L1 语义 */
    '--app-bg': 'var(--p-bg)', '--app-bg-grad': 'var(--p-bg-grad)',
    '--app-text': 'var(--p-t1)', '--app-text-2': 'var(--p-t2)', '--app-text-3': 'var(--p-t3)',
    '--app-line-strong': 'var(--p-line-strong)',
    '--app-primary': 'var(--p-primary)', '--app-primary-strong': 'var(--p-primary-strong)',
    '--app-on-primary': 'var(--p-on-primary)', '--app-accent': 'var(--p-accent)',
    '--app-primary-soft': 'color-mix(in srgb, var(--p-primary) 14%, transparent)',
    '--app-primary-soft-2': 'color-mix(in srgb, var(--p-primary) 24%, transparent)',
    '--app-overlay': 'var(--p-overlay)', '--app-sunken': 'var(--p-sunken)',
    '--app-danger': 'var(--p-danger)', '--app-success': 'var(--p-success)', '--app-warning': 'var(--p-warning)',
    '--app-danger-soft': 'color-mix(in srgb, var(--p-danger) 13%, transparent)',
    '--app-rank-1': 'linear-gradient(135deg,#F0C27F,#E8A849)',
    '--app-rank-2': 'linear-gradient(135deg,#C0C7CF,#9EA8B3)',
    '--app-rank-3': 'linear-gradient(135deg,#D4A373,#BC8A5F)',
    '--app-press': 'color-mix(in srgb, var(--app-text) 6%, transparent)',
    /* 布局高度 */
    '--app-tab-height': '56px',
    '--app-playbar-height': '64px',
    /* L2 组件覆写 */
    ...uiTokens[ui],
    /* v1 兼容别名（Task 12 移除） */
    '--app-card-bg': 'var(--app-surface)',
    '--app-card-border': 'var(--app-line)',
    '--app-card-shadow': 'var(--app-shadow-2)',
    '--app-card-blur': 'var(--app-blur)',
    '--app-primary-dark': 'var(--app-primary-strong)',
    '--app-divider': 'var(--app-line)',
    '--app-subtle': 'var(--app-surface-2)',
    '--app-input-bg': 'var(--app-sunken)',
    '--app-input-border': 'var(--app-line)',
  }
  return tokens
}

/** 直接注入到 html 根节点 */
export function applyTheme(scheme: SchemeKey, ui: UiMode, resolved: ResolvedMode) {
  if (typeof document === 'undefined' || !document.documentElement) return
  const el = document.documentElement
  Object.entries(buildTokens(scheme, ui, resolved)).forEach(([k, v]) => el.style.setProperty(k, v))
  el.dataset.scheme = scheme
  el.dataset.ui = ui
  el.dataset.mode = resolved
}

/* ------------------- 轻量响应式状态 + 系统明暗跟随 ------------------- */
import { reactive } from 'vue'

export const themeState = reactive<{ scheme: SchemeKey; ui: UiMode; mode: ThemeMode }>({
  scheme: 'morandi',
  ui: 'flat',
  mode: 'auto',
})

function reapply() {
  applyTheme(themeState.scheme, themeState.ui, resolveMode(themeState.mode))
}

/** H5 下跟随系统明暗变化（auto 模式） */
function watchSystemMode() {
  // #ifdef H5
  if (typeof window === 'undefined' || !window.matchMedia) return
  const mq = window.matchMedia('(prefers-color-scheme: dark)')
  mq.addEventListener?.('change', reapply)
  // #endif
}

export function initTheme() {
  let scheme: SchemeKey = 'morandi'
  let ui: UiMode = 'flat'
  let mode: ThemeMode = 'auto'
  try {
    // @ts-ignore
    const saved = uni.getStorageSync('shengqi-theme') || {}
    if (saved.scheme && SCHEME_KEYS.includes(saved.scheme)) scheme = saved.scheme
    if (saved.ui && UI_MODES.includes(saved.ui)) ui = saved.ui
    if (saved.mode && THEME_MODES.includes(saved.mode)) mode = saved.mode
  } catch {}
  themeState.scheme = scheme
  themeState.ui = ui
  themeState.mode = mode
  reapply()
  watchSystemMode()
}

export function setTheme(scheme: SchemeKey, ui: UiMode, mode: ThemeMode = themeState.mode) {
  themeState.scheme = scheme
  themeState.ui = ui
  themeState.mode = mode
  reapply()
  try {
    // @ts-ignore
    uni.setStorageSync('shengqi-theme', { scheme, ui, mode })
  } catch {}
}
```

- [ ] **Step 2: 类型检查**

Run: `cd prototype && pnpm type-check`
Expected: 无错误（旧调用点 `schemePrimary(k)` / `schemePrimaryDark(k)` 因可选参数保持编译通过；`setTheme(scheme, ui)` 同理）。若报 `includes` 参数类型错误，将 `SCHEME_KEYS.includes(saved.scheme as SchemeKey)` 方式断言修正。

- [ ] **Step 3: Commit**

```bash
cd prototype && git add src/theme/index.ts && git commit -m "feat(prototype): 主题引擎 v2（明暗双模式 + 三层 token + 品牌色回归 #3D6B5E）"
```

---

### Task 2: 基础样式迁移（App.vue / uni.scss）

**Files:**
- Modify: `prototype/src/App.vue`（仅 `<style>` 块；`<script>` 不动）
- Modify: `prototype/src/uni.scss`（如存在 `$uni-font-size-base`，改为 `15px`）

**Interfaces:**
- Consumes: Task 1 的 `--app-*` 全套 token
- Produces: 公共类 `.btn-primary / .btn-outline / .app-card / .page-title / .section-title / .page-subtitle / .divider / .safe-bottom / .page-bg / .page-container`（类名不变，值迁移 v2）

- [ ] **Step 1: 替换 App.vue `<style>` 块内容为以下规则（保留既有 `<script setup>` 与 `@import '@/uni.scss'`）**

关键规则（未列出的保留原结构、替换 token 名）：

```scss
page {
  background-color: var(--app-bg);
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'PingFang SC', 'HarmonyOS Sans SC', 'Noto Sans SC', 'Microsoft YaHei', sans-serif;
  color: var(--app-text);
  font-size: 30rpx;   /* 基准 15px */
  line-height: 1.55;
  -webkit-font-smoothing: antialiased;
}

/* 数字/计时专用（tabular-nums 防跳动） */
.num { font-variant-numeric: tabular-nums; }

.page-bg {
  position: fixed; left: 0; top: 0; right: 0; height: 440rpx;
  background: linear-gradient(180deg, var(--app-bg-grad) 0%, var(--app-bg) 70%, transparent 100%);
  pointer-events: none;
  z-index: -1; /* 铁律：不得改 */
}

.page-container {
  position: relative; z-index: 1; min-height: 100vh;
  padding: calc(env(safe-area-inset-top, 0rpx) + 24rpx) 40rpx calc(var(--app-tab-height, 56px) + var(--app-playbar-height, 64px) + 56rpx);
  box-sizing: border-box; background: transparent;
  animation: iosPageIn var(--dur-page, 380ms) var(--ease-std, cubic-bezier(.32,.72,0,1)) backwards;
}

/* 动效 token 未注入时的静态兜底 + 全局 reduced-motion */
:root { --dur-fast:160ms; --dur-base:220ms; --dur-slow:320ms; --dur-page:380ms;
        --ease-std:cubic-bezier(.32,.72,0,1); --ease-out:cubic-bezier(.2,0,0,1); --ease-in:cubic-bezier(.4,0,1,1); }
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after { animation-duration: .01ms !important; animation-iteration-count: 1 !important; transition-duration: .01ms !important; scroll-behavior: auto !important; }
}

:focus-visible { outline: 2px solid var(--app-primary); outline-offset: 2px; }

.btn-primary {
  background: var(--app-primary); color: var(--app-on-primary);
  border-radius: 999rpx; padding: 22rpx 44rpx; font-size: 29rpx; font-weight: 600;
  display: flex; align-items: center; justify-content: center; border: none;
  box-shadow: var(--app-shadow-2);
  transition: transform var(--dur-fast) var(--ease-std), opacity var(--dur-fast) var(--ease-std);
  &:active { transform: scale(.96); }
}
.btn-outline {
  background: transparent; color: var(--app-primary);
  border: 1rpx solid color-mix(in srgb, var(--app-primary) 55%, transparent);
  border-radius: 999rpx; padding: 20rpx 44rpx; font-size: 29rpx; font-weight: 600;
  display: flex; align-items: center; justify-content: center;
  transition: background var(--dur-fast) var(--ease-std);
  &:active { background: var(--app-primary-soft); transform: scale(.96); }
}
.app-card {
  background: var(--app-surface);
  border: 1rpx solid var(--app-line);
  border-radius: 44rpx; /* MASTER.md 卡片 lg 22px */
  box-shadow: var(--app-shadow-2), var(--app-inset);
  backdrop-filter: blur(var(--app-blur));
  -webkit-backdrop-filter: blur(var(--app-blur));
}
.page-title { font-size: 48rpx; font-weight: 700; letter-spacing: -0.4rpx; line-height: 1.22; color: var(--app-text); }
.section-title { font-size: 24rpx; font-weight: 600; letter-spacing: 0.3rpx; color: var(--app-text-2); margin-bottom: 16rpx; padding-left: 8rpx; display: block; }
.divider { height: 1rpx; background: var(--app-line); }
```

- [ ] **Step 2: 类型检查 + 目视**

Run: `cd prototype && pnpm type-check`
Run: `cd prototype && pnpm dev:h5` → 打开首页，切换明暗（DevTools 模拟 `prefers-color-scheme`）与 3 种 UI 风格（临时在 Console 执行 `uni.setStorageSync('shengqi-theme',{scheme:'morandi',ui:'glass',mode:'dark'})` 后刷新），确认无白屏、卡片描边/阴影随风格变化、玻璃卡有模糊。
Expected: 编译 0 错误；dark 模式背景近黑带绿相、morandi 主色浅色为 `#3D6B5E`。

- [ ] **Step 3: Commit**

```bash
cd prototype && git add src/App.vue src/uni.scss && git commit -m "feat(prototype): 全局样式迁移 v2（阴影/遮罩/动效 token 化 + reduced-motion + 焦点态）"
```

---

### Task 3: 基件组件（NavBar / EmptyState / Skeleton / Segmented）

**Files:**
- Create: `prototype/src/components/NavBar.vue`
- Create: `prototype/src/components/EmptyState.vue`
- Create: `prototype/src/components/Skeleton.vue`
- Create: `prototype/src/components/Segmented.vue`

**Interfaces:**
- Produces:
  - `NavBar`: props `{ title: string; back?: boolean (default true) }`；emits 无（返回走 `uni.navigateBack`，无历史时 `uni.reLaunch('/pages/index/index')`）
  - `EmptyState`: props `{ icon?: string (default 'moon'); title: string; desc?: string; actionText?: string }`；emit `action`
  - `Skeleton`: props `{ type: 'card'|'list'|'grid'; count?: number (default 3) }`
  - `Segmented`: props `{ options: { key: string; label: string }[]; modelValue: string }`；emit `update:modelValue`

- [ ] **Step 1: 创建 NavBar.vue**

```vue
<template>
  <view class="nav-bar">
    <view class="nav-side">
      <view v-if="back" class="nav-btn" @click="goBack" aria-label="返回">
        <Icon name="chevron-left" :size="22" />
      </view>
    </view>
    <text class="nav-title">{{ title }}</text>
    <view class="nav-side nav-side--right"><slot name="action" /></view>
  </view>
</template>

<script setup lang="ts">
import Icon from '@/components/Icon.vue'
defineProps<{ title: string; back?: boolean }>()
function goBack() {
  const pages = getCurrentPages()
  if (pages.length > 1) uni.navigateBack()
  else uni.reLaunch({ url: '/pages/index/index' })
}
</script>

<style lang="scss" scoped>
.nav-bar {
  display: flex; align-items: center; height: 88rpx;
  padding: calc(env(safe-area-inset-top, 0rpx)) 0 0 0; margin-bottom: 8rpx;
}
.nav-side { width: 88rpx; display: flex; align-items: center; }
.nav-side--right { justify-content: flex-end; }
.nav-btn {
  width: 88rpx; height: 88rpx; margin-left: -16rpx;
  display: flex; align-items: center; justify-content: center;
  border-radius: 999rpx; color: var(--app-text);
  transition: transform var(--dur-fast) var(--ease-std);
  &:active { transform: scale(.96); background: var(--app-press); }
}
.nav-title {
  flex: 1; text-align: center; font-size: 34rpx; font-weight: 600;
  color: var(--app-text); letter-spacing: -0.2rpx;
}
</style>
```

- [ ] **Step 2: 创建 EmptyState.vue**

```vue
<template>
  <view class="empty">
    <view class="empty-ic"><Icon :name="icon" :size="34" /></view>
    <text class="empty-title">{{ title }}</text>
    <text v-if="desc" class="empty-desc">{{ desc }}</text>
    <view v-if="actionText" class="empty-btn" @click="$emit('action')">{{ actionText }}</view>
  </view>
</template>

<script setup lang="ts">
import Icon from '@/components/Icon.vue'
withDefaults(defineProps<{ icon?: string; title: string; desc?: string; actionText?: string }>(), { icon: 'moon' })
defineEmits<{ (e: 'action'): void }>()
</script>

<style lang="scss" scoped>
.empty { display: flex; flex-direction: column; align-items: center; padding: 96rpx 48rpx; }
.empty-ic {
  width: 144rpx; height: 144rpx; border-radius: 999rpx;
  background: var(--app-surface-2); color: var(--app-text-3);
  display: flex; align-items: center; justify-content: center; margin-bottom: 32rpx;
  box-shadow: var(--app-inset);
}
.empty-title { font-size: 32rpx; font-weight: 600; color: var(--app-text); }
.empty-desc { font-size: 26rpx; color: var(--app-text-2); margin-top: 12rpx; text-align: center; line-height: 1.5; }
.empty-btn {
  margin-top: 40rpx; padding: 20rpx 56rpx; border-radius: 999rpx;
  background: var(--app-primary); color: var(--app-on-primary);
  font-size: 28rpx; font-weight: 600; box-shadow: var(--app-shadow-2);
  transition: transform var(--dur-fast) var(--ease-std);
  &:active { transform: scale(.96); }
}
</style>
```

- [ ] **Step 3: 创建 Skeleton.vue**

```vue
<template>
  <view class="sk-wrap">
    <view v-for="i in count" :key="i" class="sk-row" :class="'sk-row--' + type">
      <view class="sk sk-media" />
      <view class="sk-lines">
        <view class="sk sk-line" style="width: 62%" />
        <view class="sk sk-line" style="width: 38%" />
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
withDefaults(defineProps<{ type?: 'card' | 'list' | 'grid'; count?: number }>(), { type: 'list', count: 3 })
</script>

<style lang="scss" scoped>
.sk { background: var(--app-surface-2); border-radius: 16rpx; overflow: hidden; position: relative; }
.sk::after {
  content: ''; position: absolute; inset: 0;
  background: linear-gradient(90deg, transparent, color-mix(in srgb, var(--app-text) 6%, transparent), transparent);
  animation: skShimmer 1.6s ease-in-out infinite;
}
@keyframes skShimmer { 0% { transform: translateX(-100%); } 100% { transform: translateX(100%); } }
.sk-wrap { display: flex; flex-direction: column; gap: 24rpx; }
.sk-row { display: flex; gap: 24rpx; align-items: center; }
.sk-row--grid, .sk-row--card { display: block; }
.sk-media { width: 112rpx; height: 112rpx; flex: none; }
.sk-lines { flex: 1; display: flex; flex-direction: column; gap: 16rpx; }
.sk-line { height: 28rpx; }
@media (prefers-reduced-motion: reduce) { .sk::after { animation: none; } }
</style>
```

- [ ] **Step 4: 创建 Segmented.vue**

```vue
<template>
  <view class="seg">
    <view
      v-for="opt in options" :key="opt.key"
      class="seg-item" :class="{ on: opt.key === modelValue }"
      @click="$emit('update:modelValue', opt.key)"
    >
      <text>{{ opt.label }}</text>
    </view>
  </view>
</template>

<script setup lang="ts">
defineProps<{ options: { key: string; label: string }[]; modelValue: string }>()
defineEmits<{ (e: 'update:modelValue', key: string): void }>()
</script>

<style lang="scss" scoped>
.seg {
  display: flex; gap: 8rpx; padding: 8rpx;
  background: var(--app-surface-2); border-radius: 999rpx; border: 1rpx solid var(--app-line);
}
.seg-item {
  flex: 1; height: 64rpx; display: flex; align-items: center; justify-content: center;
  border-radius: 999rpx; font-size: 26rpx; color: var(--app-text-2); font-weight: 500;
  transition: all var(--dur-base) var(--ease-std);
}
.seg-item.on {
  background: var(--app-surface); color: var(--app-text); font-weight: 600;
  box-shadow: var(--app-shadow-1);
}
/* neu 风格下选中 = 凹陷（方向反转），与铁律一致 */
:root[data-ui='neu'] &.seg-item.on { box-shadow: inset 4rpx 4rpx 8rpx var(--p-neu-a), inset -4rpx -4rpx 8rpx var(--p-neu-b); background: var(--app-bg); }
</style>
```

- [ ] **Step 5: 类型检查**

Run: `cd prototype && pnpm type-check`
Expected: 0 错误。若 `Icon` 无 `chevron-left` 会编译通过但渲染空——该图标在 Task 4 补齐，此任务不阻塞。

- [ ] **Step 6: Commit**

```bash
cd prototype && git add src/components/NavBar.vue src/components/EmptyState.vue src/components/Skeleton.vue src/components/Segmented.vue && git commit -m "feat(prototype): 新增 NavBar/EmptyState/Skeleton/Segmented 基件（v2 规格）"
```

---

### Task 4: Icon 补齐 + BrandBar + NowPlayingCard

**Files:**
- Modify: `prototype/src/components/Icon.vue`（新增 10 个图标分支）
- Create: `prototype/src/components/BrandBar.vue`
- Create: `prototype/src/components/NowPlayingCard.vue`

**Interfaces:**
- Consumes: `usePlayer` 的 `player`（`currentScene: Scene|null`、`tracks: Track[]`、`isPlaying: boolean`、`timerMinutes`、`showTimerPanel`、`showMixPanel`）、`applyScene(scene)`、`togglePlay(): boolean`、`setTimer(minutes)`；`Scene` 含 `id/name/iconName/gradient/soundIds`
- Produces:
  - `BrandBar`: 无 props；右侧两个 44px 图标钮，点击 `uni.navigateTo` 到 `/pages/theme/theme` 与 `/pages/achievement/achievement`
  - `NowPlayingCard`: 无 props；内部自持播放状态绑定
  - Icon 新增 iconName：`play` `pause` `timer` `shuffle` `heart` `chevron-left` `chevron-right` `palette` `award` `sun` `contrast`

- [ ] **Step 1: Icon.vue 新增图标分支（在最后一个 `v-else-if` 之后追加，风格与现有一致：24×24 stroke 2）**

```html
<!-- 播放/暂停 -->
<template v-else-if="name === 'play'"><path d="M7 4.5v15l13-7.5L7 4.5z" /></template>
<template v-else-if="name === 'pause'"><path d="M8 4v16M16 4v16" /></template>
<!-- 定时 -->
<template v-else-if="name === 'timer'"><circle cx="12" cy="13" r="8" /><path d="M12 9.5v3.5l2.5 2.5M9.5 2h5" /></template>
<!-- 混音 -->
<template v-else-if="name === 'shuffle'"><path d="M16 3h5v5M4 20L21 3M21 16v5h-5M15 15l6 6M4 4l5 5" /></template>
<!-- 收藏 -->
<template v-else-if="name === 'heart'"><path d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.7l-1-1.1a5.5 5.5 0 0 0-7.8 7.8l1 1.1L12 21.2l7.8-7.7 1-1.1a5.5 5.5 0 0 0 0-7.8z" /></template>
<!-- 导航箭头 -->
<template v-else-if="name === 'chevron-left'"><path d="M15 18l-6-6 6-6" /></template>
<template v-else-if="name === 'chevron-right'"><path d="M9 18l6-6-6-6" /></template>
<!-- 主题/成就/明暗 -->
<template v-else-if="name === 'palette'"><path d="M12 3a9 9 0 1 0 .5 18c1.2 0 1.8-.9 1.8-1.8 0-.5-.2-.9-.5-1.2-.3-.3-.5-.7-.5-1.2 0-1 .8-1.8 1.8-1.8H17a4 4 0 0 0 4-4c0-4.4-4-8-9-8z" /><circle cx="7.5" cy="11" r="0.6" /><circle cx="10" cy="7.5" r="0.6" /><circle cx="14" cy="7" r="0.6" /><circle cx="16.8" cy="10" r="0.6" /></template>
<template v-else-if="name === 'award'"><circle cx="12" cy="9" r="6" /><path d="M8.6 14.2L7.5 22l4.5-2.5L16.5 22l-1.1-7.8" /></template>
<template v-else-if="name === 'sun'"><circle cx="12" cy="12" r="4.5" /><path d="M12 2v2.5M12 19.5V22M2 12h2.5M19.5 12H22M4.9 4.9l1.8 1.8M17.3 17.3l1.8 1.8M19.1 4.9l-1.8 1.8M6.7 17.3l-1.8 1.8" /></template>
<template v-else-if="name === 'contrast'"><circle cx="12" cy="12" r="9" /><path d="M12 3v18" /></template>
```

同时在 Icon.vue 的 props 类型注释/文档注释中登记以上 11 个名字（保持 `name: string` 不变即可，无类型改动）。

- [ ] **Step 2: 创建 BrandBar.vue**

```vue
<template>
  <view class="brand-bar">
    <image class="brand-logo" src="/static/logo.png" mode="aspectFill" />
    <view class="brand-text">
      <text class="brand-name">声栖</text>
      <text class="brand-greet">{{ greeting }}</text>
    </view>
    <view class="brand-actions">
      <view class="brand-btn" aria-label="主题" @click="go('/pages/theme/theme')"><Icon name="palette" :size="20" /></view>
      <view class="brand-btn" aria-label="成就" @click="go('/pages/achievement/achievement')"><Icon name="award" :size="20" /></view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import Icon from '@/components/Icon.vue'
const greeting = computed(() => {
  const h = new Date().getHours()
  if (h < 5) return '夜深了，愿你好眠'
  if (h < 11) return '早上好'
  if (h < 13) return '中午好'
  if (h < 18) return '下午好'
  return '晚上好'
})
function go(url: string) {
  uni.navigateTo({ url })
}
</script>

<style lang="scss" scoped>
.brand-bar { display: flex; align-items: center; gap: 20rpx; margin-bottom: 32rpx; }
.brand-logo { width: 88rpx; height: 88rpx; border-radius: 28rpx; flex: none; }
.brand-text { flex: 1; display: flex; flex-direction: column; gap: 4rpx; }
.brand-name { font-size: 40rpx; font-weight: 700; letter-spacing: -0.4rpx; color: var(--app-text); }
.brand-greet { font-size: 24rpx; color: var(--app-text-2); }
.brand-actions { display: flex; gap: 8rpx; }
.brand-btn {
  width: 88rpx; height: 88rpx; border-radius: 999rpx;
  background: var(--app-surface); border: 1rpx solid var(--app-line);
  box-shadow: var(--app-shadow-1), var(--app-inset);
  display: flex; align-items: center; justify-content: center; color: var(--app-text-2);
  transition: transform var(--dur-fast) var(--ease-std);
  &:active { transform: scale(.96); }
}
</style>
```

（若 `/static/logo.png` 实际文件名不同，以 `ls prototype/src/static` 结果为准，用现有 logo 路径。）

- [ ] **Step 3: 创建 NowPlayingCard.vue（首页黄金位主控卡）**

视觉对照：`html/design-preview.html` 中「首页」界面的主控卡 section。结构：场景名 + 路数胶囊 / 波形条 + 88px 播放键 / 三个次级操作（定时 / 混音 / 收藏）；空态为月亮 + 引导文案 + 「去场景库」。

```vue
<template>
  <view class="npc app-card">
    <!-- 空态 -->
    <template v-if="!player.currentScene">
      <view class="npc-empty">
        <view class="npc-empty-ic"><Icon name="moon" :size="34" /></view>
        <text class="npc-empty-t">选一个场景，开始你的助眠之旅</text>
        <view class="npc-empty-btn" @click="goLibrary">去场景库</view>
      </view>
    </template>
    <!-- 播放态 -->
    <template v-else>
      <view class="npc-head">
        <text class="npc-name">{{ player.currentScene.name }}</text>
        <view class="npc-pill num">{{ player.tracks.length }}/{{ player.tracks.length }} 路</view>
      </view>
      <view class="npc-body">
        <view class="npc-wave" :class="{ paused: !player.isPlaying }" aria-hidden="true">
          <view v-for="i in 5" :key="i" class="npc-wave-bar" :style="{ animationDelay: (i * 0.12) + 's' }" />
        </view>
        <view class="npc-play" :aria-label="player.isPlaying ? '暂停' : '播放'" @click="onToggle">
          <Icon :name="player.isPlaying ? 'pause' : 'play'" :size="34" />
        </view>
      </view>
      <view class="npc-actions">
        <view class="npc-act" :class="{ on: player.timerMinutes > 0 }" aria-label="定时" @click="onTimer">
          <Icon name="timer" :size="20" />
          <text class="num">{{ player.timerMinutes > 0 ? player.timerMinutes + '分' : '定时' }}</text>
        </view>
        <view class="npc-act" aria-label="混音" @click="onMix">
          <Icon name="shuffle" :size="20" /><text>混音</text>
        </view>
        <view class="npc-act" :class="{ on: fav }" aria-label="收藏" @click="toggleFav">
          <Icon name="heart" :size="20" /><text>{{ fav ? '已收藏' : '收藏' }}</text>
        </view>
      </view>
    </template>
  </view>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import Icon from '@/components/Icon.vue'
import { player, togglePlay, setTimer } from '@/composables/usePlayer'

const fav = ref(false) // 收藏态接入 favorites 数据层（Task 11 前 UI 态即可，见计划备注）

const onToggle = () => {
  const ok = togglePlay()
  if (!ok) uni.showToast({ title: '请先选择场景', icon: 'none' })
}
const onTimer = () => { setTimer(30) }
const onMix = () => { player.showMixPanel = true }
const goLibrary = () => uni.navigateTo({ url: '/pages/library/library' })
function toggleFav() { fav.value = !fav.value }
</script>

<style lang="scss" scoped>
.npc { padding: 40rpx; display: flex; flex-direction: column; gap: 32rpx; }
.npc-empty { display: flex; flex-direction: column; align-items: center; gap: 24rpx; padding: 24rpx 0; }
.npc-empty-ic {
  width: 128rpx; height: 128rpx; border-radius: 999rpx;
  background: var(--app-primary-soft); color: var(--app-primary);
  display: flex; align-items: center; justify-content: center;
}
.npc-empty-t { font-size: 28rpx; color: var(--app-text-2); }
.npc-empty-btn {
  padding: 18rpx 52rpx; border-radius: 999rpx;
  background: var(--app-primary); color: var(--app-on-primary); font-size: 27rpx; font-weight: 600;
  box-shadow: var(--app-shadow-2);
  transition: transform var(--dur-fast) var(--ease-std);
  &:active { transform: scale(.96); }
}
.npc-head { display: flex; align-items: center; justify-content: space-between; }
.npc-name { font-size: 38rpx; font-weight: 700; color: var(--app-text); letter-spacing: -0.3rpx; }
.npc-pill {
  padding: 8rpx 24rpx; border-radius: 999rpx; font-size: 22rpx; font-weight: 600;
  background: var(--app-primary-soft); color: var(--app-primary);
}
.npc-body { display: flex; align-items: center; gap: 32rpx; }
.npc-wave { flex: 1; display: flex; align-items: center; gap: 10rpx; height: 88rpx; }
.npc-wave-bar {
  width: 8rpx; border-radius: 999rpx; background: var(--app-primary);
  height: 30%; animation: npcBreath 1.6s ease-in-out infinite;
}
.npc-wave-bar:nth-child(2) { height: 55%; } .npc-wave-bar:nth-child(3) { height: 85%; }
.npc-wave-bar:nth-child(4) { height: 55%; } .npc-wave-bar:nth-child(5) { height: 30%; }
.npc-wave.paused .npc-wave-bar { animation-play-state: paused; opacity: .4; }
@keyframes npcBreath { 0%, 100% { transform: scaleY(.6); } 50% { transform: scaleY(1); } }
@media (prefers-reduced-motion: reduce) { .npc-wave-bar { animation: none; } }
.npc-play {
  width: 176rpx; height: 176rpx; border-radius: 999rpx; flex: none;
  background: linear-gradient(135deg, var(--app-primary), var(--app-primary-strong));
  color: var(--app-on-primary); box-shadow: var(--app-shadow-3);
  display: flex; align-items: center; justify-content: center;
  transition: transform var(--dur-fast) var(--ease-std);
  &:active { transform: scale(.96); }
}
.npc-actions { display: flex; justify-content: space-around; }
.npc-act {
  display: flex; align-items: center; gap: 10rpx; padding: 16rpx 24rpx;
  border-radius: 999rpx; font-size: 24rpx; color: var(--app-text-2);
  background: var(--app-surface-2); border: 1rpx solid var(--app-line);
  transition: transform var(--dur-fast) var(--ease-std), color var(--dur-fast), background var(--dur-fast);
  &:active { transform: scale(.96); }
  &.on { color: var(--app-primary); background: var(--app-primary-soft); border-color: transparent; }
}
</style>
```

备注（实现时照做）：`fav` 收藏态本轮为 UI 态即可，Task 11 统一接入收藏数据层；`onTimer` 简化为 30 分钟快捷定时（setTimer 自带同值取消）。

- [ ] **Step 4: 类型检查**

Run: `cd prototype && pnpm type-check`
Expected: 0 错误。

- [ ] **Step 5: Commit**

```bash
cd prototype && git add src/components/Icon.vue src/components/BrandBar.vue src/components/NowPlayingCard.vue && git commit -m "feat(prototype): Icon 补 11 个图标，新增 BrandBar/NowPlayingCard 主控卡"
```

---

### Task 5: 既有组件 v2 化（TabBar / PlayBar / SceneCard / SoundCard / MixTrack）

**Files:**
- Modify: `prototype/src/components/TabBar.vue`
- Modify: `prototype/src/components/PlayBar.vue`
- Modify: `prototype/src/components/SceneCard.vue`
- Modify: `prototype/src/components/SceneCard.vue` 引用方无需改（props 不变）
- Modify: `prototype/src/components/SoundCard.vue`
- Modify: `prototype/src/components/MixTrack.vue`

**Interfaces:**
- Consumes: 全局 token（Task 1）
- Produces: 各组件 props/emits 保持不变（调用方零改动）；`TabBar` 选中态新增指示点；`PlayBar` 高度 64px 并**仅在非首页渲染**（互斥规则，本任务先做样式，互斥逻辑在 Task 6 随首页落地）；`SceneCard` 封面统一 4:3；`SoundCard` 色底 `color-mix`；`MixTrack` 滑块 44px 触控

- [ ] **Step 1: TabBar.vue** — 选中态改为：整项底色药丸（`background: var(--app-primary-soft); border-radius: 999rpx`）+ 图标主色 + 项内底部 6rpx×24rpx 指示点（`background: var(--app-primary); border-radius: 999rpx`）；容器悬浮胶囊样式保留，底色 `var(--app-surface)`、描边 `var(--app-line)`、阴影 `var(--app-shadow-3), var(--app-inset)`；高度改为 112rpx（56px）。item 高度 88rpx 保持触控达标。

- [ ] **Step 2: PlayBar.vue** — 容器高度改为 128rpx（64px），底 `var(--app-surface)`、描边 `var(--app-line)`、阴影 `var(--app-shadow-3)`、圆角 44rpx 44rpx 0 0（吸底时）或悬浮胶囊；内部播放键 88rpx、文案字号按 v2 字排表（Title-3 16px=32rpx 主文案、Caption 12px=24rpx 次级）。样式替换遵循全局映射表（`--app-card-*` → 新 token）。

- [ ] **Step 3: SceneCard.vue** — 封面容器固定 `aspect-ratio: 4 / 3; width: 100%;`（grid 形态）并 `overflow: hidden; border-radius: 32rpx`；标题 `font-size: 30rpx; font-weight: 600; line-height: 1.3;`，两行截断（`display:-webkit-box; -webkit-line-clamp:2; -webkit-box-orient:vertical; overflow:hidden`）；卡片底 `var(--app-surface)`、描边 `var(--app-line)`、阴影 `var(--app-shadow-2), var(--app-inset)`；按压 `transform: scale(.96)`。list 形态封面 160rpx×120rpx（4:3）。

- [ ] **Step 4: SoundCard.vue** — 图标容器 112rpx 圆形，底色改：

```scss
.sound-icon { background: color-mix(in srgb, var(--sound-color) 16%, var(--app-surface)); color: var(--sound-color); }
/* 深色模式提亮，避免暗底发灰 */
:root[data-mode='dark'] & { background: color-mix(in srgb, var(--sound-color) 22%, var(--app-surface)); }
```

（`--sound-color` 由组件 `:style` 绑定声音自身的 `color` 资产值注入；移除组件内所有 rgba/hex 底色。）

- [ ] **Step 5: MixTrack.vue** — 滑轨高 6rpx 槽（`background: var(--app-sunken); border-radius: 999rpx`），滑块与整行触控高 ≥ 88rpx；删除/静音按钮 88rpx 触控、图标色 `--app-text-3` / 危险操作 `--app-danger`。

- [ ] **Step 6: 类型检查 + 目视**

Run: `cd prototype && pnpm type-check`
Expected: 0 错误。dev:h5 目视：tab 选中态出现指示点；场景卡封面为 4:3 不变形。

- [ ] **Step 7: Commit**

```bash
cd prototype && git add src/components/TabBar.vue src/components/PlayBar.vue src/components/SceneCard.vue src/components/SoundCard.vue src/components/MixTrack.vue && git commit -m "refactor(prototype): 五个公共组件迁移 v2 token 与规格（TabBar 指示点/4:3 封面/color-mix 色底/44px 滑轨）"
```

---

### Task 6: 首页 index IA 重构（播放优先三层）

**Files:**
- Modify: `prototype/src/pages/index/index.vue`（整页重构）
- Modify: `prototype/src/pages.json`（不动 index 条目——已是 custom）

**Interfaces:**
- Consumes: `BrandBar`、`NowPlayingCard`（Task 4）、`SceneCard`（Task 5）、`homeScenes`、`sceneCategories`、`getCategoryScenes(category, limit)`、`applyScene(scene)`（一键播 chip 直接 `applyScene`）、`onShow` 刷新推荐（沿用 v1 约定：推荐区用 `ref` 承载并在 `onShow` 重新拉取）
- Produces: 首页结构（后续页面无需依赖）

- [ ] **Step 1: 重写 index.vue `<template>` 为三层结构**

```
① <BrandBar />
② <NowPlayingCard />            ← 黄金位
③ 场景流：
   快捷 chip 行：深度睡眠 / 专注白噪 / 林间溪流（各绑定 homeScenes 中对应场景，点击 applyScene(scene)，无 toast）
   分类胶囊 Segmented：全部/助眠/专注/放松/自然（数据源 sceneCategories，v-model="activeCat"）
   2 列场景网格：<SceneCard v-for="getCategoryScenes(activeCat, 20)">，点击 navigateTo scene-detail
```

- [ ] **Step 2: 移除 v1 区块并处理去向**——删除：金刚区 2×2 大卡、今日精选横滑、最近使用横滑、首页 `<PlayBar />` 渲染（MiniPlayer 互斥：首页不渲染，其余页 Task 5 样式已就位、渲染逻辑不变）。「今日精选」数据改为 discover 页承接（Task 11 实现 discover 时加入，本页直接删除即可）；「最近使用」由 history 页承接（已有）。

- [ ] **Step 3: 脚本区**——`activeCat = ref('all')`；`quickChips = computed(() => ['deep-sleep', 'white-noise', 'stream'].map(findScene).filter(Boolean))`（以 `findScene(id)` 实际存在的场景 id 为准，先 `grep id:` `src/data/scenes.ts` 确认三个 id，不存在则以分类第一条 `getCategoryScenes('sleep'|'focus'|'nature', 1)[0]` 代替）；网格数据 `computed(() => getCategoryScenes(activeCat.value, 20))`；`onShow` 时强制刷新（recompute 触发即可，保持 v1 的 `ref` 承载约定：`grid = ref<Scene[]>([])`，`onShow` 中 `grid.value = getCategoryScenes(activeCat.value, 20)`，并在 `activeCat` watch 中同步）。

- [ ] **Step 4: 类型检查 + 目视**

Run: `cd prototype && pnpm type-check`；`pnpm dev:h5` 验证：首屏可见播放键；chip 一键出声（isPlaying=true）；分类切换刷新网格；明暗 × 3 风格下主控卡形态正确（neu 下主控卡叠在纯色底、无描边）。
Expected: 全部通过；空态（无 currentScene）显示月亮引导。

- [ ] **Step 5: Commit**

```bash
cd prototype && git add src/pages/index/index.vue && git commit -m "feat(prototype): 首页播放优先三层 IA（BrandBar + 主控卡 + 场景流，金刚区/精选/最近移除）"
```

---

### Task 7: scene + scene-all（分类单一来源 + token 迁移）

**Files:**
- Modify: `prototype/src/data/scenes.ts:25`（`sceneCategories` 增加 `icon` 字段）
- Modify: `prototype/src/pages/scene/scene.vue`
- Modify: `prototype/src/pages/scene-all/scene-all.vue`
- Modify: `prototype/src/pages.json`（scene-all 条目改 custom + 接 NavBar）

**Interfaces:**
- Produces: `sceneCategories: { key: SceneCategory | 'all'; label: string; icon: string }[]`（值：`[{'all','全部','wave'},{'sleep','助眠','moon'},{'focus','专注','flame'},{'relax','放松','forest'},{'nature','自然','mountain'}]`——与 scene.vue 第 177–181 行现值一致，icon 名已存在于 Icon.vue）

- [ ] **Step 1: scenes.ts** — `sceneCategories` 类型改为 `{ key: string; label: string; icon: string }[]` 并补 icon 值（如上）。`getCategoryScenes` 签名不变（参数仍 `SceneCategory | 'all'`）。

- [ ] **Step 2: scene.vue** — 删除第 177–181 行本地分类数组，改 `import { sceneCategories } from '@/data/scenes'`；样式全部按全局映射表替换旧 token；分类胶囊换用 `Segmented`（options 传 `sceneCategories.map(c => ({key:c.key,label:c.label}))`）或保留自绘但样式对齐 preview「场景」页；推荐区确认用 `ref` + `onShow` 刷新（v1 已修，回归验证）。

- [ ] **Step 3: scene-all.vue** — 顶部接 `<NavBar title="全部场景" />`；分类 `sceneCategories` 单一来源；样式迁移 v2；`pages.json` 中 `pages/scene-all/scene-all` 条目改为 `{"navigationStyle":"custom","navigationBarTitleText":""}`。

- [ ] **Step 4: 类型检查 + 目视 + Commit**

Run: `cd prototype && pnpm type-check`
```bash
cd prototype && git add src/data/scenes.ts src/pages/scene/scene.vue src/pages/scene-all/scene-all.vue src/pages.json && git commit -m "refactor(prototype): scene/scene-all 迁移 v2，分类收敛 sceneCategories 单一来源"
```

---

### Task 8: 播放链路（scene-detail / scene-edit / library）

**Files:**
- Modify: `prototype/src/pages/scene-detail/scene-detail.vue`
- Modify: `prototype/src/pages/scene-edit/scene-edit.vue`
- Modify: `prototype/src/pages/library/library.vue`
- Modify: `prototype/src/pages.json`（三条目改 custom）

**Interfaces:**
- Consumes: `NavBar`（Task 3）、`MixTrack`、`buildRecipe(scene)`、`buildPresets(scene)`、`applyScene`、`setTrackVolume`、`toggleTrackMute`、`removeTrack`
- Produces: 无（叶子页面）

- [ ] **Step 1: 三页统一**——各页顶部接 `NavBar`（标题：场景详情 / 新建场景 / 声音库）；`pages.json` 对应条目改 `{"navigationStyle":"custom","navigationBarTitleText":""}`；样式按全局映射表迁移 v2；**叠在封面图上的浮层按风格取向**（flat 实底+描边+投影 / glass 毛玻璃+高光描边 / neu 禁双阴影降级，MASTER.md §7）。

- [ ] **Step 2: library.vue 缺返回修复**——NavBar `back` 默认 true 即修复（MASTER.md §10.3-3）。

- [ ] **Step 3: scene-detail**——播放键 176rpx、波形呼吸 1.6s、音轨列表用 MixTrack（44px 触控）；定时面板/混音面板为底部 Sheet：圆角 xl（56rpx 仅顶两角）、`--app-shadow-4`、弹起 `var(--dur-slow)` + `var(--ease-std)`、遮罩 `var(--app-overlay)`（遮罩失效修复验证点）。

- [ ] **Step 4: scene-edit**——表单输入框 `background: var(--app-sunken); border: 1rpx solid var(--app-line); border-radius: 24rpx; min-height: 88rpx`；聚焦 `border-color: var(--app-line-strong)`；声音选择网格复用 SoundCard。

- [ ] **Step 5: 类型检查 + 目视 + Commit**

Run: `cd prototype && pnpm type-check`；目视验证三页返回可用、弹窗遮罩可见。
```bash
cd prototype && git add src/pages/scene-detail src/pages/scene-edit src/pages/library src/pages.json && git commit -m "refactor(prototype): 播放链路三页迁移 v2，library 补返回，弹窗遮罩修复"
```

---

### Task 9: 我的链路上半（mine / settings / theme）

**Files:**
- Modify: `prototype/src/pages/mine/mine.vue`
- Modify: `prototype/src/pages/settings/settings.vue`
- Modify: `prototype/src/pages/theme/theme.vue`
- Modify: `prototype/src/pages.json`（三条目改 custom）

**Interfaces:**
- Consumes: `NavBar`、`Segmented`、`schemeMeta`（含 `swatchLight/swatchDark`）、`THEME_MODES`、`THEMEMODE_META`、`setTheme(scheme, ui, mode)`、`schemePrimary(k, resolved)`（原生 switch `:color` 绑定改传第二参）
- Produces: 主题页外观分段（持久化 `{scheme, ui, mode}`）

- [ ] **Step 1: 三页接 NavBar + pages.json 改 custom + 全局映射表样式迁移**（同 Task 7/8 模式）。

- [ ] **Step 2: settings 两个缺陷修复**（MASTER.md §10.3-1/2）——删除重复的「提醒设置」段落（保留自绘 switch 版本，样式迁移 v2，原生 switch 的 `:color` 绑定改 `schemePrimary(themeState.scheme, resolveMode(themeState.mode))`）；`showTimePicker` 死代码补齐时间选择：点击提醒时间行 → 底部 Sheet 内 `picker mode="time"`（uni-app 内置组件，无三方依赖），确认后写回 `reminderTime` 并持久化。

- [ ] **Step 3: theme 页**——① 配色区：`SCHEME_KEYS` 渲染，每项展示 `schemeMeta(k).swatchLight` 与 `swatchDark` 两组色点（替换组件内 24 个写死 hex）；② UI 风格区：`UI_MODES` + `UIMODE_META`；③ **新增「外观」分段**：`THEME_MODES` 渲染 `THEMEMODE_META` 标签，选中调用 `setTheme(themeState.scheme, themeState.ui, mode)`。

- [ ] **Step 4: 类型检查 + 目视 + Commit**

Run: `cd prototype && pnpm type-check`；目视：外观切「深色」全站即时变暗并刷新后保持；系统切换（DevTools emulate）auto 模式跟随。
```bash
cd prototype && git add src/pages/mine src/pages/settings src/pages/theme src/pages.json && git commit -m "feat(prototype): mine/settings/theme 迁移 v2，外观明暗分段，修复重复提醒段与时间选择"
```

---

### Task 10: 我的链路下半（achievement / checkin / stats）

**Files:**
- Modify: `prototype/src/pages/achievement/achievement.vue`
- Modify: `prototype/src/pages/checkin/checkin.vue`
- Modify: `prototype/src/pages/stats/stats.vue`
- Modify: `prototype/src/pages.json`（三条目改 custom）

**Interfaces:**
- Consumes: `NavBar`、`--app-rank-1/2/3`、`--app-success/--app-warning`
- Produces: 无

- [ ] **Step 1: 三页接 NavBar + pages.json 改 custom + 映射表迁移**。

- [ ] **Step 2: achievement 进度一致性修复**（§10.3-4）——概览的「已解锁数」与「百分比」全部改 computed：`unlocked = achievements.filter(a => a.unlocked).length`、`percent = Math.round(unlocked / achievements.length * 100)`，模板引用 computed，禁止字面量「3 / 38%」；完成度条颜色改 `var(--app-success)`（v1 误用 `--app-danger` 处）。

- [ ] **Step 3: stats 金银铜**——排行榜前三奖牌底/描边色替换为 `var(--app-rank-1/2/3)`（删除 6 个 hex）；柱状图 `background: linear-gradient(180deg, var(--app-primary), var(--app-primary-strong))`，高 24rpx 圆角 full。

- [ ] **Step 4: checkin**——签到成功态用 `--app-success`、提醒用 `--app-warning`；连续签到天数 `class="num"`。

- [ ] **Step 5: 类型检查 + 目视 + Commit**

Run: `cd prototype && pnpm type-check`
```bash
cd prototype && git add src/pages/achievement src/pages/checkin src/pages/stats src/pages.json && git commit -m "refactor(prototype): achievement/checkin/stats 迁移 v2，进度 computed 化与金银铜 token"
```

---

### Task 11: 收尾页（favorites / history / invite / discover / onboarding）

**Files:**
- Modify: `prototype/src/pages/favorites/favorites.vue`
- Modify: `prototype/src/pages/history/history.vue`
- Modify: `prototype/src/pages/invite/invite.vue`
- Modify: `prototype/src/pages/discover/discover.vue`
- Modify: `prototype/src/pages/onboarding/onboarding.vue`
- Modify: `prototype/src/pages.json`（favorites/history/invite/scene-detail 外其余条目改 custom；onboarding 已 custom）

**Interfaces:**
- Consumes: `getRecent()`、`recentTimeLabel(ts)`、`EmptyState`、`favorites` 数据层（现有实现）、`homeScenes`（discover 的今日精选承接：取 `getRecommended(SIMULATED_PREFS, n)` 或既有精选数据源）
- Produces: discover 承接首页移出的「今日精选」横滑大卡

- [ ] **Step 1: favorites / history**——样式迁移；`history.vue` 的 `#C48B8B` / `rgba(196,139,139,.1)` → `var(--app-danger)` / `var(--app-danger-soft)`（§11 P0）；收藏/历史空态换 `<EmptyState title="还没有记录" desc="去首页挑一个场景开始吧" actionText="去首页" @action="uni.reLaunch({url:'/pages/index/index'})" />`；声音色底按 Task 4 Step 4 的 `color-mix` 规则（§11 P1：删除 12 组 hex/rgba）。

- [ ] **Step 2: invite**——样式迁移；邀请码容器 `--app-surface` + `--app-shadow-2`；复制按钮 `.btn-primary`。

- [ ] **Step 3: discover**——新增「今日精选」横滑区（承接自首页，MASTER.md §10.1 去向表）：横向 scroll-view，卡片用 SceneCard list 形态或精选大卡（对照 preview「发现」页）；6 组写死渐变（§11 P1）改 `linear-gradient(135deg, var(--app-primary), var(--app-primary-strong))` 与 `--app-accent` 组合。

- [ ] **Step 4: onboarding**——样式迁移；主标题 Display 30px=60rpx、正文 Body 15px；跳过/下一步按钮 `.btn-primary` / `.btn-outline`。

- [ ] **Step 5: 类型检查 + 目视 + Commit**

Run: `cd prototype && pnpm type-check`
```bash
cd prototype && git add src/pages/favorites src/pages/history src/pages/invite src/pages/discover src/pages/onboarding src/pages.json && git commit -m "refactor(prototype): favorites/history/invite/discover/onboarding 迁移 v2，discover 承接今日精选"
```

---

### Task 12: 收尾（硬编码清零 + 别名移除 + 文档回写 + 全页验收）

**Files:**
- Modify: `prototype/src/theme/index.ts`（删除 v1 兼容别名块）
- Modify: `prototype/src/pages.json`（globalStyle 与 tabBar 色值清理）
- Modify: `docs/design-system/MASTER.md`（勘误回写）
- Modify: `AGENTS.md`（计划文档入第八章索引）
- Modify: 可能的残留页面（grep 命中处）

- [ ] **Step 1: grep 硬编码清零（MASTER.md §11 逐项核对）**

```bash
cd prototype/src && grep -rn "#[0-9A-Fa-f]\{3,6\}\b" --include="*.vue" pages components | grep -v "Icon.vue" ; grep -rn "rgba(0,0,0" --include="*.vue" pages components; grep -rn -- "--app-card-bg\|--app-card-border\|--app-card-shadow\|--app-card-blur\|--app-primary-dark\|--app-divider\|--app-subtle\|--app-input-" --include="*.vue" pages components
```
Expected: 均无输出（Icon.vue 内 stroke="currentColor" 等非颜色 hex 除外；`pages.json` 色值单独处理）。有命中则逐处替换为映射 token。

- [ ] **Step 2: 移除 theme/index.ts 中「v1 兼容别名」代码块**（Step 1 无引用后），删除 `schemePrimaryDark` deprecated 导出（grep 确认无调用）。

- [ ] **Step 3: pages.json 清理**——globalStyle 的 `navigationBarBackgroundColor/backgroundColor` 与 tabBar 的 `color/selectedColor/backgroundColor` 改中性值 `#FFFFFF`（全部页面已 custom，原生导航不渲染；tabBar 为 custom:true 仅存配置兜底），文件内不再出现 `#F5F2ED`。

- [ ] **Step 4: 文档回写**——MASTER.md 附录勘误一行：`preview 中 --app-sh-1..4 在代码落地时命名为 --app-shadow-1..4（以 MASTER.md 为准）`；AGENTS.md 第八章索引追加 `| 原型 v2 落地计划 | docs/superpowers/plans/2026-09-16-prototype-v2-implementation.md | v2 全量落地实施计划 |`。

- [ ] **Step 5: 全页最终验收**

Run: `cd prototype && pnpm type-check && pnpm build:h5`
Run: `pnpm dev:h5` → 逐页过 17 页 × morandi（浅/深）×（flat/glass/neu）抽查首页、场景、主题、设置、发现、历史 6 页全组合。
Expected: 构建通过；无未定义变量（表现为透明/无色）页面；品牌行 logo+声栖在首页首屏；主播放键首屏可见。

- [ ] **Step 6: Commit**

```bash
git add prototype/src docs/design-system/MASTER.md AGENTS.md && git commit -m "chore(prototype): v2 落地收尾——硬编码清零、v1 别名移除、pages.json 清理与文档回写"
```

---

## Self-Review 记录（已执行）

1. **Spec 覆盖**：spec §3.1→Task 1；§3.2→Task 2；§3.3 组件表→Task 3/4/5；§3.4 首页 IA→Task 6、导航统一→Task 7–11 各页 pages.json 步骤、5 缺陷→Task 8（library）/9（settings×2）/10（achievement）/Task 12（pages.json）；§3.5 数据层→Task 7（sceneCategories）、Task 4/11（color-mix）、usePlayer 不改；§4 风险→别名策略/映射表/触控；§5 验收→Task 12 Step 5；§6 交付物→Tasks 1–12。无缺口。
2. **占位符扫描**：无 TBD/TODO；「以 `ls`/`grep` 实际结果为准」处均给出了替代取值规则（quickChips 回退、logo 路径确认）。
3. **类型一致性**：`buildTokens(scheme, ui, resolved)` 三参在 Task 1 定义、Task 2 消费；`setTheme(scheme, ui, mode?)` 与 Task 9 外观分段一致；`sceneCategories` 加 icon 后 `getCategoryScenes` 签名未变；`schemePrimary(k, resolved?)` 可选参保证 Task 1–9 间编译绿。
