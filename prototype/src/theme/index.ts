/**
 * 声栖 · 全局主题引擎
 *
 * 以 "配色方案 × UI 风格" 二维组合生成运行时 CSS 变量，
 * 统一注入到 html 根节点，实现全局即时切换（无需重新编译）。
 *
 * 配色方案：morandi 莫兰迪 / ocean 深海 / forest 森林
 *           sunset 日落 / lavender 薰衣草 / mono 极简黑白
 * UI 风格：flat 扁平化 / glass 玻璃拟态 / neu 新拟态
 */

export type SchemeKey = 'morandi' | 'ocean' | 'forest' | 'sunset' | 'lavender' | 'mono'
export type UiMode = 'flat' | 'glass' | 'neu'

export interface SchemeMeta {
  label: string
  desc: string
  swatch: string[]
}

/** 每套配色的基础色板（不含 UI 风格相关的容器/阴影） */
interface SchemeTokens {
  primary: string
  primarySoft: string
  primaryDark: string
  onPrimary: string
  accent: string
  bg: string
  bgGrad: string
  cardBorder: string
  text: string
  text2: string
  text3: string
  divider: string
  subtle: string
  danger: string
  glassCard: string
  glassBorder: string
  neuTint: string
  neuA: string
  neuB: string
}

const schemes: Record<SchemeKey, { meta: SchemeMeta; t: SchemeTokens }> = {
  morandi: {
    meta: { label: '莫兰迪', desc: '森系柔和的低饱和配色', swatch: ['#5C8A72', '#A3C4B0', '#F3F1EB', '#C4706B'] },
    t: {
      primary: '#5C8A72', primarySoft: 'rgba(92,138,114,.14)', primaryDark: '#3F6352', onPrimary: '#FFFFFF',
      accent: '#8FB8A0', bg: '#F2F0EA', bgGrad: '#E7E4DA', cardBorder: '#E6E1D6',
      text: '#2F3B35', text2: '#6E7B74', text3: '#A6B0A9', divider: '#ECE8DE',
      subtle: '#ECE9E0', danger: '#C4706B',
      glassCard: 'rgba(255,255,255,.62)', glassBorder: 'rgba(255,255,255,.9)',
      neuTint: '#EAE7DD', neuA: 'rgba(90,110,100,.16)', neuB: 'rgba(255,255,255,.92)',
    },
  },
  ocean: {
    meta: { label: '深海', desc: '深邃冷静的靛蓝夜色', swatch: ['#5FB0B0', '#4A9AA0', '#0E2230', '#9FD4D4'] },
    t: {
      primary: '#5FB0B0', primarySoft: 'rgba(95,176,176,.16)', primaryDark: '#3E8C8C', onPrimary: '#062026',
      accent: '#9FD4D4', bg: '#0E2230', bgGrad: '#16303F', cardBorder: '#244453',
      text: '#E6F2F3', text2: '#9FB9C1', text3: '#6E8C95', divider: '#244150',
      subtle: '#1D3946', danger: '#D98B7B',
      glassCard: 'rgba(22,48,62,.58)', glassBorder: 'rgba(255,255,255,.14)',
      neuTint: '#14303E', neuA: 'rgba(0,0,0,.38)', neuB: 'rgba(70,120,140,.16)',
    },
  },
  forest: {
    meta: { label: '森林', desc: '自然清新的苔绿色调', swatch: ['#4A6741', '#7C9D6E', '#EEF1E6', '#C0705B'] },
    t: {
      primary: '#4A6741', primarySoft: 'rgba(74,103,65,.14)', primaryDark: '#334A2C', onPrimary: '#FFFFFF',
      accent: '#7C9D6E', bg: '#EEF1E6', bgGrad: '#E0E9D6', cardBorder: '#E0E6D5',
      text: '#2C3628', text2: '#68725D', text3: '#99A48F', divider: '#E5EADB',
      subtle: '#E4ECDA', danger: '#C0705B',
      glassCard: 'rgba(255,255,255,.6)', glassBorder: 'rgba(255,255,255,.85)',
      neuTint: '#E3ECDA', neuA: 'rgba(60,90,50,.16)', neuB: 'rgba(255,255,255,.92)',
    },
  },
  sunset: {
    meta: { label: '日落', desc: '温暖治愈的暮橙色调', swatch: ['#C06B48', '#E3A377', '#FBF1E6', '#C15B58'] },
    t: {
      primary: '#C06B48', primarySoft: 'rgba(192,107,72,.14)', primaryDark: '#9C4E32', onPrimary: '#FFFFFF',
      accent: '#E3A377', bg: '#FBF1E6', bgGrad: '#F4E2CE', cardBorder: '#F0E0CE',
      text: '#3E3128', text2: '#7E6E62', text3: '#AB9A8B', divider: '#F2E8DC',
      subtle: '#F6EADD', danger: '#C15B58',
      glassCard: 'rgba(255,255,255,.62)', glassBorder: 'rgba(255,255,255,.88)',
      neuTint: '#F2E4D5', neuA: 'rgba(160,100,70,.16)', neuB: 'rgba(255,255,255,.92)',
    },
  },
  lavender: {
    meta: { label: '薰衣草', desc: '温柔静谧的淡紫配色', swatch: ['#8A7BB0', '#B3A5CE', '#F4F1FA', '#C0759B'] },
    t: {
      primary: '#8A7BB0', primarySoft: 'rgba(138,123,176,.14)', primaryDark: '#6A5A8E', onPrimary: '#FFFFFF',
      accent: '#B3A5CE', bg: '#F4F1FA', bgGrad: '#E9E3F4', cardBorder: '#E2DCF0',
      text: '#37324A', text2: '#7A7292', text3: '#A8A1C0', divider: '#ECE6F5',
      subtle: '#EDE9F5', danger: '#C0759B',
      glassCard: 'rgba(255,255,255,.62)', glassBorder: 'rgba(255,255,255,.88)',
      neuTint: '#E8E3F3', neuA: 'rgba(105,85,140,.16)', neuB: 'rgba(255,255,255,.92)',
    },
  },
  mono: {
    meta: { label: '极简黑白', desc: '克制统一的黑白灰', swatch: ['#2F2F2F', '#6B6B6B', '#FAFAFA', '#B1483D'] },
    t: {
      primary: '#2F2F2F', primarySoft: 'rgba(31,31,31,.08)', primaryDark: '#101010', onPrimary: '#FFFFFF',
      accent: '#6B6B6B', bg: '#FAFAFA', bgGrad: '#F0F0F0', cardBorder: '#EBEBEB',
      text: '#1A1A1A', text2: '#6E6E6E', text3: '#A9A9A9', divider: '#EDEDED',
      subtle: '#F2F2F2', danger: '#B1483D',
      glassCard: 'rgba(255,255,255,.62)', glassBorder: 'rgba(255,255,255,.95)',
      neuTint: '#EFEFEF', neuA: 'rgba(0,0,0,.12)', neuB: 'rgba(255,255,255,.95)',
    },
  },
}

