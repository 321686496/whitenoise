import '../data/banner_models.dart';
import '../data/scene_models.dart';
import '../services/player_service.dart';
import '../services/stats_service.dart';
import 'scene_service.dart';

/// 偏好分类优先级（与 prototype `prefOrder` 一致）。
const List<String> _prefOrder = <String>['sleep', 'nature', 'relax', 'focus'];

/// 时段 → 精选场景 id（与 prototype `featuredSceneId` 一致）。
String _featuredSceneId(int hour) {
  if (hour >= 22 || hour < 5) return 'rainy-night';
  if (hour >= 5 && hour < 9) return 'morning-forest';
  if (hour >= 9 && hour < 12) return 'focus-white-noise';
  if (hour >= 14 && hour < 18) return 'coffee-time';
  if (hour >= 18 && hour < 22) return 'nature-relax';
  return 'rainy-night';
}

/// 从偏好池取第一个未被 seen 的场景，无则 null。
Scene? _pickByPreference(List<Scene> pool, Set<String> seen) {
  for (final s in pool) {
    if (!seen.contains(s.id)) return s;
  }
  return null;
}

/// 按固定顺序组装：campaign → featured → personal → status。
List<Banner> buildBanners({
  required int hour,
  required List<RecentItem> recent,
  required StatsService stats,
}) {
  final seen = <String>{};
  final out = <Banner>[];

  // ① 运营活动
  out.add(const Banner(
    id: 'campaign-checkin',
    type: BannerType.campaign,
    title: '连续签到领好礼',
    subtitle: '每天来签到，解锁助眠奖励',
    icon: 'gift',
    gradient: 'linear-gradient(135deg, #3D6B5E, #2F544A)',
    kind: BannerKind.navigate,
    route: '/checkin',
  ));

  // ② 今日精选（findScene 非空返回，直接使用）
  final featured = findScene(_featuredSceneId(hour));
  seen.add(featured.id);
  out.add(Banner(
    id: 'featured-${featured.id}',
    type: BannerType.featured,
    title: featured.name,
    subtitle: featured.desc.isEmpty ? '点按即刻开播' : featured.desc,
    icon: featured.iconName,
    gradient: featured.gradient,
    kind: BannerKind.play,
    sceneId: featured.id,
  ));

  // ③ 个性化推荐（偏好分类且近期未听，回退最近使用）
  final personalPool = <Scene>[
    for (final cat in _prefOrder) ...getCategoryScenes(cat, 20),
  ];
  final Scene? personal =
      _pickByPreference(personalPool, seen) ??
      (recent.isNotEmpty ? findScene(recent.first.sceneId) : null);
  if (personal != null) {
    seen.add(personal.id);
    out.add(Banner(
      id: 'personal-${personal.id}',
      type: BannerType.personal,
      title: '为你推荐',
      subtitle: personal.name,
      icon: personal.iconName,
      gradient: personal.gradient,
      kind: BannerKind.navigate,
      route: '/scene-detail',
      sceneId: personal.id, // navigate 目标为 /scene-detail 时须携带 sceneId
    ));
  }

  // ④ 状态反馈（今日有播放才显示）
  final todayPlays = stats.weekPlays.isEmpty ? 0 : stats.weekPlays.first;
  if (todayPlays > 0) {
    out.add(Banner(
      id: 'status-today',
      type: BannerType.status,
      title: '今日已助眠 $todayPlays 次',
      subtitle: '坚持每晚，安睡好养神',
      icon: 'moon',
      gradient: 'linear-gradient(135deg, #5F8296, #4E7182)',
      kind: BannerKind.navigate,
      route: '/stats',
    ));
  }

  return out;
}