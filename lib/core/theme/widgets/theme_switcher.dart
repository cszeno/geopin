import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geopin/core/theme/providers/theme_provider.dart';
import 'package:geopin/core/constants/app_colors.dart';

/// 主题切换组件
/// 可以放在设置页面或其他需要切换主题的地方
class ThemeSwitcher extends StatelessWidget {
  /// 构造函数
  const ThemeSwitcher({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return ListTile(
      leading: Icon(
        isDarkMode ? Icons.dark_mode : Icons.light_mode,
        color: isDarkMode ? AppColors.primarySwatch[300] : AppColors.primarySwatch[700],
      ),
      title: Text(
        isDarkMode ? '暗色主题' : '亮色主题',
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        themeProvider.themeMode == ThemeMode.system 
            ? '跟随系统' 
            : (isDarkMode ? '手动设置为暗色' : '手动设置为亮色'),
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Switch(
        value: isDarkMode,
        activeColor: AppColors.primary,
        onChanged: (_) => themeProvider.toggleThemeMode(context),
      ),
      onTap: () => themeProvider.toggleThemeMode(context),
    );
  }
}

/// 主题模式选择器
/// 允许用户选择亮色、暗色或跟随系统的主题模式
class ThemeModeSelector extends StatelessWidget {
  /// 构造函数
  const ThemeModeSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentMode = themeProvider.themeMode;
    
    return AlertDialog(
      title: const Text('选择主题模式'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModeOption(
            context, 
            ThemeMode.light, 
            currentMode, 
            Icons.light_mode, 
            '亮色主题',
            themeProvider,
          ),
          const SizedBox(height: 8),
          _buildModeOption(
            context, 
            ThemeMode.dark, 
            currentMode, 
            Icons.dark_mode, 
            '暗色主题',
            themeProvider,
          ),
          const SizedBox(height: 8),
          _buildModeOption(
            context, 
            ThemeMode.system, 
            currentMode, 
            Icons.settings_suggest, 
            '跟随系统',
            themeProvider,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
      ],
    );
  }
  
  /// 构建每个主题模式的选项
  Widget _buildModeOption(
    BuildContext context, 
    ThemeMode mode, 
    ThemeMode currentMode, 
    IconData icon, 
    String label,
    ThemeProvider provider,
  ) {
    final isSelected = mode == currentMode;
    
    return InkWell(
      onTap: () {
        provider.setThemeMode(mode);
        Navigator.of(context).pop();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected 
              ? Theme.of(context).colorScheme.primaryContainer 
              : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}

/// 显示主题选择对话框
void showThemeModeSelector(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const ThemeModeSelector(),
  );
}