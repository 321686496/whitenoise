import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:snapp/widgets/app_icon.dart';
import 'package:snapp/widgets/app_svg_icons.dart';

void main() {
  test('all referenced icon names are registered', () {
    for (final n in ['wave', 'play', 'moon', 'rain', 'coffee', 'user']) {
      expect(hasAppIcon(n), isTrue, reason: 'missing icon $n');
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