/* ------------------------------------------------------------------------- *
 * 运行时 CSS 变量
 * ------------------------------------------------------------------------- */

export const SCHEME_KEYS: SchemeKey[] = ['morandi', 'ocean', 'forest', 'sunset', 'lavender', 'mono']
export const UI_MODES: UiMode[] = ['flat', 'glass', 'neu']

export const schemeMeta = (k: SchemeKey) => schemes[k].meta

/** 返回当前配色下的主色 HEX（供原生组件如 switch color 绑定） */
export const schemePrimary = (k: SchemeKey) => schemes[k].t.primary
export const schemePrimaryDark = (k: SchemeKey) => schemes[k].t.primaryDark

export const UIMODE_META: Record<UiMode, { label: string; desc: string }> = {
  flat: { label: '扁平化', desc: '清爽 / 低干扰' },
  glass: { label: '玻璃拟态', desc: '通透 / 高级感' },
  neu: { label: '新拟态', desc: '柔和 / 立体' },
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

/**
 * 由配色 + UI 风格计算最终 CSS 变量表。
 * 块级容器（页面主容器）额外注入 --app-pad，用于页面水平留白。
 */
export function buildTokens(scheme: SchemeKey, ui: UiMode): Record<string, string> {
  const { t } = schemes[scheme]
  const p = rpx()
  const sh = (h: number) => `${(h * p).toFixed(2)}px`

  // 不同 UI 风格下，卡片/输入/弹层的容器变量
  let cardBg = '#FFFFFF'
  let cardBorder = t.cardBorder
  let cardShadow = `0 ${sh(2)} ${sh(12)} ${t.neuA}`
  let cardBlur = '0'
  let inputBg = t.subtle
  let inputBorder = 'transparent'

  if (ui === 'flat') {
    cardBg = '#FFFFFF'
    cardBorder = t.cardBorder
    cardShadow = `0 ${sh(2)} ${sh(12)} ${t.neuA}`
    inputBg = '#FFFFFF'
    inputBorder = t.cardBorder
  } else if (ui === 'glass') {
    cardBg = t.glassCard
    cardBorder = t.glassBorder
    cardShadow = `0 ${sh(8)} ${sh(26)} rgba(20,40,34,.10)`
    cardBlur = sh(22)
    inputBg = 'rgba(255,255,255,.5)'
    inputBorder = t.glassBorder
  } else if (ui === 'neu') {
    cardBg = t.neuTint
    cardBorder = 'transparent'
    const s = (h: number) => `${(h * p).toFixed(2)}px`
    const a = `${s(7)} ${s(7)} ${s(16)} ${t.neuA}`
    const b = `${s(-7)} ${s(-7)} ${s(18)} ${t.neuB}`
    cardShadow = `${a}, ${b}`
    inputBg = t.neuTint
    inputBorder = 'transparent'
  }

  const pressBg = ui === 'glass' ? 'rgba(255,255,255,.35)' : t.subtle

  return {
    '--app-primary': t.primary,
    '--app-primary-soft': t.primarySoft,
    '--app-primary-dark': t.primaryDark,
    '--app-on-primary': t.onPrimary,
    '--app-accent': t.accent,
    '--app-bg': t.bg,
    '--app-bg-grad': t.bgGrad,
    '--app-card-bg': cardBg,
    '--app-card-border': cardBorder,
    '--app-card-shadow': cardShadow,
    '--app-card-blur': cardBlur,
    '--app-text': t.text,
    '--app-text-2': t.text2,
    '--app-text-3': t.text3,
    '--app-divider': t.divider,
    '--app-subtle': t.subtle,
    '--app-press': pressBg,
    '--app-input-bg': inputBg,
    '--app-input-border': inputBorder,
    '--app-danger': t.danger,
    '--app-tab-height': `${(100 * p).toFixed(2)}px`,
    '--app-playbar-height': `${(140 * p).toFixed(2)}px`,
  }
}

/** 直接注入到 html 根节点 */
export function applyTheme(scheme: SchemeKey, ui: UiMode) {
  const tokens = buildTokens(scheme, ui)
  if (typeof document === 'undefined' || !document.documentElement) return
  const el = document.documentElement
  Object.entries(tokens).forEach(([k, v]) => el.style.setProperty(k, v))
  el.dataset.scheme = scheme
  el.dataset.ui = ui
}

/* ------------------------------------------------------------------------- *
 * 轻量响应式状态（供组件读取当前主题）
 * ------------------------------------------------------------------------- */
import { reactive, watch } from 'vue'

export const themeState = reactive<{ scheme: SchemeKey; ui: UiMode }>({
  scheme: 'morandi',
  ui: 'flat',
})

export function initTheme() {
  // 读取本地持久化，无则默认莫兰迪 + 扁平化
  let scheme: SchemeKey = 'morandi'
  let ui: UiMode = 'flat'
  try {
    // @ts-ignore
    const saved = uni.getStorageSync('shengqi-theme') || {}
    if (saved.scheme && SCHEME_KEYS.includes(saved.scheme)) scheme = saved.scheme
    if (saved.ui && UI_MODES.includes(saved.ui)) ui = saved.ui
  } catch {}
  themeState.scheme = scheme
  themeState.ui = ui
  applyTheme(scheme, ui)
}

export function setTheme(scheme: SchemeKey, ui: UiMode) {
  themeState.scheme = scheme
  themeState.ui = ui
  applyTheme(scheme, ui)
  try {
    // @ts-ignore
    uni.setStorageSync('shengqi-theme', { scheme, ui })
  } catch {}
}