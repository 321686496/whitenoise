import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/player_service.dart';
import '../theme/theme_extension.dart';
import 'app_toast.dart';
import 'app_card.dart';
import 'app_icon.dart';
import 'mix_track.dart';
import 'pressable.dart';

/// 底部悬浮主控条（对应原型 `components/PlayBar.vue`）。
///
/// 由外层 Shell 定位在 TabBar 之上；含睡眠定时面板与混音面板（互斥弹出）。
class PlayBar extends StatelessWidget {
  final VoidCallback? onSaveTap;

  const PlayBar({this.onSaveTap, super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerService>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (player.showTimerPanel) const _TimerPanel(),
        if (player.showMixPanel) const _MixPanel(),
        const SizedBox(height: 8),
        _PlayBarInner(onSaveTap: onSaveTap),
      ],
    );
  }
}

class _PlayBarInner extends StatelessWidget {
  final VoidCallback? onSaveTap;
  const _PlayBarInner({this.onSaveTap});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    final player = context.watch<PlayerService>();
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => player.setShowMixPanel(!player.showMixPanel),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: c.sunken,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset('assets/brand/logo.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Center(child: AppIcon(name: 'wave', size: 18, color: c.text3))),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _PlayBars(playing: player.isPlaying),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  player.currentScene?.name ?? '未选择场景',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.15,
                                    color: c.text,
                                  ),
                                ),
                              ),
                              if (player.timerMinutes > 0) ...[
                                const SizedBox(width: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: c.primarySoft,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(player.timerLabel,
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: c.primary)),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _BarAction(
              active: player.isLocked,
              icon: AppIcon(
                  name: 'lock',
                  size: 20,
                  color: player.isLocked ? c.primary : c.text3),
              onTap: () {
                player.toggleLock();
                showAppToast(context, player.isLocked ? '已锁定播放' : '已解锁');
              },
            ),
            _BarAction(
              active: player.showTimerPanel,
              icon: AppIcon(
                  name: 'timer',
                  size: 20,
                  color: player.timerMinutes > 0 ? c.primary : c.text3),
              onTap: () =>
                  player.setShowTimerPanel(!player.showTimerPanel),
            ),
            _MainPlayButton(),
            _BarAction(
              icon: AppIcon(name: 'save', size: 20, color: c.text3),
              onTap: onSaveTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _BarAction extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onTap;
  final bool active;
  const _BarAction({required this.icon, required this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    return PressableScale(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: active ? c.primarySoft : Colors.transparent,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: icon,
      ),
    );
  }
}

class _MainPlayButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    final player = context.watch<PlayerService>();
    return PressableScale(
      onTap: () {
        if (!player.togglePlay()) {
          showAppToast(context, '请先选择场景');
        }
      },
      child: Container(
        width: 44,
        height: 44,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[c.primary, c.primaryStrong],
          ),
          boxShadow: c.shadow2,
        ),
        alignment: Alignment.center,
        child: AppIcon(
            name: player.isPlaying ? 'pause' : 'play',
            size: 30,
            color: c.onPrimary),
      ),
    );
  }
}

/// 播放中的 4 根跳动摇杆（原型 `.play-bars`）。
class _PlayBars extends StatefulWidget {
  final bool playing;
  const _PlayBars({required this.playing});

  @override
  State<_PlayBars> createState() => _PlayBarsState();
}

