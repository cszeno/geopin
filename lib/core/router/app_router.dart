import 'package:flutter/material.dart';
import 'package:geopin/core/constants/mini_app_register.dart';
import 'package:geopin/core/i18n/app_localizations_extension.dart';
import 'package:geopin/features/home/presentation/pages/home_page.dart';
import 'package:geopin/features/log/presentation/pages/log_viewer_page.dart';
import 'package:geopin/features/settings/presentation/pages/settings_page.dart';
import 'package:go_router/go_router.dart';

import '../../features/location/presentation/pages/location_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';

/// 应用路由配置
class AppRouter {
  static RouterEntity splashRouter = RouterEntity(name: "splash", path: "/splash");
  static RouterEntity homeRouter = RouterEntity(name: "home", path: "/home");

  // app开头的是通过app方式进入的
  static RouterEntity appLogRouter = RouterEntity(
      name: MiniAppRegister.log.name, path: MiniAppRegister.log.route);

  static RouterEntity appSettingsRouter = RouterEntity(
      name: MiniAppRegister.settings.name,
      path: MiniAppRegister.settings.route);

  static RouterEntity appLocationTestRouter = RouterEntity(
      name: MiniAppRegister.locationTest.name,
      path: MiniAppRegister.locationTest.route);

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

        // 主页
        GoRoute(
          path: homeRouter.path,
          name: homeRouter.name,
          builder: (BuildContext context, GoRouterState state) {
            return HomePage();
          },
        ),

        // 日志界面
        GoRoute(
          path: appLogRouter.path,
          builder: (context, state) => const LogViewerPage(),
        ),

        // 设置页面
        GoRoute(
          path: appLogRouter.path,
          builder: (context, state) => const SettingsPage(),
        ),
        
        // 位置显示页面
        GoRoute(
          path: appLocationTestRouter.path,
          builder: (context, state) => const LocationPage(),
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