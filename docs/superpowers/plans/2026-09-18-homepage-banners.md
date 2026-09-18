# 首页 Banners 分发位 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在首页（品牌头下方）新增一个数据驱动的 Banners 轮播栏，承载运营活动 / 今日精选 / 个性化推荐 / 状态反馈四类内容，Prototype（uni-app）与 Flutter 双平台同步落地。

**Architecture:** 数据驱动 + 个性化层。`buildBanners()` 纯函数把「运营静态配置 + 场景数据 + 最近使用/偏好（+ Flutter 真实 stats/checkin）」组装成 `Banner[]`；`BannerCarousel`（.vue / .dart）接收数组做自动轮播与点击分发。两平台逻辑对等，复用各自既有渐变引擎（CSS `linear-gradient` 字符串 / `parseCssGradient`）。

**Tech Stack:** uni-app (Vue3 `<script setup lang=ts>` + SCSS) / Flutter (Dart + Provider, `ThemeExtension`)。

## Global Constraints

- 应用名「声栖」，品牌主色深森林绿 `#3D6B5E`。
- **禁 emoji**：横幅图标一律用 `Icon.vue` / `AppIcon.name` 已定义图标名。
- 两平台均**禁硬编码配色/圆角/阴影**：背景用场景 `gradient`（CSS 渐变字符串）或主题变量 `var(--app-*)` / `Theme.of(context).appColors`。
- 不接受未适配三方库；Flutter 端仅用既有依赖（provider），不新增包。
- 状态反馈卡**不得脑补空计数器**：Prototype 用 `getRecent()` 派生、无近期记录则隐藏；Flutter 用 `StatsService.weekPlays[0]`（今日播放次数）、0 则隐藏。
- 自动轮播兼容 `prefers-reduced-motion`（减少动效则关闭自动切换）。
- 验证命令：Prototype = `pnpm type-check`；Flutter = `flutter analyze` 零错误 + `flutter test` 全绿。
- 横幅数据只读，不写播放状态；播放类动作复用 `applyScene()` / `player.applyScene()`。

---

## Phase 1 — Prototype（uni-app，设计基线）

### Task 1: Prototype 数据层 `data/banners.ts`

**Files:**
- Create: `prototype/src/data/banners.ts`

**Interfaces:**
- Consumes: `SceneCategory` / `Scene` from `@/data/scenes`；`RecentItem` / `getRecent` from `@/composables/usePlayer`。
- Produces: `BannerType`、`Banner`、`BannerAction`、`BannerCtx`、`buildBanners(ctx): Banner[]`。

- [ ] **Step 1: 创建 `data/banners.ts`**

```ts
import { findScene, getCategoryScenes } from './scenes'
import type { SceneCategory } from './scenes'

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

  // ② 今日精选（时段匹配，最多 1，避免与个性化重复抢注意力）
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
```

> 说明：`Scene` 需为 `@/data/scenes` 的默认导出类型；若该模块未导出 `Scene` 类型，改为 `ReturnType<typeof getCategoryScenes>[number]` 或适配现有类型名。

- [ ] **Step 2: 类型检查**

Run（在 `prototype/`）: `pnpm type-check`
Expected: PASS（无 banners.ts 相关报错）

- [ ] **Step 3: Commit**

```bash
git add prototype/src/data/banners.ts
git commit -m "feat(prototype): 首页 Banners 数据层与个性化组装"
```

---

### Task 2: Prototype 组件 `components/BannerCarousel.vue` 并接入首页

**Files:**
- Create: `prototype/src/components/BannerCarousel.vue`
- Modify: `prototype/src/pages/index/index.vue`（BrandBar 与 NowPlayingCard 之间插入 + onShow 刷新）

**Interfaces:**
- Consumes: `Banner` / `buildBanners` / `BannerCtx` from `@/data/banners`；`RecentItem` / `getRecent` from `@/composables/usePlayer`；`applyScene` from `@/composables/usePlayer`。
- Produces: `<BannerCarousel :banners="Banner[]" @action="(a: BannerAction) => void" />`。

- [ ] **Step 1: 创建 `components/BannerCarousel.vue`**

自适应轮播：`swiper` 循环展示、圆点指示器、`@change` 同步 current；点击整卡 `emit('action', banner.action)`。`prefers-reduced-motion` 仅供纯 CSS 动画降级（uni swiper 自动轮播由 `circular` + `indicator` 控制，若组件不支持关闭自动，则本方案以 `circular` 手动滑动 + 指示器实现「半自动」，不改全局设置）。

