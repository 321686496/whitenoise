import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/scene_models.dart';
import '../data/seed_data.dart';
import '../data/sound_models.dart';
import 'app_storage.dart';
import 'stats_service.dart';

/// 单条音轨（对应原型 usePlayer 的 `Track`）。
class PlayerTrack {
  final String id;
  final String name;
  final String iconName;
  final String color;
  int volume;
  bool muted;

  PlayerTrack({
    required this.id,
    required this.name,
    required this.iconName,
    required this.color,
    this.volume = 50,
    this.muted = false,
  });
}

/// 最近播放记录（对应原型 `RecentItem`，storage key `shengqi-recent`）。
class RecentItem {
  final String sceneId;
  final String name;
  final String iconName;
  final String gradient;
  final int ts;

  const RecentItem({
    required this.sceneId,
    required this.name,
    required this.iconName,
    required this.gradient,
    required this.ts,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'sceneId': sceneId,
        'name': name,
        'iconName': iconName,
        'gradient': gradient,
        'ts': ts,
      };

  static RecentItem fromJson(Map<String, dynamic> j) => RecentItem(
        sceneId: j['sceneId'] as String? ?? '',
        name: j['name'] as String? ?? '',
        iconName: j['iconName'] as String? ?? 'moon',
        gradient: j['gradient'] as String? ?? '',
        ts: (j['ts'] as num?)?.toInt() ?? 0,
      );
}

/// 声栖 · 共享播放状态（`composables/usePlayer.ts` 的 ChangeNotifier 移植）。
///
/// 模块级单例语义经 Provider 全局注入实现：首页大播放卡 / 场景网格 /
/// 底部 PlayBar 读写同一状态。音频引擎为后续接入预留（原型阶段为状态模拟）。
class PlayerService extends ChangeNotifier {
  PlayerService({StatsService? stats}) : _stats = stats;

  static const int _recentMax = 10;

  /// 统计服务（可选注入）：每次应用场景时记录一次播放。
  final StatsService? _stats;

  Scene? currentScene;
  List<PlayerTrack> tracks = <PlayerTrack>[];
  bool isPlaying = false;
  int timerMinutes = 0;
  int fadeMinutes = 2;
  bool showTimerPanel = false;
  bool showMixPanel = false;

  /// 睡眠定时剩余秒数（>0 表示倒计时进行中；0 表示未启用）。
  int remainingSeconds = 0;

  /// 播放锁（PlayBar / 播放页共享）：仅 UI 态 + toast，不改变播放行为。
  bool isLocked = false;

  Timer? _countdownTimer;

  /// 历史最高同时加载音轨数（成就「混音大师」数据源）。
  int maxTrackCount = 0;

  /// 是否曾在 22:00-02:00 时段播放（成就「午夜电台」数据源）。
  bool nightPlayRecorded = false;

  /// 定时器是否完整走完一次（成就「初次入眠」数据源，由播放页定时完成时置 true）。
  bool timerCompleted = false;

  /// 场景页交接：首页「更多」带入的分类（v1 pendingSceneCategory 流程）
  String pendingSceneCategory = 'all';

  /// 最近播放（内存态 + 本地持久化）
  List<RecentItem> recent = <RecentItem>[];

  /// 应用启动时恢复最近播放记录。
  Future<void> loadRecent() async {
    final list = await AppStorage.readJsonList(AppStorage.keyRecent);
    if (list == null) return;
    recent = list
        .whereType<Map<dynamic, dynamic>>()
        .map((Map<dynamic, dynamic> j) =>
            RecentItem.fromJson(j.cast<String, dynamic>()))
        .toList();
    notifyListeners();
  }

