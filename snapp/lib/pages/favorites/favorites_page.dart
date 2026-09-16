import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/scene_models.dart';
import '../../services/favorites_service.dart';
import '../../services/player_service.dart';
import '../../services/scene_service.dart';
import '../../theme/theme_extension.dart';
import '../../utils/style_utils.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_page.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/pressable.dart';

/// 收藏声音条目（对照原型 `FavSound`）。
class _FavSound {
  final String id;
  final String name;
  final String iconName;
  final String color;
  const _FavSound(this.id, this.name, this.iconName, this.color);
}

/// 我的收藏（对照原型 `pages/favorites/favorites.vue`）：
/// 分段 tab（收藏场景 / 收藏声音）+ 列表 + 空态。
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  String _activeTab = 'scenes';

  static const List<_FavSound> _favSounds = <_FavSound>[
    _FavSound('fv1', '雨声', 'rain', '#7E93A8'),
    _FavSound('fv2', '白噪音', 'white-noise', '#8296A8'),
    _FavSound('fv3', '森林', 'forest', '#7E9A74'),
    _FavSound('fv4', '篝火', 'fire', '#B97A48'),
    _FavSound('fv5', '海浪', 'wave-ocean', '#5F8296'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    return AppPage(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 8, 2, 4),
              child: Text('我的收藏',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      color: c.text)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Text('你珍藏的声音',
                  style: TextStyle(fontSize: 13, color: c.text2)),
            ),
            const SizedBox(height: 14),
            _buildTabs(c),
            const SizedBox(height: 16),
            if (_activeTab == 'scenes')
              _buildScenes(c)
            else
              _buildSounds(c),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(AppColors c) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          _tab(c, 'scenes', '收藏场景'),
          _tab(c, 'sounds', '收藏声音'),
        ],
      ),
    );
  }

  Widget _tab(AppColors c, String key, String label) {
    final active = _activeTab == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = key),
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 33,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? c.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: active ? c.shadow1 : null,
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  color: active ? c.primary : c.text2)),
        ),
      ),
    );
  }

  Widget _buildScenes(AppColors c) {
    final fav = context.watch<FavoritesService>();
    final player = context.read<PlayerService>();
    // 收藏 ID → 场景解析（找不到的回退过滤），保持收藏顺序
    final scenes = <Scene>[];
    final seen = <String>{};
    for (final id in fav.ids) {
      if (seen.contains(id)) continue;
      seen.add(id);
      final s = findScene(id);
      if (s != null && !scenes.contains(s)) scenes.add(s);
    }
    if (scenes.isEmpty) {
      return _empty(c, '还没有收藏场景', '在场景详情或播放卡中点收藏，喜欢的场景会出现在这里');
    }
    return Column(
      children: [
        for (var i = 0; i < scenes.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AppCard(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  _SceneCoverMini(gradient: scenes[i].gradient),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(scenes[i].name,
                            style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: c.text)),
                        const SizedBox(height: 3),
                        Text('${scenes[i].soundIds.length} 个声音',
                            style: TextStyle(
                                fontSize: 11, color: c.text2)),
                      ],
                    ),
                  ),
                  _ActionCircle(
                    icon: AppIcon(name: 'play', size: 18, color: c.primary),
                    onTap: () {
                      player.applyScene(scenes[i]);
                      showAppToast(context, '播放「${scenes[i].name}」');
                    },
                  ),
                  const SizedBox(width: 6),
                  _ActionCircle(
                    icon: AppIcon(name: 'close', size: 18, color: c.text2),
                    onTap: () {
                      fav.toggle(scenes[i].id);
                      showAppToast(context, '已取消收藏');
                    },
                  ),
                ],
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Center(
            child: Text('共 ${scenes.length} 个收藏',
                style: TextStyle(fontSize: 11, color: c.text3)),
          ),
        ),
      ],
    );
  }

  Widget _buildSounds(AppColors c) {
    if (_favSounds.isEmpty) return _empty(c, '还没有收藏声音', '在声音库中收藏你喜欢的声音');
    final rows = <Widget>[];
    for (var i = 0; i < _favSounds.length; i += 3) {
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var j = 0; j < 3; j++) ...[
            if (j > 0) const SizedBox(width: 8),
            Expanded(
              child: i + j < _favSounds.length
                  ? _FavSoundCard(
                      sound: _favSounds[i + j],
                      onTap: () => showAppToast(
                          context, '已添加「${_favSounds[i + j].name}」到混音'),
                    )
                  : const SizedBox(),
            ),
          ],
        ],
      ));
      rows.add(const SizedBox(height: 8));
    }
    return Column(children: rows);
  }

  Widget _empty(AppColors c, String title, String hint) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
      child: Column(
        children: [
          AppIcon(name: 'wave', size: 56, color: c.primarySoft),
          const SizedBox(height: 8),
          Text(title,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: c.text)),
          const SizedBox(height: 4),
          Text(hint,
              style: TextStyle(fontSize: 11.5, color: c.text2)),
        ],
      ),
    );
  }
}

class _SceneCoverMini extends StatelessWidget {
  final String gradient;
  const _SceneCoverMini({required this.gradient});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    final g = parseCssGradient(gradient);
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: g == null
            ? null
            : LinearGradient(begin: g.begin, end: g.end, colors: g.colors),
        color: g == null ? c.primary : null,
      ),
    );
  }
}

class _ActionCircle extends StatelessWidget {
  final Widget icon;
  final VoidCallback onTap;
  const _ActionCircle({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    return PressableScale(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: c.surface2,
          shape: BoxShape.circle,
        ),
        child: Center(child: icon),
      ),
    );
  }
}

class _FavSoundCard extends StatelessWidget {
  final _FavSound sound;
  final VoidCallback onTap;
  const _FavSoundCard({required this.sound, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    final asset = hexToColor(sound.color) ?? c.primary;
    return PressableScale(
      onTap: onTap,
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Column(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: asset.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                  child:
                      AppIcon(name: sound.iconName, size: 26, color: c.primary)),
            ),
            const SizedBox(height: 6),
            Text(sound.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: c.text)),
          ],
        ),
      ),
    );
  }
}
