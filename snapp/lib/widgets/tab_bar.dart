import 'package:flutter/material.dart';

import '../theme/theme_extension.dart';
import 'app_icon.dart';

class _TabItem {
  final String key;
  final String label;
  final String icon;
  const _TabItem(this.key, this.label, this.icon);
}

const List<_TabItem> _tabs = <_TabItem>[
  _TabItem('home', '首页', 'wave'),
  _TabItem('scene', '场景', 'mountain'),
  _TabItem('discover', '发现', 'palette'),
  _TabItem('mine', '我的', 'user'),
];

/// 悬浮底部 TabBar（4 tab：首页 / 场景 / 发现 / 我的）。
///
/// 卡片样式跟随主题：底色 / 描边走 `appColors`，圆角 / 阴影走 `appShapes`。
class AppTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const AppTabBar({required this.currentIndex, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    final s = Theme.of(context).appShapes;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 56),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: c.cardBg,
            borderRadius: BorderRadius.circular(s.cardRadius),
            border: Border.all(color: c.cardBorder, width: 0.5),
            boxShadow: s.cardShadow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List<Widget>.generate(_tabs.length, (int i) {
              final bool active = i == currentIndex;
              final _TabItem tab = _tabs[i];
              final Color color = active ? c.primary : c.text3;
              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    AppIcon(name: tab.icon, size: 22, color: color),
                    const SizedBox(height: 2),
                    Text(
                      tab.label,
                      style: TextStyle(
                        fontSize: 10,
                        color: color,
                        fontWeight:
                            active ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}