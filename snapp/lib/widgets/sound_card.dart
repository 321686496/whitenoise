import 'package:flutter/material.dart';

import '../theme/theme_extension.dart';
import '../utils/style_utils.dart';
import 'app_card.dart';
import 'app_icon.dart';

/// 声音卡片（对应原型 `components/SoundCard.vue`）：
/// 圆形色底图标（资产色 16% × 表面色）+ 名称 + 选中角标 + 类型。
class SoundCard extends StatelessWidget {
  final String name;
  final String type;
  final String iconName;
  final String color;
  final bool isActive;
  final VoidCallback onTap;

  const SoundCard({
    required this.name,
    required this.type,
    required this.iconName,
    required this.color,
    required this.isActive,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    final assetColor = hexToColor(color) ?? c.primary;
    final iconBg = colorMix(assetColor, 16, c.surface);
    return AppCard(
      onTap: onTap,
      radius: 13,
      color: isActive ? c.primarySoft : null,
      border: Border.all(
        color: isActive ? c.primary.withOpacity(0.7) : c.line,
        width: 0.5,
      ),
      padding: const EdgeInsets.fromLTRB(9, 13, 9, 11),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: AppIcon(name: iconName, size: 30, color: assetColor),
          ),
          const SizedBox(height: 7),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.15,
                    color: c.text,
                  ),
                ),
              ),
              if (isActive) ...[
                const SizedBox(width: 3),
                Container(
                  width: 13,
                  height: 13,
                  decoration: BoxDecoration(color: c.primary, shape: BoxShape.circle),
                  child: AppIcon(name: 'check', size: 9, color: c.onPrimary, stroke: 3),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(type, style: TextStyle(fontSize: 10.5, color: c.text3)),
        ],
      ),
    );
  }
}
