import 'package:flutter/material.dart';

import '../theme/theme_extension.dart';
import '../utils/style_utils.dart';
import 'app_card.dart';
import 'app_icon.dart';
import 'pressable.dart';

/// 场景卡片（对应原型 `components/SceneCard.vue`）。
///
/// [layout]：row（场景页横排，封面左贴边）／ grid（网格，封面全宽 4:3 内嵌）。
/// [bgColor] 为原型 CSS 渐变字符串，[cover] 为场景封面资源路径（优先展示）。
class SceneCard extends StatelessWidget {
  final String name;
  final int soundCount;
  final List<String> soundIcons;
  final String bgColor;
  final String cover;
  final bool isPreset;
  final bool isGrid;
  final bool active;
  final String soundLabel;
  final VoidCallback onTap;
  final VoidCallback onPlay;
  final VoidCallback? onShare;

  /// row 形态卡片下间距（原型 .scene-card margin-bottom 20rpx）。
  final bool bottomMargin;

  const SceneCard({
    required this.name,
    required this.soundCount,
    required this.soundIcons,
    required this.bgColor,
    required this.isPreset,
    required this.onTap,
    required this.onPlay,
    this.cover = '',
    this.isGrid = false,
    this.active = false,
    this.soundLabel = '',
    this.onShare,
    this.bottomMargin = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    final coverWidget = _SceneCover(
      bgColor: bgColor,
      cover: cover,
      isGrid: isGrid,
      soundIcons: soundIcons,
      active: active,
      onPlay: onPlay,
    );

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isGrid ? 15 : 15,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                  color: c.text,
                ),
              ),
            ),
            if (isPreset) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: c.primarySoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('预设',
                    style: TextStyle(fontSize: 10, color: c.primary)),
              ),
            ],
          ],
        ),
        const SizedBox(height: 3),
        Text(
          soundLabel.isNotEmpty ? soundLabel : '$soundCount 种声音组合',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: isGrid ? 11 : 12, color: c.text2),
        ),
      ],
    );

    if (isGrid) {
      return AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            coverWidget,
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
              child: body,
            ),
          ],
        ),
      );
    }

    Widget rowCard = AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          coverWidget,
          Expanded(
            child: Padding(padding: const EdgeInsets.all(12), child: body),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isPreset && onShare != null)
                  _ActionBtn(
                    icon: AppIcon(name: 'share', size: 20, color: c.text3),
                    onTap: onShare!,
                  ),
                if (!isPreset && onShare != null) const SizedBox(height: 10),
                _ActionBtn(
                  icon: AppIcon(
                      name: active ? 'pause' : 'play',
                      size: 20,
                      color: c.onPrimary),
                  primary: true,
                  playing: active,
                  onTap: onPlay,
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (bottomMargin) {
      rowCard = Padding(padding: const EdgeInsets.only(bottom: 10), child: rowCard);
    }
    return rowCard;
  }
}

/// 卡片封面：渐变底（或封面图），row 形态叠声音 chips，grid 形态中央主图标
/// 与右上播放钮。
class _SceneCover extends StatelessWidget {
  final String bgColor;
  final String cover;
  final bool isGrid;
  final List<String> soundIcons;
  final bool active;
  final VoidCallback onPlay;

  const _SceneCover({
    required this.bgColor,
    required this.cover,
    required this.isGrid,
    required this.soundIcons,
    required this.active,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    final g = parseCssGradient(bgColor);
    final colors = g?.colors ??
        <Color>[c.primary, c.primaryStrong];
    final begin = g?.begin ?? Alignment.topLeft;
    final end = g?.end ?? Alignment.bottomRight;

    Widget coverChild;
    if (isGrid) {
      coverChild = Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: begin, end: end, colors: colors),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(13),
              ),
              alignment: Alignment.center,
              child: AppIcon(
                  name: soundIcons.isNotEmpty ? soundIcons[0] : 'wave',
                  size: 44,
                  color: c.onCover),
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: _ActionBtn(
              icon: AppIcon(
                  name: active ? 'pause' : 'play',
                  size: 20,
                  color: c.onPrimary),
              primary: true,
              playing: active,
              onTap: onPlay,
            ),
          ),
        ],
      );
    } else {
      coverChild = Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: begin, end: end, colors: colors),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < soundIcons.length; i++) ...[
                if (i > 0) const SizedBox(width: 5),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Center(
                    child: AppIcon(name: soundIcons[i], size: 20, color: c.onCover),
                  ),
                ),
              ],
            ],
          ),
        ],
      );
    }

    final base = ClipRRect(
      borderRadius: isGrid ? BorderRadius.circular(16) : BorderRadius.zero,
      child: SizedBox(
        width: isGrid ? double.infinity : 80,
        height: isGrid ? null : 60,
        child: AspectRatio(
          aspectRatio: isGrid ? 4 / 3 : 80 / 60,
          child: coverChild,
        ),
      ),
    );

    // 封面图：叠在渐变之上，加载失败回退渐变（对应原型 background-image 覆盖）。
    if (cover.isNotEmpty) {
      final asset = sceneImageAsset(cover);
      return ClipRRect(
        borderRadius: isGrid ? BorderRadius.circular(16) : BorderRadius.zero,
        child: SizedBox(
          width: isGrid ? double.infinity : 80,
          height: isGrid ? null : 60,
          child: AspectRatio(
            aspectRatio: isGrid ? 4 / 3 : 80 / 60,
            child: Stack(
              fit: StackFit.expand,
              children: [
                base,
                Image.asset(asset, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                if (isGrid)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: _ActionBtn(
                      icon: AppIcon(
                          name: active ? 'pause' : 'play',
                          size: 20,
                          color: c.onPrimary),
                      primary: true,
                      playing: active,
                      onTap: onPlay,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }
    return base;
  }
}

/// 封面图资源路径换算：`/static/scene/xx.png` → `assets/scene/xx.png`。
String sceneImageAsset(String p) {
  if (p.startsWith('/static/')) return 'assets/${p.substring('/static/'.length)}';
  return p;
}

class _ActionBtn extends StatelessWidget {
  final Widget icon;
  final VoidCallback onTap;
  final bool primary;
  final bool playing;
  const _ActionBtn({
    required this.icon,
    required this.onTap,
    this.primary = false,
    this.playing = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    return PressableScale(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: primary
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[c.primary, c.primaryStrong])
              : null,
          color: primary ? null : c.surface2,
          border: playing
              ? Border.all(color: c.text.withOpacity(0.22), width: 1.5)
              : null,
          boxShadow: primary ? c.shadow2 : null,
        ),
        alignment: Alignment.center,
        child: icon,
      ),
    );
  }
}
