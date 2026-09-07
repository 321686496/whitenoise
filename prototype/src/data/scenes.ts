/**
 * 声栖 · 首页场景数据
 *
 * 供首页（场景推荐网格 / 今日精选 / 金刚区）与场景页共用。
 * iconName 需与 components/Icon.vue 中已定义的图标名保持一致。
 */

import { sounds } from './sounds'

export type SceneCategory = 'sleep' | 'focus' | 'relax' | 'nature'

export interface Scene {
  id: string
  name: string
  category: SceneCategory
  desc: string
  iconName: string
  gradient: string
  soundIds: string[]
  isPreset: boolean
}

export const sceneCategories: { key: string; label: string }[] = [
  { key: 'all', label: '全部' },
  { key: 'sleep', label: '助眠' },
  { key: 'focus', label: '专注' },
  { key: 'relax', label: '放松' },
  { key: 'nature', label: '自然' },
]

/** 由 soundIds 拼出如「雨声 + 白噪音」的组合文案 */
export function soundNames(ids: string[]): string {
  return ids.map((id) => sounds.find((s) => s.id === id)?.name ?? id).join(' + ')
}

export function findScene(id: string): Scene | undefined {
  return homeScenes.find((s) => s.id === id)
}

export const homeScenes: Scene[] = [
  // 助眠
  { id: 'deep-sleep', name: '深度睡眠', category: 'sleep', desc: '雨声铺底、白噪衬静，一夜沉入深眠', iconName: 'moon', gradient: 'linear-gradient(135deg, #7E93A8, #4E7182)', soundIds: ['rain', 'white-noise', 'forest'], isPreset: true },
  { id: 'rainy-night', name: '夜雨入眠', category: 'sleep', desc: '细雨夹着篝火，温暖安全地睡去', iconName: 'rain', gradient: 'linear-gradient(135deg, #5F7A92, #B97A48)', soundIds: ['drizzle', 'thunder', 'campfire'], isPreset: true },
  { id: 'ocean-sleep', name: '海浪催眠', category: 'sleep', desc: '潮起潮落，像摇篮一样晃进梦里', iconName: 'wave-ocean', gradient: 'linear-gradient(135deg, #5F8296, #4E7182)', soundIds: ['ocean-wave', 'white-noise'], isPreset: true },
  // 专注
  { id: 'focus-white-noise', name: '专注白噪', category: 'focus', desc: '纯净声墙，一键进入心流', iconName: 'white-noise', gradient: 'linear-gradient(135deg, #8296A8, #C49A92)', soundIds: ['white-noise', 'pink-noise'], isPreset: true },
  { id: 'coffee-time', name: '咖啡时光', category: 'focus', desc: '杯碟轻响，适合写字的角落', iconName: 'coffee', gradient: 'linear-gradient(135deg, #A89068, #9A886B)', soundIds: ['cafe', 'typewriter'], isPreset: true },
  { id: 'long-train', name: '长途列车', category: 'focus', desc: '车轮规律作响，思绪随轨道延伸', iconName: 'train', gradient: 'linear-gradient(135deg, #8E82A6, #746889)', soundIds: ['train', 'white-noise'], isPreset: true },
  // 放松
  { id: 'nature-relax', name: '自然放松', category: 'relax', desc: '把大海和森林搬进房间', iconName: 'forest', gradient: 'linear-gradient(135deg, #5F8296, #7E9A74)', soundIds: ['ocean-wave', 'forest', 'stream', 'birdsong'], isPreset: true },
  { id: 'forest-meditation', name: '森林冥想', category: 'relax', desc: '空谷幽林，让呼吸慢下来', iconName: 'mountain', gradient: 'linear-gradient(135deg, #7E9A74, #5F7A86)', soundIds: ['forest', 'stream', 'cricket'], isPreset: true },
  { id: 'campfire-night', name: '篝火夜晚', category: 'relax', desc: '火光噼啪，虫鸣作伴的冬夜', iconName: 'fire', gradient: 'linear-gradient(135deg, #B97A48, #9C5F34)', soundIds: ['campfire', 'cricket'], isPreset: true },
  // 自然
  { id: 'forest-stream', name: '林间溪流', category: 'nature', desc: '泉水淌过青石，清亮又安定', iconName: 'stream', gradient: 'linear-gradient(135deg, #7F9AA6, #66818D)', soundIds: ['stream', 'forest'], isPreset: true },
  { id: 'morning-forest', name: '山野清晨', category: 'nature', desc: '鸟鸣与风拂过林梢的清晨', iconName: 'bird', gradient: 'linear-gradient(135deg, #7E9A74, #547E54)', soundIds: ['forest', 'birdsong'], isPreset: true },
]
