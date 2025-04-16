import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';

/// 应用入口
void main() {
  runApp(
    // 使用ProviderScope包装应用，启用Riverpod
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

/// 应用根组件
class MyApp extends StatelessWidget {
  /// 构造函数
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用GoRouter管理路由
    final router = AppRouter.createRouter();
    
    return MaterialApp.router(
      title: 'GeoPIN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
