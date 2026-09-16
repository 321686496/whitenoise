import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'app_svg_icons.dart';

/// 将 [Color] 转为 `#RRGGBB`（Dart 2.19：分量取 0–255 int）。
String colorToHex(Color c) {
  String p(int v) => v.toRadixString(16).padLeft(2, '0');
  return '#${p(c.red)}${p(c.green)}${p(c.blue)}';
}

/// 声栖自定义图标（对应原型 `components/Icon.vue`，禁止 emoji）。
///
/// 图标默认加载自 [appIconBodies] 的 SVG body；未知名图标回退默认圆点。
/// 采用「SVG 内嵌 stroke/fill 着色」而非 flutter_svg 的 `color` 滤镜参数，
/// 避免对整图单色着色造成双重色调。
class AppIcon extends StatelessWidget {
  final String name;
  final double size;
  final Color color;
  final double stroke;

  const AppIcon({
    super.key,
    required this.name,
    this.size = 24,
    this.color = Colors.black,
    this.stroke = 2,
  });

  @override
  Widget build(BuildContext context) {
    final hex = colorToHex(color);
    // 部分图标用 `fill="currentColor"` 占位，渲染时替换为实际色值。
    final body = appIconBody(name).replaceAll('currentColor', hex);
    final svg =
        '<svg viewBox="0 0 24 24" width="24" height="24" fill="none" '
        'stroke="$hex" stroke-width="$stroke" '
        'stroke-linecap="round" stroke-linejoin="round">$body</svg>';
    return SvgPicture.string(
      svg,
      width: size,
      height: size,
      semanticsLabel: name,
    );
  }
}

/// 以已注册于组件内的原始 SVG body 直接渲染（TabBar 专属路径等）。
class AppRawIcon extends StatelessWidget {
  final String body;
  final double size;
  final Color color;

  const AppRawIcon({
    super.key,
    required this.body,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final hex = colorToHex(color);
    final b = body.replaceAll('currentColor', hex);
    final svg =
        '<svg viewBox="0 0 24 24" width="24" height="24" fill="none" '
        'stroke="$hex" stroke-width="1.6" '
        'stroke-linecap="round" stroke-linejoin="round">$b</svg>';
    return SvgPicture.string(
      svg,
      width: size,
      height: size,
      semanticsLabel: 'tab-icon',
    );
  }
}
