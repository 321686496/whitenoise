import 'package:flutter_test/flutter_test.dart';
import 'package:snapp/services/scene_service.dart';

void main() {
  test('findScene resolves existing scene and falls back', () {
    // first scene in homeScenes is deep-sleep with name 深度睡眠
    expect(findScene('deep-sleep')!.name, '深度睡眠');
    expect(findScene('nope')!.name, isNotEmpty); // 回退 homeScenes[0]
  });

  test('getRecommended prioritizes pref categories then fills by order', () {
    final rec = getRecommended(['sleep', 'nature'], []);
    expect(rec.length, 4);
    expect(rec.first.category, anyOf('sleep', 'nature'));
  });

  test('getCategoryScenes filters by category', () {
    final f = getCategoryScenes('focus', 10);
    expect(f.every((s) => s.category == 'focus'), isTrue);
  });

  test('buildRecipe sums to 100', () {
    final r = buildRecipe(findScene('deep-sleep')!);
    final sum = r.fold<int>(0, (a, b) => a + b.percent);
    expect(sum, 100);
  });

  test('buildPresets yields 轻度/标准/深度 with sums 100', () {
    final p = buildPresets(findScene('deep-sleep')!);
    expect(p.map((x) => x.name), containsAll(['轻度', '标准', '深度']));
    for (final op in p) {
      expect(op.ratios.fold<int>(0, (a, b) => a + b.value), 100);
    }
  });
}