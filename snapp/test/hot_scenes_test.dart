import 'package:flutter_test/flutter_test.dart';
import 'package:snapp/data/seed_data.dart';

void main() {
  test('parsePlayCount parses 万/千/plain and falls back to 0', () {
    expect(parsePlayCount('12.6万'), 126000);
    expect(parsePlayCount('9.8千'), 9800);
    expect(parsePlayCount('5000'), 5000);
    expect(parsePlayCount('abc'), 0);
  });

  test('getHotScenes(all) returns count and sorts by playCount descending', () {
    final list = getHotScenes('all');
    expect(list.length, 8);
    expect(list.first.id, 'deep-sleep'); // 播放量 12.6万 最高
    for (var i = 1; i < list.length; i++) {
      expect(
        parsePlayCount(list[i - 1].playCount) >= parsePlayCount(list[i].playCount),
      isTrue,
        reason: '${list[i - 1].id} 应排在 ${list[i].id} 之前',
      );
    }
  });

  test('getHotScenes filters by category and excludes hero id', () {
    final focus = getHotScenes('focus');
    expect(focus.every((s) => featuredSceneCategory[s.id] == 'focus'), isTrue);
    expect(
      getHotScenes('all', excludeId: 'deep-sleep').any((s) => s.id == 'deep-sleep'),
      isFalse,
    );
  });
}