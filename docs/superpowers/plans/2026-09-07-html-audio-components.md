# 声栖 · 声音播放组件单文件 HTML 展示页 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 用单个自包含 HTML 文件实现声栖 App 风格的声音播放组件展示页，全部组件可真实交互（播放/音量/静音/主题/睡眠定时），用 Web Audio API 合成噪音发声。

**Architecture:** 单文件 `html/audio-components.html`，内嵌 CSS + JS + 内联 SVG。JS 内置主题 token 引擎（6 配色 × 3 风格，运行时写入 CSS 变量，移植自 `prototype/src/theme/index.ts`）；音频引擎用 Web Audio API（白噪/粉噪/雨/海浪/森林/篝火）生成循环 buffer + BiquadFilter + 独立 GainNode，汇集到 Master Gain。交互层分五块：播放控制区 / 声音卡片 / 场景卡片 / 混音轨道 / 底部播放条 + 睡眠定时面板。

**Tech Stack:** 原生 HTML5 + CSS3（CSS 变量、backdrop-filter、pointer events）+ Vanilla JS + Web Audio API。零依赖零构建。

**验证方式说明：** 本项目无测试框架，静态页面采用"浏览器人工验证 + 控制台无报错"作为每任务验收手段。Windows 下执行 `Start-Process "html\audio-components.html"` 可用默认浏览器打开。

## Global Constraints

- 输出唯一文件：`d:\app\projects\whitenoise\html\audio-components.html`（须先创建 `html/` 目录）。
- 零外部资源：不引用任何 CDN/字体/图片，图标全部内联 SVG；字体用系统字体栈。
- `lang="zh-CN"`，文案与 `prototype/src/data/sounds.ts` 一致（声音名/类型/配色/渐变）。
- 默认主题：莫兰迪 + 扁平化；CSS 变量名与 App 一致（`--app-primary`、`--app-card-*` 等）。
- Web Audio API：AudioContext 必须由首次用户点击时创建并 `resume()`；不可用时静默降级（按钮仍切换视觉状态）。
- 同一时间只允许一组声音播放（播放新音先 `stopAll()`）。
- 所有可点元素必须有按下反馈（scale/opacity）。
- 底部为固定播放条，内容区预留 `padding-bottom: 150px`。

---

### Task 1: 页面骨架 + 主题引擎

**Files:**
- Create: `d:\app\projects\whitenoise\html\audio-components.html`（本任务写入完整骨架 + 全部主题 CSS/JS；后续任务在此文件中追加各自区块，最后统一组成完整文件）

**Interfaces:**
- Consumes: 无
- Produces:
  - 全局函数 `el(htmlString): HTMLElement`（任意任务渲染通用）
  - `SCHEMES` / `UI_MODES` / `buildTokens(scheme, ui)` / `applyTheme(scheme, ui)`
  - 公共 CSS 类（后续所有任务复用）：`.app-card`、`.section`、`.section-title`、`.section-desc`、`.sound-icon`（磁贴）、`.chips`、`.chip`、`.slider*`（滑块轨道/填充/圆头）、`.btn-press`（按下反馈）
  - 空容器：`#sec-control`、`#sec-sounds`、`#sec-scenes`、`#sec-mixer`、`#playbar`
  - 全局状态对象：`let APP = { playing: false, current: null, timer: null }`（后续任务读写）

- [ ] **Step 1: 创建目录与文件骨架**

