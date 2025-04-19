# GeoPIN 主题系统使用说明

GeoPIN应用的主题系统提供了一套完整的颜色和主题管理方案，让您能够轻松地在应用中使用一致的颜色体系，并支持明暗主题切换。

## 主题系统组件

主题系统由以下几个主要组件组成：

1. **颜色常量 (AppColors)**：定义了所有主题颜色常量
2. **主题定义 (AppTheme)**：定义了亮色和暗色主题
3. **主题工具类 (ThemeUtils)**：提供了静态方法获取主题颜色
4. **BuildContext扩展 (ThemeExtension)**：直接从BuildContext轻松获取颜色
5. **主题提供者 (ThemeProvider)**：管理主题切换并保存用户偏好
6. **主题切换组件 (ThemeSwitcher)**：用于UI中切换主题

## 颜色获取方式

在GeoPIN应用中，您可以通过以下几种方式获取主题颜色：

### 1. 使用颜色常量（静态色值）

直接使用`AppColors`类中定义的颜色常量：

```dart
import 'package:geopin/core/constants/app_colors.dart';

// 使用主色调
Container(
  color: AppColors.primary,
  child: Text('示例文本'),
)

// 使用特定深浅的主色调
Container(
  color: AppColors.primarySwatch[500],
  child: Text('示例文本'),
)
```

### 2. 使用BuildContext扩展（推荐）

这是在Widget中使用主题颜色的最简洁方式：

```dart
import 'package:geopin/core/theme/theme_extension.dart';

Container(
  color: context.primaryColor,
  child: Text(
    '示例文本',
    style: TextStyle(color: context.textColor),
  ),
)

// 根据当前主题模式自动选择亮色或暗色
Container(
  color: context.themeAwareColor(
    light: Colors.white,
    dark: Colors.black,
  ),
)
```

### 3. 使用主题工具类

当您需要在非Widget类中使用主题颜色时：

```dart
import 'package:geopin/core/theme/theme_utils.dart';

Color backgroundColor = ThemeUtils.getBackgroundColor(context);
Color primaryColor = ThemeUtils.getPrimaryColor(context);
Color primaryShade700 = ThemeUtils.getPrimaryShade(700);
```

### 4. 直接使用Theme（传统方式）

使用Flutter原生的Theme获取：

```dart
Container(
  color: Theme.of(context).colorScheme.primary,
  child: Text(
    '示例文本',
    style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
  ),
)
```

## 主题切换

### 添加主题切换器到界面

您可以使用我们提供的主题切换组件让用户自定义主题：

```dart
import 'package:geopin/core/theme/widgets/theme_switcher.dart';

// 在设置页面中添加一个简单的切换开关
ListTile(
  title: Text('主题设置'),
  onTap: () {
    showThemeModeSelector(context);
  },
)

// 或者直接使用预定义的切换组件
ThemeSwitcher(),
```

### 以编程方式切换主题

您也可以在代码中控制主题切换：

```dart
import 'package:provider/provider.dart';
import 'package:geopin/core/theme/providers/theme_provider.dart';

// 切换到暗色主题
Provider.of<ThemeProvider>(context, listen: false).setDarkMode();

// 切换到亮色主题
Provider.of<ThemeProvider>(context, listen: false).setLightMode();

// 跟随系统主题
Provider.of<ThemeProvider>(context, listen: false).setSystemMode();

// 在当前主题和相反主题之间切换
Provider.of<ThemeProvider>(context, listen: false).toggleThemeMode(context);
```

## 主题色系

我们的主题色系基于以下主要颜色：

- **主色调(primary)**: 蓝色 `#2563EB`
- **次要色调(secondary)**: 绿色 `#10B981`
- **第三色调(tertiary)**: 红色 `#EF4444`

每种主题色都提供了从50到900的不同深浅色调变体，例如：
- `AppColors.primarySwatch[50]` 到 `AppColors.primarySwatch[900]`
- `AppColors.secondarySwatch[50]` 到 `AppColors.secondarySwatch[900]`

此外，我们还提供了适用于不同UI元素的颜色：

- **背景色**: `AppColors.background` / `AppColors.darkBackground`
- **表面色**: `AppColors.surface` / `AppColors.darkSurface`
- **文本色**: `AppColors.textPrimary` / `AppColors.darkTextPrimary`
- **状态色**: `AppColors.success`, `AppColors.warning`, `AppColors.error`, `AppColors.info`

## 自定义主题

如果您需要调整应用的主题色系，可以修改`lib/core/constants/app_colors.dart`文件中的颜色定义。要调整其他主题属性（如字体、形状等），请修改`lib/core/theme/app_theme.dart`文件。

## 最佳实践

1. **一致性**：始终使用主题系统提供的颜色，避免硬编码颜色值
2. **BuildContext扩展**：在Widget中优先使用`context.primaryColor`这样的扩展方法
3. **亮暗适配**：总是考虑亮色和暗色主题，使用`themeAwareColor`方法或通过`isDarkMode`判断
4. **色调变化**：需要相同颜色的不同深浅时，使用色调系统如`primaryShade(600)`而不是自定义颜色

## 示例

### 一个卡片组件示例

```dart
import 'package:flutter/material.dart';
import 'package:geopin/core/theme/theme_extension.dart';

class CustomCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onTap;

  const CustomCard({
    Key? key,
    required this.title,
    required this.description,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      // 使用主题系统的卡片样式
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.primaryColor, // 使用主色
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  color: context.secondaryTextColor, // 使用次要文本色
                ),
              ),
              const SizedBox(height: 12),
              Divider(color: context.dividerColor), // 使用分隔线颜色
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: onTap,
                    child: Text('详情'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 设置页面中的主题切换

```dart
import 'package:flutter/material.dart';
import 'package:geopin/core/theme/widgets/theme_switcher.dart';
import 'package:geopin/core/theme/theme_extension.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置'),
      ),
      body: ListView(
        children: [
          // 添加主题切换开关
          ThemeSwitcher(),
          
          // 其他设置项
          Divider(color: context.dividerColor),
          ListTile(
            leading: Icon(Icons.language, color: context.primaryColor),
            title: Text('语言设置'),
          ),
        ],
      ),
    );
  }
} 