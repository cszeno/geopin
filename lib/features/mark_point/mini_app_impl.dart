import 'package:flutter/material.dart';
import 'package:geopin/core/utils/app_logger.dart';
import 'package:geopin/features/mark_point/presentation/pages/mark_point_collect_page.dart';
import 'package:geopin/shared/mini_app/domain/models/abstract_mini_app.dart';
import 'package:go_router/go_router.dart';
import '../../shared/mini_app/domain/models/mini_app_model.dart';

/// 标记线MiniApp实现
class MarkPointMiniApp extends AbstractMiniApp {
  /// 单例实例
  static final MarkPointMiniApp _instance = MarkPointMiniApp._();

  /// 获取单例实例
  static MarkPointMiniApp get instance => _instance;

  /// 私有构造函数
  MarkPointMiniApp._();

  /// MiniApp配置
  @override
  MiniAppModel get config =>
      const MiniAppModel(
          id: 'mark_point',
          name: '标记点',
          icon: Icons.pin_drop,
          color: Color(0xFF007AFF),
          backgroundColor: Color(0xFF007AFF),
          route: '/mark_point',
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
    return MarkPointCollectPage();
  }
} 