新目录 `d:\app\projects\whitenoise\html\`，创建 `html/audio-components.html` 并写入完整骨架：

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>声栖 · 声音播放组件库</title>
<style>
/* ================= Base ================= */
* { margin: 0; padding: 0; box-sizing: border-box; -webkit-tap-highlight-color: transparent; }
html, body { height: 100%; }
body {
  font-family: -apple-system, BlinkMacSystemFont, "PingFang SC", "Hiragino Sans GB", "Microsoft YaHei", sans-serif;
  background: var(--app-bg);
  background-image: linear-gradient(180deg, transparent 55%, var(--app-bg-grad) 100%);
  background-attachment: fixed;
  color: var(--app-text);
  transition: background .3s, color .3s;
  min-height: 100vh;
}
.app-card { background: var(--app-card-bg); border: 1px solid var(--app-card-border); box-shadow: var(--app-card-shadow); backdrop-filter: blur(var(--app-card-blur, 0)); border-radius: 22px; }
/* ================= Topbar ================= */
.topbar {
  position: sticky; top: 0; z-index: 50;
  display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 14px;
  padding: 16px 24px;
  background: color-mix(in srgb, var(--app-bg) 82%, transparent);
  backdrop-filter: blur(16px);
  border-bottom: 1px solid var(--app-divider);
}
.topbar-title h1 { font-size: 21px; font-weight: 800; letter-spacing: -0.5px; }
.topbar-title p { font-size: 12px; color: var(--app-text-3); margin-top: 3px; }
.theme-controls { display: flex; flex-direction: column; gap: 10px; align-items: flex-end; }
.ctrl-row { display: flex; align-items: center; gap: 10px; }
.ctrl-label { font-size: 12px; color: var(--app-text-2); font-weight: 600; }
.scheme-dots { display: flex; gap: 8px; }
.scheme-dot { width: 24px; height: 24px; border-radius: 50%; cursor: pointer; border: 2px solid transparent; box-shadow: 0 2px 6px rgba(0,0,0,.18); transition: transform .15s, border-color .15s; }
.scheme-dot:hover { transform: scale(1.12); }
.scheme-dot.active { border-color: var(--app-text); transform: scale(1.15); }
.seg { display: flex; background: var(--app-subtle); border-radius: 12px; padding: 3px; gap: 2px; }
.seg-btn { border: 0; background: transparent; color: var(--app-text-2); font-size: 12px; font-weight: 600; padding: 6px 12px; border-radius: 9px; cursor: pointer; transition: all .15s; font-family: inherit; }
.seg-btn.active { background: var(--app-card-bg); color: var(--app-primary); box-shadow: 0 1px 4px rgba(0,0,0,.08); }
/* ================= Sections ================= */
.page { max-width: 720px; margin: 0 auto; padding: 26px 20px 150px; }
.section { margin-bottom: 38px; }
.section-title { font-size: 17px; font-weight: 800; letter-spacing: -.3px; margin-bottom: 6px; }
.section-desc { font-size: 13px; color: var(--app-text-2); margin-bottom: 16px; }
/* ================= 通用磁贴 / chips / 按钮反馈 ================= */
.sound-icon { border-radius: 18px; display: flex; align-items: center; justify-content: center; color: #fff; box-shadow: inset 0 -2px 0 rgba(0,0,0,.08), inset 0 2px 0 rgba(255,255,255,.25), 0 4px 10px rgba(0,0,0,.10); flex-shrink: 0; }
.chips { display: flex; gap: 6px; flex-wrap: wrap; }
.chip { font-size: 11px; padding: 3px 10px; border-radius: 10px; background: rgba(255,255,255,.22); color: #fff; font-weight: 600; }
.btn-press { transition: transform .16s ease, opacity .16s ease; cursor: pointer; user-select: none; }
.btn-press:active { transform: scale(.88); }
@media (max-width: 520px) { .topbar { padding: 14px 16px; } .page { padding: 18px 14px 150px; } }
</style>
</head>
<body>
<header class="topbar">
  <div class="topbar-title"><h1>声栖</h1><p>声音播放组件库 · 单文件演示</p></div>
  <div class="theme-controls">
    <div class="ctrl-row"><span class="ctrl-label">配色</span><div class="scheme-dots" id="scheme-dots"></div></div>
    <div class="ctrl-row"><span class="ctrl-label">风格</span><div class="seg" id="ui-seg"></div></div>
  </div>
</header>
<main class="page">
  <section class="section" id="sec-control"></section>
  <section class="section" id="sec-sounds"></section>
  <section class="section" id="sec-scenes"></section>
  <section class="section" id="sec-mixer"></section>
</main>
<footer class="playbar" id="playbar"></footer>
<script>
'use strict';
/* ---- helper ---- */
function el(html) { const t = document.createElement('template'); t.innerHTML = html.trim(); return t.content.firstElementChild; }
function notify(msg) {
  let n = document.querySelector('.toast');
  if (!n) { n = el('<div class="toast"></div>'); n.style.cssText = 'position:fixed;left:50%;bottom:150px;transform:translateX(-50%);z-index:300;background:var(--app-primary);color:var(--app-on-primary);font-size:13px;font-weight:600;padding:10px 18px;border-radius:20px;box-shadow:0 8px 24px rgba(0,0,0,.2);opacity:0;transition:opacity .25s;pointer-events:none;'; document.body.appendChild(n); }
  n.textContent = msg; n.style.opacity = '1';
  clearTimeout(n._t); n._t = setTimeout(() => { n.style.opacity = '0'; }, 1600);
}
/* ---- 全局状态 ---- */
const APP = { playing: false, current: null, timer: null, tracks: [null, null, null] };
/* ================= 主题引擎（移植自 prototype/src/theme/index.ts） ================= */
const SCHEMES = {
  morandi: { label: '莫兰迪', swatch: '#5C8A72', t: { primary:'#5C8A72', primarySoft:'rgba(92,138,114,.14)', primaryDark:'#3F6352', onPrimary:'#FFFFFF', accent:'#8FB8A0', bg:'#F2F0EA', bgGrad:'#E7E4DA', cardBorder:'#E6E1D6', text:'#2F3B35', text2:'#6E7B74', text3:'#A6B0A9', divider:'#ECE8DE', subtle:'#ECE9E0', danger:'#C4706B', glassCard:'rgba(255,255,255,.62)', glassBorder:'rgba(255,255,255,.9)', neuTint:'#EAE7DD', neuA:'rgba(90,110,100,.16)', neuB:'rgba(255,255,255,.92)' } },
  ocean: { label: '深海', swatch: '#5FB0B0', t: { primary:'#5FB0B0', primarySoft:'rgba(95,176,176,.16)', primaryDark:'#3E8C8C', onPrimary:'#062026', accent:'#9FD4D4', bg:'#0E2230', bgGrad:'#16303F', cardBorder:'#244453', text:'#E6F2F3', text2:'#9FB9C1', text3:'#6E8C95', divider:'#244150', subtle:'#1D3946', danger:'#D98B7B', glassCard:'rgba(22,48,62,.58)', glassBorder:'rgba(255,255,255,.14)', neuTint:'#14303E', neuA:'rgba(0,0,0,.38)', neuB:'rgba(70,120,140,.16)' } },
  forest: { label: '森林', swatch: '#4A6741', t: { primary:'#4A6741', primarySoft:'rgba(74,103,65,.14)', primaryDark:'#334A2C', onPrimary:'#FFFFFF', accent:'#7C9D6E', bg:'#EEF1E6', bgGrad:'#E0E9D6', cardBorder:'#E0E6D5', text:'#2C3628', text2:'#68725D', text3:'#99A48F', divider:'#E5EADB', subtle:'#E4ECDA', danger:'#C0705B', glassCard:'rgba(255,255,255,.6)', glassBorder:'rgba(255,255,255,.85)', neuTint:'#E3ECDA', neuA:'rgba(60,90,50,.16)', neuB:'rgba(255,255,255,.92)' } },
  sunset: { label: '日落', swatch: '#C06B48', t: { primary:'#C06B48', primarySoft:'rgba(192,107,72,.14)', primaryDark:'#9C4E32', onPrimary:'#FFFFFF', accent:'#E3A377', bg:'#FBF1E6', bgGrad:'#F4E2CE', cardBorder:'#F0E0CE', text:'#3E3128', text2:'#7E6E62', text3:'#AB9A8B', divider:'#F2E8DC', subtle:'#F6EADD', danger:'#C15B58', glassCard:'rgba(255,255,255,.62)', glassBorder:'rgba(255,255,255,.88)', neuTint:'#F2E4D5', neuA:'rgba(160,100,70,.16)', neuB:'rgba(255,255,255,.92)' } },
  lavender: { label: '薰衣草', swatch: '#8A7BB0', t: { primary:'#8A7BB0', primarySoft:'rgba(138,123,176,.14)', primaryDark:'#6A5A8E', onPrimary:'#FFFFFF', accent:'#B3A5CE', bg:'#F4F1FA', bgGrad:'#E9E3F4', cardBorder:'#E2DCF0', text:'#37324A', text2:'#7A7292', text3:'#A8A1C0', divider:'#ECE6F5', subtle:'#EDE9F5', danger:'#C0759B', glassCard:'rgba(255,255,255,.62)', glassBorder:'rgba(255,255,255,.88)', neuTint:'#E8E3F3', neuA:'rgba(105,85,140,.16)', neuB:'rgba(255,255,255,.92)' } },
  mono: { label: '极简黑白', swatch: '#2F2F2F', t: { primary:'#2F2F2F', primarySoft:'rgba(31,31,31,.08)', primaryDark:'#101010', onPrimary:'#FFFFFF', accent:'#6B6B6B', bg:'#FAFAFA', bgGrad:'#F0F0F0', cardBorder:'#EBEBEB', text:'#1A1A1A', text2:'#6E6E6E', text3:'#A9A9A9', divider:'#EDEDED', subtle:'#F2F2F2', danger:'#B1483D', glassCard:'rgba(255,255,255,.62)', glassBorder:'rgba(255,255,255,.95)', neuTint:'#EFEFEF', neuA:'rgba(0,0,0,.12)', neuB:'rgba(255,255,255,.95)' } },
};
const UI_MODES = [{ key: 'flat', label: '扁平化' }, { key: 'glass', label: '玻璃拟态' }, { key: 'neu', label: '新拟态' }];
const schemeKeys = Object.keys(SCHEMES);

function buildTokens(scheme, ui) {
  const t = SCHEMES[scheme].t;
  let cardBg = '#FFFFFF', cardBorder = t.cardBorder, cardShadow = '0 2px 12px ' + t.neuA, cardBlur = '0',
      inputBg = t.subtle, inputBorder = 'transparent';
  if (ui === 'flat') { cardShadow = '0 2px 12px ' + t.neuA; inputBg = '#FFFFFF'; inputBorder = t.cardBorder; }
  else if (ui === 'glass') { cardBg = t.glassCard; cardBorder = t.glassBorder; cardShadow = '0 8px 26px rgba(20,40,34,.10)'; cardBlur = '22px'; inputBg = 'rgba(255,255,255,.5)'; inputBorder = t.glassBorder; }
  else if (ui === 'neu') { cardBg = t.neuTint; cardBorder = 'transparent'; cardShadow = '7px 7px 16px ' + t.neuA + ', -7px -7px 18px ' + t.neuB; inputBg = t.neuTint; inputBorder = 'transparent'; }
  return {
    '--app-primary': t.primary, '--app-primary-soft': t.primarySoft, '--app-primary-dark': t.primaryDark,
    '--app-on-primary': t.onPrimary, '--app-accent': t.accent, '--app-bg': t.bg, '--app-bg-grad': t.bgGrad,
    '--app-card-bg': cardBg, '--app-card-border': cardBorder, '--app-card-shadow': cardShadow, '--app-card-blur': cardBlur,
    '--app-text': t.text, '--app-text-2': t.text2, '--app-text-3': t.text3, '--app-divider': t.divider,
    '--app-subtle': t.subtle, '--app-press': (ui === 'glass' ? 'rgba(255,255,255,.35)' : t.subtle),
    '--app-input-bg': inputBg, '--app-input-border': inputBorder, '--app-danger': t.danger,
  };
}
function applyTheme(scheme, ui) {
  const root = document.documentElement;
  Object.entries(buildTokens(scheme, ui)).forEach(([k, v]) => root.style.setProperty(k, v));
  root.dataset.scheme = scheme; root.dataset.ui = ui;
}
let curScheme = 'morandi', curUi = 'flat';
applyTheme(curScheme, curUi);

/* ---- 渲染主题切换器 ---- */
const dots = document.getElementById('scheme-dots');
schemeKeys.forEach(k => {
  const d = el(`<button class="scheme-dot ${k === curScheme ? 'active' : ''}" title="${SCHEMES[k].label}" data-k="${k}" style="background:${SCHEMES[k].swatch}"></button>`);
  d.addEventListener('click', () => { curScheme = k; applyTheme(curScheme, curUi); dots.querySelectorAll('.scheme-dot').forEach(x => x.classList.toggle('active', x.dataset.k === k)); });
  dots.appendChild(d);
});
const seg = document.getElementById('ui-seg');
UI_MODES.forEach(m => {
  const b = el(`<button class="seg-btn ${m.key === curUi ? 'active' : ''}" data-k="${m.key}">${m.label}</button>`);
  b.addEventListener('click', () => { curUi = m.key; applyTheme(curScheme, curUi); seg.querySelectorAll('.seg-btn').forEach(x => x.classList.toggle('active', x.dataset.k === m.key)); });
  seg.appendChild(b);
});
</script>
</body>
</html>
```

