import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geopin/core/utils/app_logger.dart';
import 'package:geopin/features/mark_point/domain/repositories/preferences_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 偏好设置仓库实现类
class PreferencesRepositoryImpl implements PreferencesRepository {
  /// 颜色键名
  static const String _colorKey = 'selected_color';
  
  /// 属性历史记录键名
  static const String _attributeHistoryKey = 'attribute_history';
  
  /// 最大历史记录数量
  static const int _maxHistoryItems = 10;

  @override
  Future<bool> saveSelectedColor(Color color) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setInt(_colorKey, color.value);
    } catch (e) {
      AppLogger.error('保存颜色失败: $e');
      return false;
    }
  }

  @override
  Future<Color?> getSavedColor() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final colorValue = prefs.getInt(_colorKey);
      return colorValue != null ? Color(colorValue) : null;
    } catch (e) {
      AppLogger.error('获取保存的颜色失败: $e');
      return null;
    }
  }

  @override
  Future<bool> saveAttributeHistory(List<Map<String, String>> attributes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(attributes);
      AppLogger.debug('保存属性历史: $jsonString');
      return await prefs.setString(_attributeHistoryKey, jsonString);
    } catch (e) {
      AppLogger.error('保存属性历史失败: $e');
      return false;
    }
  }

  @override
  Future<List<Map<String, String>>> getAttributeHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_attributeHistoryKey);
      
      if (jsonString == null) {
        return [];
      }
      
      final List decodedList = jsonDecode(jsonString);
      return decodedList.map((item) {
        // 转换为Map<String, String>
        final map = Map<String, String>.from(item.map(
          (key, value) => MapEntry(key.toString(), value.toString())
        ));
        return map;
      }).toList();
    } catch (e) {
      AppLogger.error('获取属性历史失败: $e');
      return [];
    }
  }

  @override
  Future<bool> addAttributeToHistory(String key, String value) async {
    try {
      // 获取现有历史记录
      final attributes = await getAttributeHistory();
      
      // 创建新属性
      final newAttribute = {'key': key, 'value': value};
      
      // 如果已存在相同键值的属性，则移除它
      attributes.removeWhere((attr) => 
        attr['key'] == key && attr['value'] == value);
      
      // 将新属性添加到列表开头
      attributes.insert(0, newAttribute);
      
      // 如果超过最大数量，则移除最旧的
      if (attributes.length > _maxHistoryItems) {
        attributes.removeLast();
      }
      
      // 保存更新后的列表
      return await saveAttributeHistory(attributes);
    } catch (e) {
      AppLogger.error('添加属性到历史记录失败: $e');
      return false;
    }
  }
} 