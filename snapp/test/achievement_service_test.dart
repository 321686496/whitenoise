import 'package:flutter_test/flutter_test.dart';
import 'package:snapp/data/scene_models.dart';
import 'package:snapp/services/achievement_service.dart';
import 'package:snapp/services/checkin_service.dart';
import 'package:snapp/services/custom_scene_service.dart';
import 'package:snapp/services/player_service.dart';
import 'package:snapp/services/stats_service.dart';
import 'package:snapp/theme/theme_notifier.dart';
import 'package:snapp/theme/theme_tokens.dart';

Scene _scene(String id) => Scene(
      id: id,
      name: id,
      category: 'custom',
      desc: '',
      iconName: 'wave',
      gradient: '#8296A8',
      image: '',
      soundIds: <String>['white-noise'],
      isPreset: false,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('evaluate unlocks a1/a6/a7 from player state', () {
    final player = PlayerService();
    final achievement = AchievementService(
      player: player,
      checkin: CheckinService(),
      customScenes: CustomSceneService(),
      stats: StatsService(),
      themeNotifier: ThemeNotifier(),
    );
    expect(achievement.unlockedCount, 0);
    player.timerCompleted = true;
    player.nightPlayRecorded = true;
    player.maxTrackCount = 6;
    achievement.evaluate();
    final ids = achievement.items
        .where((Achievement a) => a.unlocked)
        .map((Achievement a) => a.id);
    expect(ids, containsAll(<String>['a1', 'a6', 'a7']));
    expect(
        achievement.items.firstWhere((Achievement a) => a.id == 'a4').unlocked,
        isFalse);
  });

  test('evaluate unlocks a2 via checkin streak >= 7', () {
    final checkin = CheckinService(clock: () => DateTime(2026, 9, 17));
    for (var i = 6; i >= 0; i--) {
      final d = DateTime(2026, 9, 17).subtract(Duration(days: i));
      checkin.dates.add(CheckinService.dateKey(d));
    }
    final achievement = AchievementService(
      player: PlayerService(),
      checkin: checkin,
      customScenes: CustomSceneService(),
      stats: StatsService(),
      themeNotifier: ThemeNotifier(),
    );
    achievement.evaluate();
    expect(
        achievement.items.firstWhere((Achievement a) => a.id == 'a2').unlocked,
        isTrue);
  });

  test('evaluate unlocks a3 via 5+ custom scenes', () async {
    final custom = CustomSceneService();
    for (var i = 0; i < 5; i++) {
      await custom.add(_scene('c$i'));
    }
    final achievement = AchievementService(
      player: PlayerService(),
      checkin: CheckinService(),
      customScenes: custom,
      stats: StatsService(),
      themeNotifier: ThemeNotifier(),
    );
    achievement.evaluate();
    expect(
        achievement.items.firstWhere((Achievement a) => a.id == 'a3').unlocked,
        isTrue);
  });

  test('evaluate unlocks a5 via 100 active days and a8 via all schemes', () {
    final stats = StatsService();
    for (var i = 0; i < 100; i++) {
      final d = DateTime(2025, 1, 1).add(Duration(days: i));
      stats.activeDays.add(StatsService.dateKey(d));
    }
    final notifier = ThemeNotifier();
    notifier.visitedSchemes.addAll(schemeKeys);
    final achievement = AchievementService(
      player: PlayerService(),
      checkin: CheckinService(),
      customScenes: CustomSceneService(),
      stats: stats,
      themeNotifier: notifier,
    );
    achievement.evaluate();
    expect(
        achievement.items.firstWhere((Achievement a) => a.id == 'a5').unlocked,
        isTrue);
    expect(
        achievement.items.firstWhere((Achievement a) => a.id == 'a8').unlocked,
        isTrue);
  });

  test('load tolerates unavailable storage and keeps all items', () async {
    final achievement = AchievementService(
      player: PlayerService(),
      checkin: CheckinService(),
      customScenes: CustomSceneService(),
      stats: StatsService(),
      themeNotifier: ThemeNotifier(),
    );
    await achievement.load();
    expect(achievement.total, 8);
    expect(achievement.unlockedCount, 0);
    expect(achievement.progressPercent, 0);
  });
}
