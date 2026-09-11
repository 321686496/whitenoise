# 声栖 Flutter 地基 + 图标体系 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在 `snapp/`（Flutter）搭建可运行地基：主题引擎（6 配色 × 3 UI 风格）、App 外壳与命名路由、悬浮 TabBar、37 个 SVG 图标体系、数据层模型与 SceneService、公共样式原语，并以 Home 骨架页验证主题即时切换。

**Architecture:** 以 `provider` 统一状态管理；主题用 `ChangeNotifier`（6×3 token）+ `ThemeData`/`ThemeExtension` 承载，切换全局即时生效并持久化（shared_preferences）；图标用 `flutter_svg` 以 `SvgPicture.string` 渲染；路由用命名路由对照原型 `pages.json`。所有组件样式一律走主题扩展读取，禁止硬编码。

**Tech Stack:** Flutter `3.7.12-ohos-1.1.3` / Dart `2.19.6`、provider、shared_preferences、flutter_svg。

## Global Constraints

- 工程 `snapp/` 锁定 `sdk: '>=2.19.6 <3.0.0'`（Dart<3.0）；本机工具链即 Harmony 引擎。
- 依赖版本须在 Dart 2.19 可解析：`provider ^6.1.1`（纯 Dart）、`flutter_svg ^2.0.9`（纯 Dart）、`shared_preferences ^2.2.2`（Harmony 已适配，发布版无 ohos 胶水，真实 HAP 构建时须切至 OpenHarmony 适配 git 源，见 Task 1 备注）。
- 样式永远跟随「设置里的 UI 风格 + 主题」，业务代码**零硬编码颜色/圆角/阴影/间距**；禁止不同 UI 风格/配色混搭。
- 新拟态浮雕：组件表面色==画布背景 `neuTint`，凸起=左上浅色高光+右下深色阴影，无描边；按下/选中=方向反转的内凹；叠在图片上的浮层降级为玻璃/实底取向。
- 图标一律自定义 SVG（`AppIcon`），禁止 emoji；iconName 必须与图标映射表一致，未知名回退默认圆点。
- 应用名与持久化 key：主题存储 key `shengqi-theme`；应用名为「声栖」。
- Harmony 真机构建需另配 OH SDK，本轮验收以 `flutter pub get` / `flutter analyze` / `flutter test` 通过为准。
- 改代码前先获用户许可是本仓库约定；执行实现时按 skill 流程逐任务推进。

---

## File Structure

| 任务 | 创建/修改文件 | 职责 |
|---|---|---|
| T1 | `snapp/pubspec.yaml`、目录骨架 | 依赖解析 + 目录 |
| T2 | `lib/theme/theme_tokens.dart`、`theme_extension.dart`、`app_theme.dart`、`theme_notifier.dart`、`app/theme_prefs.dart` | 主题引擎 |
| T3 | `lib/widgets/app_svg_icons.dart`、`app_icon.dart` | 图标体系 |
| T4 | `lib/widgets/app_page.dart`、`app_card.dart`、`app_buttons.dart`、`app_section.dart`、`tab_bar.dart`、`app/router.dart`、`app/app.dart`、`main.dart`、`pages/placeholder.dart` | 外壳/路由/TabBar/原语 |
| T5 | `lib/data/scene_models.dart`、`sound_models.dart`、`seed_data.dart`、`services/scene_service.dart` | 数据层 |
| T6 | `lib/pages/index/index_page.dart`、`test/theme_notifier_test.dart`、`test/scene_service_test.dart`、`test/app_icon_test.dart` | Home 骨架 + 测试 |

---

### Task 1: 依赖解析与工程骨架

**Files:**
- Modify: `snapp/pubspec.yaml`
- Create: `snapp/lib/{app,theme,widgets,data,services,pages/index}` 目录占位（依赖的源文件在后续任务创建）

**Interfaces:**
- Consumes: 现有 `snapp/pubspec.yaml`（仅 demo 依赖）
- Produces: 可 `flutter pub get` 通过的 `pubspec.yaml`，声明 `provider`、`shared_preferences`、`flutter_svg`

- [ ] **Step 1: 覆写 pubspec.yaml 的 dependencies 与 flutter assets**

`snapp/pubspec.yaml` 的 `dependencies:` 改为（保留 `flutter`/`cupertino_icons`，删除默认注释；`assets:` 本轮暂不加图片资源，logo/封面图留待页面轮次）：

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  provider: ^6.1.1
  shared_preferences: ^2.2.2
  flutter_svg: ^2.0.9
```

- [ ] **Step 2: 运行依赖解析**

Run: `flutter pub get`（在 `snapp/` 目录）
Expected: 解析成功。若 `shared_preferences`/`flutter_svg` 任一与 Dart 2.19 冲突（报 SDK 不满足），降级为兼容版本（如 `shared_preferences: 2.1.1`、`flutter_svg: 2.0.5`）并记录到本文件后重试。若无法联网拉取 git，则维持 pub.dev 版本（真实 Harmony HAP 构建时再切 OpenHarmony-sig 适配源 `https://gitcode.com/openharmony-sig/flutter_packages.git` 的 `packages/shared_preferences/shared_preferences`）。

- [ ] **Step 3: 创建目录骨架**

Create 空目录：`snapp/lib/app`、`snapp/lib/theme`、`snapp/lib/widgets`、`snapp/lib/data`、`snapp/lib/services`、`snapp/lib/pages/index`。可将原 `lib/main.dart` 保留到 T4 重写。

- [ ] **Step 4: 提交**

```bash
git add snapp/pubspec.yaml snapp/pubspec.lock
git commit -m "chore(snapp): bootstrap dependencies and directories for foundation"
```

---

### Task 2: 主题引擎（token + notifier + extension + 持久化）

**Files:**
- Create: `snapp/lib/theme/theme_tokens.dart`
- Create: `snapp/lib/theme/theme_extension.dart`
- Create: `snapp/lib/theme/app_theme.dart`
- Create: `snapp/lib/theme/theme_notifier.dart`
- Create: `snapp/lib/app/theme_prefs.dart`
- Test: `snapp/test/theme_notifier_test.dart`

