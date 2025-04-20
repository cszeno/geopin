import 'package:flutter/material.dart';

/// 偏好设置仓库接口
///
/// 定义应用偏好设置的存取方法
abstract class PreferencesRepository {
  /// 保存用户选择的颜色
  Future<bool> saveSelectedColor(Color color);
  
  /// 获取用户保存的颜色
  Future<Color?> getSavedColor();
  
  /// 保存属性历史记录
  Future<bool> saveAttributeHistory(List<Map<String, String>> attributes);
  
  /// 获取属性历史记录
  Future<List<Map<String, String>>> getAttributeHistory();
  
  /// 添加新的属性到历史记录
  Future<bool> addAttributeToHistory(String key, String value);
} 