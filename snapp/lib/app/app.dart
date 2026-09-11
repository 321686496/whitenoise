import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/placeholder.dart';
import '../theme/app_theme.dart';
import '../theme/theme_notifier.dart';
import '../theme/theme_tokens.dart';
import '../widgets/tab_bar.dart';
import 'router.dart';

/// 底部 4 tab 内容。
class _Shell extends StatefulWidget {
  const _Shell();

  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  int _index = 0;

  static const List<Widget> _pages = <Widget>[
    PlaceholderPage('首页'),
    PlaceholderPage('场景'),
    PlaceholderPage('发现'),
    PlaceholderPage('我的'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: AppTabBar(
        currentIndex: _index,
        onTap: (int i) => setState(() => _index = i),
      ),
    );
  }
}

/// 应用根组件。
///
/// 主题经 [ThemeNotifier] 驱动：配色方案与 UI 风格改变时，`Consumer`
/// 重建 [MaterialApp] 并注入新的 [ThemeData]，全局即时生效。
class Root extends StatelessWidget {
  final ThemeNotifier notifier;
  const Root({super.key, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeNotifier>.value(
      value: notifier,
      child: Consumer<ThemeNotifier>(
        builder: (BuildContext context, ThemeNotifier n, Widget? _) {
          final colors = appColorsFor(n.schemeKey, n.ui.key);
          return MaterialApp(
            title: '声栖',
            debugShowCheckedModeBanner: false,
            theme: buildAppTheme(colors),
            home: const _Shell(),
            routes: buildRoutes(),
          );
        },
      ),
    );
  }
}