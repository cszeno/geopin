import 'package:get_it/get_it.dart';
import 'package:geopin/core/services/database_service.dart';
import 'package:geopin/features/mark_point/data/datasources/mark_point_local_data_source.dart';
import 'package:geopin/features/mark_point/data/datasources/mark_point_project_local_data_source.dart';
import 'package:geopin/features/mark_point/data/repositories/mark_point_repository_impl.dart';
import 'package:geopin/features/mark_point/data/repositories/mark_point_project_repository_impl.dart';
import 'package:geopin/features/mark_point/domain/repositories/mark_point_repository.dart';
import 'package:geopin/features/mark_point/domain/repositories/mark_point_project_repository.dart';
import 'package:geopin/features/mark_point/di/mark_point_injection.dart';
import 'package:geopin/features/mark_point/presentation/providers/mark_point_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';

/// 服务定位器
/// 
/// 应用的依赖注入容器，负责管理所有依赖项
class ServiceLocator {
  // 私有构造函数，防止实例化
  ServiceLocator._();
  
  // GetIt实例
  static final GetIt _sl = GetIt.instance;

  /// 初始化所有依赖（同步版本）
  static void init() {
    // 注册标记点模块依赖
    MarkPointInjection.init(_sl);
    
    // TODO: 注册其他模块依赖
  }
  
  /// 初始化所有依赖（异步版本）
  /// 
  /// 包含需要异步初始化的依赖，推荐使用此方法
  static Future<void> initDependencies() async {
    // 初始化日志
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    });

    // 初始化SharedPreferences
    if (!_sl.isRegistered<SharedPreferences>()) {
      final prefs = await SharedPreferences.getInstance();
      _sl.registerSingleton<SharedPreferences>(prefs);
    }
    
    // 初始化数据库
    final db = await DatabaseService.instance.database;
    
    // 注册数据库服务
    if (!_sl.isRegistered<DatabaseService>()) {
      _sl.registerSingleton<DatabaseService>(DatabaseService.instance);
    }
    
    // 注册数据源
    if (!_sl.isRegistered<MarkPointLocalDataSource>()) {
      _sl.registerSingleton<MarkPointLocalDataSource>(
        MarkPointLocalDataSourceImpl(database: db)
      );
    }
    
    if (!_sl.isRegistered<MarkPointProjectLocalDataSource>()) {
      _sl.registerSingleton<MarkPointProjectLocalDataSource>(
        MarkPointProjectLocalDataSource()
      );
    }
    
    // 注册仓库
    if (!_sl.isRegistered<MarkPointRepository>()) {
      _sl.registerSingleton<MarkPointRepository>(
        MarkPointRepositoryImpl()
      );
    }
    
    if (!_sl.isRegistered<MarkPointProjectRepository>()) {
      _sl.registerSingleton<MarkPointProjectRepository>(
        MarkPointProjectRepositoryImpl()
      );
    }
    
    // 注册Provider
    if (!_sl.isRegistered<MarkPointProvider>()) {
      _sl.registerSingleton<MarkPointProvider>(
        MarkPointProvider()
      );
    }
    
    // 初始化其他模块依赖
    MarkPointInjection.init(_sl);
    
    // 等待所有异步依赖准备完毕
    await _sl.allReady();
  }
  
  /// 等待所有异步依赖初始化完成
  static Future<void> allReady() async {
    await _sl.allReady();
  }

  /// 获取GetIt实例
  static GetIt get sl => _sl;
} 