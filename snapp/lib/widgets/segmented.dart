import 'package:flutter/material.dart';

import '../theme/theme_extension.dart';

/// 分段选择（对应原型 `components/Segmented.vue`）。
///
/// neu 风格下选中 = 凹陷（阴影方向反转：左上深 / 右下浅），与铁律一致。
class Segmented extends StatelessWidget {
  final List<SegmentOption> options;
  final String value;
  final ValueChanged<String> onChanged;

  const Segmented({
    required this.options,
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    final ui = Theme.of(context).appColors;
    final isNeu = ui.line.opacity < 0.01 && ui.surface == ui.bg;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(999),
        border: c.line.opacity > 0.01
            ? Border.all(color: c.line, width: 0.5)
            : null,
      ),
      child: Row(
        children: options.map((SegmentOption opt) {
          final on = opt.key == value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(opt.key),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: on
                      ? (isNeu ? c.bg : c.surface)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: on && isNeu
                      ? <BoxShadow>[
                          BoxShadow(
                            color: c.text.withOpacity(0.18),
                            offset: const Offset(-3, -3),
                            blurRadius: 8,
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.9),
                            offset: const Offset(3, 3),
                            blurRadius: 8,
                          ),
                        ]
                      : on
                          ? c.shadow1
                          : null,
                ),
                child: Text(
                  opt.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: on ? FontWeight.w600 : FontWeight.w500,
                    color: on ? c.text : c.text2,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class SegmentOption {
  final String key;
  final String label;
  const SegmentOption(this.key, this.label);
}
