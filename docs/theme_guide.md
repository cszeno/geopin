# GeoPIN 主题系统指南

## 概述

GeoPIN应用采用了一套精心设计的主题系统，实现了以下目标：

- 提供统一的颜色管理方案
- 支持亮色和暗色主题无缝切换
- 提供多种方便的方式访问主题颜色
- 自动保存用户的主题偏好
- 易于扩展和自定义

## 主题色系

我们的主题色系包含以下主要色彩：

| 颜色类型 | 颜色名称 | 亮色模式值 | 暗色模式值 | 用途 |
|---------|---------|-----------|-----------|-----|
| 主色调 | primary | #2563EB | #3B82F6 | 主要按钮、强调项 |
| 次要色调 | secondary | #10B981 | #10B981 | 成功状态、辅助操作 |
| 第三色调 | tertiary | #EF4444 | #EF4444 | 警告、错误状态 |
| 背景色 | background | #F8FAFC | #0F172A | 页面背景 |
| 表面色 | surface | #FFFFFF | #1E293B | 卡片、对话框背景 |
| 主文本色 | textPrimary | #0F172A | #F8FAFC | 主要文本 |
| 次文本色 | textSecondary | #64748B | #CBD5E1 | 辅助文本、说明文字 |

此外，每种主色调都提供了从50到900的9个不同深浅的色调变体。

## 文件结构

主题系统由以下几个主要文件组成：

```
lib/
├── core/
│   ├── constants/
│   │   └── app_colors.dart     // 颜色常量定义
│   └── theme/
│       ├── app_theme.dart      // 主题定义（亮色和暗色）
│       ├── theme_extension.dart // BuildContext扩展
│       ├── theme_utils.dart    // 主题工具类
│       ├── widgets/
│       │   └── theme_switcher.dart // 主题切换组件
│       └── providers/
│           └── theme_provider.dart // 主题状态管理
```

## 使用方法

### 使用Context扩展获取颜色（推荐）

这是在Widget中最简洁的使用方式：

```dart
import 'package:geopin/core/theme/theme_extension.dart';

// 访问主色
Text(
  '标题文本',
  style: TextStyle(
    color: context.primaryColor,
    fontWeight: FontWeight.bold,
  ),
)

// 检查是否暗色模式
final isDark = context.isDarkMode;

// 根据主题自动选择颜色
final containerColor = context.themeAwareColor(
  light: Colors.white,
  dark: Colors.black54,
);
```

### 使用AppColors常量

当你需要静态颜色值时使用：

```dart
import 'package:geopin/core/constants/app_colors.dart';

// 固定使用主蓝色
Container(
  color: AppColors.primary,
  child: Icon(Icons.check),
)

// 使用不同深浅的主色调
final buttonColor = AppColors.primarySwatch[700];
final lightBgColor = AppColors.primarySwatch[50];
```

### 在设置页面添加主题切换

```dart
import 'package:geopin/core/theme/widgets/theme_switcher.dart';

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('设置')),
    body: ListView(
      children: [
        ThemeSwitcher(), // 添加主题切换开关
        // 其他设置项...
      ],
    ),
  );
}

// 或者显示主题选择对话框
ElevatedButton(
  child: Text('选择主题'),
  onPressed: () => showThemeModeSelector(context),
)
```

### 以编程方式切换主题

```dart
// 获取ThemeProvider实例
final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

// 切换到暗色主题
themeProvider.setDarkMode();

// 切换到亮色主题
themeProvider.setLightMode();

// 使用系统主题设置
themeProvider.setSystemMode();

// 在当前主题和相反主题之间切换
themeProvider.toggleThemeMode(context);
```

## 扩展主题系统

### 添加新的颜色

如需添加新的颜色，请修改`app_colors.dart`文件：

```dart
// 在AppColors类中添加新颜色
static const Color newColor = Color(0xFF6D28D9); // 紫色

// 如果需要不同深浅的色调，添加新的色调Map
static const Map<int, Color> newColorSwatch = {
  50: Color(0xFFF5F3FF),
  ...
  900: Color(0xFF4C1D95),
};

// 添加获取方法
static Color getNewColor(int shade) {
  return newColorSwatch[shade] ?? newColor;
}
```

### 在BuildContext扩展中添加新颜色

修改`theme_extension.dart`文件：

```dart
// 添加新的getter
Color get newColor => AppColors.newColor;

// 添加获取不同色调的方法
Color newColorShade(int shade) => AppColors.getNewColor(shade);
```

## 最佳实践

1. **避免硬编码颜色值** - 始终使用主题系统提供的颜色
2. **注意亮暗适配** - 确保您的UI在亮色和暗色主题下都有良好的可读性
3. **保持一致性** - 在整个应用中保持颜色使用的一致性
4. **使用色调变化** - 需要同一颜色的不同深浅时，使用色调系统
5. **优先使用Context扩展** - 在Widget中优先使用`context.primaryColor`这样的扩展方法获取颜色

## 实际应用示例

### 一个具有主题响应的按钮组件

```dart
import 'package:flutter/material.dart';
import 'package:geopin/core/theme/theme_extension.dart';

class ThemedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  
  const ThemedButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary 
            ? context.primaryColor 
            : context.secondaryColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(text),
    );
  }
}
```

### 使用示例

```dart
// 页面示例
Scaffold(
  appBar: AppBar(
    title: Text('主页'),
    backgroundColor: context.surfaceColor,
    foregroundColor: context.textColor,
  ),
  body: Container(
    color: context.backgroundColor,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '欢迎使用GeoPIN',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: context.primaryColor,
            ),
          ),
          SizedBox(height: 16),
          Text(
            '这是一个使用主题系统的示例',
            style: TextStyle(
              color: context.secondaryTextColor,
            ),
          ),
          SizedBox(height: 32),
          ThemedButton(
            text: '主要按钮',
            onPressed: () {},
            isPrimary: true,
          ),
          SizedBox(height: 16),
          ThemedButton(
            text: '次要按钮',
            onPressed: () {},
            isPrimary: false,
          ),
        ],
      ),
    ),
  ),
  floatingActionButton: FloatingActionButton(
    backgroundColor: context.primaryColor,
    foregroundColor: Colors.white,
    onPressed: () {},
    child: Icon(Icons.add),
  ),
)
```

## 常见问题

**Q: 如何同时适配亮色和暗色模式？**

A: 使用`context.themeAwareColor()`方法或检查`context.isDarkMode`来选择适当的颜色。

**Q: 我应该使用哪种方式获取颜色？**

A: 在Widget中，优先使用BuildContext扩展(`context.primaryColor`)；在非Widget类中，使用ThemeUtils静态方法；对于不依赖主题的固定颜色，使用AppColors常量。

**Q: 如何获取不同深浅的颜色？**

A: 使用色调系统，例如`context.primaryShade(700)`获取更深的主色调，或`AppColors.primarySwatch[200]`获取更浅的主色调。 