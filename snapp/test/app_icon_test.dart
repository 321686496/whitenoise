import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:snapp/data/seed_data.dart';
import 'package:snapp/widgets/app_icon.dart';
import 'package:snapp/widgets/app_svg_icons.dart';

void main() {
  test('all referenced icon names are registered', () {
    for (final n in ['wave', 'play', 'moon', 'rain', 'coffee', 'user']) {
      expect(hasAppIcon(n), isTrue, reason: 'missing icon $n');
    }
  });

  test('every seed-data iconName is registered', () {
    // 场景（Scene.iconName）
    for (final s in homeScenes) {
      expect(hasAppIcon(s.iconName), isTrue,
          reason: 'scene ${s.id} missing icon ${s.iconName}');
    }
    // 发现页推荐场景（FeaturedScene.iconName）
    for (final s in featuredScenes) {
      expect(hasAppIcon(s.iconName), isTrue,
          reason: 'featuredScene ${s.id} missing icon ${s.iconName}');
    }
    // 声音库（Sound.iconName）
    for (final s in sounds) {
      expect(hasAppIcon(s.iconName), isTrue,
          reason: 'sound ${s.id} missing icon ${s.iconName}');
    }
    // 精选声音（组合，取 .sound.iconName）
    for (final f in featuredSounds) {
      expect(hasAppIcon(f.sound.iconName), isTrue,
          reason: 'featuredSound ${f.sound.id} missing icon ${f.sound.iconName}');
    }
    // 声音分类（SoundCategoryItem.icon）
    for (final c in soundCategories) {
      expect(hasAppIcon(c.icon), isTrue,
          reason: 'soundCategory ${c.key} missing icon ${c.icon}');
    }
  });

  test('appIconBodies contains 37 icons plus a default fallback', () {
    expect(appIconBodies.length, 38);
    expect(appIconBodies.containsKey('__default__'), isTrue);
  });

  test('appIconBody builds non-empty svg string for a known icon', () {
    final body = appIconBody('wave');
    expect(body, isNotEmpty);
    expect(body.contains('currentColor'), isFalse);
  });

  testWidgets('AppIcon renders default circle for unknown name',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppIcon(name: '__nope__'),
        ),
      ),
    );
    expect(find.byType(AppIcon), findsOneWidget);
  });
}