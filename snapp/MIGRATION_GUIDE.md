# snapp 页面迁移指南（uni-app 原型 → Flutter）

> 供并行迁移任务使用。权威参照：`prototype/src`（页面源码）；本文只描述 Flutter 侧已有基础设施的**精确 API**与硬性规则。

## 硬性规则（违反即返工）

1. **Dart 2.19.6**：无 record / pattern / sealed 语法；`super.key` 可用。
2. **禁止硬编码颜色**：所有颜色/阴影/圆角经 `Theme.of(context).appColors` / `appShapes`。原型里的 `var(--app-*)` 对照表见下。CSS 白字面（如叠在封面上的 `rgba(255,255,255,.22)`）用 `c.onCover.withOpacity(x)`。
3. **禁止 emoji 图标**：一律 `AppIcon(name: ..., size: ..., color: ...)`，name 必须是 `app_svg_icons.dart` 已注册名（wave/white-noise/pink-noise/brown-noise/red-noise/rain/wave-ocean/forest/stream/fire/coffee/train/fan/play/pause/timer/save/palette/trophy/settings/share/user/edit/mute/volume/close/chevron-right/chevron-left/gift/moon/flame/mixer/clock/copy/lock/check/mountain/bird/shuffle/heart/award/sun/contrast）。
4. **页面容器**：每页最外层用 `AppPage(child: ...)`（tab 页传 `bottomBarSpace: true`）。`AppPage` 已含顶部渐变、安全区、进入动效、水平 padding 20px。
5. **状态管理**：`provider`。全局播放状态注入 `PlayerService`（Root 已提供），页面内 `context.watch<PlayerService>()` 读、`context.read<PlayerService>()` 写。
6. **页面级本地状态**：StatefulWidget + setState，与原型 `ref()` 对齐。**不要**自建全局单例、不要改 services/ 下文件、不要改 app/ 下文件（路由由主代理统一接线）。
7. **toast**：`showAppToast(context, '文案')`（替代 `uni.showToast({icon:'none'})`）。
8. **导航**：命名路由 `Navigator.pushNamed(context, '/xxx')`；带参：`arguments: <String, dynamic>{'id': id}`，页内 `ModalRoute.of(context)!.settings.arguments`。返回上一页 `Navigator.maybePop(context)`。tab 切换不在页面内处理。
9. **不修改**：theme/、widgets/、services/、data/、app/ 下任何文件；只新增/修改自己负责的页面文件。若缺少图标/组件/token，在最终汇报里列出，不要自行绕过。

## 主题 API（`import '../theme/theme_extension.dart';`）

```dart
final c = Theme.of(context).appColors;
final s = Theme.of(context).appShapes;
```

| 原型 token | Flutter 字段 |
|---|---|
| `--app-bg` / `--app-bg-grad` | `c.bg` / `c.bgGrad` |
| `--app-surface` / `--app-surface-2` | `c.surface` / `c.surface2` |
| `--app-sunken` | `c.sunken` |
| `--app-text` / `-2` / `-3` | `c.text` / `c.text2` / `c.text3` |
| `--app-line` / `--app-line-strong` | `c.line` / `c.lineStrong` |
| `--app-primary` / `-strong` / `-soft` / `-soft-2` / `--app-on-primary` | `c.primary` / `c.primaryStrong` / `c.primarySoft` / `c.primarySoft2` / `c.onPrimary` |
| `--app-accent` / `--app-overlay` / `--app-press` | `c.accent` / `c.overlay` / `c.press` |
| `--app-danger` / `--app-danger-soft` / `--app-success` / `--app-warning` | `c.danger` / `c.dangerSoft` / `c.success` / `c.warning` |
| `--app-on-cover` / `--app-on-cover-soft` | `c.onCover` / `c.onCoverSoft` |
| `--app-shadow-1..4` | `c.shadow1..c.shadow4`（`List<BoxShadow>`） |
| `--app-inset`（玻璃顶高光） | `c.insetHl`（Color?） |
| `--app-blur` | `c.blur`（glass=20，其余 0） |
| 卡片圆角 44rpx | `s.cardRadius`（22） |
| 金银铜渐变 | `rankGoldColors` / `rankSilverColors` / `rankBronzeColors`（theme_tokens.dart） |

## 基础组件 API（`import '../widgets/xxx.dart';`）

