import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/seed_data.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_extension.dart';
import '../../theme/theme_notifier.dart';
import '../../theme/theme_tokens.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_page.dart';
import '../../widgets/app_section.dart';

/// 首页骨架页：用于验证主题即时切换。
///
/// 内容：品牌头（主色圆角块占位 +「声栖」标题，logo 图片资源留待后续轮次迁移）、
/// 一张 [AppCard] 演示卡片、图标预览网格（遍历 [homeScenes] 的 iconName）、
/// 6 套配色 + 3 种 UI 风格的切换入口（经 [ThemeNotifier] 驱动全局刷新）。
///
/// 所有颜色 / 圆角 / 阴影一律走主题扩展（[AppColors] / [AppShapes]），禁止硬编码。
class IndexPage extends StatelessWidget {
  const IndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    final shapes = Theme.of(context).appShapes;
    final n = context.watch<ThemeNotifier>();

    return AppPage(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 品牌头：logo 图资源留待后续轮次，本轮用主色圆角块占位。
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: c.primary,
                    borderRadius: BorderRadius.circular(shapes.cardRadius),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '声栖',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: c.text,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '今日精选',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: c.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '主色 ${c.primary} · 背景 ${c.bg}',
                    style: TextStyle(color: c.text2, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const AppSectionTitle('选择配色'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: schemeKeys
                  .map(
                    (String k) => ChoiceChip(
                      label: Text(k),
                      selected: n.schemeKey == k,
                      onSelected: (_) => context.read<ThemeNotifier>().setScheme(k),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            const AppSectionTitle('选择 UI 风格'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: UIStyle.values
                  .map(
                    (UIStyle u) => ChoiceChip(
                      label: Text(u.label),
                      selected: n.ui == u,
                      onSelected: (_) => context.read<ThemeNotifier>().setUi(u),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            const AppSectionTitle('图标预览'),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 6,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: homeScenes
                  .map(
                    (final s) => Center(
                      child: AppIcon(name: s.iconName, size: 28, color: c.text),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}