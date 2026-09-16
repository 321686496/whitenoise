import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snapp/services/favorites_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('toggle adds and removes with persistence round-trip', () async {
    final s = FavoritesService();
    await s.load();
    expect(s.isFav('deep-sleep'), isFalse);

    await s.toggle('deep-sleep');
    expect(s.isFav('deep-sleep'), isTrue);

    // 新实例从存储恢复，验证持久化生效
    final s2 = FavoritesService();
    await s2.load();
    expect(s2.isFav('deep-sleep'), isTrue);

    await s2.toggle('deep-sleep');
    expect(s2.isFav('deep-sleep'), isFalse);
    final s3 = FavoritesService();
    await s3.load();
    expect(s3.isFav('deep-sleep'), isFalse);
  });

  test('toggle notifies listeners', () async {
    final s = FavoritesService();
    await s.load();
    var notified = 0;
    s.addListener(() => notified++);
    await s.toggle('ocean-waves');
    expect(notified, 1);
    await s.toggle('ocean-waves');
    expect(notified, 2);
  });
}
