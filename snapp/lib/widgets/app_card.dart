import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/theme_extension.dart';

/// 通用卡片容器（对应原型 `.app-card`）。
///
/// 样式一律跟随主题：底面 `surface` / 描边 `line` / 阴影 `shadow2` /
/// 圆角 `cardRadius(22)`；玻璃态（blur > 0）追加毛玻璃与顶部内高光；
/// 新拟态（line 透明、面 == bg）自动省略描边。
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? radius;
  final VoidCallback? onTap;
  final Color? color;
  final Border? border;

  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius,
    this.onTap,
    this.color,
    this.border,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    final s = Theme.of(context).appShapes;
    final r = radius ?? s.cardRadius;
    final hasBorder = c.line.opacity > 0.01;
    final effectiveBorder = border ??
        (hasBorder ? Border.all(color: c.line, width: 0.5) : null);

    Widget card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? c.surface,
        borderRadius: BorderRadius.circular(r),
        border: effectiveBorder,
        boxShadow: s.cardShadow,
      ),
      child: child,
    );

    // 玻璃态：毛玻璃模糊 + 顶部内高光（inset 0 1px 0 hl）
    if (s.cardBlur > 0) {
      card = ClipRRect(
        borderRadius: BorderRadius.circular(r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: s.cardBlur, sigmaY: s.cardBlur),
          child: card,
        ),
      );
    }
    if (c.insetHl != null) {
      card = Stack(
        children: [
          card,
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 1,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(color: c.insetHl),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ],
      );
    }
    if (onTap != null) {
      card = Material(
        type: MaterialType.transparency,
        child: InkWell(borderRadius: BorderRadius.circular(r), onTap: onTap, child: card),
      );
    }
    return card;
  }
}
