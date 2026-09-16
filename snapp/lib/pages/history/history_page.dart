import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/seed_data.dart';
import '../../data/sound_models.dart';
import '../../services/player_service.dart';
import '../../services/scene_service.dart';
import '../../theme/theme_extension.dart';
import '../../utils/style_utils.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_page.dart';
import '../../widgets/app_section.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/pressable.dart';

/// 历史条目中的声音小图标。
class _HistorySound {
  final String id;
  final String iconName;
  final String color;
  const _HistorySound(this.id, this.iconName, this.color);
}

/// 历史条目。
class _HistoryItem {
  final String id;
  final String time;
  final String sceneName;
  final int duration;
  final List<_HistorySound> sounds;
  const _HistoryItem(
      this.id, this.time, this.sceneName, this.duration, this.sounds);
}

/// 按日期分组的历史。
class _HistoryGroup {
  final String date;
  final List<_HistoryItem> items;
  const _HistoryGroup(this.date, this.items);
}

/// 播放历史（对照原型 `pages/history/history.vue`）：
/// 按日期分组的历史卡 + 重播 + 清空历史确认。
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  /// 由最近播放记录派生分组（今天 / 昨天 / M月d日，新→旧）。
  List<_HistoryGroup> _groupsFrom(List<RecentItem> recent) {
    final labels = <String>[];
    final itemsByLabel = <String, List<_HistoryItem>>{};
    final now = DateTime.now();
    final todayKey = _dateKey(now);
    final yesterdayKey = _dateKey(now.subtract(const Duration(days: 1)));
    for (final r in recent) {
      final dt = DateTime.fromMillisecondsSinceEpoch(r.ts);
      final dayKey = _dateKey(dt);
      final String label;
      if (dayKey == todayKey) {
        label = '今天';
      } else if (dayKey == yesterdayKey) {
        label = '昨天';
      } else {
        label = '${dt.month}月${dt.day}日';
      }
      final scene = findScene(r.sceneId);
      final items = itemsByLabel.putIfAbsent(label, () {
        labels.add(label);
        return <_HistoryItem>[];
      });
      final time =
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      final soundIcons = scene.soundIds
          .map((String id) {
            for (final s in sounds) {
              if (s.id == id) return s;
            }
            return null;
          })
          .whereType<Sound>()
          .map((Sound s) => _HistorySound(s.id, s.iconName, s.color))
          .toList();
      items.add(_HistoryItem(
          r.sceneId, time, scene.name, scene.soundIds.length, soundIcons));
    }
    return labels
        .map((String l) => _HistoryGroup(l, itemsByLabel[l]!))
        .toList();
  }

  static String _dateKey(DateTime t) =>
      '${t.year.toString().padLeft(4, '0')}-'
      '${t.month.toString().padLeft(2, '0')}-'
      '${t.day.toString().padLeft(2, '0')}';

  Future<void> _clearHistory(PlayerService player) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        final c = Theme.of(ctx).appColors;
        return AlertDialog(
          backgroundColor: c.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Text('清空历史',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: c.text)),
          content: Text('确定要清空所有播放历史吗？此操作不可撤销。',
              style: TextStyle(fontSize: 13.5, color: c.text2)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('取消', style: TextStyle(color: c.text2)),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text('确定', style: TextStyle(color: c.danger)),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      if (!mounted) return;
      player.clearRecent();
      showAppToast(context, '历史已清空');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    final player = context.watch<PlayerService>();
    final groups = _groupsFrom(player.recent);
    final totalCount =
        groups.fold(0, (int sum, _HistoryGroup g) => sum + g.items.length);
    return AppPage(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 8, 2, 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('播放历史',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                                color: c.text)),
                        const SizedBox(height: 2),
                        Text('回顾你的声音足迹',
                            style:
                                TextStyle(fontSize: 13, color: c.text2)),
                      ],
                    ),
                  ),
                  if (totalCount > 0)
                    GestureDetector(
                      onTap: () => _clearHistory(player),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text('清空历史',
                            style: TextStyle(
                                fontSize: 12.5, color: c.danger)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            if (groups.isNotEmpty) ...[
              for (final group in groups) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 4),
                  child: Text(group.date,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                          color: c.text2)),
                ),
                AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      for (var i = 0; i < group.items.length; i++)
                        _HistoryRow(
                          item: group.items[i],
                          showDivider: i < group.items.length - 1,
                          onReplay: () {
                            player.applyScene(findScene(group.items[i].id));
                            showAppToast(context,
                                '正在播放「${group.items[i].sceneName}」');
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Center(
                  child: Text('共 $totalCount 条记录',
                      style: TextStyle(fontSize: 11, color: c.text3)),
                ),
              ),
            ] else
              AppCard(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 28),
                child: Column(
                  children: [
                    AppIcon(name: 'clock', size: 56, color: c.primarySoft),
                    const SizedBox(height: 8),
                    Text('还没有播放记录',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: c.text)),
                    const SizedBox(height: 4),
                    Text('开始你的第一次声音旅程吧',
                        style: TextStyle(fontSize: 11.5, color: c.text2)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final _HistoryItem item;
  final bool showDivider;
  final VoidCallback onReplay;
  const _HistoryRow({
    required this.item,
    required this.showDivider,
    required this.onReplay,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    return Column(
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 64),
          child: Row(
            children: [
              SizedBox(
                width: 42,
                child: Text(item.time,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: c.text2)),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.sceneName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: c.text)),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text('${item.duration} 分钟',
                            style: TextStyle(
                                fontSize: 10.5, color: c.text2)),
                        Container(
                          width: 2,
                          height: 2,
                          margin:
                              const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                              color: c.text3, shape: BoxShape.circle),
                        ),
                        Row(
                          children: [
                            for (var j = 0; j < item.sounds.length; j++)
                              Container(
                                width: 18,
                                height: 18,
                                margin: const EdgeInsets.only(right: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (hexToColor(item.sounds[j].color) ??
                                          c.primary)
                                      .withOpacity(0.15),
                                ),
                                child: Center(
                                  child: AppIcon(
                                      name: item.sounds[j].iconName,
                                      size: 12,
                                      color: hexToColor(
                                              item.sounds[j].color) ??
                                          c.primary),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PressableScale(
                onTap: onReplay,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: c.surface2,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                      child:
                          AppIcon(name: 'play', size: 18, color: c.primary)),
                ),
              ),
            ],
          ),
        ),
        if (showDivider) AppDivider(),
      ],
    );
  }
}
