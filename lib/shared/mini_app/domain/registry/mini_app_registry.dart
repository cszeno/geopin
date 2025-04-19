import 'package:flutter/material.dart';
import '../models/mini_app_model.dart';

/// 小程序相关事件
enum MiniAppEvent {
  /// 点击标记点小程序事件
  tapPointMarker,

  /// 点击标记线小程序事件
  tapLineMarker,

  /// 点击任意小程序事件
  tapAnyMiniApp,
}

/// 小程序注册表
///
/// 管理应用中所有可用的小程序
class MiniAppRegister {
  /// 私有构造函数，防止实例化
  MiniAppRegister._();

  /// 存储所有注册的应用
  static final List<MiniAppModel> _registeredApps = [];

  /// 声明应用
  static const MiniAppModel markPoint = MiniAppModel(
    id: 'mark_point',
    name: '标记点',
    icon: Icons.location_searching,
    color: Color(0xFF007AFF),
    backgroundColor: Color(0xFF007AFF),
    route: '/mark_point',
    priority: 15,
    type: MiniAppType.eventBus,
    eventName: MiniAppEvent.tapPointMarker,
  );

  static const MiniAppModel markLine = MiniAppModel(
    id: 'mark_line',
    name: '标记线',
    icon: Icons.linear_scale,
    color: Color(0xFF007AFF),
    backgroundColor: Color(0xFF007AFF),
    route: '/mark_line',
    priority: 15, // 设置较高优先级使其显示在前面
    type: MiniAppType.eventBus,
    eventName: MiniAppEvent.tapLineMarker,
  );

  static const MiniAppModel locationTest = MiniAppModel(
    id: "location_test",
    name: '位置数据',
    icon: Icons.info_outline_rounded,
    color: Color(0xFF007AFF),
    backgroundColor: Color(0xFF007AFF),
    route: '/location_test',
    priority: 15, // 设置较高优先级使其显示在前面
  );

  static const MiniAppModel settings = MiniAppModel(
    id: 'setting',
    name: '设置',
    icon: Icons.settings,
    color: Color(0xFF007AFF),
    backgroundColor: Color(0xFF007AFF),
    route: '/settings',
    priority: 20,
  );

  static const MiniAppModel log = MiniAppModel(
    id: 'log',
    name: '日志',
    icon: Icons.text_snippet_outlined,
    color: Color(0xFF007AFF),
    backgroundColor: Color(0xFF007AFF),
    route: '/log',
    priority: 20,
  );

  static void register() {
    registerApp(markPoint);
    registerApp(markLine);
    registerApp(locationTest);
    registerApp(log);
    registerApp(settings);
  }

  /// 注册一个小程序
  static void registerApp(MiniAppModel app) {
    if (!_registeredApps.any((existingApp) => existingApp.id == app.id)) {
      _registeredApps.add(app);
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

  /// 取消注册小程序
  static void unregister(String appId) {
    _registeredApps.removeWhere((app) => app.id == appId);
  }
} 