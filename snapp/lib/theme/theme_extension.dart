import 'package:flutter/material.dart';

/// 声栖 · 配色扩展（挂在 ThemeData.extensions 上）
///
/// 字段与 `prototype/src/theme/index.ts` 的 Token 一一对应。
/// `cardShadow` / `cardBlur` / `cardBg` / `cardBorder` / `pressBg` /
/// `inputBg` / `inputBorder` 由 `appColorsFor(scheme, ui)` 按 UI 风格计算。
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color primary;
  final Color primarySoft;
  final Color onPrimary;
  final Color accent;
  final Color bg;
  final Color bgGrad;
  final Color text;
  final Color text2;
  final Color text3;
  final Color divider;
  final Color subtle;
  final Color danger;
  final Color cardBg;
  final Color cardBorder;
  final Color pressBg;
  final Color inputBg;
  final Color inputBorder;
  final List<BoxShadow> cardShadow;
  final double cardBlur;

  const AppColors({
    required this.primary,
    required this.primarySoft,
    required this.onPrimary,
    required this.accent,
    required this.bg,
    required this.bgGrad,
    required this.text,
    required this.text2,
    required this.text3,
    required this.divider,
    required this.subtle,
    required this.danger,
    required this.cardBg,
    required this.cardBorder,
    required this.pressBg,
    required this.inputBg,
    required this.inputBorder,
    this.cardShadow = const [],
    this.cardBlur = 0,
  });

  @override
  AppColors copyWith({
    Color? primary,
    Color? primarySoft,
    Color? onPrimary,
    Color? accent,
    Color? bg,
    Color? bgGrad,
    Color? text,
    Color? text2,
    Color? text3,
    Color? divider,
    Color? subtle,
    Color? danger,
    Color? cardBg,
    Color? cardBorder,
    Color? pressBg,
    Color? inputBg,
    Color? inputBorder,
    List<BoxShadow>? cardShadow,
    double? cardBlur,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      primarySoft: primarySoft ?? this.primarySoft,
      onPrimary: onPrimary ?? this.onPrimary,
      accent: accent ?? this.accent,
      bg: bg ?? this.bg,
      bgGrad: bgGrad ?? this.bgGrad,
      text: text ?? this.text,
      text2: text2 ?? this.text2,
      text3: text3 ?? this.text3,
      divider: divider ?? this.divider,
      subtle: subtle ?? this.subtle,
      danger: danger ?? this.danger,
      cardBg: cardBg ?? this.cardBg,
      cardBorder: cardBorder ?? this.cardBorder,
      pressBg: pressBg ?? this.pressBg,
      inputBg: inputBg ?? this.inputBg,
      inputBorder: inputBorder ?? this.inputBorder,
      cardShadow: cardShadow ?? this.cardShadow,
      cardBlur: cardBlur ?? this.cardBlur,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color lc(Color a, Color b) => Color.lerp(a, b, t)!;
    final shadow = <BoxShadow>[];
    final max = cardShadow.length > other.cardShadow.length
        ? cardShadow.length
        : other.cardShadow.length;
    for (var i = 0; i < max; i++) {
      final a = i < cardShadow.length ? cardShadow[i] : const BoxShadow();
      final b = i < other.cardShadow.length ? other.cardShadow[i] : const BoxShadow();
      shadow.add(BoxShadow.lerp(a, b, t)!);
    }
    return AppColors(
      primary: lc(primary, other.primary),
      primarySoft: lc(primarySoft, other.primarySoft),
      onPrimary: lc(onPrimary, other.onPrimary),
      accent: lc(accent, other.accent),
      bg: lc(bg, other.bg),
      bgGrad: lc(bgGrad, other.bgGrad),
      text: lc(text, other.text),
      text2: lc(text2, other.text2),
      text3: lc(text3, other.text3),
      divider: lc(divider, other.divider),
      subtle: lc(subtle, other.subtle),
      danger: lc(danger, other.danger),
      cardBg: lc(cardBg, other.cardBg),
      cardBorder: lc(cardBorder, other.cardBorder),
      pressBg: lc(pressBg, other.pressBg),
      inputBg: lc(inputBg, other.inputBg),
      inputBorder: lc(inputBorder, other.inputBorder),
      cardShadow: shadow,
      cardBlur: cardBlur + (other.cardBlur - cardBlur) * t,
    );
  }
}

/// 声栖 · 形状扩展（圆角 / 卡片阴影 / 卡片模糊）
@immutable
class AppShapes extends ThemeExtension<AppShapes> {
  final double cardRadius;
  final List<BoxShadow> cardShadow;
  final double cardBlur;

  const AppShapes({
    this.cardRadius = 14,
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
    final max = cardShadow.length > other.cardShadow.length
        ? cardShadow.length
        : other.cardShadow.length;
    for (var i = 0; i < max; i++) {
      final x = i < cardShadow.length ? cardShadow[i] : const BoxShadow();
      final y = i < other.cardShadow.length ? other.cardShadow[i] : const BoxShadow();
      bs.add(BoxShadow.lerp(x, y, t)!);
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