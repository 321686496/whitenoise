# Flutter 主工程性能优化：消除整树重建与 SVG 重复解析

## Context（为什么改）

用户反馈 App「整体很卡顿」。经追踪根因（非路由问题，路由 `MaterialPageRoute` + `onGenerateRoute` 为标准实现）：

1. **全局播放器广播 → 整页重建（主要卡顿源）**
   `PlayerService`（ChangeNotifier）任何状态变化都 `notifyListeners()`：切换曲目、音量、静音、以及**睡眠定时每秒倒计时**（`startCountdown` 中 `Timer.periodic` 每秒 decrement `remainingSeconds` 并 notify）。
   多页用 `context.watch<PlayerService>()`（26 处），任意一次通知即整页重建。开启睡眠定时后 = **整个 app 每秒重建所有常驻页面**（首页 / 场景 / 场景全部 / 我的 / 发现 / 详情 / 播放 / PlayBar）。
   经逐点核对，绝大多数 watch 站点**并未展示 `remainingSeconds`/被通知字段**，属误订阅。

2. **每个 `AppIcon` 每次都重新解析 SVG**
   `app_icon.dart` 用 `SvgPicture.string` 现拼 SVG 字符串再解析。页面一重建，页面内所有图标（首页场景网格就有几十个）全部重新做字符串拼接 + SVG 解析，放大重建开销。

3. 路由本身不是原因（已排除）。

## 目标

- 按下「系统性修复」：把消费点从 `watch` 精确改为 `context.select`（只订阅实际展示字段），使播放器任意通知不再整树重建。
- `AppIcon`/`AppRawIcon` 按签名缓存 SVG，消除跨重建重复解析。
- 睡眠定时每秒 tick 经上述改造后只驱动真正展示剩余秒的局部，无需另做独立 notifier。

## 改动清单

### A. 服务层配套改动（select 生效的前提）

`lib/services/player_service.dart`
- `setTrackVolume`（L178）与 `toggleTrackMute`（L189）原地修改 `PlayerTrack` 对象（`t.volume=` / `t.muted=`），**不替换 `tracks` 列表实例**；`context.select((p)=>p.tracks)` 按引用比较不会触发重建。需在两方法 `notifyListeners()` 前插入 `tracks = List.of(tracks);`（新建列表、复用同一批 track 对象），使界面读到更新后的值。
- `removeTrack` / `applyScene` 本就新建列表，无需改。

### B. 各消费点 `watch` → `context.select`（原子性能关键）

沿用 `context.select`（`package:provider/provider.dart`，与 `watch` 同一包）。

| 文件 | 站点 | 建议 select |
|---|---|---|
| pages/index/index_page.dart L98 | `String? id = ctx.select((p)=>p.currentScene?.id)` + `List<RecentItem> rec = ctx.select((p)=>p.recent)`；写操作改 `context.read` |
| pages/scene/scene_page.dart L134 | 同上两条 select（recent、currentScene?.id） |
| pages/scene-all/scene_all_page.dart L68 | `String? id = ctx.select((p)=>p.currentScene?.id)` |
| pages/mine/mine_page.dart L48 | `List<RecentItem> rec = ctx.select((p)=>p.recent)` |
| pages/discover/discover_page.dart L137 | `String? id = ctx.select((p)=>p.currentScene?.id)` |
| pages/history/history_page.dart L138 | `List<RecentItem> rec = ctx.select((p)=>p.recent)`（clearRecent 写操作用 `context.read`） |
| pages/scene-detail/scene_detail_page.dart L45 | 三条：`String?` currentScene?.id、`bool isPlaying`、`int timerMinutes` |
| pages/scene-detail/scene_detail_page.dart L797 `_TimerSheet` | `int t = ctx.select((p)=>p.timerMinutes)` |
| pages/scene-detail/scene_detail_page.dart L850 `_MixSheet` | `List<PlayerTrack> t = ctx.select((p)=>p.tracks)`（依赖改动 A） |
| widgets/play_bar.dart L42 顶层 | 弃 watch，改 `bool show = ctx.select((p)=>p.showTimerPanel)`；避免 `_PlayBarInner` 连坐 |

播放页 `player_page.dart` 为复杂页，建议按区块下沉独立 select：
- 页壳：`ctx.select((p)=>p.currentScene != null)` + `ctx.select((p)=>p.showTimerPanel)`
- 封面：`(p)=>p.currentScene` + `(p)=>p.isPlaying`
- 控制排：`(p)=>p.currentScene?.id`、`(p)=>p.isPlaying`、`(p)=>p.isLocked`、`(p)=>p.timerMinutes`
- 定时面板：`(p)=>p.timerMinutes` + `(p)=>p.showTimerPanel`
- 混音区：`(p)=>p.tracks`（依赖改动 A）
- `_ProgressSection`（L403-557）已是 const + 自持内部 Timer，无需改
- PlayBar 定时浮层内真正展示剩余秒的标签才 `select((p)=>p.remainingSeconds)`

各文件内存在 `context.read<PlayerService>()` 的写操作保留不变。

### C. AppIcon SVG 缓存

`lib/widgets/app_icon.dart`
- `AppIcon` / `AppRawIcon` 增加模块级签名缓存：`Map<String, SvgPicture> _cache`，键为 `'$name|$colorHex|$stroke|$size'`。命中直接复用 `SvgPicture`，未命中时拼 SVG 并 `SvgPicture.string` 后入缓存。
- 注意 `SvgPicture` 的 `width/height` 由缓存实例决定，故签名须包含 `size`；`SvgPicture` 无状态可安全跨 build 复用。
- 颜色随主题变化但变体有限（每页若干色），缓存体积受图标数×颜色数约束，可接受。

### 不做的事
- 不引入独立「轻量倒计时 notifier」：改动 A 已使每秒 tick 只重建展示剩余秒的局部，追加属过度设计。
- 不改动路由实现（已确认非卡顿源）。
- 不做与本次卡顿无关的 UI/行为调整。

## 涉及关键文件
- lib/services/player_service.dart
- lib/widgets/play_bar.dart
- lib/widgets/app_icon.dart
- lib/pages/player/player_page.dart
- lib/pages/scene-detail/scene_detail_page.dart
- lib/pages/index/index_page.dart
- lib/pages/scene/scene_page.dart
- lib/pages/scene-all/scene_all_page.dart
- lib/pages/mine/mine_page.dart
- lib/pages/discover/discover_page.dart
- lib/pages/history/history_page.dart

## 验证
1. `cd snapp && flutter analyze` → 零错误（重点确认所有 select 签名类型正确、无未用变量）。
2. `cd snapp && flutter test` → 现有 62 项全绿（含 AppIcon 回归 guard 与主题相关测试；若 AppIcon 缓存引入状态相关测试，补齐）。
3. 目视抽验（如可运行）：播放后睡眠定时 90s，确认只有 PlayBar/播放页剩余秒标签每秒变化，页面主体、首页场景网格、Tab 不跟随重建；调整音量时仅混音区刷新。