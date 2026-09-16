import 'package:flutter_test/flutter_test.dart';
import 'package:snapp/services/player_service.dart';
import 'package:snapp/services/scene_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('applyScene rebuilds tracks from soundIds and marks playing', () {
    final player = PlayerService();
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
    final player = PlayerService();
    expect(player.togglePlay(), isFalse);
    player.applyScene(findScene('focus-white-noise'));
    expect(player.togglePlay(), isTrue);
    expect(player.isPlaying, isFalse);
    expect(player.togglePlay(), isTrue);
    expect(player.isPlaying, isTrue);
  });

  test('setTimer toggles off on same duration', () {
    final player = PlayerService();
    player.setTimer(30);
    expect(player.timerMinutes, 30);
    player.setTimer(30);
    expect(player.timerMinutes, 0);
  });

  test('setTrackVolume clamps and toggleTrackMute/removeTrack work', () {
    final player = PlayerService();
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
}
