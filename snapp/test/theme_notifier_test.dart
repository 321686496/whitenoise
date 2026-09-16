import 'package:flutter_test/flutter_test.dart';
import 'package:snapp/app/theme_prefs.dart';
import 'package:snapp/theme/theme_notifier.dart';

void main() {
  test('default scheme/ui are morandi + flat', () {
    final n = ThemeNotifier();
    expect(n.schemeKey, 'morandi');
    expect(n.ui, UIStyle.flat);
  });

  test('setScheme updates and notifies', () {
    final n = ThemeNotifier();
    var notified = 0;
    n.addListener(() => notified++);
    n.setScheme('ocean');
    expect(n.schemeKey, 'ocean');
    expect(notified, 1);
  });

  test('ThemePrefs.read degrades to defaults when plugin is missing', () async {
    // 复现 OHOS：shared_preferences 无原生插件，方法通道抛 MissingPluginException。
    // 不安装 mock handler → getInstance 抛异常；固定后应优雅回退为空 Map，而非抛错。
    TestWidgetsFlutterBinding.ensureInitialized();
    final prefs = await ThemePrefs.read();
    expect(prefs, isEmpty);
  });

  test('ThemePrefs.write does not throw when plugin is missing', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await ThemePrefs.write('ocean', 'glass');
    // 不应抛出（写失败可被吞掉，避免 fire-and-forget 的未捕获异步异常）。
    expect(1, 1);
  });
}