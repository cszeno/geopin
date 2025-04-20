import 'package:flutter/material.dart';
import 'package:geopin/features/mark_point/presentation/pages/mark_point_collect_page.dart';
import 'package:geopin/features/mark_point/presentation/pages/point_marker_data_page.dart';
import 'package:geopin/i18n/app_localizations_extension.dart';

import 'package:go_router/go_router.dart';

import '../../features/settings/presentation/pages/language_settings_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../shared/mini_app/domain/registry/mini_app_hub.dart';

/// 应用路由配置
class AppRouter {
  /// 启动页路由
  static RouterEntity splashRouter = RouterEntity(name: "splash", path: "/splash");
  
  /// 主页路由
  static RouterEntity homeRouter = RouterEntity(name: "home", path: "/home");


  /// 创建路由配置
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: splashRouter.path,
      routes: <RouteBase>[
        // 启动页路由
        GoRoute(
          path: splashRouter.path,
          name: splashRouter.name,
          builder: (BuildContext context, GoRouterState state) {
            return const SplashPage();
          },
        ),

        // 自动生成所有MiniApp路由
        ...MiniAppHub.instance.generateRoutes(),

        // 语言设置页面
        GoRoute(
          path: '/language-settings',
          builder: (context, state) => const LanguageSettingsPage(),
        ),
      ],


      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.pageNotFound),
        ),
        body: Center(
          child: Text(context.l10n.pathNotFound(state.uri.path)),
        ),
      ),
    );
  }
}

class RouterEntity {
  String name;
  String path;

  RouterEntity({required this.name, required this.path});
}