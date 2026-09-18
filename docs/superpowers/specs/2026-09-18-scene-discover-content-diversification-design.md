# 场景页 / 发现页内容差异化设计

> 日期：2026-09-18
> 范围：`prototype/`（uni-app 设计基线）与 `snapp/`（Flutter 主工程）同步实现

---

## 一、背景与问题

当前「场景页」与「发现页」各自包含一张「分类 tag + 精选场景」双列网格，两组浏览入口同时指向相似内容：

| 页面 | 现有精选场景逻辑 | 数据源 |
|---|---|---|
| 场景页卡片 B「精选场景」 | `getCategoryScenes(activeTag, 3)`，按分类取前 3 | `homeScenes` |
| 发现页卡片 B「场景推荐」 | 本地 `CATEGORY_MAP` 兜底分类 + `featuredScenes` 过滤 | `featuredScenes` |

两页标题、分类 tag（全部/助眠/专注/放松/自然）、双列卡片布局高度相似，仅排序与数据源不同，用户感知「两张同样的精选场景」，重复度偏高。

## 二、目标

保留两页的「精选场景」网格，但**浏览维度差异化**，弱化重复感：

- **场景页**＝个性化：按偏好分类精选（保持现状，与卡片 A 的「为你推荐 / 最近播放」联动），传达「为你选的」。
- **发现页**＝热度：分类过滤后按 `playCount` 降序，突出「大家都在听的热门」，传达「发现的」。

## 三、设计方案

### 3.1 数据层（`prototype/src/data/scenes.ts`）

1. **`parsePlayCount(pc: string): number`**：解析 `"12.6万" → 126000`、`"9.8千" → 9800`、`"5000" → 5000`；无法解析返回 0，用作排序依据。
2. **收敛分类映射**：新增 `featuredSceneCategory: Record<string, SceneCategory>`，将 `featuredScenes` 各 id 映射到 `sceneCategories` 的分类 key（`sleep/focus/relax/nature`）。替换 `discover.vue` 内现有 `CATEGORY_MAP`，保持「分类单一来源」约定。
3. **`getHotScenes(category: 'all' | SceneCategory): FeaturedScene[]`**：从 `featuredScenes` 按分类过滤（`all` 不过滤），按 `parsePlayCount(s.playCount)` 降序返回。

> `FeaturedScene` 现有 `playCount: string` 字段，无需改数据结构；不新增自定义分类，沿用 `sceneCategories` key。

### 3.2 发现页 `prototype/src/pages/discover/discover.vue`

- 卡片 B「场景推荐」改由 `getHotScenes(activeTag)` 驱动，替代本地 `filteredFeatured` + `CATEGORY_MAP`。
- 排序来源 = 热度（`playCount` 降序），保留分类 tag 过滤、「查看全部」入口、卡片播放/进详情交互。
- **网格展示须排除今日推荐 `hero`**（沿用现有 `s.id !== hero.id` 过滤），避免同场景既做大卡又进网格。
- `hero`（今日推荐）仍为 `featuredScenes[0]`，不受影响。

### 3.3 场景页 `prototype/src/pages/scene/scene.vue`

- 卡片 B「精选场景」逻辑保持 `getCategoryScenes(activeTag, 3)`（已个性化），不改排序。
- 仅复核标题/视觉与发现页可区分（描述性文案，不做结构改动）。

### 3.4 Flutter 同步（`snapp/`）

- 在 `snapp` 的数据/模型层补齐 `featuredScenes`、`parsePlayCount`、按热度排序的取数函数（对应 `getHotScenes`）。
- `discover_page.dart` 卡片场景推荐改按热度排序；`scene_page.dart` 保持个性化逻辑。
- 服务/模型命名与 uni-app 对齐，遵循 AGENT.md 第 5 章（Harmony 适配、无硬编码、theme 一致）。

### 3.5 验证

- `prototype/`：`pnpm type-check` 通过；`pnpm dev:h5` 目视两页精选内容排序差异。
- `snapp/`：`flutter analyze` 零错误、`flutter test` 全绿（含新增排序函数单元测试）。

## 四、边界（不做）

- 不新增/删除页面或关卡；不改 `homeScenes` 与 `featuredScenes` 数据本体（仅新增读取/排序函数）。
- 不调整页面布局、卡片组件或主题。
- 不引入未适配 Harmony 的三方库。

## 五、验收标准

1. 发现页「场景推荐」按 `playCount` 降序展示，热门在前；分类过滤仍生效。
2. 场景页「精选场景」维持分类/偏好精选，排序不变。
3. 两页分类 tag 口径一致（均来自 `sceneCategories`），无重复 `CATEGORY_MAP`。
4. prototype `type-check` 通过、snapp `analyze`/`test` 通过。