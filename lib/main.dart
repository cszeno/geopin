import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:geopin/core/init/mini_app_initializer.dart';
import 'package:geopin/core/location/data/datasources/platform_location_data_source.dart';
import 'package:geopin/core/location/data/repositories/location_repository_impl.dart';
import 'package:geopin/core/location/domain/repositories/location_repository.dart';
import 'package:geopin/core/services/database_service.dart';
import 'package:geopin/features/mark_point/data/datasources/mark_point_local_data_source.dart';
import 'package:geopin/features/mark_point/data/repositories/mark_point_repository_impl.dart';
import 'package:geopin/features/mark_point/presentation/providers/mark_point_provider.dart';
import 'package:geopin/shared/theme/app_theme.dart';
import 'package:geopin/shared/theme/providers/theme_provider.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:geopin/core/location/providers/location_service_provider.dart';
import 'core/di/service_locator.dart';

import 'core/router/app_router.dart';
import 'core/utils/app_logger.dart';
import 'core/utils/sp_util.dart';
import 'i18n/generated/app_localizations.dart';
import 'i18n/providers/locale_provider.dart';

/// 应用入口
void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化日志系统
  await AppLogger.init(
    config: LogConfig(
      level: Level.ALL,
      fileLogLevel: Level.INFO,
      saveToFile: true,
      includeStackTrace: true,
      maxLogFiles: 7,
    ),
  );
  
  // 初始化并注册存储服务到GetIt
  await SPUtil.registerInGetIt();
  
  // 注册位置相关服务到GetIt
  final locationDataSource = PlatformLocationDataSource();
  GetIt.I.registerSingleton<PlatformLocationDataSource>(locationDataSource);
  GetIt.I.registerSingleton<LocationRepository>(LocationRepositoryImpl(locationDataSource));
  GetIt.I.registerSingleton<LocationServiceProvider>(
    LocationServiceProvider(GetIt.I<LocationRepository>())
  );
  
  // 注册UI状态Provider到GetIt
  GetIt.I.registerSingleton<LocaleProvider>(LocaleProvider());
  GetIt.I.registerSingleton<ThemeProvider>(ThemeProvider());
  
  // 初始化依赖注入
  await ServiceLocator.initDependencies();
  
  // 初始化所有MiniApp
  MiniAppInitializer.initialize();

  runApp(
      MultiProvider(
        providers: [
          // 所有Provider现在从GetIt获取
          Provider<PlatformLocationDataSource>.value(value: GetIt.I<PlatformLocationDataSource>()),
          Provider<LocationRepository>.value(value: GetIt.I<LocationRepository>()),
          ChangeNotifierProvider.value(value: GetIt.I<LocationServiceProvider>()),
          ChangeNotifierProvider.value(value: GetIt.I<LocaleProvider>()),
          ChangeNotifierProvider.value(value: GetIt.I<ThemeProvider>()),
          ChangeNotifierProvider.value(value: GetIt.I<MarkPointProvider>()),
        ],
        child: const MyApp(),
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
