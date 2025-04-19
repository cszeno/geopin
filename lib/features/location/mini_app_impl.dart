import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/event/event_bus.dart';
import '../../shared/mini_app/domain/models/base_mini_app.dart';
import '../../shared/mini_app/domain/models/mini_app_model.dart';
import '../../shared/mini_app/domain/registry/mini_app_registry.dart';
import 'presentation/pages/location_page.dart';

/// 位置测试MiniApp实现
class LocationTestMiniApp extends BaseMiniApp {
  /// 单例实例
  static final LocationTestMiniApp _instance = LocationTestMiniApp._();
  
  /// 获取单例实例
  static LocationTestMiniApp get instance => _instance;
  
  /// 私有构造函数
  LocationTestMiniApp._();
  
  /// MiniApp配置
  @override
  MiniAppModel get config => const MiniAppModel(
    id: 'location_test',
    name: '位置数据',
    icon: Icons.info_outline_rounded,
    color: Color(0xFF007AFF),
    backgroundColor: Color(0xFF007AFF),
    route: '/location_test',
    priority: 15,
  );
  
  /// 构建数据页面
  @override
  Widget buildDataPage(BuildContext context) {
    return const LocationPage();
  }
  
  /// 处理点击事件
  @override
  void handleTap(BuildContext context) {
    // 先发出通用事件，传递当前MiniApp实例
    bus.emit(MiniAppEvent.tapAnyMiniApp, this);
    
    // 直接导航到位置测试页面
    context.push(config.route);
  }
} 