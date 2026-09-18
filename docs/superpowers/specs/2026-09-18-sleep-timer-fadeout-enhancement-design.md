# 睡眠定时「沉浸式衔接」增强 — 设计文档

> 文档日期：2026-09-18
> 实现工程：`snapp/`（Flutter，主代码工程）
> 设计基线：`prototype/src`（uni-app）已有睡眠定时视觉与交互布局，本设计仅对 Flutter 主工程做行为与展示增强，不改原型代码。

---

## 一、背景与目标

「声栖」是白噪音混音助眠 App，目标用户大量依赖它营造舒适睡眠环境。经核实，项目**已具备睡眠定时功能**（播放页主控、场景详情 Hero、底部 PlayBar 弹层均有入口；`PlayerService` 有每秒真实递减的 `remainingSeconds` 倒计时，到点停止播放并释放后台长时任务、解锁「初次入眠」成就）。

但存在三处与「沉浸式衔接」目标不符的缺口，本设计专为填补这些缺口：

1. **到点是硬停**：`startCountdown` 倒计时归零时直接把 `isPlaying=false`，无音量渐隐 → 白噪音「啪」地断开，破坏睡眠沉浸感。
2. **定时状态不常驻**：开启定时后，退出定时面板/弹层即看不见倒计时；播放过程中无一处常驻显示剩余时间 → 用户「忘记/找不到」已开启的定时。
3. **缺柔和结束**：到点没有自然的“停”的感觉，停止点不与音乐循环节奏贴合。

### 成功标准

- 定时到点不再是硬切，而是最后 `fadeMinutes` 内音量平滑降到 0 再停止。
- 定时状态在**底部播放条 / 首页正在播放卡片 / 播放页主控**三处常驻可见。
- 到点停止**绝不弹窗 / dialog / toast 打断睡眠**，仅状态与视觉变化。
- 不改音频引擎接口、不新增三方库、iOS / Android / HarmonyOS 三平台安全、样式严格跟随主题、不引入新颜色。

---

## 二、实现方案选型

**采用方案 A：在 `PlayerService` 层做渐变控制。**

- 复用现有每秒倒计时 tick 与 `AudioEngine.setVolume(id, v)`（0–1 归一化）接口，逐轨随时间按梯度把音量降到 0。
- 取消/异常时恢复原音量，逻辑集中在服务层，可单测（`PlayerService` 已有单元测试，可用 `SimulatedAudioEngine` 断言音量递减序列）。

**对比弃用方案：**
- 方案 B（淡出下沉到 `AudioEngine.fadeOut`）：边界虽干净，但模拟桩与真实引擎两套都要维护淡出与取消恢复状态，测试复杂度抬高，不必要。
- 方案 C（just_audio 内置淡出）：just_audio 无内置淡出 API，需自写动画，等同于方案 A，不独立成立。

**「播完当前段落再停」的落地解释：**
音轨为单曲无限循环（`LoopMode.one`），无天然“段落”边界。因此将其实现为 —— 淡出开始时刻对齐到「距结束点最近的整循环节点」附近，使「停」落在随音乐节奏的自然共性时刻，而非突兀切断。核心仍是渐隐淡出到 0。

---

## 三、状态模型（`snapp/lib/services/player_service.dart`）

新增字段：

| 字段 | 类型 | 说明 |
|---|---|---|
| `_fading` | `bool` | 是否处于淡出阶段 |
| `_fadeBase` | `Map<String,double>` | 每轨淡出起点基准音量（0–1，含静音轨按 0） |

复用既有字段：`remainingSeconds`、`timerMinutes`、`fadeMinutes`（默认 2，可在设置页调整）、`_countdownTimer`、`timerCompleted`。

---

## 四、淡出算法（改造 `startCountdown`）

保持每秒一次 tick 与现有生命周期：