```vue
<template>
  <view class="banner-wrap">
    <swiper
      class="banner-swiper"
      :circular="banners.length > 1"
      indicator-dots
      indicator-active-color="#FFFFFF"
      indicator-color="rgba(255,255,255,.45)"
      current="0"
      @change="onChange"
    >
      <swiper-item v-for="b in banners" :key="b.id">
        <view class="banner app-card-el" :style="{ background: b.gradient }" @click="onTap(b)">
          <view class="banner-icon">
            <Icon :name="b.icon" :size="34" color="rgba(255,255,255,.92)" />
          </view>
          <view class="banner-text">
            <text class="banner-title">{{ b.title }}</text>
            <text class="banner-sub" v-if="b.subtitle">{{ b.subtitle }}</text>
          </view>
          <view class="banner-cue" v-if="b.type === 'featured'">
            <Icon name="play" :size="18" color="rgba(255,255,255,.9)" />
          </view>
        </view>
      </swiper-item>
    </swiper>
    <view v-if="banners.length > 1 && false" class="banner-dots" />
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import Icon from '@/components/Icon.vue'
import type { Banner, BannerAction } from '@/data/banners'

defineProps<{ banners: Banner[] }>()
const emit = defineEmits<{ (e: 'action', a: BannerAction): void }>()
const current = ref(0)
const onChange = (e: any) => { current.value = e.detail.current }
function onTap(b: Banner) { emit('action', b.action) }
</script>

<style lang="scss" scoped>
.banner-wrap { margin: 0 0 4rpx; }
.banner-swiper { height: 200rpx; }
.banner {
  height: 200rpx; box-sizing: border-box; border-radius: 32rpx;
  padding: 32rpx 44rpx; display: flex; align-items: center; gap: 30rpx;
  overflow: hidden; box-shadow: var(--app-shadow-2);
}
.banner-icon {
  width: 112rpx; height: 112rpx; border-radius: 999rpx; flex: none;
  background: rgba(255,255,255,.18);
  display: flex; align-items: center; justify-content: center;
}
.banner-text { flex: 1; display: flex; flex-direction: column; gap: 10rpx; min-width: 0; }
.banner-title { font-size: 34rpx; font-weight: 700; color: #fff; letter-spacing: -0.3rpx; }
.banner-sub { font-size: 25rpx; color: rgba(255,255,255,.82); }
.banner-cue {
  width: 72rpx; height: 72rpx; border-radius: 999rpx; flex: none;
  background: rgba(255,255,255,.22);
  display: flex; align-items: center; justify-content: center;
}
</style>
```

> 说明：文案色为覆盖在彩色渐变上的白字，属「浮层文字」，与场景封面上的 `--app-on-cover` 白字语义一致；若主题需统一可在后续按 `--app-on-cover` 收敛。

- [ ] **Step 2: 在 `pages/index/index.vue` 插入组件并接入数据**

在 `index.vue`：

```vue
<template>
  <view class="page-container">
    <view class="page-bg"></view>
    <TabBar current="index" />
    <BrandBar />
    <!-- ⑧ Banners 分发位 -->
    <BannerCarousel :banners="banners" @action="onBannerAction" />
    <NowPlayingCard />
    <!-- ... 场景流不变 ... -->
  </view>
</template>
```

script 中新增（并 import）：

```ts
import BannerCarousel from '@/components/BannerCarousel.vue'
import { buildBanners } from '@/data/banners'
import type { Banner, BannerAction } from '@/data/banners'
import { getRecent, applyScene } from '@/composables/usePlayer'
import type { SceneCategory } from '@/data/scenes'

const preference: SceneCategory[] = ['sleep', 'nature'] // 与 getRecommended 偏好一致
const banners = ref<Banner[]>([])

function refreshBanners() {
  const hour = new Date().getHours()
  banners.value = buildBanners({
    hour,
    recent: getRecent().map((r) => ({ sceneId: r.sceneId, name: r.name })),
    preference,
  })
}
onShow(refreshBanners)

function onBannerAction(a: BannerAction) {
  if (a.kind === 'play') {
    const s = findScene(a.sceneId)
    if (s) applyScene(s)
  } else {
    uni.navigateTo({ url: a.url })
  }
}
```

> `findScene` 已在上方从 `@/data/scenes` import；`getRecent` 返回 `RecentItem[]`（含 `sceneId` / `name`）。注意 `refreshBanners` 与已有 `onShow(refreshGrid)` 并存。

