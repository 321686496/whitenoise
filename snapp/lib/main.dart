import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/theme_prefs.dart';
import 'theme/theme_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notifier = ThemeNotifier(persist: ThemePrefs.write);
  await notifier.loadFrom(ThemePrefs.read);
  runApp(Root(notifier: notifier));
}