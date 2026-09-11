import 'package:flutter/material.dart';

import 'theme_extension.dart';

/// 配色方案 key（与 `prototype/src/theme/index.ts` 对齐）
const String schemeMorandi = 'morandi';
const String schemeOcean = 'ocean';
const String schemeForest = 'forest';
const String schemeSunset = 'sunset';
const String schemeLavender = 'lavender';
const String schemeMono = 'mono';

/// 配色方案的元信息
class ThemeSchemeMeta {
  final String label;
  final String desc;
  const ThemeSchemeMeta(this.label, this.desc);
}

/// 配色方案列表（显示顺序即原型 `SCHEME_KEYS` 顺序）
const List<String> schemeKeys = <String>[
  schemeMorandi,
  schemeOcean,
  schemeForest,
  schemeSunset,
  schemeLavender,
  schemeMono,
];

const Map<String, ThemeSchemeMeta> schemeLabels = <String, ThemeSchemeMeta>{
  schemeMorandi: ThemeSchemeMeta('莫兰迪', '森系柔和的低饱和配色'),
  schemeOcean: ThemeSchemeMeta('深海', '深邃冷静的靛蓝夜色'),
  schemeForest: ThemeSchemeMeta('森林', '自然清新的苔绿色调'),
  schemeSunset: ThemeSchemeMeta('日落', '温暖治愈的暮橙色调'),
  schemeLavender: ThemeSchemeMeta('薰衣草', '温柔静谧的淡紫配色'),
  schemeMono: ThemeSchemeMeta('极简黑白', '克制统一的黑白灰'),
};

/// 每套配色的基础色板（不含 UI 风格相关的容器 / 阴影字段）
class _SchemeT {
  final Color primary;
  final Color primarySoft;
  final Color onPrimary;
  final Color accent;
  final Color bg;
  final Color bgGrad;
  final Color cardBorder;
  final Color text;
  final Color text2;
  final Color text3;
  final Color divider;
  final Color subtle;
  final Color danger;
  final Color glassCard;
  final Color glassBorder;
  final Color neuTint;
  final Color neuA;
  final Color neuB;

  const _SchemeT({
    required this.primary,
    required this.primarySoft,
    required this.onPrimary,
    required this.accent,
    required this.bg,
    required this.bgGrad,
    required this.cardBorder,
    required this.text,
    required this.text2,
    required this.text3,
    required this.divider,
    required this.subtle,
    required this.danger,
    required this.glassCard,
    required this.glassBorder,
    required this.neuTint,
    required this.neuA,
    required this.neuB,
  });
}

const _SchemeT _morandi = _SchemeT(
  primary: Color(0xFF5C8A72),
  primarySoft: Color(0x245C8A72),
  onPrimary: Color(0xFFFFFFFF),
  accent: Color(0xFF8FB8A0),
  bg: Color(0xFFF2F0EA),
  bgGrad: Color(0xFFE7E4DA),
  cardBorder: Color(0xFFE6E1D6),
  text: Color(0xFF2F3B35),
  text2: Color(0xFF6E7B74),
  text3: Color(0xFFA6B0A9),
  divider: Color(0xFFECE8DE),
  subtle: Color(0xFFECE9E0),
  danger: Color(0xFFC4706B),
  glassCard: Color(0x9EFFFFFF),
  glassBorder: Color(0xE6FFFFFF),
  neuTint: Color(0xFFEAE7DD),
  neuA: Color(0x295A6E64),
  neuB: Color(0xEBFFFFFF),
);

const _SchemeT _ocean = _SchemeT(
  primary: Color(0xFF5FB0B0),
  primarySoft: Color(0x295FB0B0),
  onPrimary: Color(0xFF062026),
  accent: Color(0xFF9FD4D4),
  bg: Color(0xFF0E2230),
  bgGrad: Color(0xFF16303F),
  cardBorder: Color(0xFF244453),
  text: Color(0xFFE6F2F3),
  text2: Color(0xFF9FB9C1),
  text3: Color(0xFF6E8C95),
  divider: Color(0xFF244150),
  subtle: Color(0xFF1D3946),
  danger: Color(0xFFD98B7B),
  glassCard: Color(0x9416303E),
  glassBorder: Color(0x24FFFFFF),
  neuTint: Color(0xFF14303E),
  neuA: Color(0x61000000),
  neuB: Color(0x2946788C),
);

const _SchemeT _forest = _SchemeT(
  primary: Color(0xFF4A6741),
  primarySoft: Color(0x244A6741),
  onPrimary: Color(0xFFFFFFFF),
  accent: Color(0xFF7C9D6E),
  bg: Color(0xFFEEF1E6),
  bgGrad: Color(0xFFE0E9D6),
  cardBorder: Color(0xFFE0E6D5),
  text: Color(0xFF2C3628),
  text2: Color(0xFF68725D),
  text3: Color(0xFF99A48F),
  divider: Color(0xFFE5EADB),
  subtle: Color(0xFFE4ECDA),
  danger: Color(0xFFC0705B),
  glassCard: Color(0x99FFFFFF),
  glassBorder: Color(0xD9FFFFFF),
  neuTint: Color(0xFFE3ECDA),
  neuA: Color(0x293C5A32),
  neuB: Color(0xEBFFFFFF),
);

