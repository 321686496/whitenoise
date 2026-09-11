/// 声音数据模型。
///
/// 与原型 `prototype/src/data/sounds.ts` 的 interface 一一对应，
/// 字段以权威源码为准。

/// 内置白噪音音频。
class Sound {
  const Sound({
    required this.id,
    required this.name,
    required this.type,
    required this.category,
    required this.iconName,
    required this.color,
    required this.gradient,
    required this.duration,
    required this.sampleRate,
    required this.quality,
    required this.source,
    required this.desc,
    required this.scenes,
    required this.loopLength,
  });

  final String id;
  final String name;

  /// 显示分类：合成白噪音 / 自然音 / 城市音 / 环境音。
  final String type;

  /// 筛选分类 key：synthetic / nature / urban / ambient。
  final String category;
  final String iconName;
  final String color;
  final String gradient;
  final String duration;
  final String sampleRate;
  final String quality;

  /// 声音来源/采集说明。
  final String source;
  final String desc;

  /// 适用场景标签。
  final List<String> scenes;
  final String loopLength;
}

/// 声音分类选项（key + label + icon）。
class SoundCategoryItem {
  const SoundCategoryItem(this.key, this.label, this.icon);
  final String key;
  final String label;
  final String icon;
}

/// 精选声音（发现页人气居前），组合一条 [Sound] 并附加热度 `hot`。
///
/// 采用组合而非 `implements Sound`，避免复制 15 个字段，语义与原型
/// `interface FeaturedSound extends Sound { hot: number }` 一致（通过 `.sound` 访问）。
class FeaturedSound {
  const FeaturedSound({required this.sound, required this.hot});
  final Sound sound;
  final int hot;
}