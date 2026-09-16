import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/theme_extension.dart';
import '../../theme/theme_notifier.dart';
import '../../theme/theme_tokens.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_page.dart';
import '../../widgets/nav_bar.dart';
import '../../widgets/pressable.dart';
import '../../widgets/app_section.dart';
import '../../widgets/segmented.dart';

/// 主题与风格（对照原型 `pages/theme/theme.vue`）：
/// 实时预览卡 + 外观（明暗）+ 配色方案 + UI 风格 + 说明。
class ThemePage extends StatefulWidget {
  const ThemePage({super.key});

  @override
  State<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  static const List<_PreviewItem> _previewItems = <_PreviewItem>[
    _PreviewItem('white-noise', 58),
    _PreviewItem('rain', 76),
    _PreviewItem('forest', 44),
    _PreviewItem('coffee', 62),
  ];

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    final n = context.watch<ThemeNotifier>();

    return AppPage(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 28),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: NavBar(title: '主题与风格'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPreviewHero(c, n),
                  _buildSection(c, '外观', _buildAppearance(c, n)),
                  _buildSection(c, '配色方案', _buildSchemeGrid(c, n)),
                  _buildSection(c, 'UI 风格', _buildModeList(c, n)),
                  const SizedBox(height: 16),
                  _buildTip(c),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(AppColors c, String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 4),
            child: Text(title,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    color: c.text2)),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildPreviewHero(AppColors c, ThemeNotifier n) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Image.asset('assets/brand/logo.jpg',
                    width: 38,
                    height: 38,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                        width: 38,
                        height: 38,
                        color: c.surface2)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(schemeLabels[n.schemeKey]?.label ?? n.schemeKey,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: c.text)),
                    const SizedBox(height: 2),
                    Text(
                        '${n.ui.label} · ${n.mode.label} · 实时预览',
                        style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: c.primary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < _previewItems.length; i++) ...[
                if (i > 0) const SizedBox(width: 7),
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 65),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[c.bgGrad, c.surface2],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppIcon(
                            name: _previewItems[i].icon,
                            size: 26,
                            color: c.primary),
                        const SizedBox(height: 6),
                        FractionallySizedBox(
                          widthFactor: _previewItems[i].width / 100,
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: c.primary.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppearance(AppColors c, ThemeNotifier n) {
    return AppCard(
      padding: const EdgeInsets.all(4),
      child: Segmented(
        options: AppThemeMode.values
            .map((AppThemeMode m) => SegmentOption(m.key, m.label))
            .toList(),
        value: n.mode.key,
        onChanged: (String k) =>
            context.read<ThemeNotifier>().setMode(themeModeFromKey(k)),
      ),
    );
  }

  Widget _buildSchemeGrid(AppColors c, ThemeNotifier n) {
    final rows = <Widget>[];
    for (var i = 0; i < schemeKeys.length; i += 3) {
      final cells = <Widget>[];
      for (var j = 0; j < 3; j++) {
        final idx = i + j;
        if (idx < schemeKeys.length) {
          cells.add(Expanded(
            child: _SchemeItem(
              schemeKey: schemeKeys[idx],
              active: n.schemeKey == schemeKeys[idx],
              onTap: () =>
                  context.read<ThemeNotifier>().setScheme(schemeKeys[idx]),
            ),
          ));
        } else {
          cells.add(const Expanded(child: SizedBox()));
        }
        if (j < 2) cells.add(const SizedBox(width: 8));
      }
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: cells,
      ));
      rows.add(const SizedBox(height: 8));
    }
    return Column(children: rows);
  }

  Widget _buildModeList(AppColors c, ThemeNotifier n) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          for (var i = 0; i < UIStyle.values.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: AppDivider(),
              ),
            _ModeItem(
              style: UIStyle.values[i],
              active: n.ui == UIStyle.values[i],
              onTap: () =>
                  context.read<ThemeNotifier>().setUi(UIStyle.values[i]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTip(AppColors c) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIcon(name: 'check', size: 22, color: c.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '配色 × UI 风格 × 外观自由组合，切换即时生效并全局记忆；「跟随系统」随系统明暗自动变化。',
              style: TextStyle(fontSize: 12, height: 1.6, color: c.text2),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewItem {
  final String icon;
  final int width;
  const _PreviewItem(this.icon, this.width);
}

/// 配色项（明 / 暗两组色点 + 名称 + 描述 + 选中角标）。
class _SchemeItem extends StatelessWidget {
  final String schemeKey;
  final bool active;
  final VoidCallback onTap;
  const _SchemeItem({
    required this.schemeKey,
    required this.active,
    required this.onTap,
  });

  List<Color> _swatch(Brightness b) {
    final p = paletteFor(schemeKey, b);
    return <Color>[p.primary, p.accent, p.bg, p.danger];
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: active ? c.primarySoft : c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? c.primary : c.line,
            width: active ? 1 : 0.5,
          ),
        ),
        child: Column(
          children: [
            _SwatchRow(colors: _swatch(Brightness.light), surface: c.surface),
            const SizedBox(height: 3),
            _SwatchRow(colors: _swatch(Brightness.dark), surface: c.surface),
            const SizedBox(height: 5),
            Text(schemeLabels[schemeKey]?.label ?? schemeKey,
                style: TextStyle(
                    fontSize: 13.5, fontWeight: FontWeight.w600, color: c.text)),
            const SizedBox(height: 1),
            Text(schemeLabels[schemeKey]?.desc ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 10, color: c.text2)),
          ],
        ),
      ),
    );
  }
}

