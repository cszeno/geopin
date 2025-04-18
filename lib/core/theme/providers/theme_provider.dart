import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 主题提供者，用于管理应用的主题模式
/// 允许切换明暗主题
class ThemeProvider extends ChangeNotifier {
  // SharedPreferences键
  static const String _themePrefsKey = 'theme_mode';
  
  // 当前主题模式
  ThemeMode _themeMode = ThemeMode.system;
  
  /// 获取当前主题模式
  ThemeMode get themeMode => _themeMode;
  
  /// 构造函数
  ThemeProvider() {
    _loadThemeMode();
  }
  
  /// 从SharedPreferences加载主题模式
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeStr = prefs.getString(_themePrefsKey);
      
      if (themeStr != null) {
        setThemeMode(ThemeMode.values.firstWhere(
          (e) => e.toString() == themeStr,
          orElse: () => ThemeMode.system,
        ));
      }
    } catch (e) {
      // 如果加载失败则使用系统默认主题
      setThemeMode(ThemeMode.system);
    }
  }
  
  /// 设置主题模式并通知监听者
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themePrefsKey, mode.toString());
    } catch (e) {
      // 保存失败时不处理，只是保存不成功而已
    }
  }
  
  /// 切换至暗色主题
  Future<void> setDarkMode() => setThemeMode(ThemeMode.dark);
  
  /// 切换至亮色主题
  Future<void> setLightMode() => setThemeMode(ThemeMode.light);
  
  /// 使用系统主题
  Future<void> setSystemMode() => setThemeMode(ThemeMode.system);
  
  /// 切换主题模式
  /// 如果当前是暗色主题，则切换至亮色主题
  /// 如果当前是亮色主题，则切换至暗色主题
  /// 如果当前是系统主题，则会根据当前系统主题切换为相反的主题
  Future<void> toggleThemeMode(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (_themeMode == ThemeMode.system) {
      await setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
    } else {
      await setThemeMode(_themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
    }
  }
} 