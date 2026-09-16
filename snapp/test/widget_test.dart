// 声栖 · 应用外壳冒烟测试。
//
// 验证 Root（外壳 + 悬浮 TabBar + 命名路由）能在默认主题下正常 pump，且可经
// 底部 TabBar 切换 tab 页。

import 'package:flutter_test/flutter_test.dart';

import 'package:snapp/app/app.dart';
import 'package:snapp/services/achievement_service.dart';
import 'package:snapp/services/checkin_service.dart';
import 'package:snapp/services/custom_scene_service.dart';
import 'package:snapp/services/favorites_service.dart';
import 'package:snapp/services/player_service.dart';
import 'package:snapp/services/stats_service.dart';
import 'package:snapp/theme/theme_notifier.dart';
import 'package:snapp/widgets/tab_bar.dart';

void main() {
  testWidgets('Root shell renders floating tab bar with four tabs',
      (WidgetTester tester) async {
    await tester.pumpWidget(_buildRoot());
    expect(tester.takeException(), isNull);

    expect(find.byType(AppTabBar), findsOneWidget);
    expect(
      find.descendant(of: find.byType(AppTabBar), matching: find.text('首页')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: find.byType(AppTabBar), matching: find.text('场景')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: find.byType(AppTabBar), matching: find.text('发现')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: find.byType(AppTabBar), matching: find.text('我的')),
      findsOneWidget,
    );
  });

  testWidgets('tapping a tab bar item does not throw', (WidgetTester tester) async {
    await tester.pumpWidget(_buildRoot());

    await tester.tap(
      find.descendant(of: find.byType(AppTabBar), matching: find.text('我的')),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

/// 组装完整 Root（含 stats / achievement 服务，与 main.dart 注入一致）。
Root _buildRoot() {
  final stats = StatsService();
  final player = PlayerService(stats: stats);
  final checkin = CheckinService();
  final customScenes = CustomSceneService();
  return Root(
    notifier: ThemeNotifier(),
    player: player,
    favorites: FavoritesService(),
    checkin: checkin,
    customScenes: customScenes,
    stats: stats,
    achievement: AchievementService(
      player: player,
      checkin: checkin,
      customScenes: customScenes,
      stats: stats,
      themeNotifier: ThemeNotifier(),
    ),
  );
}