import 'package:flutter/material.dart';

import '../theme/theme_extension.dart';

/// 页面容器：顶部安全区 + 顶部柔和渐变 + 轻微上浮/淡入进入动效。
///
/// - 支持 `prefers-reduced-motion`：系统关闭动画时跳过进入动效。
/// - 底部未预留 tab 高度——悬浮 AppTabBar 叠放其上，由外层 Scaffold 控制。
class AppPage extends StatefulWidget {
  final Widget child;
  const AppPage({required this.child, super.key});

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
    value: 0,
  );

  bool _reducedMotion() {
    try {
      return WidgetsBinding
          .instance.platformDispatcher.accessibilityFeatures.disableAnimations;
    } catch (_) {
      // 平台性不可用时，退回 MediaQuery 方案。
      return MediaQuery.of(context).disableAnimations;
    }
  }

  @override
  void initState() {
    super.initState();
    if (_reducedMotion()) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.02),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 240,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [c.bgGrad, c.bg],
              ),
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: FadeTransition(
            opacity: _controller,
            child: SlideTransition(
              position: slide,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(13, 12, 13, 24),
                child: widget.child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}