（注：`.toast` 由 JS observer 验证；`.app-card` 等已就绪。）

- [ ] **Step 2: 浏览器验证骨架与主题**

运行 `Start-Process "html\audio-components.html"`。

预期：页面出现顶部"声栖"标题与 6 个配色圆点 + 3 个风格分段按钮；点击"深海"配色 → 背景变深蓝；点击"新拟态" → 卡片样式变化（本阶段页面尚无卡片，可检查顶栏/背景色与文字颜色变化）；控制台无报错。

- [ ] **Step 3: 提交（可选，如仓库已初始化）**

```bash
git add html/audio-components.html
git commit -m "feat(audio-components): 页面骨架与主题引擎"
```

---

### Task 2: 播放控制区 + Web Audio 音频引擎

**Files:**
- Modify: `html/audio-components.html`（在 `<section id="sec-control"></section>` 内追加内容；在 `<script>` 中 `/* ---- 渲染主题切换器 ---- */` 之前追加音频引擎代码）

**Interfaces:**
- Consumes: `el()`、`notify()`、`APP`（Task 1）
- Produces:
  - `ICAFF}ND: ND` 旁注：以下为本任务产出（后续任务依赖）
  - `ensureAudio()`：创建/恢复 AudioContext 与 Master Gain
  - `stopAll()`：停止当前全部声音节点并清理 `APP.tracks`
  - `playSources(soundsList)`：`soundsList = [{ id, noise, vol }]`，停止旧音、依次新建声源，返回每个声源句柄数组；每个声源 `{ id, gain, src, filters:[...], lfo:null }` 存入 `APP.playingNodes`
  - `setSoundGain(id, v)`：按 id 设置对应声源 gain（Task 3/4 音量滑块用）
  - `setMasterVolume(v)`：设置 Master Gain 音量（Task 2 主音量滑块用）
  - `masterVol`（全局变量，初始 0.6）；`NODES`（Task 5 渐弱用）
  - DOM/CSS 类：`.main-btn`（圆形播放主按钮，含 `::-after` 波纹）、`.eq` / `.eq-bar`（4 柱均衡器，播放时 `.playing` 触发动画）、`.slider` / `.slider-fill` / `.slider-thumb`、`.vol-percent`
  - 全局函数 `bindSlider(sliderEl, onChange)`：把滑块元素的点击/拖动（pointer 事件）换算为 0~1，回调 onChange

