# 声栖 Flutter 全功能实现 Implementation Plan

> 配套 spec：`docs/superpowers/specs/2026-09-17-flutter-app-features-design.md`
> 执行方式：inline / subagent 分批，任务间 `flutter analyze` + 相关 `flutter test` 验证。
> 全局约束：Dart 2.19.6（无 records / switch 表达式 / Color.r API）；样式零硬编码走主题扩展；图标走 AppIcon；改前先读目标文件。

## T1 存储扩展 + 收藏共享

- **Files**：`lib/services/app_storage.dart`、新建 `lib/services/favorites_service.dart`、`test/favorites_service_test.dart`
- **改** `app_storage.dart`：新增 key 常量 `keyFavorites='shengqi-favorites'`、`keyCheckin='shengqi-checkin'`、`keyScenes='shengqi-scenes'`、`keyStats='shengqi-stats'`、`keyPlaySettings='shengqi-play-settings'`、`keyOnboarded='shengqi-onboarded'`。
- **新建** `FavoritesService extends ChangeNotifier`：`List<String> ids`；`bool isFav(String id)`；`Future<void> load()`；`toggle(String id)`（写回 `keyFavorites`）。优雅降级同 AppStorage。
- **接入**：`lib/pages/scene-detail/scene_detail_page.dart`（收藏按钮改走服务）、`lib/widgets/now_playing_card.dart`（`_FavAction` 改走服务）、`lib/pages/favorites/favorites_page.dart`（列表读服务 + 取消收藏写回 + 空态）。三处通过 Provider 全局注入（`app/app.dart`）。
- **测试**：toggle/isFav 持久化往返。
- **验证**：`flutter test test/favorites_service_test.dart` + `flutter analyze`。

## T2 打卡真实化

- **Files**：新建 `lib/services/checkin_service.dart`、改 `lib/pages/checkin/checkin_page.dart`、`test/checkin_service_test.dart`
- `CheckinService extends ChangeNotifier`：`Set<String> dates`（YYYY-MM-DD）；`bool checkedToday`；`int streak`（连续天数，含今天为基准向前数）；`Future<void> checkIn()`（今日已签则幂等）。持久化 `keyCheckin`。
- checkin 页：状态改走服务；签到按钮真实写；连续天数展示 `streak`。
- **验证**：单测 + analyze。

## T3 自定义场景持久化

- **Files**：新建 `lib/services/custom_scene_service.dart`、改 `lib/pages/scene-edit/scene_edit_page.dart`、`lib/pages/scene/scene_page.dart`、`test/custom_scene_service_test.dart`
- `CustomSceneService extends ChangeNotifier`：`List<Scene> scenes`；`Future<void> add(Scene)` / `delete(String id)`；持久化 `keyScenes`。Scene 复用现有 model（isPreset:false）。
- scene-edit：保存不再仅 toast——写入服务，返回 scene 页并 toast「已保存」；编辑态加载对应自定义场景。
- scene 页「我的场景」：读服务列表渲染，空则隐藏/空态。
- **验证**：单测 + analyze。

## T4 统计与成就真实化

- **Files**：新建 `lib/services/stats_service.dart`、`lib/services/achievement_service.dart`、`test/stats_service_test.dart`、`test/achievement_service_test.dart`；改 `lib/pages/mine/mine_page.dart`、`lib/pages/achievement/achievement_page.dart`、`lib/pages/stats/stats_page.dart`、`lib/pages/history/history_page.dart`
- `StatsService extends ChangeNotifier`：`int totalPlays`；`Map<String,int> playCountsByScene`；`List<int> weekPlays`（近 7 日）；`recordPlay(Scene)` 由 PlayerService.applyScene 调用；持久化 `keyStats`。连续使用天数与 CheckinService 对齐（或读打卡）。
- `AchievementService extends ChangeNotifier`：8 项成就（对照原型 achievement.vue），`unlocked` 由真实数据 computed：首次播放（stats）、连续 7 天（checkin）、创建 5 场景（customScenes）、切换全部主题（themeNotifier 记录历史）、22-02 播放（recordPlay 带时间戳）、邀请（原型无真实分享→保持锁定）、6 轨混音、定时完成（player）。解锁项持久化。
- mine 页数字：播放次数/连续天数/收藏数/成就数读服务；achievement 页读服务；stats 页周报读服务；history 页接 `shengqi-recent`（读 PlayerService.recent）+ 清空写回 + 重播调 applyScene。
- **验证**：单测 + analyze。

