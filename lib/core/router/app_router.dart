import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/location/presentation/pages/location_page.dart';

/// 应用路由配置
class AppRouter {
  /// 创建路由配置
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const LocationPage(),
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