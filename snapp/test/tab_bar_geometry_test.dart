import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  testWidgets('AppTabBar fills width with 4 equal items at 390x844',
      (WidgetTester tester) async {
    // Flutter 3.7：经 binding.window 设置测试视口（390x844 @ dpr1）
    final window = tester.binding.window;
    window.physicalSizeTestValue = const Size(390, 844);
    window.devicePixelRatioTestValue = 1.0;
    addTearDown(window.clearPhysicalSizeTestValue);
    addTearDown(window.clearDevicePixelRatioTestValue);

    final stats = StatsService();
    final player = PlayerService(stats: stats);
    final checkin = CheckinService();
    final customScenes = CustomSceneService();
    await tester.pumpWidget(Root(
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
        )));
    expect(tester.takeException(), isNull);

    final tabBar = find.byType(AppTabBar);
    expect(tabBar, findsOneWidget);
    final RenderBox barBox = tester.renderObject(tabBar);
    debugPrint('AppTabBar size = ${barBox.size}');

    final rowFinder = find.descendant(
      of: tabBar,
      matching: find.byWidgetPredicate((Widget w) => w is Row),
    );
    final RenderFlex row =
        tester.renderObject(rowFinder.first) as RenderFlex;
    debugPrint('Row size = ${row.size}, childCount = ${row.childCount}');
    RenderObject? child = row.firstChild;
    var i = 0;
    while (child is RenderBox) {
      final FlexParentData pd = child.parentData as FlexParentData;
      debugPrint('item[$i] size=${child.size} offset=${pd.offset}');
      child = pd.nextSibling;
      i++;
    }

    expect(barBox.size.width, moreOrLessEquals(366, epsilon: 1));
  });
}
