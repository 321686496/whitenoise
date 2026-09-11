# 声栖 Flutter 工程地基 · 设计规格

> 日期：2026-09-11
> 范围：Flutter 工程（`snapp/`）「地基 + 图标体系」第一轮实现
> 权威参考：uni-app 原型 `prototype/src`（`theme/index.ts` / `App.vue` / `pages.json` / `data/scenes.ts` / `data/sounds.ts` / `components/Icon.vue` / `components/TabBar.vue`）

---

## 一、背景与目标

`snapp/`（Flutter）当前仅为默认 demo 骨架（`lib/main.dart`），需按 `prototype/` 设计基线迁移为三端（iOS / Android / HarmonyOS）真原生实现。

本轮为目标：搭起 **可运行的地基** —— 主题引擎（6 配色 × 3 UI 风格）、App 外壳与命名路由、悬浮 TabBar、SVG 图标体系、数据层模型与静态数据、公共样式原语，并以一个 Home 骨架页验证主题切换即时生效。

**约束**（来自 AGENTS.md 与用户偏好）：
- 工程锁定 Flutter `3.7.12-ohos-1.1.3` / `sdk >=2.19.6 <3.0.0`（Dart <3.0）。
- 引入三方库前必须过 Harmony 适配清单；本次 `provider`(纯Dart)、`shared_preferences@2.2.2`(已适配)、`flutter_svg`(纯Dart) 均合规。
- 样式永远跟随「设置里的 UI 风格 + 主题」，**禁止硬编码颜色/圆角/阴影/间距**，禁止 UI 风格混搭。
- 所有图标用 URL 化 SVG，禁止 emoji。

---

## 二、工程结构与目录

```
snapp/lib/
├── main.dart                 # 入口：异步初始化主题持久化 → runApp
├── app/
│   ├── app.dart              # 根 Provider + MaterialApp（含主题切换监听）
│   ├── router.dart           # 命名路由表（对照 pages.json）
│   └── theme_prefs.dart      # 主题持久化读写（shared_preferences）
├── theme/
│   ├── app_theme.dart        # 6配色×3UI token + 构建 ThemeData + ThemeExtension
│   ├── theme_notifier.dart   # ChangeNotifier：scheme + ui
│   ├── theme_extension.dart  # AppColors / AppShapes（ThemeExtension）
│   └── theme_tokens.dart     # 6×3 token 数据（迁移 theme/index.ts）
├── widgets/
│   ├── app_icon.dart         # AppIcon({name,size,color,stroke}) SVG 组件
│   ├── app_svg_icons.dart    # 37 图标 SVG body 定义 + 未知回退圆点
│   ├── app_card.dart         # 卡片容器（对应 .app-card）
│   ├── app_buttons.dart      # .btn-primary / .btn-outline
│   ├── app_section.dart      # .section-title / .divider / .safe-bottom / .page-title
│   ├── app_page.dart         # .page-bg + .page-container 骨架 + iOS 进入动效
│   └── tab_bar.dart          # 自定义悬浮 TabBar
├── data/
│   ├── scene_models.dart     # Scene / SceneCategory / RecipeItem / PresetOption
│   ├── sound_models.dart     # Sound / FeaturedScene / FeaturedSound
│   └── seed_data.dart        # homeScenes / sounds / featuredScenes / featuredSounds / 分类
├── services/
│   └── scene_service.dart    # findScene/getRecommended/getCategoryScenes/soundNames/buildRecipe/buildPresets
└── pages/
    ├── index/index_page.dart # Home 骨架（品牌头 + 卡片 + 图标预览网格 + 主题切换入口）
    └── placeholder.dart      # scene / discover / mine 及二级页占位（可切换主题）
```

---

## 三、主题引擎（核心）

### 3.1 token 来源

逐条迁移 `prototype/src/theme/index.ts`：

- 配色 `SchemeKey`: `morandi / ocean / forest / sunset / lavender / mono`，各自 `SchemeMeta`（label/desc/swatch）与 `SchemeTokens`（primary/primarySoft/primaryDark/onPrimary/accent/bg/bgGrad/cardBorder/text/text2/text3/divider/subtle/danger/glassCard/glassBorder/neuTint/neuA/neuB）。
- UI 风格 `UiMode`: `flat / glass / neu`，影响卡片容器（cardBg/cardBorder/cardShadow/cardBlur）、input、pressBg。其中 neu 为「凸起」双阴影（左上亮 + 右下深），glass 为半透明 + 毛玻璃，flat 不透明实底 + 发丝描边。
- `buildTokens(scheme, ui)` 生成完整 CSS 变量表 → 映射为 Dart 的 `AppColors`/`AppShapes` 运行时值。

### 3.2 实现方式

- `ThemeNotifier extends ChangeNotifier` 持 `scheme` + `ui`；`setTheme(scheme, ui)` 更新并持久化（key `shengqi-theme`）；启动从 `theme_prefs` 读取，默认 `morandi + flat`。
- `AppTheme` 构建 `ThemeData`（`colorScheme`、`scaffoldBackgroundColor=bg`、`textTheme`、`appBarTheme` 透明）并挂自定义 `ThemeExtension`：
  - `AppColors`（所有配色 token 字段）
  - `AppShapes`（cardBg/cardBorder/cardShadow/cardBlur/btnRadius 等）
