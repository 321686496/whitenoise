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

/// 明暗模式（与原型 `ThemeMode` 对齐：auto 跟随系统）
enum AppThemeMode { auto, light, dark }

extension AppThemeModeX on AppThemeMode {
  String get key {
    if (this == AppThemeMode.light) return 'light';
    if (this == AppThemeMode.dark) return 'dark';
    return 'auto';
  }

  String get label {
    if (this == AppThemeMode.light) return '浅色';
    if (this == AppThemeMode.dark) return '深色';
    return '跟随系统';
  }
}

/// 由 key 解析 [UIStyle]，无法匹配时回退到 [UIStyle.flat]
UIStyle uiFromKey(String key) {
  for (final u in UIStyle.values) {
    if (u.key == key) return u;
  }
  return UIStyle.flat;
}

/// 由 key 解析 [AppThemeMode]，无法匹配时回退 [AppThemeMode.auto]
AppThemeMode themeModeFromKey(String key) {
  for (final m in AppThemeMode.values) {
    if (m.key == key) return m;
  }
  return AppThemeMode.auto;
}

/// 由配色 + 明暗构建整套 [ThemeData]（M3 关闭 + 扩展注入 AppColors / AppShapes）
ThemeData buildAppTheme(AppColors colors) {
  final brightness = colors.bg.computeLuminance() < 0.5
      ? Brightness.dark
      : Brightness.light;
  final base = ThemeData(
    useMaterial3: false,
    brightness: brightness,
    scaffoldBackgroundColor: colors.bg,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      secondary: colors.accent,
      onSecondary: colors.onPrimary,
      surface: colors.surface,
      onSurface: colors.text,
      background: colors.bg,
      onBackground: colors.text,
      error: colors.danger,
      onError: colors.onPrimary,
    ),
  );
  return base.copyWith(
    extensions: <ThemeExtension<dynamic>>[
      colors,
      AppShapes(
        cardRadius: 22,
        cardShadow: colors.shadow2,
        cardBlur: colors.blur,
      ),
    ],
    textTheme: base.textTheme.apply(bodyColor: colors.text, displayColor: colors.text),
  );
}
