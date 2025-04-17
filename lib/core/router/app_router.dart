import 'package:flutter/material.dart';
import 'package:geopin/features/log/presentation/pages/log_viewer_page.dart';
import 'package:go_router/go_router.dart';

import '../../features/location/presentation/pages/location_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';

/// 应用路由配置
class AppRouter {
  /// 创建路由配置
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: '/splash',
      routes: <RouteBase>[
        // 启动页路由
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (BuildContext context, GoRouterState state) {
            return const SplashPage();
          },
        ),
        
        // 主页路由 - 位置显示页面
        GoRoute(
          path: '/',
          builder: (context, state) => const LocationPage(),
          routes: [
            // 日志界面 - 作为主页的子路由
            GoRoute(
              path: 'log',
              builder: (context, state) => const LogViewerPage(),
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(
          title: const Text('页面不存在'),
        ),
        body: Center(
          child: Text('找不到路径: ${state.uri.path}'),
        ),
      ),
    );
  }
} 