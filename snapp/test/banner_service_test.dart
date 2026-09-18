import 'package:flutter_test/flutter_test.dart';

import 'package:snapp/data/banner_models.dart';
import 'package:snapp/services/banner_service.dart';
import 'package:snapp/services/player_service.dart';
import 'package:snapp/services/stats_service.dart';

void main() {
  StatsService emptyStats() => StatsService();

  test('运营卡固定为第一条，动作进入签到页', () {
    final banners = buildBanners(
        hour: 20, recent: <RecentItem>[], stats: emptyStats());
    expect(banners.first.type, BannerType.campaign);
    expect(banners.first.kind, BannerKind.navigate);
    expect(banners.first.route, '/checkin');
  });

  test('全天任意时段都有 featured 卡', () {
    for (var h = 0; h < 24; h++) {
      final b = buildBanners(
          hour: h, recent: <RecentItem>[], stats: emptyStats());
      expect(b.any((x) => x.type == BannerType.featured), isTrue,
          reason: 'hour=$h 应收敛到某个精选场景');
    }
  });

  test('今日无播放时 status 卡隐藏', () {
    final b = buildBanners(
        hour: 12, recent: <RecentItem>[], stats: emptyStats());
    expect(b.any((x) => x.type == BannerType.status), isFalse);
  });

  test('今日有播放时 status 卡显示今日次数并跳统计', () {
    final s = StatsService(clock: () => DateTime(2026, 1, 1));
    s.dailyPlayCounts['2026-01-01'] = 2; // 今日=2026-01-01，weekPlays[0]==2
    final b = buildBanners(hour: 21, recent: <RecentItem>[], stats: s);
    expect(b.any((x) => x.type == BannerType.status), isTrue);
    final st = b.firstWhere((x) => x.type == BannerType.status);
    expect(st.route, '/stats');
    expect(st.title, contains('2'));
  });
}