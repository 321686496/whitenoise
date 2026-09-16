import 'package:flutter/material.dart';

/// 声栖 · v2 主题 Token（L0 基础色板 + L2 风格覆写）
///
/// 唯一权威来源：`prototype/src/theme/index.ts`（v2 三维主题：
/// 配色 × UI 风格 × 明暗）。所有色值逐条拷贝，禁止臆造。

/// 配色方案 key（与原型 `SchemeKey` 对齐）
const String schemeMorandi = 'morandi';
const String schemeOcean = 'ocean';
const String schemeForest = 'forest';
const String schemeSunset = 'sunset';
const String schemeLavender = 'lavender';
const String schemeMono = 'mono';

/// 配色方案列表（显示顺序即原型 `SCHEME_KEYS` 顺序）
const List<String> schemeKeys = <String>[
  schemeMorandi,
  schemeOcean,
  schemeForest,
  schemeSunset,
  schemeLavender,
  schemeMono,
];

/// 配色方案的元信息
class ThemeSchemeMeta {
  final String label;
  final String desc;
  const ThemeSchemeMeta(this.label, this.desc);
}

const Map<String, ThemeSchemeMeta> schemeLabels = <String, ThemeSchemeMeta>{
  schemeMorandi: ThemeSchemeMeta('莫兰迪', '森系柔和的低饱和配色'),
  schemeOcean: ThemeSchemeMeta('深海', '深邃冷静的靛蓝夜色'),
  schemeForest: ThemeSchemeMeta('森林', '自然清新的苔绿色调'),
  schemeSunset: ThemeSchemeMeta('日落', '温暖治愈的暮橙色调'),
  schemeLavender: ThemeSchemeMeta('薰衣草', '温柔静谧的淡紫配色'),
  schemeMono: ThemeSchemeMeta('极简黑白', '克制统一的黑白灰'),
};

/// L0 基础色板（对应原型 `Palette`，每配色 × 明暗一组，共 12 组）
class PaletteT {
  final Color bg;
  final Color bgGrad;
  final Color surface;
  final Color surface2;
  final Color sunken;
  final Color t1;
  final Color t2;
  final Color t3;
  final Color line;
  final Color lineStrong;
  final Color primary;
  final Color primaryStrong;
  final Color onPrimary;
  final Color accent;
  final Color overlay;

  /// scrim 基色 RGB（用于运行时按透明度生成阴影色）
  final int scrimR;
  final int scrimG;
  final int scrimB;
  final Color neuA;
  final Color neuB;
  final Color glass;
  final Color glassLine;
  final Color hl;
  final Color danger;
  final Color success;
  final Color warning;

  const PaletteT({
    required this.bg,
    required this.bgGrad,
    required this.surface,
    required this.surface2,
    required this.sunken,
    required this.t1,
    required this.t2,
    required this.t3,
    required this.line,
    required this.lineStrong,
    required this.primary,
    required this.primaryStrong,
    required this.onPrimary,
    required this.accent,
    required this.overlay,
    required this.scrimR,
    required this.scrimG,
    required this.scrimB,
    required this.neuA,
    required this.neuB,
    required this.glass,
    required this.glassLine,
    required this.hl,
    required this.danger,
    required this.success,
    required this.warning,
  });
}

