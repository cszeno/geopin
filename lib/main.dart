import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:geopin/core/init/mini_app_initializer.dart';
import 'package:geopin/core/location/data/datasources/platform_location_data_source.dart';
import 'package:geopin/core/location/data/repositories/location_repository_impl.dart';
import 'package:geopin/core/location/domain/repositories/location_repository.dart';
import 'package:geopin/features/mark_point/presentation/providers/mark_point_provider.dart';
import 'package:geopin/shared/theme/app_theme.dart';
import 'package:geopin/shared/theme/providers/theme_provider.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:geopin/core/location/providers/location_service_provider.dart';

import 'core/router/app_router.dart';
import 'core/utils/app_logger.dart';
import 'core/utils/sp_util.dart';
import 'i18n/generated/app_localizations.dart';
import 'i18n/providers/locale_provider.dart';

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

  // 初始化存储服务
  final spUtil = SPUtil();
  await spUtil.init();

  // 初始化所有MiniApp
  MiniAppInitializer.initialize();

  runApp(
      MultiProvider(
        providers: [
          Provider<PlatformLocationDataSource>(create: (_) => PlatformLocationDataSource()),

          /// ProxyProvider<A, B>：依赖一个 Provider A，生成 Provider B
          ProxyProvider<PlatformLocationDataSource, LocationRepository>(
            update: (_, dataSource, __) => LocationRepositoryImpl(dataSource),
          ),

          // 添加位置服务
          ChangeNotifierProvider(create: (context) => LocationServiceProvider(
            context.read<LocationRepository>()
          )),
          
          // 添加语言设置提供者
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          
          // 添加主题设置提供者
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          
          // 标记点
          ChangeNotifierProvider(create: (_) => MarkPointProvider())
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
    // 获取语言设置
    final localeProvider = Provider.of<LocaleProvider>(context);
    // 获取主题设置
    final themeProvider = Provider.of<ThemeProvider>(context);

    // 使用GoRouter管理路由
    final router = AppRouter.createRouter();

    return MaterialApp.router(
      title: 'GeoPIN',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getLightTheme(),
      darkTheme: AppTheme.getDarkTheme(),
      themeMode: themeProvider.themeMode,
      
      // 本地化支持
      locale: localeProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh'), // 中文
        Locale('en'), // 英文
      ],
      
      routerConfig: router,
    );
  }
}
