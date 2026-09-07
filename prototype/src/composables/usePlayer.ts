/**
 * 声栖 · 共享播放状态
 *
 * 模块级 reactive 单例，首页大播放卡 / 场景网格 / 底部 PlayBar 读写同一状态。
 */

import { reactive } from 'vue'
import type { Scene } from '@/data/scenes'
import { sounds } from '@/data/sounds'

export interface Track {
  id: string
  name: string
  iconName: string
  color: string
  volume: number
  muted: boolean
}

interface PlayerState {
  currentScene: Scene | null
  tracks: Track[]
  isPlaying: boolean
  timerMinutes: number
  fadeMinutes: number
  showTimerPanel: boolean
  showMixPanel: boolean
  pendingSceneCategory: string
}

export const player = reactive<PlayerState>({
  currentScene: null,
  tracks: [],
  isPlaying: false,
  timerMinutes: 0,
  fadeMinutes: 2,
  showTimerPanel: false,
  showMixPanel: false,
  pendingSceneCategory: 'all',
})

function findSound(id: string) {
  const s = sounds.find((item) => item.id === id)
  if (!s) throw new Error(`usePlayer: 未找到声音 ${id}`)
  return s
}

/** 应用场景：按 soundIds 重建音轨并开始播放 */
export function applyScene(scene: Scene) {
  player.currentScene = scene
  player.tracks = scene.soundIds.map((id) => {
    const s = findSound(id)
    return { id: s.id, name: s.name, iconName: s.iconName, color: s.color, volume: 50, muted: false }
  })
  player.isPlaying = true
  pushRecent(scene)
}

/** 播放/暂停；无音轨时返回 false，由调用方 toast 提示 */
export function togglePlay(): boolean {
  if (player.tracks.length === 0) return false
  player.isPlaying = !player.isPlaying
  return true
}

export function setTrackVolume(id: string, volume: number) {
  const t = player.tracks.find((x) => x.id === id)
  if (t) t.volume = volume
}

export function toggleTrackMute(id: string) {
  const t = player.tracks.find((x) => x.id === id)
  if (t) t.muted = !t.muted
}

export function removeTrack(id: string) {
  player.tracks = player.tracks.filter((t) => t.id !== id)
  if (player.tracks.length === 0) player.isPlaying = false
}

/** 定时：重复点击同一时长则取消 */
export function setTimer(minutes: number) {
  player.timerMinutes = player.timerMinutes === minutes ? 0 : minutes
}

/* ------------------------- 最近使用（本地存储） ------------------------- */

const RECENT_KEY = 'shengqi-recent'
const RECENT_MAX = 10

export interface RecentItem {
  sceneId: string
  name: string
  iconName: string
  gradient: string
  ts: number
}

export function getRecent(): RecentItem[] {
  try {
    const raw = uni.getStorageSync(RECENT_KEY) as unknown
    return Array.isArray(raw) ? (raw as RecentItem[]) : []
  } catch {
    return []
  }
}

function pushRecent(scene: Scene) {
  const list = getRecent().filter((i) => i.sceneId !== scene.id)
  list.unshift({ sceneId: scene.id, name: scene.name, iconName: scene.iconName, gradient: scene.gradient, ts: Date.now() })
  try {
    uni.setStorageSync(RECENT_KEY, list.slice(0, RECENT_MAX))
  } catch {}
}

/** 时间标签：刚刚 / n分钟前 / n小时前 / 昨晚 / n天前 */
export function recentTimeLabel(ts: number): string {
  const diff = Date.now() - ts
  const m = Math.floor(diff / 60000)
  if (m < 1) return '刚刚'
  if (m < 60) return `${m}分钟前`
  const h = Math.floor(m / 60)
  if (h < 8) return `${h}小时前`
  if (h < 24) return '昨晚'
  const d = Math.floor(h / 24)
  return `${d}天前`
}
