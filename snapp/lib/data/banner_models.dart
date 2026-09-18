/// 横幅类型：对应原型 `BannerType`。
enum BannerType { campaign, featured, personal, status }

/// 点击行为：播放 / 跳转。
enum BannerKind { play, navigate }

/// 首页 Banners 分发位条目（对照原型 `Banner`）。
class Banner {
  final String id;
  final BannerType type;
  final String title;
  final String? subtitle;
  final String icon; // AppIcon.name
  final String gradient; // CSS linear-gradient 字符串，parseCssGradient 消费
  final BannerKind kind;
  final String? sceneId; // kind == play
  final String? route; // kind == navigate

  const Banner({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.gradient,
    required this.kind,
    this.sceneId,
    this.route,
  });
}