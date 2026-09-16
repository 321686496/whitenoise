import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/achievement_service.dart';
import '../../theme/theme_extension.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_page.dart';
import '../../widgets/app_section.dart';
import '../../widgets/nav_bar.dart';

/// 成就墙（对照原型 `pages/achievement/achievement.vue`）：
/// 达成概览 + 最近获得 + 全部成就进度列表，数据读 [AchievementService]。
class AchievementPage extends StatelessWidget {
  const AchievementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    final achievement = context.watch<AchievementService>();
    final unlockedCount = achievement.unlockedCount;
    final total = achievement.total;
    final progressPercent = achievement.progressPercent;
    return AppPage(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 28),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: NavBar(title: '成就墙'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('记录你的每一次专注与放松',
                      style: TextStyle(fontSize: 13, color: c.text2)),
                  const SizedBox(height: 12),
                  _buildOverview(c, unlockedCount, total, progressPercent),
                  const SizedBox(height: 18),
                  const AppSectionTitle('最近获得'),
                  ..._recentGrid(c, achievement),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const AppSectionTitle('全部成就'),
                        const Spacer(),
                        Text('$unlockedCount / $total',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: c.primary)),
                      ],
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: SizedBox(
                      height: 6,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          Container(color: c.sunken),
                          FractionallySizedBox(
                            widthFactor: progressPercent / 100,
                            child: Container(color: c.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ..._allList(c, achievement),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverview(
      AppColors c, int unlockedCount, int total, int progressPercent) {
    Widget item(String num, String label, {bool accent = false}) {
      return Expanded(
        child: Column(
          children: [
            Text(num,
                style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: accent ? c.success : c.primary)),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(fontSize: 10.5, color: c.text2)),
          ],
        ),
      );
    }

    Widget sep() => Container(
        width: 0.5, height: 28, margin: const EdgeInsets.symmetric(horizontal: 4), color: c.line);

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
      child: Row(
        children: [
          item('$unlockedCount', '已解锁'),
          sep(),
          item('$total', '全部成就'),
          sep(),
          item('$progressPercent%', '完成度', accent: true),
        ],
      ),
    );
  }

  List<Widget> _recentGrid(AppColors c, AchievementService achievement) {
    final recent = achievement.unlockedItems.take(3).toList();
    final rows = <Widget>[];
    for (var i = 0; i < recent.length; i += 3) {
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var j = 0; j < 3; j++) ...[
            if (j > 0) const SizedBox(width: 8),
            Expanded(
              child: i + j < recent.length
                  ? _AchievementCard(ach: recent[i + j], c: c)
                  : const SizedBox(),
            ),
          ],
        ],
      ));
      rows.add(const SizedBox(height: 8));
    }
    return rows;
  }

  List<Widget> _allList(AppColors c, AchievementService achievement) {
    return achievement.items.map((Achievement ach) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: ach.unlocked ? c.primarySoft : c.surface2,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: AppIcon(
                    name: ach.unlocked ? ach.iconName : 'lock',
                    size: ach.unlocked ? 24 : 20,
                    color: ach.unlocked ? c.primary : c.text3,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ach.name,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ach.unlocked ? c.text : c.text2)),
                    const SizedBox(height: 2),
                    Text(ach.desc,
                        style: TextStyle(fontSize: 11, color: c.text2)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ach.unlocked ? c.success.withOpacity(0.13) : c.surface2,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppIcon(
                        name: ach.unlocked ? 'check' : 'lock',
                        size: 14,
                        color: ach.unlocked ? c.success : c.text3),
                    const SizedBox(width: 3),
                    Text(ach.unlocked ? '已解锁' : '未解锁',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: ach.unlocked ? c.success : c.text3)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement ach;
  final AppColors c;
  const _AchievementCard({required this.ach, required this.c});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: c.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Center(
                child: AppIcon(name: ach.iconName, size: 32, color: c.primary)),
          ),
          const SizedBox(height: 6),
          Text(ach.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: c.text)),
          const SizedBox(height: 2),
          Text(ach.desc,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: c.text2)),
          const SizedBox(height: 3),
          Text(ach.date ?? '',
              style: TextStyle(fontSize: 9.5, color: c.text3)),
        ],
      ),
    );
  }
}
