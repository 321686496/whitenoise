import 'package:flutter/foundation.dart';

/// 应用壳 Tab 切换通知器：页面内可经 `context.read<ShellTabNotifier>().go(i)`
/// 切换底部 tab（对应原型 `uni.switchTab` 语义）。
class ShellTabNotifier extends ChangeNotifier {
  int index = 0;

  void go(int i) {
    if (i == index) return;
    index = i;
    notifyListeners();
  }
}
