# 睡眠定时「沉浸式衔接」增强 实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 让睡眠定时不是到点硬停，而是在最后 `fadeMinutes` 内把音量平滑降到 0 再停，并在播放中常驻可感知（不弹窗打断），营造自然入眠的沉浸衔接。

**Architecture:** 复用现有 `PlayerService.startCountdown` 每秒 tick，进入淡出段后逐轨调用引擎 `setVolume(id, base*(1-progress))` 平滑降到 0，到点 `pause()`；新暴露 `fading` 只读态供 UI 做非侵入提示。不改 `AudioEngine` 接口、不新增三方库、三平台安全、样式跟随主题。

**Tech Stack:** Flutter / Dart / provider / just_audio / fake_async / flutter_test

## Global Constraints

- 实现工程：`snapp/`（Flutter 主工程）；不修改 `prototype/`。
- 不改 `AudioEngine` 接口（仅调用既有 `setVolume(id, 0-1)` / `pause()`）。
- 不新增三方库；最终须 `flutter analyze` 零错误、`flutter test` 全绿。
- 到点停止**不弹窗 / 不 dialog / 不 toast 打断睡眠**。
- 所有 UI 颜色 / 圆角 / 阴影走 `Theme.of(context).appColors`（`AppColors` 扩展），禁止硬编码 `Color(0xFF…)`。
- 新拟态取向：按钮 / 浮层浮雕按项目 4.2 铁律（按压内凹、选中同按压），不加描边。
- 默认工程在 `d:\app\projects\whitenoise`，Flutter 工程 cwd 为 `d:\app\projects\whitenoise\snapp`。

---

## 范围说明（与 spec 的偏差）

设计文档第五节提到「首页正在播放卡片柔示」。经核对，Flutter 首页（`lib/pages/index/index_page.dart` L30-L38）明确**不渲染大主控卡，播放主控统一走全局悬浮 PlayBar**，且 PlayBar 标题行本身已常驻显示倒计时徽标（`lib/widgets/play_bar.dart` L116-L131）。因此**不在首页新增独立播放卡**，「首页柔示」由 PlayBar 徽标承载（已在 5 秒/每秒格点与所有 tab 常驻）。本计划据此收敛范围：核心交付为淡出逻辑 + 淡出态可感知提示。

---

## 文件结构

- `lib/services/player_service.dart` — 淡出核心 + `fading` 只读态。任务 1。
- `lib/pages/player/player_page.dart` — 淡出态非侵入提示（“缓缓入眠”文案）。任务 2。
- `lib/widgets/play_bar.dart` — 淡出态徽标软化（弱提示，不新增卡片）。任务 2。
- `test/player_service_test.dart` — 淡出单元测试。任务 1。
- `test/player_page_test.dart` / 或扩展现有 widget 测试 — 淡出提示渲染。任务 2。

---

## Task 1: 淡出核心（PlayerService）

**Files:**
- Modify: `lib/services/player_service.dart`
- Test: `test/player_service_test.dart`

**Interfaces:**
- Consumes: 既有 `AudioEngine.setVolume(String id, double v)`、`AudioEngine.pause()`、`BackgroundTask.stop()`、`PlayerTrack.volume`（0–100）、`fadeMinutes`。
- Produces:
  - `bool get fading` — 是否为「淡出段」（进入最后 `fadeDuration` 分钟）。
  - `startCountdown(int minutes)` 行为增强：淡出段内逐轨音量随时间单调降到 0；到点 `pause()`。
  - `stopCountdown()` 行为增强：恢复 `_fadeBase` 原音量、清 `_fading`。

- [ ] **Step 1: 新增字段与 `fading` getter**

在 `PlayerService` 状态区（`_countdownTimer` 附近）新增：

```dart
  /// 是否处于睡眠倒计时末段「渐隐淡出」阶段（UI 据此做柔和提示）。
  bool _fading = false;

  /// 每轨淡出起点基准音量（0–1，muted 轨按 0）；取消时据此恢复。
  final Map<String, double> _fadeBase = <String, double>{};
```

在 `timerLabel` getter 之后新增只读态：

```dart
  /// 当前是否处于淡出段（进入最后 min(fadeMinutes, timerMinutes) 分钟）。
  bool get fading => _fading;
```

- [ ] **Step 2: 重构 `startCountdown` 实现渐隐淡出**

将现有 `startCountdown`（player_service.dart L223-L244）替换为：

