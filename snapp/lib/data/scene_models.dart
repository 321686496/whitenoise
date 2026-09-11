/// 场景数据模型。
///
/// 与原型 `prototype/src/data/scenes.ts` 的 interface 一一对应，
/// 字段以权威源码为准（Dart 2.19 兼容，无 record 语法）。

/// 场景分类 key（filter 分类），含 'all' 特例。
typedef SceneCategory = String;

const String catAll = 'all';
const String catSleep = 'sleep';
const String catFocus = 'focus';
const String catRelax = 'relax';
const String catNature = 'nature';

/// 首页/场景列表的场景模型。
class Scene {
  const Scene({
    required this.id,
    required this.name,
    required this.category,
    required this.desc,
    required this.iconName,
    required this.gradient,
    required this.image,
    required this.soundIds,
    required this.isPreset,
  });

  final String id;
  final String name;
  final String category;
  final String desc;
  final String iconName;
  final String gradient;

  /// 场景封面素材相对路径；为空时回退 gradient。
  final String image;
  final List<String> soundIds;
  final bool isPreset;
}

/// 发现页推荐场景（FeaturedScene）。
///
/// 注：原型 `ratio` 为 number[]、`playCount` 为 string，
/// 与计划示例（double/Number）不同，此处以原型数据为准适配。
class FeaturedScene {
  const FeaturedScene({
    required this.id,
    required this.name,
    required this.desc,
    required this.iconName,
    required this.gradient,
    required this.tags,
    required this.soundIds,
    required this.ratio,
    required this.playCount,
    required this.duration,
  });

  final String id;
  final String name;
  final String desc;
  final String iconName;
  final String gradient;
  final List<String> tags;
  final List<String> soundIds;
  final List<int> ratio;
  final String playCount;
  final String duration;
}

/// 场景分类选项（key + label）。
class SceneCategoryItem {
  const SceneCategoryItem(this.key, this.label);
  final String key;
  final String label;
}

/// 最近播放记录（用于推荐剔除已听场景）。
class RecentHit {
  const RecentHit(this.sceneId);
  final String sceneId;
}