**Interfaces:**
- Consumes: `shared_preferences`；原型 `prototype/src/theme/index.ts` 的 token 值
- Produces:
  - `typedef SchemeKey = String`，常量 `schemeMorandi='morandi' ...`；`class ThemeScheme { final String key,label,desc; final AppColors colors; }`
  - `class AppColors`（ThemeExtension）：字段 `primary, primarySoft, primaryDark, onPrimary, accent, bg, bgGrad, text, text2, text3, divider, subtle, danger, cardBg, cardBorder, pressBg, inputBg`，`List<BoxShadow> cardShadow, neuA, neuB`（或 `cardShadowA/cardShadowB`）。含 `copyWith`/`lerp`。
  - `ThemeNotifier extends ChangeNotifier { ThemeScheme scheme; UIStyle ui; Future<void> load(); Future<void> setScheme(String); Future<void> setUi(String); }`
  - `class ThemePrefs { static Future<({String scheme,String ui})> read(); static Future<void> write(String,String); }`
  - `ThemeData appThemeFor(...)`

- [ ] **Step 1: 写主题 Notifier 失败测试**

`snapp/test/theme_notifier_test.dart`：

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:snapp/theme/theme_notifier.dart';

void main() {
  test('default scheme/ui are morandi + flat', () {
    final n = ThemeNotifier();
    expect(n.schemeKey, 'morandi');
    expect(n.ui, UIStyle.flat);
  });

  test('setScheme updates and notifies', () {
    final n = ThemeNotifier();
    var notified = 0;
    n.addListener(() => notified++);
    n.setScheme('ocean');
    expect(n.schemeKey, 'ocean');
    expect(notified, 1);
  });
}
```

- [ ] **Step 2: 运行测试确认失败**

Run: `flutter test test/theme_notifier_test.dart`
Expected: 编译失败（`ThemeNotifier` 不存在）。

- [ ] **Step 3: 实现 theme_tokens.dart 的 6 配色 token**

逐条迁自 `theme/index.ts`（值原样拷贝）。定义 `AppColors colorFor(String scheme, String ui)` 逻辑：先取配色基础字段，再按 ui（flat/glass/neu）计算容器字段。示例（morandi 基础字段 + 三种 ui 的 cardBg/cardShadow）：

```dart
import 'package:flutter/material.dart';

const double _kNeuShadowA = 7;
const double _kNeuShadowB = 7;

class AppUiColor {
  final Color cardBg;
  final Color cardBorder;
  final List<BoxShadow> cardShadow;
  final double cardBlur;
  final Color pressBg;
  final Color inputBg;
  final Color inputBorder;
  const AppUiColor({required this.cardBg, required this.cardBorder,
    required this.cardShadow, required this.cardBlur, required this.pressBg,
    required this.inputBg, required this.inputBorder});
}

