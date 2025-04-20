import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/abstract_mini_app.dart';
import '../models/mini_app_model.dart';

/// MiniApp注册中心
/// 
/// 单一责任：管理所有MiniApp的注册、发现和访问
class MiniAppHub {
  /// 私有构造函数，确保单例模式
  MiniAppHub._();
  
  /// 单例实例
  static final MiniAppHub _instance = MiniAppHub._();
  
  /// 获取单例实例
  static MiniAppHub get instance => _instance;
  
  /// 存储所有注册的MiniApp，按ID索引
  final Map<String, AbstractMiniApp> _apps = {};
  
  /// 注册一个MiniApp
  /// 
  /// 将MiniApp添加到注册中心
  void register(AbstractMiniApp app) {
    _apps[app.id] = app;
  }
  

  /// 获取所有注册的MiniApp
  /// 
  /// 返回所有已注册MiniApp的不可变列表
  List<AbstractMiniApp> getAllApps() {
    return List.unmodifiable(_apps.values);
  }
  
  /// 获取所有MiniApp的配置信息
  /// 
  /// 返回所有已注册MiniApp的配置信息列表
  List<MiniAppModel> getAllAppConfigs() {
    return _apps.values.map((app) => app.config).toList();
  }
  
  /// 根据ID获取MiniApp
  /// 
  /// 返回指定ID的MiniApp，如果不存在则返回null
  AbstractMiniApp? getAppById(String id) {
    return _apps[id];
  }
  
  /// 处理MiniApp点击
  /// 
  /// 统一处理MiniApp点击事件
  void handleMiniAppTap(BuildContext context, String appId) {
    final app = getAppById(appId);
    if (app != null) {
      app.handleTap(context);
    }
  }
  
  /// 获取所有MiniApp的路由配置
  /// 
  /// 为路由系统生成所有MiniApp的路由配置
  List<RouteBase> generateRoutes() {
    final List<RouteBase> routes = [];

    for (final app in _apps.values) {
      routes.add(
        app.config.enableTransitionPage ? GoRoute(
          path: app.route,
          name: app.id,
          builder: (context, state) => app.buildPage(context),
        ) :
        GoRoute(
          path: app.route,
          name: app.id,
          pageBuilder: (context, state) =>
              CustomTransitionPage(child: app.buildPage(context),
                  transitionsBuilder: (context, animation, secondaryAnimation,
                      child) {
                    return child;
                  }),
        ),
      );
    }
    
    return routes;
  }

  /// 获取MiniApp的采集页面
  ///
  /// 根据MiniApp ID获取其采集页面
  Widget? getPage(String appId, BuildContext context) {
    final app = getAppById(appId);
    if (app == null) {
      return null;
    }

    return app.buildPage(context);
  }
}