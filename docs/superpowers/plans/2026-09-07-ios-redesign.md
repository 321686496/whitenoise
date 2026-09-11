# 声栖 iOS 重设计实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将 `prototype/`（uni-app Vue3 + Vite）原型全面改造为 iOS 设计哲学（Large Title / inset 分组列表 / 底部 Sheet / Mini Player / 深浅色跟随系统），视觉风格收敛为「新拟态 × Liquid Glass」单一方向，主题维度收敛为 appearance × accent。

**Architecture:** 主题引擎由「6 配色 × 3 UI 风格」重构为「外观（浅/深/跟随系统）× 主色调（青绿/靛蓝/紫）」，仍通过 CSS 变量运行时注入 html 根节点（保留 rpx→px 换算）。新建由 CSS 变量驱动的组件库（NeGlass/NeChip/NeSlider/NeSwitch/NeSegmented/NeSheet/NavBar/LargeTitle/ListRow/EmptyState），以此重做四个 Tab 根页、全部二级页与沉浸页。播放/混音/定时/数据逻辑全部保留，组件显式 import（与现有 PlayBar/Icon 约定一致），不引入 pinia。

**Tech Stack:** uni-app 3（`@dcloudio/uni-app`）、Vue 3.4 `<script setup lang="ts">`、SCSS（`lang="scss"`）、运行时 CSS 变量注入、`uni.onThemeChange` / `window.matchMedia`、`vue-tsc` 类型校验。物理包 `prototype/`。

## Global Constraints

- **验证方式（替代单测，仓库无测试框架）**：每个任务以 `npm run type-check`（`vue-tsc --noEmit`）零错误 + `npm run dev:h5` 手测清单为准。**禁止**新增测试框架 / 状态管理（pinia/vuex）依赖（YAGNI）。

- 主题引擎继续通过 CSS 变量注入 `document.documentElement`，保留 `uni.getSystemInfoSync` rpx→px 换算与 `--app-tab-height` / `--app-playbar-height` 布局令牌（规格 §7.1）。

- 新变量集**必须保留全部既有** **`--app-*`** **变量名**（`--app-primary`、`--app-accent`、`--app-bg`、`--app-card-*`、`--app-text*`、`--app-divider`、`--app-subtle`、`--app-press`、`--app-input-*`、`--app-danger`、`--app-tab-height`、`--app-playbar-height`），并新增 `--app-bg-end`、`--app-edge-highlight`、`--app-neu-tint`、`--app-neu-a`、`--app-neu-b`、`--app-neu-raised`、`--app-neu-pressed`、`--app-ios-blue`。

- 状态维度：`appearance: 'light' | 'dark' | 'system'` × `accent: 'teal' | 'indigo' | 'lavender'`，默认 `system` × `teal`。跟随系统：H5 用 `matchMedia('(prefers-color-scheme: dark)')`，原生端用 `uni.onThemeChange`，应用内选择可覆盖；持久化沿用 `uni.setStorageSync`（新 key `shengqi-appearance`）。

- 所有新组件放 `src/components/` 扁平目录（单文件单组件），页面内显式 `import`（不使用 easycom）。

- 仅替换视觉壳，**保留全部播放/混音/定时/收藏/历史/签到/成就/邀请逻辑与数据**。

- 材质约束：glass = `backdrop-blur(20px)` + 边缘高光；不支持 `backdrop-filter` 的环境用 `@supports not` 回退为高不透明纯色 `var(--app-neu-tint)`。

- 字体仅系统栈（`-apple-system, "PingFang SC", "Helvetica Neue", sans-serif`），不引入外部字体；数字用 `font-variant-numeric: tabular-nums`。

- Logo 沿用 `static/logo-v10-1.jpg`（PlayBar/首页/外观页引用不变），本次不改。

- 全部命令在 `prototype/` 目录下执行（cwd = `d:\app\projects\whitenoise\prototype`）。

- 规格文档：`docs/superpowers/specs/2026-09-07-whitenoise-ios-redesign.md`（以规格 §3 令牌、§5 页面明细、§9 阶段划分为准）。

***

## File Structure

**Create（新组件文件）：**

- `prototype/src/components/NeGlass.vue`

- `prototype/src/components/NeChip.vue`

- `prototype/src/components/NeSlider.vue`

- `prototype/src/components/NeSwitch.vue`

- `prototype/src/components/NeSegmented.vue`

- `prototype/src/components/NeSheet.vue`

- `prototype/src/components/NavBar.vue`

- `prototype/src/components/LargeTitle.vue`

- `prototype/src/components/ListRow.vue`

- `prototype/src/components/EmptyState.vue`

- `prototype/src/components/LibrarySheet.vue`（P2）

- `prototype/src/components/MiniPlayer.vue`、`prototype/src/components/PlayerPanel.vue`（P3）

**Modify（重写或局部改造）：**

- `prototype/src/theme/index.ts`：整文件重写（P0 核心）

- `prototype/src/uni.scss`：追加设计令牌变量

- `prototype/src/App.vue`：全局样式升级（背景氛围光斑、edge highligh、`.subpage`、分组列表、tabbar 跟随）

- `prototype/src/pages.json`：theme 标题改「外观」（P0）；所有二级页改 `navigationStyle: custom`（P2）

- `prototype/src/components/Icon.vue`：新增 7 个图标（P0）

- 页面：`pages/index/index.vue`、`pages/scene/scene.vue`、`pages/discover/discover.vue`、`pages/mine/mine.vue`、`pages/theme/theme.vue`、`pages/settings/settings.vue`、`pages/favorites/favorites.vue`、`pages/history/history.vue`、`pages/stats/stats.vue`、`pages/achievement/achievement.vue`、`pages/invite/invite.vue`、`pages/checkin/checkin.vue`、`pages/scene-detail/scene-detail.vue`、`pages/onboarding/onboarding.vue`

**Delete：**

- `prototype/src/pages/library/library.vue` + `pages.json` 中 library 条目（P2，功能迁入 `LibrarySheet.vue`）

- `prototype/src/components/PlayBar.vue`（P3，功能迁入 MiniPlayer.vue）

***

# P0 视觉基座

## Task 1: 主题引擎重构（appearance × accent + 系统跟随）

**Files:**

- Rewrite: `src/theme/index.ts`

- Modify: `src/pages/theme/theme.vue`（整个文件替换为「外观」页）

- Modify: `src/pages/mine/mine.vue`（import 行 + `currentThemeLabel`）

- Modify: `src/pages/settings/settings.vue`（import 行 + `switchColor` + `currentThemeLabel`）

- Modify: `src/pages.json`（theme 条目标题「主题设置」→「外观」）

**Interfaces:**

- Consumes：旧主题引擎的既有 `--app-*` CSS 变量名（下一页继续使用）。

- Produces：

  - `type Appearance = 'light' | 'dark' | 'system'`；`type AccentKey = 'teal' | 'indigo' | 'lavender'`

  - `APPEARANCE_KEYS: Appearance[]`、`ACCENT_KEYS: AccentKey[]`

  - `APPEARANCE_META: Record<Appearance, {label:string; desc:string}>`

  - `ACCENT_META: Record<AccentKey, {label:string; desc:string; swatch:string}>`

  - `themeState: reactive<{ appearance: Appearance; accent: AccentKey }>`

  - `systemDark: Ref<boolean>`；`effectiveMode: ComputedRef<'light'|'dark'>`

  - `initTheme()`；`setTheme(appearance: Appearance, accent: AccentKey)`

  - `buildTokens(appearance: Appearance, accent: AccentKey): Record<string, string>`

  - `applyTheme(appearance: Appearance, accent: AccentKey)`

  - `schemePrimary(accent?: AccentKey): string`（当前生效模式下主色，供原生组件 color 绑定）

- 删除（不再导出）：`SchemeKey`、`UiMode`、`SCHEME_KEYS`、`UI_MODES`、`schemeMeta`、`schemePrimaryDark`、`UIMODE_META`。

- [ ] **Step 1: 整文件重写** **`src/theme/index.ts`**

