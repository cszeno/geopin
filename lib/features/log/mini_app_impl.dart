import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/event/event_bus.dart';
import '../../shared/mini_app/domain/models/base_mini_app.dart';
import '../../shared/mini_app/domain/models/mini_app_model.dart';
import '../../shared/mini_app/domain/registry/mini_app_registry.dart';
import 'presentation/pages/log_viewer_page.dart';

/// 日志MiniApp实现
class LogMiniApp extends BaseMiniApp {
  /// 单例实例
  static final LogMiniApp _instance = LogMiniApp._();
  
  /// 获取单例实例
  static LogMiniApp get instance => _instance;
  
  /// 私有构造函数
  LogMiniApp._();
  
  /// MiniApp配置
  @override
  MiniAppModel get config => const MiniAppModel(
    id: 'log',
    name: '日志',
    icon: Icons.text_snippet_outlined,
    color: Color(0xFF007AFF),
    backgroundColor: Color(0xFF007AFF),
    route: '/log',
    priority: 20,
  );
  
  /// 构建数据页面
  @override
  Widget buildDataPage(BuildContext context) {
    return const LogViewerPage();
  }
  
  /// 日志没有采集页面，使用基类默认实现返回null
  
  /// 处理点击事件
  @override
  void handleTap(BuildContext context) {
    // 先发出通用事件，传递当前MiniApp实例
    bus.emit(MiniAppEvent.tapAnyMiniApp, this);
    
    // 直接导航到日志页面
    context.push(config.route);
  }
} 