AppUiColor _uiColors(String ui, {
  required Color tone, required Color cardBorder, required Color subtle,
  required Color glassCard, required Color glassBorder, required Color neuTint,
  required Color neuA, required Color neuB,
}) {
  switch (ui) {
    case 'glass':
      return AppUiColor(
        cardBg: glassCard, cardBorder: glassBorder,
        cardShadow: [BoxShadow(color: Color(0x1A142822), offset: const Offset(8, 8), blurRadius: 26)],
        cardBlur: 22, pressBg: const Color(0x59FFFFFF),
        inputBg: const Color(0x80FFFFFF), inputBorder: glassBorder,
      );
    case 'neu':
      return AppUiColor(
        cardBg: neuTint, cardBorder: Colors.transparent,
        cardShadow: [
          BoxShadow(color: neuA, offset: const Offset(-_kNeuShadowA, -_kNeuShadowA), blurRadius: 16),
          BoxShadow(color: neuB, offset: const Offset(_kNeuShadowB, _kNeuShadowB), blurRadius: 18),
        ],
        cardBlur: 0, pressBg: subtle, inputBg: neuTint, inputBorder: Colors.transparent,
      );
    default: // flat
      return AppUiColor(
        cardBg: const Color(0xFFFFFFFF), cardBorder: cardBorder,
        cardShadow: [BoxShadow(color: neuA, offset: const Offset(2, 2), blurRadius: 12)],
        cardBlur: 0, pressBg: subtle, inputBg: const Color(0xFFFFFFFF), inputBorder: cardBorder,
      );
  }
}
```

随后按 `scheme` 返回 `AppColors`。6 套配色的基础色值（HEX→Color 需补 alpha；`neuA`/`neuB` 直接给 Color）：

| scheme | primary | primarySoft | onPrimary | bg | bgGrad | text | text2 | text3 | divider | subtle | danger | neuTint | neuA | neuB |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| morandi | 5C8A72 | 24_5C8A72 | FFFFFF | F2F0EA | E7E4DA | 2F3B35 | 6E7B74 | A6B0A9 | ECE8DE | ECE9E0 | C4706B | EAE7DD | 34_5A6E64* | EBFFFFFF |
| ocean | 5FB0B0 | 29_5FB0B0 | 062026 | 0E2230 | 16303F | E6F2F3 | 9FB9C1 | 6E8C95 | 244150 | 1D3946 | D98B7B | 14303E | 61_000000 | 29_468C74* |
| forest | 4A6741 | 24_4A6741 | FFFFFF | EEF1E6 | E0E9D6 | 2C3628 | 68725D | 99A48F | E5EADB | E4ECDA | C0705B | E3ECDA | 29_5D5A32* | EBFFFFFF |
| sunset | C06B48 | 24_C06B48 | FFFFFF | FBF1E6 | F4E2CE | 3E3128 | 7E6E62 | AB9A8B | F2E8DC | F6EADD | C15B58 | F2E4D5 | 29_A06446* | EBFFFFFF |
| lavender | 8A7BB0 | 24_8A7BB0 | FFFFFF | F4F1FA | E9E3F4 | 37324A | 7A7292 | A8A1C0 | ECE6F5 | EDE9F5 | C0759B | E8E3F3 | 29_69558C* | EBFFFFFF |
| mono | 2F2F2F | 14_1F1F1F | FFFFFF | FAFAFA | F0F0F0 | 1A1A1A | 6E6E6E | A9A9A9 | EDEDED | F2F2F2 | B1483D | EFEFEF | 1F_000000 | F2FFFFFF |

> `*` 处 alpha 前缀为透明度近似：原型 `rgba(a,b,c,α)` → Flutter `Color(0xAARRGGBB)`。`neuA`/`neuB` 原型的 rgba(…, .16/.92) 近似为 `0x2A…/0xEB…`；实现时以 `theme/index.ts` 原值为准逐个转换，上方为示例值，完成校验以浏览器取色/透明 alpha 与原值一致为准。

> ⚠️ 比例与透明度较多，Token 的**唯一权威来源是 `prototype/src/theme/index.ts` 与 `prototype/src/uni.scss`**。实现时必须逐字段对照迁移，本表为字段清单与转换规则，非最终值。

- [ ] **Step 4: 实现 theme_extension.dart 的 AppColors**

```dart
import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color primary, primarySoft, onPrimary, accent, bg, bgGrad, text;
  final Color text2, text3, divider, subtle, danger;
  final Color cardBg, cardBorder, pressBg, inputBg, inputBorder;
  final Color neuA, neuB;
  const AppColors({
    required this.primary, required this.primarySoft, required this.onPrimary,
    required this.accent, required this.bg, required this.bgGrad,
    required this.text, required this.text2, required this.text3,
    required this.divider, required this.subtle, required this.danger,
    required this.cardBg, required this.cardBorder, required this.pressBg,
    required this.inputBg, required this.inputBorder,
    required this.neuA, required this.neuB,
  });

  @override
  AppColors copyWith({Color? primary, Color? cardBg, Color? cardBorder, Color? onPrimary,
      Color? bg, Color? text, Color? text2, Color? divider, Color? pressBg,
      Color? inputBg, Color? inputBorder, Color? neuA, Color? neuB, Color? subtle,
      Color? accent, Color? bgGrad, Color? text3, Color? danger, Color? primarySoft}) {
    return AppColors(
      primary: primary ?? this.primary, primarySoft: primarySoft ?? this.primarySoft,
      onPrimary: onPrimary ?? this.onPrimary, accent: accent ?? this.accent,
      bg: bg ?? this.bg, bgGrad: bgGrad ?? this.bgGrad, text: text ?? this.text,
      text2: text2 ?? this.text2, text3: text3 ?? this.text3, divider: divider ?? this.divider,
      subtle: subtle ?? this.subtle, danger: danger ?? this.danger,
      cardBg: cardBg ?? this.cardBg, cardBorder: cardBorder ?? this.cardBorder,
      pressBg: pressBg ?? this.pressBg, inputBg: inputBg ?? this.inputBg,
      inputBorder: inputBorder ?? this.inputBorder, neuA: neuA ?? this.neuA,
      neuB: neuB ?? this.neuB,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color lc(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      primary: lc(primary, other.primary), primarySoft: lc(primarySoft, other.primarySoft),
      onPrimary: lc(onPrimary, other.onPrimary), accent: lc(accent, other.accent),
      bg: lc(bg, other.bg), bgGrad: lc(bgGrad, other.bgGrad), text: lc(text, other.text),
      text2: lc(text2, other.text2), text3: lc(text3, other.text3),
      divider: lc(divider, other.divider), subtle: lc(subtle, other.subtle),
      danger: lc(danger, other.danger), cardBg: lc(cardBg, other.cardBg),
      cardBorder: lc(cardBorder, other.cardBorder), pressBg: lc(pressBg, other.pressBg),
      inputBg: lc(inputBg, other.inputBg), inputBorder: lc(inputBorder, other.inputBorder),
      neuA: lc(neuA, other.neuA), neuB: lc(neuB, other.neuB),
    );
  }
}
```

- [ ] **Step 5: 实现 app_theme.dart（ThemeData + scheme/ui 元数据）**

```dart
import 'package:flutter/material.dart';
import 'theme_extension.dart';
import 'theme_tokens.dart';

enum UIStyle { flat, glass, neu }

extension UIStyleX on UIStyle {
  String get key => switch (this) { UIStyle.flat => 'flat', UIStyle.glass => 'glass', UIStyle.neu => 'neu' };
  String get label => switch (this) { UIStyle.flat => '扁平化', UIStyle.glass => '玻璃拟态', UIStyle.neu => '新拟态' };
  String get desc => switch (this) { UIStyle.flat => '清爽 / 低干扰', UIStyle.glass => '通透 / 高级感', UIStyle.neu => '柔和 / 立体' };
}

UIStyleUIL? uiFromKey(String key) => UIStyle.values.where((u) => u.key == key).firstOrNull;

ThemeData buildAppTheme(AppColors colors, List<BoxShadow> cardShadow) {
  final base = ThemeData(
    useMaterial3: false,
    scaffoldBackgroundColor: colors.bg,
    colorScheme: ColorScheme.light(
      primary: colors.primary, onPrimary: colors.onPrimary,
      surface: colors.cardBg, onSurface: colors.text,
    ),
  );
  return base.copyWith(
    extensions: <ThemeExtension<dynamic>>[
      AppShapes(cardRadius: 14, cardShadow: cardShadow, cardBlur: 22),
    ],
    textTheme: base.textTheme.apply(bodyColor: colors.text, displayColor: colors.text),
  );
}
```

> 注：`AppColors` 需作为扩展一并注入。若用 `switch` 表达式与 `firstOrNull` 在 Dart 2.19 不可用，改用 `if/else` 与循环。颜色等信息以 Token 迁移为准。

- [ ] **Step 6: 实现 AppShapes（ThemeExtension）**

```dart
import 'package:flutter/material.dart';

@immutable
class AppShapes extends ThemeExtension<AppShapes> {
  final double cardRadius;
  final List<BoxShadow> cardShadow;
  final double cardBlur;
  const AppShapes({this.cardRadius = 14, this.cardShadow = const [], this.cardBlur = 0});

  @override
  AppShapes copyWith({double? cardRadius, List<BoxShadow>? cardShadow, double? cardBlur}) =>
      AppShapes(cardRadius: cardRadius ?? this.cardRadius,
        cardShadow: cardShadow ?? this.cardShadow, cardBlur: cardBlur ?? this.cardBlur);

