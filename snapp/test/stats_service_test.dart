import 'package:flutter_test/flutter_test.dart';
import 'package:snapp/services/scene_service.dart';
import 'package:snapp/services/stats_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('recordPlay increments totals, per-scene and per-day counts', () {
    final stats = StatsService(clock: () => DateTime(2026, 9, 17, 10));
    stats.recordPlay('deep-sleep');
    stats.recordPlay('deep-sleep');
    stats.recordPlay('rainy-night');
    expect(stats.totalPlays, 3);
    expect(stats.playCountsByScene['deep-sleep'], 2);
    expect(stats.playCountsByScene['rainy-night'], 1);
    expect(stats.dailyPlayCounts['2026-09-17'], 3);
    expect(stats.activeDays, contains('2026-09-17'));
    expect(stats.activeDayCount, 1);
  });

  test('weekPlays returns today-first 7-day window', () {
    final stats = StatsService(clock: () => DateTime(2026, 9, 17, 10));
    stats.recordPlay('deep-sleep');
    // 直接写入历史日期
    stats.dailyPlayCounts['2026-09-12'] = 2;
    stats.activeDays.add('2026-09-12');
    final week = stats.weekPlays;
    expect(week.length, 7);
    expect(week[0], 1); // 今天
    expect(week[1], 0); // 9-16
    expect(week[5], 2); // 9-12
    expect(stats.weekUsageDays, 2);
    expect(stats.weekTotalMinutes, 3);
  });

  test('favoriteScene and topScenes derived from counts', () {
    final stats = StatsService();
    stats.recordPlay('deep-sleep');
    stats.recordPlay('deep-sleep');
    stats.recordPlay('ocean-sleep');
    expect(stats.favoriteSceneId, 'deep-sleep');
    expect(stats.favoriteSceneName, findScene('deep-sleep').name);
    final top = stats.topScenes;
    expect(top.length, 2);
    expect(top[0].name, findScene('deep-sleep').name);
    expect(top[0].count, 2);
    expect(top[0].percent, 100);
    expect(top[1].percent, 50);
  });

  test('formatMinutes renders Xh Ym / Ym', () {
    expect(StatsService.formatMinutes(0), '0m');
    expect(StatsService.formatMinutes(45), '45m');
    expect(StatsService.formatMinutes(60), '1h');
    expect(StatsService.formatMinutes(128), '2h 8m');
  });

  test('load tolerates unavailable storage', () async {
    final stats = StatsService();
    await stats.load(); // 存储不可用 → 空态不抛错
    expect(stats.totalPlays, 0);
    stats.recordPlay('deep-sleep');
    expect(stats.totalPlays, 1);
  });
}
