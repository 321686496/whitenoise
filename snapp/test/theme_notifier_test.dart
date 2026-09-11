import 'package:flutter_test/flutter_test.dart';
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
}