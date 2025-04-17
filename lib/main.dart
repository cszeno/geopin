import 'package:flutter/material.dart';
import 'package:geopin/core/location/data/datasources/platform_location_data_source.dart';
import 'package:geopin/core/location/data/repositories/location_repository_impl.dart';
import 'package:geopin/core/location/domain/repositories/location_repository.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:geopin/core/location/providers/location_service_provider.dart';

import 'core/router/app_router.dart';
import 'core/utils/app_logger.dart';

/// 应用入口
void main() async {

  // 初始化日志系统
  WidgetsFlutterBinding.ensureInitialized();
  await AppLogger.init(
    config: LogConfig(
      level: Level.ALL,
      fileLogLevel: Level.INFO,
      saveToFile: true,
      includeStackTrace: true,
      maxLogFiles: 7,
    ),
  );

  runApp(
      MultiProvider(
        providers: [
          Provider<PlatformLocationDataSource>(create: (_) => PlatformLocationDataSource()),

          /// ProxyProvider<A, B>：依赖一个 Provider A，生成 Provider B
          ProxyProvider<PlatformLocationDataSource, LocationRepository>(
            update: (_, dataSource, __) => LocationRepositoryImpl(dataSource),
          ),

          ChangeNotifierProvider(create: (context) => LocationServiceProvider(
            context.read<LocationRepository>()
          )),
        ],
        child: MyApp(),
      )
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB), // 蓝色
          brightness: Brightness.light,
          primary: const Color(0xFF2563EB),
          secondary: const Color(0xFF10B981), // 绿色
          tertiary: const Color(0xFFEF4444), // 红色,
        ),
        useMaterial3: true,
        // 按钮主题
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        // 卡片主题
        cardTheme: CardTheme(
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        // AppBar主题
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.dark,
          primary: const Color(0xFF3B82F6),
          secondary: const Color(0xFF10B981),
          tertiary: const Color(0xFFEF4444),
        ),
        useMaterial3: true,
        // 按钮主题
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        // 卡片主题
        cardTheme: CardTheme(
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        // AppBar主题
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