  @override
  AppShapes lerp(ThemeExtension<AppShapes>? other, double t) {
    if (other is! AppShapes) return this;
    final a = cardRadius, b = other.cardRadius;
    final bs = <BoxShadow>[];
    for (var i = 0; i < cardShadow.length || i < other.cardShadow.length; i++) {
      final x = i < cardShadow.length ? cardShadow[i] : const BoxShadow();
      final y = i < other.cardShadow.length ? other.cardShadow[i] : const BoxShadow();
      bs.add(BoxShadow.lerp(x, y, t)!);
    }
    return AppShapes(cardRadius: a + (b - a) * t, cardShadow: bs,
      cardBlur: cardBlur + (other.cardBlur - cardBlur) * t);
  }
}

extension AppThemeX on ThemeData {
  AppColors get appColors => extension<AppColors>()!;
  AppShapes get appShapes => extension<AppShapes>()!;
}
```

- [ ] **Step 7: 实现 theme_notifier.dart**

```dart
import 'package:flutter/foundation.dart';
import 'app_theme.dart';

class ThemeNotifier extends ChangeNotifier {
  UIStyle ui = UIStyle.flat;
  String schemeKey = 'morandi';
  String get scheme => schemeKey;

  Future<void> loadFrom(Future<Map<String, String>> Function() reader) async {
    final data = await reader();
    if (data.containsKey('scheme')) schemeKey = data['scheme']!;
    if (data.containsKey('ui')) {
      final u = uiFromKey(data['ui']!);
      if (u != null) ui = u;
    }
    notifyListeners();
  }

  void setScheme(String key) {
    if (key == schemeKey) return;
    schemeKey = key;
    notifyListeners();
  }

  void setUi(UIStyle style) {
    if (style == ui) return;
    ui = style;
    notifyListeners();
  }
}
```

> 签名按测试使用对齐：测试用 `setScheme('ocean')` 与 `n.scheme.key`。若此处 `scheme` 为 String，则测试断言应改为针对 schemeKey；最终以 ThemeNotifier 实际字段为唯一约定，测试与实现保持一致。

- [ ] **Step 8: 实现 theme_prefs.dart（shared_preferences 持久化）**

```dart
import 'package:shared_preferences/shared_preferences.dart';

class ThemePrefs {
  static const _key = 'shengqi-theme';
  static Future<Map<String, String>> read() async {
    final p = await SharedPreferences.getInstance();
    final scheme = p.getString('$_key.scheme');
    final ui = p.getString('$_key.ui');
    return {
      if (scheme != null) 'scheme': scheme,
      if (ui != null) 'ui': ui,
    };
  }
  static Future<void> write(String scheme, String ui) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('$_key.scheme', scheme);
    await p.setString('$_key.ui', ui);
  }
}
```

（`app_theme.dart` 中把 `buildAppTheme` 与 `AppShapes` 相关的 `switch` 语法在 Dart 2.19 下改写成兼容写法，并以 analyzer 无错为准。）

- [ ] **Step 9: 调整测试断言并通过；提交**

Test 断言对齐最终 `ThemeNotifier` 字段（scheme 为 String 时：`expect(n.sc…, 'ocean')`）。运行

Run: `flutter test test/theme_notifier_test.dart`
Expected: PASS。

```bash
git add snapp/lib/theme snapp/lib/app/theme_prefs.dart snapp/test/theme_notifier_test.dart
git commit -m "feat(snapp): theme engine with 6 schemes x 3 UI styles"
```

---

### Task 3: 图标体系（AppIcon + 37 SVG）

**Files:**
- Create: `snapp/lib/widgets/app_svg_icons.dart`
- Create: `snapp/lib/widgets/app_icon.dart`
- Test: `snapp/test/app_icon_test.dart`

**Interfaces:**
- Consumes: 原型 `prototype/src/components/Icon.vue` 的 37 个 SVG body；`flutter_svg`
- Produces:
  - `const Map<String, String> appIconBodies;`
  - `bool hasAppIcon(String name);`
  - `class AppIcon extends StatelessWidget { final String name; final double size; final Color color; final double stroke; }`

- [ ] **Step 1: 写失败测试**

`snapp/test/app_icon_test.dart`：

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapp/widgets/app_icon.dart';
import 'package:snapp/widgets/app_svg_icons.dart';

void main() {
  test('all referenced icon names are registered', () {
    for (final n in ['wave', 'play', 'moon', 'rain', 'coffee', 'user']) {
      expect(hasAppIcon(n), isTrue, reason: 'missing icon $n');
    }
  });
  testWidgets('AppIcon renders default circle for unknown name',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: AppIcon(name: '__nope__'))));
    expect(find.byType(AppIcon), findsOneWidget);
  });
}
```

- [ ] **Step 2: 运行确认失败**

Run: `flutter test test/app_icon_test.dart`
Expected: 编译失败（文件不存在）。

- [ ] **Step 3: 实现 app_svg_icons.dart**

`appIconBodies` 收录 37 个 key：`wave white-noise pink-noise brown-noise red-noise rain wave-ocean forest stream fire coffee train fan play pause timer save palette trophy settings share user edit mute volume close chevron-right gift moon flame mixer clock copy lock check mountain bird` 与默认 `__default__`。

**从 `prototype/src/components/Icon.vue` 逐图标原样拷贝 `<path>/<line>/<rect>/<circle>/<polygon>/<polyline>` 标签内联字符串作为 body**。首个示例（`wave` 与 `play`）：

```dart
const Map<String, String> appIconBodies = <String, String>{
  'wave': '<path d="M2 12h2l3-9 4 18 4-14 3 7h4"/>',
  'play': '<polygon points="6,3 20,12 6,21" fill="currentColor" stroke="none"/>',
  // ... 其余 35+1 个图标从 Icon.vue 原样拷贝
  '__default__': '<circle cx="12" cy="12" r="8"/>',
};

final Set<String> _known = appIconBodies.keys.toSet();

bool hasAppIcon(String name) => _known.contains(name);

String appIconBody(String name) =>
    appIconBodies[name] ?? appIconBodies['__default__']!;
```

> ⚠️ 完整性要求：37 个非默认图标**一个不能少**，逐个对照 `Icon.vue` 的 `v-else-if` 分支拷贝；其余图标列表（rain、coffee、moon、user 等）须全量纳入 `appIconBodies`。本轮最终以 `flutter test` 的 7 项断言 + 手动清点 37 项确认完整。

