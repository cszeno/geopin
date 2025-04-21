import 'package:get_it/get_it.dart';
import 'package:geopin/features/mark_point/di/mark_point_injection.dart';

/// 服务定位器
/// 
/// 应用的依赖注入容器，负责管理所有依赖项
class ServiceLocator {
  // 私有构造函数，防止实例化
  ServiceLocator._();
  
  // GetIt实例
  static final GetIt _sl = GetIt.instance;

  /// 初始化所有依赖
  static void init() {
    // 注册标记点模块依赖
    MarkPointInjection.init(_sl);
    
    // TODO: 注册其他模块依赖
  }

  /// 获取GetIt实例
  static GetIt get sl => _sl;
} 