- 业务代码一律 `Theme.of(context).appColors / .appShapes`（provider 传给 `ThemeData`），**零硬编码颜色/阴影/圆角**。

### 3.3 新拟态浮雕铁律（落地 4.2）

- 凸起：组件表面色 == 画布背景 `neuTint`，左上浅色高光阴影 + 右下深色阴影；无描边。
- 凹陷（按下/选中）：方向反转（左上深色 + 右下浅色）；按钮按下态与选中态均为内凹。
- 叠在图片上的浮层：neu 降级为玻璃/实底取向（见 4.3 速查）。

---

## 四、图标体系

- `AppIcon`：`AppIcon({required String name, double size = 24, Color? color, double stroke = 2.0})`，内部用 `SvgPicture.string`。
- `app_svg_icons.dart` 存 37 个图标 body（自 `Icon.vue`）：`wave / white-noise / pink-noise / brown-noise / red-noise / rain / wave-ocean / forest / stream / fire / coffee / train / fan / play / pause / timer / save / palette / trophy / settings / share / user / edit / mute / volume / close / chevron-right / gift / moon / flame / mixer / clock / copy / lock / check / mountain / bird`。
- 构建时注入 `color` 与 `stroke`；图标内 `currentColor`（填充元素：play/pause/train 轮/wheel、palette 圆点、bird 眼睛等）同步替换为注入色。
- 未知 `name` → 默认圆点回退。

---

## 五、App 外壳 与 路由

- `main.dart`：`WidgetsFlutterBinding.ensureInitialized()` → 读主题 → `runApp(const App())`。
- `app.dart`：`ChangeNotifierProvider` 提供 `ThemeNotifier` → `MaterialApp`（onGenerateRoute 用 `router.dart`；builder 层订阅主题重建）。
- `router.dart`：命名路由，对照 `pages.json`：
  - Tab 页：`/index`、`/scene`、`/discover`、`/mine`。
  - 二级页：`/library`、`/theme`、`/achievement`、`/invite`、`/settings`、`/checkin`、`/stats`、`/favorites`、`/history`、`/onboarding`、`/scene-detail`、`/scene-edit`、`/scene-all`。
- `tab_bar.dart`：自定义悬浮 TabBar（图标取自定义 SVG，选中态主色）。

---

## 六、数据层

- `Scene`：`id/name/category/desc/iconName/gradient/image/soundIds/isPreset`；`SceneCategory=all|sleep|focus|relax|nature`。
- `Sound`、`FeaturedScene`、`FeaturedSound`（含 `hot`）与分类数组。
- `seed_data.dart`：迁移 `homeScenes`（11 项）、`sounds`（30 项）、`featuredScenes`（8 项）、`featuredSounds`（8 项）、`soundCategories`、`sceneCategories`。
- `SceneService`：复刻纯函数 —— `findScene`、`soundNames`、`getRecommended(prefs,recent,limit)`、`getCategoryScenes(category,limit)`、`buildRecipe`、`buildPresets`；`SIMULATED_PREFS=['sleep','nature']`。
- 数据层 `iconName` 与 `AppIcon` 图标名一一对应（引用 `app_svg_icons.dart` 常量校验）。

---

## 七、公共样式原语

- `AppPage`：`page-bg`（顶部柔和渐变 z-index 背景）+ `page-container`（安全区 padding、左右留白、底部 tab/playbar 预留）+ iOS 进入动效（轻上浮+淡入，尊重 `disableAnimations`）。
- `AppCard`：读主题 cardBg/cardBorder/cardShadow/cardBlur；glass 用 `BackdropFilter` 毛玻璃；neu 双阴影凸起。
- `AppButtons`：Primary（主色填充+按压缩放 0.97）/ Outline（主色描边）。
- `AppSection`：`section-title`（小号次级灰色标签）/ `page-title` / `divider` / `safe-bottom`。

---

## 八、依赖（Harmony 合规）

| 依赖 | 版本 | 依据 |
|---|---|---|
| provider | ^6.1.1 | 纯 Dart，兼容 Dart<3.0 |
| shared_preferences | ^2.2.2 | OpenHarmony 适配清单「已适配」 |
| flutter_svg | ^2.0.9 | 纯 Dart（依赖 dart:ui） |

> 工程 `sdk <3.0.0`，最终版本以 `flutter pub get` 实际解析为准；若个别版本与 Dart 2.19 冲突，选用低兼容版并记录到本文件。

---

## 九、验证与验收

- `flutter pub get` 成功。
- `flutter analyze` 无 error（本机为 Windows 标准 Flutter 工具链）。
- `dart format` 通过。
- Home 骨架可运行：品牌头（logo 图 + 声栖）+ 卡片 + 图标预览网格 + 悬浮 TabBar；内置配色/UI 风格切换器，验证即时生效。
- Harmony 真机构建需另配 OH SDK 环境，留待后续轮次。

---

## 十、里程碑（本轮交付）

M1 工程骨架与依赖解析
M2 主题引擎（token + ThemeNotifier + ThemeExtension + 持久化）
M3 图标体系（AppIcon + 36 图标）
M4 外壳/路由/TabBar/公共样式原语
M5 数据层（模型 + 静态数据 + SceneService）
M6 Home 骨架验证页 + analyze/format 通过