const _SchemeT _sunset = _SchemeT(
  primary: Color(0xFFC06B48),
  primarySoft: Color(0x24C06B48),
  onPrimary: Color(0xFFFFFFFF),
  accent: Color(0xFFE3A377),
  bg: Color(0xFFFBF1E6),
  bgGrad: Color(0xFFF4E2CE),
  cardBorder: Color(0xFFF0E0CE),
  text: Color(0xFF3E3128),
  text2: Color(0xFF7E6E62),
  text3: Color(0xFFAB9A8B),
  divider: Color(0xFFF2E8DC),
  subtle: Color(0xFFF6EADD),
  danger: Color(0xFFC15B58),
  glassCard: Color(0x9EFFFFFF),
  glassBorder: Color(0xE0FFFFFF),
  neuTint: Color(0xFFF2E4D5),
  neuA: Color(0x29A06446),
  neuB: Color(0xEBFFFFFF),
);

const _SchemeT _lavender = _SchemeT(
  primary: Color(0xFF8A7BB0),
  primarySoft: Color(0x248A7BB0),
  onPrimary: Color(0xFFFFFFFF),
  accent: Color(0xFFB3A5CE),
  bg: Color(0xFFF4F1FA),
  bgGrad: Color(0xFFE9E3F4),
  cardBorder: Color(0xFFE2DCF0),
  text: Color(0xFF37324A),
  text2: Color(0xFF7A7292),
  text3: Color(0xFFA8A1C0),
  divider: Color(0xFFECE6F5),
  subtle: Color(0xFFEDE9F5),
  danger: Color(0xFFC0759B),
  glassCard: Color(0x9EFFFFFF),
  glassBorder: Color(0xE0FFFFFF),
  neuTint: Color(0xFFE8E3F3),
  neuA: Color(0x2969558C),
  neuB: Color(0xEBFFFFFF),
);

const _SchemeT _mono = _SchemeT(
  primary: Color(0xFF2F2F2F),
  primarySoft: Color(0x141F1F1F),
  onPrimary: Color(0xFFFFFFFF),
  accent: Color(0xFF6B6B6B),
  bg: Color(0xFFFAFAFA),
  bgGrad: Color(0xFFF0F0F0),
  cardBorder: Color(0xFFEBEBEB),
  text: Color(0xFF1A1A1A),
  text2: Color(0xFF6E6E6E),
  text3: Color(0xFFA9A9A9),
  divider: Color(0xFFEDEDED),
  subtle: Color(0xFFF2F2F2),
  danger: Color(0xFFB1483D),
  glassCard: Color(0x9EFFFFFF),
  glassBorder: Color(0xF2FFFFFF),
  neuTint: Color(0xFFEFEFEF),
  neuA: Color(0x1F000000),
  neuB: Color(0xF2FFFFFF),
);

const Map<String, _SchemeT> _schemes = <String, _SchemeT>{
  schemeMorandi: _morandi,
  schemeOcean: _ocean,
  schemeForest: _forest,
  schemeSunset: _sunset,
  schemeLavender: _lavender,
  schemeMono: _mono,
};

const Color _kFlatCard = Color(0xFFFFFFFF);
const Color _kGlassInputBg = Color(0x80FFFFFF);
const Color _kGlassPressBg = Color(0x59FFFFFF);
const Offset _kNeuTopLeft = Offset(-7, -7);
const Offset _kNeuBottomRight = Offset(7, 7);

/// 按 UI 风格计算容器 / 阴影字段，返回完整 [AppColors]。
///
/// - flat（扁平化）: 不透明白卡 + 发丝描边 + 柔和投影
/// - glass（玻璃拟态）: 半透明卡 + 毛玻璃模糊（cardBlur>0）
/// - neu（新拟态）: 无描边、双浮雕阴影（左上浅色含负偏移，右下深色为正偏移），面 == neuTint
AppColors appColorsFor(String schemeKey, String ui) {
  final base = _schemes[schemeKey] ?? _morandi;

  Color cardBg;
  Color cardBorder;
  List<BoxShadow> cardShadow;
  double cardBlur;
  Color pressBg;
  Color inputBg;
  Color inputBorder;

  switch (ui) {
    case 'glass':
      cardBg = base.glassCard;
      cardBorder = base.glassBorder;
      cardShadow = const <BoxShadow>[
        BoxShadow(
          color: Color(0x1A142822),
          offset: Offset(8, 8),
          blurRadius: 26,
        ),
      ];
      cardBlur = 22;
      pressBg = _kGlassPressBg;
      inputBg = _kGlassInputBg;
      inputBorder = base.glassBorder;
      break;
    case 'neu':
      cardBg = base.neuTint;
      cardBorder = Colors.transparent;
      cardShadow = <BoxShadow>[
        BoxShadow(
          color: base.neuB,
          offset: _kNeuTopLeft,
          blurRadius: 16,
        ),
        BoxShadow(
          color: base.neuA,
          offset: _kNeuBottomRight,
          blurRadius: 18,
        ),
      ];
      cardBlur = 0;
      pressBg = base.subtle;
      inputBg = base.neuTint;
      inputBorder = Colors.transparent;
      break;
    default: // flat
      cardBg = _kFlatCard;
      cardBorder = base.cardBorder;
      cardShadow = <BoxShadow>[
        BoxShadow(
          color: base.neuA,
          offset: const Offset(2, 2),
          blurRadius: 12,
        ),
      ];
      cardBlur = 0;
      pressBg = base.subtle;
      inputBg = _kFlatCard;
      inputBorder = base.cardBorder;
      break;
  }

  return AppColors(
    primary: base.primary,
    primarySoft: base.primarySoft,
    onPrimary: base.onPrimary,
    accent: base.accent,
    bg: base.bg,
    bgGrad: base.bgGrad,
    text: base.text,
    text2: base.text2,
    text3: base.text3,
    divider: base.divider,
    subtle: base.subtle,
    danger: base.danger,
    cardBg: cardBg,
    cardBorder: cardBorder,
    pressBg: pressBg,
    inputBg: inputBg,
    inputBorder: inputBorder,
    cardShadow: cardShadow,
    cardBlur: cardBlur,
  );
}