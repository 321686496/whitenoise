import 'package:flutter/material.dart';

import '../theme/theme_extension.dart';

/// 主按钮（primary / onPrimary，胶囊圆角 26）。
class AppPrimaryButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  const AppPrimaryButton({required this.child, this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
      ),
      child: child,
    );
  }
}

/// 描边按钮（primary 文字 + 描边）。
class AppOutlineButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  const AppOutlineButton({required this.child, this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: c.primary,
        side: BorderSide(color: c.primary.withOpacity(0.6)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      ),
      child: child,
    );
  }
}