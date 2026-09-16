import 'package:flutter/material.dart';

import '../theme/theme_extension.dart';
import '../theme/theme_tokens.dart';
import '../utils/style_utils.dart';

/// 页面容器：顶部安全区 + 顶部柔和渐变（`.page-bg`，高度 440rpx）+
/// 轻微上浮/淡入进入动效（尊重系统「减弱动态效果」）。
///
/// [bottomBarSpace]：true 时预留「悬浮 TabBar + PlayBar」高度
/// （tab 高 56 + playbar 64 + 余量 28），对应原型 `.page-container` 底部 padding。
class AppPage extends StatefulWidget {
  final Widget child;
  final bool bottomBarSpace;

  /// 覆盖默认内边距（默认 LTRB(20,12,20,bottom)）。
  /// 需要内容通栏（如场景详情 Hero）时传 EdgeInsets.zero 自行控制。
  final EdgeInsetsGeometry? padding;

  const AppPage({
    required this.child,
    this.bottomBarSpace = false,
    this.padding,
    super.key,
  });

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
    value: 0,
  );

  bool _reducedMotion() {
    try {
      return WidgetsBinding
          .instance.platformDispatcher.accessibilityFeatures.disableAnimations;
    } catch (_) {
      return MediaQuery.of(context).disableAnimations;
    }
  }

  @override
  void initState() {
    super.initState();
    // 延后到首帧后再启动动画：initState 阶段外层路由的 TickerMode 可能尚未激活，
    // 若在此处 forward() 且 ticker 被静音后未能恢复（部分嵌入式/OHOS 引擎），
    // 控制器会停在 0。
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
    final bottomPad = widget.bottomBarSpace ? kTabHeight + kPlayBarHeight + 28.0 : 28.0;
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 220,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0, 0.7, 1],
                  colors: [c.bgGrad, c.bg, c.bg.withOpacity(0)],
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: FadeTransition(
            // 底值 0.3：即使 ticker 卡住导致控制器停在 0，页面也已可见。
            opacity: Tween<double>(begin: 0.3, end: 1.0).animate(_controller),
            child: SlideTransition(
              position: slide,
              child: Padding(
                padding: widget.padding ??
                    EdgeInsets.fromLTRB(rx(40), rx(24), rx(40), bottomPad),
                child: widget.child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
