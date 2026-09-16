import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/custom_scene_service.dart';
import '../../services/stats_service.dart';
import '../../theme/theme_extension.dart';
import '../../theme/theme_tokens.dart';
import '../../utils/style_utils.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_page.dart';
import '../../widgets/app_section.dart';
import '../../widgets/nav_bar.dart';

/// 柱状图数据。
class _ChartBar {
  final String label;
  final int minutes;
  final double heightPercent;
  const _ChartBar(this.label, this.minutes, this.heightPercent);
}

/// 最爱场景数据。
class _TopScene {
  final String name;
  final String duration;
  final int percent;
  const _TopScene(this.name, this.duration, this.percent);
}

/// 使用数据（对照原型 `pages/stats/stats.vue`）：
/// 概览 + 本周趋势柱状图 + 最爱场景 Top3（金银铜）+ 累计成就，
/// 数据读 [StatsService] 与 [CustomSceneService]。
class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  static const List<String> _weekdayLabels =
      <String>['一', '二', '三', '四', '五', '六', '日'];

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    final stats = context.watch<StatsService>();
    final customScenes = context.watch<CustomSceneService>();

    // weekPlays 为「今天→前 6 天」，反转成「前 6 天→今天」从左到右展示；
    // 标签按真实星期（一~日）生成。
    final weekly = stats.weekPlays.reversed.toList();
    final today = DateTime.now();
    final bars = List<_ChartBar>.generate(
      weekly.length,
      (int i) {
        final day = today.subtract(Duration(days: weekly.length - 1 - i));
        final label = _weekdayLabels[day.weekday - 1];
        final max = weekly.fold<int>(1, (int m, int v) => v > m ? v : m);
        return _ChartBar(
          label,
          weekly[i],
          (weekly[i] / max * 100).clamp(4.0, 100.0),
        );
      },
    );

    return AppPage(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 28),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: NavBar(title: '使用数据'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('你的声音旅程',
                      style: TextStyle(fontSize: 13, color: c.text2)),
                  const SizedBox(height: 12),
                  _buildOverview(c, stats),
                  const SizedBox(height: 18),
                  const AppSectionTitle('本周使用趋势'),
                  _buildChart(c, bars),
                  const SizedBox(height: 18),
                  const AppSectionTitle('最爱场景 Top 3'),
                  ..._buildTopList(c, stats),
                  const SizedBox(height: 18),
                  const AppSectionTitle('累计成就'),
                  _buildAchieveGrid(c, stats, customScenes),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverview(AppColors c, StatsService stats) {
    Widget item(String num, String label, {bool accent = false}) {
      return Expanded(
        child: Column(
          children: [
            Text(num,
                style: TextStyle(
                    fontSize: accent ? 15 : 18,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    color: c.primary)),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(fontSize: 10.5, color: c.text2)),
          ],
        ),
      );
    }

    Widget sep() => Container(
        width: 0.5,
        height: 28,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        color: c.line);

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
      child: Row(
        children: [
          item('${stats.weekUsageDays}', '使用天数'),
          sep(),
          item(StatsService.formatMinutes(stats.weekTotalMinutes), '累计时长'),
          sep(),
          item(stats.favoriteSceneName.isEmpty ? '暂无' : stats.favoriteSceneName,
              '最爱场景',
              accent: true),
        ],
      ),
    );
  }

  Widget _buildChart(AppColors c, List<_ChartBar> bars) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 10),
      child: SizedBox(
        height: 120,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final bar in bars)
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: 12,
                          height: double.infinity,
                          child: FractionallySizedBox(
                            heightFactor: bar.heightPercent / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: <Color>[
                                    c.primary,
                                    c.primary.withOpacity(0.55)
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(bar.label,
                        style: TextStyle(
                            fontSize: 10, color: c.text2)),
                    const SizedBox(height: 2),
                    SizedBox(
                      height: 12,
                      child: bar.minutes > 0
                          ? Text('${bar.minutes}m',
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: c.primary))
                          : null,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTopList(AppColors c, StatsService stats) {
    final top = stats.topScenes;
    if (top.isEmpty) {
      return <Widget>[
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
          child: Center(
            child: Text('暂无播放记录',
                style: TextStyle(fontSize: 12.5, color: c.text2)),
          ),
        ),
      ];
    }
    final scenes = top
        .map((TopSceneStat s) => _TopScene(
              s.name,
              StatsService.formatMinutes(s.count),
              s.percent,
            ))
        .toList();
    final ranks = <List<Color>>[
      rankGoldColors,
      rankSilverColors,
      rankBronzeColors,
    ];
    return List<Widget>.generate(scenes.length, (int i) {
      final scene = scenes[i];
      final g = parseCssGradient(
          'linear-gradient(135deg,${rankColorHex(ranks[i][0])},${rankColorHex(ranks[i][1])})');
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: g == null
                      ? null
                      : LinearGradient(
                          begin: g.begin, end: g.end, colors: g.colors),
                  color: g == null ? c.primary : null,
                ),
                child: Center(
                  child: Text('${i + 1}',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: c.onCover)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(scene.name,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: c.text)),
                        ),
                        Text(scene.duration,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: c.text2)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: SizedBox(
                        height: 5,
                        width: double.infinity,
                        child: Stack(
                          children: [
                            Container(color: c.sunken),
                            FractionallySizedBox(
                              widthFactor: scene.percent / 100,
                              child: Container(color: c.primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('${scene.percent}%',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: c.text2)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAchieveGrid(
      AppColors c, StatsService stats, CustomSceneService customScenes) {
    Widget item(String icon, String num, String label) {
      return Expanded(
        child: AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: c.primarySoft,
                  shape: BoxShape.circle,
                ),
                child:
                    Center(child: AppIcon(name: icon, size: 22, color: c.primary)),
              ),
              const SizedBox(height: 6),
              Text(num,
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: c.text)),
              const SizedBox(height: 2),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, color: c.text2)),
            ],
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        item('clock', '${stats.totalMinutes}', '累计使用分钟'),
        const SizedBox(width: 8),
        item('mountain', '${stats.playCountsByScene.length}', '探索场景'),
        const SizedBox(width: 8),
        item('mixer', '${customScenes.scenes.length}', '自定义场景'),
      ],
    );
  }
}

/// Color → '#RRGGBB'（用于复用原型的 rank 渐变字符串路径）。
String rankColorHex(Color color) {
  String p(int v) => v.toRadixString(16).padLeft(2, '0');
  return '#${p(color.red)}${p(color.green)}${p(color.blue)}';
}