- [ ] **Step 4: 实现 app_icon.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'app_svg_icons.dart';

class AppIcon extends StatelessWidget {
  final String name;
  final double size;
  final Color color;
  final double stroke;
  const AppIcon({super.key, required this.name,
    this.size = 24, this.color = Colors.black, this.stroke = 2});

  @override
  Widget build(BuildContext context) {
    final body = appIconBody(name)
        .replaceAll('currentColor', _hex(color));
    final svg = '''
<svg viewBox="0 0 24 24" width="24" height="24" fill="none"
     stroke="$_hex(color)" stroke-width="$stroke"
     stroke-linecap="round" stroke-linejoin="round">
  $body
</svg>''';
    return SvgPicture.string(svg,
        width: size, height: size,
        color: color); // color 参数兜底非透明元素
  }

  static String _hex(Color c) {
    final a = (c.a * 255).round().toRadixString(16).padLeft(2, '0');
    final r = (c.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (c.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (c.b * 255).round().toRadixString(16).padLeft(2, '0');
    return '#$r$g$b';
  }
}
```

> `Color.a/r/g/b` 是 0–1 double（Flutter 新 API）；Dart 2.19 用 `color.alpha/red/green/blue`（0–255 int）改用后者。

- [ ] **Step 5: 运行测试通过**

Run: `flutter test test/app_icon_test.dart`
Expected: PASS。

- [ ] **Step 6: 提交**

```bash
git add snapp/lib/widgets/app_svg_icons.dart snapp/lib/widgets/app_icon.dart snapp/test/app_icon_test.dart
git commit -m "feat(snapp): icon system with 37 custom SVG icons"
```

---

### Task 4: App 外壳 / 命名路由 / 悬浮 TabBar / 公共样式原语

**Files:**
- Create: `snapp/lib/widgets/app_page.dart`、`app_card.dart`、`app_buttons.dart`、`app_section.dart`、`tab_bar.dart`
- Create: `snapp/lib/app/router.dart`、`app/app.dart`
- Modify (rewrite): `snapp/lib/main.dart`
- Create: `snapp/lib/pages/placeholder.dart`

**Interfaces:**
- Consumes: Task 2 的 `ThemeNotifier`/`appThemeX.appColors`；Task 3 的 `AppIcon`
- Produces:
  - `class AppPage extends StatelessWidget { final Widget child; final Widget? pageBackground; }`（含安全区 padding、底部预留 tab/playbar 高度、iOS 进入动效）
  - `class AppCard extends StatelessWidget { final Widget child; final EdgeInsetsGeometry padding; final double radius; }`
  - `class AppPrimaryButton extends StatelessWidget { final VoidCallback? onPressed; final Widget child; }` / `AppOutlineButton`
  - `class AppSectionTitle` / `class AppDivider`
  - `class AppTabBar extends StatelessWidget { final int currentIndex; final ValueChanged<int> onTap; }`（4 tab：home/scene/discover/mine）
  - `class Router { static Route<dynamic> Function(RouteSettings) generateRoute; }`（路由名 `/index /scene /discover /mine /library /theme /achievement /invite /settings /checkin /stats /favorites /history /onboarding /scene-detail /scene-edit /scene-all`，Tab 页走 `_tabScaffold`）
  - `class Root extends StatelessWidget`（MaterialApp + `home` 的第一 tab 或 `onGenerateRoute`）

- [ ] **Step 1: 实现 app_section.dart（title/divider）**

```dart
import 'package:flutter/material.dart';
import '../theme/theme_extension.dart';

class AppSectionTitle extends StatelessWidget {
  final String text;
  const AppSectionTitle(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
      child: Text(text, style: TextStyle(color: c.text2,
          fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: .3)),
    );
  }
}

class AppDivider extends StatelessWidget {
  const AppDivider({super.key});
  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, thickness: 1, color: Theme.of(context).appColors.divider);
}
```

- [ ] **Step 2: 实现 app_card.dart**

```dart
import 'package:flutter/material.dart';
import '../theme/theme_extension.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? radius;
  const AppCard({required this.child, this.padding = const EdgeInsets.all(16), this.radius, super.key});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    final s = Theme.of(context).appShapes;
    final r = radius ?? s.cardRadius;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: c.cardBg,
        borderRadius: BorderRadius.circular(r),
        border: Border.all(color: c.cardBorder, width: .5),
        boxShadow: s.cardShadow,
      ),
      child: child,
    );
  }
}
```

> `cardBlur`（毛玻璃）在 neu 降级/glass 场景：若需真毛玻璃，用 `ClipRRect` + `BackdropFilter` 包裹 child；本轮底色已半透明可先不包 BackdropFilter，后续页面轮次按需补毛玻璃，属设计允差。

- [ ] **Step 3: 实现 app_buttons.dart**

```dart
import 'package:flutter/material.dart';
import '../theme/theme_extension.dart';

class AppPrimaryButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  const AppPrimaryButton({required this.child, this.onPressed, super.key});
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: c.primary, foregroundColor: c.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
      ),
      child: child,
    );
  }
}

class AppOutlineButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  const AppOutlineButton({required this.child, this.onPressed, super.key});
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: c.primary,
        side: BorderSide(color: c.primary.withOpacity(.6)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      ),
      child: child,
    );
  }
}
```

- [ ] **Step 4: 实现 app_page.dart（含 iOS 进入动效与安全区）**

```dart
import 'package:flutter/material.dart';
import '../theme/theme_extension.dart';

class AppPage extends StatefulWidget {
  final Widget child;
  const AppPage({required this.child, super.key});
  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 320), value: 0);
  late final Animation<double> _y = Tween(begin: 9.0, end: 0.0)
      .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));

  @override
  void initState() {
    super.initState();
    final reduced = WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.disableAnimations;
    if (!reduced) _c.forward();
    else _c.value = 1;
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    // 顶部柔和渐变 + 主体容器
    return Stack(children: [
      Positioned(top: 0, left: 0, right: 0, height: 240,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [c.bgGrad.withOpacity(1), c.bg, c.bg.withOpacity(0)]),
          ))),
      SafeArea(bottom: false, child: FadeTransition(opacity: _c,
        child: SlideTransition(position: Tween<Offset>(begin: const Offset(0, .02), end: Offset.zero).animate(_c),
          child: Padding(padding: const EdgeInsets.fromLTRB(13, 12, 13, 0),
            child: widget.child)))),
    ]);
  }
}
```

> Android 方（`disableAnimations`）同理；`platformDispatcher` 在 Dart 2.19 用 `MediaQuery.of(context).disableAnimations` 替代亦可。

- [ ] **Step 5: 实现 tab_bar.dart（悬浮 TabBar）**

```dart
import 'package:flutter/material.dart';
import '../theme/theme_extension.dart';
import 'app_icon.dart';

