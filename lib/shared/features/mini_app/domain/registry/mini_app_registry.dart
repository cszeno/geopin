import 'package:flutter/material.dart';
import '../models/mini_app_model.dart';

/// 小程序注册表
///
/// 管理应用中所有可用的小程序
class MiniAppRegistry {
  /// 私有构造函数，防止实例化
  MiniAppRegistry._();

  /// 存储所有注册的应用
  static final List<MiniAppModel> _registeredApps = [];

  /// 注册一个小程序
  static void register(MiniAppModel app) {
    if (!_registeredApps.any((existingApp) => existingApp.id == app.id)) {
      _registeredApps.add(app);
    }
  }

  /// 注册多个小程序
  static void registerAll(List<MiniAppModel> apps) {
    for (final app in apps) {
      register(app);
    }
  }

  /// 获取所有小程序列表
  static List<MiniAppModel> getAllApps() {
    return List.unmodifiable(_registeredApps);
  }
  
  /// 根据ID获取小程序
  static MiniAppModel? getAppById(String id) {
    final allApps = getAllApps();
    try {
      return allApps.firstWhere((app) => app.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// 根据类别获取小程序列表
  static List<MiniAppModel> getAppsByCategory(String category) {
    final allApps = getAllApps();
    return allApps
        .where((app) => app.isEnabled)
        .toList()
        ..sort((a, b) => a.priority.compareTo(b.priority));
  }

  /// 取消注册小程序
  static void unregister(String appId) {
    _registeredApps.removeWhere((app) => app.id == appId);
  }
} 