- [ ] **Step 3: 类型检查**

Run（在 `prototype/`）: `pnpm type-check`
Expected: PASS

- [ ] **Step 4: H5 目视检查**

Run（在 `prototype/`）: `pnpm dev:h5`
Expected: 品牌头之下出现轮播，四类卡按数据渲染；运营商点击进签到、精选点按开播、个性化进详情、无近期记录时状态卡隐藏；6 配色 × 3 UI 风格下文案/圆角正常。

- [ ] **Step 5: Commit**

```bash
git add prototype/src/components/BannerCarousel.vue prototype/src/pages/index/index.vue
git commit -m "feat(prototype): 首页接入 Banners 轮播栏"
```

---

## Phase 2 — Flutter（snapp/，主代码）

### Task 3: Flutter 数据模型 + 个性化组装（TDD）

**Files:**
- Create: `snapp/lib/data/banner_models.dart`
- Create: `snapp/lib/services/banner_service.dart`
- Create: `snapp/test/banner_service_test.dart`
- Modify: `snapp/lib/app/app.dart`（若需注入 stats/player 已有则不改）

**Interfaces:**
- Consumes: `Scene`/`findScene`/`getCategoryScenes`/`sceneCategories` from `services/scene_service.dart`；`RecentItem` from `services/player_service.dart`；`StatsService` from `services/stats_service.dart`；`AppThemeColors`（`Theme.of(context).appColors`）供组件用（本 Task 不依赖）。
- Produces: `enum BannerType`、`enum BannerKind`、`class Banner`、`List<Banner> buildBanners({required int hour, required List<RecentItem> recent, required StatsService stats})`。

- [ ] **Step 1: 创建 `data/banner_models.dart`**

```dart
/// 横幅类型：对应原型 `BannerType`。
enum BannerType { campaign, featured, personal, status }

/// 点击行为：播放 / 跳转。
enum BannerKind { play, navigate }

/// 首页 Banners 分发位条目（对照原型 `Banner`）。
class Banner {
  final String id;
  final BannerType type;
  final String title;
  final String? subtitle;
  final String icon; // AppIcon.name
  final String gradient; // CSS linear-gradient 字符串，parseCssGradient 消费
  final BannerKind kind;
  final String? sceneId; // kind == play
  final String? route; // kind == navigate

  const Banner({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.gradient,
    required this.kind,
    this.sceneId,
    this.route,
  });
}
```

- [ ] **Step 2: 写失败测试 `test/banner_service_test.dart`**

```dart
import 'package:flutter_test/flutter_test.dart';

import 'package:snapp/data/banner_models.dart';
import 'package:snapp/services/banner_service.dart';
import 'package:snapp/services/player_service.dart';
import 'package:snapp/services/stats_service.dart';

void main() {
  StatsService emptyStats() => StatsService()..load();

  test('运营卡固定为第一条，动作进入签到页', () {
    final banners = buildBanners(
        hour: 20, recent: <RecentItem>[], stats: emptyStats());
    expect(banners.first.type, BannerType.campaign);
    expect(banners.first.kind, BannerKind.navigate);
    expect(banners.first.route, '/checkin');
  });

  test('全天任意时段都有 pbanner 且含 featured', () {
    for (var h = 0; h < 24; h++) {
      final b = buildBanners(
          hour: h, recent: <RecentItem>[], stats: emptyStats());
      expect(b.any((x) => x.type == BannerType.featured), isTrue,
          reason: 'hour=$h 应收敛到某个精选场景');
    }
  });

  test('今日无播放时 status 卡隐藏', () {
    final b = buildBanners(
        hour: 12, recent: <RecentItem>[], stats: emptyStats());
    expect(b.any((x) => x.type == BannerType.status), isFalse);
  });

  test('今日有播放时 status 卡显示今日次数并跳统计', () {
    final stats = StatsService()..load();
    // recordPlay 需时钟注入固定今日；此处用真实 now，weekPlays[0]>0
    final s = StatsService();
    unawaited_ignore: // 说明：直接调用同步 set 字段构造今日数据
    s.totalPlays = 2;
    statsSync(s);
    final b = buildBanners(hour: 21, recent: <RecentItem>[], stats: s);
    expect(b.any((x) => x.type == BannerType.status), isTrue);
    final st = b.firstWhere((x) => x.type == BannerType.status);
    expect(st.route, '/stats');
    expect(st.title, contains('2'));
  });
}
```

