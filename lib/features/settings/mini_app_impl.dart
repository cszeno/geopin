import 'package:flutter/material.dart';
import 'package:geopin/core/utils/app_logger.dart';
import 'package:geopin/features/location/presentation/pages/location_page.dart';
import 'package:geopin/features/mark_point/presentation/pages/mark_point_collect_page.dart';
import 'package:geopin/features/settings/presentation/pages/settings_page.dart';
import 'package:geopin/shared/mini_app/domain/models/abstract_mini_app.dart';
import 'package:go_router/go_router.dart';
import '../../shared/mini_app/domain/models/mini_app_model.dart';

/// 标记线MiniApp实现
class SettingsMiniApp extends AbstractMiniApp {
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

  /// 处理点击事件
  @override
  void handleTap(BuildContext context) {
    context.push(config.route);
    AppLogger.debug("点击了miniapp，路由为：${config.route}");
  }

  @override
  Widget buildPage(BuildContext context) {
    return SettingsPage();
  }
} 