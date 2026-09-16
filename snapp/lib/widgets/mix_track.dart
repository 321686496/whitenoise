import 'package:flutter/material.dart';

import '../theme/theme_extension.dart';
import '../utils/style_utils.dart';
import 'app_card.dart';
import 'app_icon.dart';
import 'pressable.dart';

/// 混音音轨（对应原型 `components/MixTrack.vue`）：
/// 色底图标 + 名称/音量 + 自定义滑轨 + 静音 / 移除。
class MixTrack extends StatelessWidget {
  final String name;
  final String iconName;
  final String color;
  final int volume;
  final bool isMuted;
  final ValueChanged<int> onVolumeChange;
  final VoidCallback onMute;
  final VoidCallback onRemove;

  const MixTrack({
    required this.name,
    required this.iconName,
    required this.color,
    required this.volume,
    required this.isMuted,
    required this.onVolumeChange,
    required this.onMute,
    required this.onRemove,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    final assetColor = hexToColor(color) ?? c.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colorMix(assetColor, 16, c.surface),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: AppIcon(name: iconName, size: 22, color: assetColor),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.15,
                      color: c.text,
                    ),
                  ),
                ),
                Text('$volume%',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: c.primary)),
              ],
            ),
            SizedBox(
              height: 44,
              child: Row(
                children: [
                  Expanded(
                    child: _VolumeSlider(
                      volume: volume,
                      onChanged: onVolumeChange,
                    ),
                  ),
                  PressableScale(
                    onTap: onMute,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isMuted ? c.dangerSoft : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: AppIcon(
                        name: isMuted ? 'mute' : 'volume',
                        size: 17,
                        color: isMuted ? c.danger : c.text3,
                      ),
                    ),
                  ),
                  PressableScale(
                    onTap: onRemove,
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: Center(
                        child: AppIcon(name: 'close', size: 15, color: c.text3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 细槽滑轨（6rpx 槽 + 28rpx 旋钮），横向拖拽 / 点按改值。
class _VolumeSlider extends StatefulWidget {
  final int volume;
  final ValueChanged<int> onChanged;
  const _VolumeSlider({required this.volume, required this.onChanged});

  @override
  State<_VolumeSlider> createState() => _VolumeSliderState();
}

class _VolumeSliderState extends State<_VolumeSlider> {
  void _update(BuildContext context, Offset localPosition, double width) {
    final v = (localPosition.dx / width * 100).round().clamp(0, 100).toInt();
    widget.onChanged(v);
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final w = constraints.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (TapDownDetails d) => _update(context, d.localPosition, w),
          onHorizontalDragUpdate: (DragUpdateDetails d) =>
              _update(context, d.localPosition, w),
          child: Center(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 3,
                  width: w,
                  decoration: BoxDecoration(
                    color: c.sunken,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: widget.volume / 100,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: c.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Positioned(
                  left: (w * widget.volume / 100).clamp(7.0, w - 7.0) - 7,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: c.surface,
                      shape: BoxShape.circle,
                      boxShadow: c.shadow1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
