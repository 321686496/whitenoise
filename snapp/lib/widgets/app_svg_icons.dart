/// 图标 SVG 内联 body 库（纯 Dart，不依赖 Flutter）。
///
/// 唯一权威来源：`prototype/src/components/Icon.vue`，以下每个 key 的 value
/// 都是从该组件对应分支**原样拷贝**的 SVG 元素串（已带完整属性）。
/// 禁止自行发明图标；未知名图标在 [appIconBody] 回退默认圆点。
const Map<String, String> appIconBodies = {
  'wave': '<path d="M2 12h2l3-9 4 18 4-14 3 7h4" />',
  'white-noise':
      '<path d="M2 12c2-3 4-3 6 0s4 3 6 0 4-3 6 0" /><path d="M2 16c2-3 4-3 6 0s4 3 6 0 4-3 6 0" /><path d="M2 8c2-3 4-3 6 0s4 3 6 0 4-3 6 0" />',
  'pink-noise':
      '<circle cx="12" cy="12" r="4" /><path d="M12 2v4M12 18v4M2 12h4M18 12h4M4.93 4.93l2.83 2.83M16.24 16.24l2.83 2.83M4.93 19.07l2.83-2.83M16.24 7.76l2.83-2.83" />',
  'brown-noise':
      '<path d="M3 17c3-2 6-2 9 0s6 2 9 0" /><path d="M3 13c3-2 6-2 9 0s6 2 9 0" /><path d="M3 9c3-2 6-2 9 0s6 2 9 0" /><path d="M3 5c3-2 6-2 9 0s6 2 9 0" />',
  'red-noise': '<path d="M4 20c2-4 4-4 6 0s4 4 6 0 4-4 6 0" stroke-width="2.5" />',
  'rain':
      '<path d="M16 13V8a4 4 0 0 0-8 0v1" /><path d="M12 13v5M8 15v4M16 15v4M4 13v3M20 13v3" />',
  'wave-ocean':
      '<path d="M2 12c2-3 4-3 6 0s4 3 6 0 4-3 6 0" /><path d="M2 16c2-3 4-3 6 0s4 3 6 0 4-3 6 0" /><path d="M2 8c2-3 4-3 6 0s4 3 6 0 4-3 6 0" />',
  'forest': '<path d="M12 3L7 10h3l-4 7h12l-4-7h3L12 3z" /><path d="M12 17v4" />',
  'stream': '<path d="M12 2c-3 4-6 6-6 10a6 6 0 0 0 12 0c0-4-3-6-6-10z" /><path d="M12 10v4M10 12h4" />',
  'fire': '<path d="M12 2c-1 3-4 5-4 9a4 4 0 0 0 8 0c0-2-1-3-2-4 1 1 2 2 2 4" /><path d="M8 21h8M10 17h4" />',
  'coffee': '<path d="M17 8h1a4 4 0 0 1 0 8h-1" /><path d="M3 8h14v9a4 4 0 0 1-4 4H7a4 4 0 0 1-4-4V8z" /><path d="M6 2v2M10 2v2M14 2v2" />',
  'train':
      '<rect x="4" y="3" width="16" height="14" rx="3" /><path d="M4 11h16M8 21l-2-4M16 21l2-4" /><circle cx="8" cy="15" r="1" fill="currentColor" stroke="none" /><circle cx="16" cy="15" r="1" fill="currentColor" stroke="none" />',
  'fan': '<circle cx="12" cy="12" r="2" /><path d="M12 10c-2-4-2-7 0-8s2 4 0 8" /><path d="M14 12c4-2 7-2 8 0s-4 2-8 0" /><path d="M12 14c2 4 2 7 0 8s-2-4 0-8" /><path d="M10 12c-4 2-7 2-8 0s4-2 8 0" />',
  'play': '<path d="M7 4.5v15l13-7.5L7 4.5z" fill="currentColor" stroke="none" />',
  'pause': '<path d="M8 4v16M16 4v16" />',
  'timer': '<circle cx="12" cy="13" r="8" /><path d="M12 9.5v3.5l2.5 2.5M9.5 2h5" />',
  'save':
      '<path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z" /><polyline points="17,21 17,13 7,13 7,21" /><polyline points="7,3 7,8 15,8" />',
  'palette':
      '<path d="M12 3a9 9 0 1 0 .5 18c1.2 0 1.8-.9 1.8-1.8 0-.5-.2-.9-.5-1.2-.3-.3-.5-.7-.5-1.2 0-1 .8-1.8 1.8-1.8H17a4 4 0 0 0 4-4c0-4.4-4-8-9-8z" /><circle cx="7.5" cy="11" r="0.6" /><circle cx="10" cy="7.5" r="0.6" /><circle cx="14" cy="7" r="0.6" /><circle cx="16.8" cy="10" r="0.6" />',
  'trophy':
      '<path d="M6 9H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h2" /><path d="M18 9h2a2 2 0 0 0 2-2V5a2 2 0 0 0-2-2h-2" /><path d="M6 3h12v6a6 6 0 0 1-12 0V3z" /><path d="M9 21h6M12 15v6" />',
  'settings':
      '<circle cx="12" cy="12" r="3" /><path d="M12 1v2M12 21v2M4.22 4.22l1.42 1.42M18.36 18.36l1.42 1.42M1 12h2M21 12h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42" />',
  'share': '<circle cx="18" cy="5" r="3" /><circle cx="6" cy="12" r="3" /><circle cx="18" cy="19" r="3" /><line x1="8.59" y1="13.51" x2="15.42" y2="17.49" /><line x1="15.41" y1="6.51" x2="8.59" y2="10.49" />',
  'user': '<path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" /><circle cx="12" cy="7" r="4" />',
  'edit': '<path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" /><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z" />',
  'mute': '<polygon points="11,5 6,9 2,9 2,15 6,15 11,19" /><line x1="23" y1="9" x2="17" y2="15" /><line x1="17" y1="9" x2="23" y2="15" />',
  'volume': '<polygon points="11,5 6,9 2,9 2,15 6,15 11,19" /><path d="M15.54 8.46a5 5 0 0 1 0 7.07" /><path d="M19.07 4.93a10 10 0 0 1 0 14.14" />',
  'close': '<line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" />',
  'chevron-right': '<polyline points="9,18 15,12 9,6" />',
  'gift': '<polyline points="20,12 20,22 4,22 4,12" /><rect x="2" y="7" width="20" height="5" /><line x1="12" y1="22" x2="12" y2="7" /><path d="M12 7H7.5a2.5 2.5 0 0 1 0-5C11 2 12 7 12 7z" /><path d="M12 7h4.5a2.5 2.5 0 0 0 0-5C13 2 12 7 12 7z" />',
  'moon': '<path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z" />',
  'flame':
      '<path d="M8.5 14.5A2.5 2.5 0 0 0 11 12c0-1.38-.5-2-1-3-1.072-2.143-.224-4.054 2-6 .5 2.5 2 4.9 4 6.5 2 1.6 3 3.5 3 5.5a7 7 0 1 1-14 0c0-1.153.433-2.294 1-3a2.5 2.5 0 0 0 2.5 2.5z" />',
  'mixer': '<line x1="4" y1="21" x2="4" y2="14" /><line x1="4" y1="10" x2="4" y2="3" /><line x1="12" y1="21" x2="12" y2="12" /><line x1="12" y1="8" x2="12" y2="3" /><line x1="20" y1="21" x2="20" y2="16" /><line x1="20" y1="12" x2="20" y2="3" /><line x1="1" y1="14" x2="7" y2="14" /><line x1="9" y1="8" x2="15" y2="8" /><line x1="17" y1="16" x2="23" y2="16" />',
  'clock': '<circle cx="12" cy="12" r="10" /><polyline points="12,6 12,12 16,14" />',
  'copy': '<rect x="9" y="9" width="13" height="13" rx="2" ry="2" /><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1" />',
  'lock': '<rect x="3" y="11" width="18" height="11" rx="2" ry="2" /><path d="M7 11V7a5 5 0 0 1 10 0v4" />',
  'check': '<polyline points="20,6 9,17 4,12" />',
  'mountain': '<path d="M8 21l4-11 4 11" /><path d="M2 21l6-14 4 8" /><path d="M14 21l4-8 4 8" />',
  'bird': '<path d="M16 7c-2-2-5-2-7 0-3 3-3 7 0 10 2 2 5 3 8 2" /><path d="M16 7c1-3 4-4 6-3" /><circle cx="13" cy="9" r="1" fill="currentColor" stroke="none" />',
  'shuffle': '<path d="M16 3h5v5M4 20L21 3M21 16v5h-5M15 15l6 6M4 4l5 5" />',
  'heart': '<path d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.7l-1-1.1a5.5 5.5 0 0 0-7.8 7.8l1 1.1L12 21.2l7.8-7.7 1-1.1a5.5 5.5 0 0 0 0-7.8z" />',
  'chevron-left': '<path d="M15 18l-6-6 6-6" />',
  'chevron-down': '<path d="M6 9l6 6 6-6" />',
  'award': '<circle cx="12" cy="9" r="6" /><path d="M8.6 14.2L7.5 22l4.5-2.5L16.5 22l-1.1-7.8" />',
  'sun': '<circle cx="12" cy="12" r="4.5" /><path d="M12 2v2.5M12 19.5V22M2 12h2.5M19.5 12H22M4.9 4.9l1.8 1.8M17.3 17.3l1.8 1.8M19.1 4.9l-1.8 1.8M6.7 17.3l-1.8 1.8" />',
  'contrast': '<circle cx="12" cy="12" r="9" /><path d="M12 3v18" />',
  '__default__': '<circle cx="12" cy="12" r="8" />',
};

/// 已注册的非默认图标名集合（与原型 Icon.vue 的 name 清单一致）。
const Set<String> _known = {
  'wave', 'white-noise', 'pink-noise', 'brown-noise', 'red-noise',
  'rain', 'wave-ocean', 'forest', 'stream', 'fire', 'coffee', 'train',
  'fan', 'play', 'pause', 'timer', 'save', 'palette', 'trophy', 'settings',
  'share', 'user', 'edit', 'mute', 'volume', 'close', 'chevron-right',
  'chevron-left', 'gift', 'moon', 'flame', 'mixer', 'clock', 'copy', 'lock',
  'check', 'mountain', 'bird', 'shuffle', 'heart', 'award', 'sun', 'contrast',
  'chevron-down',
};

/// 该图标名是否已注册。
bool hasAppIcon(String name) => _known.contains(name);

/// 取图标 body；未知名图标回退默认圆点。
String appIconBody(String name) =>
    appIconBodies[name] ?? appIconBodies['__default__']!;
