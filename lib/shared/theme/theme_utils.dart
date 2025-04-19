import 'package:flutter/material.dart';
import 'package:geopin/core/constants/app_colors.dart';

/// 主题工具类
/// 提供在应用中任何位置方便地访问颜色和主题属性的方法
class ThemeUtils {
  /// 获取当前主题的主要颜色
  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }
  
  /// 获取当前主题的次要颜色
  static Color getSecondaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }
  
  /// 获取当前主题的第三颜色
  static Color getTertiaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.tertiary;
  }
  
  /// 获取当前主题的背景颜色
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.background;
  }
  
  /// 获取当前主题的表面颜色
  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }
  
  /// 获取当前主题的文本颜色
  static Color getTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }
  
  /// 获取当前主题的次要文本颜色
  static Color getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }
  
  /// 获取错误颜色
  static Color getErrorColor(BuildContext context) {
    return Theme.of(context).colorScheme.error;
  }
  
  /// 根据当前主题返回适当的颜色
  /// 可用于根据当前主题选择亮色或暗色版本的颜色
  static Color getThemeAwareColor(BuildContext context, {
    required Color lightColor,
    required Color darkColor,
  }) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.light ? lightColor : darkColor;
  }
  
  /// 获取主色调的不同色调
  static Color getPrimaryShade(int shade) {
    return AppColors.getPrimaryColor(shade);
  }
  
  /// 获取次要色调的不同色调
  static Color getSecondaryShade(int shade) {
    return AppColors.getSecondaryColor(shade);
  }
  
  /// 获取第三色调的不同色调
  static Color getTertiaryShade(int shade) {
    return AppColors.getTertiaryColor(shade);
  }
  
  /// 根据亮度获取适当的分隔线颜色
  static Color getDividerColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.light 
        ? AppColors.divider 
        : AppColors.darkDivider;
  }
  
  /// 检查当前主题是否为暗色主题
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
  
  /// 创建一个带有透明度的颜色
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
} 