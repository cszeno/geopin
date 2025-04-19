import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/event/event_bus.dart';
import '../../shared/mini_app/domain/models/base_mini_app.dart';
import '../../shared/mini_app/domain/models/mini_app_model.dart';
import '../../shared/mini_app/domain/registry/mini_app_registry.dart';
import 'presentation/pages/line_marker_collect_page.dart';
import 'presentation/pages/line_marker_data_page.dart';

/// 标记线MiniApp实现
class MarkLineMiniApp extends BaseMiniApp {
  /// 单例实例
  static final MarkLineMiniApp _instance = MarkLineMiniApp._();
  
  /// 获取单例实例
  static MarkLineMiniApp get instance => _instance;
  
  /// 私有构造函数
  MarkLineMiniApp._();
  
  /// MiniApp配置
  @override
  MiniAppModel get config => const MiniAppModel(
    id: 'mark_line',
    name: '标记线',
    icon: Icons.linear_scale,
    color: Color(0xFF007AFF),
    backgroundColor: Color(0xFF007AFF),
    route: '/mark_line',
    priority: 15,
    type: MiniAppType.eventBus,
    eventName: MiniAppEvent.tapLineMarker,
  );
  
  /// 构建数据页面
  @override
  Widget buildDataPage(BuildContext context) {
    return const LineMarkerDataPage();
  }
  
  /// 构建采集页面
  @override
  Widget buildCollectPage(BuildContext context) {
    return const LineMarkerCollectPage();
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
      
      // 对于标记线，关闭底部弹窗是通过通用事件处理来完成的
    }
  }
} 