```dart
AppCard(padding:, radius:, onTap:, color:, border:, child:)             // .app-card（含玻璃模糊/内高光）
AppPage(child:, bottomBarSpace:)                                        // 页面容器
AppSectionTitle('文案')                                                  // .section-title 小灰标题
AppDivider()                                                            // .divider
AppPrimaryButton(child:, onPressed:) / AppOutlineButton(...)            // .btn-primary / .btn-outline
AppIcon(name:, size:, color:)                                           // 定制 SVG 图标
PressableScale(onTap:, child:)                                          // :active scale(.96) 通用包装
NavBar(title:, back:, action:)                                          // 页头导航（返回钮+标题+右侧插槽）
EmptyState(icon:, title:, desc?, actionText?, onAction?)
Segmented(options:, value:, onChanged:)                                 // options: SegmentOption(key,label)
SceneCard(name:, soundCount:, soundIcons:, bgColor:, cover:, isPreset:, isGrid:, active:, soundLabel:, onTap:, onPlay:, onShare?)
SoundCard(name:, type:, iconName:, color:, isActive:, onTap:)
MixTrack(name:, iconName:, color:, volume:, isMuted:, onVolumeChange:, onMute:, onRemove:)
PlayBar(onSaveTap:)                                                     // 底部主控条（Shell 已挂，页面不要再放）
NowPlayingCard()                                                        // 首页大播放卡（含混音 Sheet）
BrandBar()                                                              // 首页品牌头
showAppToast(context, msg)
```

## 播放状态（`import '../services/player_service.dart';`）

```dart
final player = context.watch<PlayerService>();
player.currentScene            // Scene?（当前场景）
player.tracks                  // List<PlayerTrack>（id/name/iconName/color/volume(int)/muted）
player.isPlaying               // bool
player.timerMinutes / fadeMinutes
player.pendingSceneCategory    // 首页「更多」带入分类
player.applyScene(scene)       // 应用场景并开始播放（写最近记录）
player.togglePlay()            // false = 无音轨，需 toast「请先选择场景」
player.setTrackVolume(id, v) / toggleTrackMute(id) / removeTrack(id) / setTimer(min)
player.recent                  // List<RecentItem>（sceneId/name/iconName/gradient/ts）
PlayerService.recentTimeLabel(ts)  // '刚刚'/'n分钟前'/'昨晚'…
player.findSound(id)           // Sound?
```

## 数据层（`import '../data/seed_data.dart';` 等）

```dart
homeScenes                     // List<Scene>（id/name/category/desc/iconName/gradient/image/soundIds/isPreset）
sounds                         // List<Sound>（id/name/type/category/iconName/color/gradient/duration/sampleRate/quality/source/desc/scenes/loopLength）
sceneCategories                // List<SceneCategoryItem>(key,label)
soundCategories                // List<SoundCategoryItem>(key,label,icon)
featuredScenes                 // List<FeaturedScene>（id/name/desc/iconName/gradient/tags/soundIds/ratio/playCount/duration）
featuredSounds                 // List<FeaturedSound>（.sound + .hot）
simulatedPrefs                 // ['sleep','nature']
```

SceneService（`import '../services/scene_service.dart';`）：`findScene(id)` / `soundNames(ids)` / `getRecommended(prefs, recent, limit:4)` / `getCategoryScenes(category, limit)` / `buildRecipe(scene)` / `buildPresets(scene)`。

## 工具（`import '../utils/style_utils.dart';`）

```dart
rx(24)                       // rpx→px（除 2）
parseCssGradient(cssStr)     // → CssGradient?(colors/begin/end)；null 时回退主色
hexToColor('#8296A8')        // → Color?
colorMix(a, 16, b)           // color-mix 语义
gradientFirstColor(css, fallback)
```

场景封面图：`SceneCard` 已内置处理；页面若需直接展示封面图，用
`Image.asset('assets/scene/${id}.png', errorBuilder: …)`（原型 `/static/scene/xx.png`）。
品牌 logo：`assets/brand/logo.jpg`。

## 文件位置与注册

- 页面文件放 `lib/pages/<路由名>/<路由名>_page.dart`（如 `lib/pages/library/library_page.dart`，类名 `LibraryPage`）。
- **不要**改 `app/router.dart`；在最终回复中列出「路由名 → 类名 + 构造参数（若有）」，由主代理接线。
- 不要运行 `flutter analyze`/`pub get`/构建命令（主代理统一验证）。

## 页面迁移要领

- 以对应 `prototype/src/pages/<x>/<x>.vue` 为唯一参照：模板结构、文案、交互、分区顺序逐段对齐；`rpx` 一律 `rx()` 换算。
- uni-app `scroll-view scroll-x` → 水平 `SingleChildScrollView`/`ListView`（`ShowScrollbar` 关系不大）。
- `v-if` → 条件成员；`v-for` → `.map()`/`ListView.builder`。
- 原型 localStorage（`shengqi-*`）如页面有使用：经 `AppStorage`（`services/app_storage.dart`，getString/setString/readJsonList/writeJsonList），key 保持一致；页面加载时异步读取、变更即写。
- 布局基准：iPhone 逻辑宽 375；字号 = 原型 rpx/2。
