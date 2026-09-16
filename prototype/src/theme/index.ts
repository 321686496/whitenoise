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