```ts
/**
 * 声栖 · 全局主题引擎
 *
 * 状态维度：外观 appearance（浅色 / 深色 / 跟随系统）× 主色调 accent（青绿 / 靛蓝 / 紫）。
 * 令牌按「浅色 / 深色」两套主题树生成，accent 只影响 --app-accent 与选中态高亮；
 * 运行时以 CSS 变量注入 html 根节点（保留 rpx → px 换算）。
 */

import { reactive, ref, computed } from 'vue'
import type { ComputedRef } from 'vue'

export type Appearance = 'light' | 'dark' | 'system'
export type AccentKey = 'teal' | 'indigo' | 'lavender'

export const APPEARANCE_KEYS: Appearance[] = ['system', 'light', 'dark']
export const ACCENT_KEYS: AccentKey[] = ['teal', 'indigo', 'lavender']

export const APPEARANCE_META: Record<Appearance, { label: string; desc: string }> = {
  system: { label: '跟随系统', desc: '随设备深浅色自动切换' },
  light: { label: '浅色', desc: '始终使用浅色外观' },
  dark: { label: '深色', desc: '始终使用深色外观' },
}

export const ACCENT_META: Record<AccentKey, { label: string; desc: string; swatch: string }> = {
  teal: { label: '青绿', desc: '声栖品牌默认', swatch: '#00A88E' },
  indigo: { label: '靛蓝', desc: '沉静专注', swatch: '#5E7CE6' },
  lavender: { label: '紫', desc: '温柔放松', swatch: '#9B7BD8' },
}

interface AccentTokens { main: string; soft: string; dark: string }

const ACCENTS: Record<AccentKey, { light: AccentTokens; dark: AccentTokens }> = {
  teal: {
    light: { main: '#00A88E', soft: 'rgba(0,168,142,.14)', dark: '#007A68' },
    dark: { main: '#00C8B2', soft: 'rgba(0,200,178,.22)', dark: '#00A88E' },
  },
  indigo: {
    light: { main: '#5E7CE6', soft: 'rgba(94,124,230,.14)', dark: '#4157B8' },
    dark: { main: '#7C97F0', soft: 'rgba(124,151,240,.22)', dark: '#5E7CE6' },
  },
  lavender: {
    light: { main: '#9B7BD8', soft: 'rgba(155,123,216,.14)', dark: '#7C5CB5' },
    dark: { main: '#B296E8', soft: 'rgba(178,150,232,.22)', dark: '#9B7BD8' },
  },
}

/** 深浅两套「基础色板 + 材质」主题树（不含 accent） */
interface TokenSet {
  bgBase: string
  bgMid: string
  bgEnd: string
  text: string
  text2: string
  text3: string
  divider: string
  subtle: string
  danger: string
  glassCard: string
  glassBorder: string
  glassShadow: string
  glassBlur: string
  edgeHighlight: string
  neuTint: string
  neuA: string
  neuB: string
  inputBg: string
  inputBorder: string
  press: string
  iosBlue: string
}

const LIGHT: TokenSet = {
  bgBase: '#DFE7EF', bgMid: '#D3DFE2', bgEnd: '#D8E4DC',
  text: '#1C2632', text2: '#5B6B77', text3: '#8E98A5',
  divider: 'rgba(28,38,50,.08)', subtle: 'rgba(28,38,50,.05)', danger: '#C4706B',
  glassCard: 'rgba(255,255,255,.42)', glassBorder: 'rgba(255,255,255,.75)',
  glassShadow: '0 4px 14px rgba(60,80,90,.18)', glassBlur: '20px',
  edgeHighlight: 'rgba(255,255,255,.9)',
  neuTint: '#DAE2E9', neuA: 'rgba(163,177,188,.55)', neuB: 'rgba(255,255,255,.85)',
  inputBg: 'rgba(255,255,255,.5)', inputBorder: 'rgba(255,255,255,.75)',
  press: 'rgba(255,255,255,.35)', iosBlue: '#007AFF',
}

const DARK: TokenSet = {
  bgBase: '#22262E', bgMid: '#1D2629', bgEnd: '#232822',
  text: '#EEF2F4', text2: '#9AA6B0', text3: '#5C6872',
  divider: 'rgba(238,242,244,.1)', subtle: 'rgba(238,242,244,.06)', danger: '#E0817B',
  glassCard: 'rgba(42,50,58,.46)', glassBorder: 'rgba(255,255,255,.16)',
  glassShadow: '0 4px 14px rgba(0,0,0,.42)', glassBlur: '20px',
  edgeHighlight: 'rgba(255,255,255,.22)',
  neuTint: '#1E222A', neuA: 'rgba(8,10,13,.6)', neuB: 'rgba(60,68,78,.4)',
  inputBg: 'rgba(42,50,58,.6)', inputBorder: 'rgba(255,255,255,.16)',
  press: 'rgba(255,255,255,.12)', iosBlue: '#0A84FF',
}

/** rpx → px：H5 下运行时注入需换算为像素 */
function rpx() {
  try {
    // @ts-ignore 运行环境提供 uni
    const info = uni.getSystemInfoSync()
    return info.windowWidth / 750
  } catch {
    return 375 / 750
  }
}

/** 系统深浅偏好（H5 matchMedia / 原生 uni.onThemeChange 维护） */
export const systemDark = ref(false)

export const effectiveMode = computed<Exclude<Appearance, 'system'>>(
  () => (systemDark.value ? 'dark' : 'light'),
)

export const themeState = reactive<{ appearance: Appearance; accent: AccentKey }>({
  appearance: 'system',
  accent: 'teal',
})

/** 生成最终 CSS 变量表 */
export function buildTokens(appearance: Appearance, accent: AccentKey): Record<string, string> {
  const mode: Exclude<Appearance, 'system'> = appearance === 'system' ? effectiveMode.value : appearance
  const t = mode === 'dark' ? DARK : LIGHT
  const a = ACCENTS[accent][mode]
  const p = rpx()
  const sh = (h: number) => `${(h * p).toFixed(2)}px`

  return {
    '--app-primary': a.main,
    '--app-primary-soft': a.soft,
    '--app-primary-dark': a.dark,
    '--app-on-primary': '#FFFFFF',
    '--app-accent': a.main,
    '--app-ios-blue': t.iosBlue,
    '--app-bg': t.bgBase,
    '--app-bg-grad': t.bgMid,
    '--app-bg-end': t.bgEnd,
    '--app-card-bg': t.glassCard,
    '--app-card-border': t.glassBorder,
    '--app-card-shadow': t.glassShadow,
    '--app-card-blur': t.glassBlur,
    '--app-edge-highlight': t.edgeHighlight,
    '--app-neu-tint': t.neuTint,
    '--app-neu-a': t.neuA,
    '--app-neu-b': t.neuB,
    '--app-neu-raised': `${sh(6)} ${sh(6)} ${sh(16)} ${t.neuA}, -${sh(6)} -${sh(6)} ${sh(16)} ${t.neuB}`,
    '--app-neu-pressed': `inset ${sh(5)} ${sh(5)} ${sh(12)} ${t.neuA}, inset -${sh(5)} -${sh(5)} ${sh(12)} ${t.neuB}`,
    '--app-text': t.text,
    '--app-text-2': t.text2,
    '--app-text-3': t.text3,
    '--app-divider': t.divider,
    '--app-subtle': t.subtle,
    '--app-press': t.press,
    '--app-input-bg': t.inputBg,
    '--app-input-border': t.inputBorder,
    '--app-danger': t.danger,
    '--app-tab-height': `${(100 * p).toFixed(2)}px`,
    '--app-playbar-height': `${(140 * p).toFixed(2)}px`,
  }
}

/** 直接注入到 html 根节点 */
export function applyTheme(appearance: Appearance, accent: AccentKey) {
  if (typeof document === 'undefined' || !document.documentElement) return
  const el = document.documentElement
  const tokens = buildTokens(appearance, accent)
  Object.entries(tokens).forEach(([k, v]) => el.style.setProperty(k, v))
  el.dataset.appearance = appearance
  el.dataset.accent = accent
}

const STORE_KEY = 'shengqi-appearance'

function watchSystemScheme() {
  try {
    if (typeof window !== 'undefined' && window.matchMedia) {
      const mq = window.matchMedia('(prefers-color-scheme: dark)')
      systemDark.value = mq.matches
      const onChange = (e: MediaQueryListEvent) => {
        systemDark.value = e.matches
        applyTheme(themeState.appearance, themeState.accent)
      }
      mq.addEventListener
        ? mq.addEventListener('change', onChange)
        : mq.addListener(onChange)
    }
  } catch {}
  try {
    // @ts-ignore 原生端（App / 小程序）系统深浅切换回调
    uni.onThemeChange?.((res: { theme: string }) => {
      systemDark.value = res.theme === 'dark'
      applyTheme(themeState.appearance, themeState.accent)
    })
  } catch {}
}

export function initTheme() {
  let appearance: Appearance = 'system'
  let accent: AccentKey = 'teal'
  try {
    // @ts-ignore
    const saved = uni.getStorageSync(STORE_KEY) || {}
    if (saved.appearance && APPEARANCE_KEYS.includes(saved.appearance)) appearance = saved.appearance
    if (saved.accent && ACCENT_KEYS.includes(saved.accent)) accent = saved.accent
  } catch {}
  watchSystemScheme()
  themeState.appearance = appearance
  themeState.accent = accent
  applyTheme(appearance, accent)
}

export function setTheme(appearance: Appearance, accent: AccentKey) {
  themeState.appearance = appearance
  themeState.accent = accent
  applyTheme(appearance, accent)
  try {
    // @ts-ignore
    uni.setStorageSync(STORE_KEY, { appearance, accent })
  } catch {}
}

/** 当前生效模式下的主色（供原生组件 color 绑定） */
export const schemePrimary = (accent: AccentKey = themeState.accent): string =>
  ACCENTS[accent][effectiveMode.value].main
```