## T5 最近播放恢复 bug

- **Files**：`lib/main.dart`、`lib/app/app.dart`
- main 创建 `PlayerService` 一次 → `await player.loadRecent()` → `Root(player: player)`；app.dart 用 `ChangeNotifierProvider<PlayerService>.value(value: player)`。删去原 Provider create。

## T6 播放链路补全

- **Files**：新建 `lib/pages/player/player_page.dart`、改 `lib/app/router.dart`（`/player`）、`lib/services/player_service.dart`、`lib/widgets/play_bar.dart`、`lib/pages/settings/settings_page.dart`、`lib/widgets/now_playing_card.dart`（入口进播放页）、`test/player_service_test.dart`
- PlayerService：新增 `int remainingSeconds` + `Timer` tick（每 1s）；`startCountdown(minutes)` / `stopCountdown()`；到点 `isPlaying=false` + 停引擎 + 解锁「初次入眠」；fadeMinutes 应用于淡出（模拟阶段先置状态）。
- player_page：对照 `prototype/src/pages/player/player.vue` 迁移（Hero 封面、音轨混音、定时面板、大播放/暂停）。
- play_bar：锁按钮 `isLocked` 切换 + toast「已锁定播放/已解锁」（对照原型 PlayBar.vue）。
- settings 播放设置：默认音量/淡入淡出持久化 `keyPlaySettings`。
- **验证**：单测（countdown 到点停播）+ analyze。

## T7 首启引导

- **Files**：改 `lib/main.dart` 或 `lib/app/app.dart`（启动判定）、`lib/pages/onboarding/onboarding_page.dart`（完成回调标记 `keyOnboarded`）
- 未读 `keyOnboarded` → home 先 push `/onboarding`（不可返回），完成后写标记。

## T8 音频引擎

- **Files**：`pubspec.yaml`（加 `just_audio: 0.9.37`）、新建 `tool/gen_audio.dart`（WAV 合成脚本）、`assets/audio/*.wav`（生成物）、新建 `lib/services/audio_engine.dart`（接口 + SimulatedAudioEngine + JustAudioEngine）、改 `lib/services/player_service.dart`（注入引擎、音轨资产映射）、`lib/data/seed_data.dart`（Sound 增 `asset` 字段或映射表）、`test/audio_engine_test.dart`
- 资产：gen_audio.dart 合成白/粉/褐噪、雨、风、溪流等 → `assets/audio/<soundId>.wav`（44.1kHz 16bit mono，约 10s 循环）；`pubspec.yaml` 声明 `assets/audio/`。
- AudioEngine 接口：`Future<void> loadTrack(String id, String? asset)`、`Future<void> play()`、`Future<void> pause()`、`Future<void> setVolume(String id, double v)`、`Future<void> setMute(String id, bool m)`、`Future<void> disposeAll()`。
- `JustAudioEngine`：每轨独立 `AudioPlayer`，`LoopMode.one`，`setAsset`/`setVolume`；创建/加载抛 MissingPluginException → 整体降级 SimulatedAudioEngine（测试环境天然走此路）。
- PlayerService：applyScene 时 `engine.loadTrack`（无 asset 的音轨跳过引擎，保持模拟）；togglePlay/音量/静音/移除同步引擎；dispose 释放。
- **验证**：`dart run tool/gen_audio.dart` 生成资产；`flutter test`（引擎回退路径）；analyze。

## T9 收尾验证 + 文档同步

- **Files**：`AGENTS.md`（文档索引加 2 篇：本 spec + plan；更新待办：HAP 构建需 OH SDK）、如有必要 `docs/code-wiki/whitenoise-code-wiki.md`
- `flutter analyze` 零错误；`flutter test` 全绿。
- 逐项自查 AGENTS.md 5.6 清单；记录 Harmony 构建验证为后续待办。
