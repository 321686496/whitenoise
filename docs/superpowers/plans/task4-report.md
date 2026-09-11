# Task 4 实现报告 — App 外壳 / 命名路由 / 悬浮 TabBar / 公共样式原语

> 日期：2026-09-11
> 归属计划：`docs/superpowers/plans/2026-09-11-flutter-foundation.md`（Task 4）

## 一、Status：完成

`flutter analyze`（No issues found）、`flutter test`（8 项全部通过，含既有 theme_notifier / app_icon 测试）。

## 二、改动文件

### 新建
- `snapp/lib/widgets/app_section.dart` — `AppSectionTitle`（12px、text2 色）、`AppDivider`（divider 色），样式走 `appColors`。
- `snapp/lib/widgets/app_card.dart` — `AppCard({child, padding=16, radius?})`；底色/描边（.5）走 `appColors.cardBg/cardBorder`，圆角/阴影走 `appShapes.cardRadius/cardShadow`。玻璃毛玻璃（`cardBlur`）本轮未包 BackdropFilter，属计划允差。
- `snapp/lib/widgets/app_buttons.dart` — `AppPrimaryButton`（primary/onPrimary，圆角 26）、`AppOutlineButton`（primary 文字 + 描边）。按下态交由 Material 默认。
- `snapp/lib/widgets/app_page.dart` — `AppPage`（StatefulWidget）：顶部柔和渐变 `bgGrad→bg`、SafeArea、上浮/淡入动效，`platformDispatcher.accessibilityFeatures.disableAnimations` 关闭动画时跳过。
- `snapp/lib/widgets/tab_bar.dart` — 悬浮 `AppTabBar`（4 tab：home/scene/discover/mine → wave/mountain/palette/user），选中 `appColors.primary`、未选 `text3`，卡片用 `appColors.cardBg/cardBorder` + `appShapes.cardRadius/cardShadow`。用 `_TabItem` 类（非 record，Dart 2.19）。
- `snapp/lib/pages/placeholder.dart` — `PlaceholderPage(title)`：`AppPage` 包裹 + 大标题 + `AppSectionTitle('占位页面 · 后续轮次实现')`。
- `snapp/lib/app/router.dart` — `buildRoutes()`：17 条命名路由（对照原型 `pages.json`），tab 页与非 tab 页均落入 `PlaceholderPage`；tab 真实切换由 `_Shell` 管理。
- `snapp/lib/app/app.dart` — `Root({notifier})`：`ChangeNotifierProvider` + `Consumer`，`appColorsFor(n.schemeKey, n.ui.key)`（真实签名，无 BuildContext）→ `buildAppTheme(colors)` + `MaterialApp(title:'声栖')` + `home:_Shell`。`_Shell` 用 `IndexedStack` 承载 4 占位页 + 底部 `AppTabBar`。

### 重写
- `snapp/lib/main.dart`（原 demo）→ 替换为 `ensureInitialized + ThemeNotifier + loadFrom(ThemePrefs.read) + runApp(Root)`。
- `snapp/test/widget_test.dart`（原 demo counter smoke test）→ 重写为有效冒烟测试：pump `Root` 无异常、TabBar 四 tab 文案齐全、点击 tab 不抛异常。

## 三、与真实接口的修正（计划示例 vs 落地）

- `appColorsFor(String schemeKey, String ui)`：按真实签名，去掉 `BuildContext` 参数（Task 2 产出即两个 String 参数）。
- `ThemeNotifier`：无 `scheme` getter，落地用 `schemeKey` / `ui`（已按 Task 2 真实接口构造 `Root`）。
- `cardShadow/cardRadius`：统一从 `appShapes` 读取，`cardBg/cardBorder` 从 `appColors` 读取（单一读取路径，符合任务 concern）。
- 无 Dart 3 语法：UIStyle 扩展用 if/else；tab 用 `_TabItem` 类；无 record/`switch` 表达式/`.firstOrNull`/`Color.r`。

## 四、验证

- `flutter analyze`：No issues found。
- `flutter test`：8 项全通过（theme_notifier 2 / app_icon 4 / widget_test 2）。
- 未跑 `flutter build apk --debug`（可选，本轮不强求）。

## 五、提交

`sco/fix` 分支单次提交，仅 add 本任务文件：
```
feat(snapp): app shell, named routes, floating tab bar, shared widgets
```