/* ---------------------------- morandi ---------------------------- */
const PaletteT _morandiLight = PaletteT(
  bg: Color(0xFFF4F2EC), bgGrad: Color(0xFFEAE6DC), surface: Color(0xFFFFFFFF),
  surface2: Color(0xFFEDEAE1), sunken: Color(0xFFE9E5DA),
  t1: Color(0xFF26302B), t2: Color(0xFF66756D), t3: Color(0xFF9AA69F),
  line: Color(0xFFE5E0D5), lineStrong: Color(0xFFD6D0C3),
  primary: Color(0xFF3D6B5E), primaryStrong: Color(0xFF2F544A), onPrimary: Color(0xFFFFFFFF),
  accent: Color(0xFF8FB8A0),
  overlay: Color.fromRGBO(24, 32, 28, 0.42), scrimR: 24, scrimG: 32, scrimB: 28,
  neuA: Color.fromRGBO(90, 110, 100, 0.18), neuB: Color.fromRGBO(255, 255, 255, 0.9),
  glass: Color.fromRGBO(255, 255, 255, 0.64), glassLine: Color.fromRGBO(255, 255, 255, 0.85),
  hl: Colors.transparent,
  danger: Color(0xFFB4544C), success: Color(0xFF4A8F6B), warning: Color(0xFFB98A3E),
);
const PaletteT _morandiDark = PaletteT(
  bg: Color(0xFF101513), bgGrad: Color(0xFF18211D), surface: Color(0xFF1A221F),
  surface2: Color(0xFF222B27), sunken: Color(0xFF0C1210),
  t1: Color(0xFFE8EDEA), t2: Color(0xFFA3B2AA), t3: Color(0xFF6E7D76),
  line: Color(0xFF26312C), lineStrong: Color(0xFF37443D),
  primary: Color(0xFF7FBFAA), primaryStrong: Color(0xFF5EA88F), onPrimary: Color(0xFF0C1512),
  accent: Color(0xFF6FA892),
  overlay: Color.fromRGBO(0, 0, 0, 0.62), scrimR: 0, scrimG: 0, scrimB: 0,
  neuA: Color.fromRGBO(0, 0, 0, 0.45), neuB: Color.fromRGBO(255, 255, 255, 0.055),
  glass: Color.fromRGBO(255, 255, 255, 0.07), glassLine: Color.fromRGBO(255, 255, 255, 0.13),
  hl: Color.fromRGBO(255, 255, 255, 0.055),
  danger: Color(0xFFE0837B), success: Color(0xFF6FC295), warning: Color(0xFFE0AA5E),
);

/* ---------------------------- ocean ---------------------------- */
const PaletteT _oceanLight = PaletteT(
  bg: Color(0xFFEFF4F5), bgGrad: Color(0xFFE2EDEF), surface: Color(0xFFFFFFFF),
  surface2: Color(0xFFE6EFF1), sunken: Color(0xFFDFEAEC),
  t1: Color(0xFF0F2833), t2: Color(0xFF5A7480), t3: Color(0xFF93A8B0),
  line: Color(0xFFDCE7EA), lineStrong: Color(0xFFC6D8DD),
  primary: Color(0xFF2F7F86), primaryStrong: Color(0xFF1F5F65), onPrimary: Color(0xFFFFFFFF),
  accent: Color(0xFF7FC4C4),
  overlay: Color.fromRGBO(15, 40, 51, 0.42), scrimR: 15, scrimG: 40, scrimB: 51,
  neuA: Color.fromRGBO(60, 110, 120, 0.18), neuB: Color.fromRGBO(255, 255, 255, 0.92),
  glass: Color.fromRGBO(255, 255, 255, 0.66), glassLine: Color.fromRGBO(255, 255, 255, 0.88),
  hl: Colors.transparent,
  danger: Color(0xFFB4544C), success: Color(0xFF3E8C6E), warning: Color(0xFFB98A3E),
);
const PaletteT _oceanDark = PaletteT(
  bg: Color(0xFF0B1A21), bgGrad: Color(0xFF122831), surface: Color(0xFF13242C),
  surface2: Color(0xFF1B2F38), sunken: Color(0xFF091820),
  t1: Color(0xFFE4F1F3), t2: Color(0xFF9DB6BF), t3: Color(0xFF6A858F),
  line: Color(0xFF22333C), lineStrong: Color(0xFF33474F),
  primary: Color(0xFF6FC9CE), primaryStrong: Color(0xFF4FA9AF), onPrimary: Color(0xFF04171C),
  accent: Color(0xFF4FA3A8),
  overlay: Color.fromRGBO(0, 0, 0, 0.62), scrimR: 0, scrimG: 0, scrimB: 0,
  neuA: Color.fromRGBO(0, 0, 0, 0.48), neuB: Color.fromRGBO(120, 190, 200, 0.06),
  glass: Color.fromRGBO(255, 255, 255, 0.07), glassLine: Color.fromRGBO(255, 255, 255, 0.14),
  hl: Color.fromRGBO(255, 255, 255, 0.05),
  danger: Color(0xFFE0837B), success: Color(0xFF6FC295), warning: Color(0xFFE0AA5E),
);