- [ ] **Step 2: 整文件替换** **`src/pages/theme/theme.vue`（新「外观」页，暂用内联控件，P2 精修）**

```vue
<template>
  <view class="page-container">
    <view class="page-bg"></view>

    <view class="header">
      <text class="page-title">外观</text>
      <text class="page-subtitle">深浅色默认跟随系统，主色调三选即时生效</text>
    </view>

    <view class="preview app-card">
      <image src="/static/logo-v10-1.jpg" mode="aspectFit" class="preview-logo" />
      <view class="preview-info">
        <text class="preview-name">{{ accentLabel }} · {{ appearanceLabel }}</text>
        <text class="preview-hint">声栖正在用这套外观渲染全局</text>
      </view>
    </view>

    <view class="section">
      <text class="section-title">外观模式</text>
      <view class="row-list app-card">
        <view
          v-for="a in appearanceOptions"
          :key="a.key"
          class="row"
          :class="{ 'row--on': appearance === a.key }"
          @click="pickAppearance(a.key)"
        >
          <view class="row-text">
            <text class="row-label">{{ a.label }}</text>
            <text class="row-desc">{{ a.desc }}</text>
          </view>
          <view class="radio"><view v-if="appearance === a.key" class="radio-dot" /></view>
        </view>
      </view>
    </view>

    <view class="section">
      <text class="section-title">主色调</text>
      <view class="accent-row">
        <view
          v-for="a in accentOptions"
          :key="a.key"
          class="accent-item"
          :class="{ 'accent-item--on': accent === a.key }"
          @click="pickAccent(a.key)"
        >
          <view class="accent-swatch" :style="{ background: a.swatch }">
            <Icon v-if="accent === a.key" name="check" :size="24" color="#fff" />
          </view>
          <text class="accent-label">{{ a.label }}</text>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import Icon from '@/components/Icon.vue'
import { setTheme, themeState, APPEARANCE_KEYS, APPEARANCE_META, ACCENT_KEYS, ACCENT_META } from '@/theme/index'
import type { Appearance, AccentKey } from '@/theme/index'

const appearance = computed(() => themeState.appearance)
const accent = computed(() => themeState.accent)

const appearanceLabel = computed(() => APPEARANCE_META[appearance.value].label)
const accentLabel = computed(() => ACCENT_META[accent.value].label)

const appearanceOptions = APPEARANCE_KEYS.map((key) => ({ key, ...APPEARANCE_META[key] }))
const accentOptions = ACCENT_KEYS.map((key) => ({ key, ...ACCENT_META[key] }))

function pickAppearance(key: Appearance) {
  setTheme(key, accent.value)
}
function pickAccent(key: AccentKey) {
  setTheme(appearance.value, key)
}
</script>

<style scoped>
.header {
  padding: 24rpx 6rpx 32rpx;
}
.preview {
  display: flex;
  flex-direction: row;
  align-items: center;
  padding: 32rpx;
  gap: 28rpx;
  border-radius: 28rpx;
  background: var(--app-card-bg, rgba(255, 255, 255, 0.5));
  border: 1px solid var(--app-card-border, rgba(255, 255, 255, 0.6));
  box-shadow: var(--app-card-shadow, 0 4px 14px rgba(60, 80, 90, 0.18));
  backdrop-filter: blur(var(--app-card-blur, 20px));
  -webkit-backdrop-filter: blur(var(--app-card-blur, 20px));
}
.preview-logo {
  width: 96rpx;
  height: 96rpx;
  border-radius: 24rpx;
  background: rgba(255, 255, 255, 0.5);
}
.preview-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 8rpx;
}
.preview-name {
  font-size: 36rpx;
  font-weight: 600;
  color: var(--app-text, #1c2632);
}
.preview-hint {
  font-size: 24rpx;
  color: var(--app-text-3, #8e98a5);
}
.section {
  margin-top: 40rpx;
}
.row-list {
  border-radius: 28rpx;
  padding: 8rpx 0;
  background: var(--app-card-bg, rgba(255, 255, 255, 0.5));
  border: 1px solid var(--app-card-border, rgba(255, 255, 255, 0.6));
  box-shadow: var(--app-card-shadow, 0 4px 14px rgba(60, 80, 90, 0.18));
  backdrop-filter: blur(var(--app-card-blur, 20px));
  -webkit-backdrop-filter: blur(var(--app-card-blur, 20px));
}
.row {
  display: flex;
  flex-direction: row;
  align-items: center;
  justify-content: space-between;
  padding: 28rpx 32rpx;
  border-bottom: 1px solid var(--app-divider, rgba(28, 38, 50, 0.08));
}
.row:last-child {
  border-bottom: none;
}
.row-text {
  display: flex;
  flex-direction: column;
  gap: 4rpx;
}
.row-label {
  font-size: 30rpx;
  color: var(--app-text, #1c2632);
}
.row-desc {
  font-size: 24rpx;
  color: var(--app-text-3, #8e98a5);
}
.radio {
  width: 44rpx;
  height: 44rpx;
  border-radius: 50%;
  border: 2rpx solid var(--app-text-3, #8e98a5);
  display: flex;
  align-items: center;
  justify-content: center;
}
.row--on .radio {
  border-color: var(--app-primary, #00a88e);
}
.radio-dot {
  width: 26rpx;
  height: 26rpx;
  border-radius: 50%;
  background: var(--app-primary, #00a88e);
}
.accent-row {
  display: flex;
  flex-direction: row;
  gap: 24rpx;
}
.accent-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12rpx;
  padding: 24rpx 0;
}
.accent-swatch {
  width: 88rpx;
  height: 88rpx;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 2rpx solid transparent;
  overflow: hidden;
}
.accent-item--on .accent-swatch {
  border-color: var(--app-text, #1c2632);
}
.accent-label {
  font-size: 24rpx;
  color: var(--app-text-2, #5b6b77);
}
</style>
```

- [ ] **Step 3: 校验**

```bash
npm run type-check
```

重点检查：`theme.vue` 的 `appearanceOptions` 拼合类型、`schemePrimary()` 默认参数、`Icon` 的 `name="check"` 存在性；若原来引用了 `themeState.scheme / themeState.ui` 的页面报错，按上方 Files 列表修 import 与标签展示。

- [ ] **Step 4: 提交**

