# OHOS 后台播放 & 通知栏播放条修复方案

## Context（背景）

用户反馈：Flutter 主工程 `snapp/`（目标平台含 HarmonyOS）「后台播放」与「导航栏播放条」两个功能实际都未生效，要求对照华为官方文档《连续任务（continuous task）》实现。

### 已核实的事实
- **长时任务部分已就绪**：
  - `snapp/ohos/entry/src/main/module.json5` 已声明 `backgroundModes: ["audioPlayback"]` + `ohos.permission.KEEP_BACKGROUND_RUNNING`（[L24-L42](file:///d:/app/projects/whitenoise/snapp/ohos/entry/src/main/module.json5#L24-L42)）。
  - 自研插件 `snapp/plugins/background_task/` 已申请 `backgroundTaskManager.startBackgroundRunning(..., BackgroundMode.AUDIO_PLAYBACK, ...)`/`stopBackgroundRunning`，Dart 侧由 `PlayerService` 在开始/暂停播放时调用（[player_service.dart#L148-L175](file:///d:/app/projects/whitenoise/snapp/lib/services/player_service.dart#L148-L175)）。
- **AVSession / 通知栏播放条能力由第三方引擎 `just_audio_ohos` 内置**，但存在一个「context 接缝」断链，导致 AVSession 无法正确创建：
  - 引擎在播放时构造 `MediaAvPlayer`，其用 `AppStorage.get('context')` 取 context 来 `createAVSession`（[MediaAvPlayer.ets#L94](file:///D:/app/PubCache/git/fluttertpc_just_audio-f103bec53ce72bf0dc685440021a84e329147450/just_audio/ohos/ohos/src/main/ets/components/plugin/MediaAvPlayer.ets#L94)、[#L596-L620](file:///D:/app/PubCache/git/fluttertpc_just_audio-f103bec53ce72bf0dc685440021a84e329147450/just_audio/ohos/ohos/src/main/ets/components/plugin/MediaAvPlayer.ets#L596-L620)）。
  - `just_audio_ohos` 插件注册时写的是 `AppStorage.setOrCreate('context', applicationContext)`（应用上下文，[JustAudioOhosPlugin.ets#L38](file:///D:/app/PubCache/git/fluttertpc_just_audio-f103bec53ce72bf0dc685440021a84e329147450/just_audio/ohos/ohos/src/main/ets/components/plugin/JustAudioOhosPlugin.ets#L38)）。`createAVSession` 需要 **UIAbilityContext**，传 applicationContext 会触发 401 参数校验失败 → AVSession 未创建 → 通知栏无播放条、也不满足「接入 AVSession 才能后台播放」的约束（API≥20 下未接入 AVSession 的长时任务退后台会被系统强制暂停）。
  - 我们现有代码只把 UIAbilityContext 写进了 `'entryContext'`（[EntryAbility.ets#L9](file:///d:/app/projects/whitenoise/snapp/ohos/entry/src/main/ets/entryability/EntryAbility.ets#L9)），**未写入引擎读取的 `'context'` key**。
- **`AppStorage.setOrCreate` 语义**（已查官方文档）：key 已存在且值不同 → 覆盖为 newValue；不存在 → 创建。因此可在引擎插件 `onAttachedToEngine` 执行后，用 UIAbilityContext 覆盖 `'context'`，让引擎之后构造 `MediaAvPlayer` 时读到正确 context。

### 目标
让后台播放真正可用 + 系统通知栏出现「声栖」媒体播放条（可由系统播控中心/锁屏控制）。仅改动原生层一处接缝，不动第三方引擎源码，不新增缓存依赖。

## 方案（推荐）

**单点修复**：在 `snapp/ohos/entry/src/main/ets/entryability/EntryAbility.ets` 的 `configureFlutterEngine` 中，把 UIAbilityContext 同时写入引擎读取的 `'context'` key，并确保它在 `just_audio_ohos` 插件写入 applicationContext **之后**覆盖（利用 `setOrCreate`「值不同则覆盖」语义）。

具体改动：
```typescript
configureFlutterEngine(flutterEngine: FlutterEngine) {
  // 供 background_task 插件取用（沿用现有 key）
  AppStorage.setOrCreate<common.UIAbilityContext>('entryContext', this.context);
  super.configureFlutterEngine(flutterEngine);
  GeneratedPluginRegistrant.registerWith(flutterEngine);
  // 修复引擎 context 接缝：just_audio_ohos 注册时向 'context' 写入了 applicationContext，
  // createAVSession 需要 UIAbilityContext。registerWith 之后用 UIAbilityContext 覆盖之，
  // 使 MediaAvPlayer 以正确 context 创建 AVSession（通知栏播放条 + 后台播放）。
  AppStorage.setOrCreate<common.UIAbilityContext>('context', this.context);
}
```
> 依赖一个前提：`GeneratedPluginRegistrant.registerWith(...)` 是同步执行的，且 `just_audio_ohos` 的 `onAttachedToEngine` 与其后的覆盖行在同一同步段内先后执行（先写 applicationContext，后覆盖为 UIAbilityContext）。这与当前代码结构一致。

### 验证逻辑（为什么这样就够）
- 引擎 `MediaAvPlayer` 在 `createSession()` 里：`createAVSession(UIAbilityContext, ...)` → 不再 401；随后 `activate()`、`setAVMetadata(...)`、`setLaunchAbility`、`setPlayState` 均已内置（引擎自带完整 AVSession 生命周期与播控命令处理）。
- 长时任务单独工作正常；接入有效 AVSession 后，系统认可其后台播放合法性 → 退后台/锁屏持续播放 + 通知栏播放条出现。

## 待修改文件
- `snapp/ohos/entry/src/main/ets/entryability/EntryAbility.ets`（唯一改动点，加 1 行 + 注释）。

## 验证方式
1. `flutter analyze` 零错误、`flutter test` 全绿（Dart 侧无改动，应保持现状）。
2. 真机/模拟器（Harmony 设备）`flutter run -d <ohos-device>`：
   - 首页/场景页播放一个场景，Hilog 过滤 `BackgroundTask` 应出现 `background running started`；过滤引擎 TAG（`just_audio_ohos`/`MediaAvPlayer`）确认 `createAVSession` / `SetAVMetadata successfully`、无 401 报错。
   - 退到后台、锁屏：确认音频持续播放、系统通知栏出现「声栖」媒体播放条。
   - 通过通知栏/播控中心点播放-暂停-上一首-下一首，确认状态与 App 内 PlayBar/播放页同步。
3. 若通知栏仍不出现，追加排查：确认引擎实际播放路径确实实例化 `MediaAvPlayer`（asset 走 AVPlayer 链路），必要时比对 pushRecent 后 `AppStorage.get('context')` 的实际值。

## 风险与备选
- 若真机 hilog 显示仍是 applicationContext（插件在 registerWith 之后/运行期再次写入 `'context'`），则改为在自定义 `BackgroundTaskPlugin.onAttachedToEngine` 内同样补充 `AppStorage.setOrCreate('context', UIAbilityContext)`（该插件是我们自有代码，注入点更可控）。此为兜底，不优先做。
- 不修改 `just_audio_ohos` 引擎源码（在 pub cache，会被构建刷新），故所有改动收敛在 `snapp/ohos` 项目内。