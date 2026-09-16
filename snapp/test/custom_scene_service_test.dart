import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:snapp/data/scene_models.dart';
import 'package:snapp/services/custom_scene_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Scene makeScene(String id, {String name = '测试场景'}) => Scene(
        id: id,
        name: name,
        category: 'custom',
        desc: '自定义场景',
        iconName: 'rain',
        gradient: 'linear-gradient(135deg, #8E82A6, #6E6290)',
        image: '',
        soundIds: <String>['rain', 'campfire'],
        isPreset: false,
      );

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('add 持久化，重启后恢复', () async {
    final s = CustomSceneService();
    await s.load();
    expect(s.scenes, isEmpty);

    await s.add(makeScene('c1'));
    expect(s.scenes.length, 1);

    // 新实例（模拟重启）从存储恢复
    final restored = CustomSceneService();
    await restored.load();
    expect(restored.scenes.length, 1);
    expect(restored.scenes.first.id, 'c1');
    expect(restored.scenes.first.name, '测试场景');
    expect(restored.scenes.first.soundIds, <String>['rain', 'campfire']);
    expect(restored.scenes.first.isPreset, isFalse);
  });

  test('findById 命中与未命中', () async {
    final s = CustomSceneService();
    await s.load();
    await s.add(makeScene('c1'));
    expect(s.findById('c1')?.name, '测试场景');
    expect(s.findById('nope'), isNull);
  });

  test('update 更新已有场景并持久化', () async {
    final s = CustomSceneService();
    await s.load();
    await s.add(makeScene('c1'));
    await s.update(makeScene('c1', name: '改名后的场景'));
    expect(s.scenes.length, 1);
    expect(s.scenes.first.name, '改名后的场景');

    final restored = CustomSceneService();
    await restored.load();
    expect(restored.scenes.first.name, '改名后的场景');
  });

  test('delete 删除场景并持久化', () async {
    final s = CustomSceneService();
    await s.load();
    await s.add(makeScene('c1'));
    await s.add(makeScene('c2'));
    await s.delete('c1');
    expect(s.scenes.length, 1);
    expect(s.scenes.first.id, 'c2');

    final restored = CustomSceneService();
    await restored.load();
    expect(restored.scenes.length, 1);
    expect(restored.findById('c1'), isNull);
  });

  test('add / update / delete 触发 notifyListeners', () async {
    final s = CustomSceneService();
    await s.load();
    var notified = 0;
    s.addListener(() => notified++);

    await s.add(makeScene('c1'));
    expect(notified, 1);
    await s.update(makeScene('c1', name: 'x'));
    expect(notified, 2);
    await s.delete('c1');
    expect(notified, 3);
  });
}
