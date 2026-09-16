import 'dart:async';

import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

/// 音频引擎接口（对应原型 WebAudioEngine 的职责边界）。
///
/// 每个音轨以 [loadTrack] 独立加载；无资产（asset 为 null）的音轨跳过引擎，
/// 保持静音模拟。音量 [setVolume] 传 0-1 归一化值。
abstract class AudioEngine {
  Future<void> loadTrack(String id, String? asset);
  Future<void> play();
  Future<void> pause();
  Future<void> setVolume(String id, double v);
  Future<void> setMute(String id, bool muted);
  Future<void> disposeTrack(String id);
  Future<void> disposeAll();
}

/// 模拟引擎：不发声，仅记录状态供断言。
///
/// 用于测试环境，以及「无合成资产」的音轨（真实采录音）——它们由
/// [PlayerService] 直接跳过加载，播放时静默。
class SimulatedAudioEngine implements AudioEngine {
  bool playing = false;
  final Set<String> loaded = <String>{};
  final Map<String, double> volumes = <String, double>{};
  final Map<String, bool> mutes = <String, bool>{};

  @override
  Future<void> loadTrack(String id, String? asset) async {
    if (asset == null) return;
    loaded.add(id);
    volumes[id] = 1.0;
    mutes[id] = false;
  }

  @override
  Future<void> play() async {
    playing = true;
  }

  @override
  Future<void> pause() async {
    playing = false;
  }

  @override
  Future<void> setVolume(String id, double v) async {
    volumes[id] = v;
  }

  @override
  Future<void> setMute(String id, bool muted) async {
    mutes[id] = muted;
  }

  @override
  Future<void> disposeTrack(String id) async {
    loaded.remove(id);
    volumes.remove(id);
    mutes.remove(id);
  }

  @override
  Future<void> disposeAll() async {
    loaded.clear();
    volumes.clear();
    mutes.clear();
  }
}

/// just_audio 真实引擎：每轨独立 [AudioPlayer] + 单曲循环。
///
/// 平台插件缺失（测试环境 / 未安装原生实现）时，任意调用抛出的
/// [MissingPluginException] / [PlatformException] / [PlayerException] 会让引擎
/// **整体降级**（[degraded] = true，后续全部静默跳过），与 [SimulatedAudioEngine]
/// 行为等价，保证应用在任何环境可运行、可构建。
class JustAudioEngine implements AudioEngine {
  final Map<String, AudioPlayer> _players = <String, AudioPlayer>{};
  final Map<String, double> _volumes = <String, double>{};
  final Map<String, bool> _mutes = <String, bool>{};
  bool _degraded = false;

  /// 目标播放状态：play/pause 立即记录，加载完成的音轨自动跟进。
  bool _playing = false;

  bool get degraded => _degraded;

  /// 包裹一次引擎操作：常规异常按类型降级；just_audio 内部 fire-and-forget
  /// future（如 `_platform = setPlatform()`）的未捕获错误经 zone 处理器同样
  /// 降级，避免测试环境/平台缺失时成为未处理异步错误。
  Future<void> _guard(Future<void> Function() action) {
    if (_degraded) return Future<void>.value();
    return runZonedGuarded(() async {
      try {
        await action();
      } on MissingPluginException {
        _degraded = true;
      } on PlatformException {
        _degraded = true;
      } on PlayerException {
        _degraded = true;
      }
    }, (Object error, StackTrace stack) {
      _degraded = true;
    }) ?? Future<void>.value();
  }

  @override
  Future<void> loadTrack(String id, String? asset) => _guard(() async {
        if (asset == null) return;
        final p = AudioPlayer();
        await p.setAsset(asset);
        await p.setLoopMode(LoopMode.one);
        await p.setVolume(_mutes[id] == true ? 0 : 1);
        _volumes[id] = 1;
        if (_playing) await p.play();
        _players[id] = p;
      });

  @override
  Future<void> play() => _guard(() async {
        _playing = true;
        for (final AudioPlayer p in _players.values) {
          await p.play();
        }
      });

  @override
  Future<void> pause() => _guard(() async {
        _playing = false;
        for (final AudioPlayer p in _players.values) {
          await p.pause();
        }
      });

  @override
  Future<void> setVolume(String id, double v) => _guard(() async {
        _volumes[id] = v;
        if (_mutes[id] == true) return;
        final AudioPlayer? p = _players[id];
        if (p != null) await p.setVolume(v);
      });

  /// just_audio 无独立静音 API：静音时把音量置 0，取消静音恢复原音量。
  @override
  Future<void> setMute(String id, bool muted) => _guard(() async {
        _mutes[id] = muted;
        final AudioPlayer? p = _players[id];
        if (p == null) return;
        await p.setVolume(muted ? 0 : (_volumes[id] ?? 1));
      });

  @override
  Future<void> disposeTrack(String id) => _guard(() async {
        final AudioPlayer? p = _players.remove(id);
        if (p != null) await p.dispose();
      });

  @override
  Future<void> disposeAll() => _guard(() async {
        for (final AudioPlayer p in _players.values) {
          await p.dispose();
        }
        _players.clear();
      });
}
