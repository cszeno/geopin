import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/event/event_bus.dart';
import '../../shared/mini_app/domain/models/base_mini_app.dart';
import '../../shared/mini_app/domain/models/mini_app_model.dart';
import '../../shared/mini_app/domain/registry/mini_app_registry.dart';
import 'presentation/pages/settings_page.dart';

/// 设置MiniApp实现
class SettingsMiniApp extends BaseMiniApp {
  /// 单例实例
  static final SettingsMiniApp _instance = SettingsMiniApp._();
  
  /// 获取单例实例
  static SettingsMiniApp get instance => _instance;
  
  /// 私有构造函数
  SettingsMiniApp._();
  
  /// MiniApp配置
  @override
  MiniAppModel get config => const MiniAppModel(
    id: 'setting',
    name: '设置',
    icon: Icons.settings,
    color: Color(0xFF007AFF),
    backgroundColor: Color(0xFF007AFF),
    route: '/settings',
    priority: 20,
  );
  
  /// 构建数据页面
  @override
  Widget buildDataPage(BuildContext context) {
    return const SettingsPage();
  }
  
  /// 处理点击事件
  @override
  void handleTap(BuildContext context) {
    // 先发出通用事件，传递当前MiniApp实例
    bus.emit(MiniAppEvent.tapAnyMiniApp, this);
    
    // 直接导航到设置页面
    context.push(config.route);
  }
} 