- [ ] **Step 1: 写入播放控制区 HTML/CSS 与音频引擎 JS**

在 `<style>` 中 `/* ================= 通用磁贴... */` 之前追加：

```css
/* ================= 播放控制区 ================= */
.control-panel { padding: 26px; display: flex; flex-direction: column; align-items: center; gap: 22px; }
.main-btn {
  width: 96px; height: 96px; border-radius: 50%; border: 0; cursor: pointer; position: relative;
  display: flex; align-items: center; justify-content: center; color: var(--app-on-primary);
  background: linear-gradient(135deg, var(--app-primary), var(--app-primary-dark));
  box-shadow: 0 12px 26px color-mix(in srgb, var(--app-primary) 36%, transparent);
  transition: transform .16s cubic-bezier(.4,0,.2,1);
}
.main-btn:active { transform: scale(.9); }
.main-btn.playing::after { content: ''; position: absolute; inset: 0; border-radius: 50%; box-shadow: 0 0 0 0 color-mix(in srgb, var(--app-primary) 55%, transparent); animation: ripple 1.6s ease-out infinite; }
@keyframes ripple { to { box-shadow: 0 0 0 18px transparent; } }
.eq { display: flex; align-items: flex-end; gap: 5px; height: 30px; }
.eq-bar { width: 5px; border-radius: 3px; background: var(--app-text-3); transition: background .2s;
  height: 10px; }
.eq-bar:nth-child(2) { height: 20px; } .eq-bar:nth-child(3) { height: 14px; } .eq-bar:nth-child(4) { height: 17px; }
.eq.playing .eq-bar { background: var(--app-primary); animation: eqwave 1.2s ease-in-out infinite; }
.eq.playing .eq-bar:nth-child(2) { animation-delay: .2s; } .eq.playing .eq-bar:nth-child(3) { animation-delay: .4s; } .eq.playing .eq-bar:nth-child(4) { animation-delay: .6s; }
@keyframes eqwave { 0%,100% { transform: scaleY(.5); } 50% { transform: scaleY(1.5); } }
.volume-row { display: flex; align-items: center; gap: 14px; width: 100%; max-width: 420px; }
.volume-row .vol-label { font-size: 14px; font-weight: 700; color: var(--app-primary); min-width: 44px; text-align: right; }
.slider { flex: 1; height: 34px; display: flex; align-items: center; cursor: pointer; position: relative; touch-action: none; }
.slider-track { width: 100%; height: 8px; border-radius: 4px; background: var(--app-input-bg); position: relative; overflow: visible; }
.slider-fill { height: 100%; border-radius: 4px; background: linear-gradient(90deg, var(--app-primary), var(--app-accent)); }
.slider-thumb { position: absolute; top: 50%; width: 22px; height: 22px; border-radius: 50%; background: #fff; box-shadow: 0 2px 8px rgba(0,0,0,.25); transform: translate(-50%, -50%); }
```

