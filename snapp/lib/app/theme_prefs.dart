import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 主题偏好持久化（复用本地 storage key `shengqi-theme`，与原型保持一致）。
class ThemePrefs {
  static const String _key = 'shengqi-theme';

  /// 读取已保存的方案 / 风格 / 明暗；未保存的键不进入返回 Map。
  ///
  /// 平台插件缺失（如 OHOS 端 shared_preferences 无原生实现）时优雅降级：
  /// 返回空 Map（走默认主题），避免启动阶段 `await` 抛 MissingPluginException 导致白屏。
  static Future<Map<String, String>> read() async {
    final SharedPreferences p;
    try {
      p = await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('ThemePrefs.read: shared_preferences unavailable, use defaults: $e');
      return <String, String>{};
    }
    return <String, String>{
      'scheme': p.getString('$_key.scheme') ?? '',
      'ui': p.getString('$_key.ui') ?? '',
      'mode': p.getString('$_key.mode') ?? '',
    }..removeWhere((String k, String v) => v.isEmpty);
  }

  static Future<void> write(String scheme, String ui, String mode) async {
    final SharedPreferences p;
    try {
      p = await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('ThemePrefs.write: shared_preferences unavailable, skip persist: $e');
      return;
    }
    await p.setString('$_key.scheme', scheme);
    await p.setString('$_key.ui', ui);
    await p.setString('$_key.mode', mode);
  }
}