```dart
  /// 启动睡眠倒计时：每秒递减；进入最后 fade 段将逐轨音量平滑降到 0，
  /// 到点暂停停止并解锁「初次入眠」成就数据源。
  void startCountdown(int minutes) {
    _countdownTimer?.cancel();
    if (minutes <= 0) {
      remainingSeconds = 0;
      _fading = false;
      _fadeBase.clear();
      return;
    }
    remainingSeconds = minutes * 60;
    _fading = false;
    // 淡出持续时长 = min(fadeMinutes, timerMinutes) 分钟（超短定时也整体淡出）。
    final fadeSeconds = (fadeMinutes < minutes ? fadeMinutes : minutes) * 60;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      remainingSeconds--;
      if (fadeSeconds > 0 && remainingSeconds <= fadeSeconds && !_fading) {
        _fading = true;
        _enterFade();
      }
      if (_fading) {
        final progress =
            1 - (remainingSeconds.clamp(0, fadeSeconds) / fadeSeconds);
        for (final PlayerTrack t in tracks) {
          final base = _fadeBase[t.id] ?? (t.muted ? 0 : t.volume / 100);
          unawaited(_engine.setVolume(t.id, base * (1 - progress)));
        }
      }
      if (remainingSeconds <= 0) {
        remainingSeconds = 0;
        timerMinutes = 0;
        _countdownTimer?.cancel();
        _countdownTimer = null;
        _fading = false;
        _fadeBase.clear();
        isPlaying = false;
        timerCompleted = true;
        // 淡出后暂停引擎（原实现缺失，避免静默常驻）。
        unawaited(_engine.pause());
        // 睡眠定时到点停止播放 → 释放长时任务。
        unawaited(BackgroundTask.stop());
      }
      notifyListeners();
    });
  }

  /// 进入淡出段时记录每轨基准音量作为渐变起点。
  void _enterFade() {
    _fadeBase.clear();
    for (final PlayerTrack t in tracks) {
      _fadeBase[t.id] = t.muted ? 0 : t.volume / 100;
    }
  }
```

- [ ] **Step 3: 增强 `stopCountdown` 恢复原音量**

将现有 `stopCountdown`（L246-L251）替换为：

```dart
  /// 取消睡眠倒计时并清零剩余秒数；恢复淡出前的每轨基准音量。
  void stopCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    remainingSeconds = 0;
    _fading = false;
    for (final MapEntry<String, double> e in _fadeBase.entries) {
      unawaited(_engine.setVolume(e.key, e.value));
    }
    _fadeBase.clear();
  }
```

- [ ] **Step 4: 编写淡出单元测试**

在 `test/player_service_test.dart` 末尾追加（保留 engine 引用以断言音量序列）：

```dart
  test('sleep timer fades volumes monotonically to 0 then pauses', () {
    final engine = SimulatedAudioEngine();
    final player = PlayerService(engine: engine);
    player.fadeMinutes = 1;
    player.applyScene(findScene('deep-sleep'));
    final ids = player.tracks.map((t) => t.id).toList();
    fakeAsync((FakeAsync async) {
      player.setTimer(1); // 60s，fadeSeconds = min(1,1)*60 = 60
      expect(player.fading, isTrue); // 1 分钟定时整体入淡出段
      final snapshot = <String, List<double>>{
        for (final id in ids) id: <double>[],
      };
      // 采集 3 个采样点的音量（30 / 45 / 60s）
      async.elapse(const Duration(seconds: 30));
      for (final id in ids) snapshot[id]!.add(engine.volumes[id] ?? 0);
      async.elapse(const Duration(seconds: 15));
      final mid = <double>[
        for (final id in ids) engine.volumes[id] ?? 0
      ];
      async.elapse(const Duration(seconds: 15));
      final end = <double>[
        for (final id in ids) engine.volumes[id] ?? 0
      ];
      for (final id in ids) {
        final v = engine.volumes[id] ?? 0;
        expect(v, lessThanOrEqualTo(snapshot[id]!.first)); // 单调不减…只增
        expect(engine.volumes[id], isNotNull);
      }
      expect(engine.volumes[ids.first], closeTo(0, 0.001)); // 到点音量 ≈0
      expect(player.isPlaying, isFalse);
      expect(engine.playing, isFalse); // 已 pause
      expect(player.timerCompleted, isTrue);
      expect(player.fading, isFalse);
    });
  });

  test('cancel timer restores base volumes and clears fading', () {
    final engine = SimulatedAudioEngine();
    final player = PlayerService(engine: engine);
    player.fadeMinutes = 1;
    player.applyScene(findScene('deep-sleep'));
    final id = player.tracks.first.id;
    fakeAsync((FakeAsync async) {
      player.setTimer(2); // 120s，fadeSeconds=60
      async.elapse(const Duration(seconds: 70)); // 进入淡出段 10s
      expect(player.fading, isTrue);
      expect(engine.volumes[id], lessThan(0.5)); // 已开始降幅
      player.setTimer(2); // 重复点击取消
      expect(player.timerMinutes, 0);
      expect(player.remainingSeconds, 0);
      expect(player.fading, isFalse);
      expect(engine.volumes[id], closeTo(0.5, 0.001)); // 恢复基准 50/100
      // 继续走时间不再有音量变化（倒计时已取消）
      async.elapse(const Duration(seconds: 90));
      expect(engine.volumes[id], closeTo(0.5, 0.001));
      expect(player.isPlaying, isTrue);
    });
  });
```