```bash
git add -A && git commit -m "refactor(theme): appearance × accent 双维主题引擎 + 外观页重排"
```

> **任务完成标准**：`npm run type-check` 零错误；`npm run dev:h5` 打开后页面底色变为浅色青绿色系，从「我的 → 外观」可切换外观模式与主色调，刷新后选择保持。`src/pages/mine/mine.vue` 与 `src/pages/settings/settings.vue` 的旧 scheme 文案已被新标签替代。

***

## Task 2: 图标库扩展 + SCSS 静态令牌 + 全局样式升级

**Files:**

- Modify: `src/components/Icon.vue`（新增 7 个图标，插在「默认圆点」`v-else` 之前）

- Modify: `src/uni.scss`（文件末尾追加设计系统静态令牌）

- Modify: `src/App.vue`（整文件替换；`<script setup>` 段不变，全局 `<style lang="scss">` 升级为「新拟态 × Liquid Glass」）

**Interfaces:**

- Consumes：Task 1 注入的 CSS 变量 `--app-bg-grad`、`--app-bg-end`、`--app-edge-highlight`、`--app-neu-a`、`--app-neu-tint`、`--app-neu-raised`、`--app-neu-pressed`、`--app-card-blur`。

- Produces：

  - Icon 新名称：`chevron-left`（NavBar 返回）、`sun`（浅色）、`heart`（收藏/点赞）、`calendar`（签到）、`trending-up`（使用数据）、`info`（关于）、`bell`（提醒）

  - SCSS 静态令牌：`$app-font-family`、`$app-radius-lg`、`$app-radius-xl`、`$app-gap-xs`、`$app-gap-sm`、`$app-gap`、`$app-gap-lg`、`$app-glass-blur`、`$app-sheet-radius`、`$app-duration`、`$app-ease`

  - 全局样式类：`.subpage`（二级页容器）、`.fullpage`（沉浸页容器）、`.group-card`（inset 分组列表卡片）、`.group-gap`、`.group-title`、`.neu-raised`、`.neu-pressed`、`.pressable`、`.glass-input`、`@supports not backdrop-filter` 回退

- [ ] **Step 1: 扩展** **`src/components/Icon.vue`**

在文件中「鸟」模板块之后、「`<!-- 默认圆点 -->`」的 `<template v-else>` 之前，插入以下 7 个模板块：

```vue
      <!-- 返回（iOS chevron 左） -->
      <template v-else-if="name === 'chevron-left'">
        <polyline points="15,18 9,12 15,6" />
      </template>
      <!-- 太阳（浅色外观） -->
      <template v-else-if="name === 'sun'">
        <circle cx="12" cy="12" r="5" />
        <line x1="12" y1="1" x2="12" y2="3" />
        <line x1="12" y1="21" x2="12" y2="23" />
        <line x1="4.22" y1="4.22" x2="5.64" y2="5.64" />
        <line x1="18.36" y1="18.36" x2="19.78" y2="19.78" />
        <line x1="1" y1="12" x2="3" y2="12" />
        <line x1="21" y1="12" x2="23" y2="12" />
        <line x1="4.22" y1="19.78" x2="5.64" y2="18.36" />
        <line x1="18.36" y1="5.64" x2="19.78" y2="4.22" />
      </template>
      <!-- 收藏/喜欢 -->
      <template v-else-if="name === 'heart'">
        <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z" />
      </template>
      <!-- 日历/签到 -->
      <template v-else-if="name === 'calendar'">
        <rect x="3" y="4" width="18" height="18" rx="2" ry="2" />
        <line x1="16" y1="2" x2="16" y2="6" />
        <line x1="8" y1="2" x2="8" y2="6" />
        <line x1="3" y1="10" x2="21" y2="10" />
      </template>
      <!-- 趋势（使用数据） -->
      <template v-else-if="name === 'trending-up'">
        <polyline points="23,6 13.5,15.5 8.5,10.5 1,18" />
        <polyline points="17,6 23,6 23,12" />
      </template>
      <!-- 信息（关于） -->
      <template v-else-if="name === 'info'">
        <circle cx="12" cy="12" r="10" />
        <line x1="12" y1="16" x2="12" y2="12" />
        <line x1="12" y1="8" x2="12.01" y2="8" />
      </template>
      <!-- 铃铛（提醒） -->
      <template v-else-if="name === 'bell'">
        <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9" />
        <path d="M13.73 21a2 2 0 0 1-3.46 0" />
      </template>
```

`<script setup>` 段无需改动（`name` 为字符串 prop，新增键直接可用）。

- [ ] **Step 2: 追加** **`src/uni.scss`** **静态令牌**

在文件末尾（`$app-playbar-height: 140rpx;` 之后）追加：

```scss
/* ============ 声栖 · 设计系统静态令牌（新拟态 × Liquid Glass） ============ */
$app-font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'SF Pro Display', 'PingFang SC', 'Helvetica Neue', 'Segoe UI', Roboto, sans-serif;
$app-radius-lg: 32rpx;
$app-radius-xl: 48rpx;
$app-gap-xs: 12rpx;
$app-gap-sm: 20rpx;
$app-gap: 28rpx;
$app-gap-lg: 40rpx;
$app-glass-blur: 20px;
$app-sheet-radius: 48rpx;
$app-duration: 0.24s;
$app-ease: cubic-bezier(.4, 0, .2, 1);
```

> 注意：这些是编译期 SCSS 变量，供页面/组件 scoped 样式使用；运行时主题一律走 `var(--app-*)`（Task 1），二者不冲突。

- [ ] **Step 3: 整文件替换** **`src/App.vue`（全局样式升级）**

`<script setup>` 段保持 Task 0 现状不变；`<style lang="scss">` 段整体替换为下方内容（氛围光斑、边缘高光、`.subpage`、分组列表、新拟态工具类、玻璃回退、tabbar 玻璃化）：

