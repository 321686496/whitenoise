import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/discover/discover_page.dart';
import '../pages/index/index_page.dart';
import '../pages/mine/mine_page.dart';
import '../pages/scene/scene_page.dart';
import '../services/favorites_service.dart';
import '../services/player_service.dart';
import '../theme/app_theme.dart';
import '../theme/theme_extension.dart';
import '../theme/theme_notifier.dart';
import '../theme/theme_tokens.dart';
import '../widgets/play_bar.dart';
import '../widgets/app_toast.dart';
import '../widgets/tab_bar.dart';
import 'router.dart';
import 'shell_tabs.dart';

/// 底部 4 tab 内容（对照原型 tabBar：首页 / 场景 / 发现 / 我的）。
///
/// PlayBar 仅在「发现」tab 挂载（对照原型：首页用主控卡互斥，场景/我的
/// 不含 PlayBar；发现页 `<PlayBar @save-tap>`）。保存行为：跳转编辑场景。
class _Shell extends StatefulWidget {
  const _Shell();

  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  static const List<Widget> _pages = <Widget>[
    IndexPage(),
    ScenePage(),
    DiscoverPage(),
    MinePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final tabIndex = context.watch<ShellTabNotifier>().index;
    final safeBottom = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: tabIndex, children: _pages),
          // PlayBar：仅发现 tab（浮在 TabBar 之上）
          if (tabIndex == 2)
            Positioned(
              left: 13,
              right: 13,
              bottom: safeBottom + kTabHeight + 8,
              child: PlayBar(
                onSaveTap: () => showAppToast(context, '可在首页保存为场景'),
              ),
            ),
          // 紧约束包裹：避免松约束下 Expanded 自适应导致 TabBar 溢出
          Positioned(
            left: 12,
            right: 12,
            bottom: safeBottom * 0.4 + 6,
            child: AppTabBar(
              currentIndex: tabIndex,
              onTap: (int i) => context.read<ShellTabNotifier>().go(i),
            ),
          ),
        ],
      ),
    );
  }
}

/// 应用根组件。
///
/// 主题经 [ThemeNotifier] 驱动：配色 / UI 风格 / 明暗改变时，`Consumer`
/// 重建 [MaterialApp] 并注入新的 [ThemeData]，全局即时生效。
/// 播放状态经 [PlayerService] 全局共享（首页主控卡 / 场景网格 / PlayBar）。
class Root extends StatelessWidget {
  final ThemeNotifier notifier;
  final PlayerService player;
  final FavoritesService favorites;
  const Root({
    super.key,
    required this.notifier,
    required this.player,
    required this.favorites,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeNotifier>.value(value: notifier),
        ChangeNotifierProvider<PlayerService>.value(value: player),
        ChangeNotifierProvider<FavoritesService>.value(value: favorites),
        ChangeNotifierProvider<ShellTabNotifier>(create: (_) => ShellTabNotifier()),
      ],
      child: Consumer<ThemeNotifier>(
        builder: (BuildContext context, ThemeNotifier n, Widget? _) {
          final colors = appColorsFor(n.schemeKey, n.ui.key, n.resolvedBrightness);
          return MaterialApp(
            title: '声栖',
            debugShowCheckedModeBanner: false,
            theme: buildAppTheme(colors),
            home: const _Shell(),
            routes: buildRoutes(),
            onGenerateRoute: onGenerateRoute,
          );
        },
      ),
    );
  }
}
