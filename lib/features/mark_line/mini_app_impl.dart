import 'package:flutter/material.dart';
import 'package:geopin/features/mark_line/presentation/pages/mark_line_collect_page.dart';
import 'package:geopin/shared/mini_app/domain/models/abstract_mini_app.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/app_logger.dart';
import '../../shared/mini_app/domain/models/mini_app_model.dart';

/// 标记线MiniApp实现
class MarkLineMiniApp extends AbstractMiniApp {
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
    enableTransitionPage: false
  );
  
  /// 处理点击事件
  @override
  void handleTap(BuildContext context) {
    context.go(config.route);
    AppLogger.debug("点击了miniapp，路由为：${config.route}");
  }

  @override
  Widget buildPage(BuildContext context) {
    return MarkLineCollectPage();
  }
} 