class _SwatchRow extends StatelessWidget {
  final List<Color> colors;
  final Color surface;
  const _SwatchRow({required this.colors, required this.surface});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 14,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < colors.length; i++)
            Container(
              width: 14,
              height: 14,
              margin: EdgeInsets.only(left: i == 0 ? 0 : -4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors[i],
                border: Border.all(color: surface, width: 1),
              ),
            ),
        ],
      ),
    );
  }
}

/// UI 风格行（小样 + 名称/描述 + 单选圈）。
class _ModeItem extends StatelessWidget {
  final UIStyle style;
  final bool active;
  final VoidCallback onTap;
  const _ModeItem({
    required this.style,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        child: Row(
          children: [
            _ModeDemo(style: style),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(style.label,
                      style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: c.text)),
                  const SizedBox(height: 2),
                  Text(style.desc,
                      style: TextStyle(fontSize: 11, color: c.text2)),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: active ? c.primary : c.lineStrong,
                  width: 1.5,
                ),
              ),
              child: active
                  ? Center(
                      child: Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c.primary,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// 风格小样（flat / glass / neu 三种微缩演示）。
class _ModeDemo extends StatelessWidget {
  final UIStyle style;
  const _ModeDemo({required this.style});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    Widget demo;
    if (style == UIStyle.flat) {
      demo = _demoBox(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[c.primary, c.accent],
        ),
        cardColor: c.onPrimary.withOpacity(0.9),
        barColor: c.onPrimary.withOpacity(0.6),
        btnColor: c.onPrimary.withOpacity(0.8),
      );
    } else if (style == UIStyle.glass) {
      demo = _demoBox(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[c.accent, c.primarySoft],
        ),
        cardColor: c.onPrimary.withOpacity(0.9),
        barColor: c.onPrimary.withOpacity(0.6),
        btnColor: c.onPrimary.withOpacity(0.8),
      );
    } else {
      demo = _demoBox(
        color: c.bg,
        shadow: <BoxShadow>[
          BoxShadow(
            color: c.text.withOpacity(0.18),
            offset: const Offset(1, 1),
            blurRadius: 3,
          ),
        ],
        cardColor: c.text.withOpacity(0.9),
        barColor: c.text.withOpacity(0.6),
        btnColor: c.text.withOpacity(0.8),
      );
    }
    return SizedBox(width: 55, height: 39, child: demo);
  }

  Widget _demoBox({
    Color? color,
    Gradient? gradient,
    List<BoxShadow> shadow = const [],
    required Color cardColor,
    required Color barColor,
    required Color btnColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color,
        gradient: gradient,
        boxShadow: shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 12,
            width: 39,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 8,
            width: 23,
            decoration: BoxDecoration(
              color: btnColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 5,
            width: 30,
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }
}
