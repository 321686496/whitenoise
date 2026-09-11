import 'package:flutter/material.dart';

import '../theme/theme_extension.dart';

/// 通用卡片容器。
///
/// 样式一律跟随主题：底色 / 描边走 `appColors`，圆角 / 阴影走 `appShapes`。
/// 玻璃态的毛玻璃模糊（[AppShapes.cardBlur] > 0）本轮属设计允差，后续页面轮次可补。
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? radius;

  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    final s = Theme.of(context).appShapes;
    final r = radius ?? s.cardRadius;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: c.cardBg,
        borderRadius: BorderRadius.circular(r),
        border: Border.all(color: c.cardBorder, width: 0.5),
        boxShadow: s.cardShadow,
      ),
      child: child,
    );
  }
}