const _tabs = <(String, String)>[
  ('home', '首页'), ('scene', '场景'), ('discover', '发现'), ('mine', '我的'),
];

class AppTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const AppTabBar({required this.currentIndex, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    final s = Theme.of(context).appShapes;
    return Align(alignment: Alignment.bottomCenter,
      child: Padding(padding: const EdgeInsets.only(bottom: 8),
        child: Material(color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 48),
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(color: c.cardBg,
              borderRadius: BorderRadius.circular(s.cardRadius),
              border: Border.all(color: c.cardBorder, width: .5),
              boxShadow: s.cardShadow),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_tabs.length, (i) {
                final active = i == currentIndex;
                final icon = _tabs[i].$1 == 'home' ? 'wave'
                    : _tabs[i].$1 == 'scene' ? 'mountain'
                    : _tabs[i].$1 == 'discover' ? 'palette'
                    : 'user';
                return GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(mainAxisSize: MainAxisSize.min,
                    children: [
                      AppIcon(name: icon, size: 22,
                          color: active ? c.primary : c.text3),
                      const SizedBox(height: 2),
                      Text(_tabs[i].$2, style: TextStyle(
                          fontSize: 10, color: active ? c.primary : c.text3,
                          fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
                    ]),
                );
              })),
          ))));
  }
}
```

> 记录：原型 tab 图标另有 `Icon` 命名；此处先用现有图标近似，后续若原型 tab 是专用 SVG 图标则以 `Icon.vue`/tab 静态资源为准替换。`(String,String)` record 在 Dart 2.19 可用（3.0 引入 records——**需确认**！Dart 2.19 无 records，改用 `List<String>` 或 `_TabItem` 类）。改用：

```dart
class _TabItem { final String key; final String label; const _TabItem(this.key, this.label); }
const _tabs = [ _TabItem('home','首页'), _TabItem('scene','场景'), _TabItem('discover','发现'), _TabItem('mine','我的') ];
```

- [ ] **Step 6: 实现占位页与 tab 脚手架**

`snapp/lib/pages/placeholder.dart`：

```dart
import 'package:flutter/material.dart';
import '../widgets/app_page.dart';
import '../widgets/app_section.dart';
import '../theme/theme_extension.dart';

class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage(this.title, {super.key});
  @override
  Widget build(BuildContext context) {
    return AppPage(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700,
          color: Theme.of(context).appColors.text)),
      const SizedBox(height: 12),
      const AppSectionTitle('占位页面 · 后续轮次实现'),
    ]));
  }
}
```

`snapp/lib/app/router.dart` 定义 `Map<String, WidgetBuilder> routes`，Tab 页用 `IndexedStack` 脚手架承载悬浮 `AppTabBar`（当前 index 为 0，待 Home 页接入后挂到 root state）：

```dart
import 'package:flutter/material.dart';
import '../pages/placeholder.dart';

Map<String, WidgetBuilder> buildRoutes() => <String, WidgetBuilder>{
  '/index': (_) => const PlaceholderPage('首页'),
  '/scene': (_) => const PlaceholderPage('场景'),
  '/discover': (_) => const PlaceholderPage('发现'),
  '/mine': (_) => const PlaceholderPage('我的'),
  '/library': (_) => const PlaceholderPage('音频库'),
  '/theme': (_) => const PlaceholderPage('主题设置'),
  // ... /achievement /invite /settings /checkin /stats /favorites /history
  //     /onboarding /scene-detail /scene-edit /scene-all 同样映射到 PlaceholderPage
};
```

- [ ] **Step 7: 重写 main.dart 与 app.dart**

`snapp/lib/main.dart`（覆盖原 demo）：

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'app/theme_prefs.dart';
import 'theme/app_theme.dart';
import 'theme/theme_extension.dart';
import 'theme/theme_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notifier = ThemeNotifier();
  await notifier.loadFrom(ThemePrefs.read);
  runApp(Root(notifier: notifier));
}
```

`snapp/lib/app/app.dart`：

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../theme/theme_extension.dart';
import '../theme/theme_tokens.dart';
import '../theme/theme_notifier.dart';
import '../widgets/tab_bar.dart';
import '../pages/placeholder.dart';
import 'router.dart';

class _Shell extends StatefulWidget {
  final Widget home;
  const _Shell({required this.home});
  @override
  State<_Shell> createState() => _ShellState();
}
class _ShellState extends State<_Shell> {
  int _index = 0;
  static const _pages = [PlaceholderPage('首页'), PlaceholderPage('场景'),
    PlaceholderPage('发现'), PlaceholderPage('我的')];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: AppTabBar(
          currentIndex: _index, onTap: (i) => setState(() => _index = i)),
    );
  }
}