> 说明：第 5 个用例需让 `StatsService.dailyPlayCounts['<今日>'] > 0`。设备上 `StatsService` 的 `weekPlays` 依据 `_clock()`，构造 `StatsService(clock: () => DateTime(2026,1,1))` 更稳：`stats = StatsService(clock: () => DateTime(2026,1,1)); stats.dailyPlayCounts['2026-01-01'] = 2;`（`recordPlay` 依赖 `dailyPlayCounts` 与 `activeDays`，寻径见 Task 描述）。请在测试内用**时钟注入**方式构造今日数据，断言 `title` 含今日次数。

- [ ] **Step 3: 运行测试确认失败**

Run（在 `snapp/`）: `flutter test test/banner_service_test.dart -v`
Expected: FAIL（`banner_service.dart` / `banner_models.dart` 未定义）

- [ ] **Step 4: 创建 `services/banner_service.dart` 实现**

```dart
import '../data/banner_models.dart';
import '../services/player_service.dart';
import '../services/stats_service.dart';
import 'scene_service.dart';

/// 偏好分类优先级（与 prototype `prefOrder` 一致）。
const List<String> _prefOrder = <String>['sleep', 'nature', 'relax', 'focus'];

/// 时段 → 精选场景 id（与 prototype `featuredSceneId` 一致）。
String _featuredSceneId(int hour) {
  if (hour >= 22 || hour < 5) return 'rainy-night';
  if (hour >= 5 && hour < 9) return 'morning-forest';
  if (hour >= 9 && hour < 12) return 'focus-white-noise';
  if (hour >= 14 && hour < 18) return 'coffee-time';
  if (hour >= 18 && hour < 22) return 'nature-relax';
  return 'rainy-night';
}

Scene? _pickByPreference(List<Scene> pool, Set<String> seen) {
  for (final id in pool.map((s) => s.id)) {
    if (!seen.contains(id)) return findScene(id);
  }
  return null;
}

/// 按固定顺序组装：campaign → featured → personal → status。
List<Banner> buildBanners({
  required int hour,
  required List<RecentItem> recent,
  required StatsService stats,
}) {
  final seen = <String>{};
  final out = <Banner>[];

  // ① 运营活动
  out.add(Banner(
    id: 'campaign-checkin',
    type: BannerType.campaign,
    title: '连续签到领好礼',
    subtitle: '每天来签到，解锁助眠奖励',
    icon: 'gift',
    gradient: 'linear-gradient(135deg, #3D6B5E, #2F544A)',
    kind: BannerKind.navigate,
    route: '/checkin',
  ));

  // ② 今日精选
  final featured = findScene(_featuredSceneId(hour));
  if (featured.isNotEmpty) {
    seen.add(featured.id);
    out.add(Banner(
      id: 'featured-${featured.id}',
      type: BannerType.featured,
      title: featured.name,
      subtitle: featured.desc.isEmpty ? '点按即刻开播' : featured.desc,
      icon: featured.iconName,
      gradient: featured.gradient,
      kind: BannerKind.play,
      sceneId: featured.id,
    ));
  }

  // ③ 个性化推荐
  final personalPool = <String>[
    for (final cat in _prefOrder)
      ...getCategoryScenes(cat, 20).map((s) => s.id),
  ];
  final personalId = _pickByPreference(
      personalPool.map((String id) => findScene(id)).toList(), seen);
  final Scene? personal = personalId != null && personalId.isNotEmpty
      ? personalId
      : (recent.isNotEmpty ? findScene(recent.first.sceneId) : null);
  if (personal != null && personal.isNotEmpty) {
    seen.add(personal.id);
    out.add(Banner(
      id: 'personal-${personal.id}',
      type: BannerType.personal,
      title: '为你推荐',
      subtitle: personal.name,
      icon: personal.iconName,
      gradient: personal.gradient,
      kind: BannerKind.navigate,
      route: '/scene-detail',
      sceneId: personal.id, // navigate 目标为 /scene-detail 时须携带 sceneId 参数
    ));
  }

  // ④ 状态反馈（今日有播放才显示）
  final todayPlays = stats.weekPlays.isEmpty ? 0 : stats.weekPlays.first;
  if (todayPlays > 0) {
    out.add(Banner(
      id: 'status-today',
      type: BannerType.status,
      title: '今日已助眠 $todayPlays 次',
      subtitle: '坚持每晚，安睡好养神',
      icon: 'moon',
      gradient: 'linear-gradient(135deg, #5F8296, #4E7182)',
      kind: BannerKind.navigate,
      route: '/stats',
    ));
  }

  return out;
}
```