  Sound? findSound(String id) {
    for (final s in sounds) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// 应用场景：按 soundIds 重建音轨并开始播放，同时写入最近记录并上报统计。
  void applyScene(Scene scene) {
    currentScene = scene;
    tracks = scene.soundIds.map((String id) {
      final s = findSound(id);
      return PlayerTrack(
        id: s?.id ?? id,
        name: s?.name ?? id,
        iconName: s?.iconName ?? 'wave',
        color: s?.color ?? '#8296A8',
      );
    }).toList();
    if (tracks.length > maxTrackCount) maxTrackCount = tracks.length;
    final now = DateTime.now();
    if (now.hour >= 22 || now.hour < 2) nightPlayRecorded = true;
    isPlaying = true;
    pushRecent(scene);
    _stats?.recordPlay(scene.id);
    notifyListeners();
  }

  /// 播放/暂停；无音轨时返回 false，由调用方 toast 提示。
  bool togglePlay() {
    if (tracks.isEmpty) return false;
    isPlaying = !isPlaying;
    notifyListeners();
    return true;
  }

  void setTrackVolume(String id, int volume) {
    for (final t in tracks) {
      if (t.id == id) {
        t.volume = volume.clamp(0, 100).toInt();
        break;
      }
    }
    notifyListeners();
  }

  void toggleTrackMute(String id) {
    for (final t in tracks) {
      if (t.id == id) {
        t.muted = !t.muted;
        break;
      }
    }
    notifyListeners();
  }

  void removeTrack(String id) {
    tracks = tracks.where((PlayerTrack t) => t.id != id).toList();
    if (tracks.isEmpty) isPlaying = false;
    notifyListeners();
  }

  /// 定时：重复点击同一时长则取消（启用/取消真实倒计时）。
  void setTimer(int minutes) {
    if (timerMinutes == minutes) {
      stopCountdown();
      timerMinutes = 0;
      notifyListeners();
      return;
    }
    timerMinutes = minutes;
    startCountdown(minutes);
  }

  /// 启动睡眠倒计时：每秒递减；到点停止播放并解锁「初次入眠」成就数据源。
  void startCountdown(int minutes) {
    _countdownTimer?.cancel();
    if (minutes <= 0) {
      remainingSeconds = 0;
      return;
    }
    remainingSeconds = minutes * 60;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      remainingSeconds--;
      if (remainingSeconds <= 0) {
        remainingSeconds = 0;
        timerMinutes = 0;
        _countdownTimer?.cancel();
        _countdownTimer = null;
        isPlaying = false;
        timerCompleted = true;
      }
      notifyListeners();
    });
  }

  /// 取消睡眠倒计时并清零剩余秒数。
  void stopCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    remainingSeconds = 0;
  }

  /// 播放锁切换（toast 由调用方展示）。
  void toggleLock() {
    isLocked = !isLocked;
    notifyListeners();
  }

  /// 定时显示标签：倒计时进行中显示 `mm:ss`，否则显示 `n分钟`。
  String get timerLabel {
    if (remainingSeconds > 0) {
      final m = remainingSeconds ~/ 60;
      final s = remainingSeconds % 60;
      return '$m:${s.toString().padLeft(2, '0')}';
    }
    if (timerMinutes > 0) return '$timerMinutes分钟';
    return '';
  }

  void setFadeMinutes(int minutes) {
    if (fadeMinutes == minutes) return;
    fadeMinutes = minutes;
    notifyListeners();
  }

  void setShowTimerPanel(bool v) {
    if (showTimerPanel == v) return;
    showTimerPanel = v;
    if (v) showMixPanel = false;
    notifyListeners();
  }

  void setShowMixPanel(bool v) {
    if (showMixPanel == v) return;
    showMixPanel = v;
    if (v) showTimerPanel = false;
    notifyListeners();
  }

  /* ------------------------- 最近使用（本地存储） ------------------------- */

  void pushRecent(Scene scene) {
    final list =
        recent.where((RecentItem i) => i.sceneId != scene.id).toList();
    list.insert(
      0,
      RecentItem(
        sceneId: scene.id,
        name: scene.name,
        iconName: scene.iconName,
        gradient: scene.gradient,
        ts: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    recent = list.take(_recentMax).toList();
    AppStorage.writeJsonList(
        AppStorage.keyRecent, recent.map((RecentItem r) => r.toJson()).toList());
  }

  /// 清空最近播放记录（历史页「清空历史」），写回存储。
  void clearRecent() {
    recent = <RecentItem>[];
    AppStorage.writeJsonList(AppStorage.keyRecent, const <Map<String, dynamic>>[]);
    notifyListeners();
  }

  /// 时间标签：刚刚 / n分钟前 / n小时前 / 昨晚 / n天前
  static String recentTimeLabel(int ts) {
    final diff = DateTime.now().millisecondsSinceEpoch - ts;
    final m = (diff / 60000).floor();
    if (m < 1) return '刚刚';
    if (m < 60) return '$m分钟前';
    final h = (m / 60).floor();
    if (h < 8) return '$h小时前';
    if (h < 24) return '昨晚';
    final d = (h / 24).floor();
    return '$d天前';
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
