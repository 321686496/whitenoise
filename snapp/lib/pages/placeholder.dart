import 'package:flutter/material.dart';

import '../theme/theme_extension.dart';
import '../widgets/app_page.dart';
import '../widgets/app_section.dart';

/// 统一占位页：供尚未实现的页面使用（后续轮次替换为真实页面）。
class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    return AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: c.text,
            ),
          ),
          const SizedBox(height: 12),
          const AppSectionTitle('占位页面 · 后续轮次实现'),
        ],
      ),
    );
  }
}