import 'package:flutter/material.dart';

import '../theme/theme_extension.dart';
import 'app_icon.dart';
import 'pressable.dart';

/// 空态（对应原型 `components/EmptyState.vue`）。
class EmptyState extends StatelessWidget {
  final String icon;
  final String title;
  final String? desc;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyState({
    required this.title,
    this.icon = 'moon',
    this.desc,
    this.actionText,
    this.onAction,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: c.surface2,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: AppIcon(name: icon, size: 34, color: c.text3),
          ),
          const SizedBox(height: 16),
          Text(title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: c.text)),
          if (desc != null) ...[
            const SizedBox(height: 6),
            Text(
              desc!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, height: 1.5, color: c.text2),
            ),
          ],
          if (actionText != null) ...[
            const SizedBox(height: 20),
            PressableScale(
              onTap: onAction,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
                decoration: BoxDecoration(
                  color: c.primary,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: Theme.of(context).appShapes.cardShadow,
                ),
                child: Text(actionText!,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: c.onPrimary)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