在 `<section class="section" id="sec-control"></section>` 内填充：

```html
<h2 class="section-title">播放控制</h2>
<p class="section-desc">圆形主播放按钮 · 均衡器动效 · 主音量滑块</p>
<div class="control-panel app-card" id="control-panel">
  <button class="main-btn btn-press" id="main-play" aria-label="播放" style="color:var(--app-on-primary)"></button>
  <div class="eq" id="eq-main"><span class="eq-bar"></span><span class="eq-bar"></span><span class="eq-bar"></span><span class="eq-bar"></span></div>
  <div class="volume-row">
    <span class="vol-icon" id="vol-icon-main"></span>
    <div class="slider" id="slider-main" role="slider" aria-label="主音量" tabindex="0">
      <div class="slider-track"><div class="slider-fill" id="slider-main-fill"></div><div class="slider-thumb" id="slider-main-thumb"></div></div>
    </div>
    <span class="vol-label" id="vol-label-main">60%</span>
  </div>
</div>
```

在 `<script>` 内 `/* ---- 渲染主题切换器 ---- */` 之前追加：

```js
/* ================= 内联 SVG 图标 ================= */
const ICONS = {
  play: '<path d="M8 5.14v13.72c0 .8.87 1.29 1.56.88l10.79-6.86a1.03 1.03 0 0 0 0-1.76L9.56 4.26A1.03 1.03 0 0 0 8 5.14z"/>',
  pause: '<path d="M7.5 5h4v14h-4zM12.5 5h4v14h-4z"/>',
  volume: '<path d="M4 9.5h3.5L12 5.5v13l-4.5-4H4z"/><path d="M15.5 9a4.5 4.5 0 0 1 0 6M18 6.8a7.5 7.5 0 0 1 0 10.4" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/>',
  mute: '<path d="M4 9.5h3.5L12 5.5v13l-4.5-4H4z"/><path d="M16 9.5l5 5M21 9.5l-5 5" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/>',
  lock: '<rect x="6" y="11" width="12" height="9" rx="2.5"/><path d="M9 11V8a3 3 0 0 1 6 0v3" fill="none" stroke="currentColor" stroke-width="1.6"/>',
  timer: '<circle cx="12" cy="13" r="8"/><path d="M12 9v4l3 2M9.5 2.5h5" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/>',
  heart: '<path d="M12 20.5S4 15 4 9.6A4.4 4.4 0 0 1 12 6.9a4.4 4.4 0 0 1 8 2.7c0 5.4-8 10.9-8 10.9z"/>',
  wave: '<path d="M2 12c2-2 3.5-2 5 0s3 2 5 0 3.5-2 5 0 3 2 5 0" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/>',
  rain: '<path d="M4 8a4 4 0 0 1 8 0 4 4 0 0 1 4 3.5M14 11.5c1.5.5 2.5 2 2 3.5M3.5 13.5C1.5 15 2.5 18 5 18c1.5 0 2.5-1 2.5-2.3C7.5 14 6 13 5 13.5" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/>',
  ocean: '<path d="M2 14c2.5-3 5-3 7.5 0s5 3 7.5 0 3.5-1.5 5 0M2 19c2.5-3 5-3 7.5 0s5 3 7.5 0 3.5-1.5 5 0M2 9c2.5-3 5-3 7.5 0s5 3 7.5 0 3.5-1.5 5 0" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/>',
  forest: '<path d="M7 20v-4M7 9l2.5-4L12 9l2.5-5 2.5 5 1.5-2.5L20 7v13H7zM7 20h13M2 12l4-2 1 4M1.5 17l4-2 1.5 3M3 20h4" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/>',
  fire: '<path d="M12 3s6 4.5 6 10a6 6 0 0 1-12 0c0-2 .8-3.6 1.8-4.8.3 1 1 1.9 2 2.2C9 7.5 10 4.8 12 3z" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/>',
  check: '<path d="M4 12.5l5 5L20 6.5" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"/>',
  close: '<path d="M6 6l12 12M18 6L6 18" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>',
  share: '<circle cx="18" cy="5" r="2.5"/><circle cx="6" cy="12" r="2.5"/><circle cx="18" cy="19" r="2.5"/><path d="M8.2 10.8l7.6-4.4M8.2 13.2l7.6 4.4" fill="none" stroke="currentColor" stroke-width="1.5"/>',
};
function icon(name, size) { return `<svg viewBox="0 0 24 24" width="${size || 22}" height="${size || 22}" fill="currentColor" stroke="none" style="display:block">${ICONS[name]}</svg>`; }

/* ================= Web Audio 引擎 ================= */
let ctx = null, masterGain = null, masterVol = 0.6;
const NODES = { list: new Map() }; /* id -> { gain, src, filters, loopNodes } */

function ensureAudio() {
  if (!ctx) {
    ctx = new (window.AudioContext || window.webkitAudioContext)();
    masterGain = ctx.createGain();
    masterGain.gain.value = masterVol;
    masterGain.connect(ctx.destination);
  }
  if (ctx.state === 'suspended') ctx.resume();
  return ctx;
}
/* noise 预设：white 直通 / pink 低通 / rain 带通 / ocean 低通+LFO / forest 带通 / fire 高通 */
const NOISE_PRESETS = {
  pink:     { type: 'lowpass',  freq: 480 },
  rain:     { type: 'bandpass', freq: 1300, q: .55 },
  ocean:    { type: 'lowpass',  freq: 750,  lfo: { rate: .12, depth: .55 } },
  forest:   { type: 'bandpass', freq: 720,  q: .4 },
  fire:     { type: 'highpass', freq: 220 },
};
function noiseBuffer(seconds = 3) {
  const b = ctx.createBuffer(1, ctx.sampleRate * seconds, ctx.sampleRate);
  const d = b.getChannelData(0);
  let last = 0;
  for (let i = 0; i < d.length; i++) {
    const w = Math.random() * 2 - 1;
    last = (last + .02 * w) / 1.02;
    d[i] = (w * 0.6 + last * 0.4);
  }
  return b;
}
function stopAll() {
  NODES.list.forEach(n => { try { n.src.stop(); } catch (e) {} });
  NODES.list.clear();
  APP.playing = false;
  APP.current = null;
  APP.tracks = [null, null, null];
  syncPlayingUI();
  if (typeof renderMixer === 'function') renderMixer();
}
function playSources(soundsList, sceneMeta) {
  stopAll();
  ensureAudio();
  const handles = [];
  soundsList.forEach((s, i) => {
    const src = ctx.createBufferSource();
    src.buffer = noiseBuffer(); src.loop = true;
    const gain = ctx.createGain(); gain.gain.value = s.vol || .5;
    let node = src;
    const preset = NOISE_PRESETS[s.noise];
    if (preset) {
      const f = ctx.createBiquadFilter();
      f.type = preset.type; f.frequency.value = preset.freq; if (preset.q) f.Q.value = preset.q;
      node.connect(f); node = f;
    }
    node.connect(gain); gain.connect(masterGain);
    src.start();
    const h = { id: s.id, name: s.name, icon: s.icon, color: s.color, noise: s.noise, gain, src, filter: node };
    if (preset && preset.lfo) {
      const lfo = ctx.createOscillator(), lg = ctx.createGain();
      lfo.frequency.value = preset.lfo.rate; lg.gain.value = preset.lfo.depth * (s.vol || .5);
      lfo.connect(lg); lg.connect(gain.gain); lfo.start();
      h.lfo = (s.vol || .5);
    }
    NODES.list.set(s.id, h); handles.push(h);
  });
  APP.playing = true;
  if (sceneMeta) { APP.current = sceneMeta; } else { APP.current = soundsList[0]; }
  syncPlayingUI();
  return handles;
}
function setSoundGain(id, v) { const n = NODES.list.get(id); if (n) n.gain.gain.setTargetAtTime(v, ctx.currentTime, .02); }
function setMasterVolume(v) { masterVol = v; if (masterGain) masterGain.gain.setTargetAtTime(v, ctx.currentTime, .02); }
function syncPlayingUI() {
  const eqs = document.querySelectorAll('.eq');
  const btns = document.querySelectorAll('.main-btn');
  eqs.forEach(e => e.classList.toggle('playing', APP.playing));
  btns.forEach(b => {
    b.classList.toggle('playing', APP.playing);
    const child = b.querySelector('svg'); if (child) b.innerHTML = icon(APP.playing ? 'pause' : 'play', 34);
  });
  if (typeof updatePlaybarMeta === 'function') updatePlaybarMeta();
}

/* ================= 通用滑块（pointer 拖动） ================= */
function bindSlider(sliderEl, onChange) {
  const fill = sliderEl.querySelector('.slider-fill'), thumb = sliderEl.querySelector('.slider-thumb');
  function setFromClientX(clientX) {
    const r = sliderEl.getBoundingClientRect();
    const v = Math.min(1, Math.max(0, (clientX - r.left) / r.width));
    fill.style.width = (v * 100) + '%';
    thumb.style.left = (v * 100) + '%';
    onChange(v);
  }
  let dragging = false;
  sliderEl.addEventListener('pointerdown', e => { dragging = true; sliderEl.setPointerCapture(e.pointerId); setFromClientX(e.clientX); });
  sliderEl.addEventListener('pointermove', e => { if (dragging) setFromClientX(e.clientX); });
  sliderEl.addEventListener('pointerup', () => { dragging = false; });
  return { setFromClientX, set(v) { setFromClientX(0); fill.style.width = (v*100)+'%'; thumb.style.left = (v*100)+'%'; } };
}

/* ---- 渲染播放控制区（填充 #sec-control）及绑定事件 ---- */
(function initControl() {
  const sec = document.getElementById('sec-control');
  sec.innerHTML = `<h2 class="section-title">播放控制</h2>
  <p class="section-desc">圆形主播放按钮 · 均衡器动效 · 主音量滑块</p>
  <div class="control-panel app-card" id="control-panel">
    <button class="main-btn btn-press" id="main-play" aria-label="播放" style="color:var(--app-on-primary)">${icon('play', 34)}</button>
    <div class="eq" id="eq-main">${'<span class="eq-bar"></span>'.repeat(4)}</div>
    <div class="volume-row">
      <span class="vol-icon" id="vol-icon-main">${icon('volume', 20)}</span>
      <div class="slider" id="slider-main" role="slider" aria-label="主音量" tabindex="0">
        <div class="slider-track"><div class="slider-fill" style="width:60%"></div><div class="slider-thumb" style="left:60%"></div></div>
      </div>
      <span class="vol-label" id="vol-label-main">60%</span>
    </div>
  </div>`;
  const playBtn = sec.querySelector('#main-play');
  playBtn.addEventListener('click', () => {
    if (APP.playing) { stopAll(); return; }
    playTrackFromCard('white-noise'); /* Task 3 提供；本阶段先提供 fallback */
  });
  const sliderMain = sec.querySelector('#slider-main');
  const volLabel = sec.querySelector('#vol-label-main');
  bindSlider(sliderMain, v => { setMasterVolume(v); volLabel.textContent = Math.round(v * 100) + '%'; });
  const volIcon = sec.querySelector('#vol-icon-main');
  volIcon.addEventListener('click', () => {
    if (masterVol > 0) { setMasterVolume(0); volLabel.textContent = '0%'; fillZero(); } else { setMasterVolume(.6); volLabel.textContent = '60%'; }
    volIcon.innerHTML = icon(masterVol > 0 ? 'volume' : 'mute', 20);
  });
  function fillZero() { const s = sec.querySelector('#slider-main'); s.querySelector('.slider-fill').style.width = '0%'; s.querySelector('.slider-thumb').style.left = '0%'; }
})();
```

