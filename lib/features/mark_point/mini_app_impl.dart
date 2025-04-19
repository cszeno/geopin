import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/event/event_bus.dart';
import '../../shared/mini_app/domain/models/base_mini_app.dart';
import '../../shared/mini_app/domain/models/mini_app_model.dart';
import '../../shared/mini_app/domain/registry/mini_app_registry.dart';
import 'presentation/pages/mark_point_page.dart';
import 'presentation/pages/point_marker_collect_page.dart';

/// 标记点MiniApp实现
class MarkPointMiniApp extends BaseMiniApp {
  /// 单例实例
  static final MarkPointMiniApp _instance = MarkPointMiniApp._();
  
  /// 获取单例实例
  static MarkPointMiniApp get instance => _instance;
  
  /// 私有构造函数
  MarkPointMiniApp._();
  
  /// MiniApp配置
  @override
  MiniAppModel get config => const MiniAppModel(
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
  
  /// 构建数据页面
  @override
  Widget buildDataPage(BuildContext context) {
    return const MarkPointPage();
  }
  
  /// 构建采集页面
  @override
  Widget buildCollectPage(BuildContext context) {
    return const PointMarkerCollectPage();
  }
  
  /// 处理点击事件
  @override
  void handleTap(BuildContext context) {
    // 先发出通用事件，传递当前MiniApp实例
    bus.emit(MiniAppEvent.tapAnyMiniApp, this);
    
    // 可以直接导航到页面
    if (config.type == MiniAppType.router) {
      context.push(config.route);
    } 
    // 或者发送事件
    else if (config.type == MiniAppType.eventBus && config.eventName != null) {
      bus.emit(config.eventName!, this);
      
      // 对于标记点，关闭底部弹窗是通过通用事件处理来完成的
    }
  }
} 