import 'package:flutter/material.dart';

/// 按压缩放反馈容器（对应原型各组件 `:active { transform: scale(.96) }`）。
class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  /// 按下时的缩放比例（原型统一 0.96）
  final double scale;

  const PressableScale({
    required this.child,
    this.onTap,
    this.scale = 0.96,
    super.key,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
