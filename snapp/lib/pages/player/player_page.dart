import 'dart:async';
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/favorites_service.dart';
import '../../services/player_service.dart';
import '../../theme/theme_extension.dart';
import '../../utils/style_utils.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_page.dart';
import '../../widgets/app_section.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/mix_track.dart';
import '../../widgets/pressable.dart';
import '../../widgets/scene_card.dart';

/// 独立播放页（对应原型 `pages/player/player.vue`）：
/// 大封面呼吸、进度条模拟推进、主控排（收藏/定时/播放/锁/保存）、
/// 睡眠定时面板与当前混音列表；定时到点由 PlayerService 倒计时统一处理。
class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  /// 原型无真实音频，取固定演示总时长（秒）。
  static const int totalSec = 200;

  Timer? _tick;
  int curSec = 0;
  double? _dragPct;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureTick();
  }

  void _ensureTick() {
    final playing = context.read<PlayerService>().isPlaying;
    if (playing && _tick == null) {
      _tick = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        if (!context.read<PlayerService>().isPlaying) return;
        setState(() => curSec = (curSec + 1) % totalSec);
      });
    } else if (!playing && _tick != null) {
      _tick!.cancel();
      _tick = null;
    }
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  double get _progress {
    if (_dragPct != null) return _dragPct!;
    return totalSec > 0 ? (curSec / totalSec).clamp(0.0, 1.0) : 0.0;
  }

  void _seekFrom(double ratio) {
    setState(() => _dragPct = ratio.clamp(0.0, 1.0));
  }

  void _seekEnd() {
    if (_dragPct == null) return;
    curSec = (_dragPct! * totalSec).round();
    _dragPct = null;
    setState(() {});
  }

  static String _fmt(int s) {
    final m = s ~/ 60;
    final ss = s % 60;
    return '$m:${ss.toString().padLeft(2, '0')}';
  }

  void _goBack(BuildContext context) {
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
    } else {
      nav.pushNamedAndRemoveUntil('/index', (Route<dynamic> r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    final player = context.watch<PlayerService>();

    return AppPage(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(rx(8), rx(8), rx(8), rx(24)),
            child: Row(
              children: [
                SizedBox(
                  width: 44,
                  child: PressableScale(
                    onTap: () => _goBack(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      child: AppIcon(
                          name: 'chevron-down', size: 22, color: c.text),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '正在播放',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      color: c.text2,
                    ),
                  ),
                ),
                const SizedBox(width: 44),
              ],
            ),
          ),
          Expanded(
            child: player.currentScene == null
                ? _EmptyState(onGoLibrary: () => _goLibrary(context))
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildCover(context, player),
                        _buildMeta(context, player),
                        _buildProgress(context),
                        _buildControls(context, player),
                        if (player.showTimerPanel)
                          _buildTimerPanel(context, player),
                        _buildMix(context, player),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _goLibrary(BuildContext context) {
    Navigator.pushNamed(context, '/library');
  }

  Widget _buildCover(BuildContext context, PlayerService player) {
    final scene = player.currentScene!;
    return Padding(
      padding: EdgeInsets.fromLTRB(0, rx(24), 0, rx(40)),
      child: _BreathingCover(
        playing: player.isPlaying,
        gradient: scene.gradient,
        image: scene.image,
        iconName: scene.iconName,
      ),
    );
  }

  Widget _buildMeta(BuildContext context, PlayerService player) {
    final c = Theme.of(context).appColors;
    final scene = player.currentScene!;
    final names = player.tracks.map((PlayerTrack t) => t.name).join(' + ');
    return Column(
      children: [
        Text(
          scene.name,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: rx(42),
            fontWeight: FontWeight.w700,
            letterSpacing: -0.25,
            height: 1.2,
            color: c.text,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${player.tracks.length} 路音轨 · $names',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: rx(25), color: c.text2),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: player.tracks.map((PlayerTrack t) {
            final chip = hexToColor(t.color) ?? c.primary;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colorMix(chip, 14, c.surface),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: c.line, width: 0.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppIcon(name: t.iconName, size: 12, color: chip),
                  const SizedBox(width: 5),
                  Text(t.name, style: TextStyle(fontSize: 11, color: c.text2)),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProgress(BuildContext context) {
    final c = Theme.of(context).appColors;
    return Padding(
      padding: EdgeInsets.fromLTRB(0, rx(40), 0, rx(8)),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final w = constraints.maxWidth;
          final pct = _progress;
          return Column(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (TapDownDetails d) =>
                    _seekFrom(d.localPosition.dx / w),
                onHorizontalDragUpdate: (DragUpdateDetails d) =>
                    _seekFrom(d.localPosition.dx / w),
                onHorizontalDragEnd: (_) => _seekEnd(),
                child: SizedBox(
                  height: 22,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: c.sunken,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      Container(
                        width: w * pct,
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: LinearGradient(
                            colors: <Color>[c.primary, c.primaryStrong],
                          ),
                        ),
                      ),
                      Positioned(
                        left: (w * pct - 8).clamp(0.0, w - 16),
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: c.surface,
                            boxShadow: c.shadow1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(_fmt(curSec),
                        style: TextStyle(
                            fontSize: 11.5,
                            color: c.text3,
                            fontFeatures: const <FontFeature>[
                              FontFeature.tabularFigures()
                            ])),
                    Text(_fmt(totalSec),
                        style: TextStyle(
                            fontSize: 11.5,
                            color: c.text3,
                            fontFeatures: const <FontFeature>[
                              FontFeature.tabularFigures()
                            ])),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildControls(BuildContext context, PlayerService player) {
    final c = Theme.of(context).appColors;
    final fav = context.watch<FavoritesService>();
    final scene = player.currentScene;
    final isFav = scene != null && fav.isFav(scene.id);
    return Padding(
      padding: EdgeInsets.fromLTRB(0, rx(16), 0, rx(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _CtlButton(
            on: isFav,
            icon: AppIcon(
                name: 'heart', size: 26, color: isFav ? c.primary : c.text2),
            onTap: () {
              if (scene == null) {
                showAppToast(context, '请先选择场景');
                return;
              }
              fav.toggle(scene.id);
              showAppToast(context, isFav ? '已取消收藏' : '已收藏');
            },
          ),
          _CtlButton(
            on: player.timerMinutes > 0,
            icon: AppIcon(
                name: 'timer',
                size: 26,
                color: player.timerMinutes > 0 ? c.primary : c.text2),
            onTap: () => player.setShowTimerPanel(!player.showTimerPanel),
          ),
          PressableScale(
            onTap: () {
              if (!player.togglePlay()) {
                showAppToast(context, '请先选择场景');
              }
            },
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[c.primary, c.primaryStrong],
                ),
                boxShadow: c.shadow3,
              ),
              alignment: Alignment.center,
              child: AppIcon(
                  name: player.isPlaying ? 'pause' : 'play',
                  size: 44,
                  color: c.onPrimary),
            ),
          ),
          _CtlButton(
            on: player.isLocked,
            icon: AppIcon(
                name: 'lock',
                size: 26,
                color: player.isLocked ? c.primary : c.text2),
            onTap: () {
              player.toggleLock();
              showAppToast(context, player.isLocked ? '已锁定播放' : '已解锁');
            },
          ),
          _CtlButton(
            on: false,
            icon: AppIcon(name: 'save', size: 26, color: c.text2),
            onTap: () => showAppToast(context, '已保存到收藏'),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerPanel(BuildContext context, PlayerService player) {
    final c = Theme.of(context).appColors;
    const options = <int>[15, 30, 45, 60, 90];
    return Padding(
      padding: EdgeInsets.fromLTRB(0, rx(20), 0, rx(8)),
      child: AppCard(
        padding: EdgeInsets.all(rx(28)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('睡眠定时',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.15,
                          color: c.text)),
                ),
                GestureDetector(
                  onTap: () => player.setShowTimerPanel(false),
                  child: Transform.translate(
                    offset: const Offset(8, 0),
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      child: AppIcon(name: 'close', size: 18, color: c.text3),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: rx(20)),
            Wrap(
              spacing: rx(14),
              runSpacing: rx(14),
              children: options.map((int m) {
                final on = player.timerMinutes == m;
                return GestureDetector(
                  onTap: () => player.setTimer(m),
                  child: Container(
                    height: rx(72),
                    padding: EdgeInsets.symmetric(horizontal: rx(26)),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: on ? c.primary : c.surface2,
                      borderRadius: BorderRadius.circular(999),
                      border: on ? null : Border.all(color: c.line, width: 0.5),
                    ),
                    child: Text('$m分钟',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: on ? FontWeight.w600 : FontWeight.w500,
                            color: on ? c.onPrimary : c.text2)),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMix(BuildContext context, PlayerService player) {
    final c = Theme.of(context).appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(0, rx(40), 0, rx(16)),
          child: Row(
            children: [
              const Expanded(child: AppSectionTitle('当前混音')),
              if (player.tracks.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: c.primarySoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('${player.tracks.length}/6 路',
                      style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: c.primary)),
                ),
            ],
          ),
        ),
        if (player.tracks.isNotEmpty)
          Column(
            children: player.tracks.map((PlayerTrack t) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: MixTrack(
                  name: t.name,
                  iconName: t.iconName,
                  color: t.color,
                  volume: t.volume,
                  isMuted: t.muted,
                  onVolumeChange: (int v) => player.setTrackVolume(t.id, v),
                  onMute: () => player.toggleTrackMute(t.id),
                  onRemove: () => player.removeTrack(t.id),
                ),
              );
            }).toList(),
          )
        else
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            child: Center(
              child: Text('暂无音轨，去选择场景后调整混音',
                  style: TextStyle(fontSize: 12.5, color: c.text2)),
            ),
          ),
        PressableScale(
          onTap: () => _goLibrary(context),
          child: Container(
            margin: const EdgeInsets.only(top: 10),
            constraints: const BoxConstraints(minHeight: 44),
            decoration: BoxDecoration(
              color: c.surface2,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: c.line, width: 0.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppIcon(name: 'mixer', size: 18, color: c.primary),
                const SizedBox(width: 6),
                Text('添加声音',
                    style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: c.primary)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 空态：还没有在播放的场景（对应原型 `.np-empty`）。
class _EmptyState extends StatelessWidget {
  final VoidCallback onGoLibrary;
  const _EmptyState({required this.onGoLibrary});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: rx(88), horizontal: rx(40)),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: c.primarySoft,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: AppIcon(name: 'moon', size: 40, color: c.primary),
            ),
            const SizedBox(height: 8),
            Text('还没有在播放的场景',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700, color: c.text)),
            const SizedBox(height: 6),
            Text('选一个场景或声音，享受此刻的安静',
                style: TextStyle(fontSize: 12.5, color: c.text2)),
            const SizedBox(height: 12),
            PressableScale(
              onTap: onGoLibrary,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 26, vertical: 9),
                decoration: BoxDecoration(
                  color: c.primary,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: c.shadow2,
                ),
                child: Text('去场景库',
                    style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: c.onPrimary)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 主控排圆形按钮（对应原型 `.np-ctl`）。
class _CtlButton extends StatelessWidget {
  final Widget icon;
  final bool on;
  final VoidCallback onTap;
  const _CtlButton({required this.icon, required this.on, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    return PressableScale(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: on ? c.primarySoft : Colors.transparent,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: icon,
      ),
    );
  }
}

/// 大封面：渐变底 + 封面图（失败回退图标），播放时轻微呼吸放大。
class _BreathingCover extends StatefulWidget {
  final bool playing;
  final String gradient;
  final String image;
  final String iconName;
  const _BreathingCover({
    required this.playing,
    required this.gradient,
    required this.image,
    required this.iconName,
  });

  @override
  State<_BreathingCover> createState() => _BreathingCoverState();
}

class _BreathingCoverState extends State<_BreathingCover>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  );

  @override
  void initState() {
    super.initState();
    _update(widget.playing);
  }

  @override
  void didUpdateWidget(_BreathingCover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playing != widget.playing) _update(widget.playing);
  }

  void _update(bool playing) {
    if (playing) {
      _ctrl.repeat(reverse: true);
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
    final g = parseCssGradient(widget.gradient);
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (BuildContext context, _) {
        final scale = widget.playing ? 1.0 + 0.035 * _ctrl.value : 1.0;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: rx(520),
            height: rx(520),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(rx(48)),
              gradient: g == null
                  ? null
                  : LinearGradient(
                      begin: g.begin, end: g.end, colors: g.colors),
              color: g == null ? c.surface2 : null,
              boxShadow: c.shadow3,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(rx(48)),
              child: widget.image.isNotEmpty
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(sceneImageAsset(widget.image),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                                child: AppIcon(
                                    name: widget.iconName,
                                    size: rx(110),
                                    color: c.onPrimary))),
                      ],
                    )
                  : Center(
                      child: AppIcon(
                          name: widget.iconName,
                          size: rx(110),
                          color: c.onPrimary),
                    ),
            ),
          ),
        );
      },
    );
  }
}
