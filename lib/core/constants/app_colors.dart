import 'package:flutter/material.dart';

/// 应用颜色常量
/// 提供了轻松访问应用颜色的方式
class AppColors {
  // 私有构造函数防止实例化
  AppColors._();
  
  // 主要颜色
  static const Color primary = Color(0xFF2563EB);        // 主色调 - 蓝色
  static const Color secondary = Color(0xFF10B981);      // 次要色调 - 绿色
  static const Color tertiary = Color(0xFFEF4444);       // 第三色调 - 红色
  
  // 中性色
  static const Color background = Color(0xFFF8FAFC);     // 背景色
  static const Color surface = Color(0xFFFFFFFF);        // 表面色
  static const Color surfaceVariant = Color(0xFFF1F5F9); // 变种表面色
  
  // 文本颜色
  static const Color textPrimary = Color(0xFF0F172A);    // 主要文本
  static const Color textSecondary = Color(0xFF64748B);  // 次要文本
  static const Color textDisabled = Color(0xFFA1A1AA);   // 禁用文本
  
  // 状态颜色
  static const Color success = Color(0xFF22C55E);        // 成功
  static const Color warning = Color(0xFFF59E0B);        // 警告
  static const Color error = Color(0xFFEF4444);          // 错误
  static const Color info = Color(0xFF3B82F6);           // 信息
  
  // 深色模式颜色
  static const Color darkBackground = Color(0xFF0F172A); // 深色背景
  static const Color darkSurface = Color(0xFF1E293B);    // 深色表面
  static const Color darkSurfaceVariant = Color(0xFF334155); // 深色变种表面
  static const Color darkTextPrimary = Color(0xFFF8FAFC); // 深色主要文本
  static const Color darkTextSecondary = Color(0xFFCBD5E1); // 深色次要文本
  
  // 特殊颜色
  static const Color overlay = Color(0x80000000);        // 覆盖层
  static const Color divider = Color(0xFFE2E8F0);        // 分隔线
  static const Color darkDivider = Color(0xFF334155);    // 深色分隔线
  
  // 各种主题色的不同色调
  static const Map<int, Color> primarySwatch = {
    50: Color(0xFFEFF6FF),
    100: Color(0xFFDBEAFE),
    200: Color(0xFFBFDBFE),
    300: Color(0xFF93C5FD),
    400: Color(0xFF60A5FA),
    500: Color(0xFF3B82F6),
    600: Color(0xFF2563EB),
    700: Color(0xFF1D4ED8),
    800: Color(0xFF1E40AF),
    900: Color(0xFF1E3A8A),
  };
  
  static const Map<int, Color> secondarySwatch = {
    50: Color(0xFFECFDF5),
    100: Color(0xFFD1FAE5),
    200: Color(0xFFA7F3D0),
    300: Color(0xFF6EE7B7),
    400: Color(0xFF34D399),
    500: Color(0xFF10B981),
    600: Color(0xFF059669),
    700: Color(0xFF047857),
    800: Color(0xFF065F46),
    900: Color(0xFF064E3B),
  };
  
  static const Map<int, Color> tertiarySwatch = {
    50: Color(0xFFFEF2F2),
    100: Color(0xFFFEE2E2),
    200: Color(0xFFFECACA),
    300: Color(0xFFFCA5A5),
    400: Color(0xFFF87171),
    500: Color(0xFFEF4444),
    600: Color(0xFFDC2626),
    700: Color(0xFFB91C1C),
    800: Color(0xFF991B1B),
    900: Color(0xFF7F1D1D),
  };
  
  // 获取特定色调的颜色
  static Color getPrimaryColor(int shade) {
    return primarySwatch[shade] ?? primary;
  }
  
  static Color getSecondaryColor(int shade) {
    return secondarySwatch[shade] ?? secondary;
  }
  
  static Color getTertiaryColor(int shade) {
    return tertiarySwatch[shade] ?? tertiary;
  }
} 