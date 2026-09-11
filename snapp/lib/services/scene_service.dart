/// SceneService 纯函数。
///
/// 语义与原型 `prototype/src/data/scenes.ts` 同名函数一一对应，
/// `buildRecipe`/`buildPresets` 的比例算法按原型实现原样复刻。

import '../data/scene_models.dart';
import '../data/sound_models.dart';
import '../data/seed_data.dart';

/// 配方单项（对应原型 RecipeItem）。
class RecipeItem {
  const RecipeItem(this.name, this.icon, this.percent, this.color);
  final String name;
  final String icon;
  final int percent;
  final String color;
}

/// 预设每档比例项（Dart 2.19 无 record，以类承载 name/value）。
class PresetRatio {
  const PresetRatio(this.name, this.value);
  final String name;
  final int value;
}

/// 三档预设选项。
class PresetOption {
  const PresetOption(this.name, this.badgeColor, this.ratios);
  final String name;
  final String badgeColor;
  final List<PresetRatio> ratios;
}

/// 按 id 查找场景；找不到回退 homeScenes 首条。
Scene? findScene(String id) {
  for (final s in homeScenes) {
    if (s.id == id) return s;
  }
  return homeScenes.first;
}

/// 由 soundIds 解析声音名（找不到用原 id），对应原型 soundNames(ids)。
List<String> soundNames(List<String> ids) {
  return ids.map((id) {
    for (final s in sounds) {
      if (s.id == id) return s.name;
    }
    return id;
  }).toList();
}

/// 按偏好推荐：优先 prefs 分类且 recent 未听过的，取 limit 个；不足按序补齐。
List<Scene> getRecommended(List<String> prefs, List<RecentHit> recent,
    {int limit = 4}) {
  final heard = recent.map((r) => r.sceneId).toSet();
  final preferred = homeScenes
      .where((s) => prefs.contains(s.category) && !heard.contains(s.id))
      .toList();
  if (preferred.length >= limit) return preferred.take(limit).toList();
  final rest = homeScenes.where((s) => !preferred.contains(s)).toList();
  return [...preferred, ...rest].take(limit).toList();
}

/// 分类精选：'all' 取前 limit，否则按分类过滤后取前 limit。
List<Scene> getCategoryScenes(String category, int limit) {
  final list = category == 'all'
      ? homeScenes
      : homeScenes.where((s) => s.category == category).toList();
  return list.take(limit).toList();
}

/// 生成配方比例（原型模拟）：首音 40%，其余均分，末位补齐保证总和 100。
List<RecipeItem> buildRecipe(Scene scene) {
  const first = 40;
  final n = scene.soundIds.length;
  final result = <RecipeItem>[];
  for (var i = 0; i < n; i++) {
    final id = scene.soundIds[i];
    final s = _findSound(id);
    final percent = _recipePercent(first, n, i);
    result.add(RecipeItem(s?.name ?? id, s?.iconName ?? 'wave',
        percent, s?.color ?? '#8296A8'));
  }
  return result;
}

/// 计算第 i 个配方的占比（复刻原型 buildRecipe 的 spread 逻辑）。
int _recipePercent(int first, int n, int i) {
  if (i == 0) return first;
  if (i == n - 1) {
    final unit = ((100 - first) / (n - 1)).round();
    return 100 - first - unit * (n - 2);
  }
  return ((100 - first) / (n - 1)).round();
}

/// 生成三档预设（原型模拟）：轻度首音 25% / 标准 40% / 深度 60%，末位补齐。
List<PresetOption> buildPresets(Scene scene) {
  final names = soundNames(scene.soundIds);
  List<PresetRatio> spread(int first) {
    final n = names.length;
    final out = <PresetRatio>[];
    var used = 0;
    for (var i = 0; i < n; i++) {
      if (i == 0) {
        out.add(PresetRatio(names[i], first));
        used = first;
      } else if (i == n - 1) {
        out.add(PresetRatio(names[i], 100 - used));
      } else {
        final v = ((100 - first) / (n - 1)).round();
        out.add(PresetRatio(names[i], v));
        used += v;
      }
    }
    return out;
  }

  return [
    PresetOption('轻度', 'linear-gradient(135deg, #B0BFA8, #8FAF8F)', spread(25)),
    PresetOption('标准', 'linear-gradient(135deg, #8296A8, #5F7A92)', spread(40)),
    PresetOption('深度', 'linear-gradient(135deg, #6E6290, #8E82A6)', spread(60)),
  ];
}

/// 按 id 找声音，找不到返回 null。
Sound? _findSound(String id) {
  for (final s in sounds) {
    if (s.id == id) return s;
  }
  return null;
}