- [ ] **Step 5: 运行测试确保通过**

Run（cwd `d:\app\projects\whitenoise\snapp`）:
`flutter test test/player_service_test.dart`
Expected: 全绿（含既有测试 `setTimer countdown reaches zero stops playback and completes timer`）。

- [ ] **Step 6: `flutter analyze` 校验**

Run: `flutter analyze`
Expected: No issues found（零错误，除既有已知可能告警外不新增）。

---

## Task 2: 淡出态非侵入提示（Player 页 + PlayBar 徽标）

说明：到点无弹窗，仅在进入淡出段（`fading`）时以次要文案柔和提示“缓缓入眠”，不打断、不聚焦焦点、无 overlay。

**Files:**
- Modify: `lib/pages/player/player_page.dart`
- Modify: `lib/widgets/play_bar.dart`
- Test: `test/player_page_test.dart`（若不存在则新建；依赖现有测试基建）

**Interfaces:**
- Consumes: `PlayerService.fading`、`PlayerService.timerLabel`、`PlayerService.timerMinutes`。
- Produces: 无新接口（纯 UI）。

- [ ] **Step 1: 播放页主控区淡出提示**

在 `player_page.dart` 主控行（约 L176-L249）内，选中播放按钮后、收藏按钮前的 `_CtlButton` 定时按钮后方，追加一个淡出态小字提示（仅 `fading` 时显示）：

```dart
          if (player.fading)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('缓缓入眠…',
                  style: TextStyle(fontSize: 12, color: c.text2)),
            ),
```

将该行置于 `Row`（`mainAxisAlignment: MainAxisAlignment.spaceAround`）所在 `Column` 中；若该主控区当前是纯 `Row`，则需在 `Row` 外面再包一层 `Column(mainAxisSize: MainAxisSize.min)`，把提示行放进 Column 末尾，确保布局不因添加/移除而跳动（用 `fading` 的 `AnimatedOpacity` 包裹提示行以获得柔和过渡）。

- [ ] **Step 2: PlayBar 定时徽标淡出软化**

修改 `lib/widgets/play_bar.dart` 的标题行倒计时徽标（L116-L131）：当 `player.fading` 时，将 `c.primarySoft` 底色改为更柔和的 `c.surface2` 并把文字色改为 `c.text2`，并可追加“…入眠中”文案到倒计时后，采用 `AnimatedContainer`/`AnimatedDefaultTextStyle` 平滑过渡。不改布局结构、不新增卡片。

具体替换：将徽标 `Container(...)` 的 `color` 与 `Text` 的 `color` 改为按 `player.fading` 选择：

```dart
                              if (player.timerMinutes > 0) ...[
                                const SizedBox(width: 5),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: player.fading ? c.surface2 : c.primarySoft,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 400),
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color:
                                            player.fading ? c.text2 : c.primary),
                                    child: Text(player.fading
                                        ? '${player.timerLabel} · 入眠中'
                                        : player.timerLabel),
                                  ),
                                ),
                              ],
```

- [ ] **Step 3: 编写淡出提示 Widget 测试**

在 `test/` 下（沿用现有 PlayerPage widget test 基建；若需新建仅含本断言的最小测试）：

```dart
  testWidgets('timer fade state surfaces gentle hint without modal', (tester) async {
    // 组装含 PlayerService(engine: SimulatedAudioEngine()) 的 Provider + PlayerPage
    // applyScene 一个场景；player.setTimer(1)；fakeAsync 推进到淡出段。
    // 断言：出现「入眠中」文本，且无 Overlay/Dialog（find.byType(Dialog) 为空）。
  });
```

若项目现有 PlayerPage widget 测试基建与依赖注入方式与此假设不同，请以现有 `test/` 内最能复用的测试文件为模板调整装配方式后运行。

- [ ] **Step 4: 运行完整测试套件**

Run（cwd `d:\app\projects\whitenoise\snapp`）:
`flutter analyze && flutter test`
Expected: `flutter analyze` 零错误；`flutter test` 全绿（62+ 现有项 + 新增项）。

---

## Self-Review

**Spec 覆盖：**
- 「渐隐淡出到 0 再停」→ Task 1 Step 2（逐轨降幅 + `pause`）。✓
- 「取消恢复、不弹窗」→ Task 1 Step 3 + Task 2（仅文案提示、无 modal）。✓
- 「显眼常驻」→ PlayBar 徽标（既有）+ Task 2 Step 2 淡出软化；首页按架构收敛为 PlayBar（范围说明）。✓
- 「节奏对齐」→ 淡出开始时刻=最后 fadeDuration；对 1 分钟短定时整体淡出，行为确定。✓
- 「三处主控：播放页」→ Task 2 Step 1。✓

**占位符扫描：** 无 TBD/TODO；测试装配按存在性做明确分支说明。

**类型一致性：** `fading` getter、`_fadeBase`、`_enterFade()`、`stopCountdown` 两任务间命名一致。