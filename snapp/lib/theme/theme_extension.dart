import 'package:flutter/material.dart';

import 'theme_tokens.dart';

/// 声栖 · 配色扩展（挂在 ThemeData.extensions 上）
///
/// L1 语义字段与 `prototype/src/theme/index.ts` 的 `--app-*` token 一一对应；
/// `surface / line / shadow1..4 / insetHl / blur` 由 `appColorsFor(scheme, ui, mode)`
/// 按 UI 风格计算（L2 组件覆写）。
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color bg;
  final Color bgGrad;
  final Color surface;
  final Color surface2;
  final Color sunken;
  final Color text;
  final Color text2;
  final Color text3;
  final Color line;
  final Color lineStrong;
  final Color primary;
  final Color primaryStrong;
  final Color primarySoft;
  final Color primarySoft2;
  final Color onPrimary;
  final Color accent;
  final Color overlay;
  final Color press;
  final Color onCover;
  final Color onCoverSoft;
  final Color danger;
  final Color dangerSoft;
  final Color success;
  final Color warning;

  /// L2 组件覆写（随 UI 风格变化）
  final List<BoxShadow> shadow1;
  final List<BoxShadow> shadow2;
  final List<BoxShadow> shadow3;
  final List<BoxShadow> shadow4;

  /// 玻璃态内高光（inset 0 1px 0 hl）；非玻璃风格为 null
  final Color? insetHl;
  final double blur;

  const AppColors({
    required this.bg,
    required this.bgGrad,
    required this.surface,
    required this.surface2,
    required this.sunken,
    required this.text,
    required this.text2,
    required this.text3,
    required this.line,
    required this.lineStrong,
    required this.primary,
    required this.primaryStrong,
    required this.primarySoft,
    required this.primarySoft2,
    required this.onPrimary,
    required this.accent,
    required this.overlay,
    required this.press,
    required this.onCover,
    required this.onCoverSoft,
    required this.danger,
    required this.dangerSoft,
    required this.success,
    required this.warning,
    this.shadow1 = const [],
    this.shadow2 = const [],
    this.shadow3 = const [],
    this.shadow4 = const [],
    this.insetHl,
    this.blur = 0,
  });

  @override
  AppColors copyWith({
    Color? bg,
    Color? bgGrad,
    Color? surface,
    Color? surface2,
    Color? sunken,
    Color? text,
    Color? text2,
    Color? text3,
    Color? line,
    Color? lineStrong,
    Color? primary,
    Color? primaryStrong,
    Color? primarySoft,
    Color? primarySoft2,
    Color? onPrimary,
    Color? accent,
    Color? overlay,
    Color? press,
    Color? onCover,
    Color? onCoverSoft,
    Color? danger,
    Color? dangerSoft,
    Color? success,
    Color? warning,
    List<BoxShadow>? shadow1,
    List<BoxShadow>? shadow2,
    List<BoxShadow>? shadow3,
    List<BoxShadow>? shadow4,
    Color? insetHl,
    double? blur,
  }) {
    return AppColors(
      bg: bg ?? this.bg,
      bgGrad: bgGrad ?? this.bgGrad,
      surface: surface ?? this.surface,
      surface2: surface2 ?? this.surface2,
      sunken: sunken ?? this.sunken,
      text: text ?? this.text,
      text2: text2 ?? this.text2,
      text3: text3 ?? this.text3,
      line: line ?? this.line,
      lineStrong: lineStrong ?? this.lineStrong,
      primary: primary ?? this.primary,
      primaryStrong: primaryStrong ?? this.primaryStrong,
      primarySoft: primarySoft ?? this.primarySoft,
      primarySoft2: primarySoft2 ?? this.primarySoft2,
      onPrimary: onPrimary ?? this.onPrimary,
      accent: accent ?? this.accent,
      overlay: overlay ?? this.overlay,
      press: press ?? this.press,
      onCover: onCover ?? this.onCover,
      onCoverSoft: onCoverSoft ?? this.onCoverSoft,
      danger: danger ?? this.danger,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      shadow1: shadow1 ?? this.shadow1,
      shadow2: shadow2 ?? this.shadow2,
      shadow3: shadow3 ?? this.shadow3,
      shadow4: shadow4 ?? this.shadow4,
      insetHl: insetHl ?? this.insetHl,
      blur: blur ?? this.blur,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color lc(Color a, Color b) => Color.lerp(a, b, t)!;
    List<BoxShadow> ls(List<BoxShadow> a, List<BoxShadow> b) {
      final n = a.length > b.length ? a.length : b.length;
      final out = <BoxShadow>[];
      for (var i = 0; i < n; i++) {
        out.add(BoxShadow.lerp(
          i < a.length ? a[i] : const BoxShadow(),
          i < b.length ? b[i] : const BoxShadow(),
          t,
        )!);
      }
      return out;
    }

    return AppColors(
      bg: lc(bg, other.bg),
      bgGrad: lc(bgGrad, other.bgGrad),
      surface: lc(surface, other.surface),
      surface2: lc(surface2, other.surface2),
      sunken: lc(sunken, other.sunken),
      text: lc(text, other.text),
      text2: lc(text2, other.text2),
      text3: lc(text3, other.text3),
      line: lc(line, other.line),
      lineStrong: lc(lineStrong, other.lineStrong),
      primary: lc(primary, other.primary),
      primaryStrong: lc(primaryStrong, other.primaryStrong),
      primarySoft: lc(primarySoft, other.primarySoft),
      primarySoft2: lc(primarySoft2, other.primarySoft2),
      onPrimary: lc(onPrimary, other.onPrimary),
      accent: lc(accent, other.accent),
      overlay: lc(overlay, other.overlay),
      press: lc(press, other.press),
      onCover: lc(onCover, other.onCover),
      onCoverSoft: lc(onCoverSoft, other.onCoverSoft),
      danger: lc(danger, other.danger),
      dangerSoft: lc(dangerSoft, other.dangerSoft),
      success: lc(success, other.success),
      warning: lc(warning, other.warning),
      shadow1: ls(shadow1, other.shadow1),
      shadow2: ls(shadow2, other.shadow2),
      shadow3: ls(shadow3, other.shadow3),
      shadow4: ls(shadow4, other.shadow4),
      insetHl: Color.lerp(insetHl, other.insetHl, t),
      blur: blur + (other.blur - blur) * t,
    );
  }
}