- [ ] **Step 2: 浏览器验证播放控制区**

刷新页面。预期：出现"播放控制"卡片（渐变圆按钮 + 4 柱均衡器 + 音量滑块）；点击主播放按钮 → 有声音、按钮变暂停图标、均衡器跳动；再点 → 静音、均衡器静止；拖动滑块音量实时变化、百分比同步；控制台无报错。

（注：本阶段主播放按钮默认播放"白噪音"，由 Task 3 的 `playTrackFromCard` 实现，因此 Task 2 完成后点击会报 `playTrackFromCard is not a function`——**这是预期行为**，Task 3 完成后消除。若想暂不报错，可在 initControl 中临时改为 `ensureAudio(); notify('音频引擎就绪');`）

- [ ] **Step 3: 提交**

```bash
git add html/audio-components.html
git commit -m "feat(audio-components): 播放控制区与 Web Audio 引擎"
```

---

### Task 3: 声音卡片网格

**Files:**
- Modify: `html/audio-components.html`（`#sec-sounds` 填充；`<script>` 追加数据与渲染逻辑）

**Interfaces:**
- Consumes: `el()`、`icon()`、`playSources()`、`setSoundGain()`、`stopAll()`、`APP`、`bindSlider()`（Task 1/2）
- Produces:
  - 全局函数 `playTrackFromCard(id)`：按声音 id 播放（track0 = 单音），同步选中高亮；与 Task 5 播放条联动
  - 声音数据常量 `SOUNDS`（6 条，字段 `id/name/type/noise/icon/color/gradient/duration/quality`）
  - 混音轨道渲染容器 `#mixer-list`、全局函数 `renderMixer()` 与 `setTrack(i, data|null)`、轨道数组读写 `APP.tracks[i]`（Task 4 实现 `renderMixer`；本任务仅调用占位——Task 2 已在 `stopAll` 内调用 `renderMixer`，Task 4 前需要空实现兜底）

