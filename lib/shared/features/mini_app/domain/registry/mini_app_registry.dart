import 'package:flutter/material.dart';
import '../models/mini_app_model.dart';

/// 小程序注册表
///
/// 管理应用中所有可用的小程序
class MiniAppRegistry {
  /// 私有构造函数，防止实例化
  MiniAppRegistry._();
  
  /// 角度转换器小程序ID
  static const String angleConverterAppId = 'angle_converter';
  
  /// 进制转换器小程序ID
  static const String baseConverterAppId = 'base_converter';

  /// 标记点
  static const String pointMarker = 'mark_point';

  /// 线记点
  static const String lineMarker = 'mark_line';

  
  /// 获取所有预设小程序列表
  static List<MiniAppModel> getPresetApps() {
    return [
      
      // =============== 测量类应用 ===============
      // 添加点测量应用
      const MiniAppModel(
        id: pointMarker,
        name: '标记点',
        icon: Icons.location_searching,
        color: Color(0xFF007AFF),
        backgroundColor: Color(0xFF007AFF),
        route: '/',
        priority: 15, // 设置较高优先级使其显示在前面
      ),
      const MiniAppModel(
        id: lineMarker,
        name: '标记线',
        icon: Icons.linear_scale,
        color: Color(0xFF007AFF),
        backgroundColor: Color(0xFF007AFF),
        route: '/measurement/mark_line',
        priority: 15, // 设置较高优先级使其显示在前面
      ),
      const MiniAppModel(
        id: "location_test",
        name: '位置数据',
        icon: Icons.info_outline_rounded,
        color: Color(0xFF007AFF),
        backgroundColor: Color(0xFF007AFF),
        route: '/location_test',
        priority: 15, // 设置较高优先级使其显示在前面
      ),
      const MiniAppModel(
        id: 'setting',
        name: '设置',
        icon: Icons.settings,
        color: Color(0xFF007AFF),
        backgroundColor: Color(0xFF007AFF),
        route: '/settings',
        priority: 20,
      ),
      const MiniAppModel(
        id: 'log',
        name: '日志',
        icon: Icons.text_snippet_outlined,
        color: Color(0xFF007AFF),
        backgroundColor: Color(0xFF007AFF),
        route: '/log',
        priority: 20,
      ),
    ];
  }
  
  /// 根据ID获取小程序
  static MiniAppModel? getAppById(String id, List<MiniAppModel> allApps) {
    try {
      return allApps.firstWhere((app) => app.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// 根据类别获取小程序列表
  static List<MiniAppModel> getAppsByCategory(String category, List<MiniAppModel> allApps) {
    return allApps
        .where((app) => app.isEnabled)
        .toList()
        ..sort((a, b) => a.priority.compareTo(b.priority));
  }
} 