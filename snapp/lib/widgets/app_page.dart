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
    // 延后到首帧后再启动动画：initState 阶段外层路由的 TickerMode 可能尚未激活，
    // 若在此处 forward() 且 ticker 被静音后未能恢复（部分嵌入式/OHOS 引擎），控制器会停在 0。
    // 推迟启动即可避免把内容做成“依赖 ticker 才能可见”。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_reducedMotion()) {
        _controller.value = 1;
      } else {
        _controller.forward();
      }
    });
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
            // 底值 0.3：即使 ticker 卡住导致控制器停在 0，页面也已可见（避免整页消失）。
            opacity: Tween<double>(begin: 0.3, end: 1.0).animate(_controller),
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