- [ ] **Step 1: 写入声音数据与卡片渲染**

在 `<script>` 内 `/* ---- 渲染播放控制区 ---- */` 之前追加：

```js
/* ================= 声音数据（精选自 sounds.ts） ================= */
const SOUNDS = [
  { id: 'white-noise', name: '白噪音', type: '合成白噪音', noise: null, color: '#8296A8', gradient: 'linear-gradient(135deg,#9FB2C4,#6E8396)', duration: '60:00', quality: '无损' },
  { id: 'pink-noise', name: '粉红噪音', type: '合成白噪音', noise: 'pink', color: '#C49A92', gradient: 'linear-gradient(135deg,#D9B4AC,#AE7C73)', duration: '45:00', quality: '高清' },
  { id: 'rain', name: '雨声', type: '自然音', noise: 'rain', color: '#7E93A8', gradient: 'linear-gradient(135deg,#9AABC0,#667C91)', duration: '60:00', quality: '无损' },
  { id: 'ocean-wave', name: '海浪', type: '自然音', noise: 'ocean', color: '#5F8296', gradient: 'linear-gradient(135deg,#7EA2B6,#48657A)', duration: '55:00', quality: '无损' },
  { id: 'forest', name: '森林', type: '自然音', noise: 'forest', color: '#7E9A74', gradient: 'linear-gradient(135deg,#9CB493,#64825C)', duration: '50:00', quality: '无损' },
  { id: 'campfire', name: '篝火', type: '自然音', noise: 'fire', color: '#B97A48', gradient: 'linear-gradient(135deg,#D39A68,#9C5F34)', duration: '35:00', quality: '高清' },
];
function findSound(id) { return SOUNDS.find(s => s.id === id); }

/* ================= 声音卡片网格（#sec-sounds） ================= */
function renderSounds() {
  const sec = document.getElementById('sec-sounds');
  sec.innerHTML = `<h2 class="section-title">声音卡片</h2>
  <p class="section-desc">点击卡片即播放对应声音，再次点击选中的卡片可停止</p>
  <div class="sound-grid" id="sound-grid" style="display:grid;grid-template-columns:repeat(auto-fill,minmax(132px,1fr));gap:14px;">${SOUNDS.map(s => cardHtml(s)).join('')}</div>`;
  sec.querySelectorAll('.sound-card').forEach(card => {
    card.addEventListener('click', () => {
      const id = card.dataset.id;
      if (card.classList.contains('active')) { stopAll(); return; }
      playTrackFromCard(id);
    });
  });
}
function cardHtml(s) {
  return `<div class="sound-card app-card btn-press" data-id="${s.id}" style="display:flex;flex-direction:column;align-items:center;gap:10