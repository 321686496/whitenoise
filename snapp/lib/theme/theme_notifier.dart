import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../services/app_storage.dart';
import 'app_theme.dart';
import 'theme_tokens.dart';

export 'app_theme.dart'
    show AppThemeMode, AppThemeModeX, UIStyle, UIStyleX, themeModeFromKey;

/// 主题状态：配色方案 × UI 风格 × 明暗 的运行时 Notifier。
///
/// `mode == auto` 时跟随系统明暗（监听 platformDispatcher），可通过 [loadFrom]
/// 从持久化恢复，或经 [setScheme] / [setUi] / [setMode] 即时切换并通知监听者。
/// 切换后通过可注入的 [persist] 写器持久化（fire-and-forget）。
/// 同时记录「访问过的配色方案」[visitedSchemes]（成就「审美家」数据源，
/// 持久化 `shengqi-theme-visits`）。
class ThemeNotifier extends ChangeNotifier {
  ThemeNotifier({Future<void> Function(String scheme, String ui, String mode)? persist})
      : _persist = persist {
    _systemBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged = () {
      _systemBrightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      if (mode == AppThemeMode.auto) {
        notifyListeners();
      }
    };
  }

  final Future<void> Function(String scheme, String ui, String mode)? _persist;

  Brightness _systemBrightness = Brightness.light;

  String schemeKey = schemeMorandi;
  UIStyle ui = UIStyle.flat;
  AppThemeMode mode = AppThemeMode.auto;

  /// 曾切换过的配色方案 key 集合（含默认方案），持久化 key `shengqi-theme-visits`。
  final Set<String> visitedSchemes = <String>{schemeMorandi};

  /// 最终生效的明暗（auto → 系统明暗）
  Brightness get resolvedBrightness {
    if (mode == AppThemeMode.dark) return Brightness.dark;
    if (mode == AppThemeMode.light) return Brightness.light;
    return _systemBrightness;
  }

  /// 从持久化读取器恢复方案 / 风格 / 明暗（缺省键保持默认）。
  Future<void> loadFrom(Future<Map<String, String>> Function() reader) async {
    final data = await reader();
    if (data.containsKey('scheme')) {
      schemeKey = data['scheme']!;
    }
    if (data.containsKey('ui')) {
      ui = uiFromKey(data['ui']!);
    }
    if (data.containsKey('mode')) {
      mode = themeModeFromKey(data['mode']!);
    }
    visitedSchemes.add(schemeKey);
    await _loadVisits();
    notifyListeners();
  }

  Future<void> _loadVisits() async {
    final list = await AppStorage.readJsonList(AppStorage.keyThemeVisits);
    if (list == null) return;
    visitedSchemes.addAll(list
        .whereType<Map<dynamic, dynamic>>()
        .map((Map<dynamic, dynamic> j) => (j['key'] as String?) ?? '')
        .where((String k) => k.isNotEmpty));
  }

  void _persistVisits() {
    unawaited(AppStorage.writeJsonList(
      AppStorage.keyThemeVisits,
      visitedSchemes.map((String s) => <String, dynamic>{'key': s}).toList(),
    ));
  }

  void setScheme(String key) {
    if (key == schemeKey) return;
    schemeKey = key;
    visitedSchemes.add(key);
    _persistVisits();
    notifyListeners();
    _persistNow();
  }

  void setUi(UIStyle style) {
    if (style == ui) return;
    ui = style;
    notifyListeners();
    _persistNow();
  }

  void setMode(AppThemeMode m) {
    if (m == mode) return;
    mode = m;
    notifyListeners();
    _persistNow();
  }

  void _persistNow() {
    unawaited(_persist?.call(schemeKey, ui.key, mode.key));
  }
}
