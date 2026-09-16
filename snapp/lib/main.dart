import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/theme_prefs.dart';
import 'services/checkin_service.dart';
import 'services/favorites_service.dart';
import 'services/player_service.dart';
import 'theme/theme_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notifier = ThemeNotifier(persist: ThemePrefs.write);
  await notifier.loadFrom(ThemePrefs.read);
  // 播放服务单例：main 创建一次并恢复最近播放，Provider 以 .value 注入同一实例，
  // 避免冷启动时 Provider 另建实例导致最近播放为空（存储不可用时静默降级）。
  final player = PlayerService();
  await player.loadRecent();
  final favorites = FavoritesService();
  await favorites.load();
  final checkin = CheckinService();
  await checkin.load();
  runApp(Root(
      notifier: notifier,
      player: player,
      favorites: favorites,
      checkin: checkin));
}
