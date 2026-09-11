import 'package:flutter/material.dart';

import '../pages/index/index_page.dart';
import '../pages/placeholder.dart';

/// 命名路由表（对照原型 `pages.json`）。
///
/// 4 个 tab 页的真实切换由 Root 的 `_Shell`（IndexedStack + 悬浮 AppTabBar）管理，
/// 此处路由主要用于命名跳转与还原，未实现页面统一落到 [PlaceholderPage]。
Map<String, WidgetBuilder> buildRoutes() => <String, WidgetBuilder>{
      '/index': (_) => const IndexPage(),
      '/scene': (_) => const PlaceholderPage('场景'),
      '/discover': (_) => const PlaceholderPage('发现'),
      '/mine': (_) => const PlaceholderPage('我的'),
      '/library': (_) => const PlaceholderPage('音频库'),
      '/theme': (_) => const PlaceholderPage('主题设置'),
      '/achievement': (_) => const PlaceholderPage('成就'),
      '/invite': (_) => const PlaceholderPage('邀请好友'),
      '/settings': (_) => const PlaceholderPage('设置'),
      '/checkin': (_) => const PlaceholderPage('每日签到'),
      '/stats': (_) => const PlaceholderPage('数据统计'),
      '/favorites': (_) => const PlaceholderPage('我的收藏'),
      '/history': (_) => const PlaceholderPage('最近播放'),
      '/onboarding': (_) => const PlaceholderPage('新人引导'),
      '/scene-detail': (_) => const PlaceholderPage('场景详情'),
      '/scene-edit': (_) => const PlaceholderPage('编辑场景'),
      '/scene-all': (_) => const PlaceholderPage('全部场景'),
    };