1. 启动时 `_fading=false`、`_fadeBase` 清空。
2. 每 tick：`remainingSeconds--`。
3. **进入淡出段**当 `remainingSeconds ≤ fadeMinutes*60`：
   - 首次进入（`_fading` 由 false 置 true）时，为每轨记录基准 `_fadeBase[id] = track.volume/100`（该轨 muted 时按 0）。
   - 计算 `progress = (fadeMinutes*60 − remainingSeconds) / (fadeMinutes*60)`，范围 [0,1]。
   - 逐轨 `_engine.setVolume(id, _fadeBase[id]! * (1 - progress))`。
4. **到点** `remainingSeconds ≤ 0`：`_fading=false` → `_countdownTimer` 取消、`isPlaying=false`、`timerCompleted=true`、`BackgroundTask.stop()`，并调用 `_engine.pause()`（补上原先缺失的引擎暂停，避免静默常驻）。

**取消 / 恢复**（`setTimer` 重复点同一时长、手动清定时）：
- `stopCountdown()` 恢复 `_fadeBase` 中原音量至各轨，清空 `_fadeBase`、`_fading=false`、`remainingSeconds=0`。

**时长档位**：保持现有可选 `5/15/30/45/60` 分钟不新增；`fadeMinutes` 走既有设置项。

---

## 五、显眼常驻展示（三处）

### 5.1 底部播放条（`widgets/play_bar.dart`）
- 常驻「定时」按钮（现有入口保留），开启后按钮**显示实时倒计时 `timerLabel`（`mm:ss`）**并点亮选中态。
- 倒计时随每秒状态刷新，无需打开面板即可看见剩余时间。
- 面板逻辑与现有一致（重复点同一时长取消）。

### 5.2 首页正在播放卡片（`widgets/` 对应 NowPlayingCard）
- 开启定时后，在卡片副标题/角落以柔和方式展示定时状态与剩余时间。
- 选中态沿用 `.on` 点亮样式；本地无新颜色，全部走主题变量/`Theme`。

### 5.3 播放页主控区（`pages/player/player_page.dart`）
- 保留定时 chip 主控，开启后显示倒计时、选中态点亮。
- 当剩余 < 1 分钟（进入淡出段）时，以次要文案提示当前正“缓缓入眠淡出”，不产生弹窗/toast。

---

## 六、交互约束（明确不做）

- **不弹窗打断**：到点停止仅状态变化，无 modal / dialog / toast。
- **样式跟随主题**：所有颜色/圆角/阴影继续走 `ThemeData` + `ThemeExtension`，禁止 `Color(0xFF…)` / `Colors.xxx` 硬编码；禁止不同 UI 风格 / 主题混搭。
- **不改引擎接口**：仅调用既有 `setVolume(id, v)`。
- **新拟态取向**：若当前 UI 风格为新拟态，按钮/浮层浮雕取向（按压内凹、选中同按压）按项目 4.2 铁律执行。

---

## 七、测试策略

`PlayerService` 单元测试（沿用 `SimulatedAudioEngine` 断言状态）：
- 淡出段每 tick `setVolume` 值按梯度单调递减，末值为 0。
- 到点后 `isPlaying=false`、`pause` 被调用、`BackgroundTask.stop` 触发、`timerCompleted=true`。
- 取消定时恢复 `_fadeBase` 原音量、`_fading=false`、`remainingSeconds=0`。

Widget 测试：
- 底部播放条开启定时后渲染 `mm:ss` 倒计时。
- 首页正在播放卡片开启定时后渲染剩余时间。

---

## 八、范围与验收

- 改动仅在 `snapp/`；不新增三方库；三平台构建通过（`flutter analyze` 零错误、`flutter test` 全绿）。
- `prototype/` 不动（仅作设计参照）。
- 不修改 AGENT.md 文档索引（无新增/删除文档外的约定变更，若工程结构或路由有变再同步）。

---

## 九、总结

用一个服务层内收敛的渐变控制 + 三处常驻倒计时展示，把「醒着也能继续听的睡眠助手」从「到点断电」升级为「缓缓入眠」，全程不打扰、可感知、跟随主题。无新依赖、无平台适配风险、可单测。