```vue
<style lang="scss">
@import '@/uni.scss';

/* ============================================================
   声栖 · 全局 iOS 设计语言（Apple HIG）+ 新拟态 × Liquid Glass
   全部跟随主题引擎 var(--app-*) 运行时令牌
   ============================================================ */
page {
  background-color: var(--app-bg);
  font-family: $app-font-family;
  color: var(--app-text);
  font-size: $uni-font-size-base;
  -webkit-font-smoothing: antialiased;
  transition: background-color 0.3s ease;
}

/* ---------- 全局背景氛围：三色渐变 + 双光斑 ---------- */
.page-bg {
  position: fixed;
  left: 0;
  top: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(180deg, var(--app-bg-grad) 0%, var(--app-bg) 62%, var(--app-bg-end) 100%);
  overflow: hidden;
  pointer-events: none;
  z-index: 0;
}

.page-bg::before,
.page-bg::after {
  content: '';
  position: absolute;
  border-radius: 50%;
  filter: blur(70px);
  will-change: transform;
}

.page-bg::before {
  width: 480rpx;
  height: 480rpx;
  right: -120rpx;
  top: -80rpx;
  background: radial-gradient(circle, var(--app-primary-soft) 0%, rgba(255, 255, 255, 0) 70%);
  animation: blobFloat 14s ease-in-out infinite;
}

.page-bg::after {
  width: 560rpx;
  height: 560rpx;
  left: -160rpx;
  bottom: 12%;
  background: radial-gradient(circle, color-mix(in srgb, var(--app-neu-a) 40%, transparent) 0%, rgba(255, 255, 255, 0) 70%);
  animation: blobFloat 18s ease-in-out infinite reverse;
}

@keyframes blobFloat {
  0%, 100% { transform: translate3d(0, 0, 0) scale(1); }
  50% { transform: translate3d(30rpx, 40rpx, 0) scale(1.08); }
}

/* ---------- 页面容器 ---------- */
.page-container {
  position: relative;
  z-index: 1;
  min-height: 100vh;
  padding: calc(env(safe-area-inset-top, 0rpx) + 24rpx) 26rpx calc(var(--app-tab-height, 100rpx) + var(--app-playbar-height, 140rpx) + 28rpx);
  box-sizing: border-box;
  background: transparent;
  animation: iosPageIn 0.32s cubic-bezier(.4, 0, .2, 1) backwards;
}

/* 二级页容器：自定义导航条（状态栏 + 约 128rpx 导航条） */
.subpage {
  position: relative;
  z-index: 1;
  min-height: 100vh;
  padding: calc(env(safe-area-inset-top, 0rpx) + 176rpx) 26rpx calc(env(safe-area-inset-bottom, 0rpx) + 44rpx);
  box-sizing: border-box;
  background: transparent;
  animation: iosPageIn 0.32s cubic-bezier(.4, 0, .2, 1) backwards;
}

/* 沉浸页容器：无导航、无留白，全屏内容 */
.fullpage {
  position: relative;
  z-index: 1;
  min-height: 100vh;
  box-sizing: border-box;
  background: transparent;
}

/* iOS 页面进入动效：轻微上浮 + 淡入 */
@keyframes iosPageIn {
  from {
    opacity: 0;
    transform: translateY(18rpx);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@media (prefers-reduced-motion: reduce) {
  .page-container,
  .subpage,
  .fullpage {
    animation: none;
  }
  .page-bg::before,
  .page-bg::after {
    animation: none;
  }
}

/* ---------- 交互按压反馈 ---------- */
.pressable {
  transition: transform 0.18s cubic-bezier(.4, 0, .2, 1), opacity 0.18s;

  &:active {
    transform: scale(0.97);
    opacity: 0.85;
  }
}

/* ---------- 按钮 Primary ---------- */
.btn-primary {
  background: var(--app-primary);
  color: var(--app-on-primary);
  border-radius: 26rpx;
  padding: 22rpx 44rpx;
  font-size: 29rpx;
  font-weight: 600;
  letter-spacing: 1rpx;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 10rpx 26rpx color-mix(in srgb, var(--app-primary) 30%, transparent);
  transition: all 0.18s cubic-bezier(.4, 0, .2, 1);

  &:active {
    opacity: 0.82;
    transform: scale(0.97);
  }
}

/* ---------- 按钮 Outline ---------- */
.btn-outline {
  background: transparent;
  color: var(--app-primary);
  border: 1rpx solid color-mix(in srgb, var(--app-primary) 60%, transparent);
  border-radius: 26rpx;
  padding: 20rpx 44rpx;
  font-size: 29rpx;
  font-weight: 600;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.18s;

  &:active {
    background: var(--app-primary-soft);
  }
}

/* ---------- 玻璃卡片（Liquid Glass） ---------- */
.app-card {
  position: relative;
  background: var(--app-card-bg);
  border: 1rpx solid var(--app-card-border);
  border-radius: 28rpx;
  box-shadow: var(--app-card-shadow);
  backdrop-filter: blur(var(--app-card-blur));
  -webkit-backdrop-filter: blur(var(--app-card-blur));
}

.app-card::before {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: inherit;
  border: 1rpx solid var(--app-edge-highlight);
  pointer-events: none;
  opacity: 0.6;
}

/* backdrop-filter 不支持回退：高不透明纯色 */
@supports not ((backdrop-filter: blur(20px)) or (-webkit-backdrop-filter: blur(20px))) {
  .app-card,
  .group-card {
    background: var(--app-neu-tint);
  }
  uni-tabbar,
  uni-tabbar .uni-tabbar__bd {
    background: var(--app-neu-tint) !important;
  }
}

/* ---------- 新拟态双影工具类 ---------- */
.neu-raised {
  background: var(--app-neu-tint);
  box-shadow: var(--app-neu-raised);
}

.neu-pressed {
  background: var(--app-neu-tint);
  box-shadow: var(--app-neu-pressed);
}

/* ---------- inset 分组列表 ---------- */
.group-card {
  border-radius: 32rpx;
  overflow: hidden;
  background: var(--app-card-bg);
  border: 1rpx solid var(--app-card-border);
  box-shadow: var(--app-card-shadow);
  backdrop-filter: blur(var(--app-card-blur));
  -webkit-backdrop-filter: blur(var(--app-card-blur));
}

.group-gap {
  height: 36rpx;
}

.group-title {
  font-size: 24rpx;
  font-weight: 600;
  letter-spacing: 0.3rpx;
  color: var(--app-text-2);
  padding: 12rpx 36rpx 12rpx;
  display: block;
}

/* ---------- 页面大标题 ---------- */
.page-title {
  font-size: 52rpx;
  font-weight: 700;
  letter-spacing: -1.5rpx;
  color: var(--app-text);
  line-height: 1.15;
  display: block;
}

/* ---------- 小节标题 ---------- */
.section-title {
  font-size: 24rpx;
  font-weight: 600;
  letter-spacing: 0.3rpx;
  color: var(--app-text-2);
  margin-bottom: 16rpx;
  padding-left: 8rpx;
  display: block;
}

.page-subtitle {
  font-size: 26rpx;
  font-weight: 400;
  letter-spacing: 0rpx;
  color: var(--app-text-2);
  margin-top: 10rpx;
  display: block;
}

/* ---------- 玻璃输入框 ---------- */
.glass-input {
  background: var(--app-input-bg);
  border: 1rpx solid var(--app-input-border);
  border-radius: 24rpx;
  padding: 18rpx 26rpx;
  color: var(--app-text);
  font-size: $uni-font-size-base;
  width: 100%;
  box-sizing: border-box;
}

.glass-input::placeholder {
  color: var(--app-text-3);
}

/* ---------- 分隔线 ---------- */
.divider {
  height: 1rpx;
  background: var(--app-divider);
}

/* 底部安全区 */
.safe-bottom {
  padding-bottom: constant(safe-area-inset-bottom);
  padding-bottom: env(safe-area-inset-bottom);
}

/* ============================================================
   H5 原生 tabBar 玻璃化
   ============================================================ */
uni-tabbar,
uni-tabbar .uni-tabbar,
uni-tabbar .uni-tabbar__bd {
  background: var(--app-card-bg) !important;
  border-top: 1rpx solid var(--app-divider) !important;
  backdrop-filter: blur(var(--app-card-blur)) !important;
  -webkit-backdrop-filter: blur(var(--app-card-blur)) !important;
}

uni-tabbar .uni-tabbar__label {
  color: var(--app-text-3) !important;
}

uni-tabbar .uni-tabbar__label--active,
uni-tabbar .uni-tabbar__label.uni-tabbar__label--active {
  color: var(--app-primary) !important;
}
</style>
```

- [ ] **Step 4: 校验**

```bash
npm run type-check
```

重点检查：`Icon.vue` 新增 `v-else-if` 键不存在 emoji/自闭合问题；`App.vue` 里 `@supports not ((backdrop-filter: blur(20px)) or (-webkit-backdrop-filter: blur(20px)))` 的嵌套写法是否被 scss 接受（若不接受，改写为两个独立 `@supports` 块）；`color-mix` 是否触发构建警告（可容忍）。

- [ ] **Step 5: 提交**

```bash
git add -A && git commit -m "style(base): 图标库 +7、SCSS 静态令牌、全局新拟态×Liquid Glass 样式升级"
```

> **任务完成标准**：`npm run type-check` 零错误；`npm run dev:h5` 首页/我的页出现全屏青绿渐变背景 + 右上主色光斑与左下中性光斑并缓慢浮动；玻璃卡片带发丝级边缘高光；开发者工具「渲染 → 模拟 CSS prefers-color-scheme: dark」时背景、光斑与负极平滑切换（`--app-bg`/`--app-edge-highlight` 等变量变化）。

***

## Task 3: 核心组件库 A（NeGlass / NeChip / NeSlider）

**Files:**

- Create: `src/components/NeGlass.vue`

- Create: `src/components/NeChip.vue`

- Create: `src/components/NeSlider.vue`

**Interfaces:**

- Consumes：Task 1 的 `--app-neu-raised`/`--app-neu-pressed`/`--app-glass-*` 等运行时令牌；Task 2 的 `$app-gap-*`/`$app-ease` 静态令牌。