/* ---------------------------- forest ---------------------------- */
const PaletteT _forestLight = PaletteT(
  bg: Color(0xFFF1F4EA), bgGrad: Color(0xFFE4EBD9), surface: Color(0xFFFFFFFF),
  surface2: Color(0xFFE9EFDF), sunken: Color(0xFFE2E9D6),
  t1: Color(0xFF25301F), t2: Color(0xFF5F7053), t3: Color(0xFF96A48A),
  line: Color(0xFFE0E7D4), lineStrong: Color(0xFFCBD6B9),
  primary: Color(0xFF3F6B34), primaryStrong: Color(0xFF2C4E24), onPrimary: Color(0xFFFFFFFF),
  accent: Color(0xFF8FB071),
  overlay: Color.fromRGBO(37, 48, 31, 0.42), scrimR: 37, scrimG: 48, scrimB: 31,
  neuA: Color.fromRGBO(70, 95, 55, 0.18), neuB: Color.fromRGBO(255, 255, 255, 0.92),
  glass: Color.fromRGBO(255, 255, 255, 0.66), glassLine: Color.fromRGBO(255, 255, 255, 0.88),
  hl: Colors.transparent,
  danger: Color(0xFFB4544C), success: Color(0xFF3F7A4E), warning: Color(0xFFB98A3E),
);
const PaletteT _forestDark = PaletteT(
  bg: Color(0xFF12170F), bgGrad: Color(0xFF1A2216), surface: Color(0xFF1A2016),
  surface2: Color(0xFF232B1D), sunken: Color(0xFF0F140D),
  t1: Color(0xFFEAF0E3), t2: Color(0xFFA6B598), t3: Color(0xFF728068),
  line: Color(0xFF27301F), lineStrong: Color(0xFF38432D),
  primary: Color(0xFF8FC46F), primaryStrong: Color(0xFF6EA64F), onPrimary: Color(0xFF0E1509),
  accent: Color(0xFF6EA34F),
  overlay: Color.fromRGBO(0, 0, 0, 0.62), scrimR: 0, scrimG: 0, scrimB: 0,
  neuA: Color.fromRGBO(0, 0, 0, 0.48), neuB: Color.fromRGBO(180, 230, 150, 0.06),
  glass: Color.fromRGBO(255, 255, 255, 0.07), glassLine: Color.fromRGBO(255, 255, 255, 0.13),
  hl: Color.fromRGBO(255, 255, 255, 0.05),
  danger: Color(0xFFE0837B), success: Color(0xFF8FD08A), warning: Color(0xFFE0AA5E),
);

/* ---------------------------- sunset ---------------------------- */
const PaletteT _sunsetLight = PaletteT(
  bg: Color(0xFFFBF3EA), bgGrad: Color(0xFFF5E7D6), surface: Color(0xFFFFFFFF),
  surface2: Color(0xFFF7ECE0), sunken: Color(0xFFF2E5D6),
  t1: Color(0xFF3A2A20), t2: Color(0xFF7A6455), t3: Color(0xFFAC9683),
  line: Color(0xFFF0E2D2), lineStrong: Color(0xFFDFCAB2),
  primary: Color(0xFFB4603C), primaryStrong: Color(0xFF8E482B), onPrimary: Color(0xFFFFFFFF),
  accent: Color(0xFFE3A377),
  overlay: Color.fromRGBO(58, 42, 32, 0.42), scrimR: 58, scrimG: 42, scrimB: 32,
  neuA: Color.fromRGBO(130, 90, 60, 0.18), neuB: Color.fromRGBO(255, 255, 255, 0.92),
  glass: Color.fromRGBO(255, 255, 255, 0.66), glassLine: Color.fromRGBO(255, 255, 255, 0.88),
  hl: Colors.transparent,
  danger: Color(0xFFA94F45), success: Color(0xFF4A8F6B), warning: Color(0xFFB98A3E),
);
const PaletteT _sunsetDark = PaletteT(
  bg: Color(0xFF1A1310), bgGrad: Color(0xFF261A14), surface: Color(0xFF241A16),
  surface2: Color(0xFF2E221C), sunken: Color(0xFF150F0C),
  t1: Color(0xFFF3E7DD), t2: Color(0xFFBFA795), t3: Color(0xFF8A7466),
  line: Color(0xFF33251E), lineStrong: Color(0xFF453229),
  primary: Color(0xFFE08B5E), primaryStrong: Color(0xFFBF6B42), onPrimary: Color(0xFF1A0F09),
  accent: Color(0xFFC47A50),
  overlay: Color.fromRGBO(0, 0, 0, 0.62), scrimR: 0, scrimG: 0, scrimB: 0,
  neuA: Color.fromRGBO(0, 0, 0, 0.5), neuB: Color.fromRGBO(255, 200, 160, 0.06),
  glass: Color.fromRGBO(255, 255, 255, 0.07), glassLine: Color.fromRGBO(255, 255, 255, 0.14),
  hl: Color.fromRGBO(255, 255, 255, 0.05),
  danger: Color(0xFFE0837B), success: Color(0xFF6FC295), warning: Color(0xFFE0AA5E),
);

