import 'package:shared_preferences/shared_preferences.dart';

/// 主题偏好持久化（复用本地 storage key `shengqi-theme`，与原型保持一致）。
class ThemePrefs {
  static const String _key = 'shengqi-theme';

  /// 读取已保存的方案与风格；未保存的键不进入返回 Map。
  static Future<Map<String, String>> read() async {
    final p = await SharedPreferences.getInstance();
    final scheme = p.getString('$_key.scheme');
    final ui = p.getString('$_key.ui');
    return <String, String>{
      if (scheme != null) 'scheme': scheme,
      if (ui != null) 'ui': ui,
    };
  }

  static Future<void> write(String scheme, String ui) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('$_key.scheme', scheme);
    await p.setString('$_key.ui', ui);
  }
}