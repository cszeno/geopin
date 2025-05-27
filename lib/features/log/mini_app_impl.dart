import 'package:flutter/material.dart';
import 'package:geopin/core/utils/app_logger.dart';
import 'package:geopin/features/log/presentation/pages/log_viewer_page.dart';
import 'package:geopin/shared/mini_app/domain/models/abstract_mini_app.dart';
import 'package:go_router/go_router.dart';
import '../../shared/mini_app/domain/models/mini_app_model.dart';

/// 标记线MiniApp实现
class LogMiniApp extends AbstractMiniApp {
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
    icon: Icons.text_snippet,
    color: Color(0xFF007AFF),
    backgroundColor: Color(0xFF007AFF),
    route: '/log',
    priority: 15,
  );

  /// 处理点击事件
  @override
  void handleTap(BuildContext context) {
    context.push(config.route);
    AppLogger.debug("点击了miniapp，路由为：${config.route}");
  }

  @override
  Widget buildPage(BuildContext context) {
    return LogViewerPage();
  }
} 