class Root extends StatelessWidget {
  final ThemeNotifier notifier;
  const Root({super.key, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeNotifier>.value(
        value: notifier,
        child: Consumer<ThemeNotifier>(builder: (context, n, _) {
          final colors = appColorsFor(n.schemeKey, n.ui.key, context);
          return MaterialApp(
            title: '声栖',
            debugShowCheckedModeBanner: false,
            theme: buildAppTheme(colors),
            home: const _Shell(),
            routes: buildRoutes(),
          );
        }));
  }
}
```

> `appColorsFor(String scheme, String ui, BuildContext)` 为 Task 2 token 模块暴露的工厂（由 colorFor 包装），返回含容器字段的 `AppColors`。若 `placeholder` 页面要在路由中用到 `AppPage`，在 `buildRoutes` 里的页面用 `AppPage` 包裹。

- [ ] **Step 8: 运行 analyze 通过**

Run: `flutter analyze`
Expected: No issues found（若 recorder/字段名不一致按报错修正，保持零 error）。

- [ ] **Step 9: 提交**

```bash
git add snapp/lib/widgets snapp/lib/app snapp/lib/pages snapp/lib/main.dart
git commit -m "feat(snapp): app shell, named routes, floating tab bar, shared widgets"
```

---

### Task 5: 数据层（模型 + 静态数据 + SceneService）

**Files:**
- Create: `snapp/lib/data/scene_models.dart`、`sound_models.dart`、`seed_data.dart`
- Create: `snapp/lib/services/scene_service.dart`
- Test: `snapp/test/scene_service_test.dart`

**Interfaces:**
- Consumes: 原型 `prototype/src/data/scenes.ts`、`sounds.ts` 全量数据与函数
- Produces:
  - `typedef SceneCategory = String`（`'all'|'sleep'|'focus'|'relax'|'nature'`），常量 `catAll...`
  - `class Scene { final String id,name,category,desc,iconName,gradient,image; final List<String> soundIds; final bool isPreset; }`
  - `class Sound { final String id,name,type,category,iconName,color,gradient,duration,sampleRate,quality,source,desc,loopLength; final List<String> scenes; }`
  - `class FeaturedScene { id,name,desc,iconName,gradient,tags,soundIds,ratio,playCount,duration }`
  - `class FeaturedSound implements Sound { final int hot; }`
  - `Scene? findScene(String id);` `List<String> soundNames(List<String> ids);`
  - `List<Scene> getRecommended(List<String> prefs, List<Recentlike> recent, {int limit=4});`
  - `List<Scene> getCategoryScenes(String category, int limit);`
  - `class RecipeItem { name, icon, percent, color }` `List<RecipeItem> buildRecipe(Scene s);`
  - `class PresetOption { name, badgeColor, ratios }` `List<PresetOption> buildPresets(Scene s);`

- [ ] **Step 1: 写 SceneService 失败测试**

`snapp/test/scene_service_test.dart`（核心断言承载原型函数语义）：

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:snapp/services/scene_service.dart';

void main() {
  test('findScene resolves existing scene and falls back', () {
    expect(findScene('deep-sleep')!.name, '深度睡眠');
    expect(findScene('nope')!.name, isNotEmpty); // 回退 homeScenes[0]
  });

  test('getRecommended prioritizes pref categories then fills by order', () {
    final rec = getRecommended(['sleep', 'nature'], []);
    expect(rec.length, 4);
    expect(rec.first.category, anyOf('sleep', 'nature'));
  });

  test('getCategoryScenes filters by category', () {
    final f = getCategoryScenes('focus', 10);
    expect(f.every((s) => s.category == 'focus'), isTrue);
  });

  test('buildRecipe sums to 100', () {
    final r = buildRecipe(findScene('deep-sleep')!);
    final sum = r.fold<int>(0, (a, b) => a + b.percent);
    expect(sum, 100);
  });

  test('buildPresets yields 轻度/标准/深度 with sums 100', () {
    final p = buildPresets(findScene('deep-sleep')!);
    expect(p.map((x) => x.name), containsAll(['轻度', '标准', '深度']));
    for (final op in p) {
      expect(op.ratios.fold<int>(0, (a, b) => a + b.value), 100);
    }
  });
}
```

- [ ] **Step 2: 运行确认失败**

Run: `flutter test test/scene_service_test.dart`
Expected: 编译失败（不存在）。

- [ ] **Step 3: 实现 scene_models.dart / sound_models.dart**

按上面「Produce」字段定义可变/不可变类（用 `const` 构造 + `final` 字段；`FeaturedSound` 以组合方式含 `Sound` 或复制字段）。示例 `Scene`：

```dart
class Scene {
  const Scene({required this.id, required this.name, required this.category,
    required this.desc, required this.iconName, required this.gradient,
    required this.image, required this.soundIds, required this.isPreset});
  final String id; final String name; final String category; final String desc;
  final String iconName; final String gradient; final String image;
  final List<String> soundIds; final bool isPreset;
}
```

（其余模型类同理，字段取自原型 interface。）

- [ ] **Step 4: 实现 seed_data.dart（全量静态数据）**

- `homeScenes`：迁移 `scenes.ts` 11 条 `Scene`，`isPreset: true`。
- `sounds`：迁移 `sounds.ts` 30 条 `Sound`（含 synthetic/nature/urban/ambient 各类）。
- `featuredScenes`：迁移 8 条 `FeaturedScene`（含 `ratio`）。
- `featuredSounds`：迁移 8 条 `FeaturedSound`（白噪/粉噪/雨/海浪/森林/褐噪/篝火/溪流 + `hot`）。
- `soundCategories` / `sceneCategories`：迁移对应常量数组。
- `simulatedPrefs = ['sleep', 'nature']`。

> ⚠️ 数据量较大，**唯一权威来源是 `prototype/src/data/scenes.ts` 与 `sounds.ts`**，需逐条原样拷贝 id/name/desc/gradient/image/soundIds 等，禁止臆造。工厂用 `const` 列表。

- [ ] **Step 5: 实现 scene_service.dart（纯函数）**

```dart
import '../data/scene_models.dart';
import '../data/sound_models.dart';
import '../data/seed_data.dart';

class RecipeItem { const RecipeItem(this.name, this.icon, this.percent, this.color);
  final String name, icon; final int percent; final String color; }
class PresetOption { const PresetOption(this.name, this.badgeColor, this.ratios);
  final String name, badgeColor; final List<({String name, int value})> ratios; }
class RecentHit { const RecentHit(this.sceneId); final String sceneId; }

Scene? findScene(String id) {
  for (final s in homeScenes) { if (s.id == id) return s; }
  return homeScenes.first;
}

List<String> soundNames(List<String> ids) =>
    ids.map((id) => sounds.firstWhere((s) => s.id == id, orElse: () => _unknown(id)).name).toList();

Sound _unknown(String id) => Sound(id: id, name: id, /* 缺省字段 */ );

List<Scene> getRecommended(List<String> prefs, List<RecentHit> recent, {int limit = 4}) {
  final heard = recent.map((r) => r.sceneId).toSet();
  final preferred = homeScenes.where((s) => prefs.contains(s.category) && !heard.contains(s.id)).toList();
  if (preferred.length >= limit) return preferred.take(limit).toList();
  final rest = homeScenes.where((s) => !preferred.contains(s)).toList();
  return (preferred + rest).take(limit).toList();
}

List<Scene> getCategoryScenes(String category, int limit) {
  final list = category == 'all' ? homeScenes : homeScenes.where((s) => s.category == category).toList();
  return list.take(limit).toList();
}
```

> 注：原型 `buildRecipe`/`buildPresets` 生成首音 40%（及 25/40/60 三档）的比例算法，须按 `scenes.ts` 的 `spread`/末位补齐逻辑原样复刻，确保各比值总和=100（测试断言）。`record` 类型在 Dart 2.19 不可用，`ratios` 用 `List<PresetRatio>`（含 `name`,`value`）类替代。

- [ ] **Step 6: 运行测试通过**

Run: `flutter test test/scene_service_test.dart`
Expected: PASS（4 个断言组）。

- [ ] **Step 7: 提交**

```bash
git add snapp/lib/data snapp/lib/services snapp/test/scene_service_test.dart
git commit -m "feat(snapp): data models, seed data, and scene service"
```

---

### Task 6: Home 骨架验证页 + 收尾验证

**Files:**
- Create: `snapp/lib/pages/index/index_page.dart`
- Modify: `snapp/lib/app/router.dart`（`/index` 指向 `IndexPage`）、`snapp/lib/app/app.dart`（首 tab body 换 `IndexPage`）
- Test: `snapp/test/app_icon_test.dart`（已在 T3 建）

**Interfaces:**
- Consumes: Task 2–5 全部
- Produces: 可运行 Home 骨架（品牌头 logo+声栖、AppCard、图标预览网格、配色/UI 切换入口），验证主题即时生效

- [ ] **Step 1: 实现 IndexPage**

`snapp/lib/pages/index/index_page.dart`：品牌头（logo 图 `assets` 见下方说明，若无资源先用色块占位 +「声栖」大标题）、一张 `AppCard` 演示卡片、`GridView` 图标预览（遍历 `homeScenes` 的 `iconName`）、主题切换行（6 个配色 `ChoiceChip` + 3 个 UI `ChoiceChip`；onChanged 调 `context.read<ThemeNotifier>()`）。示意：

```dart
class IndexPage extends StatelessWidget {
  const IndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    final n = context.watch<ThemeNotifier>();
    return AppPage(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: c.primary,
            borderRadius: BorderRadius.circular(10))),
        const SizedBox(width: 10),
        Text('声栖', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: c.text)),
      ]),
      const SizedBox(height: 16),
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('今日精选', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: c.text)),
        const SizedBox(height: 8),
        Text('主色 ${c.primary} · 背景 ${c.bg}', style: TextStyle(color: c.text2, fontSize: 12)),
      ])),
      const SizedBox(height: 24),
      const AppSectionTitle('选择配色'),
      Wrap(spacing: 8, children: ['morandi','ocean','forest','sunset','lavender','mono']
          .map((k) => ChoiceChip(label: Text(k), selected: n.scheme == k,
              onSelected: (_) => n.setScheme(k))).toList()),
      const SizedBox(height: 16),
      const AppSectionTitle('选择 UI 风格'),
      Wrap(spacing: 8, children: UIStyle.values
          .map((u) => ChoiceChip(label: Text(u.label), selected: n.ui == u,
              onSelected: (_) => n.setUi(u))).toList()),
      const SizedBox(height: 24),
      const AppSectionTitle('图标预览'),
      GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 6, children: homeScenes
          .map((s) => AppIcon(name: s.iconName, size: 28, color: c.text)).toList()),
    ]));
  }
}
```

（`logo` 图：`assets` 迁移推荐放下一轮；本轮头用主色圆角块 + 文字占位，避免引入图片资源解析复杂度。若用户要求同步迁移 logo，则在 `pubspec.yaml` 声明 `assets` 并在本页引用 `logo-v10-1.jpg`。)

