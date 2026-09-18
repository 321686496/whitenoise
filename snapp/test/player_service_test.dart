import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapp/services/audio_engine.dart';
import 'package:snapp/services/player_service.dart';
import 'package:snapp/services/scene_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// 播放状态单例：注入模拟引擎，保持测试无插件、无真实音频依赖。
  PlayerService buildPlayer() =>
      PlayerService(engine: SimulatedAudioEngine());

  test('applyScene rebuilds tracks from soundIds and marks playing', () {
    final player = buildPlayer();
    final scene = findScene('deep-sleep');
    player.applyScene(scene);
    expect(player.currentScene?.id, 'deep-sleep');
    expect(player.tracks.length, scene.soundIds.length);
    expect(player.isPlaying, isTrue);
    for (final t in player.tracks) {
      expect(t.volume, 50);
      expect(t.muted, isFalse);
    }
  });

  test('togglePlay returns false when no tracks, true otherwise', () {
    final player = buildPlayer();
    expect(player.togglePlay(), isFalse);
    player.applyScene(findScene('focus-white-noise'));
    expect(player.togglePlay(), isTrue);
    expect(player.isPlaying, isFalse);
    expect(player.togglePlay(), isTrue);
    expect(player.isPlaying, isTrue);
  });

  test('setTimer toggles off on same duration', () {
    final player = buildPlayer();
    player.setTimer(30);
    expect(player.timerMinutes, 30);
    player.setTimer(30);
    expect(player.timerMinutes, 0);
  });

  test('setTrackVolume clamps and toggleTrackMute/removeTrack work', () {
    final player = buildPlayer();
    player.applyScene(findScene('ocean-sleep'));
    final id = player.tracks.first.id;
    player.setTrackVolume(id, 150);
    expect(player.tracks.first.volume, 100);
    player.setTrackVolume(id, -5);
    expect(player.tracks.first.volume, 0);
    player.setTrackVolume(id, 66);
    expect(player.tracks.first.volume, 66);

    player.toggleTrackMute(id);
    expect(player.tracks.first.muted, isTrue);

    // 移除全部音轨后自动停止播放
    for (final t in List<PlayerTrack>.from(player.tracks)) {
      player.removeTrack(t.id);
    }
    expect(player.tracks, isEmpty);
    expect(player.isPlaying, isFalse);
  });

  test('recentTimeLabel formats relative time', () {
    final now = DateTime.now().millisecondsSinceEpoch;
    expect(PlayerService.recentTimeLabel(now), '刚刚');
    expect(PlayerService.recentTimeLabel(now - 5 * 60000), '5分钟前');
    expect(PlayerService.recentTimeLabel(now - 2 * 3600000), '2小时前');
    expect(PlayerService.recentTimeLabel(now - 12 * 3600000), '昨晚');
    expect(PlayerService.recentTimeLabel(now - 3 * 24 * 3600000), '3天前');
  });

  test('setTimer countdown reaches zero stops playback and completes timer',
      () {
    final player = buildPlayer();
    player.applyScene(findScene('deep-sleep'));
    fakeAsync((FakeAsync async) {
      player.setTimer(1); // 60 秒
      expect(player.timerMinutes, 1);
      expect(player.remainingSeconds, 60);
      expect(player.timerCompleted, isFalse);

      async.elapse(const Duration(seconds: 30));
      expect(player.remainingSeconds, 30);

      async.elapse(const Duration(seconds: 30));
      expect(player.remainingSeconds, 0);
      expect(player.timerMinutes, 0);
      expect(player.isPlaying, isFalse);
      expect(player.timerCompleted, isTrue);
    });
  });

  test('stopCountdown cancels and resets remaining seconds', () {
    final player = buildPlayer();
    fakeAsync((FakeAsync async) {
      player.setTimer(15);
      expect(player.remainingSeconds, 900);
      async.elapse(const Duration(seconds: 5));
      player.stopCountdown();
      expect(player.remainingSeconds, 0);
      async.elapse(const Duration(minutes: 5));
      expect(player.remainingSeconds, 0); // 计时器已取消，不再递减
    });
  });

  test('setTimer toggles off on same duration and cancels countdown', () {
    final player = buildPlayer();
    fakeAsync((FakeAsync async) {
      player.setTimer(30);
      expect(player.timerMinutes, 30);
      expect(player.remainingSeconds, 1800);
      player.setTimer(30);
      expect(player.timerMinutes, 0);
      expect(player.remainingSeconds, 0);
      async.elapse(const Duration(minutes: 5));
      expect(player.remainingSeconds, 0);
    });
  });

  test('timerLabel formats countdown and minutes', () {
    final player = buildPlayer();
    fakeAsync((FakeAsync async) {
      player.setTimer(2);
      expect(player.timerLabel, '2:00');
      async.elapse(const Duration(seconds: 1));
      expect(player.timerLabel, '1:59');
      player.stopCountdown();
      player.timerMinutes = 5;
      expect(player.timerLabel, '5分钟');
    });
  });

  test('toggleLock flips isLocked', () {
    final player = buildPlayer();
    expect(player.isLocked, isFalse);
    player.toggleLock();
    expect(player.isLocked, isTrue);
    player.toggleLock();
    expect(player.isLocked, isFalse);
  });

  test('sleep timer fades volumes monotonically to 0 then pauses', () {
    final engine = SimulatedAudioEngine();
    final player = PlayerService(engine: engine);
    player.fadeMinutes = 1;
    player.applyScene(findScene('deep-sleep'));
    final ids = player.tracks.map((t) => t.id).toList();
    fakeAsync((FakeAsync async) {
      player.setTimer(1); // 60s，fadeSeconds = min(1,1)*60 = 60
      expect(player.fading, isTrue);
      async.elapse(const Duration(seconds: 30));
      for (final id in ids) {
        expect(engine.volumes[id], isNotNull);
      }
      async.elapse(const Duration(seconds: 15));
      final mid = <double>[for (final id in ids) engine.volumes[id] ?? 0];
      async.elapse(const Duration(seconds: 15));
      for (var i = 0; i < ids.length; i++) {
        expect(engine.volumes[ids[i]] ?? 0, lessThanOrEqualTo(mid[i])); // 单调不增
        expect(engine.volumes[ids[i]] ?? 0, lessThan(mid[i]));
      }
      expect(engine.volumes[ids.first] ?? 0, closeTo(0, 0.001)); // 到点音量 ≈0
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
      expect(engine.volumes[id] ?? 0, lessThan(0.5)); // 已开始降幅
      player.setTimer(2); // 重复点击取消
      expect(player.timerMinutes, 0);
      expect(player.remainingSeconds, 0);
      expect(player.fading, isFalse);
      expect(engine.volumes[id] ?? 0, closeTo(0.5, 0.001)); // 恢复基准 50/100
      // 继续走时间不再有音量变化（倒计时已取消）
      async.elapse(const Duration(seconds: 90));
      expect(engine.volumes[id] ?? 0, closeTo(0.5, 0.001));
      expect(player.isPlaying, isTrue);
    });
  });
}
