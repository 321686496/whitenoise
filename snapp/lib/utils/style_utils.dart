import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 原型 CSS 值 → Flutter 的换算工具。
///
/// 数据层中的 `gradient` / `color` 字段保持与原型一致的 CSS 字符串，
/// 渲染时经此处换算，禁止在业务代码中另行发明色值。

/// 解析 `#RGB` / `#RRGGBB` / `#AARRGGBB`；解析失败返回 null。
Color? hexToColor(String hex) {
  var h = hex.trim().replaceFirst('#', '');
  if (h.length == 3) {
    h = h.split('').map((String c) => c + c).join();
  }
  if (h.length == 6) h = 'FF$h';
  if (h.length != 8) return null;
  final v = int.tryParse(h, radix: 16);
  if (v == null) return null;
  return Color(v);
}

/// color-mix(in srgb, [a] [pct]% , [b])：sRGB 通道线性混合。
Color colorMix(Color a, double pct, Color b) => Color.lerp(b, a, pct / 100)!;

/// CSS linear-gradient 解析结果
class CssGradient {
  final List<Color> colors;
  final Alignment begin;
  final Alignment end;
  const CssGradient(this.colors, this.begin, this.end);
}

/// 解析原型数据中的 `linear-gradient(135deg, #A, #B)` 字符串。
///
/// - 仅支持 hex 颜色 stop（数据层均为该格式）；
/// - 135deg 在 CSS 中指向右下（begin 左上 → end 右下）；
/// - 解析失败返回 null，调用方回退纯色/主色。
CssGradient? parseCssGradient(String css) {
  final m = RegExp(r'linear-gradient\(\s*(-?\d+)deg\s*,(.+)\)').firstMatch(css);
  if (m == null) return null;
  final angle = double.tryParse(m.group(1)!) ?? 135;
  final stops = m
      .group(2)!
      .split(',')
      .map((String s) => hexToColor(s))
      .whereType<Color>()
      .toList();
  if (stops.isEmpty) return null;
  final rad = angle * math.pi / 180.0;
  // CSS 0deg 指向上方，角度顺时针增长；屏幕坐标 y 向下。
  final end = Alignment(math.sin(rad), -math.cos(rad));
  return CssGradient(stops, -end, end);
}

/// 取渐变的第一个颜色作为兜底纯色（解析失败时回退 [fallback]）。
Color gradientFirstColor(String css, Color fallback) {
  final g = parseCssGradient(css);
  return (g != null && g.colors.isNotEmpty) ? g.colors.first : fallback;
}

/// rpx → 逻辑像素（原型 750 设计稿宽，1rpx = 0.5px）。
double rx(num v) => v / 2.0;
