import 'package:flutter/material.dart';

import '../theme/theme_extension.dart';

/// 轻提示（对应原型 `uni.showToast({ icon: 'none' })`）。
///
/// 深色胶囊 + 白字，居中偏下浮现，1.8s 自动消失；颜色走主题 token。
void showAppToast(BuildContext context, String message) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (BuildContext ctx) =>
        _ToastView(message: message, onDone: () => entry.remove()),
  );
  overlay.insert(entry);
}

class _ToastView extends StatefulWidget {
  final String message;
  final VoidCallback onDone;
  const _ToastView({required this.message, required this.onDone});

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _visible = true);
    });
    Future<void>.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() => _visible = false);
      Future<void>.delayed(const Duration(milliseconds: 220), widget.onDone);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    return Positioned.fill(
      child: IgnorePointer(
        child: Align(
          alignment: const Alignment(0, 0.72),
          child: AnimatedOpacity(
            opacity: _visible ? 1 : 0,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              constraints: const BoxConstraints(minHeight: 40),
              decoration: BoxDecoration(
                color: c.overlay,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: c.onCover, height: 1.4),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