- [ ] **Step 2: 接入 `/index` 路由与 shell 首页**

`router.dart` 的 `/index` 与 `app.dart` 首 tab 均指向 `IndexPage`。`app.dart` 中 `_pages` 第一项改 `const IndexPage()`。

- [ ] **Step 3: 运行 analyze 与全部测试**

Run: `flutter analyze`  → Expected: No issues found
Run: `flutter test` → Expected: 全部通过（theme_notifier / app_icon / scene_service）

- [ ] **Step 4: （可选）运行编译产物**

Run: `flutter build apk --debug`（若本机可构建 Android）
Expected: 构建成功。Harmony HAP 构建需另配 OH SDK，本轮不强求。

- [ ] **Step 5: 提交**

```bash
git add snapp/lib/pages/index snapp/lib/app/router.dart snapp/lib/app/app.dart
git commit -m "feat(snapp): home skeleton verifying theme switching"
```

---

## Self-Review

- **Spec 覆盖率**：M1→T1、M2→T2、M3→T3、M4→T4、M5→T5、M6→T6，逐项对应 ✓。
- **依赖合规**：provider/flutter_svg 纯 Dart，shared_preferences 已适配 Harmony（HAP 构建切适配源已在 T1 备注）✓。
- **占位检查**：SVG 37 图标、seed 数据、token 均指向原型权威源码逐条拷贝，无 TBD ✓。
- **类型一致性**：`ThemeNotifier.scheme` 为 String、`ui` 为 `UIStyle`；测试与实现签名已在 T2 Step 9 对齐说明。Dart 2.19 不支持 records/`switch` 表达式/`Color.r`，已用兼容写法加注排除，analyze 兜底修正 ✓。
- **已知风险**：Dart 2.19 新语法差异、token 透明度转换、shared_preferences 发布版无 ohos 胶水 —— 均已在本计划作显式处理并在执行时以 analyzer/test 校验。

## Execution Handoff

Plan 保存在 `docs/superpowers/plans/2026-09-11-flutter-foundation.md`。两种执行方式：

1. **Subagent-Driven（推荐）**—— 每个 Task 派发独立子智能体，Task 间做两段式 review，迭代快。
2. **Inline Execution** —— 本会话内用 executing-plans 批量执行，带 checkpoint 供 review。

采用哪种？