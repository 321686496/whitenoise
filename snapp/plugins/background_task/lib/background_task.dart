import 'package:flutter/services.dart';

/// 声栖 · OHOS 后台长时任务通道。
///
/// 通过原生 [MethodChannel] 在"开始播放/停止播放"时申请/释放
/// audioPlayback 长时任务。长时任务存活期间系统在通知栏展示关联播放条，
/// 保证应用退到后台后白噪音仍持续播放。
class BackgroundTask {
  BackgroundTask._();

  static const MethodChannel _channel = MethodChannel('com.snapp.background');

  /// 申请 audioPlayback 长时任务（播放开始时调用，幂等）。
  static Future<void> start() async {
    try {
      await _channel.invokeMethod<int>('start');
    } catch (_) {
      // 非 OHOS 平台插件未注册会抛 MissingPluginException，这里吞掉：
      // 仅让 OHOS 端获得后台播放能力，其它平台忽略。
    }
  }

  /// 释放长时任务（暂停/停止播放时调用，幂等）。
  static Future<void> stop() async {
    try {
      await _channel.invokeMethod<int>('stop');
    } catch (_) {
      // 同上，静默忽略。
    }
  }
}