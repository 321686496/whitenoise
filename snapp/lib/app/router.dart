import 'package:flutter/material.dart';

import '../pages/achievement/achievement_page.dart';
import '../pages/checkin/checkin_page.dart';
import '../pages/discover/discover_page.dart';
import '../pages/favorites/favorites_page.dart';
import '../pages/history/history_page.dart';
import '../pages/index/index_page.dart';
import '../pages/invite/invite_page.dart';
import '../pages/library/library_page.dart';
import '../pages/mine/mine_page.dart';
import '../pages/onboarding/onboarding_page.dart';
import '../pages/player/player_page.dart';
import '../pages/scene-all/scene_all_page.dart';
import '../pages/scene-detail/scene_detail_page.dart';
import '../pages/scene-edit/scene_edit_page.dart';
import '../pages/scene/scene_page.dart';
import '../pages/settings/settings_page.dart';
import '../pages/stats/stats_page.dart';
import '../pages/theme/theme_page.dart';

/// 命名路由表（对照原型 `pages.json`，一一对应）。
///
/// 4 个 tab 页的真实切换由 Root 的 `_Shell`（IndexedStack + 悬浮 AppTabBar）
/// 管理；其余页面为命名路由 push。
Map<String, WidgetBuilder> buildRoutes() => <String, WidgetBuilder>{
      '/index': (_) => const IndexPage(),
      '/scene': (_) => const ScenePage(),
      '/discover': (_) => const DiscoverPage(),
      '/mine': (_) => const MinePage(),
      '/library': (_) => const LibraryPage(),
      '/theme': (_) => const ThemePage(),
      '/achievement': (_) => const AchievementPage(),
      '/invite': (_) => const InvitePage(),
      '/settings': (_) => const SettingsPage(),
      '/checkin': (_) => const CheckinPage(),
      '/stats': (_) => const StatsPage(),
      '/favorites': (_) => const FavoritesPage(),
      '/history': (_) => const HistoryPage(),
      '/onboarding': (_) => const OnboardingPage(),
      '/player': (_) => const PlayerPage(),
      '/scene-all': (_) => const SceneAllPage(),
      '/scene-detail': (_) => const SceneDetailPage(),
      '/scene-edit': (_) => const SceneEditPage(),
    };

/// 需要携带参数的页面统一走 onGenerateRoute（arguments 为 Map<String, dynamic>）。
RouteFactory get onGenerateRoute => (RouteSettings settings) {
      final builder = buildRoutes()[settings.name];
      if (builder == null) return null;
      return MaterialPageRoute<void>(
        builder: builder,
        settings: settings,
      );
    };