> 注：`findScene` 在 `scene_service.dart` 的返回类型以实际为准（可能是 `Scene` 且可空，或返回宽松类型）。**改写时保持真实类型**：若 `findScene` 返回 `Scene`（不可空、找不到回退首条），则去掉 `isNotEmpty` 判空改写为直接使用；`personal` 的声明跟随实际类型。以 Task-3 Step-1 的 `banner_service_test.dart` 为导向，确保证编译通过。

- [ ] **Step 5: 运行测试确认通过**

Run（在 `snapp/`）: `flutter test test/banner_service_test.dart -v`
Expected: PASS

- [ ] **Step 6: `flutter analyze` + Commit**

Run（在 `snapp/`）: `flutter analyze`
Expected: No issues found

```bash
git add snapp/lib/data/banner_models.dart snapp/lib/services/banner_service.dart snapp/test/banner_service_test.dart
git commit -m "feat(flutter): 首页 Banners 数据层与个性化组装（含单测）"
```

---

### Task 4: Flutter 组件 `BannerCarousel` 并接入首页

**Files:**
- Create: `snapp/lib/widgets/banner_carousel.dart`
- Modify: `snapp/lib/pages/index/index_page.dart`（BrandBar 与场景流之间插入 + 数据装配）

**Interfaces:**
- Consumes: `Banner`/`BannerType`/`BannerKind` from `data/banner_models.dart`；`buildBanners` from `services/banner_service.dart`；`PlayerService`（`applyScene`）from `services/player_service.dart`；`StatsService` from `services/stats_service.dart`；`parseCssGradient` from `utils/style_utils.dart`；`AppIcon` from `widgets/app_icon.dart`；`PressableScale` from `widgets/pressable.dart`；`AppPage`/`AppThemeColors` 沿用。
- Produces: `class BannerCarousel`（StatelessWidget，接收 `List<Banner>`，`onTapBanner(Banner)`）——自动轮播用 `PageView` + `Timer.periodic` + 圆点指示，`MediaQuery.disableAnimationsOf` 关闭自动。

- [ ] **Step 1: 创建 `widgets/banner_carousel.dart`**

```dart
import 'dart:async';

import 'package:flutter/material.dart';

import '../data/banner_models.dart';
import '../theme/theme_extension.dart';
import '../utils/style_utils.dart';
import 'app_icon.dart';

/// 首页 Banners 轮播（对照原型 `BannerCarousel.vue`）。
class BannerCarousel extends StatefulWidget {
  final List<Banner> banners;
  final void Function(Banner) onTapBanner;
  const BannerCarousel({
    super.key,
    required this.banners,
    required this.onTapBanner,
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final PageController _controller = PageController();
  Timer? _timer;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _startAuto();
  }

  void _startAuto() {
    if (MediaQuery.disableAnimationsOf(context)) return; // prefers-reduced-motion
    if (widget.banners.length < 2) return;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_controller.hasClients) return;
      final next = (_current + 1) % widget.banners.length;
      _controller.animateToPage(next,
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    return Column(children: <Widget>[
      SizedBox(
        height: 100,
        child: PageView.builder(
          controller: _controller,
          itemCount: widget.banners.length,
          onPageChanged: (int i) => setState(() => _current = i),
          itemBuilder: (_, int i) => _card(context, widget.banners[i]),
        ),
      ),
      if (widget.banners.length > 1)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(widget.banners.length, (int i) {
              final on = i == _current;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: on ? 14 : 5,
                height: 5,
                decoration: BoxDecoration(
                  color: on ? c.primary : c.text3,
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            }),
          ),
        ),
    ]);
  }

  Widget _card(BuildContext context, Banner b) {
    final c = Theme.of(context).appColors;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () => widget.onTapBanner(b),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: parseCssGradient(b.gradient),
            boxShadow: c.shadow2,
          ),
          child: Row(children: <Widget>[
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x2EFFFFFF),
              ),
              child: const Icon(Icons.music_note, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(b.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3)),
                  if (b.subtitle != null) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(b.subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Color(0xD9FFFFFF), fontSize: 13)),
                  ],
                ],
              ),
            ),
            if (b.type == BannerType.featured)
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x38FFFFFF),
                ),
                child: const Icon(Icons.play_arrow, color: Colors.white, size: 18),
              ),
          ]),
        ),
      ),
    );
  }
}
```