/// 声栖 · 形状扩展（卡片圆角 / 主卡片阴影 / 模糊）
@immutable
class AppShapes extends ThemeExtension<AppShapes> {
  /// `--app-card` 圆角 44rpx = 22px（MASTER.md 卡片 lg）
  final double cardRadius;
  final List<BoxShadow> cardShadow;
  final double cardBlur;

  const AppShapes({
    this.cardRadius = 22,
    this.cardShadow = const [],
    this.cardBlur = 0,
  });

  @override
  AppShapes copyWith({double? cardRadius, List<BoxShadow>? cardShadow, double? cardBlur}) {
    return AppShapes(
      cardRadius: cardRadius ?? this.cardRadius,
      cardShadow: cardShadow ?? this.cardShadow,
      cardBlur: cardBlur ?? this.cardBlur,
    );
  }

  @override
  AppShapes lerp(ThemeExtension<AppShapes>? other, double t) {
    if (other is! AppShapes) return this;
    final bs = <BoxShadow>[];
    final n = cardShadow.length > other.cardShadow.length
        ? cardShadow.length
        : other.cardShadow.length;
    for (var i = 0; i < n; i++) {
      bs.add(BoxShadow.lerp(
        i < cardShadow.length ? cardShadow[i] : const BoxShadow(),
        i < other.cardShadow.length ? other.cardShadow[i] : const BoxShadow(),
        t,
      )!);
    }
    return AppShapes(
      cardRadius: cardRadius + (other.cardRadius - cardRadius) * t,
      cardShadow: bs,
      cardBlur: cardBlur + (other.cardBlur - cardBlur) * t,
    );
  }
}

extension AppThemeX on ThemeData {
  AppColors get appColors => extension<AppColors>()!;

  AppShapes get appShapes => extension<AppShapes>()!;
}