- Produces（统一双向绑定约定）：

  - `NeGlass`：props `padding?: string`（默认 `28rpx`）、`radius?: string`（默认 `32rpx`）、`pressable?: boolean`；默认 slot；根节点 class `ne-glass`。

  - `NeChip`：props `label: string`、`active?: boolean`；emits `(e:'tap')`；根节点 class `ne-chip` + 条件 `ne-chip--on`。

  - `NeSlider`：props `modelValue: number`、`min?: number`（0）、`max?: number`（100）、`step?: number`（1）；emits `update:modelValue`、`change`；根节点 class `ne-slider`（内部含轨道 `ne-slider__track`、进度 `ne-slider__fill`、滑块 `ne-slider__thumb`）。

- 全部组件根节点可被外部追加 class（透传 `$attrs`），供页面控制尺寸/边距。

- [ ] **Step 1: 创建** **`src/components/NeGlass.vue`**

```vue
<template>
  <view class="ne-glass" :class="{ 'ne-glass--press': pressable }" v-bind="$attrs">
    <slot />
  </view>
</template>

<script setup lang="ts">
withDefaults(defineProps<{
  padding?: string
  radius?: string
  pressable?: boolean
}>(), {
  padding: '28rpx',
  radius: '32rpx',
  pressable: false,
})
</script>

<style lang="scss" scoped>
@import '@/uni.scss';

@supports ((backdrop-filter: blur(20px)) or (-webkit-backdrop-filter: blur(20px))) {
  .ne-glass {
    background: var(--app-card-bg);
    border: 1rpx solid var(--app-card-border);
    box-shadow: var(--app-card-shadow);
    backdrop-filter: blur(var(--app-card-blur));
    -webkit-backdrop-filter: blur(var(--app-card-blur));
  }
}

.ne-glass {
  position: relative;
  border-radius: v-bind(radius);
  padding: v-bind(padding);
  box-sizing: border-box;
}

.ne-glass::before {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: inherit;
  border: 1rpx solid var(--app-edge-highlight);
  pointer-events: none;
  opacity: 0.6;
}

@supports not ((backdrop-filter: blur(20px)) or (-webkit-backdrop-filter: blur(20px))) {
  .ne-glass {
    background: var(--app-neu-tint);
    border: 1rpx solid var(--app-neu-a);
    box-shadow: var(--app-neu-raised);
  }
}

.ne-glass--press {
  transition: transform $app-duration $app-ease, opacity $app-duration;

  &:active {
    transform: scale(0.97);
    opacity: 0.85;
  }
}
</style>
```

> 说明：uni-app vue3 的 `v-bind(radius)` 会把 prop 编译为 CSS 变量注入并支持 rpx 字符串。

- [ ] **Step 2: 创建** **`src/components/NeChip.vue`**

```vue
<template>
  <view class="ne-chip" :class="{ 'ne-chip--on': active }" @tap="emit('tap')" v-bind="$attrs">
    <slot>{{ label }}</slot>
  </view>
</template>

<script setup lang="ts">
withDefaults(defineProps<{
  label: string
  active?: boolean
}>(), {
  active: false,
})

const emit = defineEmits<{ (e: 'tap'): void }>()
</script>

<style lang="scss" scoped>
@import '@/uni.scss';

.ne-chip {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 14rpx 30rpx;
  min-height: 64rpx;
  border-radius: 999rpx;
  background: var(--app-card-bg);
  border: 1rpx solid var(--app-card-border);
  color: var(--app-text-2);
  font-size: 26rpx;
  font-weight: 500;
  transition: all $app-duration $app-ease;
  backdrop-filter: blur(var(--app-card-blur));
  -webkit-backdrop-filter: blur(var(--app-card-blur));

  &:active {
    transform: scale(0.95);
  }
}

.ne-chip--on {
  background: var(--app-primary);
  border-color: var(--app-primary);
  color: var(--app-on-primary);
  font-weight: 600;
}
</style>
```

- [ ] **Step 3: 创建** **`src/components/NeSlider.vue`**

```vue
<template>
  <view class="ne-slider" @touchstart="onStart" @touchmove="onMove" @touchend="onEnd">
    <view class="ne-slider__track">
      <view class="ne-slider__fill" :style="{ width: `${fillPercent}%` }" />
      <view class="ne-slider__thumb" :style="{ left: `${fillPercent}%` }" />
    </view>
  </view>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'

const props = withDefaults(defineProps<{
  modelValue: number
  min?: number
  max?: number
  step?: number
}>(), {
  min: 0,
  max: 100,
  step: 1,
})

const emit = defineEmits<{
  (e: 'update:modelValue', v: number): void
  (e: 'change', v: number): void
}>()

const trackEl = ref<unknown>(null)
const fillPercent = computed(() =>
  props.max === props.min ? 0 : ((props.modelValue - props.min) / (props.max - props.min)) * 100,
)

function clampToStep(v: number): number {
  const steps = Math.round((v - props.min) / props.step)
  return Math.min(props.max, Math.max(props.min, props.min + steps * props.step))
}

function getRect(): Promise<{ left: number; width: number }> {
  return new Promise((resolve) => {
    const q = uni.createSelectorQuery().in(trackEl.value)
    q.select('.ne-slider__track').boundingClientRect((rect) => {
      resolve(rect || { left: 0, width: 1 })
    }).exec()
  })
}

async function onStart(e: UniApp.TouchEvent) {
  const rect = await getRect()
  const touch = e.touches[0]
  const ratio = Math.min(1, Math.max(0, (touch.clientX - rect.left) / rect.width))
  emit('update:modelValue', clampToStep(props.min + ratio * (props.max - props.min)))
  emit('change', clampToStep(props.min + ratio * (props.max - props.min)))
}

async function onMove(e: UniApp.TouchEvent) {
  const rect = await getRect()
  const touch = e.touches[0]
  const ratio = Math.min(1, Math.max(0, (touch.clientX - rect.left) / rect.width))
  emit('update:modelValue', clampToStep(props.min + ratio * (props.max - props.min)))
}

async function onEnd() {
  emit('change', props.modelValue)
}
</script>

<style lang="scss" scoped>
.ne-slider {
  position: relative;
  height: 64rpx;
  display: flex;
  align-items: center;
  touch-action: none;
}

.ne-slider__track {
  position: relative;
  width: 100%;
  height: 12rpx;
  border-radius: 999rpx;
  background: var(--app-neu-tint);
  box-shadow: inset 2rpx 2rpx 6rpx var(--app-neu-a), inset -2rpx -2rpx 6rpx var(--app-neu-b);
}

.ne-slider__fill {
  position: absolute;
  left: 0;
  top: 0;
  bottom: 0;
  border-radius: 999rpx;
  background: linear-gradient(90deg, var(--app-neu-b), var(--app-primary));
  opacity: 0.9;
}

.ne-slider__thumb {
  position: absolute;
  top: 50%;
  transform: translate(-50%, -50%);
  width: 44rpx;
  height: 44rpx;
  border-radius: 50%;
  background: var(--app-neu-tint);
  box-shadow: var(--app-neu-raised), 0 0 0 2rpx var(--app-primary-soft);
}
</style>
```

> 说明：`trackEl` 使用 `ref<unknown>(null)`，`uni.createSelectorQuery().in()` 的参数类型为 `any`，可直接传入；`boundingClientRect` 回调的 `rect` 由 uni-app 类型推导，若提示可能为 `null`，`getRect` 内已用 `rect || { left: 0, width: 1 }` 兜底。

- [ ] **Step 4: 校验**

```bash
npm run type-check
```

重点检查：`NeSlider` 的 `uni.getSystemInfoSync()` 是否需 `// @ts-ignore`（若报错则加）；`NeGlass` 的 `v-bind(radius)` 是否被 scss 编译（若报错，改为 `:style="{ borderRadius: radius }"` 绑定到根节点并保留 padding 走 css）。

- [ ] **Step 5: 提交**

```bash
git add -A && git commit -m "feat(components): NeGlass/NeChip/NeSlider 核心组件库 A"
```

> **任务完成标准**：`npm run type-check` 零错误；`npm run dev:h5` 下临时在 `mine` 页插入三个组件手测：NeGlass 出现玻璃底 + 边缘高光、NeChip 点击切换选中态、NeSlider 拖动更新进度条（验证完即移除临时代码）。

