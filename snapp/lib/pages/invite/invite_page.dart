import 'package:flutter/material.dart';

import '../../theme/theme_extension.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_page.dart';
import '../../widgets/app_section.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/nav_bar.dart';
import '../../widgets/pressable.dart';

/// 邀请权益条目。
class _Benefit {
  final String id;
  final String name;
  final String condition;
  final bool unlocked;
  const _Benefit(this.id, this.name, this.condition, this.unlocked);
}

/// 邀请记录条目。
class _InviteHistory {
  final String id;
  final String name;
  final String date;
  const _InviteHistory(this.id, this.name, this.date);
}

/// 邀请好友（对照原型 `pages/invite/invite.vue`）：
/// 邀请码卡 + 邀请进度 + 权益列表 + 邀请记录。
class InvitePage extends StatelessWidget {
  const InvitePage({super.key});

  static const int _inviteCount = 2;
  static const int _target = 10;

  static const List<_Benefit> _benefits = <_Benefit>[
    _Benefit('b1', '薰衣草配色', '邀请 1 人', true),
    _Benefit('b2', '场景上限 +5', '邀请 3 人', false),
    _Benefit('b3', '全部主题风格', '邀请 10 人', false),
  ];

  static const List<_InviteHistory> _history = <_InviteHistory>[
    _InviteHistory('h1', '小明', '2026-08-17'),
    _InviteHistory('h2', '小红', '2026-08-15'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    final progressPercent = _inviteCount / _target * 100;
    const rewards = <int, String>{
      1: '解锁 1 套配色',
      3: '场景上限 +5',
      10: '解锁全部主题',
    };

    return AppPage(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 28),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: NavBar(title: '邀请好友'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('邀请好友一起使用，解锁更多主题与场景',
                      style: TextStyle(fontSize: 13, color: c.text2)),
                  const SizedBox(height: 12),
                  _buildHero(context, c),
                  const SizedBox(height: 18),
                  const AppSectionTitle('邀请进度'),
                  _buildProgress(c, progressPercent, rewards),
                  const SizedBox(height: 18),
                  const AppSectionTitle('邀请权益'),
                  ..._buildBenefits(c),
                  const SizedBox(height: 18),
                  const AppSectionTitle('邀请记录'),
                  ..._buildHistory(c),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context, AppColors c) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: c.primarySoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
                child: AppIcon(name: 'gift', size: 32, color: c.primary)),
          ),
          const SizedBox(height: 9),
          Text('分享邀请码给好友',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700, color: c.text)),
          const SizedBox(height: 9),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: c.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('WN2024',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                        color: c.primary)),
              ),
              const SizedBox(width: 10),
              PressableScale(
                onTap: () => showAppToast(context, '邀请码已复制'),
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: c.line.opacity > 0.01
                        ? Border.all(color: c.line, width: 0.5)
                        : null,
                    boxShadow: c.shadow1,
                  ),
                  child: Row(
                    children: [
                      AppIcon(name: 'copy', size: 18, color: c.primary),
                      const SizedBox(width: 3),
                      Text('复制',
                          style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: c.primary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          PressableScale(
            onTap: () => showAppToast(context, '已生成分享卡片'),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: c.primary,
                borderRadius: BorderRadius.circular(999),
                boxShadow: c.shadow2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppIcon(name: 'share', size: 20, color: c.onPrimary),
                  const SizedBox(width: 6),
                  Text('分享邀请',
                      style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: c.onPrimary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(
      AppColors c, double progressPercent, Map<int, String> rewards) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('$_inviteCount',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: c.primary)),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: SizedBox(
                    height: 8,
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
              ),
              const SizedBox(width: 6),
              Text('/ $_target',
                  style: TextStyle(fontSize: 12, color: c.text3)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: rewards.keys.map((int count) {
              final unlocked = _inviteCount >= count;
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: unlocked ? c.primary : c.surface2,
                      ),
                      child: unlocked
                          ? Center(
                              child: AppIcon(
                                  name: 'check',
                                  size: 12,
                                  color: c.onPrimary))
                          : null,
                    ),
                    const SizedBox(height: 4),
                    Text(rewards[count]!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 9.5,
                            fontWeight:
                                unlocked ? FontWeight.w600 : FontWeight.w400,
                            color: unlocked ? c.primary : c.text2)),
                    Text('邀请 $count 人',
                        style: TextStyle(fontSize: 9, color: c.text3)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBenefits(AppColors c) {
    return _benefits.map((_Benefit benefit) {
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
                  color: benefit.unlocked ? c.primarySoft : c.surface2,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: AppIcon(
                      name: benefit.unlocked ? 'check' : 'lock',
                      size: 24,
                      color: benefit.unlocked ? c.primary : c.text3),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(benefit.name,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: benefit.unlocked ? c.text : c.text2)),
                    const SizedBox(height: 2),
                    Text(benefit.condition,
                        style: TextStyle(fontSize: 11, color: c.text2)),
                  ],
                ),
              ),
              Text(benefit.unlocked ? '已解锁' : '未解锁',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: benefit.unlocked ? c.primary : c.text3)),
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildHistory(AppColors c) {
    if (_history.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              AppIcon(name: 'user', size: 40, color: c.text3),
              const SizedBox(height: 6),
              Text('暂无邀请记录',
                  style: TextStyle(fontSize: 12, color: c.text2)),
            ],
          ),
        ),
      ];
    }
    return _history.map((_InviteHistory h) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: c.primarySoft,
                  shape: BoxShape.circle,
                ),
                child:
                    Center(child: AppIcon(name: 'user', size: 22, color: c.primary)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(h.name,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: c.text)),
                    const SizedBox(height: 2),
                    Text(h.date,
                        style: TextStyle(fontSize: 11, color: c.text2)),
                  ],
                ),
              ),
              Row(
                children: [
                  AppIcon(name: 'check', size: 14, color: c.primary),
                  const SizedBox(width: 3),
                  Text('已加入',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: c.primary)),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
