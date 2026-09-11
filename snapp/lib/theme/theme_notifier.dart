import 'dart:async';

import 'package:flutter/foundation.dart';

import 'app_theme.dart';
import 'theme_tokens.dart';

export 'app_theme.dart' show UIStyle;

/// 主题状态：配色方案 × UI 风格的运行时 Notifier。
///
/// 按控制器契约暴露 `schemeKey` + `ui`，可通过 [loadFrom] 从持久化恢复，
/// 或通过 [setScheme] / [setUi] 即时切换并通知监听者。
/// 切换后可通过可注入的 [persist] 写器将当前方案与风格持久化（fire-and-forget）。
class ThemeNotifier extends ChangeNotifier {
  ThemeNotifier({Future<void> Function(String scheme, String ui)? persist})
      : _persist = persist;

  final Future<void> Function(String scheme, String ui)? _persist;

  String schemeKey = schemeMorandi;
  UIStyle ui = UIStyle.flat;

  /// 从持久化读取器恢复已保存的方案与风格。
  /// 传入 `Future<Map<String, String>> Function()`（例如 `ThemePrefs.read`）。
  Future<void> loadFrom(Future<Map<String, String>> Function() reader) async {
    final data = await reader();
    if (data.containsKey('scheme')) {
      schemeKey = data['scheme']!;
    }
    if (data.containsKey('ui')) {
      ui = uiFromKey(data['ui']!);
    }
    notifyListeners();
  }

  void setScheme(String key) {
    if (key == schemeKey) return;
    schemeKey = key;
    notifyListeners();
    unawaited(_persist?.call(schemeKey, ui.key));
  }

  void setUi(UIStyle style) {
    if (style == ui) return;
    ui = style;
    notifyListeners();
    unawaited(_persist?.call(schemeKey, ui.key));
  }
}