class _PlayBarsState extends State<_PlayBars> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );
  // 原型静态高度：10 / 20 / 14 / 17（rpx→px 减半后 5 / 10 / 7 / 8.5）
  static const List<double> _heights = <double>[5, 10, 7, 8.5];

  @override
  void initState() {
    super.initState();
    _update(widget.playing);
  }

  @override
  void didUpdateWidget(_PlayBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playing != widget.playing) _update(widget.playing);
  }

  void _update(bool playing) {
    if (playing) {
      _ctrl.repeat();
    } else {
      _ctrl.stop();
      _ctrl.value = 0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    return SizedBox(
      height: 12,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List<Widget>.generate(_heights.length, (int i) {
          return AnimatedBuilder(
            animation: _ctrl,
            builder: (BuildContext context, _) {
              final t = widget.playing
                  ? 0.5 + 0.5 * _wave(_ctrl.value * 2 + i * 0.2)
                  : 1.0;
              return Container(
                width: 2.5,
                height: (_heights[i] * (widget.playing ? t : 1)).clamp(2.0, 12.0),
                margin: const EdgeInsets.only(right: 2.5),
                decoration: BoxDecoration(
                  color: widget.playing ? c.primary : c.text3,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  double _wave(double x) {
    final v = (x % 1.0) * 2;
    return v <= 1 ? v : 2 - v;
  }
}

/// 睡眠定时面板（对应原型 `.timer-panel`）。
class _TimerPanel extends StatelessWidget {
  const _TimerPanel();

  static const List<int> _options = <int>[15, 30, 45, 60, 90];
  static const List<int> _fades = <int>[1, 2, 3, 5];

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    final player = context.watch<PlayerService>();
    return _PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeader(title: '睡眠定时'),
          const SizedBox(height: 10),
          Row(
            children: _options.map((int m) {
              final on = player.timerMinutes == m;
              return Expanded(
                child: GestureDetector(
                  onTap: () => player.setTimer(m),
                  child: Container(
                    height: 44,
                    margin: EdgeInsets.only(
                        right: m == _options.last ? 0 : 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: on ? c.primary : c.surface2,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: on ? c.shadow1 : null,
                    ),
                    child: Text('$m分钟',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: on ? c.onPrimary : c.text)),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('渐弱时长', style: TextStyle(fontSize: 12, color: c.text2)),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: _fades.map((int f) {
                    final on = player.fadeMinutes == f;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => player.setFadeMinutes(f),
                        child: Container(
                          height: 32,
                          margin: EdgeInsets.only(
                              right: f == _fades.last ? 0 : 5),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: on ? c.primarySoft : c.surface2,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text('$f分钟',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight:
                                      on ? FontWeight.w600 : FontWeight.w500,
                                  color: on ? c.primary : c.text2)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 混音面板（对应原型 `.mix-panel`）。
class _MixPanel extends StatelessWidget {
  const _MixPanel();

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    final player = context.watch<PlayerService>();
    return _PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeader(
            title: '当前混音',
            badge: player.tracks.isNotEmpty
                ? '${player.tracks.length}/6 路'
                : null,
          ),
          if (player.tracks.isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 210),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: player.tracks.length,
                itemBuilder: (BuildContext context, int i) {
                  final t = player.tracks[i];
                  return MixTrack(
                    name: t.name,
                    iconName: t.iconName,
                    color: t.color,
                    volume: t.volume,
                    isMuted: t.muted,
                    onVolumeChange: (int v) => player.setTrackVolume(t.id, v),
                    onMute: () => player.toggleTrackMute(t.id),
                    onRemove: () => player.removeTrack(t.id),
                  );
                },
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('暂无音轨，去首页选择一个场景吧',
                    style: TextStyle(fontSize: 12, color: c.text2)),
              ),
            ),
        ],
      ),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  final String title;
  final String? badge;
  const _PanelHeader({required this.title, this.badge});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    final player = context.watch<PlayerService>();
    return Row(
      children: [
        Expanded(
          child: Text(title,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: c.text)),
        ),
        if (badge != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: c.primarySoft,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(badge!,
                style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: c.primary)),
          ),
        GestureDetector(
          onTap: () {
            player.setShowTimerPanel(false);
            player.setShowMixPanel(false);
          },
          child: Container(
            width: 44,
            height: 44,
            margin: const EdgeInsets.only(right: -14),
            alignment: Alignment.center,
            child: AppIcon(name: 'close', size: 16, color: c.text3),
          ),
        ),
      ],
    );
  }
}

/// 面板统一容器：浮层卡片 + panelIn 进入动效。
class _PanelCard extends StatelessWidget {
  final Widget child;
  const _PanelCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      builder: (BuildContext context, double v, Widget? w) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 6 * (1 - v)), child: w),
      ),
      child: AppCard(padding: const EdgeInsets.all(12), child: child),
    );
  }
}
