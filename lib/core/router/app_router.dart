import 'package:flutter/material.dart';
import 'package:geopin/core/i18n/app_localizations_extension.dart';
import 'package:geopin/features/log/presentation/pages/log_viewer_page.dart';
import 'package:geopin/features/settings/presentation/pages/language_settings_page.dart';
import 'package:geopin/features/settings/presentation/pages/settings_page.dart';
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
            
            // 设置页面
            GoRoute(
              path: 'settings',
              builder: (context, state) => const SettingsPage(),
            ),
            
            // 语言设置页面
            GoRoute(
              path: 'language-settings',
              builder: (context, state) => const LanguageSettingsPage(),
            ),
          ],
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