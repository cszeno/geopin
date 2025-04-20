import 'package:flutter/material.dart';
import 'package:geopin/core/utils/app_logger.dart';
import 'package:geopin/features/location/presentation/pages/location_page.dart';
import 'package:geopin/shared/mini_app/domain/models/abstract_mini_app.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/mini_app/domain/models/mini_app_model.dart';

/// 标记线MiniApp实现
class LocationTestApp extends AbstractMiniApp {
  /// 单例实例
  static final LocationTestApp _instance = LocationTestApp._();

  /// 获取单例实例
  static LocationTestApp get instance => _instance;

  /// 私有构造函数
  LocationTestApp._();

  /// MiniApp配置
  @override
  MiniAppModel get config => const MiniAppModel(
    id: "location_test",
    name: '位置数据',
    icon: Icons.info_outline_rounded,
    color: Color(0xFF007AFF),
    backgroundColor: Color(0xFF007AFF),
    route: '/location_test',
    priority: 15, // 设置较高优先级使其显示在前面
  );

  /// 处理点击事件
  @override
  void handleTap(BuildContext context) {
    context.push(config.route);
    AppLogger.debug("点击了miniapp，路由为：${config.route}");
  }

  @override
  Widget buildPage(BuildContext context) {
    return LocationPage();
  }
} 