/* ---------------------------- lavender ---------------------------- */
const PaletteT _lavenderLight = PaletteT(
  bg: Color(0xFFF5F3FA), bgGrad: Color(0xFFEAE5F4), surface: Color(0xFFFFFFFF),
  surface2: Color(0xFFEEEAF6), sunken: Color(0xFFE7E2F1),
  t1: Color(0xFF2E2A3D), t2: Color(0xFF6C6486), t3: Color(0xFF9E96B8),
  line: Color(0xFFE6E1F0), lineStrong: Color(0xFFD2CAE3),
  primary: Color(0xFF6B5A9E), primaryStrong: Color(0xFF524478), onPrimary: Color(0xFFFFFFFF),
  accent: Color(0xFFB3A5CE),
  overlay: Color.fromRGBO(46, 42, 61, 0.42), scrimR: 46, scrimG: 42, scrimB: 61,
  neuA: Color.fromRGBO(85, 70, 120, 0.18), neuB: Color.fromRGBO(255, 255, 255, 0.92),
  glass: Color.fromRGBO(255, 255, 255, 0.66), glassLine: Color.fromRGBO(255, 255, 255, 0.88),
  hl: Colors.transparent,
  danger: Color(0xFFA94F45), success: Color(0xFF4A8F6B), warning: Color(0xFFB98A3E),
);
const PaletteT _lavenderDark = PaletteT(
  bg: Color(0xFF14121C), bgGrad: Color(0xFF1E1A28), surface: Color(0xFF1D1A26),
  surface2: Color(0xFF262231), sunken: Color(0xFF100E17),
  t1: Color(0xFFEDEAF5), t2: Color(0xFFA79FC0), t3: Color(0xFF746C8C),
  line: Color(0xFF2B2637), lineStrong: Color(0xFF3B3549),
  primary: Color(0xFFA896E0), primaryStrong: Color(0xFF8B76C6), onPrimary: Color(0xFF120F1A),
  accent: Color(0xFF8E7EC0),
  overlay: Color.fromRGBO(0, 0, 0, 0.62), scrimR: 0, scrimG: 0, scrimB: 0,
  neuA: Color.fromRGBO(0, 0, 0, 0.5), neuB: Color.fromRGBO(190, 175, 240, 0.06),
  glass: Color.fromRGBO(255, 255, 255, 0.07), glassLine: Color.fromRGBO(255, 255, 255, 0.14),
  hl: Color.fromRGBO(255, 255, 255, 0.05),
  danger: Color(0xFFE0837B), success: Color(0xFF6FC295), warning: Color(0xFFE0AA5E),
);

