import '../../features/location/mini_app_impl.dart';
import '../../features/log/mini_app_impl.dart';
import '../../features/mark_line/mini_app_impl.dart';
import '../../features/mark_point/mini_app_impl.dart';
import '../../features/settings/mini_app_impl.dart';
import '../../shared/mini_app/domain/registry/mini_app_hub.dart';

// 这里引入更多的MiniApp实现

/// MiniApp初始化器
/// 
/// 负责初始化和注册所有MiniApp
class MiniAppInitializer {
  /// 私有构造函数防止实例化
  MiniAppInitializer._();
  
  /// 初始化所有MiniApp
  /// 
  /// 将所有MiniApp注册到MiniAppHub
  static void initialize() {
    final hub = MiniAppHub.instance;
    
    // 注册所有MiniApp
    hub.register(MarkPointMiniApp.instance);
    hub.register(MarkLineMiniApp.instance);
    hub.register(LogMiniApp.instance);
    hub.register(SettingsMiniApp.instance);
    hub.register(LocationTestMiniApp.instance);

    // 要添加新的MiniApp，只需:
    // 1. 在对应feature目录创建mini_app_impl.dart实现
    // 2. 在此处添加导入和注册语句
    
    // 例如:
    // import '../../../my_feature/mini_app_impl.dart';
    // hub.register(MyFeatureMiniApp.instance);
  }
} 