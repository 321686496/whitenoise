import 'package:flutter/material.dart';

import 'theme_extension.dart';

/// UI 风格（与 `prototype/src/theme/index.ts` 的 `UiMode` 对齐）
enum UIStyle { flat, glass, neu }

extension UIStyleX on UIStyle {
  String get key {
    if (this == UIStyle.glass) return 'glass';
    if (this == UIStyle.neu) return 'neu';
    return 'flat';
  }

  String get label {
    if (this == UIStyle.glass) return '玻璃拟态';
    if (this == UIStyle.neu) return '新拟态';
    return '扁平化';
  }

  String get desc {
    if (this == UIStyle.glass) return '通透 / 高级感';
    if (this == UIStyle.neu) return '柔和 / 立体';
    return '清爽 / 低干扰';
  }
}

/// 由 key 解析 [UIStyle]，无法匹配时回退到 [UIStyle.flat]
UIStyle uiFromKey(String key) {
  for (final u in UIStyle.values) {
    if (u.key == key) return u;
  }
  return UIStyle.flat;
}

/// 由配色构建整套 [ThemeData]（M3 关闭 + 扩展注入 AppColors / AppShapes）
ThemeData buildAppTheme(AppColors colors) {
  final base = ThemeData(
    useMaterial3: false,
    scaffoldBackgroundColor: colors.bg,
    colorScheme: ColorScheme.light(
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      secondary: colors.accent,
      surface: colors.cardBg,
      onSurface: colors.text,
      error: colors.danger,
    ),
  );
  return base.copyWith(
    extensions: <ThemeExtension<dynamic>>[
      colors,
      AppShapes(
        cardRadius: 14,
        cardShadow: colors.cardShadow,
        cardBlur: colors.cardBlur,
      ),
    ],
    textTheme: base.textTheme.apply(bodyColor: colors.text, displayColor: colors.text),
  );
}