/* ---------------------------- mono ---------------------------- */
const PaletteT _monoLight = PaletteT(
  bg: Color(0xFFF7F7F7), bgGrad: Color(0xFFEDEDED), surface: Color(0xFFFFFFFF),
  surface2: Color(0xFFF0F0F0), sunken: Color(0xFFE9E9E9),
  t1: Color(0xFF171717), t2: Color(0xFF616161), t3: Color(0xFF9A9A9A),
  line: Color(0xFFE8E8E8), lineStrong: Color(0xFFD4D4D4),
  primary: Color(0xFF2E2E2E), primaryStrong: Color(0xFF141414), onPrimary: Color(0xFFFFFFFF),
  accent: Color(0xFF757575),
  overlay: Color.fromRGBO(23, 23, 23, 0.42), scrimR: 23, scrimG: 23, scrimB: 23,
  neuA: Color.fromRGBO(0, 0, 0, 0.14), neuB: Color.fromRGBO(255, 255, 255, 0.95),
  glass: Color.fromRGBO(255, 255, 255, 0.66), glassLine: Color.fromRGBO(255, 255, 255, 0.9),
  hl: Colors.transparent,
  danger: Color(0xFFA83B32), success: Color(0xFF3F7A4E), warning: Color(0xFF8A6A24),
);
const PaletteT _monoDark = PaletteT(
  bg: Color(0xFF0E0E0E), bgGrad: Color(0xFF171717), surface: Color(0xFF171717),
  surface2: Color(0xFF202020), sunken: Color(0xFF0A0A0A),
  t1: Color(0xFFF2F2F2), t2: Color(0xFFA8A8A8), t3: Color(0xFF747474),
  line: Color(0xFF262626), lineStrong: Color(0xFF363636),
  primary: Color(0xFFE4E4E4), primaryStrong: Color(0xFFC4C4C4), onPrimary: Color(0xFF111111),
  accent: Color(0xFF9A9A9A),
  overlay: Color.fromRGBO(0, 0, 0, 0.66), scrimR: 0, scrimG: 0, scrimB: 0,
  neuA: Color.fromRGBO(0, 0, 0, 0.5), neuB: Color.fromRGBO(255, 255, 255, 0.055),
  glass: Color.fromRGBO(255, 255, 255, 0.07), glassLine: Color.fromRGBO(255, 255, 255, 0.14),
  hl: Color.fromRGBO(255, 255, 255, 0.05),
  danger: Color(0xFFE0837B), success: Color(0xFF6FC295), warning: Color(0xFFE0AA5E),
);

const Map<String, PaletteT> _palettesLight = <String, PaletteT>{
  schemeMorandi: _morandiLight,
  schemeOcean: _oceanLight,
  schemeForest: _forestLight,
  schemeSunset: _sunsetLight,
  schemeLavender: _lavenderLight,
  schemeMono: _monoLight,
};

const Map<String, PaletteT> _palettesDark = <String, PaletteT>{
  schemeMorandi: _morandiDark,
  schemeOcean: _oceanDark,
  schemeForest: _forestDark,
  schemeSunset: _sunsetDark,
  schemeLavender: _lavenderDark,
  schemeMono: _monoDark,
};

/// 取配色在指定明暗下的 L0 色板；未知 key 回退 morandi 浅色。
PaletteT paletteFor(String schemeKey, Brightness resolved) =>
    (resolved == Brightness.dark ? _palettesDark : _palettesLight)[schemeKey] ??
    _morandiLight;

/// 当前配色/明暗下的主色 HEX 源色（供原生组件如 switch 绑定）。
Color schemePrimary(String schemeKey, Brightness resolved) =>
    paletteFor(schemeKey, resolved).primary;

/// 金银铜榜位渐变（全主题固定，对应 `--app-rank-1/2/3`）
const List<Color> rankGoldColors = <Color>[Color(0xFFF0C27F), Color(0xFFE8A849)];
const List<Color> rankSilverColors = <Color>[Color(0xFFC0C7CF), Color(0xFF9EA8B3)];
const List<Color> rankBronzeColors = <Color>[Color(0xFFD4A373), Color(0xFFBC8A5F)];

/// 布局高度 token（对应 `--app-tab-height` / `--app-playbar-height`）
const double kTabHeight = 56;
const double kPlayBarHeight = 64;
