import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/discover/discover_page.dart';
import '../pages/index/index_page.dart';
import '../pages/mine/mine_page.dart';
import '../pages/onboarding/onboarding_page.dart';
import '../pages/scene/scene_page.dart';
import '../services/achievement_service.dart';
import '../services/app_storage.dart';
import '../services/checkin_service.dart';
import '../services/custom_scene_service.dart';
import '../services/favorites_service.dart';
import '../services/player_service.dart';
import '../services/stats_service.dart';
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
/// 有播放内容时四个 tab 全局悬浮 PlayBar（覆盖在页面之上，不压缩页面高度）；
/// 点击 PlayBar 从底部滑入完整播放页。保存行为：toast 提示。
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
    // 只订阅是否需要展示 PlayBar：避免音量拖拽 / 静音 / 睡眠定时逐秒等
    // PlayerService 的高频变更导致整棵 Shell（Stack + TabBar + PlayBar）重建。
    final showPlayBar = context.select<PlayerService, bool>(
        (PlayerService p) => p.currentScene != null);
    final safeBottom = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: tabIndex, children: _pages),
          if (showPlayBar)
            Positioned(
              left: 13,
              right: 13,
              bottom: safeBottom + kTabHeight + 8,
              child: PlayBar(
                onSaveTap: () => showAppToast(context, '可在首页保存为场景'),
              ),
            ),
          // 紧约束包裹：避免松约束下 Expanded 自适应导致 TabBar 溢出。
          // 无外部盒子的悬浮 tab：4 项图标浮于底部，内容可滚到最底不被截断。
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
/// [onboarded]：首启引导状态（main 读取 `shengqi-onboarded` 传入）。未引导时
/// home 直接挂载引导页（无返回栈、不可返回），完成后写标记并切换主界面。
class Root extends StatefulWidget {
  final ThemeNotifier notifier;
  final PlayerService player;
  final FavoritesService favorites;
  final CheckinService checkin;
  final CustomSceneService customScenes;
  final StatsService stats;
  final AchievementService achievement;
  final bool onboarded;
  const Root({
    super.key,
    required this.notifier,
    required this.player,
    required this.favorites,
    required this.checkin,
    required this.customScenes,
    required this.stats,
    required this.achievement,
    this.onboarded = true,
  });

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  late bool _onboarded = widget.onboarded;

  void _finishOnboarding() {
    // 写标记（存储不可用时静默跳过，不影响进入主界面）。
    AppStorage.setString(AppStorage.keyOnboarded, 'true');
    setState(() => _onboarded = true);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeNotifier>.value(value: widget.notifier),
        ChangeNotifierProvider<PlayerService>.value(value: widget.player),
        ChangeNotifierProvider<FavoritesService>.value(value: widget.favorites),
        ChangeNotifierProvider<CheckinService>.value(value: widget.checkin),
        ChangeNotifierProvider<CustomSceneService>.value(value: widget.customScenes),
        ChangeNotifierProvider<StatsService>.value(value: widget.stats),
        ChangeNotifierProvider<AchievementService>.value(value: widget.achievement),
        ChangeNotifierProvider<ShellTabNotifier>(create: (_) => ShellTabNotifier()),
      ],
      child: Consumer<ThemeNotifier>(
        builder: (BuildContext context, ThemeNotifier n, Widget? _) {
          final colors = appColorsFor(n.schemeKey, n.ui.key, n.resolvedBrightness);
          return MaterialApp(
            title: '声栖',
            debugShowCheckedModeBanner: false,
            theme: buildAppTheme(colors),
            home: _onboarded
                ? const _Shell()
                : OnboardingPage(onDone: _finishOnboarding),
            routes: buildRoutes(),
            onGenerateRoute: onGenerateRoute,
          );
        },
      ),
    );
  }
}
