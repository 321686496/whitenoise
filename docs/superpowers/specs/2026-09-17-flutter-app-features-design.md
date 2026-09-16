# 声栖 Flutter 全功能实现 Design Spec

> 日期：2026-09-17
> 范围：`snapp/`（Flutter）整 App 具体功能补齐：共享持久化 + 数据真实化、播放链路补全、首启引导、真实音频引擎。
> 决策依据：用户确认「全部 + 数据真实化 + 本轮接入音频引擎 + 合成噪声族素材」。

## 1. 目标

Flutter 工程已 1:1 复刻原型（原型本身多为演示态）。本轮把系统性缺失补成可用功能：

- 收藏 / 打卡 / 成就 / 统计 / 自定义场景从「内存态 / 写死」改为**共享持久化**，跨页面互通。
- 修复最近播放冷启动丢失 bug。
- 补独立播放页（真倒计时到点停播）、PlayBar 锁交互、播放设置持久化。
- 首启引导（onboarding 首次展示）。
- 接入**真实音频引擎**：just_audio（Harmony 适配清单 3.7 ✓），合成噪声族 WAV 资产，平台不可用优雅回退模拟。

## 2. 架构

服务分层（用户已确认推荐方案）：

- `AudioEngine` 接口（播放实现可替换）→ `PlayerService` 持引擎继续做状态机。
- 领域服务独立：`FavoritesService` / `CheckinService` / `CustomSceneService` / `StatsService` / `AchievementService`，统一走 `AppStorage`。
- 存储 key 沿用 `shengqi-*` 命名规约。

## 3. 模块

### M1 共享持久化与数据真实化

| 服务 | 文件 | 存储 key | 行为 |
|---|---|---|---|
| 存储扩展 | `lib/services/app_storage.dart` | — | 新增 key 常量；维持 `readJsonList/writeJsonList/getString/setString` 优雅降级 |
| 收藏 | `lib/services/favorites_service.dart` | `shengqi-favorites` | 共享收藏态（sceneId 列表）；scene-detail / now_playing_card / favorites 页三处统一读写 |
| 打卡 | `lib/services/checkin_service.dart` | `shengqi-checkin` | 按日期落库（YYYY-MM-DD 列表）、连续天数真实计算、今日已签判定 |
| 自定义场景 | `lib/services/custom_scene_service.dart` | `shengqi-scenes` | scene-edit 保存落库；scene 页「我的场景」回流；成就「创建 5 场景」数据源 |
| 统计 | `lib/services/stats_service.dart` | `shengqi-stats` | 累计播放次数/时长；周播放量；Top 音轨；连续使用天数 |
| 成就 | `lib/services/achievement_service.dart` | 派生 | 基于真实数据 computed：首次播放、连续 7 天、创建 5 场景、切换全部主题、22-02 播放、邀请等；未达成锁定 |
| Bug 修复 | `lib/main.dart` + `lib/app/app.dart` | — | PlayerService 单例注入：main 创建一次 → Root 用 `.value` 提供；恢复最近播放到同一实例 |

写死页面真实化：`mine`（128 次/连续 5 天/3 收藏等）、`achievement`、`stats`、`favorites`、`checkin`、`history`（接 `shengqi-recent`）。

### M2 播放链路补全

- 独立播放页 `/player`：对照 `prototype/src/pages/player/player.vue` 迁移（大播放卡、混音面板、定时面板）。
- 定时器**真实倒计时**：`PlayerService` 增加剩余秒数与计时 tick；到点停播 + 解锁成就「初次入眠」。
- `PlayBar` 锁按钮：`isLocked` 切换 + toast（对照原型 PlayBar.vue）。
- 设置页「播放设置」持久化（`shengqi-play-settings`）：默认音量 / 淡入淡出时长 / 定时默认等，按原型 settings.vue 实项对齐。

### M3 首启引导

- key `shengqi-onboarded`；未看过首启先展示 onboarding，完成后标记并进入主界面。

### M4 音频引擎

- 依赖：`just_audio: 0.9.37`（Dart 2.19 兼容；Harmony 适配清单 3.7 ✓）。HAP 构建时按 AGENTS.md 5.2 切 OpenHarmony git 源（`fluttertpc_just_audio`），本机无 OH SDK，构建验证记录待后续。
- 素材：开发期脚本合成循环 WAV（44.1kHz 16bit mono，约 10s 循环）——白噪/粉噪/褐噪/雨/风/溪流等可合成噪声族，输出到 `assets/audio/`；`pubspec.yaml` 声明 assets。
- `AudioEngine` 接口：`loadTrack(id, asset)` / `play()` / `pause()` / `setVolume(id, v)` / `setMute(id, m)` / `dispose()`；每轨独立 `AudioPlayer`（loop + 音量 + 静音）。
- 实现 `JustAudioEngine`；平台插件缺失（MissingPluginException / 测试环境）→ 回退 `SimulatedAudioEngine`（维持现状状态模拟）。
- 无资产的音轨（篝火、咖啡厅等非合成类）播放时优雅回退（保持状态模拟 / 静音轨道），后续补素材即生效。

### M5 验证

- `flutter analyze` 零错误；`flutter test` 全绿（新增各 Service 单测 + 既有测试回归）。
- HAP 构建需 OH SDK，本机不具备 → 记录到 AGENTS.md 待办，不在本轮强制。

## 4. 约束

- 样式零硬编码，全部走主题扩展（沿用既有约定）。
- 图标沿用 `AppIcon`，禁止 emoji。
- 音频三方库引入前已查证适配清单（just_audio 3.7 ✓），记录在案。
- 未获用户许可不擅自扩大范围；超出本 spec 的改动需先确认。
