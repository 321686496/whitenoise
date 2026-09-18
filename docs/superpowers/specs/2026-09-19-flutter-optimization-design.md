# 声栖 · Flutter 工程全面优化设计

> 版本 v1.0（2026-09-19） · 对 `snapp/`（Flutter）主工程做一轮系统性加固与打磨
> 前置：T1–T9 全功能已落地，`flutter analyze` 零错误、83 项 `flutter test` 全绿、UI 遵循 Design System MASTER v2
> 依赖 skill：`partial-name` 见各 Phase 标注

---

## 1. 背景与目标

`snapp/` 已是功能完整的主代码工程（iOS / Android / HarmonyOS 三平台），不在救火而是**有基线的代码上做加固**。本优化在五个维度系统性推进，全部以「不破坏现有功能、保持三平台可构建」为前提。

目标产出：
1. 测试覆盖从「services 为主」提升到「关键页面有 widget 测试 + 一条集成测试」
2. 已知布局/调试问题（爆红、溢出、负 margin、设置页空白）逐一定位并固化测试
3. 分层架构边界审计，修正 2-3 处高价值坏味道
4. 核心组件响应式适配 + Widget Preview 化，窄屏无溢出
5. 逐页规范自检 + 主题切换（6配色×3风格×明暗）验收

**铁律**：任何 Phase 完成后必须 `flutter analyze`（零错误零警告）+ `flutter test`（全绿）才视为通过；每阶段停下向用户汇报，确认后再进下一阶段。

---

## 2. 执行顺序与对应 skill

| Phase | 内容 | 对应 skill |
|---|---|---|
| 1 | 测试铺底：关键页面 widget 测试 + 集成测试 | `flutter-add-widget-test` / `flutter-add-integration-test` |
| 2 | 布局/调试问题修复 | `flutter-fix-layout-issues` |
| 3 | 架构与代码质量审计 | `flutter-apply-architecture-best-practices` |
| 4 | 响应式/兼容性 + Widget Preview | `flutter-build-responsive-layout` / `flutter-add-widget-preview` |
| 5 | UI/UX：规范自检 + 主题切换验收 | 规范自检 / 主题验收流程 |

---

## 3. Phase 1 · 测试铺底

**目的**：为后续所有改动铺安全网。

范围（当前缺口：关键页面缺 widget 测试）：
- 为 4 个核心页面补 Widget 测试：首页 `index_page`、场景页 `scene_page`、播放器 `player_page`、播放条 `play_bar`（含混音交互）。
- 补一条集成测试：冷启动 → 首页 → 播放一个场景 → 底部 PlayBar 同步 → 停止，完整链路。

**验收标准**：
- `flutter test` 全绿。
- 新增 widget 测试 ≥ 6–8 项 + 1 条集成测试。
- 每个测试对页面渲染与关键交互（点击播放/切换/返回）均有断言。

---

## 4. Phase 2 · 已知布局/调试问题修复

**目的**：消除历史遗留的红屏与溢出风险。

排查清单：
- 设置页卡片空白 + overflow 报错（上次未复现，需定位触发条件）。
- `theme_page` `_ModeDemo` 内部 Column 高度溢出问题复核。
- 受影响底部 Sheet 顶部圆角/边框冲突是否彻底排除。
- 审查所有 `Transform.translate` 替代负 margin 的落地是否覆盖全部历史点位。

**验收标准**：`flutter analyze` 零错误零警告；`flutter test` 全绿；相关页面在窄/宽屏无 overflow 报错；每个修复对应回归测试。

---

## 5. Phase 3 · 架构与代码质量审计

**目的**：分层已成型，做边界审计而非重构重来。

审计点：
- service 层是否遵循「接口与实现分离」目标形态。
- Store/Service 间是否出现直接引用。
- 是否存在可避免的 `dynamic`。
- 单文件是否过大需拆分（以可独立理解/测试为界）。
- 跨平台条件编译（`Platform.isX`）使用是否规范。

**交付**：架构审计报告（找出问题 → 修正 2-3 处高价值项 → 同步 AGENT.md 如涉及目录/约定变更）。

**验收标准**：`flutter analyze` + `flutter test` 全绿；报告列出已修问题与结论。

---

## 6. Phase 4 · 响应式/兼容性 + Widget Preview

**目的**：保证关键字手机与平板等不同屏幕尺寸下布局正确。

内容：
- 为可复用核心组件（SceneCard / SoundCard / PlayBar / 双列网格）加 Widget Preview（`flutter-add-widget-preview`）。
- 用 `LayoutBuilder` / `MediaQuery` 检视关键页面窄屏（小屏机）与宽屏（平板）适配，修正溢出（`flutter-build-responsive-layout`）。

**验收标准**：核心组件有 preview；窄屏关键页无溢出；`flutter analyze` + `flutter test` 全绿。

---

## 7. Phase 5 · UI/UX：规范自检 + 主题切换验收

**目的**：确保视觉与交互严格对齐 Design System MASTER v2、无硬编码、无混搭。

内容：
- **规范自检**：逐页对照 MASTER v2 token / 触控（≥44pt）/ 间距 / 圆角，修正偏差；确认业务代码无 `Color(0xFF…)` / `Colors.xxx` 硬编码。
- **主题切换验收**：抽查 6配色 × 3风格 × 明暗两模式，在首页/播放器/场景页查看可读性、对比度（4.5:1）、明暗分层一致性；每一 UI 风格浮层取向（flat/glass/neu）正确。

**交付**：主题切换验收清单（逐页逐组合结论 + 修正项）。

**验收标准**：验收清单输出；发现的问题修正；`flutter analyze` + `flutter test` 全绿。

---

## 8. 全局约束

- 主工程唯一改动对象为 `snapp/`；`prototype/`（uni-app）仅作设计基线参考，不改其代码。
- 封面、图标、排版遵循 MASTER v2 与品牌（深森林绿 `#3D6B5E`）。
- 引入任何三方库前必须查 Harmony 适配清单（当前各 Phase 均不引入新三方库，若出现需走 5.2 流程）。
- 三平台构建验证：本阶段以代码层保证为主；真机/OHSDK 构建列为后续待办（同 5.7）。
- 改动完成后同步更新涉及的设计文档与 AGENT.md（文档同步规则）。

---

## 9. 文档同步

- 本设计文档写入 `docs/superpowers/specs/` 并提交 git。
- AGENT.md 第八章「关键文档索引」需补录本设计文档。
- 实施计划文档（writing-plans）引用本设计文档。