/// 按「配色 × UI 风格 × 明暗」计算完整 [AppColors]（对应原型 `buildTokens`）。
///
/// - flat（扁平化）: 不透明 surface + 发丝描边 + scrim 系投影
/// - glass（玻璃拟态）: 半透明 glass 面 + 毛玻璃模糊（blur>0）+ 顶部内高光
/// - neu（新拟态）: 面 == bg，无描边，双浮雕阴影（右下深 neuA / 左上浅 neuB，
///   光源固定左上），面与画布同色呈现浮雕
AppColors appColorsFor(String schemeKey, String ui, Brightness resolved) {
  final p = paletteFor(schemeKey, resolved);

  Color scrim(double o) => Color.fromRGBO(p.scrimR, p.scrimG, p.scrimB, o);

  // L1 语义（风格无关）：color-mix(in srgb, X p%, transparent)
  Color mixOverTransparent(Color a, double pct) => a.withOpacity(pct);
  final primarySoft = mixOverTransparent(p.primary, 0.14);
  final primarySoft2 = mixOverTransparent(p.primary, 0.24);
  final pressC = mixOverTransparent(p.t1, 0.06);
  final dangerSoft = mixOverTransparent(p.danger, 0.13);
  final onCoverSoft = Colors.white.withOpacity(0.78);

  Color surface;
  Color surface2;
  Color line;
  double blur;
  Color? insetHl;
  List<BoxShadow> s1;
  List<BoxShadow> s2;
  List<BoxShadow> s3;
  List<BoxShadow> s4;

  if (ui == 'glass') {
    surface = p.glass;
    surface2 = p.glass;
    line = p.glassLine;
    blur = 20;
    insetHl = p.hl == Colors.transparent ? null : p.hl;
    s1 = <BoxShadow>[BoxShadow(color: scrim(0.06), offset: const Offset(0, 2), blurRadius: 8)];
    s2 = <BoxShadow>[BoxShadow(color: scrim(0.10), offset: const Offset(0, 8), blurRadius: 26)];
    s3 = <BoxShadow>[BoxShadow(color: scrim(0.14), offset: const Offset(0, 14), blurRadius: 38)];
    s4 = <BoxShadow>[BoxShadow(color: scrim(0.20), offset: const Offset(0, 24), blurRadius: 56)];
  } else if (ui == 'neu') {
    surface = p.bg;
    surface2 = p.bg;
    line = Colors.transparent;
    blur = 0;
    insetHl = null;
    // 光源固定左上：右下深色 neuA（正偏移），左上浅色 neuB（负偏移）
    s1 = <BoxShadow>[
      BoxShadow(color: p.neuA, offset: const Offset(3, 3), blurRadius: 8),
      BoxShadow(color: p.neuB, offset: const Offset(-3, -3), blurRadius: 8),
    ];
    s2 = <BoxShadow>[
      BoxShadow(color: p.neuA, offset: const Offset(7, 7), blurRadius: 16),
      BoxShadow(color: p.neuB, offset: const Offset(-7, -7), blurRadius: 18),
    ];
    s3 = <BoxShadow>[
      BoxShadow(color: p.neuA, offset: const Offset(12, 12), blurRadius: 26),
      BoxShadow(color: p.neuB, offset: const Offset(-10, -10), blurRadius: 24),
    ];
    s4 = <BoxShadow>[
      BoxShadow(color: p.neuA, offset: const Offset(18, 18), blurRadius: 38),
      BoxShadow(color: p.neuB, offset: const Offset(-14, -14), blurRadius: 32),
    ];
  } else {
    // flat
    surface = p.surface;
    surface2 = p.surface2;
    line = p.line;
    blur = 0;
    insetHl = null;
    s1 = <BoxShadow>[BoxShadow(color: scrim(0.06), offset: const Offset(0, 1), blurRadius: 2)];
    s2 = <BoxShadow>[
      BoxShadow(color: scrim(0.07), offset: const Offset(0, 4), blurRadius: 12),
      BoxShadow(color: scrim(0.05), offset: const Offset(0, 1), blurRadius: 3),
    ];
    s3 = <BoxShadow>[
      BoxShadow(color: scrim(0.10), offset: const Offset(0, 12), blurRadius: 28),
      BoxShadow(color: scrim(0.06), offset: const Offset(0, 2), blurRadius: 6),
    ];
    s4 = <BoxShadow>[BoxShadow(color: scrim(0.18), offset: const Offset(0, 20), blurRadius: 48)];
  }

  return AppColors(
    bg: p.bg,
    bgGrad: p.bgGrad,
    surface: surface,
    surface2: surface2,
    sunken: p.sunken,
    text: p.t1,
    text2: p.t2,
    text3: p.t3,
    line: line,
    lineStrong: p.lineStrong,
    primary: p.primary,
    primaryStrong: p.primaryStrong,
    primarySoft: primarySoft,
    primarySoft2: primarySoft2,
    onPrimary: p.onPrimary,
    accent: p.accent,
    overlay: p.overlay,
    press: pressC,
    onCover: const Color(0xFFFFFFFF),
    onCoverSoft: onCoverSoft,
    danger: p.danger,
    dangerSoft: dangerSoft,
    success: p.success,
    warning: p.warning,
    shadow1: s1,
    shadow2: s2,
    shadow3: s3,
    shadow4: s4,
    insetHl: insetHl,
    blur: blur,
  );
}
