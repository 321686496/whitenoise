/**
 * 声栖 · 首页 Banners 数据层
 *
 * 类型定义 + 运营静态配置 + buildBanners(ctx) 个性化组装。
 * 仅数据层，UI 由组件层接入（Task Banner-2）。
 */

import { findScene, getCategoryScenes } from './scenes'
import type { Scene, SceneCategory } from './scenes'

export type BannerType = 'campaign' | 'featured' | 'personal' | 'status'

export type BannerAction =
  | { kind: 'play'; sceneId: string }
  | { kind: 'navigate'; url: string }

export interface Banner {
  id: string
  type: BannerType
  title: string
  subtitle?: string
  icon: string
  gradient: string // CSS linear-gradient 字符串，与场景 gradient 同构
  action: BannerAction
}

export interface BannerRecentItem {
  sceneId: string
  name: string
}

export interface BannerCtx {
  hour: number
  recent: BannerRecentItem[]
  preference: SceneCategory[]
}

const prefOrder: SceneCategory[] = ['sleep', 'nature', 'relax', 'focus']

function pickByPreference(ctx: BannerCtx, seenIds: Set<string>): Scene | null {
  for (const cat of prefOrder) {
    if (!ctx.preference.includes(cat)) continue
    const pool = getCategoryScenes(cat, 20).filter((s) => !seenIds.has(s.id))
    if (pool.length > 0) return pool[0]
  }
  return null
}

/** 时段 → 精选场景 id（与「开启助眠」人设一致）。 */
function featuredSceneId(hour: number): string {
  if (hour >= 22 || hour < 5) return 'rainy-night'
  if (hour >= 5 && hour < 9) return 'morning-forest'
  if (hour >= 9 && hour < 12) return 'focus-white-noise'
  if (hour >= 14 && hour < 18) return 'coffee-time'
  if (hour >= 18 && hour < 22) return 'nature-relax'
  return 'rainy-night'
}

/** 按固定顺序组装横幅：campaign → featured → personal → status。 */
export function buildBanners(ctx: BannerCtx): Banner[] {
  const seen = new Set<string>()
  const out: Banner[] = []

  // ① 运营活动（固定 1）：签到有礼
  out.push({
    id: 'campaign-checkin',
    type: 'campaign',
    title: '连续签到领好礼',
    subtitle: '每天来签到，解锁助眠奖励',
    icon: 'gift',
    gradient: 'linear-gradient(135deg, #3D6B5E, #2F544A)',
    action: { kind: 'navigate', url: '/pages/checkin/checkin' },
  })
  seen.add('campaign-*')

  // ② 今日精选（时段匹配，最多 1）
  const featured = findScene(featuredSceneId(ctx.hour))
  if (featured) {
    seen.add(featured.id)
    out.push({
      id: 'featured-' + featured.id,
      type: 'featured',
      title: featured.name,
      subtitle: displayedDesc(featured),
      icon: featured.iconName,
      gradient: featured.gradient,
      action: { kind: 'play', sceneId: featured.id },
    })
  }

  // ③ 个性化推荐（偏好分类且近期未听，回退最近使用）
  const personalScene =
    pickByPreference(ctx, seen) ??
    (ctx.recent.length > 0 ? findScene(ctx.recent[0].sceneId) : null)
  if (personalScene) {
    seen.add(personalScene.id)
    out.push({
      id: 'personal-' + personalScene.id,
      type: 'personal',
      title: '为你推荐',
      subtitle: personalScene.name,
      icon: personalScene.iconName,
      gradient: personalScene.gradient,
      action: { kind: 'navigate', url: `/pages/scene-detail/scene-detail?sceneId=${personalScene.id}` },
    })
  }

  // ④ 状态反馈（无近期记录则整张隐藏）
  const last = ctx.recent[0]
  if (last) {
    out.push({
      id: 'status-recent',
      type: 'status',
      title: '最近在听',
      subtitle: last.name,
      icon: 'moon',
      gradient: 'linear-gradient(135deg, #5F8296, #4E7182)',
      action: { kind: 'navigate', url: '/pages/achievement/achievement' },
    })
  }

  return out
}

function displayedDesc(s: Scene): string {
  return s.desc.length > 0 ? s.desc : '点按即刻开播'
}