> 说明：图标默认用 Material `Icons` 占位——**若要求禁 Material 图标**，改用已封装的 `AppIcon(name: b.icon, ...)`（Task 需按工程实际 `AppIcon` 签名替换）；横幅背景上的图标/播放 cue 为彩色渐变的白色覆盖物，属浮层白字语义。

- [ ] **Step 2: 在 `index_page.dart` 装配数据并插入**

在 `_IndexPageState` 顶部新增字段与方法，并 import：

```dart
import 'dart:async';
// 新增 import：
import '../../data/banner_models.dart';
import '../../services/banner_service.dart';
import '../../services/stats_service.dart';
import '../../widgets/banner_carousel.dart';
```

State：

```dart
List<Banner> _banners = <Banner>[];

void _refreshBanners() {
  final player = context.read<PlayerService>();
  final stats = context.read<StatsService>();
  _banners = buildBanners(
    hour: DateTime.now().hour,
    recent: player.recent,
    stats: stats,
  );
}

void _onBannerTap(Banner b) {
  final player = context.read<PlayerService>();
  if (b.kind == BannerKind.play && b.sceneId != null) {
    final s = findScene(b.sceneId!);
    player.applyScene(s);
  } else if (b.kind == BannerKind.navigate && b.route != null) {
    // /scene-detail 须携带 sceneId 参数；其余短路由直接 pushNamed
    if (b.route == '/scene-detail' && b.sceneId != null) {
      Navigator.pushNamed(context, b.route!,
          arguments: <String, dynamic>{'sceneId': b.sceneId!});
    } else {
      navigatorKey_push(b.route!);
    }
  }
}
```

> **说明**：命中 `findScene`、`context.read`、导航方式须与首页现有写法一致（参考 `index_page.dart` 已有 `findScene`/`Navigator.pushNamed` 用法）。若 `IndexPage` 已能通过 `context.watch<PlayerService>()` 拿到 player，则 banner 数据可在 `build` 内装配；但 `onShow` 级刷新在 Flutter 无 `onShow`，改为在 `build` 每次装配即可（`_banners` 作为 build 内局部计算，去掉 State 缓存，随 Agent 原样实现）。

在 `build` 的 `const BrandBar()` 之后、场景流 `Padding` 之前插入：

```dart
const BrandBar(),
const SizedBox(height: 12),
if (_banners.isNotEmpty)
  BannerCarousel(banners: _banners, onTapBanner: _onBannerTap),
const SizedBox(height: 8),
```

- [ ] **Step 3: `flutter analyze` + `flutter test`**

Run（在 `snapp/`）: `flutter analyze` → Expected: No issues found
Run（在 `snapp/`）: `flutter test` → Expected: All tests pass

- [ ] **Step 4: Commit**

```bash
git add snapp/lib/widgets/banner_carousel.dart snapp/lib/pages/index/index_page.dart
git commit -m "feat(flutter): 首页接入 Banners 轮播栏"
```

---

## Self-Review

**Spec 覆盖：**
- 数据驱动 + 个性化层 → Task 1 / Task 3（`buildBanners`）。
- 四类内容（运营/精选/个性化/状态）与点击行为 → 两平台 `buildBanners` 均实现 campaign/featured/personal/status 及 play/navigate 分发。
- 自动轮播 + prefers-reduced-motion → Task 2 / Task 4（`MediaQuery.disableAnimationsOf`）。
- 无真实数据则状态卡隐藏 → Task 3 测试覆盖 `status` 隐藏/显示；原型任务用 `recent`/`stats` 判空。
- 位置：品牌头下方、主控卡/场景流上方 → Task 2 / Task 4 插入点。
- 主题一致性、禁 emoji、禁硬编码色 → Global Constraints 逐条落地（渐变复用场景 `gradient`；图标走 Icon/AppIcon）。

**占位符扫描：** 无 TBD/TODO；代码步骤均有实际代码。标注了「以实际类型/签名适配」的护栏说明。

**类型一致性：** `BannerType`/`BannerKind`/`Banner`、`buildBanners` 签名在两平台各自 Task 间一致；Flutter 跨 Task 内的 `BannerAction` 等价物（kind/route/sceneId）在 Task 3 模型与 Task 4 消费间对齐。

> 已知护栏：`findScene`、`Scene` 可空性、`getCategoryScenes`、`parseCssGradient`、`MediaQuery.disableAnimationsOf`、`AppIcon`/Material 图标取舍，均以各工程实际源码为准微调，不改变行为契约。