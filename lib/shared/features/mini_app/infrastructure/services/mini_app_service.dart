import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/models/mini_app_model.dart';
import '../../domain/registry/mini_app_registry.dart';
import 'package:flutter/material.dart';

/// 小程序服务类
///
/// 管理小程序的持久化存储、排序和状态
class MiniAppService {
  /// 小程序排序键名
  static const String _miniAppOrderKey = 'mini_app_order';
  
  /// 小程序状态键名
  static const String _miniAppStatusKey = 'mini_app_status';
  
  /// 从本地存储加载所有小程序
  Future<List<MiniAppModel>> loadMiniApps() async {
    // 获取预设小程序列表
    final presetApps = MiniAppRegistry.getPresetApps();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 加载自定义排序
      final orderJson = prefs.getString(_miniAppOrderKey);
      final statusJson = prefs.getString(_miniAppStatusKey);
      
      // 如果没有存储的排序和状态，返回预设小程序
      if (orderJson == null && statusJson == null) {
        return presetApps;
      }
      
      // 处理排序
      Map<String, int> appOrder = {};
      if (orderJson != null) {
        final orderMap = json.decode(orderJson) as Map<String, dynamic>;
        appOrder = orderMap.map((key, value) => MapEntry(key, value as int));
      }
      
      // 处理状态
      Map<String, bool> appStatus = {};
      if (statusJson != null) {
        final statusMap = json.decode(statusJson) as Map<String, dynamic>;
        appStatus = statusMap.map((key, value) => MapEntry(key, value as bool));
      }
      
      // 应用自定义排序和状态到预设应用
      final customizedApps = presetApps.map((app) {
        // 应用自定义优先级（如果存在）
        final priority = appOrder[app.id] ?? app.priority;
        
        // 应用自定义启用状态（如果存在）
        final isEnabled = appStatus[app.id] ?? app.isEnabled;
        
        // 返回更新后的小程序
        return app.copyWith(
          priority: priority,
          isEnabled: isEnabled,
        );
      }).toList();
      
      return customizedApps;
    } catch (e) {
      // 如果加载失败，返回预设小程序
      debugPrint('加载小程序失败: $e');
      return presetApps;
    }
  }
  
  /// 保存小程序排序
  Future<bool> saveMiniAppOrder(Map<String, int> order) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final orderJson = json.encode(order);
      return await prefs.setString(_miniAppOrderKey, orderJson);
    } catch (e) {
      debugPrint('保存小程序排序失败: $e');
      return false;
    }
  }
  
  /// 保存小程序状态
  Future<bool> saveMiniAppStatus(Map<String, bool> status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statusJson = json.encode(status);
      return await prefs.setString(_miniAppStatusKey, statusJson);
    } catch (e) {
      debugPrint('保存小程序状态失败: $e');
      return false;
    }
  }
} 