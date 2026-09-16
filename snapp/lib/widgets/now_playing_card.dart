import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/favorites_service.dart';
import '../services/player_service.dart';
import '../theme/theme_extension.dart';
import '../widgets/app_toast.dart';
import 'app_card.dart';
import 'app_icon.dart';
import 'mix_track.dart';
import 'pressable.dart';

/// 首页大播放卡（对应原型 `components/NowPlayingCard.vue`）。
///
/// 空态引导去场景库；播放态含跳动摇杆 / 大播放钮 / 定时·混音·收藏；
/// 「混音」弹出底部 Sheet（与 PlayBar 面板互斥：首页不渲染 PlayBar）。
class NowPlayingCard extends StatelessWidget {
  const NowPlayingCard({super.key});

  void _openMixSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext ctx) => const _MixSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    final player = context.watch<PlayerService>();

    if (player.currentScene == null) {
      return AppCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: c.primarySoft,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: AppIcon(name: 'moon', size: 34, color: c.primary),
            ),
            const SizedBox(height: 12),
            Text('选一个场景，开始你的助眠之旅',
                style: TextStyle(fontSize: 14, color: c.text2)),
            const SizedBox(height: 12),
            PressableScale(
              onTap: () => Navigator.pushNamed(context, '/library'),
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
            const SizedBox(height: 12),
          ],
        ),
      );
    }

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: GestureDetector(
        // 点击卡片空白区 → 展开完整播放器页（内部按钮自吸收点击）
        behavior: HitTestBehavior.translucent,
        onTap: () => Navigator.pushNamed(context, '/player'),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    player.currentScene!.name,
                    style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.15,
                        color: c.text),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: c.primarySoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${player.tracks.length}/${player.tracks.length} 路',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: c.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _WaveBars(playing: player.isPlaying)),
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
                        size: 34,
                        color: c.onPrimary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NpcAction(
                  icon: AppIcon(
                      name: 'timer',
                      size: 20,
                      color: player.timerMinutes > 0 ? c.primary : c.text2),
                  label: player.timerMinutes > 0
                      ? '${player.timerMinutes}分'
                      : '定时',
                  on: player.timerMinutes > 0,
                  onTap: () => player.setTimer(30),
                ),
                _NpcAction(
                  icon: AppIcon(name: 'shuffle', size: 20, color: c.text2),
                  label: '混音',
                  onTap: () => _openMixSheet(context),
                ),
                const _FavAction(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 呼吸波浪（5 根，播放时呼吸、暂停时静止变淡）。
class _WaveBars extends StatefulWidget {
  final bool playing;
  const _WaveBars({required this.playing});

  @override
  State<_WaveBars> createState() => _WaveBarsState();
}

class _WaveBarsState extends State<_WaveBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );
  static const List<double> _heights = <double>[
    26,
    48,
    75,
    48,
    26
  ]; // 88rpx 高容器内的百分比

  @override
  void initState() {
    super.initState();
    _update(widget.playing);
  }

  @override
  void didUpdateWidget(_WaveBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playing != widget.playing) _update(widget.playing);
  }

  void _update(bool playing) {
    if (playing) {
      _ctrl.repeat();
    } else {
      _ctrl.stop();
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
      height: 44,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List<Widget>.generate(_heights.length, (int i) {
          return AnimatedBuilder(
            animation: _ctrl,
            builder: (BuildContext context, _) {
              final phase = (_ctrl.value * 2 - i * 0.12) % 1.0;
              final scale = widget.playing
                  ? 0.6 + 0.4 * (1 - (2 * phase - 1).abs())
                  : 0.6;
              return Opacity(
                opacity: widget.playing ? 1 : 0.4,
                child: Container(
                  width: 4,
                  height: _heights[i],
                  margin: const EdgeInsets.only(right: 5),
                  alignment: Alignment.center,
                  child: FractionallySizedBox(
                    heightFactor: scale,
                    child: Container(
                      width: 4,
                      decoration: BoxDecoration(
                        color: c.primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

class _NpcAction extends StatelessWidget {
  final Widget icon;
  final String label;
  final bool on;
  final VoidCallback onTap;
  const _NpcAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.on = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        constraints: const BoxConstraints(minHeight: 44),
        decoration: BoxDecoration(
          color: on ? c.primarySoft : c.surface2,
          borderRadius: BorderRadius.circular(999),
          border: on ? null : Border.all(color: c.line, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: on ? c.primary : c.text2)),
          ],
        ),
      ),
    );
  }
}

/// 收藏按钮（共享 FavoritesService，跨页面互通并持久化）。
class _FavAction extends StatelessWidget {
  const _FavAction();

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    final fav = context.watch<FavoritesService>();
    final scene = context.watch<PlayerService>().currentScene;
    final active = scene != null && fav.isFav(scene.id);
    return _NpcAction(
      icon:
          AppIcon(name: 'heart', size: 20, color: active ? c.primary : c.text2),
      label: active ? '已收藏' : '收藏',
      on: active,
      onTap: () {
        if (scene == null) {
          showAppToast(context, '请先选择场景');
          return;
        }
        fav.toggle(scene.id);
        showAppToast(context, active ? '已取消收藏' : '已收藏');
      },
    );
  }
}

/// 混音底部 Sheet（对应原型 `.npc-sheet`：顶部 xl 圆角 + shadow-4）。
class _MixSheet extends StatelessWidget {
  const _MixSheet();

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    final player = context.watch<PlayerService>();
    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.82),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: c.line, width: 0.5)),
          boxShadow: c.shadow4,
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: c.sunken,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text('当前混音',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.15,
                          color: c.text)),
                ),
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
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 44,
                    height: 44,
                    margin: const EdgeInsets.only(right: -9),
                    alignment: Alignment.center,
                    child: AppIcon(name: 'close', size: 18, color: c.text3),
                  ),
                ),
              ],
            ),
            Flexible(
              child: player.tracks.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(top: 8),
                      itemCount: player.tracks.length,
                      itemBuilder: (BuildContext context, int i) {
                        final t = player.tracks[i];
                        return MixTrack(
                          name: t.name,
                          iconName: t.iconName,
                          color: t.color,
                          volume: t.volume,
                          isMuted: t.muted,
                          onVolumeChange: (int v) =>
                              player.setTrackVolume(t.id, v),
                          onMute: () => player.toggleTrackMute(t.id),
                          onRemove: () => player.removeTrack(t.id),
                        );
                      },
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text('暂无音轨，添加一个声音开始混音',
                            style: TextStyle(fontSize: 12.5, color: c.text2)),
                      ),
                    ),
            ),
            PressableScale(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/library');
              },
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
        ),
      ),
    );
  }
}
