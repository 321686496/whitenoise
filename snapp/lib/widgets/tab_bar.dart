import 'package:flutter/material.dart';

import '../theme/theme_extension.dart';
import 'app_icon.dart';
import 'pressable.dart';

class _TabItem {
  final String key;
  final String label;
  final String iconBody;
  const _TabItem(this.key, this.label, this.iconBody);
}

/// 图标路径沿用原型 `components/TabBar.vue` 的内联绘制（非 Icon.vue 清单）。
const List<_TabItem> _tabs = <_TabItem>[
  _TabItem('index', '首页',
      '<path d="M3 18c2-2.5 4-2.5 6 0s4 2.5 6 0 4-2.5 6 0"/><path d="M3 15c2-2.5 4-2.5 6 0s4 2.5 6 0 4-2.5 6 0"/><path d="M3 12c2-2.5 4-2.5 6 0s4 2.5 6 0 4-2.5 6 0"/><path d="M3 9c2-2.5 4-2.5 6 0s4 2.5 6 0 4-2.5 6 0"/>'),
  _TabItem('scene', '场景',
      '<path d="M4 20l4-10 3 6 3-8 3 6 3-6 3 12"/><circle cx="17" cy="6" r="1.2" fill="currentColor" stroke="none"/>'),
  _TabItem('discover', '发现',
      '<circle cx="12" cy="12" r="9"/><path d="M15.5 8.5l-2 5-5 2 2-5z"/>'),
  _TabItem('mine', '我的',
      '<path d="M14 5c-1-1.5-2.5-2-4-1.5C8.5 4 7.5 5.5 8 7c.3 1 1 1.8 2 2.2"/><path d="M20 21v-1.5a3.5 3.5 0 0 0-3.5-3.5H7.5A3.5 3.5 0 0 0 4 19.5V21"/><circle cx="10" cy="8.5" r="2.5"/>'),
];

// MARKER_TABV5
/// 悬浮底部 TabBar v2（4 tab：首页 / 场景 / 发现 / 我的）。
///
/// 选中态：整项 `primary-soft` 药丸底 + 主色文字 + 底部指示点（对应原型 v2）。
class AppTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const AppTabBar({required this.currentIndex, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    final s = Theme.of(context).appShapes;
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(17),
        border: c.line.opacity > 0.01
            ? Border.all(color: c.line, width: 0.5)
            : null,
        boxShadow: s.cardShadow,
      ),
      child: Row(
        children: List<Widget>.generate(_tabs.length, (int i) {
          final bool active = i == currentIndex;
          final _TabItem tab = _tabs[i];
          return Expanded(
            child: PressableScale(
              onTap: () => onTap(i),
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  color: active ? c.primarySoft : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _TabIcon(body: tab.iconBody, size: 26, color: active ? c.primary : c.text3),
                    const SizedBox(height: 1),
                    Text(
                      tab.label,
                      style: TextStyle(
                        fontSize: 9.5,
                        height: 1.2,
                        letterSpacing: 0.5,
                        color: active ? c.primary : c.text3,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Container(
                      width: 12,
                      height: 3,
                      decoration: BoxDecoration(
                        color: active ? c.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Tab 专属图标（独立于 Icon.vue 清单，body 来自 TabBar.vue）。
class _TabIcon extends StatelessWidget {
  final String body;
  final double size;
  final Color color;
  const _TabIcon({required this.body, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return AppRawIcon(body: body, size: size, color: color);
  }
}
