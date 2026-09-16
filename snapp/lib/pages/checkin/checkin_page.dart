import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/checkin_service.dart';
import '../../theme/theme_extension.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_page.dart';
import '../../widgets/app_section.dart';
import '../../widgets/nav_bar.dart';
import '../../widgets/pressable.dart';

/// 签到奖励模型（对照原型 `Reward`），解锁阈值 = 连续签到天数。
class _Reward {
  final String id;
  final String name;
  final String desc;
  final String iconName;
  final int thresholdDays;
  const _Reward(this.id, this.name, this.desc, this.iconName, this.thresholdDays);
}

/// 本周日历格（对照原型 `weekDays`）。
class _WeekDay {
  final String label;
  final int date;
  final bool checked;
  final bool isToday;
  final bool isFuture;
  const _WeekDay({
    required this.label,
    required this.date,
    required this.checked,
    required this.isToday,
    required this.isFuture,
  });
}

/// 每日签到（对照原型 `pages/checkin/checkin.vue`）：
/// 连续签到卡 + 本周签到日历 + 签到按钮 + 签到奖励列表。
/// 状态全部走 [CheckinService]（真实落库、连续天数真实计算）。
class CheckinPage extends StatefulWidget {
  const CheckinPage({super.key});

  @override
  State<CheckinPage> createState() => _CheckinPageState();
}

class _CheckinPageState extends State<CheckinPage> {
  static const int _nextRewardDays = 7;
  static const List<String> _labels = <String>['一', '二', '三', '四', '五', '六', '日'];

  bool _showSuccess = false;

  static const List<_Reward> _rewards = <_Reward>[
    _Reward('r1', '连续 3 天', '专属场景「清晨森林」', 'forest', 3),
    _Reward('r2', '连续 7 天', '专属场景「星空夜晚」', 'moon', 7),
    _Reward('r3', '连续 14 天', '专属场景「山间溪流」', 'stream', 14),
    _Reward('r4', '连续 30 天', '专属场景「深夜壁炉」', 'flame', 30),
  ];

  Future<void> _handleCheckin() async {
    final checkin = context.read<CheckinService>();
    if (checkin.checkedToday) return;
    await checkin.checkIn();
    if (!mounted) return;
    setState(() => _showSuccess = true);
    Timer(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => _showSuccess = false);
    });
  }

  /// 本周（周一至周日）日历数据，checked 取真实打卡集合。
  List<_WeekDay> _buildWeekDays(CheckinService checkin) {
    final today = DateTime.now();
    final todayKey = CheckinService.dateKey(today);
    final monday = today.subtract(Duration(days: today.weekday - 1));
    return List<_WeekDay>.generate(7, (int i) {
      final d = monday.add(Duration(days: i));
      final key = CheckinService.dateKey(d);
      return _WeekDay(
        label: '周${_labels[i]}',
        date: d.day,
        checked: checkin.dates.contains(key),
        isToday: key == todayKey,
        isFuture: d.isAfter(DateTime(today.year, today.month, today.day)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    final checkin = context.watch<CheckinService>();
    final streak = checkin.streak;
    final remainDays = (_nextRewardDays - streak) < 0 ? 0 : (_nextRewardDays - streak);

    return AppPage(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 28),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: NavBar(title: '每日签到'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('坚持使用，解锁专属奖励',
                      style: TextStyle(fontSize: 13, color: c.text2)),
                  const SizedBox(height: 12),
                  _buildStreakCard(c, streak, remainDays),
                  const SizedBox(height: 18),
                  const AppSectionTitle('本周签到'),
                  _buildCalendar(c, _buildWeekDays(checkin)),
                  const SizedBox(height: 18),
                  _buildCheckinButton(c, checkin.checkedToday),
                  const SizedBox(height: 18),
                  const AppSectionTitle('签到奖励'),
                  ..._buildRewards(c, streak),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(AppColors c, int streak, int remainDays) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('已连续签到',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500, color: c.text2)),
              const Spacer(),
              Text('$streak',
                  style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      height: 1,
                      color: c.primary)),
              const SizedBox(width: 3),
              Text('天',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: c.primary)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: AppDivider(),
          ),
          Row(
            children: [
              AppIcon(name: 'gift', size: 16, color: c.warning),
              const SizedBox(width: 4),
              Text('再坚持 ',
                  style: TextStyle(fontSize: 12, color: c.text2)),
              Text('$remainDays',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: c.warning)),
              Text(' 天解锁奖励',
                  style: TextStyle(fontSize: 12, color: c.text2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(AppColors c, List<_WeekDay> weekDays) {
    return Row(
      children: [
        for (var i = 0; i < weekDays.length; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            child: Column(
              children: [
                Text(weekDays[i].label,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: c.text2)),
                const SizedBox(height: 5),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: weekDays[i].checked
                        ? c.success
                        : (weekDays[i].isToday ? c.surface : c.surface2),
                    border: weekDays[i].isToday
                        ? Border.all(color: c.primary, width: 1.5)
                        : null,
                  ),
                  child: weekDays[i].checked
                      ? Center(
                          child: AppIcon(
                              name: 'check',
                              size: 18,
                              color: c.onPrimary))
                      : Center(
                          child: Opacity(
                            opacity: weekDays[i].isFuture ? 0.4 : 1,
                            child: Text('${weekDays[i].date}',
                                style: TextStyle(
                                    fontSize: 12, color: c.text)),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCheckinButton(AppColors c, bool checkedToday) {
    return Column(
      children: [
        PressableScale(
          onTap: _handleCheckin,
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: checkedToday ? c.success : c.primary,
              borderRadius: BorderRadius.circular(999),
              boxShadow: c.shadow2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppIcon(
                    name: checkedToday ? 'check' : 'trophy',
                    size: 32,
                    color: checkedToday ? c.onPrimary : c.primary),
                const SizedBox(width: 8),
                Text(checkedToday ? '已签到' : '签到',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: c.onPrimary)),
              ],
            ),
          ),
        ),
        if (_showSuccess)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppIcon(name: 'check', size: 14, color: c.success),
                const SizedBox(width: 4),
                Text('签到成功！',
                    style: TextStyle(fontSize: 12, color: c.success)),
              ],
            ),
          ),
      ],
    );
  }

  List<Widget> _buildRewards(AppColors c, int streak) {
    return _rewards.map((_Reward reward) {
      final unlocked = streak >= reward.thresholdDays;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: unlocked ? c.primarySoft : c.surface2,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: AppIcon(
                      name: unlocked ? reward.iconName : 'lock',
                      size: unlocked ? 22 : 18,
                      color: unlocked ? c.primary : c.text3),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reward.name,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: unlocked ? c.text : c.text2)),
                    const SizedBox(height: 2),
                    Text(reward.desc,
                        style: TextStyle(fontSize: 11, color: c.text2)),
                  ],
                ),
              ),
              AppIcon(
                  name: unlocked ? 'check' : 'lock',
                  size: 14,
                  color: unlocked ? c.success : c.text3),
              const SizedBox(width: 4),
              Text(unlocked ? '已解锁' : '未解锁',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: unlocked ? c.success : c.text3)),
            ],
          ),
        ),
      );
    }).toList();
  }
}
