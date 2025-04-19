import 'package:flutter/material.dart';
import 'package:geopin/core/utils/sp_util.dart';

/// 应用本地化提供者
class LocaleProvider extends ChangeNotifier {
  /// 保存语言设置的键名
  static const String _localeKey = 'app_locale';
  
  /// 本地存储工具实例
  final _spUtil = SPUtil();
  
  /// 当前区域设置
  Locale? _locale;
  
  /// 获取当前区域设置
  Locale? get locale => _locale;
  
  /// 构造函数
  LocaleProvider() {
    _loadLocale();
  }
  
  /// 从本地存储加载语言设置
  Future<void> _loadLocale() async {
    // 确保初始化存储服务
    if (!_spUtil.isInitialized) {
      await _spUtil.init();
    }
    
    final String? languageCode = _spUtil.getString(_localeKey);
    
    // 如果没有保存过语言设置，则返回null（使用系统默认语言）
    if (languageCode == null) {
      _locale = null;
      notifyListeners();
      return;
    }
    
    // 设置为保存的语言
    _locale = Locale(languageCode);
    notifyListeners();
  }
  
  /// 设置应用语言
  /// [languageCode] 语言代码，如zh、en。如果为null，则使用系统默认语言
  Future<void> setLocale(String? languageCode) async {
    // 确保初始化存储服务
    if (!_spUtil.isInitialized) {
      await _spUtil.init();
    }
    
    if (languageCode == null) {
      // 清除保存的语言设置，使用系统默认
      await _spUtil.remove(_localeKey);
      _locale = null;
    } else {
      // 保存语言设置
      await _spUtil.setString(_localeKey, languageCode);
      _locale = Locale(languageCode);
    }
    
    notifyListeners();
  }
  
  /// 设置为中文
  Future<void> setChineseLocale() => setLocale('zh');
  
  /// 设置为英文
  Future<void> setEnglishLocale() => setLocale('en');
  
  /// 设置为系统默认语言
  Future<void> setSystemLocale() => setLocale(null);
} 