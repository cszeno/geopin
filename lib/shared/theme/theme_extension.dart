import 'package:flutter/material.dart';
import 'package:geopin/core/constants/app_colors.dart';

/// BuildContext的扩展
/// 提供了直接从BuildContext获取主题颜色的便捷方法
extension ThemeExtension on BuildContext {
  /// 获取当前主题
  ThemeData get theme => Theme.of(this);
  
  /// 获取当前主题的ColorScheme
  ColorScheme get colorScheme => theme.colorScheme;
  
  /// 当前是否是暗色主题
  bool get isDarkMode => theme.brightness == Brightness.dark;
  
  /// 获取主色调
  Color get primaryColor => colorScheme.primary;
  
  /// 获取次要色调
  Color get secondaryColor => colorScheme.secondary;
  
  /// 获取第三色调
  Color get tertiaryColor => colorScheme.tertiary;
  
  /// 获取背景色
  Color get backgroundColor => colorScheme.background;
  
  /// 获取表面色
  Color get surfaceColor => colorScheme.surface;
  
  /// 获取变种表面色
  Color get surfaceVariantColor => colorScheme.surfaceVariant;
  
  /// 获取主要文本色
  Color get textColor => colorScheme.onSurface;
  
  /// 获取次要文本色
  Color get secondaryTextColor => colorScheme.onSurfaceVariant;
  
  /// 获取错误色
  Color get errorColor => colorScheme.error;
  
  /// 获取分割线颜色
  Color get dividerColor => isDarkMode ? AppColors.darkDivider : AppColors.divider;
  
  /// 根据当前主题选择颜色
  Color themeAwareColor({required Color light, required Color dark}) {
    return isDarkMode ? dark : light;
  }
  
  /// 获取主色的特定色调
  Color primaryShade(int shade) => AppColors.getPrimaryColor(shade);
  
  /// 获取次要色的特定色调
  Color secondaryShade(int shade) => AppColors.getSecondaryColor(shade);
  
  /// 获取第三色的特定色调
  Color tertiaryShade(int shade) => AppColors.getTertiaryColor(shade);
} 