***

## Task 4: 核心组件库 B（NeSwitch / NeSegmented / NeSheet）

**Files:**

- Create: `src/components/NeSwitch.vue`

- Create: `src/components/NeSegmented.vue`

- Create: `src/components/NeSheet.vue`

**Interfaces:**

- Consumes：Task 1 令牌；Task 2 静态令牌。

- Produces：

  - `NeSwitch`：props `modelValue: boolean`、`disabled?: boolean`；emits `update:modelValue`、`change`；class `ne-switch` + `ne-switch--on`。

  - `NeSegmented`：props `options: { label: string; value: string }[]`、`modelValue: string`；emits `update:modelValue`、`change`；class `ne-segmented`，选中项 `ne-segmented__item--on`。

  - `NeSheet`：props `visible: boolean`、`title?: string`、`grab?: boolean`（默认 true）；emits `update:visible`（下滑/遮罩关闭触发）；默认 slot 为面板内容；class `ne-sheet`（遮罩 `ne-sheet__mask` + 面板 `ne-sheet__panel`）。

- [ ] **Step 1: 创建** **`src/components/NeSwitch.vue`**

```vue
<template>
  <view
    class="ne-switch"
    :class="{ 'ne-switch--on': modelValue, 'ne-switch--disabled': disabled }"
    @tap="toggle"
  >
    <view class="ne-switch__thumb" />
  </view>
</template>

<script setup lang="ts">
const props = withDefaults(defineProps<{
  modelValue: boolean
  disabled?: boolean
}>(), {
  disabled: false,
})

const emit = defineEmits<{
  (e: 'update:modelValue', v: boolean): void
  (e: 'change', v: boolean): void
}>()

function toggle() {
  if (props.disabled) return
  const v = !props.modelValue
  emit('update:modelValue', v)
  emit('change', v)
}
</script>

<style lang="scss" scoped>
.ne-switch {
  width: 96rpx;
  height: 56rpx;
  border-radius: 999rpx;
  background: var(--app-input-border);
  border: 1rpx solid var(--app-divider);
  padding: 4rpx;
  box-sizing: border-box;
  transition: background 0.25s ease;
  display: flex;
  align-items: center;
}

.ne-switch__thumb {
  width: 46rpx;
  height: 46rpx;
  border-radius: 50%;
  background: #ffffff;
  box-shadow: 0 2rpx 6rpx rgba(0, 0, 0, 0.18);
  transform: translateX(0);
  transition: transform 0.25s cubic-bezier(.4, 0, .2, 1);
}

.ne-switch--on {
  background: var(--app-primary);
  border-color: var(--app-primary);

  .ne-switch__thumb {
    transform: translateX(40rpx);
  }
}

.ne-switch--disabled {
  opacity: 0.4;
}
</style>
```

- [ ] **Step 2: 创建** **`src/components/NeSegmented.vue`**

```vue
<template>
  <view class="ne-segmented">
    <view
      v-for="opt in options"
      :key="opt.value"
      class="ne-segmented__item"
      :class="{ 'ne-segmented__item--on': opt.value === modelValue }"
      @tap="pick(opt.value)"
    >
      {{ opt.label }}
    </view>
  </view>
</template>

<script setup lang="ts">
withDefaults(defineProps<{
  options: { label: string; value: string }[]
  modelValue: string
}>(), {
  options: () => [],
})

const emit = defineEmits<{
  (e: 'update:modelValue', v: string): void
  (e: 'change', v: string): void
}>()

function pick(value: string) {
  emit('update:modelValue', value)
  emit('change', value)
}
</script>

<style lang="scss" scoped>
@import '@/uni.scss';

.ne-segmented {
  display: flex;
  padding: 8rpx;
  border-radius: 28rpx;
  background: var(--app-neu-tint);
  box-shadow: inset 3rpx 3rpx 8rpx var(--app-neu-a), inset -3rpx -3rpx 8rpx var(--app-neu-b);
  gap: 8rpx;
}

.ne-segmented__item {
  flex: 1;
  text-align: center;
  padding: 16rpx 0;
  border-radius: 20rpx;
  font-size: 27rpx;
  color: var(--app-text-2);
  transition: all $app-duration $app-ease;
}

.ne-segmented__item--on {
  background: var(--app-card-bg);
  color: var(--app-text);
  font-weight: 600;
  box-shadow: var(--app-neu-raised);
}
</style>
```

- [ ] **Step 3: 创建** **`src/components/NeSheet.vue`**

```vue
<template>
  <view v-if="visible" class="ne-sheet">
    <view class="ne-sheet__mask" @tap="close" />
    <view class="ne-sheet__panel">
      <view v-if="grab" class="ne-sheet__grabber" />
      <view v-if="title" class="ne-sheet__header">
        <text class="ne-sheet__title">{{ title }}</text>
      </view>
      <slot />
    </view>
  </view>
</template>

<script setup lang="ts">
withDefaults(defineProps<{
  visible: boolean
  title?: string
  grab?: boolean
}>(), {
  title: '',
  grab: true,
})

const emit = defineEmits<{ (e: 'update:visible', v: boolean): void }>()

function close() {
  emit('update:visible', false)
}
</script>

<style lang="scss" scoped>
@import '@/uni.scss';

.ne-sheet {
  position: fixed;
  inset: 0;
  z-index: 999;
  display: flex;
  align-items: flex-end;
}

.ne-sheet__mask {
  position: absolute;
  inset: 0;
  background: rgba(0, 0, 0, 0.35);
  animation: maskIn 0.28s ease both;
}

.ne-sheet__panel {
  position: relative;
  width: 100%;
  max-height: 88vh;
  overflow-y: auto;
  border-radius: 48rpx 48rpx 0 0;
  background: var(--app-card-bg);
  border-top: 1rpx solid var(--app-card-border);
  box-shadow: 0 -10rpx 40rpx rgba(0, 0, 0, 0.14);
  backdrop-filter: blur(var(--app-card-blur));
  -webkit-backdrop-filter: blur(var(--app-card-blur));
  padding: 0 32rpx calc(env(safe-area-inset-bottom, 0rpx) + 32rpx);
  padding-top: 0;
  box-sizing: border-box;
  animation: sheetUp 0.32s cubic-bezier(.32, 0.72, 0, 1) both;
}

.ne-sheet__grabber {
  width: 72rpx;
  height: 10rpx;
  border-radius: 999rpx;
  background: var(--app-text-3);
  opacity: 0.5;
  margin: 20rpx auto 8rpx;
}

.ne-sheet__header {
  padding: 8rpx 8rpx 20rpx;
  text-align: center;
}

.ne-sheet__title {
  font-size: 30rpx;
  font-weight: 600;
  color: var(--app-text);
}

@keyframes maskIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes sheetUp {
  from { transform: translateY(100%); }
  to { transform: translateY(0); }
}
</style>
```

- [ ] **Step 4: 校验**

```bash
npm run type-check
```

如 `NeSwitch`/`NeSegmented` 的 props 在模板外被引用（`props.disabled`/`props.modelValue`），必须用 `const props = withDefaults(defineProps<...>(), {...})` 具名接收后再使用；`NeSwitch.toggle()` 中 `props.disabled`、`props.modelValue` 即依赖该写法，删除具名接收会导致 `props is not defined`。

- [ ] **Step 5: 提交**

```bash
git add -A && git commit -m "feat(components): NeSwitch/NeSegmented/NeSheet 核心组件库 B"
```

> **任务完成标准**：`npm run type-check` 零错误；`dev:h5` 下 NeSwitch 开关动效、NeSegmented 选中态、NeSheet 上滑入场 + 遮罩点击关闭 + grabber 展示均正常。

***

## Task 5: 核心组件库 C（NavBar / LargeTitle / ListRow / EmptyState）

**Files:**

- Create: `src/components/NavBar.vue`

- Create: `src/components/LargeTitle.vue`

- Create: `src/components/ListRow.vue`

- Create: `src/components/EmptyState.vue`

**Interfaces:**

- Consumes：Task 1 令牌；Task 2 的 `chevron-left` 图标与全局工具类。

- Produces：

  - `NavBar`：props `title?: string`、`transparent?: boolean`、`showBack?: boolean`（默认 true）；emits `back`（未提供时不 emit，内部 `uni.navigateBack()`）；class `nav-bar`，含 `<Icon name="chevron-left" />` 返回钮。

  - `LargeTitle`：props `title: string`、`subtitle?: string`；默认 slot 追加在标题下方；class `large-title`/`large-title__sub`。

  - `ListRow`：props `label: string`、`desc?: string`、`icon?: string` ｜ `iconColor`、`value?: string`、`showChevron?: boolean`（默认 true）、`last?: boolean`（隐藏底部分隔线）；emits `tap`；class `list-row`。

  - `EmptyState`：props `icon?: string`（默认 `mountain`）、`title: string`、`desc?: string`；默认 slot 放操作按钮；class `empty-state`。

- [ ] **Step 1: 创建** **`src/components/NavBar.vue`**

```vue
<template>
  <view class="nav-bar" :class="{ 'nav-bar--transparent': transparent }">
    <view v-if="showBack" class="nav-bar__back" hover-class="nav-bar__back--hover" @tap="onBack">
      <Icon name="chevron-left" :size="30" color="var(--app-ios-blue)" />
      <text class="nav-bar__back-label">返回</text>
    </view>
    <text class="nav-bar__title">{{ title }}</text>
    <view class="nav-bar__side"></view>
  </view>
</template>

<script setup lang="ts">
import Icon from '@/components/Icon.vue'

withDefaults(defineProps<{
  title?: string
  transparent?: boolean
  showBack?: boolean
}>(), {
  title: '',
  transparent: false,
  showBack: true,
})

const emit = defineEmits<{ (e: 'back'): void }>()

function onBack() {
  emit('back')
  // @ts-ignore
  uni.navigateBack()
}
</script>

<style lang="scss" scoped>
.nav-bar {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 100;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-top: env(safe-area-inset-top, 0rpx);
  height: calc(env(safe-area-inset-top, 0rpx) + 88rpx);
  box-sizing: border-box;
  padding-left: 16rpx;
  padding-right: 16rpx;
}

.nav-bar--transparent {
  background: transparent;
}

.nav-bar__back {
  display: flex;
  align-items: center;
  min-width: 140rpx;
  height: 88rpx;
}

.nav-bar__back--hover {
  opacity: 0.5;
}

.nav-bar__back-label {
  font-size: 30rpx;
  color: var(--app-ios-blue);
  margin-left: 2rpx;
}

.nav-bar__title {
  position: absolute;
  left: 50%;
  transform: translateX(-50%);
  font-size: 32rpx;
  font-weight: 600;
  color: var(--app-text);
  text-align: center;
}

.nav-bar__side {
  min-width: 140rpx;
}
</style>
```

- [ ] **Step 2: 创建** **`src/components/LargeTitle.vue`**

```vue
<template>
  <view class="large-title">
    <text class="large-title__main">{{ title }}</text>
    <text v-if="subtitle" class="large-title__sub">{{ subtitle }}</text>
    <view class="large-title__extra">
      <slot />
    </view>
  </view>
</template>

<script setup lang="ts">
withDefaults(defineProps<{
  title: string
  subtitle?: string
}>(), {
  subtitle: '',
})
</script>

<style lang="scss" scoped>
@import '@/uni.scss';

.large-title {
  padding: 8rpx 0 24rpx;
}

.large-title__main {
  display: block;
  font-size: 64rpx;
  font-weight: 700;
  letter-spacing: -1.5rpx;
  line-height: 1.12;
  color: var(--app-text);
}

.large-title__sub {
  display: block;
  margin-top: 12rpx;
  font-size: 28rpx;
  color: var(--app-text-2);
}

.large-title__extra {
  margin-top: $app-gap;
}
</style>
```

- [ ] **Step 3: 创建** **`src/components/ListRow.vue`**

```vue
<template>
  <view class="list-row" :class="{ 'list-row--last': last }" @tap="onTap" hover-class="list-row--hover">
    <Icon v-if="icon" :name="icon" :size="30" :color="iconColor" class="list-row__icon" />
    <view class="list-row__body">
      <text class="list-row__label">{{ label }}</text>
      <text v-if="desc" class="list-row__desc">{{ desc }}</text>
    </view>
    <text v-if="value" class="list-row__value">{{ value }}</text>
    <Icon v-if="showChevron" name="chevron-right" :size="26" color="var(--app-text-3)" class="list-row__chevron" />
  </view>
</template>

<script setup lang="ts">
import Icon from '@/components/Icon.vue'

withDefaults(defineProps<{
  label: string
  desc?: string
  icon?: string
  iconColor?: string
  value?: string
  showChevron?: boolean
  last?: boolean
}>(), {
  desc: '',
  icon: '',
  iconColor: 'var(--app-primary)',
  value: '',
  showChevron: true,
  last: false,
})

const emit = defineEmits<{ (e: 'tap'): void }>()

function onTap() {
  emit('tap')
}
</script>

<style lang="scss" scoped>
@import '@/uni.scss';

.list-row {
  display: flex;
  align-items: center;
  min-height: 112rpx;
  padding: 20rpx 32rpx;
  background: var(--app-card-bg);
  border-bottom: 1rpx solid var(--app-divider);
  transition: background $app-duration;

  &:last-child {
    border-bottom: none;
  }
}

.list-row--hover {
  background: var(--app-subtle);
}

.list-row--last {
  border-bottom: none;
}

.list-row__icon {
  margin-right: 24rpx;
  flex-shrink: 0;
}

.list-row__body {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4rpx;
  min-width: 0;
}

.list-row__label {
  font-size: 30rpx;
  color: var(--app-text);
}

.list-row__desc {
  font-size: 24rpx;
  color: var(--app-text-3);
}

.list-row__value {
  font-size: 28rpx;
  color: var(--app-text-2);
  margin-right: 8rpx;
}

.list-row__chevron {
  flex-shrink: 0;
}
</style>
```

- [ ] **Step 4: 创建** **`src/components/EmptyState.vue`**

```vue
<template>
  <view class="empty-state">
    <view class="empty-state__icon neu-raised">
      <Icon :name="icon" :size="64" color="var(--app-text-3)" />
    </view>
    <text class="empty-state__title">{{ title }}</text>
    <text v-if="desc" class="empty-state__desc">{{ desc }}</text>
    <view class="empty-state__action">
      <slot />
    </view>
  </view>
</template>

<script setup lang="ts">
import Icon from '@/components/Icon.vue'

withDefaults(defineProps<{
  icon?: string
  title: string
  desc?: string
}>(), {
  icon: 'mountain',
  desc: '',
})
</script>

<style lang="scss" scoped>
@import '@/uni.scss';

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 100rpx 60rpx;
  text-align: center;
}

.empty-state__icon {
  width: 140rpx;
  height: 140rpx;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: $app-gap;
}

.empty-state__title {
  font-size: 32rpx;
  font-weight: 600;
  color: var(--app-text);
}

.empty-state__desc {
  margin-top: 12rpx;
  font-size: 26rpx;
  color: var(--app-text-2);
  line-height: 1.6;
}

.empty-state__action {
  margin-top: $app-gap-lg;
  display: flex;
  justify-content: center;
  width: 100%;
}
</style>
```

- [ ] **Step 5: 校验**

```bash
npm run type-check
```

如 `Icon` 的 `color="var(--app-ios-blue)"` 因类型导致报错（`color?: string` 已允许字符串），不应报错；若 `hover-class` 提示类型问题，移除该属性即可。

- [ ] **Step 6: 提交**

```bash
git add -A && git commit -m "feat(components): NavBar/LargeTitle/ListRow/EmptyState 核心组件库 C"
```

> **任务完成标准**：`npm run type-check` 零错误；`dev:h5` 下 NavBar 返回钮返回上一页、LargeTitle 大标题渲染、ListRow 分组行带 chevron 与分隔线、EmptyState 空态占位均正常。

***

# P1 四大 Tab 根页
